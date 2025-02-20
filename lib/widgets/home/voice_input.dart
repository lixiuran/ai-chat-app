import 'package:flutter/material.dart';

/// 语音输入按钮组件
/// 处理语音输入的UI和动画效果
class VoiceInputButton extends StatelessWidget {
  final bool isListening;
  final Animation<double>? animation;
  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressEnd;

  const VoiceInputButton({
    super.key,
    required this.isListening,
    this.animation,
    required this.onLongPressStart,
    required this.onLongPressEnd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPressStart,
      onLongPressEnd: (_) => onLongPressEnd(),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
          color: isListening 
            ? const Color(0xFF2AAF62).withOpacity(0.2)
            : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isListening && animation != null)
              AnimatedBuilder(
                animation: animation!,
                builder: (context, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 3,
                        height: 12 + (10 * animation!.value * ((index + 1) % 2)),
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
              isListening ? ' ' : '按住说话',
              style: TextStyle(
                color: isListening 
                  ? const Color(0xFF2AAF62)
                  : Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 