import 'package:flutter/material.dart';

/// 语音输入按钮组件
/// 处理语音输入的UI和动画效果
class VoiceInputButton extends StatefulWidget {
  final bool isListening;
  final Animation<double>? animation;
  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressEnd;
  final VoidCallback onLongPressCancel;

  const VoiceInputButton({
    super.key,
    required this.isListening,
    this.animation,
    required this.onLongPressStart,
    required this.onLongPressEnd,
    required this.onLongPressCancel,
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> {
  bool _isCancelling = false;
  double _startY = 0;
  double _currentY = 0;
  static const double _cancelThreshold = -50.0; // 上滑取消的阈值
  DateTime? _pressStartTime;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 语音输入提示框
        if (widget.isListening)
          Positioned.fill(
            child: Container(
              color: Colors.transparent,
              child: Stack(
                children: [
                  // 中央提示框
                  Positioned(
                    left: 50,
                    right: 50,
                    top: -180,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 语音波纹动画
                          if (!_isCancelling && widget.animation != null)
                            SizedBox(
                              height: 60,
                              child: Center(
                                child: AnimatedBuilder(
                                  animation: widget.animation!,
                                  builder: (context, child) {
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(4, (index) {
                                        final delay = index * 0.2;
                                        final animationValue = ((widget.animation!.value + delay) % 1.0);
                                        return Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 2),
                                          width: 3,
                                          height: 15 + (30 * animationValue),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(1 - animationValue),
                                            borderRadius: BorderRadius.circular(1.5),
                                          ),
                                        );
                                      }),
                                    );
                                  },
                                ),
                              ),
                            )
                          else if (_isCancelling)
                            const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                              size: 40,
                            ),
                          const SizedBox(height: 16),
                          // 提示文本
                          Text(
                            _isCancelling ? '松开手指，取消发送' : '松开发送，上滑取消',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // 主按钮
        GestureDetector(
          onLongPressStart: (details) {
            setState(() {
              _startY = details.globalPosition.dy;
              _currentY = _startY;
              _pressStartTime = DateTime.now();
            });
            widget.onLongPressStart();
          },
          onLongPressMoveUpdate: (details) {
            setState(() {
              _currentY = details.globalPosition.dy;
              _isCancelling = (_startY - _currentY) > _cancelThreshold;
            });
          },
          onLongPressEnd: (details) {
            final now = DateTime.now();
            final duration = now.difference(_pressStartTime ?? now);
            
            if (_isCancelling) {
              widget.onLongPressCancel();
            } else if (duration.inMilliseconds < 500) {
              widget.onLongPressCancel();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    '说话时间太短',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  backgroundColor: Colors.black87,
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else {
              widget.onLongPressEnd();
            }
            
            setState(() {
              _isCancelling = false;
              _startY = 0;
              _currentY = 0;
              _pressStartTime = null;
            });
          },
          onLongPressCancel: () {
            widget.onLongPressCancel();
            setState(() {
              _isCancelling = false;
              _startY = 0;
              _currentY = 0;
              _pressStartTime = null;
            });
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _getBorderColor(context),
                width: widget.isListening ? 2 : 1,
              ),
              color: _getBackgroundColor(context),
              boxShadow: widget.isListening && !_isCancelling
                  ? [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: _getTextColor(context),
                  fontSize: widget.isListening ? 18 : 16,
                  fontWeight: widget.isListening ? FontWeight.bold : FontWeight.normal,
                ),
                child: Text(
                  _isCancelling ? '松开取消' : (widget.isListening ? ' ' : '按住说话'),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getBorderColor(BuildContext context) {
    if (_isCancelling) {
      return Theme.of(context).colorScheme.error;
    }
    if (widget.isListening) {
      return Theme.of(context).colorScheme.primary;
    }
    return Theme.of(context).colorScheme.outline.withAlpha(128);
  }

  Color _getBackgroundColor(BuildContext context) {
    if (_isCancelling) {
      return Theme.of(context).colorScheme.errorContainer;
    }
    if (widget.isListening) {
      return Theme.of(context).colorScheme.primary.withOpacity(0.15);
    }
    return Theme.of(context).colorScheme.primary.withAlpha(26);
  }

  Color _getTextColor(BuildContext context) {
    if (_isCancelling) {
      return Theme.of(context).colorScheme.error;
    }
    if (widget.isListening) {
      return Theme.of(context).colorScheme.primary;
    }
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }
} 