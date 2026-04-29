// futdle/lib/features/leagues/providers/friend_leagues_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_client.dart';
import '../models/friend_league.dart';

/// All active friend leagues the current user belongs to (approved).
final friendLeaguesProvider =
    FutureProvider<List<FriendLeagueSummary>>((ref) async {
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return [];

  final memberships = await supabase
      .from('friend_league_members')
      .select('league_id, friend_leagues(id, name, mode, starts_at, ends_at)')
      .eq('user_id', userId)
      .eq('status', 'approved');

  final today = DateTime.now();
  final result = <FriendLeagueSummary>[];

  for (final m in memberships as List) {
    final raw = m['friend_leagues'];
    if (raw == null) continue;
    final league = raw as Map<String, dynamic>;
    final endsAt = DateTime.parse(league['ends_at'] as String);
    if (endsAt.isBefore(DateTime(today.year, today.month, today.day))) continue;

    final leagueId = league['id'] as String;

    // Member count
    final members = await supabase
        .from('friend_league_members')
        .select('user_id')
        .eq('league_id', leagueId)
        .eq('status', 'approved');
    final memberCount = (members as List).length;

    // User rank
    final scores = await supabase
        .from('friend_league_scores')
        .select('user_id, total_points')
        .eq('league_id', leagueId)
        .order('total_points', ascending: false);

    int? userRank;
    int? userPoints;
    for (int i = 0; i < (scores as List).length; i++) {
      if (scores[i]['user_id'] == userId) {
        userRank   = i + 1;
        userPoints = scores[i]['total_points'] as int;
        break;
      }
    }

    result.add(FriendLeagueSummary(
      id:          leagueId,
      name:        league['name'] as String,
      mode:        league['mode'] as String,
      startsAt:    DateTime.parse(league['starts_at'] as String),
      endsAt:      endsAt,
      memberCount: memberCount,
      userRank:    userRank,
      userPoints:  userPoints,
    ));
  }

  return result;
});

/// Full detail + ranking for a specific friend league.
final friendLeagueDetailProvider =
    FutureProvider.family<FriendLeagueDetail?, String>((ref, leagueId) async {
  final currentUserId = supabase.auth.currentUser?.id;

  final leagueRow = await supabase
      .from('friend_leagues')
      .select('id, code, name, mode, entry_mode, created_by, starts_at, ends_at')
      .eq('id', leagueId)
      .maybeSingle();

  if (leagueRow == null) return null;

  final scores = await supabase
      .from('friend_league_scores')
      .select('user_id, total_points')
      .eq('league_id', leagueId)
      .order('total_points', ascending: false);

  final userIds = (scores as List).map((s) => s['user_id'] as String).toList();
  List<Map<String, dynamic>> profiles = [];
  if (userIds.isNotEmpty) {
    profiles = List<Map<String, dynamic>>.from(await supabase
        .from('user_profiles')
        .select('user_id, nickname')
        .inFilter('user_id', userIds));
  }
  final profileMap = {for (final p in profiles) p['user_id'] as String: p['nickname'] as String};

  final rankings = scores.asMap().entries.map((e) {
    final userId = e.value['user_id'] as String;
    return FriendLeagueRankEntry(
      userId:       userId,
      nickname:     profileMap[userId] ?? 'Anônimo',
      totalPoints:  e.value['total_points'] as int,
      rank:         e.key + 1,
      isCurrentUser: userId == currentUserId,
    );
  }).toList();

  return FriendLeagueDetail(
    id:         leagueRow['id'] as String,
    code:       leagueRow['code'] as String,
    name:       leagueRow['name'] as String,
    mode:       leagueRow['mode'] as String,
    entryMode:  leagueRow['entry_mode'] as String,
    createdBy:  leagueRow['created_by'] as String,
    startsAt:   DateTime.parse(leagueRow['starts_at'] as String),
    endsAt:     DateTime.parse(leagueRow['ends_at'] as String),
    rankings:   rankings,
    isCreator:  leagueRow['created_by'] == currentUserId,
  );
});

/// Pending join requests for a league (visible to creator only).
final pendingRequestsProvider =
    FutureProvider.family<List<PendingRequest>, String>((ref, leagueId) async {
  final pending = await supabase
      .from('friend_league_members')
      .select('user_id')
      .eq('league_id', leagueId)
      .eq('status', 'pending');

  if ((pending as List).isEmpty) return [];

  final userIds = pending.map((r) => r['user_id'] as String).toList();
  final profiles = await supabase
      .from('user_profiles')
      .select('user_id, nickname')
      .inFilter('user_id', userIds);

  final profileMap = {
    for (final p in profiles as List) p['user_id'] as String: p['nickname'] as String,
  };

  return pending.map((r) {
    final uid = r['user_id'] as String;
    return PendingRequest(userId: uid, nickname: profileMap[uid] ?? 'Anônimo');
  }).toList();
});
