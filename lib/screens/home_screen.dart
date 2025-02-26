import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:ai_app/providers/chat_provider.dart';
import 'package:ai_app/providers/conversation_provider.dart';
import 'package:ai_app/providers/model_provider.dart';
import 'package:ai_app/models/ai_model.dart';
import 'package:ai_app/models/conversation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:uuid/uuid.dart';
import 'package:ai_app/widgets/home/chat_input.dart';
import 'package:ai_app/widgets/home/message_list.dart';
import 'package:ai_app/widgets/conversation_drawer.dart';
import 'package:ai_app/widgets/model_selector.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:developer' as developer;

/// 主屏幕
/// 包含聊天界面、模型选择器和会话抽屉
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  // 控制器
  final textController = TextEditingController();
  final scrollController = ScrollController();
  final focusNode = FocusNode();
  
  // 语音相关
  bool isVoiceMode = false;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';
  
  // 滚动相关
  bool _showScrollToBottom = false;
  
  // 动画相关
  AnimationController? _animationController;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initAnimation();
    _initScrollListener();
    _createNewConversationIfNeeded();
    _requestFocusAfterDelay();
    
    // 初始化完成后打印日志
    developer.log('HomeScreen initialized');
    
    // 监听焦点变化
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        developer.log('Input field focused');
      }
    });
    
    // 初始化语音动画
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController!);
    
    developer.log('Animation controller initialized');
  }

  /// 初始化语音识别
  Future<void> _initSpeech() async {
    _speech = stt.SpeechToText();
    try {
      var hasSpeech = await _speech.initialize(
        onError: (error) {
          developer.log('语音识别错误: ${error.errorMsg}');
          setState(() => _isListening = false);
        },
        onStatus: (status) {
          developer.log('语音识别状态: $status');
          if (status == 'done' && _isListening) {
            _handleVoiceButtonReleased();
          }
        },
        finalTimeout: const Duration(seconds: 5),
        debugLogging: true,
      );

      if (hasSpeech) {
        var systemLocale = await _speech.systemLocale();
        var supportedLocales = await _speech.locales();
        
        var zhLocale = supportedLocales.firstWhere(
          (locale) => locale.localeId.startsWith('zh'),
          orElse: () => systemLocale!,
        );
        
        developer.log('选择的语言: ${zhLocale.localeId}');
      }
    } catch (e) {
      developer.log('语音识别初始化错误: $e');
    }
  }

  /// 初始化动画控制器
  void _initAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    if (_animationController != null) {
      _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController!);
    }
  }

  /// 初始化滚动监听
  void _initScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels > 300 && !_showScrollToBottom) {
        setState(() => _showScrollToBottom = true);
      } else if (scrollController.position.pixels <= 300 && _showScrollToBottom) {
        setState(() => _showScrollToBottom = false);
      }
    });
  }

  /// 如果没有当前会话，创建新会话
  void _createNewConversationIfNeeded() {
    Future.microtask(() async {
      final currentConversationId = ref.read(currentConversationProvider);
      if (currentConversationId == null) {
        final now = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
        await ref
            .read(currentConversationProvider.notifier)
            .createAndSetNewConversation('新对话 $now');
      }
    });
  }

  /// 延迟请求焦点
  void _requestFocusAfterDelay() {
    Future.delayed(const Duration(milliseconds: 100), () {
      focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    textController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    _speech.cancel();
    _animationController?.dispose();
    super.dispose();
  }

  /// 处理语音按钮按下
  Future<void> _handleVoiceButtonPressed() async {
    final hasMicPermission = await Permission.microphone.request().isGranted;
    if (!hasMicPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('需要麦克风权限才能使用语音功能')),
        );
      }
      return;
    }

    if (!_speech.isAvailable) {
      await _initSpeech();
      if (!_speech.isAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('语音识别服务不可用')),
          );
        }
        return;
      }
    }

    setState(() {
      _isListening = true;
      _recognizedText = '';
    });

    _animationController?.repeat(reverse: true);

    try {
      await _speech.listen(
        onResult: (result) {
          setState(() {
            if (result.finalResult) {
              _recognizedText = result.recognizedWords;
            }
          });
        },
        localeId: 'zh_CN',
      );
    } catch (e) {
      developer.log('开始语音识别错误: $e');
      setState(() => _isListening = false);
      _animationController?.stop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('开始语音识别失败: $e')),
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
        _animationController?.stop();

        await Future.delayed(const Duration(milliseconds: 500));

        if (_recognizedText.isNotEmpty) {
          final currentConversationId = ref.read(currentConversationProvider);
          if (currentConversationId != null) {
            final conversations = ref.read(conversationsProvider);
            final conversation = conversations.firstWhere(
              (conv) => conv.id == currentConversationId,
            );
            final selectedModel = ref.read(selectedModelProvider);
            
            await _sendMessage(_recognizedText, conversation, selectedModel);
            setState(() => _recognizedText = '');
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('请先创建或选择一个对话')),
              );
            }
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
      _animationController?.stop();
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
          focusNode.requestFocus();
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
                      scrollController: scrollController,
                      showScrollToBottom: _showScrollToBottom,
                      onScrollToBottom: () {
                        scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      },
                    ),
            ),
            ChatInput(
              textController: textController,
              focusNode: focusNode,
              isVoiceMode: isVoiceMode,
              isListening: _isListening,
              voiceAnimation: _animation,
              onVoiceModeToggle: _toggleInputMode,
              onVoiceLongPressStart: _handleVoiceButtonPressed,
              onVoiceLongPressEnd: _handleVoiceButtonReleased,
              selectedModel: selectedModel,
              onSendMessage: (text) {
                if (currentConversationId != null) {
                  final conversation = conversations.firstWhere(
                    (conv) => conv.id == currentConversationId,
                  );
                  _sendMessage(text, conversation, selectedModel);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
} 