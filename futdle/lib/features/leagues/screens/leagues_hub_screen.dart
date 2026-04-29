// futdle/lib/features/leagues/screens/leagues_hub_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../providers/official_league_provider.dart';
import '../providers/friend_leagues_provider.dart';
import '../models/friend_league.dart';

class LeaguesHubScreen extends ConsumerWidget {
  const LeaguesHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classicPos = ref.watch(myLeaguePositionProvider('classic'));
    final shieldPos  = ref.watch(myLeaguePositionProvider('shield'));
    final friendLeagues = ref.watch(friendLeaguesProvider);

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Ligas',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Official leagues ──────────────────────────────────────────
            _SectionHeader(title: '🏆 Liga Oficial', color: const Color(0xFFf59e0b)),
            const SizedBox(height: 10),
            _OfficialLeagueCard(
              label:   '🎮 Clássico',
              mode:    'classic',
              posAsync: classicPos,
              onTap:   () => context.push('/leagues/official/classic'),
            ),
            const SizedBox(height: 10),
            _OfficialLeagueCard(
              label:   '🛡️ Escudo',
              mode:    'shield',
              posAsync: shieldPos,
              onTap:   () => context.push('/leagues/official/shield'),
            ),
            const SizedBox(height: 24),

            // ── Friend leagues ────────────────────────────────────────────
            Row(
              children: [
                const Expanded(
                  child: _SectionHeader(title: '👥 Suas Ligas', color: Color(0xFF60a5fa)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            friendLeagues.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:   (e, _) => Text('Erro: $e', style: const TextStyle(color: kRed)),
              data:    (leagues) => leagues.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: kSurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Você ainda não participa de nenhuma liga de amigos.',
                        style: TextStyle(color: kTextSecondary),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Column(
                      children: leagues
                          .map((l) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _FriendLeagueCard(
                                  league: l,
                                  onTap:  () => context.push('/leagues/friend/${l.id}'),
                                ),
                              ))
                          .toList(),
                    ),
            ),
            const SizedBox(height: 20),

            // ── Action buttons ────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: '+ Criar liga',
                    color: const Color(0xFF60a5fa),
                    onTap: () => context.push('/leagues/create'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    label: 'Entrar com código',
                    color: kGreenLight,
                    onTap: () => context.push('/leagues/join'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets ──────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      );
}

class _OfficialLeagueCard extends StatelessWidget {
  final String label;
  final String mode;
  final AsyncValue<MyLeaguePosition?> posAsync;
  final VoidCallback onTap;
  const _OfficialLeagueCard({
    required this.label,
    required this.mode,
    required this.posAsync,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFf59e0b).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: kTextPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const SizedBox(height: 4),
                  posAsync.when(
                    loading: () => const Text('Carregando...',
                        style: TextStyle(color: kTextSecondary, fontSize: 12)),
                    error:   (_, __) => const Text('—',
                        style: TextStyle(color: kTextSecondary, fontSize: 12)),
                    data: (pos) => pos == null
                        ? const Text('Sem pontos ainda',
                            style: TextStyle(color: kTextSecondary, fontSize: 12))
                        : Text(
                            '${pos.points} pts · #${pos.rank}º · 🔥 ${pos.streak} dias',
                            style: const TextStyle(color: kGreenLight, fontSize: 12)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: kTextSecondary),
          ],
        ),
      ),
    );
  }
}

class _FriendLeagueCard extends StatelessWidget {
  final FriendLeagueSummary league;
  final VoidCallback onTap;
  const _FriendLeagueCard({required this.league, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final modeLabel = league.mode == 'classic'
        ? '🎮 Clássico'
        : league.mode == 'shield'
            ? '🛡️ Escudo'
            : '⚡ Ambos';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: const Color(0xFF60a5fa).withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(league.name,
                      style: const TextStyle(
                          color: kTextPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    '$modeLabel · ${league.memberCount} membros · ${league.daysLeft} dias restantes',
                    style: const TextStyle(color: kTextSecondary, fontSize: 12),
                  ),
                  if (league.userRank != null)
                    Text(
                      '#${league.userRank}º · ${league.userPoints} pts',
                      style: const TextStyle(color: kGreenLight, fontSize: 12),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: kTextSecondary),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withOpacity(0.6)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 13)),
    );
  }
}
