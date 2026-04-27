import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../game/models/attempt_result.dart';
import '../../game/providers/leaderboard_provider.dart';

class ResultScreen extends ConsumerWidget {
  final bool solved;
  final int attempts;
  final List<AttemptResult> attemptsList;
  final String clubName;
  final String mode;
  final String? challengeId;
  final int timeSeconds;
  final int streak;

  const ResultScreen({
    super.key,
    required this.solved,
    required this.attempts,
    this.attemptsList = const [],
    required this.clubName,
    required this.mode,
    this.challengeId,
    this.timeSeconds = 0,
    this.streak = 0,
  });

  String _formatTime(int seconds) {
    if (seconds >= 60) {
      final m = seconds ~/ 60;
      final s = seconds % 60;
      return '${m}m ${s}s';
    }
    return '${seconds}s';
  }

  String _statusEmoji(FeedbackStatus status) {
    switch (status) {
      case FeedbackStatus.correct:
        return '🟩';
      case FeedbackStatus.partial:
        return '🟨';
      case FeedbackStatus.wrong:
        return '🟥';
    }
  }

  String _directionSuffix(Direction dir) {
    switch (dir) {
      case Direction.up:
        return '⬆️';
      case Direction.down:
        return '⬇️';
      case Direction.none:
        return '';
    }
  }

  String _attemptRow(AttemptResult r) {
    final attrs = [
      r.country,
      r.continent,
      r.league,
      r.foundedYear,
      r.primaryColor,
      r.secondaryColor,
      r.nationalTitles,
      r.internationalTitles,
    ];
    return attrs.map((a) => _statusEmoji(a.status) + _directionSuffix(a.direction)).join('');
  }

  String _buildShareText() {
    final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
    final grid = attemptsList.map(_attemptRow).join('\n');
    final resultLine = solved
        ? 'Acertei em $attempts tentativa${attempts == 1 ? '' : 's'} (${_formatTime(timeSeconds)})!'
        : 'Não acertei hoje 😢';
    final streakLine =
        (mode == 'daily' && solved && streak > 0) ? '🔥 $streak dia${streak == 1 ? '' : 's'} acertando!' : null;

    return [
      'Futdle $today',
      '⚽ $clubName',
      if (grid.isNotEmpty) grid,
      resultLine,
      if (streakLine != null) streakLine,
      'Jogue você também! #Futdle',
    ].join('\n');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showLeaderboard = mode == 'daily' && challengeId != null;

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
            const SizedBox(height: 16),
            Icon(
              solved ? Icons.emoji_events : Icons.sports_soccer,
              size: 72,
              color: solved ? kYellow : kTextSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              solved ? 'Você acertou!' : 'Era $clubName',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: kTextPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (solved) ...[
              Text(
                '$attempts ${attempts == 1 ? 'tentativa' : 'tentativas'}',
                style: const TextStyle(fontSize: 16, color: kTextSecondary),
              ),
              Text(
                _formatTime(timeSeconds),
                style: const TextStyle(fontSize: 14, color: kTextSecondary),
              ),
            ],
            if (mode == 'daily' && streak > 0) ...[
              const SizedBox(height: 20),
              _StreakCard(streak: streak, solved: solved),
            ],
            const SizedBox(height: 28),

            // Leaderboard — somente no desafio diário
            if (showLeaderboard) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Ranking de hoje',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextPrimary),
                ),
              ),
              const SizedBox(height: 12),
              _LeaderboardWidget(challengeId: challengeId!),
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

class _StreakCard extends StatelessWidget {
  final int streak;
  final bool solved;
  const _StreakCard({required this.streak, required this.solved});

  @override
  Widget build(BuildContext context) {
    final color = solved ? const Color(0xFFf97316) : kTextSecondary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.35), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '🔥',
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                solved
                    ? 'Você está a $streak dia${streak == 1 ? '' : 's'} acertando!'
                    : 'Sequência encerrada',
                style: TextStyle(
                  color: solved ? const Color(0xFFfb923c) : kTextSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              if (!solved && streak > 0)
                Text(
                  'Sua sequência era de $streak dia${streak == 1 ? '' : 's'}',
                  style: const TextStyle(color: kTextSecondary, fontSize: 12),
                ),
              if (solved)
                const Text(
                  'Continue jogando para aumentar!',
                  style: TextStyle(color: kTextSecondary, fontSize: 12),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeaderboardWidget extends ConsumerWidget {
  final String challengeId;
  const _LeaderboardWidget({required this.challengeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider(challengeId));

    return leaderboardAsync.when(
      loading: () => const Center(child: Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      )),
      error: (e, _) => const SizedBox.shrink(),
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
              // Cabeçalho
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: const [
                    SizedBox(width: 32, child: Text('#', style: TextStyle(color: kTextSecondary, fontSize: 12, fontWeight: FontWeight.bold))),
                    Expanded(child: Text('Jogador', style: TextStyle(color: kTextSecondary, fontSize: 12, fontWeight: FontWeight.bold))),
                    SizedBox(width: 50, child: Text('Tent.', textAlign: TextAlign.center, style: TextStyle(color: kTextSecondary, fontSize: 12, fontWeight: FontWeight.bold))),
                    SizedBox(width: 60, child: Text('Tempo', textAlign: TextAlign.right, style: TextStyle(color: kTextSecondary, fontSize: 12, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFF374151)),
              // Linhas
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
                              '${entry.attemptsCount}',
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
