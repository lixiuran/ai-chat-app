import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:ai_app/widgets/home/chat_input.dart';
import 'package:ai_app/widgets/home/message_list.dart';
import 'package:ai_app/widgets/conversation_drawer.dart';
import 'package:ai_app/widgets/model_selector.dart';
import 'package:ai_app/providers/conversation_provider.dart';
import 'package:ai_app/providers/chat_provider.dart';
import 'package:ai_app/providers/model_provider.dart';
import 'package:ai_app/models/ai_model.dart';
import 'package:ai_app/models/conversation.dart';

/// 主屏幕
/// 包含聊天界面、模型选择器和会话抽屉
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late TextEditingController textController;
  late FocusNode textFocusNode;
  late AnimationController _animationController;
  bool _isListening = false;
  final SpeechToText _speech = SpeechToText();
  LocaleName? _currentLocale;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToBottom = false;
  bool isVoiceMode = false;
  
  // 动画控制器
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    // 初始化控制器
    textController = TextEditingController();
    textFocusNode = FocusNode();
    
    // 初始化动画控制器
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    // 初始化语音识别
    _initSpeech();
    
    // 监听滚动
    _scrollController.addListener(_scrollListener);
    
    // 监听焦点变化
    textFocusNode.addListener(() {
      if (textFocusNode.hasFocus) {
        developer.log('Input field focused');
      }
    });
    
    // 请求焦点
    _requestFocusAfterDelay();
    
    // 初始化完成后打印日志
    developer.log('HomeScreen initialized');
  }

  /// 初始化语音识别
  Future<void> _initSpeech() async {
    try {
      final available = await _speech.initialize(
        onError: (error) => developer.log('语音识别错误: $error'),
        onStatus: (status) => developer.log('语音识别状态: $status'),
      );

      if (available) {
        var locales = await _speech.locales();
        
        // 尝试找到中文语言
        var zhLocale = locales.where((locale) => 
          locale.localeId.startsWith('zh') || 
          locale.name.toLowerCase().contains('chinese')
        ).toList();
        
        if (zhLocale.isNotEmpty) {
          setState(() {
            _currentLocale = zhLocale.first;
          });
          developer.log('设置语音识别语言为: ${zhLocale.first.name}');
        } else {
          developer.log('未找到中文语言，将使用默认语言');
        }
      } else {
        developer.log('语音识别不可用');
      }
    } catch (e) {
      developer.log('初始化语音识别失败: $e');
    }
  }

  /// 初始化滚动监听
  void _scrollListener() {
    if (_scrollController.position.pixels > 300 && !_showScrollToBottom) {
      setState(() => _showScrollToBottom = true);
    } else if (_scrollController.position.pixels <= 300 && _showScrollToBottom) {
      setState(() => _showScrollToBottom = false);
    }
  }

  /// 请求焦点
  void _requestFocusAfterDelay() {
    Future.delayed(const Duration(milliseconds: 100), () {
      textFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    textController.dispose();
    _scrollController.dispose();
    textFocusNode.dispose();
    _speech.cancel();
    _animationController.dispose();
    super.dispose();
  }

  /// 处理语音按钮按下事件
  Future<void> _handleVoiceButtonPressed() async {
    setState(() {
      _isListening = true;
    });

    _animationController.repeat(reverse: true);

    try {
      await _speech.listen(
        onResult: (result) {
          setState(() {
            if (result.finalResult) {
              textController.text = result.recognizedWords;
            }
          });
        },
        localeId: _currentLocale?.localeId,
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.confirmation,
          cancelOnError: true,
          partialResults: true,
        ),
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      );
    } catch (e) {
      developer.log('开始语音识别错误: $e');
      setState(() => _isListening = false);
      _animationController.stop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('语音识别失败: $e')),
        );
      }
    }
  }

  /// 处理语音按钮释放
  void _handleVoiceButtonReleased() async {
    try {
      if (_isListening) {
        await _speech.stop();
        setState(() => _isListening = false);
        _animationController.stop();

        // 确保在处理文本前语音识别已完全停止
        await Future.delayed(const Duration(milliseconds: 500));

        if (textController.text.isNotEmpty) {
          final currentConversationId = ref.read(currentConversationProvider);
          if (currentConversationId != null) {
            final conversations = ref.read(conversationsProvider);
            final conversation = conversations.firstWhere(
              (conv) => conv.id == currentConversationId,
            );
            final selectedModel = ref.read(selectedModelProvider);
            
            await _sendMessage(textController.text, conversation, selectedModel);
            textController.clear();
          } else {
            // 如果没有当前会话，自动创建一个新会话
            final now = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
            
            // 创建新会话对象
            final newConversation = Conversation(
              id: const Uuid().v4(),
              title: '新对话 $now',
              createdAt: DateTime.now(),
            );
            
            // 先创建会话
            final newConversationId = await ref
                .read(conversationsProvider.notifier)
                .createConversation(newConversation.title);
            
            // 设置为当前会话
            await ref
                .read(currentConversationProvider.notifier)
                .setCurrentConversation(newConversationId);
            
            // 等待一下确保状态更新
            await Future.delayed(const Duration(milliseconds: 100));
            
            // 重新获取最新的conversations列表
            final updatedConversations = ref.read(conversationsProvider);
            
            // 获取新创建的会话，如果找不到就使用我们预先创建的对象
            Conversation conversationToUse;
            try {
              conversationToUse = updatedConversations.firstWhere(
                (conv) => conv.id == newConversationId,
              );
            } catch (e) {
              // 如果找不到，使用我们预先创建的对象
              conversationToUse = newConversation.copyWith(id: newConversationId);
              developer.log('找不到新创建的会话，使用预创建对象: $e');
            }
            
            final selectedModel = ref.read(selectedModelProvider);
            
            // 发送消息
            await _sendMessage(textController.text, conversationToUse, selectedModel);
            textController.clear();
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  '没有识别到文字，请重试',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                backgroundColor: Color(0xFF2AAF62),
                duration: Duration(seconds: 1),
              ),
            );
          }
        }
      }
    } catch (e) {
      developer.log('停止语音识别错误: $e');
      setState(() => _isListening = false);
      _animationController.stop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('停止语音识别失败: $e')),
        );
      }
    }
  }

  /// 切换输入模式
  void _toggleInputMode() {
    setState(() {
      isVoiceMode = !isVoiceMode;
      if (!isVoiceMode) {
        Future.delayed(const Duration(milliseconds: 100), () {
          textFocusNode.requestFocus();
        });
      } else {
        FocusScope.of(context).unfocus();
      }
    });
  }

  /// 发送消息
  Future<void> _sendMessage(
    String text,
    Conversation currentConversation,
    AIModel selectedModel,
  ) async {
    final textMessage = types.TextMessage(
      author: const types.User(id: 'user'),
      id: const Uuid().v4(),
      text: text,
      createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );

    final updatedMessages = [
      ...currentConversation.messages,
      _messageToJson(textMessage),
    ];
    
    ref.read(conversationsProvider.notifier).updateConversation(
          currentConversation.copyWith(messages: updatedMessages),
        );

    final botMessage = types.TextMessage(
      author: const types.User(id: 'bot'),
      id: const Uuid().v4(),
      text: '',
      createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );

    final messagesWithBot = [
      ...updatedMessages,
      _messageToJson(botMessage),
    ];

    ref.read(conversationsProvider.notifier).updateConversation(
          currentConversation.copyWith(messages: messagesWithBot),
        );

    ref.read(isLoadingProvider.notifier).state = true;
    try {
      String fullResponse = '';
      bool hasStartedReceiving = false;
      final responseStream = ref.read(chatServiceProvider).sendMessageStream(
            text,
            selectedModel,
          );

      await for (final chunk in responseStream) {
        if (!hasStartedReceiving) {
          hasStartedReceiving = true;
          ref.read(isLoadingProvider.notifier).state = false;
        }
        
        fullResponse += chunk;
        final updatedBotMessage = types.TextMessage(
          author: const types.User(id: 'bot'),
          id: botMessage.id,
          text: fullResponse,
          createdAt: botMessage.createdAt,
        );

        final newMessages = [
          ...updatedMessages,
          _messageToJson(updatedBotMessage),
        ];
        
        ref.read(conversationsProvider.notifier).updateConversation(
              currentConversation.copyWith(messages: newMessages),
            );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发送消息失败：$e')),
        );
      }
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  /// 将消息对象转换为JSON格式
  Map<String, dynamic> _messageToJson(types.Message message) {
    if (message is types.TextMessage) {
      return {
        'type': 'text',
        'author': {'id': message.author.id},
        'id': message.id,
        'text': message.text,
        'createdAt': message.createdAt,
      };
    } else if (message is types.ImageMessage) {
      return {
        'type': 'image',
        'author': {'id': message.author.id},
        'id': message.id,
        'uri': message.uri,
        'name': message.name,
        'size': message.size,
        'createdAt': message.createdAt,
      };
    } else if (message is types.FileMessage) {
      return {
        'type': 'file',
        'author': {'id': message.author.id},
        'id': message.id,
        'uri': message.uri,
        'name': message.name,
        'size': message.size,
        'createdAt': message.createdAt,
      };
    }
    throw UnimplementedError('Message type not supported');
  }

  @override
  Widget build(BuildContext context) {
    final currentConversationId = ref.watch(currentConversationProvider);
    final conversations = ref.watch(conversationsProvider);
    final selectedModel = ref.watch(selectedModelProvider);
    final isLoading = ref.watch(isLoadingProvider);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        drawer: const ConversationDrawer(),
        appBar: AppBar(
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                FocusScope.of(context).unfocus();
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          title: const ModelSelector(),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.post_add_rounded),
              tooltip: '新建对话',
              onPressed: () async {
                FocusScope.of(context).unfocus();
                final now = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
                await ref
                    .read(currentConversationProvider.notifier)
                    .createAndSetNewConversation('新对话 $now');
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: currentConversationId == null
                  ? Center(
                      child: Text(
                        'Hi ~ 我是 AI Chat，快来体验吧',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : MessageList(
                      messages: conversations
                          .firstWhere((conv) => conv.id == currentConversationId)
                          .messagesList
                          .reversed
                          .toList(),
                      isLoading: isLoading,
                      scrollController: _scrollController,
                      showScrollToBottom: _showScrollToBottom,
                      onScrollToBottom: () {
                        _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      },
                    ),
            ),
            ChatInput(
              textController: textController,
              focusNode: textFocusNode,
              isVoiceMode: isVoiceMode,
              isListening: _isListening,
              voiceAnimation: _animation,
              onVoiceModeToggle: _toggleInputMode,
              onVoiceLongPressStart: _handleVoiceButtonPressed,
              onVoiceLongPressEnd: _handleVoiceButtonReleased,
              selectedModel: selectedModel,
              onSendMessage: (text) async {
                if (currentConversationId != null) {
                  final conversation = conversations.firstWhere(
                    (conv) => conv.id == currentConversationId,
                  );
                  _sendMessage(text, conversation, selectedModel);
                } else {
                  // 如果没有当前会话，自动创建一个新会话
                  final now = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
                  
                  // 创建新会话对象
                  final newConversation = Conversation(
                    id: const Uuid().v4(),
                    title: '新对话 $now',
                    createdAt: DateTime.now(),
                  );
                  
                  // 先创建会话
                  final newConversationId = await ref
                      .read(conversationsProvider.notifier)
                      .createConversation(newConversation.title);
                  
                  // 设置为当前会话
                  await ref
                      .read(currentConversationProvider.notifier)
                      .setCurrentConversation(newConversationId);
                  
                  // 等待一下确保状态更新
                  await Future.delayed(const Duration(milliseconds: 100));
                  
                  // 重新获取最新的conversations列表
                  final updatedConversations = ref.read(conversationsProvider);
                  
                  // 获取新创建的会话，如果找不到就使用我们预先创建的对象
                  Conversation conversationToUse;
                  try {
                    conversationToUse = updatedConversations.firstWhere(
                      (conv) => conv.id == newConversationId,
                    );
                  } catch (e) {
                    // 如果找不到，使用我们预先创建的对象
                    conversationToUse = newConversation.copyWith(id: newConversationId);
                    developer.log('找不到新创建的会话，使用预创建对象: $e');
                  }
                  
                  // 发送消息
                  _sendMessage(text, conversationToUse, selectedModel);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
} 