import 'package:flutter/material.dart';
import '../models/attempt_result.dart';
import '../../../core/theme.dart';

class FeedbackCell extends StatelessWidget {
  final AttributeFeedback feedback;
  final String label;
  final String? textValue;
  final String? colorValue;
  final int? numericValue;

  const FeedbackCell({
    super.key,
    required this.feedback,
    required this.label,
    this.textValue,
    this.colorValue,
    this.numericValue,
  });

  Color get _bgColor => switch (feedback.status) {
        FeedbackStatus.correct => kGreenLight,
        FeedbackStatus.partial => kYellow,
        FeedbackStatus.wrong => kRed,
      };

  String get _arrow => switch (feedback.direction) {
        Direction.up => '↑',
        Direction.down => '↓',
        Direction.none => '',
      };

  Color _hexToColor(String hex) {
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: colorValue != null ? _bgColor.withOpacity(0.15) : _bgColor,
        borderRadius: BorderRadius.circular(6),
        border: colorValue != null
            ? Border.all(color: _bgColor, width: 2)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Label no topo
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w500,
              color: colorValue != null ? _bgColor : Colors.white70,
            ),
          ),
          const SizedBox(height: 2),
          // Valor
          if (colorValue != null)
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _hexToColor(colorValue!),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white30),
              ),
            )
          else if (numericValue != null)
            Text(
              _arrow.isNotEmpty ? '$numericValue $_arrow' : '$numericValue',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          else
            Text(
              textValue ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}
