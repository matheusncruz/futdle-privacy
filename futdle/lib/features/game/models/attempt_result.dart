import 'club.dart';

enum FeedbackStatus { correct, partial, wrong }

enum Direction { up, down, none }

class AttributeFeedback {
  final FeedbackStatus status;
  final Direction direction;

  const AttributeFeedback({
    required this.status,
    this.direction = Direction.none,
  });
}

class AttemptResult {
  final Club club;
  final AttributeFeedback country;
  final AttributeFeedback continent;
  final AttributeFeedback league;
  final AttributeFeedback foundedYear;
  final AttributeFeedback primaryColor;
  final AttributeFeedback secondaryColor;
  final AttributeFeedback nationalTitles;
  final AttributeFeedback internationalTitles;

  const AttemptResult({
    required this.club,
    required this.country,
    required this.continent,
    required this.league,
    required this.foundedYear,
    required this.primaryColor,
    required this.secondaryColor,
    required this.nationalTitles,
    required this.internationalTitles,
  });

  bool get isCorrect => [
        country, continent, league, foundedYear,
        primaryColor, secondaryColor, nationalTitles, internationalTitles,
      ].every((f) => f.status == FeedbackStatus.correct);
}
