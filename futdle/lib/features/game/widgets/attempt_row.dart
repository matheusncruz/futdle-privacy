import 'package:flutter/material.dart';
import '../models/attempt_result.dart';
import '../services/game_service.dart' show titleRange;
import 'feedback_cell.dart';

class AttemptRow extends StatefulWidget {
  final AttemptResult result;
  const AttemptRow({super.key, required this.result});

  @override
  State<AttemptRow> createState() => _AttemptRowState();
}

class _AttemptRowState extends State<AttemptRow> with TickerProviderStateMixin {
  static const _cellCount = 8;
  static const _flipDuration = Duration(milliseconds: 350);
  static const _cellDelay = Duration(milliseconds: 130);

  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      _cellCount,
      (_) => AnimationController(vsync: this, duration: _flipDuration),
    );

    _animations = _controllers.map((c) {
      return CurvedAnimation(parent: c, curve: Curves.easeInOut);
    }).toList();

    // Dispara cada célula com delay crescente
    for (var i = 0; i < _cellCount; i++) {
      Future.delayed(_cellDelay * i, () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final club = widget.result.club;
    final cells = [
      _text(widget.result.country, club.country, 'País'),
      _text(widget.result.continent, _shortContinent(club.continent), 'Cont.'),
      _text(widget.result.league, _shortLeague(club.leagueName), 'Liga'),
      _num(widget.result.foundedYear, club.foundedYear, 'Ano'),
      _color(widget.result.primaryColor, club.primaryColor, 'Cor 1'),
      _color(widget.result.secondaryColor, club.secondaryColor, 'Cor 2'),
      _numRounded(widget.result.nationalTitles, club.nationalTitles, 'Nac.'),
      _numRounded(widget.result.internationalTitles, club.internationalTitles, 'Int.'),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            club.name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(_cellCount, (i) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _FlipCell(
                    animation: _animations[i],
                    child: cells[i],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _shortContinent(String c) => switch (c) {
        'América do Sul' => 'Am. Sul',
        'América do Norte' => 'Am. Norte',
        'América Central' => 'Am. Central',
        _ => c,
      };

  String _shortLeague(String l) => switch (l) {
        'Brasileirão Série A' => 'Brasileirão',
        'Liga Profesional Argentina' => 'Liga Arg.',
        _ => l,
      };

  Widget _text(AttributeFeedback fb, String value, String label) =>
      FeedbackCell(feedback: fb, textValue: value, label: label);

  Widget _num(AttributeFeedback fb, int value, String label) =>
      FeedbackCell(feedback: fb, numericValue: value, label: label);

  Widget _numRounded(AttributeFeedback fb, int value, String label) =>
      FeedbackCell(feedback: fb, textValue: titleRange(value), label: label);

  Widget _color(AttributeFeedback fb, String hex, String label) =>
      FeedbackCell(feedback: fb, colorValue: hex, label: label);
}

/// Célula com efeito de flip no eixo Y (escala)
class _FlipCell extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _FlipCell({required this.animation, required this.child});

  static const _placeholder = _CellPlaceholder();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        final t = animation.value;

        if (t <= 0.5) {
          // Primeira metade: placeholder escala de 1 → 0 (dobra)
          final scaleY = 1.0 - (t * 2.0);
          return Transform.scale(scaleY: scaleY, child: _placeholder);
        } else {
          // Segunda metade: conteúdo escala de 0 → 1 (abre)
          final scaleY = (t - 0.5) * 2.0;
          return Transform.scale(scaleY: scaleY, child: child);
        }
      },
    );
  }
}

class _CellPlaceholder extends StatelessWidget {
  const _CellPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF374151),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
