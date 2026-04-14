import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/club.dart';
import '../providers/daily_challenge_provider.dart';
import '../providers/clubs_provider.dart';
import '../providers/game_provider.dart';
import '../services/progress_service.dart';
import '../widgets/attempt_row.dart';
import '../widgets/club_search_field.dart';
import '../widgets/tutorial_overlay.dart';
import '../widgets/powerup_bar.dart';
import '../widgets/revealed_attribute_row.dart';
import '../../../core/theme.dart';

// ── IDs de anúncio ──────────────────────────────────────────────────────────
// Troque pelo ID real antes de publicar:
// https://apps.admob.com → Seu app → Blocos de anúncios → Intersticial
const _kInterstitialAdId = 'ca-app-pub-5458992347294296/6748400461';
// ─────────────────────────────────────────────────────────────────────────────

class GameScreen extends ConsumerWidget {
  final String mode;
  const GameScreen({super.key, required this.mode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (mode == 'free') {
      final clubAsync = ref.watch(randomClubProvider);
      return clubAsync.when(
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, _) => Scaffold(body: Center(child: Text('Erro: $e'))),
        data: (club) => _GameView(target: club, mode: mode),
      );
    }

    final challengeAsync = ref.watch(dailyChallengeProvider);
    return challengeAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Erro: $e'))),
      data: (challenge) => _GameView(
        target: challenge.club,
        mode: mode,
        challengeId: challenge.id,
      ),
    );
  }
}

class _GameView extends ConsumerStatefulWidget {
  final Club target;
  final String mode;
  final String? challengeId;

  const _GameView({
    required this.target,
    required this.mode,
    this.challengeId,
  });

  @override
  ConsumerState<_GameView> createState() => _GameViewState();
}

class _GameViewState extends ConsumerState<_GameView> {
  InterstitialAd? _interstitialAd;
  bool _adReady = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Pré-carrega o intersticial apenas no desafio diário
    if (widget.mode == 'daily') {
      _loadAd();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final show = await shouldShowTutorial();
      if (show && mounted) {
        await showTutorialOverlay(context);
      }
    });
  }

  void _loadAd() {
    InterstitialAd.load(
      adUnitId: _kInterstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _adReady = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _adReady = false;
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              _adReady = false;
            },
          );
        },
        onAdFailedToLoad: (error) {
          _adReady = false;
        },
      ),
    );
  }

  /// Exibe o anúncio (se carregado) e navega para o resultado em seguida
  Future<void> _showAdThenNavigate(Map<String, dynamic> resultExtra) async {
    if (_adReady && _interstitialAd != null) {
      // Sobrescreve o callback de dismiss para navegar após fechar
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          if (context.mounted) context.pushReplacement('/result', extra: resultExtra);
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          if (context.mounted) context.pushReplacement('/result', extra: resultExtra);
        },
      );
      await _interstitialAd!.show();
    } else {
      // Anúncio não carregou — navega direto
      if (context.mounted) context.pushReplacement('/result', extra: resultExtra);
    }
  }

  void _confirmGiveUp(BuildContext context, GameState gameState, GameNotifier notifier) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text('Desistir?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Você será levado ao resultado sem acertar.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(context);
              final elapsed = gameState.startedAt != null
                  ? DateTime.now().difference(gameState.startedAt!).inSeconds
                  : 0;
              context.pushReplacement('/result', extra: {
                'solved': false,
                'attempts': gameState.attempts.length,
                'attempts_list': gameState.attempts,
                'clubName': widget.target.name,
                'mode': widget.mode,
                'challengeId': widget.challengeId,
                'timeSeconds': elapsed,
              });
            },
            child: const Text('Desistir'),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider(widget.target));
    final notifier = ref.read(gameProvider(widget.target).notifier);

    ref.listen(gameProvider(widget.target), (prev, next) {
      // Rola para baixo sempre que uma nova tentativa é adicionada
      if (next.attempts.length != (prev?.attempts.length ?? 0)) {
        _scrollToBottom();
      }

      if (next.gameOver && !(prev?.gameOver ?? false)) {
        // Salva progresso no desafio diário
        if (widget.mode == 'daily' && widget.challengeId != null) {
          ProgressService.saveResult(
            challengeId: widget.challengeId!,
            solved: next.solved,
            attemptsCount: next.attempts.length,
            timeSeconds: next.elapsedSeconds,
          );
        }

        final resultExtra = {
          'solved': next.solved,
          'attempts': next.attempts.length,
          'attempts_list': next.attempts,
          'clubName': widget.target.name,
          'mode': widget.mode,
          'challengeId': widget.challengeId,
          'timeSeconds': next.elapsedSeconds,
        };

        // Mostra anúncio somente ao acertar o desafio diário
        final showAd = widget.mode == 'daily' && next.solved;

        Future.delayed(const Duration(milliseconds: 600), () {
          if (!context.mounted) return;
          if (showAd) {
            _showAdThenNavigate(resultExtra);
          } else {
            context.pushReplacement('/result', extra: resultExtra);
          }
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('FUTDLE',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 3)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
        actions: widget.mode == 'free'
            ? [
                TextButton(
                  onPressed: () => _confirmGiveUp(context, gameState, notifier),
                  child: const Text('Desistir',
                      style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                controller: _scrollController,
                children: [
                  if (gameState.revealedAttributes.isNotEmpty)
                    RevealedAttributeRow(
                      target: widget.target,
                      revealedIndices: gameState.revealedAttributes,
                    ),
                  ...gameState.attempts.map((r) => AttemptRow(result: r)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (!gameState.gameOver) ...[
              PowerupBar(target: widget.target),
              const SizedBox(height: 8),
              ClubSearchField(
                  onClubSelected: (club) => notifier.makeAttempt(club)),
            ],
            if (gameState.gameOver)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  gameState.solved ? 'Parabéns!' : 'Fim de jogo',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }
}
