import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/notification_service.dart';
import 'core/router.dart';
import 'core/theme.dart';

/// Resultado do check de perfil feito antes do runApp.
/// Evita redirect async no GoRouter (que causa tela branca).
bool appUserHasNickname = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gfdckfalguhfxyjkbwim.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdmZGNrZmFsZ3VoZnh5amtid2ltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU5MzIxMjQsImV4cCI6MjA5MTUwODEyNH0.IG0UXw9o4uGiQlqynDgVQjWYai1kn0uD_Wg8F4MZi2k',
  );

  // Notificações com timeout para não travar inicialização
  await NotificationService.initialize().timeout(
    const Duration(seconds: 4),
    onTimeout: () {},
  );

  final auth = Supabase.instance.client.auth;

  // Garante sessão (anônima ou existente)
  if (auth.currentUser == null) {
    await auth.signInAnonymously();
  }

  // Checa nickname ANTES do runApp → redirect do router fica síncrono
  try {
    final user = auth.currentUser;
    if (user != null) {
      final profile = await Supabase.instance.client
          .from('user_profiles')
          .select('nickname')
          .eq('user_id', user.id)
          .maybeSingle()
          .timeout(const Duration(seconds: 5));
      appUserHasNickname = profile != null;
    }
  } catch (_) {
    appUserHasNickname = false;
  }

  // Status bar transparente (sem forçar fullscreen que quebra o teclado)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const ProviderScope(child: FutdleApp()));
}

class FutdleApp extends ConsumerWidget {
  const FutdleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Futdle',
      theme: futdleTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
