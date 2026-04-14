import 'package:flutter/material.dart';
import '../models/club.dart';
import '../models/attempt_result.dart';
import 'feedback_cell.dart';
import '../../../core/theme.dart';

/// Exibe os atributos revelados pelo powerup como células verdes.
/// Cada índice corresponde a um dos 8 atributos do clube.
class RevealedAttributeRow extends StatelessWidget {
  final Club target;
  final List<int> revealedIndices;

  const RevealedAttributeRow({
    super.key,
    required this.target,
    required this.revealedIndices,
  });

  static const _labels = [
    'País', 'Cont.', 'Liga', 'Ano', 'Cor 1', 'Cor 2', 'Nac.', 'Int.'
  ];

  static const _correct = AttributeFeedback(status: FeedbackStatus.correct);

  int _roundToNearest5(int value) => ((value / 5).round() * 5).clamp(5, 999);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kGreenLight.withOpacity(0.4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.visibility, color: kGreenLight, size: 12),
              const SizedBox(width: 4),
              Text(
                'Atributo${revealedIndices.length > 1 ? 's' : ''} revelado${revealedIndices.length > 1 ? 's' : ''}',
                style: const TextStyle(
                  color: kGreenLight,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(8, (i) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: revealedIndices.contains(i)
                      ? _buildRevealed(i)
                      : _buildHidden(),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRevealed(int index) {
    switch (index) {
      case 0:
        return FeedbackCell(
            feedback: _correct, textValue: target.country, label: _labels[0]);
      case 1:
        return FeedbackCell(
            feedback: _correct, textValue: target.continent, label: _labels[1]);
      case 2:
        return FeedbackCell(
            feedback: _correct, textValue: target.leagueName, label: _labels[2]);
      case 3:
        return FeedbackCell(
            feedback: _correct,
            numericValue: target.foundedYear,
            label: _labels[3]);
      case 4:
        return FeedbackCell(
            feedback: _correct,
            colorValue: target.primaryColor,
            label: _labels[4]);
      case 5:
        return FeedbackCell(
            feedback: _correct,
            colorValue: target.secondaryColor,
            label: _labels[5]);
      case 6:
        return FeedbackCell(
            feedback: _correct,
            numericValue: _roundToNearest5(target.nationalTitles),
            label: _labels[6]);
      case 7:
        return FeedbackCell(
            feedback: _correct,
            numericValue: _roundToNearest5(target.internationalTitles),
            label: _labels[7]);
      default:
        return _buildHidden();
    }
  }

  Widget _buildHidden() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white12),
      ),
    );
  }
}
