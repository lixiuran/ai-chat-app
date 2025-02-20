import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:ai_app/widgets/markdown_text.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// 消息列表组件
/// 显示聊天消息列表，包括用户消息和机器人回复
class MessageList extends StatelessWidget {
  final List<types.Message> messages;
  final bool isLoading;
  final ScrollController scrollController;
  final bool showScrollToBottom;
  final VoidCallback onScrollToBottom;

  const MessageList({
    super.key,
    required this.messages,
    required this.isLoading,
    required this.scrollController,
    required this.showScrollToBottom,
    required this.onScrollToBottom,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Text(
          'Hi ~ 我是 AI Chat，快来体验吧',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          controller: scrollController,
          reverse: true,
          padding: const EdgeInsets.all(8),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isUser = message.author.id == 'user';
            final timestamp = (message.createdAt ?? DateTime.now().millisecondsSinceEpoch ~/ 1000) * 1000;
            final timeString = DateFormat('HH:mm', 'zh_CN').format(
              DateTime.fromMillisecondsSinceEpoch(timestamp)
            );
            
            return Column(
              children: [
                // 显示时间戳
                if (index == 0 || index == messages.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      timeString,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                
                // 消息气泡
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: isUser 
                                    ? MediaQuery.of(context).size.width * 0.7
                                    : MediaQuery.of(context).size.width,
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
                              child: _buildMessageContent(message, context, isLoading),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        
        // 滚动到底部按钮
        if (showScrollToBottom)
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              onPressed: onScrollToBottom,
              child: Icon(
                Icons.keyboard_arrow_down,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
      ],
    );
  }

  /// 构建消息内容
  Widget _buildMessageContent(types.Message message, BuildContext context, bool isLoading) {
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
      // 显示文件消息
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
} 