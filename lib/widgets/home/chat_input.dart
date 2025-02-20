import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_app/models/ai_model.dart';
import 'package:ai_app/models/conversation.dart';
import 'package:ai_app/widgets/home/voice_input.dart';
import 'package:ai_app/widgets/home/feature_button.dart';

/// 聊天输入组件
/// 包含文本输入框、语音输入按钮和发送按钮
class ChatInput extends ConsumerWidget {
  final TextEditingController textController;
  final FocusNode focusNode;
  final bool isVoiceMode;
  final bool isListening;
  final Animation<double>? voiceAnimation;
  final VoidCallback onVoiceModeToggle;
  final VoidCallback onVoiceLongPressStart;
  final VoidCallback onVoiceLongPressEnd;
  final Function(String) onSendMessage;
  final AIModel selectedModel;

  const ChatInput({
    super.key,
    required this.textController,
    required this.focusNode,
    required this.isVoiceMode,
    required this.isListening,
    this.voiceAnimation,
    required this.onVoiceModeToggle,
    required this.onVoiceLongPressStart,
    required this.onVoiceLongPressEnd,
    required this.onSendMessage,
    required this.selectedModel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
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
            // DeepSeek R1 模型特性按钮
            if (selectedModel.id == 'deepseek-r1')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    FeatureButton(
                      icon: Icons.psychology_outlined,
                      label: '深度思考(R1)',
                      isEnabled: selectedModel.enableDeepThinking,
                    ),
                    const SizedBox(width: 8),
                    FeatureButton(
                      icon: Icons.search_outlined,
                      label: '联网搜索',
                      isEnabled: selectedModel.enableSearch,
                    ),
                  ],
                ),
              ),
            
            // 输入区域
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 语音/键盘切换按钮
                  IconButton(
                    icon: Icon(
                      isVoiceMode ? Icons.keyboard_alt_outlined : Icons.mic_none_outlined,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 28,
                    ),
                    onPressed: onVoiceModeToggle,
                    tooltip: isVoiceMode ? '切换键盘' : '切换语音',
                  ),
                  
                  // 输入框区域
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 120),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: isVoiceMode
                          ? VoiceInputButton(
                              isListening: isListening,
                              animation: voiceAnimation,
                              onLongPressStart: onVoiceLongPressStart,
                              onLongPressEnd: onVoiceLongPressEnd,
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
                                if (text.trim().isNotEmpty) {
                                  onSendMessage(text);
                                  textController.clear();
                                  focusNode.requestFocus();
                                }
                              },
                            ),
                    ),
                  ),
                  
                  // 发送按钮
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      if (isVoiceMode) return;
                      final text = textController.text;
                      if (text.trim().isNotEmpty) {
                        onSendMessage(text);
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
    );
  }
} 