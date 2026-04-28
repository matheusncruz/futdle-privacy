/// Points for classic mode based on number of attempts (1–10 → 20–2, 11+ → 1).
int classicPoints(int attempts) {
  if (attempts <= 0) return 0;
  if (attempts >= 11) return 1;
  return 22 - attempts * 2;
}

/// Points for shield mode based on wrong answers (0–6 → 20–8, 7+ → 1).
int shieldPoints(int wrongCount) {
  if (wrongCount < 0) return 0;
  if (wrongCount >= 7) return 1;
  return 20 - wrongCount * 2;
}

/// Additional streak bonus earned when [currentStreak] days are reached,
/// given [alreadyAwarded] bonus points were previously awarded this month.
/// Milestones: 10 days → +50, 20 days → +100, 30 days → +200.
int streakBonusDelta(int currentStreak, int alreadyAwarded) {
  if (currentStreak >= 30 && alreadyAwarded < 350) return 350 - alreadyAwarded;
  if (currentStreak >= 20 && alreadyAwarded < 150) return 150 - alreadyAwarded;
  if (currentStreak >= 10 && alreadyAwarded < 50)  return 50  - alreadyAwarded;
  return 0;
}
