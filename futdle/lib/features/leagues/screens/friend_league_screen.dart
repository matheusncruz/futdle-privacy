// futdle/lib/features/leagues/screens/friend_league_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../core/supabase_client.dart';
import '../providers/friend_leagues_provider.dart';
import '../models/friend_league.dart';

class FriendLeagueScreen extends ConsumerWidget {
  final String leagueId;
  const FriendLeagueScreen({super.key, required this.leagueId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync  = ref.watch(friendLeagueDetailProvider(leagueId));
    final pendingAsync = ref.watch(pendingRequestsProvider(leagueId));

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: detailAsync.maybeWhen(
          data: (d) => Text(d?.name ?? 'Liga',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          orElse: () => const Text('Liga'),
        ),
        centerTitle: true,
        actions: [
          // Share code button
          detailAsync.maybeWhen(
            data: (d) => d == null
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.ios_share),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: d.code));
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Código copiado!')));
                    },
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: detailAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('Erro: $e',
                style: const TextStyle(color: kRed))),
        data: (detail) {
          if (detail == null) {
            return const Center(
                child: Text('Liga não encontrada.',
                    style: TextStyle(color: kTextSecondary)));
          }
          return _LeagueBody(
            detail:       detail,
            pendingAsync: pendingAsync,
            leagueId:     leagueId,
            ref:          ref,
          );
        },
      ),
    );
  }
}

class _LeagueBody extends StatelessWidget {
  final FriendLeagueDetail detail;
  final AsyncValue<List<PendingRequest>> pendingAsync;
  final String leagueId;
  final WidgetRef ref;
  const _LeagueBody({
    required this.detail,
    required this.pendingAsync,
    required this.leagueId,
    required this.ref,
  });

  String get _modeLabel => detail.mode == 'classic'
      ? '🎮 Clássico'
      : detail.mode == 'shield'
          ? '🛡️ Escudo'
          : '⚡ Ambos';

  Future<void> _approve(BuildContext ctx, String userId) async {
    await supabase
        .from('friend_league_members')
        .update({'status': 'approved', 'joined_at': DateTime.now().toIso8601String()})
        .eq('league_id', leagueId)
        .eq('user_id', userId);

    await supabase.from('friend_league_scores').upsert({
      'league_id':    leagueId,
      'user_id':      userId,
      'total_points': 0,
    }, onConflict: 'league_id,user_id');

    ref.invalidate(friendLeagueDetailProvider(leagueId));
    ref.invalidate(pendingRequestsProvider(leagueId));
  }

  Future<void> _reject(String userId) async {
    await supabase
        .from('friend_league_members')
        .update({'status': 'rejected'})
        .eq('league_id', leagueId)
        .eq('user_id', userId);
    ref.invalidate(pendingRequestsProvider(leagueId));
  }

  @override
  Widget build(BuildContext context) {
    final rankings = detail.rankings;
    final memberCount = rankings.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meta info
          Row(
            children: [
              Text('$_modeLabel · $memberCount membros',
                  style: const TextStyle(
                      color: kTextSecondary, fontSize: 12)),
              const Spacer(),
              Text(
                '${detail.daysLeft} dias restantes',
                style: const TextStyle(
                    color: Color(0xFFf59e0b), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Código: ${detail.code}',
              style: const TextStyle(
                  color: kTextSecondary, fontSize: 11, letterSpacing: 2)),
          const SizedBox(height: 16),

          // Pending requests (creator only)
          if (detail.isCreator)
            pendingAsync.when(
              loading: () => const SizedBox.shrink(),
              error:   (_, __) => const SizedBox.shrink(),
              data: (pending) => pending.isEmpty
                  ? const SizedBox.shrink()
                  : _PendingSection(
                      pending:  pending,
                      onApprove: (uid) => _approve(context, uid),
                      onReject:  _reject,
                    ),
            ),

          // Ranking
          const Text('RANKING',
              style: TextStyle(
                  color: kTextSecondary,
                  fontSize: 10,
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (rankings.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(12)),
              child: const Center(
                child: Text('Nenhuma pontuação ainda.',
                    style: TextStyle(color: kTextSecondary)),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: rankings.asMap().entries.map((e) {
                  return _RankRow(
                    entry: e.value,
                    isLast: e.key == rankings.length - 1,
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _PendingSection extends StatelessWidget {
  final List<PendingRequest> pending;
  final void Function(String) onApprove;
  final void Function(String) onReject;
  const _PendingSection(
      {required this.pending,
      required this.onApprove,
      required this.onReject});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFFf59e0b).withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('✋ SOLICITAÇÕES PENDENTES (${pending.length})',
              style: const TextStyle(
                  color: Color(0xFFf59e0b),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1)),
          const SizedBox(height: 10),
          ...pending.map((req) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(req.nickname,
                            style: const TextStyle(
                                color: kTextPrimary, fontSize: 13))),
                    GestureDetector(
                      onTap: () => onApprove(req.userId),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: kGreenLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('✓',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => onReject(req.userId),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: kRed.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('✕',
                            style: TextStyle(color: kRed)),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  final FriendLeagueRankEntry entry;
  final bool isLast;
  const _RankRow({required this.entry, required this.isLast});

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
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom:
                    BorderSide(color: Color(0xFF374151), width: 0.5)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(_medal,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isMe ? '${entry.nickname} (você)' : entry.nickname,
              style: TextStyle(
                color: isMe ? kGreenLight : kTextPrimary,
                fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
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
