import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_app/providers/conversation_provider.dart';
import 'package:ai_app/models/conversation.dart';
import 'package:intl/intl.dart';

class ConversationDrawer extends ConsumerWidget {
  const ConversationDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(conversationsProvider);
    final currentConversationId = ref.watch(currentConversationProvider);

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Center(
              child: Text(
                '对话历史',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('新建对话'),
            onTap: () async {
              final now = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
              final id = await ref
                  .read(currentConversationProvider.notifier)
                  .createAndSetNewConversation('新对话 $now');
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                return ListTile(
                  selected: conversation.id == currentConversationId,
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: Text(conversation.title),
                  subtitle: Text(
                    DateFormat('yyyy-MM-dd HH:mm')
                        .format(conversation.createdAt),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('删除对话'),
                          content: const Text('确定要删除这个对话吗？'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('取消'),
                            ),
                            TextButton(
                              onPressed: () {
                                ref
                                    .read(conversationsProvider.notifier)
                                    .deleteConversation(conversation.id);
                                if (conversation.id == currentConversationId) {
                                  ref
                                      .read(currentConversationProvider.notifier)
                                      .setCurrentConversation(null);
                                }
                                Navigator.pop(context);
                              },
                              child: const Text('删除'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    ref
                        .read(currentConversationProvider.notifier)
                        .setCurrentConversation(conversation.id);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 