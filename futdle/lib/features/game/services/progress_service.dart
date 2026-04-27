import 'dart:math';
import '../../../core/supabase_client.dart';
import 'streak_service.dart';

class ProgressService {
  /// Retorna o nickname existente ou cria um novo ("Craque#XXXX")
  static Future<String> getOrCreateNickname() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return 'Anônimo';

    final existing = await supabase
        .from('user_profiles')
        .select('nickname')
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) return existing['nickname'] as String;

    final rand = Random().nextInt(9000) + 1000;
    final nickname = 'Craque#$rand';

    await supabase.from('user_profiles').insert({
      'user_id': userId,
      'nickname': nickname,
    });

    return nickname;
  }

  /// Salva ou atualiza o resultado do desafio diário.
  /// Retorna o streak atual após a atualização (0 se falhou).
  static Future<int> saveResult({
    required String challengeId,
    required bool solved,
    required int attemptsCount,
    required int timeSeconds,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return 0;

    // Garante que o perfil existe antes de salvar
    await getOrCreateNickname();

    await supabase.from('user_progress').upsert(
      {
        'user_id': userId,
        'challenge_id': challengeId,
        'solved': solved,
        'attempts_count': attemptsCount,
        'time_seconds': timeSeconds,
        'attempts': [],
        'finished_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'user_id,challenge_id',
    );

    return StreakService.update(solved: solved);
  }
}
