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

class ChatView extends ConsumerWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentConversationId = ref.watch(currentConversationProvider);
    final conversations = ref.watch(conversationsProvider);
    final currentConversation = conversations.firstWhere(
      (conv) => conv.id == currentConversationId,
    );
    final selectedModel = ref.watch(selectedModelProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final messages = currentConversation.messagesList.reversed.toList();

    return Column(
      children: [
        // 输入区域
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: () => _showAttachmentOptions(context, ref, currentConversation),
              ),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: '输入消息...',
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (text) {
                    if (text.trim().isNotEmpty) {
                      _sendMessage(text, ref, context, currentConversation, selectedModel);
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  final textField = context.findRenderObject() as RenderBox?;
                  if (textField != null) {
                    final text = (textField as dynamic).child?.child?.controller?.text ?? '';
                    if (text.trim().isNotEmpty) {
                      _sendMessage(text, ref, context, currentConversation, selectedModel);
                      (textField as dynamic).child?.child?.controller?.clear();
                    }
                  }
                },
              ),
            ],
          ),
        ),
        
        // 消息列表
        Expanded(
          child: Stack(
            children: [
              ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isUser = message.author.id == 'user';
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        if (!isUser) const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _buildMessageContent(message, context),
                          ),
                        ),
                        if (isUser) const SizedBox(width: 8),
                      ],
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
      ],
    );
  }

  Widget _buildMessageContent(types.Message message, BuildContext context) {
    if (message is types.TextMessage) {
      return Text(
        message.text,
        style: TextStyle(
          color: message.author.id == 'user'
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onBackground,
        ),
      );
    } else if (message is types.ImageMessage) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.file(
            File(message.uri),
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
          if (message.name != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                message.name!,
                style: TextStyle(
                  color: message.author.id == 'user'
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onBackground,
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
          const Icon(Icons.attach_file),
          const SizedBox(width: 8),
          Text(
            message.name,
            style: TextStyle(
              color: message.author.id == 'user'
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onBackground,
            ),
          ),
        ],
      );
    }
    return const SizedBox();
  }

  Future<void> _showAttachmentOptions(
    BuildContext context,
    WidgetRef ref,
    Conversation currentConversation,
  ) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('选择图片'),
                onTap: () => Navigator.pop(context, 'image'),
              ),
              ListTile(
                leading: const Icon(Icons.attach_file),
                title: const Text('选择文件'),
                onTap: () => Navigator.pop(context, 'file'),
              ),
            ],
          ),
        );
      },
    );

    if (result == null) return;

    switch (result) {
      case 'image':
        await _handleImageSelection(context, ref, currentConversation);
        break;
      case 'file':
        await _handleFileSelection(context, ref, currentConversation);
        break;
    }
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

    ref.read(isLoadingProvider.notifier).state = true;
    try {
      final response = await ref.read(chatServiceProvider).sendMessage(
            text,
            selectedModel,
          );

      final botMessage = types.TextMessage(
        author: const types.User(id: 'bot'),
        id: const Uuid().v4(),
        text: response,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      final newMessages = [
        ...updatedMessages,
        _messageToJson(botMessage),
      ];
      
      ref.read(conversationsProvider.notifier).updateConversation(
            currentConversation.copyWith(messages: newMessages),
          );
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

  Future<void> _handleImageSelection(
    BuildContext context,
    WidgetRef ref,
    Conversation currentConversation,
  ) async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await _saveFile(bytes, result.name);

      final message = types.ImageMessage(
        author: const types.User(id: 'user'),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        name: result.name,
        size: bytes.length,
        uri: image.path,
      );

      final updatedMessages = [
        ...currentConversation.messages,
        _messageToJson(message),
      ];

      ref.read(conversationsProvider.notifier).updateConversation(
            currentConversation.copyWith(messages: updatedMessages),
          );
    }
  }

  Future<void> _handleFileSelection(
    BuildContext context,
    WidgetRef ref,
    Conversation currentConversation,
  ) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final size = await file.length();
      final name = result.files.single.name;

      final message = types.FileMessage(
        author: const types.User(id: 'user'),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        name: name,
        size: size,
        uri: file.path,
      );

      final updatedMessages = [
        ...currentConversation.messages,
        _messageToJson(message),
      ];

      ref.read(conversationsProvider.notifier).updateConversation(
            currentConversation.copyWith(messages: updatedMessages),
          );
    }
  }

  Future<File> _saveFile(List<int> bytes, String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$name');
    await file.writeAsBytes(bytes);
    return file;
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