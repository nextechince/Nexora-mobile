import 'package:flutter/material.dart';

class MessageFormattingService {
  static String formatMarkdown(String text) {
    text = text.replaceAllMapped(
      RegExp(r'\*\*(.*?)\*\*|__(.*?)__'),
      (match) => '**${match.group(1) ?? match.group(2)}**',
    );
    text = text.replaceAllMapped(
      RegExp(r'\*(.*?)\*|_(.*?)_'),
      (match) => '*${match.group(1) ?? match.group(2)}*',
    );
    text = text.replaceAllMapped(
      RegExp(r'~(.*?)~'),
      (match) => '~${match.group(1)}~',
    );
    text = text.replaceAllMapped(
      RegExp(r'~~(.*?)~~'),
      (match) => '~~${match.group(1)}~~',
    );
    text = text.replaceAllMapped(
      RegExp(r'`(.*?)`'),
      (match) => '`${match.group(1)}`',
    );
    return text;
  }

  static List<TextSpan> parseMarkdown(String text, TextStyle baseStyle) {
    final List<TextSpan> spans = [];
    final RegExp exp = RegExp(
      r'(\*\*(.*?)\*\*|__(.*?)__|\*(.*?)\*|_(.*?)_|~(.*?)~|~~(.*?)~~|`(.*?)`|(?!\n)\n?)+',
      multiLine: true,
    );
    int pos = 0;
    for (final match in exp.allMatches(text)) {
      if (match.start > pos) {
        spans.add(TextSpan(text: text.substring(pos, match.start), style: baseStyle));
      }
      final formatted = match.group(0)!;
      if (formatted.startsWith('**') || formatted.startsWith('__')) {
        final content = formatted.substring(2, formatted.length - 2);
        spans.add(TextSpan(text: content, style: baseStyle.copyWith(fontWeight: FontWeight.bold)));
      } else if (formatted.startsWith('*') || formatted.startsWith('_')) {
        final content = formatted.substring(1, formatted.length - 1);
        spans.add(TextSpan(text: content, style: baseStyle.copyWith(fontStyle: FontStyle.italic)));
      } else if (formatted.startsWith('~') && !formatted.startsWith('~~')) {
        final content = formatted.substring(1, formatted.length - 1);
        spans.add(TextSpan(text: content, style: baseStyle.copyWith(decoration: TextDecoration.underline)));
      } else if (formatted.startsWith('~~')) {
        final content = formatted.substring(2, formatted.length - 2);
        spans.add(TextSpan(text: content, style: baseStyle.copyWith(decoration: TextDecoration.lineThrough)));
      } else if (formatted.startsWith('`')) {
        final content = formatted.substring(1, formatted.length - 1);
        spans.add(TextSpan(text: content, style: baseStyle.copyWith(fontFamily: 'monospace', backgroundColor: Colors.grey.shade800)));
      } else {
        spans.add(TextSpan(text: formatted, style: baseStyle));
      }
      pos = match.end;
    }
    if (pos < text.length) {
      spans.add(TextSpan(text: text.substring(pos), style: baseStyle));
    }
    return spans;
  }

  static Widget buildRichText(String text, TextStyle baseStyle) {
    final spans = parseMarkdown(text, baseStyle);
    return RichText(text: TextSpan(children: spans), softWrap: true);
  }

  static String formatCodeBlock(String code, String language) {
    return '```$language\n$code\n```';
  }

  static String createOrderedList(List<String> items) {
    final buffer = StringBuffer();
    for (var i = 0; i < items.length; i++) {
      buffer.writeln('${i + 1}. ${items[i]}');
    }
    return buffer.toString();
  }

  static String createUnorderedList(List<String> items) {
    final buffer = StringBuffer();
    for (final item in items) {
      buffer.writeln('• $item');
    }
    return buffer.toString();
  }

  static String quoteText(String text) {
    return '> $text';
  }
}