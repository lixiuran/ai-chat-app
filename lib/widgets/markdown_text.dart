import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class MarkdownText extends StatelessWidget {
  final String text;
  final Color textColor;
  final double maxWidth;

  const MarkdownText({
    super.key,
    required this.text,
    required this.textColor,
    this.maxWidth = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: MarkdownBody(
        data: text,
        selectable: false,
        softLineBreak: true,
        styleSheet: MarkdownStyleSheet(
          p: TextStyle(
            color: textColor,
            fontSize: 16,
            height: 1.5,
          ),
          code: TextStyle(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(192),
            fontFamily: 'monospace',
            fontSize: 14,
          ),
          codeblockDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(166),
            borderRadius: BorderRadius.circular(8),
          ),
          codeblockPadding: const EdgeInsets.all(12),
          blockquote: TextStyle(
            color: textColor.withAlpha(204),
            fontSize: 16,
            fontStyle: FontStyle.italic,
          ),
          blockquoteDecoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: textColor.withAlpha(77),
                width: 4,
              ),
            ),
          ),
          blockquotePadding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          h1: TextStyle(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.5,
          ),
          h2: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            height: 1.5,
          ),
          h3: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            height: 1.5,
          ),
          h4: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            height: 1.5,
          ),
          h5: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            height: 1.5,
          ),
          h6: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            height: 1.5,
          ),
          listBullet: TextStyle(
            color: textColor,
            fontSize: 16,
            height: 1.5,
          ),
          strong: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
          em: TextStyle(
            color: textColor,
            fontStyle: FontStyle.italic,
          ),
          a: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            decoration: TextDecoration.underline,
          ),
        ),
        onTapLink: (text, href, title) {
          if (href != null) {
            launchUrl(Uri.parse(href));
          }
        },
      ),
    );
  }
} 