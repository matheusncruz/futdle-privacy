import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme.dart';
import '../providers/shield_game_provider.dart';
import '../providers/shield_leaderboard_provider.dart';

class ShieldResultScreen extends ConsumerWidget {
  final bool solved;
  final int wrongCount;
  final String clubName;
  final String shieldUrl;
  final int timeSeconds;
  final String? challengeId;

  const ShieldResultScreen({
    super.key,
    required this.solved,
    required this.wrongCount,
    required this.clubName,
    required this.shieldUrl,
    required this.timeSeconds,
    this.challengeId,
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
  Widget build(BuildContext context, WidgetRef ref) {
    final showLeaderboard = challengeId != null;

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

            // Ranking — somente no desafio diário
            if (showLeaderboard) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Ranking de hoje',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextPrimary),
                ),
              ),
              const SizedBox(height: 12),
              _ShieldLeaderboardWidget(challengeId: challengeId!),
              const SizedBox(height: 28),
            ],

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

class _ShieldLeaderboardWidget extends ConsumerWidget {
  final String challengeId;
  const _ShieldLeaderboardWidget({required this.challengeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(shieldLeaderboardProvider(challengeId));

    return leaderboardAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text(
            'Não foi possível carregar o ranking.',
            style: TextStyle(color: kTextSecondary, fontSize: 13),
          ),
        ),
      ),
      data: (entries) {
        if (entries.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'Nenhum acerto ainda. Seja o primeiro!',
                style: TextStyle(color: kTextSecondary, fontSize: 13),
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1F2937),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: const [
                    SizedBox(width: 32, child: Text('#', style: TextStyle(color: kTextSecondary, fontSize: 12, fontWeight: FontWeight.bold))),
                    Expanded(child: Text('Jogador', style: TextStyle(color: kTextSecondary, fontSize: 12, fontWeight: FontWeight.bold))),
                    SizedBox(width: 50, child: Text('Erros', textAlign: TextAlign.center, style: TextStyle(color: kTextSecondary, fontSize: 12, fontWeight: FontWeight.bold))),
                    SizedBox(width: 60, child: Text('Tempo', textAlign: TextAlign.right, style: TextStyle(color: kTextSecondary, fontSize: 12, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFF374151)),
              ...entries.asMap().entries.map((e) {
                final pos = e.key + 1;
                final entry = e.value;
                final isTop3 = pos <= 3;
                final medalColors = [kYellow, const Color(0xFFB0B0B0), const Color(0xFFCD7F32)];

                return Column(
                  children: [
                    Container(
                      color: entry.isCurrentUser ? kGreenLight.withOpacity(0.1) : Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 32,
                            child: isTop3
                                ? Icon(Icons.circle, color: medalColors[pos - 1], size: 14)
                                : Text('$pos', style: const TextStyle(color: kTextSecondary, fontSize: 13)),
                          ),
                          Expanded(
                            child: Text(
                              entry.isCurrentUser ? '${entry.nickname} (você)' : entry.nickname,
                              style: TextStyle(
                                color: entry.isCurrentUser ? kGreenLight : kTextPrimary,
                                fontSize: 13,
                                fontWeight: entry.isCurrentUser ? FontWeight.bold : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            width: 50,
                            child: Text(
                              '${entry.wrongCount}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: kTextPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: Text(
                              entry.formattedTime,
                              textAlign: TextAlign.right,
                              style: const TextStyle(color: kTextSecondary, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (e.key < entries.length - 1)
                      const Divider(height: 1, color: Color(0xFF374151)),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
