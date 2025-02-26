import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_app/providers/conversation_provider.dart';
import 'package:ai_app/models/conversation.dart';
import 'package:intl/intl.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:ai_app/providers/theme_provider.dart';

class ConversationDrawer extends ConsumerWidget {
  const ConversationDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(conversationsProvider);
    final currentConversationId = ref.watch(currentConversationProvider);

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            // 抽屉头部
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(26),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: const Icon(
                            Icons.chat_outlined,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'AI 助手',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        // 添加清空按钮
                        if (conversations.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.delete_sweep_outlined),
                            tooltip: '清空所有会话',
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('清空所有会话'),
                                  content: const Text('确定要清空所有会话吗？此操作不可恢复。'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('取消'),
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Theme.of(context).colorScheme.error,
                                      ),
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('清空'),
                                    ),
                                  ],
                                ),
                              ) ?? false;

                              if (confirmed && context.mounted) {
                                // 清空所有会话
                                await ref.read(conversationsProvider.notifier).clearConversations();
                                // 清空当前会话选择
                                await ref.read(currentConversationProvider.notifier).setCurrentConversation(null);
                              }
                            },
                            color: Theme.of(context).colorScheme.error,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // 新建对话按钮
                    OutlinedButton.icon(
                      onPressed: () async {
                        final now = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
                        await ref
                            .read(currentConversationProvider.notifier)
                            .createAndSetNewConversation('新对话 $now');
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('新建对话'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        minimumSize: const Size(double.infinity, 44),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary.withAlpha(128),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 对话列表
            Expanded(
              child: conversations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary.withAlpha(128),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '暂无对话',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: conversations.length,
                        itemBuilder: (context, index) {
                          final conversation = conversations[index];
                          final isSelected = conversation.id == currentConversationId;
                          
                          // 获取最后一条消息
                          String? lastMessageText;
                          if (conversation.messagesList.isNotEmpty) {
                            final lastMessage = conversation.messagesList.last;
                            if (lastMessage is types.TextMessage) {
                              // 截取前50个字符，如果超过则添加省略号
                              lastMessageText = lastMessage.text.length > 50
                                  ? '${lastMessage.text.substring(0, 50)}...'
                                  : lastMessage.text;
                            } else if (lastMessage is types.ImageMessage) {
                              lastMessageText = '[图片]';
                            } else if (lastMessage is types.FileMessage) {
                              lastMessageText = '[文件]';
                            }
                          }
                          
                          return Dismissible(
                            key: Key(conversation.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Theme.of(context).colorScheme.error,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child: Icon(
                                Icons.delete_outline,
                                color: Theme.of(context).colorScheme.onError,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('删除对话'),
                                  content: const Text('确定要删除这个对话吗？'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('取消'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('删除'),
                                    ),
                                  ],
                                ),
                              ) ?? false;
                            },
                            onDismissed: (direction) {
                              ref
                                  .read(conversationsProvider.notifier)
                                  .deleteConversation(conversation.id);
                              if (conversation.id == currentConversationId) {
                                ref
                                    .read(currentConversationProvider.notifier)
                                    .setCurrentConversation(null);
                              }
                            },
                            child: ListTile(
                              selected: isSelected,
                              selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withAlpha(77),
                              leading: CircleAvatar(
                                backgroundColor: isSelected
                                    ? Theme.of(context).colorScheme.primaryContainer.withAlpha(77)
                                    : Colors.transparent,
                                child: Icon(
                                  Icons.chat_bubble_outline,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary.withAlpha(26)
                                      : Colors.transparent,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                conversation.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: lastMessageText != null
                                  ? Text(
                                      lastMessageText,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                    )
                                  : Text(
                                      DateFormat('yyyy-MM-dd HH:mm').format(conversation.createdAt),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                              onTap: () {
                                ref
                                    .read(currentConversationProvider.notifier)
                                    .setCurrentConversation(conversation.id);
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      ),
                    ),
            ),

            // 底部登录信息
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    offset: const Offset(1, 0),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(26),
                        child: Icon(
                          Icons.person_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '游客模式',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '点击登录账号',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Consumer(
                        builder: (context, ref, child) {
                          final themeMode = ref.watch(themeProvider);
                          final isDarkMode = themeMode == ThemeMode.dark;
                          return IconButton(
                            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
                            onPressed: () {
                              ref.read(themeProvider.notifier).toggleTheme();
                            },
                            tooltip: isDarkMode ? '切换到亮色模式' : '切换到暗色模式',
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined),
                        onPressed: () {
                        },
                        tooltip: '设置',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 