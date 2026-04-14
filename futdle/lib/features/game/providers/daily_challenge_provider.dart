import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_client.dart';
import '../models/club.dart';

class DailyChallenge {
  final String id;
  final Club club;
  final String date;

  const DailyChallenge({required this.id, required this.club, required this.date});
}

final dailyChallengeProvider = FutureProvider<DailyChallenge>((ref) async {
  final today = DateTime.now().toIso8601String().substring(0, 10);
  final data = await supabase
      .from('daily_challenges')
      .select('id, date, clubs(*, leagues(name))')
      .eq('date', today)
      .single();

  return DailyChallenge(
    id: data['id'] as String,
    club: Club.fromJson(data['clubs'] as Map<String, dynamic>),
    date: data['date'] as String,
  );
});
