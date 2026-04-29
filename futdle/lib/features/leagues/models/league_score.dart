// futdle/lib/features/leagues/models/league_score.dart

class OfficialLeagueRankEntry {
  final String userId;
  final String nickname;
  final int totalPoints;
  final int rank;
  final int currentStreak;
  final bool isCurrentUser;
  final bool hasChampionBadge;

  const OfficialLeagueRankEntry({
    required this.userId,
    required this.nickname,
    required this.totalPoints,
    required this.rank,
    required this.currentStreak,
    required this.isCurrentUser,
    required this.hasChampionBadge,
  });
}

class MyLeaguePosition {
  final int points;
  final int rank;
  final int streak;

  const MyLeaguePosition({
    required this.points,
    required this.rank,
    required this.streak,
  });
}
