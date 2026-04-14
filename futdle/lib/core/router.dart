import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/home/screens/home_screen.dart';
import '../features/game/screens/game_screen.dart';
import '../features/result/screens/result_screen.dart';
import '../features/game/models/attempt_result.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/auth/screens/nickname_screen.dart';
import '../features/shield/screens/shield_game_screen.dart';
import '../features/shield/screens/shield_result_screen.dart';
import '../main.dart' show appUserHasNickname;

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    // Redirect síncrono — sem await, sem tela branca
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (loc == '/nickname') return null;
      if (loc != '/') return null;
      if (!appUserHasNickname) return '/nickname';
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
        path: '/shield-game',
        builder: (context, state) => const ShieldGameScreen(),
      ),
      GoRoute(
        path: '/shield-result',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ShieldResultScreen(
            solved: extra['solved'] as bool,
            wrongCount: extra['wrongCount'] as int,
            clubName: extra['clubName'] as String,
            shieldUrl: extra['shieldUrl'] as String,
            timeSeconds: extra['timeSeconds'] as int? ?? 0,
          );
        },
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
