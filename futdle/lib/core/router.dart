import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/home/screens/home_screen.dart';
import '../features/game/screens/game_screen.dart';
import '../features/result/screens/result_screen.dart';
import '../features/game/models/attempt_result.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/auth/screens/nickname_screen.dart';
import 'supabase_client.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      // Não redireciona se já está na tela de nickname
      if (state.matchedLocation == '/nickname') return null;

      final user = supabase.auth.currentUser;
      if (user == null) return null;

      // Verifica se já tem nickname cadastrado
      final profile = await supabase
          .from('user_profiles')
          .select('nickname')
          .eq('user_id', user.id)
          .maybeSingle();

      if (profile == null) return '/nickname';
      return null;
    },
    routes: [
      GoRoute(
        path: '/nickname',
        builder: (context, state) => const NicknameScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/game',
        builder: (context, state) {
          final mode = state.uri.queryParameters['mode'] ?? 'daily';
          return GameScreen(mode: mode);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/result',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ResultScreen(
            solved: extra['solved'] as bool,
            attempts: extra['attempts'] as int,
            attemptsList: (extra['attempts_list'] as List<AttemptResult>?) ?? const [],
            clubName: extra['clubName'] as String,
            mode: extra['mode'] as String? ?? 'daily',
            challengeId: extra['challengeId'] as String?,
            timeSeconds: extra['timeSeconds'] as int? ?? 0,
          );
        },
      ),
    ],
  );
});
