// futdle/lib/features/leagues/screens/official_league_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../providers/official_league_provider.dart';
import '../models/league_score.dart';

class OfficialLeagueScreen extends ConsumerWidget {
  final String mode; // 'classic' | 'shield'
  const OfficialLeagueScreen({super.key, required this.mode});

  String get _title =>
      mode == 'classic' ? '🎮 Liga Clássico' : '🛡️ Liga Escudo';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingAsync = ref.watch(officialLeagueProvider(mode));
    final now = DateTime.now();
    final monthNames = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
    ];

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: Text(_title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: rankingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:   (e, _) => Center(
            child: Text('Erro ao carregar ranking: $e',
                style: const TextStyle(color: kRed))),
        data: (entries) {
          // Find current user's entry (may not be in top 100)
          final myEntry = entries.where((e) => e.isCurrentUser).firstOrNull;

          return Column(
            children: [
              // Month header
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                color: kSurface,
                child: Text(
                  '${monthNames[now.month - 1]} ${now.year}',
                  style: const TextStyle(
                      color: kTextSecondary, fontSize: 12, letterSpacing: 1),
                  textAlign: TextAlign.center,
                ),
              ),

              // Current user's streak card (if they have a score)
              if (myEntry != null)
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: kGreenLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: kGreenLight.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department,
                          color: Color(0xFFf97316), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Sequência: ${myEntry.currentStreak} dias',
                        style: const TextStyle(
                            color: kTextPrimary, fontSize: 13),
                      ),
                    ],
                  ),
                ),

              // Ranking list
              Expanded(
                child: entries.isEmpty
                    ? const Center(
                        child: Text('Nenhum jogador ainda este mês.',
                            style: TextStyle(color: kTextSecondary)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: entries.length,
                        itemBuilder: (ctx, i) =>
                            _RankRow(entry: entries[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  final OfficialLeagueRankEntry entry;
  const _RankRow({required this.entry});

  String get _medal {
    if (entry.rank == 1) return '🥇';
    if (entry.rank == 2) return '🥈';
    if (entry.rank == 3) return '🥉';
    return '${entry.rank}';
  }

  @override
  Widget build(BuildContext context) {
    final isMe = entry.isCurrentUser;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? kGreenLight.withOpacity(0.08) : kSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isMe
                ? kGreenLight.withOpacity(0.4)
                : Colors.transparent),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(_medal,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Text(
                  entry.nickname,
                  style: TextStyle(
                    color:
                        isMe ? kGreenLight : kTextPrimary,
                    fontWeight: isMe
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
                if (entry.hasChampionBadge) ...[
                  const SizedBox(width: 6),
                  const Text('👑', style: TextStyle(fontSize: 13)),
                ],
                if (isMe)
                  const Text(' (você)',
                      style: TextStyle(
                          color: kGreenLight, fontSize: 12)),
              ],
            ),
          ),
          Text(
            '${entry.totalPoints} pts',
            style: TextStyle(
              color: isMe ? kGreenLight : kTextSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
