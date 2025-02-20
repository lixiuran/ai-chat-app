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

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final textController = TextEditingController();
  final scrollController = ScrollController();
  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // 延迟100毫秒后自动弹出键盘
    Future.delayed(const Duration(milliseconds: 100), () {
      focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    textController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    super.dispose();
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
                            icon: const Icon(Icons.mic_none_outlined),
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              // TODO: 实现语音输入
                            },
                            tooltip: '语音输入',
                          ),
                          Expanded(
                            child: Container(
                              constraints: const BoxConstraints(maxHeight: 120),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
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