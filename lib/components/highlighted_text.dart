import 'dart:math';
import 'package:flutter/material.dart';

class HighlightedText extends StatelessWidget {
//  final TextHeightBehavior textHeightBehavior;

  const HighlightedText({
    super.key,
    required this.text,
    required this.highlights,
    this.color = Colors.yellow,
    this.style = const TextStyle(
      color: Colors.black,
    ),
    this.caseSensitive = true,

    //RichText
    this.textAlign = TextAlign.start,
    this.textDirection = TextDirection.ltr,
    this.textScaleFactor = 1.0,
    this.textWidthBasis = TextWidthBasis.parent,
  });

  final String text;
  final List<String> highlights;
  final Color color;
  final TextStyle style;
  final bool caseSensitive;

  //RichText
  final TextAlign textAlign;
  final TextDirection textDirection;
  final double textScaleFactor;
  final TextWidthBasis textWidthBasis;

  @override
  Widget build(BuildContext context) {
    //Controls
    if (text == '') {
      return _richText(_normalSpan(text));
    }
    if (highlights.isEmpty) {
      return _richText(_normalSpan(text));
    }
    for (var i = 0; i < highlights.length; i++) {
      if (highlights[i].isEmpty) {
        assert(highlights[i].isNotEmpty);
        return _richText(_normalSpan(text));
      }
    }

    //Main code
    final spans = <TextSpan>[];
    var start = 0;

    //For "No Case Sensitive" option
    final lowerCaseText = text.toLowerCase();
    final lowerCaseHighlights = <String>[];

    for (final element in highlights) {
      lowerCaseHighlights.add(element.toLowerCase());
    }

    while (true) {
      final highlightsMap = <int, String>{}; //key (index), value (highlight).

      if (caseSensitive) {
        for (var i = 0; i < highlights.length; i++) {
          final index = text.indexOf(highlights[i], start);
          if (index >= 0) {
            highlightsMap[index] = highlights[i];
          }
        }
      } else {
        for (var i = 0; i < highlights.length; i++) {
          final index = lowerCaseText.indexOf(lowerCaseHighlights[i], start);
          if (index >= 0) {
            highlightsMap[index] = highlights[i];
          }
        }
      }

      if (highlightsMap.isNotEmpty) {
        final indexes = highlightsMap.keys;

        final currentIndex = indexes.reduce(min);
        final currentHighlight = text.substring(
          currentIndex,
          currentIndex + highlightsMap[currentIndex]!.length,
        );

        if (currentIndex == start) {
          spans.add(_highlightSpan(currentHighlight));
          start += currentHighlight.length;
        } else {
          spans.add(_normalSpan(text.substring(start, currentIndex)));
          spans.add(_highlightSpan(currentHighlight));
          start = currentIndex + currentHighlight.length;
        }
      } else {
        spans.add(_normalSpan(text.substring(start, text.length)));
        break;
      }
    }

    return _richText(TextSpan(children: spans));
  }

  TextSpan _highlightSpan(String value) {
    if (style.color == null) {
      return TextSpan(
        text: value,
        style: style.copyWith(
          color: Colors.black,
          backgroundColor: color,
        ),
      );
    } else {
      return TextSpan(
        text: value,
        style: style.copyWith(
          backgroundColor: color,
        ),
      );
    }
  }

  TextSpan _normalSpan(String value) {
    if (style.color == null) {
      return TextSpan(
        text: value,
        style: style.copyWith(
          color: Colors.black,
        ),
      );
    } else {
      return TextSpan(
        text: value,
        style: style,
      );
    }
  }

  Widget _richText(TextSpan text) {
    return SelectableText.rich(
      text,
      key: key,
      textAlign: textAlign,
      textDirection: textDirection,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
    );
  }
}
