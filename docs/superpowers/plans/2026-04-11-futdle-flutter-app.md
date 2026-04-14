# Futdle — Plano 2: Flutter App (Android)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Pre-requisito:** Plano 1 concluído (Supabase configurado, ~160 clubes inseridos, desafios criados).

**Goal:** Construir o app Android Futdle com modo clássico de desafio diário, sistema de energia, tela de resultado com compartilhamento e banner de ads.

**Architecture:** Flutter com Riverpod para estado, GoRouter para navegação, Supabase Flutter SDK para dados e auth anônimo. Cada feature fica em seu próprio diretório dentro de `lib/features/`.

**Tech Stack:** Flutter 3.x (Dart), flutter_riverpod 2.x, supabase_flutter 2.x, go_router 13.x, google_mobile_ads 5.x, share_plus 9.x

---

## Arquivos que serão criados/modificados

```
futdle/
  lib/
    main.dart                                   -- entry point, init Supabase + Riverpod
    core/
      supabase_client.dart                      -- instância global do Supabase
      router.dart                               -- GoRouter com todas as rotas
      theme.dart                                -- cores e tipografia globais
      constants.dart                            -- constantes (MAX_ENERGY, REGEN_MINUTES etc)
    features/
      game/
        models/
          club.dart                             -- Club data class + fromJson
          attempt_result.dart                   -- AttemptResult + AttributeFeedback
        services/
          game_service.dart                     -- lógica de feedback puro (sem estado)
        providers/
          clubs_provider.dart                   -- Riverpod: lista de clubes + busca
          game_provider.dart                    -- Riverpod: estado da partida
          daily_challenge_provider.dart         -- Riverpod: desafio do dia
        screens/
          game_screen.dart                      -- tela de jogo completa
        widgets/
          club_search_field.dart                -- campo autocomplete de busca
          attempt_row.dart                      -- linha de tentativa (8 células)
          feedback_cell.dart                    -- célula individual com cor + ícone
      home/
        screens/
          home_screen.dart                      -- tela principal
      result/
        screens/
          result_screen.dart                    -- resultado + botão compartilhar
      energy/
        models/
          energy_state.dart                     -- modelo de energia com cálculo de regen
        providers/
          energy_provider.dart                  -- Riverpod: energia do jogador
        widgets/
          energy_bar.dart                       -- display de energia (corações)
      ads/
        ad_banner.dart                          -- widget de banner AdMob
  pubspec.yaml
  android/
    app/
      src/
        main/
          AndroidManifest.xml                   -- adicionar AdMob app ID
```

---

## Task 1: Instalar Flutter e configurar ambiente Android

**Files:**
- Nenhum arquivo criado — instalação de ferramentas

