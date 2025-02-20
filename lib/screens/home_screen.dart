import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:ai_app/providers/chat_provider.dart';
import 'package:ai_app/providers/model_provider.dart';
import 'package:ai_app/providers/conversation_provider.dart';
import 'package:ai_app/models/conversation.dart';
import 'package:ai_app/models/ai_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ai_app/widgets/markdown_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ai_app/widgets/model_selector.dart';
import 'package:ai_app/widgets/conversation_drawer.dart';
import 'package:ai_app/providers/theme_provider.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  final textController = TextEditingController();
  final scrollController = ScrollController();
  final focusNode = FocusNode();
  bool isVoiceMode = false;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';
  
  // 动画相关变量
  AnimationController? _animationController;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeechState();
    _initAnimationController();
    
    // 延迟100毫秒后自动弹出键盘
    Future.delayed(const Duration(milliseconds: 100), () {
      focusNode.requestFocus();
    });
  }

  void _initAnimationController() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    if (_animationController != null) {
      _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController!);
    }
  }

  // 初始化语音识别状态
  Future<void> _initSpeechState() async {
    try {
      var hasSpeech = await _speech.initialize(
        onError: (error) {
          print('语音识别错误: ${error.errorMsg}');
          setState(() => _isListening = false);
        },
        onStatus: (status) {
          print('语音识别状态: $status');
          if (status == 'done' && _isListening) {
            _handleVoiceButtonReleased();
          }
        },
        finalTimeout: const Duration(seconds: 5),
        debugLogging: true,
      );

      if (hasSpeech) {
        // 获取可用的语音识别语言
        var systemLocale = await _speech.systemLocale();
        var supportedLocales = await _speech.locales();
        
        print('系统语言: ${systemLocale?.localeId}');
        print('支持的语言: ${supportedLocales.map((locale) => locale.localeId).join(', ')}');
        
        // 检查是否支持中文
        var zhLocale = supportedLocales.firstWhere(
          (locale) => locale.localeId.startsWith('zh'),
          orElse: () => systemLocale!,
        );
        
        print('选择的语言: ${zhLocale.localeId}');
      } else {
        print('语音识别初始化失败');
      }
    } catch (e) {
      print('语音识别初始化错误: $e');
    }
  }

  // 处理语音按钮按下
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
      print('语音识别服务不可用，尝试重新初始化...');
      await _initSpeechState();
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

    // 开始动画
    if (_animationController != null) {
      _animationController!.repeat(reverse: true);
    }

    try {
      await _speech.listen(
        onResult: (result) {
          print('识别结果: ${result.recognizedWords}');
          setState(() {
            // 只在结果是最终结果时更新文本
            if (result.finalResult) {
              _recognizedText = result.recognizedWords;
              print('最终识别结果: $_recognizedText');
            }
          });
        },
        localeId: 'zh_CN',
        listenMode: stt.ListenMode.dictation,  // 使用听写模式
        partialResults: false,  // 不需要部分结果
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      );
    } catch (e) {
      print('开始语音识别错误: $e');
      setState(() => _isListening = false);
      // 停止动画
      if (_animationController != null) {
        _animationController!.stop();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('开始语音识别失败: $e')),
        );
      }
    }
  }

  // 处理语音按钮释放
  void _handleVoiceButtonReleased() async {
    try {
      if (_isListening) {
        print('停止语音识别...');
        await _speech.stop();
        setState(() {
          _isListening = false;
        });

        // 停止动画
        if (_animationController != null) {
          _animationController!.stop();
        }

        // 等待一小段时间确保获取到最终结果
        await Future.delayed(const Duration(milliseconds: 500));

        if (_recognizedText.isNotEmpty) {
          print('发送识别到的文字: $_recognizedText');
          final currentConversationId = ref.read(currentConversationProvider);
          if (currentConversationId != null) {
            final conversations = ref.read(conversationsProvider);
            final conversation = conversations.firstWhere(
              (conv) => conv.id == currentConversationId,
            );
            final selectedModel = ref.read(selectedModelProvider);
            
            // 将识别到的文本作为消息发送
            await _sendMessage(_recognizedText, ref, context, conversation, selectedModel);
            
            // 清空识别的文本
            setState(() {
              _recognizedText = '';
            });
          } else {
            print('没有选中的对话');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('请先创建或选择一个对话')),
              );
            }
          }
        } else {
          print('没有识别到文字');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('没有识别到文字，请重试')),
            );
          }
        }
      }
    } catch (e) {
      print('停止语音识别错误: $e');
      setState(() {
        _isListening = false;
      });
      // 停止动画
      if (_animationController != null) {
        _animationController!.stop();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('停止语音识别失败: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    textController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    _speech.cancel();
    if (_animationController != null) {
      _animationController!.dispose();
    }
    super.dispose();
  }

  // 切换输入模式
  void _toggleInputMode() {
    setState(() {
      isVoiceMode = !isVoiceMode;
      if (!isVoiceMode) {
        // 切换回键盘模式时自动弹出键盘
        Future.delayed(const Duration(milliseconds: 100), () {
          focusNode.requestFocus();
        });
      } else {
        // 切换到语音模式时收起键盘
        FocusScope.of(context).unfocus();
      }
    });
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
        drawer: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: const ConversationDrawer(),
        ),
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
          title: const Text('AI Chat'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                FocusScope.of(context).unfocus();
                final now = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
                await ref
                    .read(currentConversationProvider.notifier)
                    .createAndSetNewConversation('新对话 $now');
              },
            ),
            GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: const ModelSelector(),
            ),
          ],
        ),
        body: Column(
          children: [
            // 消息列表区域
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
                  : Stack(
                      children: [
                        ListView.builder(
                          controller: scrollController,
                          reverse: true,
                          padding: const EdgeInsets.all(8),
                          itemCount: conversations
                              .firstWhere((conv) => conv.id == currentConversationId)
                              .messagesList
                              .reversed
                              .length,
                          itemBuilder: (context, index) {
                            final message = conversations
                                .firstWhere((conv) => conv.id == currentConversationId)
                                .messagesList
                                .reversed
                                .toList()[index];
                            final isUser = message.author.id == 'user';
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Center(
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 1,
                                  child: Row(
                                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          constraints: BoxConstraints(
                                            maxWidth: isUser 
                                                ? MediaQuery.of(context).size.width * 0.7
                                                : MediaQuery.of(context).size.width * 1,
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: isUser
                                                ? const Color(0xFF2AAF62)
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.05),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: _buildMessageContent(message, context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        if (isLoading)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withOpacity(0.3),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SpinKitDoubleBounce(
                                      color: Theme.of(context).colorScheme.primary,
                                      size: 50.0,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      '正在思考...',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onBackground,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
            
            // 底部输入区域
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    if (selectedModel.id == 'deepseek-r1')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            _buildFeatureButton(
                              icon: Icons.psychology_outlined,
                              label: '深度思考(R1)',
                              isEnabled: selectedModel.enableDeepThinking,
                            ),
                            const SizedBox(width: 8),
                            _buildFeatureButton(
                              icon: Icons.search_outlined,
                              label: '联网搜索',
                              isEnabled: selectedModel.enableSearch,
                            ),
                          ],
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(
                              isVoiceMode ? Icons.keyboard : Icons.mic_none_outlined,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            onPressed: _toggleInputMode,
                            tooltip: isVoiceMode ? '切换键盘' : '切换语音',
                          ),
                          Expanded(
                            child: Container(
                              constraints: const BoxConstraints(maxHeight: 120),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: isVoiceMode
                                  ? GestureDetector(
                                      onLongPress: _handleVoiceButtonPressed,
                                      onLongPressEnd: (_) => _handleVoiceButtonReleased(),
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(24),
                                          border: Border.all(
                                            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                                          ),
                                          color: _isListening 
                                            ? const Color(0xFF2AAF62).withOpacity(0.2)
                                            : null,
                                        ),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            if (_isListening && _animation != null)
                                              AnimatedBuilder(
                                                animation: _animation!,
                                                builder: (context, child) {
                                                  return Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: List.generate(3, (index) {
                                                      return Container(
                                                        margin: const EdgeInsets.symmetric(horizontal: 2),
                                                        width: 3,
                                                        height: 12 + (10 * _animation!.value * ((index + 1) % 2)),
                                                        decoration: BoxDecoration(
                                                          color: const Color(0xFF2AAF62),
                                                          borderRadius: BorderRadius.circular(1.5),
                                                        ),
                                                      );
                                                    }),
                                                  );
                                                },
                                              ),
                                            Text(
                                              _isListening ? '松开发送' : '按住说话',
                                              style: TextStyle(
                                                color: _isListening 
                                                  ? const Color(0xFF2AAF62)
                                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : TextField(
                                      controller: textController,
                                      focusNode: focusNode,
                                      decoration: InputDecoration(
                                        hintText: '有问题，尽管问',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(24),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                      ),
                                      maxLines: null,
                                      textInputAction: TextInputAction.send,
                                      onSubmitted: (text) {
                                        if (text.trim().isNotEmpty && currentConversationId != null) {
                                          final conversation = conversations.firstWhere(
                                            (conv) => conv.id == currentConversationId,
                                          );
                                          _sendMessage(text, ref, context, conversation, selectedModel);
                                          textController.clear();
                                          focusNode.requestFocus();
                                        }
                                      },
                                    ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () {
                              if (isVoiceMode) return;  // 语音模式下禁用发送按钮
                              final text = textController.text;
                              if (text.trim().isNotEmpty && currentConversationId != null) {
                                final conversation = conversations.firstWhere(
                                  (conv) => conv.id == currentConversationId,
                                );
                                _sendMessage(text, ref, context, conversation, selectedModel);
                                textController.clear();
                                focusNode.requestFocus();
                              }
                            },
                            tooltip: '发送',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(types.Message message, BuildContext context) {
    if (message is types.TextMessage) {
      return MarkdownText(
        text: message.text,
        textColor: message.author.id == 'user'
            ? Colors.white
            : Theme.of(context).colorScheme.onSurface,
        maxWidth: MediaQuery.of(context).size.width * 0.9,
      );
    } else if (message is types.ImageMessage) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(message.uri),
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          if (message.name != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                message.name!,
                style: TextStyle(
                  color: message.author.id == 'user'
                      ? Colors.white.withOpacity(0.7)
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      );
    } else if (message is types.FileMessage) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.attach_file,
            color: message.author.id == 'user'
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message.name,
              style: TextStyle(
                color: message.author.id == 'user'
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      );
    }
    return const SizedBox();
  }

  Widget _buildFeatureButton({
    required IconData icon,
    required String label,
    required bool isEnabled,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            if (isEnabled)
              Container(
                margin: const EdgeInsets.only(left: 4),
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage(
    String text,
    WidgetRef ref,
    BuildContext context,
    Conversation currentConversation,
    AIModel selectedModel,
  ) async {
    final textMessage = types.TextMessage(
      author: const types.User(id: 'user'),
      id: const Uuid().v4(),
      text: text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
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
      createdAt: DateTime.now().millisecondsSinceEpoch,
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发送消息失败：$e')),
        );
      }
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

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
} 