// futdle/lib/features/leagues/providers/trophies_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_client.dart';
import '../models/trophy.dart';

final userTrophiesProvider = FutureProvider<List<UserTrophy>>((ref) async {
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return [];

  final rows = await supabase
      .from('user_trophies')
      .select('type, month, awarded_at')
      .eq('user_id', userId)
      .order('awarded_at', ascending: false);

  return (rows as List).map((r) => UserTrophy(
    type:      r['type'] as String,
    month:     DateTime.parse(r['month'] as String),
    awardedAt: DateTime.parse(r['awarded_at'] as String),
  )).toList();
});