- [ ] **Step 1: Baixar Flutter SDK**

  Acesse [flutter.dev/docs/get-started/install/windows](https://flutter.dev/docs/get-started/install/windows) e baixe o arquivo ZIP do Flutter SDK (versão estável).

- [ ] **Step 2: Extrair e configurar PATH**

  1. Extraia o ZIP para `C:\flutter` (sem espaços no caminho)
  2. Pesquise "Variáveis de Ambiente" no Windows
  3. Em "Variáveis do usuário", edite `Path` e adicione: `C:\flutter\bin`
  4. Feche e reabra o terminal

- [ ] **Step 3: Verificar instalação**

  ```bash
  flutter --version
  ```
  Esperado: `Flutter 3.x.x ...`

- [ ] **Step 4: Baixar e instalar Android Studio**

  Acesse [developer.android.com/studio](https://developer.android.com/studio), baixe e instale.
  Durante a instalação, aceite instalar o Android SDK.

- [ ] **Step 5: Instalar plugin Flutter no Android Studio**

  Android Studio → **Plugins** → pesquise `Flutter` → Install → Restart.

- [ ] **Step 6: Aceitar licenças Android**

  ```bash
  flutter doctor --android-licenses
  ```
  Responda `y` para todas as licenças.

- [ ] **Step 7: Rodar flutter doctor**

  ```bash
  flutter doctor
  ```
  Esperado: checkmarks em Flutter, Android toolchain e Android Studio. Ignore iOS.

---

## Task 2: Criar projeto Flutter e configurar dependências

**Files:**
- Create: `futdle/pubspec.yaml` (via flutter create)

- [ ] **Step 1: Criar projeto Flutter**

  ```bash
  cd "C:/Users/mathe/OneDrive/Desktop/Futdle"
  flutter create futdle --org com.futdle --platforms android
  ```

  Esperado: `All done! Your application code is in futdle\lib\main.dart`

- [ ] **Step 2: Entrar na pasta do app**

  ```bash
  cd futdle
  ```

- [ ] **Step 3: Atualizar pubspec.yaml**

  Abra `futdle/pubspec.yaml` e substitua a seção `dependencies:` por:

  ```yaml
  dependencies:
    flutter:
      sdk: flutter
    supabase_flutter: ^2.5.0
    flutter_riverpod: ^2.5.1
    go_router: ^13.2.0
    google_mobile_ads: ^5.1.0
    share_plus: ^9.0.0
    intl: ^0.19.0

  dev_dependencies:
    flutter_test:
      sdk: flutter
    flutter_lints: ^3.0.0
  ```

- [ ] **Step 4: Instalar dependências**

  ```bash
  flutter pub get
  ```

  Esperado: `Resolving dependencies... Got dependencies!`

- [ ] **Step 5: Commit**

  ```bash
  cd "C:/Users/mathe/OneDrive/Desktop/Futdle"
  git add futdle/
  git commit -m "feat: scaffold Flutter project with dependencies"
  ```

---

## Task 3: Configurar constantes, tema e cliente Supabase

**Files:**
- Create: `futdle/lib/core/constants.dart`
- Create: `futdle/lib/core/supabase_client.dart`
- Create: `futdle/lib/core/theme.dart`

- [ ] **Step 1: Criar constants.dart**

  Crie `futdle/lib/core/constants.dart`:

  ```dart
  const int kMaxEnergy = 5;
  const int kEnergyRegenMinutes = 30;
  const int kMaxRewardedAdsPerDay = 3;

  // Cores do feedback
  const String kColorCorrect = '#22c55e';   // verde
  const String kColorPartial = '#eab308';   // amarelo
  const String kColorWrong = '#ef4444';     // vermelho
  ```

- [ ] **Step 2: Criar supabase_client.dart**

  Crie `futdle/lib/core/supabase_client.dart`:

  ```dart
  import 'package:supabase_flutter/supabase_flutter.dart';

  /// Acesso global ao cliente Supabase após inicialização em main.dart
  SupabaseClient get supabase => Supabase.instance.client;
  ```

- [ ] **Step 3: Criar theme.dart**

  Crie `futdle/lib/core/theme.dart`:

  ```dart
  import 'package:flutter/material.dart';

  const Color kGreen = Color(0xFF1a472a);
  const Color kGreenLight = Color(0xFF22c55e);
  const Color kYellow = Color(0xFFEAB308);
  const Color kRed = Color(0xFFEF4444);
  const Color kBackground = Color(0xFF111827);
  const Color kSurface = Color(0xFF1F2937);
  const Color kTextPrimary = Color(0xFFF9FAFB);
  const Color kTextSecondary = Color(0xFF9CA3AF);

  final ThemeData futdleTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kBackground,
    colorScheme: const ColorScheme.dark(
      primary: kGreen,
      secondary: kGreenLight,
      surface: kSurface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: kBackground,
      foregroundColor: kTextPrimary,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: kTextPrimary,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      bodyMedium: TextStyle(color: kTextPrimary, fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kGreen,
        foregroundColor: kTextPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: kTextSecondary),
    ),
  );
  ```

- [ ] **Step 4: Commit**

  ```bash
  git add futdle/lib/core/
  git commit -m "feat: add core constants, theme, and supabase client"
  ```

---

## Task 4: Configurar main.dart e inicialização

**Files:**
- Modify: `futdle/lib/main.dart`

- [ ] **Step 1: Substituir main.dart**

  Substitua todo o conteúdo de `futdle/lib/main.dart` por:

  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:supabase_flutter/supabase_flutter.dart';
  import 'core/router.dart';
  import 'core/theme.dart';

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Supabase.initialize(
      url: 'COLE_SUA_SUPABASE_URL_AQUI',
      anonKey: 'COLE_SUA_ANON_KEY_AQUI',
    );

    // Autenticação anônima automática
    final supabase = Supabase.instance.client;
    if (supabase.auth.currentUser == null) {
      await supabase.auth.signInAnonymously();
    }

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
  ```

  > Substitua `COLE_SUA_SUPABASE_URL_AQUI` e `COLE_SUA_ANON_KEY_AQUI` pelos valores do Supabase dashboard (Settings → API).

- [ ] **Step 2: Commit**

  ```bash
  git add futdle/lib/main.dart
  git commit -m "feat: init Supabase and anonymous auth in main.dart"
  ```

---

## Task 5: Configurar GoRouter

**Files:**
- Create: `futdle/lib/core/router.dart`

- [ ] **Step 1: Criar router.dart**

  Crie `futdle/lib/core/router.dart`:

  ```dart
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:go_router/go_router.dart';
  import '../features/home/screens/home_screen.dart';
  import '../features/game/screens/game_screen.dart';
  import '../features/result/screens/result_screen.dart';

  final routerProvider = Provider<GoRouter>((ref) {
    return GoRouter(
      initialLocation: '/',
      routes: [
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
          path: '/result',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return ResultScreen(
              solved: extra['solved'] as bool,
              attempts: extra['attempts'] as int,
              clubName: extra['clubName'] as String,
            );
          },
        ),
      ],
    );
  });
  ```

- [ ] **Step 2: Criar telas placeholder para compilar**

  Crie `futdle/lib/features/home/screens/home_screen.dart`:
  ```dart
  import 'package:flutter/material.dart';

  class HomeScreen extends StatelessWidget {
    const HomeScreen({super.key});

    @override
    Widget build(BuildContext context) {
      return const Scaffold(
        body: Center(child: Text('Home — em breve')),
      );
    }
  }
  ```

  Crie `futdle/lib/features/game/screens/game_screen.dart`:
  ```dart
  import 'package:flutter/material.dart';

  class GameScreen extends StatelessWidget {
    final String mode;
    const GameScreen({super.key, required this.mode});

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Center(child: Text('Game $mode — em breve')),
      );
    }
  }
  ```

  Crie `futdle/lib/features/result/screens/result_screen.dart`:
  ```dart
  import 'package:flutter/material.dart';

  class ResultScreen extends StatelessWidget {
    final bool solved;
    final int attempts;
    final String clubName;
    const ResultScreen({
      super.key,
      required this.solved,
      required this.attempts,
      required this.clubName,
    });

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Center(child: Text('Resultado — em breve')),
      );
    }
  }
  ```

- [ ] **Step 3: Testar build**

  ```bash
  cd "C:/Users/mathe/OneDrive/Desktop/Futdle/futdle"
  flutter build apk --debug
  ```

  Esperado: `✓ Built build\app\outputs\flutter-apk\app-debug.apk`

- [ ] **Step 4: Commit**

  ```bash
  git add futdle/lib/
  git commit -m "feat: add GoRouter with placeholder screens"
  ```

---

## Task 6: Modelos de dados (Club e AttemptResult)

**Files:**
- Create: `futdle/lib/features/game/models/club.dart`
- Create: `futdle/lib/features/game/models/attempt_result.dart`

- [ ] **Step 1: Criar club.dart**

  Crie `futdle/lib/features/game/models/club.dart`:

  ```dart
  class Club {
    final String id;
    final String name;
    final String? altName;
    final String country;
    final String continent;
    final String leagueName;
    final int foundedYear;
    final String primaryColor;
    final String secondaryColor;
    final int nationalTitles;
    final int internationalTitles;
    final String? shieldUrl;

    const Club({
      required this.id,
      required this.name,
      this.altName,
      required this.country,
      required this.continent,
      required this.leagueName,
      required this.foundedYear,
      required this.primaryColor,
      required this.secondaryColor,
      required this.nationalTitles,
      required this.internationalTitles,
      this.shieldUrl,
    });

    factory Club.fromJson(Map<String, dynamic> json) {
      return Club(
        id: json['id'] as String,
        name: json['name'] as String,
        altName: json['alt_name'] as String?,
        country: json['country'] as String,
        continent: json['continent'] as String,
        leagueName: (json['leagues'] as Map<String, dynamic>)['name'] as String,
        foundedYear: json['founded_year'] as int? ?? 0,
        primaryColor: json['primary_color'] as String,
        secondaryColor: json['secondary_color'] as String,
        nationalTitles: json['national_titles'] as int,
        internationalTitles: json['international_titles'] as int,
        shieldUrl: json['shield_url'] as String?,
      );
    }
  }
  ```

- [ ] **Step 2: Criar attempt_result.dart**

  Crie `futdle/lib/features/game/models/attempt_result.dart`:

  ```dart
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
    final String clubName;
    final AttributeFeedback country;
    final AttributeFeedback continent;
    final AttributeFeedback league;
    final AttributeFeedback foundedYear;
    final AttributeFeedback primaryColor;
    final AttributeFeedback secondaryColor;
    final AttributeFeedback nationalTitles;
    final AttributeFeedback internationalTitles;

    const AttemptResult({
      required this.clubName,
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
          country,
          continent,
          league,
          foundedYear,
          primaryColor,
          secondaryColor,
          nationalTitles,
          internationalTitles,
        ].every((f) => f.status == FeedbackStatus.correct);
  }
  ```

- [ ] **Step 3: Commit**

  ```bash
  git add futdle/lib/features/game/models/
  git commit -m "feat: add Club and AttemptResult models"
  ```

---

## Task 7: Lógica de feedback (game_service.dart) com testes

**Files:**
- Create: `futdle/lib/features/game/services/game_service.dart`
- Create: `futdle/test/game_service_test.dart`

- [ ] **Step 1: Escrever os testes primeiro**

  Crie `futdle/test/game_service_test.dart`:

  ```dart
  import 'package:flutter_test/flutter_test.dart';
  import 'package:futdle/features/game/models/club.dart';
  import 'package:futdle/features/game/models/attempt_result.dart';
  import 'package:futdle/features/game/services/game_service.dart';

  Club _makeClub({
    String id = '1',
    String name = 'Club A',
    String country = 'Brasil',
    String continent = 'América do Sul',
    String leagueName = 'Brasileirão',
    int foundedYear = 1895,
    String primaryColor = '#ff0000',
    String secondaryColor = '#000000',
    int nationalTitles = 5,
    int internationalTitles = 2,
  }) => Club(
        id: id,
        name: name,
        country: country,
        continent: continent,
        leagueName: leagueName,
        foundedYear: foundedYear,
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
        nationalTitles: nationalTitles,
        internationalTitles: internationalTitles,
      );

  void main() {
    group('evaluateAttempt', () {
      test('país correto → verde', () {
        final attempt = _makeClub(country: 'Brasil');
        final target = _makeClub(country: 'Brasil');
        final result = evaluateAttempt(attempt, target);
        expect(result.country.status, FeedbackStatus.correct);
      });

      test('país errado → vermelho', () {
        final attempt = _makeClub(country: 'Espanha');
        final target = _makeClub(country: 'Brasil');
        final result = evaluateAttempt(attempt, target);
        expect(result.country.status, FeedbackStatus.wrong);
      });

      test('mesma liga → verde na liga', () {
        final attempt = _makeClub(leagueName: 'Brasileirão');
        final target = _makeClub(leagueName: 'Brasileirão');
        final result = evaluateAttempt(attempt, target);
        expect(result.league.status, FeedbackStatus.correct);
      });

      test('mesmo continente mas liga diferente → amarelo na liga', () {
        final attempt = _makeClub(continent: 'Europa', leagueName: 'La Liga');
        final target = _makeClub(continent: 'Europa', leagueName: 'Premier League');
        final result = evaluateAttempt(attempt, target);
        expect(result.league.status, FeedbackStatus.partial);
      });

      test('ano de fundação correto → verde sem seta', () {
        final attempt = _makeClub(foundedYear: 1895);
        final target = _makeClub(foundedYear: 1895);
        final result = evaluateAttempt(attempt, target);
        expect(result.foundedYear.status, FeedbackStatus.correct);
        expect(result.foundedYear.direction, Direction.none);
      });

      test('ano de fundação mais recente → seta para cima (correto é mais antigo)', () {
        final attempt = _makeClub(foundedYear: 1920);
        final target = _makeClub(foundedYear: 1895);
        final result = evaluateAttempt(attempt, target);
        expect(result.foundedYear.status, FeedbackStatus.wrong);
        expect(result.foundedYear.direction, Direction.up);
      });

      test('ano de fundação mais antigo → seta para baixo (correto é mais recente)', () {
        final attempt = _makeClub(foundedYear: 1880);
        final target = _makeClub(foundedYear: 1895);
        final result = evaluateAttempt(attempt, target);
        expect(result.foundedYear.status, FeedbackStatus.wrong);
        expect(result.foundedYear.direction, Direction.down);
      });

      test('títulos nacionais corretos → verde', () {
        final attempt = _makeClub(nationalTitles: 5);
        final target = _makeClub(nationalTitles: 5);
        final result = evaluateAttempt(attempt, target);
        expect(result.nationalTitles.status, FeedbackStatus.correct);
      });

      test('títulos nacionais menores → seta para baixo (correto é maior)', () {
        final attempt = _makeClub(nationalTitles: 3);
        final target = _makeClub(nationalTitles: 5);
        final result = evaluateAttempt(attempt, target);
        expect(result.nationalTitles.status, FeedbackStatus.wrong);
        expect(result.nationalTitles.direction, Direction.down);
      });

      test('isCorrect quando todos os atributos são corretos', () {
        final club = _makeClub();
        final result = evaluateAttempt(club, club);
        expect(result.isCorrect, true);
      });
    });
  }
  ```

- [ ] **Step 2: Rodar os testes para confirmar que falham**

  ```bash
  flutter test test/game_service_test.dart
  ```

  Esperado: erros de compilação (`game_service.dart not found`) — isso é esperado.

- [ ] **Step 3: Criar game_service.dart**

  Crie `futdle/lib/features/game/services/game_service.dart`:

  ```dart
  import '../models/club.dart';
  import '../models/attempt_result.dart';

  /// Compara [attempt] com [target] e retorna o feedback por atributo.
  AttemptResult evaluateAttempt(Club attempt, Club target) {
    return AttemptResult(
      clubName: attempt.name,
      country: _exactMatch(attempt.country, target.country),
      continent: _exactMatch(attempt.continent, target.continent),
      league: _leagueMatch(attempt, target),
      foundedYear: _numericMatch(attempt.foundedYear, target.foundedYear),
      primaryColor: _colorMatch(attempt.primaryColor, target.primaryColor),
      secondaryColor: _colorMatch(attempt.secondaryColor, target.secondaryColor),
      nationalTitles: _numericMatch(attempt.nationalTitles, target.nationalTitles),
      internationalTitles: _numericMatch(attempt.internationalTitles, target.internationalTitles),
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
    if (attempt.continent == target.continent) {
      return const AttributeFeedback(status: FeedbackStatus.partial);
    }
    return const AttributeFeedback(status: FeedbackStatus.wrong);
  }

  AttributeFeedback _numericMatch(int attempt, int target) {
    if (attempt == target) {
      return const AttributeFeedback(status: FeedbackStatus.correct);
    }
    // direction: up = correto é mais antigo/maior, down = correto é mais recente/menor
    return AttributeFeedback(
      status: FeedbackStatus.wrong,
      direction: attempt > target ? Direction.up : Direction.down,
    );
  }

  AttributeFeedback _colorMatch(String attemptHex, String targetHex) {
    if (attemptHex.toLowerCase() == targetHex.toLowerCase()) {
      return const AttributeFeedback(status: FeedbackStatus.correct);
    }
    // Parcial: mesma família de cor (primeiro caractere após #)
    if (attemptHex.length > 1 &&
        targetHex.length > 1 &&
        attemptHex[1].toLowerCase() == targetHex[1].toLowerCase()) {
      return const AttributeFeedback(status: FeedbackStatus.partial);
    }
    return const AttributeFeedback(status: FeedbackStatus.wrong);
  }
  ```

- [ ] **Step 4: Rodar os testes**

  ```bash
  flutter test test/game_service_test.dart
  ```

  Esperado:
  ```
  00:01 +9: All tests passed!
  ```

- [ ] **Step 5: Commit**

  ```bash
  git add futdle/lib/features/game/services/ futdle/test/
  git commit -m "feat: add game feedback logic with tests"
  ```

---

## Task 8: Providers Riverpod (clubes e desafio diário)

**Files:**
- Create: `futdle/lib/features/game/providers/clubs_provider.dart`
- Create: `futdle/lib/features/game/providers/daily_challenge_provider.dart`
- Create: `futdle/lib/features/game/providers/game_provider.dart`

- [ ] **Step 1: Criar clubs_provider.dart**

  Crie `futdle/lib/features/game/providers/clubs_provider.dart`:

  ```dart
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import '../../../core/supabase_client.dart';
  import '../models/club.dart';

  /// Carrega todos os clubes uma vez (usado para busca/autocomplete)
  final allClubsProvider = FutureProvider<List<Club>>((ref) async {
    final data = await supabase
        .from('clubs')
        .select('*, leagues(name)')
        .order('name');
    return (data as List).map((e) => Club.fromJson(e)).toList();
  });

  /// Filtra clubes por nome digitado
  final clubSearchProvider = Provider.family<List<Club>, String>((ref, query) {
    final clubs = ref.watch(allClubsProvider).valueOrNull ?? [];
    if (query.isEmpty) return [];
    final lower = query.toLowerCase();
    return clubs
        .where((c) =>
            c.name.toLowerCase().contains(lower) ||
            (c.altName?.toLowerCase().contains(lower) ?? false))
        .take(8)
        .toList();
  });
  ```

- [ ] **Step 2: Criar daily_challenge_provider.dart**

  Crie `futdle/lib/features/game/providers/daily_challenge_provider.dart`:

  ```dart
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import '../../../core/supabase_client.dart';
  import '../models/club.dart';

  class DailyChallenge {
    final String id;
    final Club club;
    final String date;

    const DailyChallenge({
      required this.id,
      required this.club,
      required this.date,
    });
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
  ```

- [ ] **Step 3: Criar game_provider.dart**

  Crie `futdle/lib/features/game/providers/game_provider.dart`:

  ```dart
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import '../models/club.dart';
  import '../models/attempt_result.dart';
  import '../services/game_service.dart';

  class GameState {
    final List<AttemptResult> attempts;
    final bool solved;
    final bool gameOver;

    const GameState({
      this.attempts = const [],
      this.solved = false,
      this.gameOver = false,
    });

    GameState copyWith({
      List<AttemptResult>? attempts,
      bool? solved,
      bool? gameOver,
    }) {
      return GameState(
        attempts: attempts ?? this.attempts,
        solved: solved ?? this.solved,
        gameOver: gameOver ?? this.gameOver,
      );
    }
  }

  class GameNotifier extends StateNotifier<GameState> {
    final Club target;

    GameNotifier(this.target) : super(const GameState());

    void makeAttempt(Club attempt) {
      if (state.solved || state.gameOver) return;

      final result = evaluateAttempt(attempt, target);
      final newAttempts = [...state.attempts, result];

      state = state.copyWith(
        attempts: newAttempts,
        solved: result.isCorrect,
        gameOver: result.isCorrect,
      );
    }

    void reset() => state = const GameState();
  }

  final gameProvider = StateNotifierProvider.family<GameNotifier, GameState, Club>(
    (ref, target) => GameNotifier(target),
  );
  ```

- [ ] **Step 4: Commit**

  ```bash
  git add futdle/lib/features/game/providers/
  git commit -m "feat: add Riverpod providers for clubs, daily challenge, and game state"
  ```

---

## Task 9: Widgets de feedback (FeedbackCell e AttemptRow)

**Files:**
- Create: `futdle/lib/features/game/widgets/feedback_cell.dart`
- Create: `futdle/lib/features/game/widgets/attempt_row.dart`

- [ ] **Step 1: Criar feedback_cell.dart**

  Crie `futdle/lib/features/game/widgets/feedback_cell.dart`:

  ```dart
  import 'package:flutter/material.dart';
  import '../models/attempt_result.dart';
  import '../../../core/theme.dart';

  class FeedbackCell extends StatelessWidget {
    final AttributeFeedback feedback;
    final String label;

    const FeedbackCell({
      super.key,
      required this.feedback,
      required this.label,
    });

    Color get _backgroundColor {
      return switch (feedback.status) {
        FeedbackStatus.correct => kGreenLight,
        FeedbackStatus.partial => kYellow,
        FeedbackStatus.wrong => kRed,
      };
    }

    String get _directionIcon {
      return switch (feedback.direction) {
        Direction.up => ' ↑',
        Direction.down => ' ↓',
        Direction.none => '',
      };
    }

    @override
    Widget build(BuildContext context) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '$label$_directionIcon',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
  }
  ```

- [ ] **Step 2: Criar attempt_row.dart**

  Crie `futdle/lib/features/game/widgets/attempt_row.dart`:

  ```dart
  import 'package:flutter/material.dart';
  import '../models/attempt_result.dart';
  import 'feedback_cell.dart';

  class AttemptRow extends StatelessWidget {
    final AttemptResult result;

    const AttemptRow({super.key, required this.result});

    @override
    Widget build(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            // Nome do clube tentado
            Expanded(
              flex: 2,
              child: Text(
                result.clubName,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            // 8 células de feedback
            Expanded(
              flex: 8,
              child: Row(
                children: [
                  _cell(result.country, 'País'),
                  _cell(result.continent, 'Cont.'),
                  _cell(result.league, 'Liga'),
                  _cell(result.foundedYear, 'Ano'),
                  _cell(result.primaryColor, 'Cor 1'),
                  _cell(result.secondaryColor, 'Cor 2'),
                  _cell(result.nationalTitles, 'Nac.'),
                  _cell(result.internationalTitles, 'Int.'),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget _cell(AttributeFeedback feedback, String label) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: FeedbackCell(feedback: feedback, label: label),
        ),
      );
    }
  }
  ```

- [ ] **Step 3: Commit**

  ```bash
  git add futdle/lib/features/game/widgets/
  git commit -m "feat: add FeedbackCell and AttemptRow widgets"
  ```

---

## Task 10: Campo de busca com autocomplete

**Files:**
- Create: `futdle/lib/features/game/widgets/club_search_field.dart`

- [ ] **Step 1: Criar club_search_field.dart**

  Crie `futdle/lib/features/game/widgets/club_search_field.dart`:

  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import '../models/club.dart';
  import '../providers/clubs_provider.dart';
  import '../../../core/theme.dart';

  class ClubSearchField extends ConsumerStatefulWidget {
    final void Function(Club club) onClubSelected;

    const ClubSearchField({super.key, required this.onClubSelected});

    @override
    ConsumerState<ClubSearchField> createState() => _ClubSearchFieldState();
  }

  class _ClubSearchFieldState extends ConsumerState<ClubSearchField> {
    final _controller = TextEditingController();
    final _focusNode = FocusNode();

    @override
    void dispose() {
      _controller.dispose();
      _focusNode.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      final query = _controller.text;
      final suggestions = ref.watch(clubSearchProvider(query));

      return Column(
        children: [
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: const InputDecoration(
              hintText: 'Digite o nome do time...',
              prefixIcon: Icon(Icons.search, color: kTextSecondary),
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (suggestions.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: suggestions.length,
                itemBuilder: (context, i) {
                  final club = suggestions[i];
                  return ListTile(
                    dense: true,
                    title: Text(club.name, style: const TextStyle(fontSize: 14)),
                    subtitle: Text(
                      '${club.leagueName} · ${club.country}',
                      style: const TextStyle(fontSize: 12, color: kTextSecondary),
                    ),
                    onTap: () {
                      _controller.clear();
                      setState(() {});
                      _focusNode.unfocus();
                      widget.onClubSelected(club);
                    },
                  );
                },
              ),
            ),
        ],
      );
    }
  }
  ```

- [ ] **Step 2: Commit**

  ```bash
  git add futdle/lib/features/game/widgets/club_search_field.dart
  git commit -m "feat: add ClubSearchField with autocomplete"
  ```

---

## Task 11: Tela de jogo completa

**Files:**
- Modify: `futdle/lib/features/game/screens/game_screen.dart`

- [ ] **Step 1: Substituir game_screen.dart**

  Substitua `futdle/lib/features/game/screens/game_screen.dart` por:

  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:go_router/go_router.dart';
  import '../models/club.dart';
  import '../providers/daily_challenge_provider.dart';
  import '../providers/game_provider.dart';
  import '../widgets/attempt_row.dart';
  import '../widgets/club_search_field.dart';
  import '../../../core/theme.dart';

  class GameScreen extends ConsumerWidget {
    final String mode;
    const GameScreen({super.key, required this.mode});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final challengeAsync = ref.watch(dailyChallengeProvider);

      return challengeAsync.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(
          body: Center(child: Text('Erro ao carregar desafio: $e')),
        ),
        data: (challenge) => _GameView(
          target: challenge.club,
          mode: mode,
        ),
      );
    }
  }

  class _GameView extends ConsumerWidget {
    final Club target;
    final String mode;

    const _GameView({required this.target, required this.mode});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final gameState = ref.watch(gameProvider(target));
      final notifier = ref.read(gameProvider(target).notifier);

      // Navegar para resultado quando o jogo acabar
      ref.listen(gameProvider(target), (prev, next) {
        if (next.gameOver && !(prev?.gameOver ?? false)) {
          Future.delayed(const Duration(milliseconds: 600), () {
            if (context.mounted) {
              context.go('/result', extra: {
                'solved': next.solved,
                'attempts': next.attempts.length,
                'clubName': target.name,
              });
            }
          });
        }
      });

      return Scaffold(
        appBar: AppBar(
          title: const Text('FUTDLE', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Cabeçalho das colunas
              _ColumnHeaders(),
              const SizedBox(height: 8),

              // Lista de tentativas
              Expanded(
                child: ListView.builder(
                  itemCount: gameState.attempts.length,
                  itemBuilder: (_, i) => AttemptRow(result: gameState.attempts[i]),
                ),
              ),

              const SizedBox(height: 8),

              // Campo de busca (desabilitado se jogo acabou)
              if (!gameState.gameOver)
                ClubSearchField(
                  onClubSelected: (club) => notifier.makeAttempt(club),
                ),

              if (gameState.gameOver)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    gameState.solved ? 'Parabéns! 🎉' : 'Fim de jogo',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      );
    }
  }

  class _ColumnHeaders extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      const headers = ['Time', 'País', 'Cont.', 'Liga', 'Ano', 'Cor1', 'Cor2', 'Nac.', 'Int.'];
      return Row(
        children: [
          Expanded(flex: 2, child: _header(headers[0])),
          const SizedBox(width: 4),
          ...List.generate(
            8,
            (i) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: _header(headers[i + 1]),
              ),
            ),
          ),
        ],
      );
    }

    Widget _header(String text) => Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: kTextSecondary,
          ),
        );
  }
  ```

- [ ] **Step 2: Testar no emulador Android**

  Abra o Android Studio, inicie um emulador Android (AVD Manager → Play), depois:

  ```bash
  flutter run
  ```

  Esperado: app abre na Home, clicando em "Desafio Diário" navega para a tela de jogo com campo de busca.

- [ ] **Step 3: Commit**

  ```bash
  git add futdle/lib/features/game/screens/game_screen.dart
  git commit -m "feat: implement game screen with search and feedback grid"
  ```

---

## Task 12: Tela de resultado com compartilhamento

**Files:**
- Modify: `futdle/lib/features/result/screens/result_screen.dart`

- [ ] **Step 1: Substituir result_screen.dart**

  Substitua `futdle/lib/features/result/screens/result_screen.dart` por:

  ```dart
  import 'package:flutter/material.dart';
  import 'package:go_router/go_router.dart';
  import 'package:share_plus/share_plus.dart';
  import 'package:intl/intl.dart';
  import '../../../core/theme.dart';

  class ResultScreen extends StatelessWidget {
    final bool solved;
    final int attempts;
    final String clubName;

    const ResultScreen({
      super.key,
      required this.solved,
      required this.attempts,
      required this.clubName,
    });

    String _buildShareText() {
      final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
      final emoji = solved ? '🟢' : '🔴';
      final attemptsText = solved ? '$attempts tentativas' : 'Não acertei';
      return 'Futdle $today $emoji\n'
          'Time: $clubName\n'
          '$attemptsText\n'
          'Jogue você também! #Futdle';
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('FUTDLE', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  solved ? Icons.emoji_events : Icons.sports_soccer,
                  size: 80,
                  color: solved ? kYellow : kTextSecondary,
                ),
                const SizedBox(height: 24),
                Text(
                  solved ? 'Você acertou!' : 'Era $clubName',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: kTextPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                if (solved)
                  Text(
                    '$attempts ${attempts == 1 ? 'tentativa' : 'tentativas'}',
                    style: const TextStyle(fontSize: 18, color: kTextSecondary),
                  ),
                const SizedBox(height: 40),

                // Botão compartilhar
                ElevatedButton.icon(
                  onPressed: () => Share.share(_buildShareText()),
                  icon: const Icon(Icons.share),
                  label: const Text('Compartilhar resultado'),
                ),
                const SizedBox(height: 16),

                // Voltar para home
                TextButton(
                  onPressed: () => context.go('/'),
                  child: const Text(
                    'Voltar ao início',
                    style: TextStyle(color: kTextSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
  ```

- [ ] **Step 2: Commit**

  ```bash
  git add futdle/lib/features/result/
  git commit -m "feat: implement result screen with share button"
  ```

---

## Task 13: Sistema de energia

**Files:**
- Create: `futdle/lib/features/energy/models/energy_state.dart`
- Create: `futdle/lib/features/energy/providers/energy_provider.dart`
- Create: `futdle/lib/features/energy/widgets/energy_bar.dart`

- [ ] **Step 1: Criar energy_state.dart**

  Crie `futdle/lib/features/energy/models/energy_state.dart`:

  ```dart
  import '../../../core/constants.dart';

  class EnergyState {
    final int current;
    final DateTime lastRegenAt;

    const EnergyState({required this.current, required this.lastRegenAt});

    /// Calcula energia atual considerando regeneração passiva
    EnergyState withRegen() {
      final now = DateTime.now();
      final elapsed = now.difference(lastRegenAt);
      final regenCount = elapsed.inMinutes ~/ kEnergyRegenMinutes;
      if (regenCount == 0) return this;

      final newEnergy = (current + regenCount).clamp(0, kMaxEnergy);
      final newLastRegen = lastRegenAt.add(
        Duration(minutes: regenCount * kEnergyRegenMinutes),
      );
      return EnergyState(current: newEnergy, lastRegenAt: newLastRegen);
    }

    bool get canPlay => current > 0;

    Duration get timeToNextRegen {
      final elapsed = DateTime.now().difference(lastRegenAt);
      final remaining = Duration(minutes: kEnergyRegenMinutes) - elapsed;
      return remaining.isNegative ? Duration.zero : remaining;
    }
  }
  ```

- [ ] **Step 2: Criar energy_provider.dart**

  Crie `futdle/lib/features/energy/providers/energy_provider.dart`:

  ```dart
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import '../../../core/supabase_client.dart';
  import '../../../core/constants.dart';
  import '../models/energy_state.dart';

  class EnergyNotifier extends AsyncNotifier<EnergyState> {
    @override
    Future<EnergyState> build() async {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        return EnergyState(current: kMaxEnergy, lastRegenAt: DateTime.now());
      }

      final data = await supabase
          .from('user_energy')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (data == null) {
        // Primeiro acesso: criar registro
        final now = DateTime.now();
        await supabase.from('user_energy').insert({
          'user_id': userId,
          'current_energy': kMaxEnergy,
          'last_regen_at': now.toIso8601String(),
        });
        return EnergyState(current: kMaxEnergy, lastRegenAt: now);
      }

      final raw = EnergyState(
        current: data['current_energy'] as int,
        lastRegenAt: DateTime.parse(data['last_regen_at'] as String),
      );
      return raw.withRegen();
    }

    Future<bool> consume() async {
      final current = state.valueOrNull;
      if (current == null || !current.canPlay) return false;

      final newState = EnergyState(
        current: current.current - 1,
        lastRegenAt: current.lastRegenAt,
      );
      state = AsyncData(newState);

      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        await supabase.from('user_energy').update({
          'current_energy': newState.current,
          'last_regen_at': newState.lastRegenAt.toIso8601String(),
        }).eq('user_id', userId);
      }
      return true;
    }
  }

  final energyProvider = AsyncNotifierProvider<EnergyNotifier, EnergyState>(
    EnergyNotifier.new,
  );
  ```

- [ ] **Step 3: Criar energy_bar.dart**

  Crie `futdle/lib/features/energy/widgets/energy_bar.dart`:

  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import '../providers/energy_provider.dart';
  import '../../../core/constants.dart';

  class EnergyBar extends ConsumerWidget {
    const EnergyBar({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final energyAsync = ref.watch(energyProvider);

      return energyAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
        data: (energy) => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(kMaxEnergy, (i) {
            return Icon(
              i < energy.current ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
              size: 20,
            );
          }),
        ),
      );
    }
  }
  ```

- [ ] **Step 4: Commit**

  ```bash
  git add futdle/lib/features/energy/
  git commit -m "feat: add energy system with Supabase persistence and regen logic"
  ```

---

## Task 14: Tela Home completa

**Files:**
- Modify: `futdle/lib/features/home/screens/home_screen.dart`

- [ ] **Step 1: Substituir home_screen.dart**

  Substitua `futdle/lib/features/home/screens/home_screen.dart` por:

  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:go_router/go_router.dart';
  import '../../energy/widgets/energy_bar.dart';
  import '../../energy/providers/energy_provider.dart';
  import '../../../core/theme.dart';

  class HomeScreen extends ConsumerWidget {
    const HomeScreen({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'FUTDLE',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
          centerTitle: true,
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: EnergyBar(),
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.sports_soccer, size: 80, color: kGreenLight),
                const SizedBox(height: 16),
                const Text(
                  'Adivinhe o time do dia',
                  style: TextStyle(fontSize: 18, color: kTextSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Desafio Diário
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/game?mode=daily'),
                    child: const Text('Desafio Diário'),
                  ),
                ),
                const SizedBox(height: 16),

                // Modo Livre
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      final energy = ref.read(energyProvider).valueOrNull;
                      if (energy == null || !energy.canPlay) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sem energia! Aguarde ou assista um anúncio.'),
                          ),
                        );
                        return;
                      }
                      await ref.read(energyProvider.notifier).consume();
                      if (context.mounted) context.go('/game?mode=free');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kTextPrimary,
                      side: const BorderSide(color: kGreen),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Modo Livre (-1 energia)'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
  ```

- [ ] **Step 2: Testar no emulador**

  ```bash
  flutter run
  ```

  Verificar:
  - Home exibe corações de energia no canto superior
  - "Desafio Diário" navega para o jogo
  - "Modo Livre" consome energia e navega para o jogo
  - Completar uma partida navega para a tela de resultado

- [ ] **Step 3: Commit**

  ```bash
  git add futdle/lib/features/home/
  git commit -m "feat: implement Home screen with energy display and mode selection"
  ```

---

## Task 15: Integrar AdMob (banner)

**Files:**
- Modify: `futdle/android/app/src/main/AndroidManifest.xml`
- Modify: `futdle/lib/features/home/screens/home_screen.dart`
- Create: `futdle/lib/features/ads/ad_banner.dart`

- [ ] **Step 1: Criar conta no Google AdMob**

  Acesse [admob.google.com](https://admob.google.com), faça login com sua conta Google, crie um app Android chamado "Futdle".
  Copie o **App ID** (formato: `ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX`).
  Crie um ad unit de tipo **Banner** e copie o **Ad Unit ID**.

  > Para testes sem conta AdMob real, use os IDs de teste do Google:
  > - App ID de teste: `ca-app-pub-3940256099942544~3347511713`
  > - Banner ID de teste: `ca-app-pub-3940256099942544/6300978111`

- [ ] **Step 2: Adicionar App ID no AndroidManifest.xml**

  Abra `futdle/android/app/src/main/AndroidManifest.xml` e adicione dentro de `<application>`:

  ```xml
  <meta-data
      android:name="com.google.android.gms.ads.APPLICATION_ID"
      android:value="ca-app-pub-3940256099942544~3347511713"/>
  ```

- [ ] **Step 3: Criar ad_banner.dart**

  Crie `futdle/lib/features/ads/ad_banner.dart`:

  ```dart
  import 'package:flutter/material.dart';
  import 'package:google_mobile_ads/google_mobile_ads.dart';

  // Troque pelo seu Ad Unit ID real antes de publicar
  const String _kBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';

  class AdBannerWidget extends StatefulWidget {
    const AdBannerWidget({super.key});

    @override
    State<AdBannerWidget> createState() => _AdBannerWidgetState();
  }

  class _AdBannerWidgetState extends State<AdBannerWidget> {
    BannerAd? _bannerAd;
    bool _isLoaded = false;

    @override
    void initState() {
      super.initState();
      _loadAd();
    }

    void _loadAd() {
      _bannerAd = BannerAd(
        adUnitId: _kBannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (_) => setState(() => _isLoaded = true),
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            _bannerAd = null;
          },
        ),
      )..load();
    }

    @override
    void dispose() {
      _bannerAd?.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      if (!_isLoaded || _bannerAd == null) return const SizedBox.shrink();
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
  }
  ```

- [ ] **Step 4: Inicializar AdMob no main.dart**

  No `futdle/lib/main.dart`, adicione antes de `runApp`:

  ```dart
  import 'package:google_mobile_ads/google_mobile_ads.dart';
  // ... (imports existentes)

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await MobileAds.instance.initialize();  // <- adicionar esta linha
    await Supabase.initialize(/* ... */);
    // ...
  }
  ```

- [ ] **Step 5: Adicionar banner na HomeScreen**

  No `home_screen.dart`, envolva o `Scaffold` com um `Column` que inclua o banner no rodapé:

  ```dart
  // Substituir o return Scaffold(...) por:
  return Scaffold(
    // ... igual ao anterior
    bottomNavigationBar: const AdBannerWidget(),
  );
  ```

- [ ] **Step 6: Build final de release**

  ```bash
  flutter build apk --release
  ```

  Esperado: `✓ Built build\app\outputs\flutter-apk\app-release.apk`

- [ ] **Step 7: Commit final**

  ```bash
  git add futdle/
  git commit -m "feat: integrate AdMob banner — MVP complete"
  ```

---

## Resultado esperado ao final deste plano

- App Flutter Android funcional com:
  - Desafio diário carregado do Supabase
  - Busca de clubes com autocomplete
  - Grid de feedback com cores (verde/amarelo/vermelho) e setas
  - Tela de resultado com botão de compartilhamento
  - Sistema de energia persistido no Supabase
  - Banner AdMob na tela Home
- APK de release gerado e pronto para testes via cabo USB ou emulador
- Testes unitários passando para a lógica de feedback

**Próximos passos sugeridos:**
- Publicar na Google Play (conta de desenvolvedor: $25 taxa única)
- Adicionar rewarded ad para recarregar energia
- Implementar Modo Escudo (v2)
