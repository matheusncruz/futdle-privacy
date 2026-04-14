import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme.dart';
import '../providers/shield_game_provider.dart';

class ShieldResultScreen extends StatelessWidget {
  final bool solved;
  final int wrongCount;
  final String clubName;
  final String shieldUrl;
  final int timeSeconds;

  const ShieldResultScreen({
    super.key,
    required this.solved,
    required this.wrongCount,
    required this.clubName,
    required this.shieldUrl,
    required this.timeSeconds,
  });

  String _formatTime(int s) {
    if (s >= 60) return '${s ~/ 60}m ${s % 60}s';
    return '${s}s';
  }

  String _buildShareText() {
    final blocks = List.generate(kMaxWrongGuesses, (i) {
      if (i < wrongCount) return '🟥';
      if (!solved) return '⬛';
      return '🟩';
    }).join('');

    return [
      'Futdle 🛡 Modo Escudo',
      solved
          ? 'Acertei em $wrongCount erro${wrongCount == 1 ? '' : 's'} (${_formatTime(timeSeconds)})!'
          : 'Não acertei — era $clubName',
      blocks,
      '#Futdle',
    ].join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FUTDLE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 3)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.home_outlined),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Escudo completo
            if (shieldUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  shieldUrl,
                  width: 160,
                  height: 160,
                  fit: BoxFit.contain,
                ),
              ),
            const SizedBox(height: 20),

            // Resultado
            Icon(
              solved ? Icons.emoji_events : Icons.sports_soccer,
              size: 56,
              color: solved ? kYellow : kTextSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              solved ? 'Você acertou!' : 'Era $clubName',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: kTextPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (solved) ...[
              Text(
                '$wrongCount erro${wrongCount == 1 ? '' : 's'} · ${_formatTime(timeSeconds)}',
                style: const TextStyle(fontSize: 15, color: kTextSecondary),
              ),
            ],
            const SizedBox(height: 8),

            // Blocos de desempenho
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(kMaxWrongGuesses, (i) {
                Color c;
                if (i < wrongCount) {
                  c = kRed;
                } else if (!solved) {
                  c = const Color(0xFF374151);
                } else {
                  c = kGreenLight;
                }
                return Container(
                  width: 28, height: 28,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Share.share(_buildShareText()),
                icon: const Icon(Icons.share),
                label: const Text('Compartilhar resultado'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('Voltar ao início', style: TextStyle(color: kTextSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}
