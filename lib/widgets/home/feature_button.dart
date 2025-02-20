import 'package:flutter/material.dart';

/// 功能按钮组件
/// 用于显示模型特性按钮（如深度思考、联网搜索等）
class FeatureButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isEnabled;

  const FeatureButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
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
} 