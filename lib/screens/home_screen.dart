import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_app/widgets/chat_view.dart';
import 'package:ai_app/widgets/model_selector.dart';
import 'package:ai_app/widgets/conversation_drawer.dart';
import 'package:ai_app/providers/chat_provider.dart';
import 'package:ai_app/providers/theme_provider.dart';
import 'package:ai_app/providers/conversation_provider.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final currentConversationId = ref.watch(currentConversationProvider);
    final conversations = ref.watch(conversationsProvider);
    final currentConversation = currentConversationId != null
        ? conversations.firstWhere((conv) => conv.id == currentConversationId)
        : null;

    return Scaffold(
      drawer: const ConversationDrawer(),
      appBar: AppBar(
        title: Text(currentConversation?.title ?? 'AI Chat'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
          const ModelSelector(),
        ],
      ),
      body: currentConversationId == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('请创建或选择一个对话'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('新建对话'),
                    onPressed: () async {
                      final now =
                          DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
                      await ref
                          .read(currentConversationProvider.notifier)
                          .createAndSetNewConversation('新对话 $now');
                    },
                  ),
                ],
              ),
            )
          : const ChatView(),
    );
  }
} 