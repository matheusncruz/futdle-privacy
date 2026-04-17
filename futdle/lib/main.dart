import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/notification_service.dart';
import 'core/router.dart';
import 'core/theme.dart';

const _kHasNicknameKey = 'has_nickname';

/// Lido do cache local — redirect do router é 100% síncrono, sem tela branca.
bool appUserHasNickname = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Cache local — leitura instantânea, sem rede
  final prefs = await SharedPreferences.getInstance();
  appUserHasNickname = prefs.getBool(_kHasNicknameKey) ?? false;

  // 2) Supabase init (restaura sessão do storage local — rápido)
  await Supabase.initialize(
    url: 'https://gfdckfalguhfxyjkbwim.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdmZGNrZmFsZ3VoZnh5amtid2ltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU5MzIxMjQsImV4cCI6MjA5MTUwODEyNH0.IG0UXw9o4uGiQlqynDgVQjWYai1kn0uD_Wg8F4MZi2k',
  );

  // 3) Status bar transparente
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // 4) Sobe o app IMEDIATAMENTE — signInAnonymously vai pro background
  runApp(const ProviderScope(child: FutdleApp()));

  // 5) Tudo que envolve rede roda em background (não bloqueia UI)
  _initBackground(prefs);
}

/// Inicializações que não precisam bloquear o app.
Future<void> _initBackground(SharedPreferences prefs) async {
  final auth = Supabase.instance.client.auth;

  // Garante sessão anônima em background — não bloqueia o runApp
  if (auth.currentUser == null) {
    try {
      await auth.signInAnonymously().timeout(const Duration(seconds: 10));
      appUserHasNickname = false;
      await prefs.setBool(_kHasNicknameKey, false);
    } catch (_) {
      // Sem rede — tenta novamente na próxima abertura
    }
  }

  // Notificações — pode ser lento por causa do timezone
  NotificationService.initialize().timeout(
    const Duration(seconds: 6),
    onTimeout: () {},
  );

  // Verifica nickname no Supabase e atualiza cache
  try {
    final user = auth.currentUser;
    if (user != null) {
      final profile = await Supabase.instance.client
          .from('user_profiles')
          .select('nickname')
          .eq('user_id', user.id)
          .maybeSingle()
          .timeout(const Duration(seconds: 8));

      await prefs.setBool(_kHasNicknameKey, profile != null);
    }
  } catch (_) {
    // Falha silenciosa — usa o valor cacheado
  }
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
