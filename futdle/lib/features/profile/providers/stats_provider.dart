import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_client.dart';
import '../../game/services/progress_service.dart';

class PlayerStats {
  final String nickname;
  final int totalGames;
  final int wins;
  final double winRate;
  final double avgAttempts;
  final int bestAttempts;
  final String bestTime;

  const PlayerStats({
    required this.nickname,
    required this.totalGames,
    required this.wins,
    required this.winRate,
    required this.avgAttempts,
    required this.bestAttempts,
    required this.bestTime,
  });
}

final playerStatsProvider = FutureProvider<PlayerStats>((ref) async {
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) throw Exception('Sem usuário');

  final progress = await supabase
      .from('user_progress')
      .select('solved, attempts_count, time_seconds')
      .eq('user_id', userId);

  final nickname = await ProgressService.getOrCreateNickname();

  final total = progress.length;
  final wonGames = progress.where((r) => r['solved'] == true).toList();
  final wins = wonGames.length;
  final winRate = total > 0 ? (wins / total * 100) : 0.0;

  final avgAttempts = wonGames.isNotEmpty
      ? wonGames
              .map((r) => r['attempts_count'] as int)
              .reduce((a, b) => a + b) /
          wonGames.length
      : 0.0;

  final bestAttempts = wonGames.isNotEmpty
      ? wonGames.map((r) => r['attempts_count'] as int).reduce(min)
      : 0;

  // Melhor tempo (menor) entre as vitórias
  String bestTime = '-';
  if (wonGames.isNotEmpty) {
    final minSeconds =
        wonGames.map((r) => r['time_seconds'] as int).reduce(min);
    if (minSeconds >= 60) {
      final m = minSeconds ~/ 60;
      final s = minSeconds % 60;
      bestTime = '${m}m ${s}s';
    } else {
      bestTime = '${minSeconds}s';
    }
  }

  return PlayerStats(
    nickname: nickname,
    totalGames: total,
    wins: wins,
    winRate: winRate,
    avgAttempts: avgAttempts,
    bestAttempts: bestAttempts,
    bestTime: bestTime,
  );
});
