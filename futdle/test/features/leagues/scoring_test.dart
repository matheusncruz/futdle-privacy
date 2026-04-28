import 'package:flutter_test/flutter_test.dart';
import 'package:futdle/features/leagues/utils/scoring.dart';

void main() {
  group('classicPoints', () {
    test('1 attempt = 20 pts', () => expect(classicPoints(1), 20));
    test('2 attempts = 18 pts', () => expect(classicPoints(2), 18));
    test('3 attempts = 16 pts', () => expect(classicPoints(3), 16));
    test('10 attempts = 2 pts', () => expect(classicPoints(10), 2));
    test('11 attempts = 1 pt',  () => expect(classicPoints(11), 1));
    test('20 attempts = 1 pt',  () => expect(classicPoints(20), 1));
  });

  group('shieldPoints', () {
    test('0 wrong = 20 pts', () => expect(shieldPoints(0), 20));
    test('1 wrong = 18 pts', () => expect(shieldPoints(1), 18));
    test('6 wrong = 8 pts',  () => expect(shieldPoints(6), 8));
    test('7 wrong = 1 pt',   () => expect(shieldPoints(7), 1));
    test('10 wrong = 1 pt',  () => expect(shieldPoints(10), 1));
  });

  group('streakBonusDelta', () {
    test('no bonus before 10 days',       () => expect(streakBonusDelta(9, 0),   0));
    test('+50 pts at day 10',             () => expect(streakBonusDelta(10, 0),  50));
    test('no double bonus at day 10',     () => expect(streakBonusDelta(10, 50), 0));
    test('+100 pts at day 20',            () => expect(streakBonusDelta(20, 50), 100));
    test('no double bonus at day 20',     () => expect(streakBonusDelta(20, 150), 0));
    test('+200 pts at day 30',            () => expect(streakBonusDelta(30, 150), 200));
    test('no double bonus at day 30',     () => expect(streakBonusDelta(30, 350), 0));
    test('negative alreadyAwarded treated as 0', () => expect(streakBonusDelta(10, -1), 50));
  });
}
