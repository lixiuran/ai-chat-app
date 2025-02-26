import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:ai_app/providers/chat_provider.dart';
import 'package:ai_app/providers/model_provider.dart';
import 'package:ai_app/providers/conversation_provider.dart';
import 'package:ai_app/models/conversation.dart';
import 'package:ai_app/models/ai_model.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ai_app/widgets/markdown_text.dart';

/// 聊天界面组件
/// 实现了消息列表显示、消息发送、文件上传等功能
class ChatView extends ConsumerWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取当前会话ID和会话列表
    final currentConversationId = ref.watch(currentConversationProvider);
    final conversations = ref.watch(conversationsProvider);
    final currentConversation = conversations.firstWhere(
      (conv) => conv.id == currentConversationId,
    );
    
    // 获取选中的AI模型和加载状态
    final selectedModel = ref.watch(selectedModelProvider);
    final isLoading = ref.watch(isLoadingProvider);
    
    // 获取消息列表并反转顺序（最新的消息在底部）
    final messages = currentConversation.messagesList.reversed.toList();
    
    // 创建文本输入控制器和滚动控制器
    final textController = TextEditingController();
    final scrollController = ScrollController();
    final focusNode = FocusNode();

    // 不再自动聚焦
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   focusNode.requestFocus();
    // });

    return Column(
      children: [
        // 消息列表区域
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: [
                messages.isEmpty
                    ? Center(
                        child: Text(
                          'Hi ~ 我是 AI Chat，快来体验吧',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        reverse: true,  // 反向列表，新消息在底部
                        padding: const EdgeInsets.all(8),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isUser = message.author.id == 'user';
                          
                          // 构建单个消息项
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Center(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 1,
                                child: Row(
                                  // 用户消息靠右，机器人消息居中
                                  mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        constraints: BoxConstraints(
                                          // 用户消息宽度70%，机器人消息宽度100%
                                          maxWidth: isUser 
                                              ? MediaQuery.of(context).size.width * 0.7
                                              : MediaQuery.of(context).size.width * 1,
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                        decoration: BoxDecoration(
                                          // 用户消息使用绿色背景，机器人消息使用白色背景
                                          color: isUser
                                              ? const Color(0xFF2AAF62)
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withAlpha(13),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: _buildMessageContent(message, ref),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                // 加载状态指示器
                if (isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withAlpha(77),
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
                                color: Theme.of(context).colorScheme.onSurface,
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
        ),
        
        // 底部输入区域
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
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
                        icon: const Icon(Icons.mic_none_outlined),
                        onPressed: () {
                        },
                        tooltip: '语音输入',
                      ),
                      Expanded(
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 120),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(128),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
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
                              if (text.trim().isNotEmpty) {
                                _sendMessage(text, ref, context, currentConversation, selectedModel);
                                textController.clear();
                                // 发送后重新聚焦
                                focusNode.requestFocus();
                              }
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          final text = textController.text;
                          if (text.trim().isNotEmpty) {
                            _sendMessage(text, ref, context, currentConversation, selectedModel);
                            textController.clear();
                            // 发送后重新聚焦
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
    );
  }

  /// 构建消息内容
  /// 支持文本消息、图片消息和文件消息
  Widget _buildMessageContent(types.Message message, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider);
    final context = ref.context;
    
    if (message is types.TextMessage) {
      // 如果是空消息且正在加载，显示加载动画
      if (!message.author.id.contains('user') && 
          message.text.isEmpty && 
          isLoading) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SpinKitThreeBounce(
              color: Theme.of(context).colorScheme.primary,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              '思考中...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
          ],
        );
      }
      
      // 显示文本消息
      return MarkdownText(
        text: message.text,
        textColor: message.author.id == 'user'
            ? Colors.white
            : Theme.of(context).colorScheme.onSurface,
        maxWidth: MediaQuery.of(context).size.width * 0.9,
      );
    } else if (message is types.ImageMessage) {
      // 显示图片消息
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
          if (message.name.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                message.name,
                style: TextStyle(
                  color: message.author.id == 'user'
                      ? Colors.white.withAlpha(179)
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      );
    } else if (message is types.FileMessage) {
      // 文件消息显示文件图标和文件名
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

  /// 发送消息
  /// 支持流式输出，实时显示AI响应
  Future<void> _sendMessage(
    String text,
    WidgetRef ref,
    BuildContext context,
    Conversation currentConversation,
    AIModel selectedModel,
  ) async {
    // 创建用户消息
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
    
    // 更新会话消息
    ref.read(conversationsProvider.notifier).updateConversation(
          currentConversation.copyWith(messages: updatedMessages),
        );

    // 创建空的机器人消息用于流式更新
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

    // 开始加载状态
    ref.read(isLoadingProvider.notifier).state = true;
    try {
      String fullResponse = '';
      bool hasStartedReceiving = false;
      // 获取AI响应流
      final responseStream = ref.read(chatServiceProvider).sendMessageStream(
            text,
            selectedModel,
          );

      // 处理流式响应
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
        
        // 更新消息显示
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

  Widget _buildFeatureButton({
    required IconData icon,
    required String label,
    required bool isEnabled,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha(26),
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
} 