import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:ai_app/providers/chat_provider.dart';
import 'package:ai_app/providers/model_provider.dart';

class ChatView extends ConsumerWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatMessagesProvider);
    final selectedModel = ref.watch(selectedModelProvider);

    return Chat(
      messages: messages,
      onSendPressed: (types.PartialText message) {
        ref.read(chatMessagesProvider.notifier).sendMessage(
          types.TextMessage(
            author: const types.User(id: 'user'),
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: message.text,
          ),
        );
      },
      user: const types.User(id: 'user'),
      theme: DefaultChatTheme(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        primaryColor: Theme.of(context).colorScheme.primary,
        secondaryColor: Theme.of(context).colorScheme.secondary,
        userAvatarNameColors: [Theme.of(context).colorScheme.primary],
      ),
    );
  }
} 