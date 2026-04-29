// futdle/lib/features/leagues/models/friend_league.dart

class FriendLeagueSummary {
  final String id;
  final String name;
  final String mode;
  final DateTime startsAt;
  final DateTime endsAt;
  final int memberCount;
  final int? userRank;
  final int? userPoints;

  const FriendLeagueSummary({
    required this.id,
    required this.name,
    required this.mode,
    required this.startsAt,
    required this.endsAt,
    required this.memberCount,
    this.userRank,
    this.userPoints,
  });

  int get daysLeft => endsAt.difference(DateTime.now()).inDays + 1;
}

class FriendLeagueRankEntry {
  final String userId;
  final String nickname;
  final int totalPoints;
  final int rank;
  final bool isCurrentUser;

  const FriendLeagueRankEntry({
    required this.userId,
    required this.nickname,
    required this.totalPoints,
    required this.rank,
    required this.isCurrentUser,
  });
}

class PendingRequest {
  final String userId;
  final String nickname;

  const PendingRequest({required this.userId, required this.nickname});
}

class FriendLeagueDetail {
  final String id;
  final String code;
  final String name;
  final String mode;
  final String entryMode;
  final String createdBy;
  final DateTime startsAt;
  final DateTime endsAt;
  final List<FriendLeagueRankEntry> rankings;
  final bool isCreator;

  const FriendLeagueDetail({
    required this.id,
    required this.code,
    required this.name,
    required this.mode,
    required this.entryMode,
    required this.createdBy,
    required this.startsAt,
    required this.endsAt,
    required this.rankings,
    required this.isCreator,
  });

  int get daysLeft => endsAt.difference(DateTime.now()).inDays + 1;
}
