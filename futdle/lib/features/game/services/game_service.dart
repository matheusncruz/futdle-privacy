import '../models/club.dart';
import '../models/attempt_result.dart';

AttemptResult evaluateAttempt(Club attempt, Club target) {
  return AttemptResult(
    club: attempt,
    country: _exactMatch(attempt.country, target.country),
    continent: _exactMatch(attempt.continent, target.continent),
    league: _leagueMatch(attempt, target),
    foundedYear: _numericMatch(attempt.foundedYear, target.foundedYear),
    primaryColor: _colorMatch(attempt.primaryColor, target.primaryColor),
    secondaryColor: _colorMatch(attempt.secondaryColor, target.secondaryColor),
    nationalTitles: _numericMatchRounded(attempt.nationalTitles, target.nationalTitles),
    internationalTitles: _numericMatchRounded(attempt.internationalTitles, target.internationalTitles),
  );
}

AttributeFeedback _exactMatch(String a, String b) {
  return AttributeFeedback(
    status: a == b ? FeedbackStatus.correct : FeedbackStatus.wrong,
  );
}

AttributeFeedback _leagueMatch(Club attempt, Club target) {
  if (attempt.leagueName == target.leagueName) {
    return const AttributeFeedback(status: FeedbackStatus.correct);
  }
  if (attempt.country == target.country) {
    return const AttributeFeedback(status: FeedbackStatus.partial);
  }
  return const AttributeFeedback(status: FeedbackStatus.wrong);
}

int _roundToNearest5(int value) => ((value / 5).round() * 5).clamp(5, 999);

AttributeFeedback _numericMatch(int attempt, int target) {
  if (attempt == target) {
    return const AttributeFeedback(status: FeedbackStatus.correct);
  }
  // Se digitei 1920 e o alvo é 1900, preciso ir para baixo (ano menor) → ↓
  return AttributeFeedback(
    status: FeedbackStatus.wrong,
    direction: attempt > target ? Direction.down : Direction.up,
  );
}

AttributeFeedback _numericMatchRounded(int attempt, int target) {
  final rAttempt = _roundToNearest5(attempt);
  final rTarget = _roundToNearest5(target);
  if (rAttempt == rTarget) {
    return const AttributeFeedback(status: FeedbackStatus.correct);
  }
  return AttributeFeedback(
    status: FeedbackStatus.wrong,
    direction: rAttempt > rTarget ? Direction.down : Direction.up,
  );
}

/// Retorna a faixa de títulos para exibição na célula
String titleRange(int value) {
  if (value == 0) return '0';
  if (value <= 5) return '1–5';
  if (value <= 10) return '6–10';
  if (value <= 20) return '11–20';
  if (value <= 30) return '21–30';
  if (value <= 50) return '31–50';
  return '50+';
}

AttributeFeedback _colorMatch(String attemptHex, String targetHex) {
  if (attemptHex.toLowerCase() == targetHex.toLowerCase()) {
    return const AttributeFeedback(status: FeedbackStatus.correct);
  }
  if (attemptHex.length > 1 &&
      targetHex.length > 1 &&
      attemptHex[1].toLowerCase() == targetHex[1].toLowerCase()) {
    return const AttributeFeedback(status: FeedbackStatus.partial);
  }
  return const AttributeFeedback(status: FeedbackStatus.wrong);
}
