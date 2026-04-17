import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../game/models/club.dart';
import '../../game/widgets/club_search_field.dart';
import '../providers/shield_game_provider.dart';
import '../providers/shield_daily_challenge_provider.dart';
import '../providers/shield_free_club_provider.dart';
import '../widgets/shield_reveal_widget.dart';

class ShieldGameScreen extends ConsumerWidget {
  final String mode; // 'daily' ou 'free'
  const ShieldGameScreen({super.key, this.mode = 'daily'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengeAsync = mode == 'free'
        ? ref.watch(shieldFreeClubProvider)
        : ref.watch(shieldDailyChallengeProvider).whenData((c) => c.club);

    return challengeAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(child: Text('Erro: $e')),
      ),
      data: (club) {
        if (club.shieldUrl == null || club.shieldUrl!.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('FUTDLE',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 3)),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => context.pop(),
              ),
            ),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Escudo não disponível para o time de hoje.\nTente amanhã!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kTextSecondary, fontSize: 16),
                ),
              ),
            ),
          );
        }
        return _ShieldGameView(club: club, mode: mode);
      },
    );
  }
}

class _ShieldGameView extends ConsumerWidget {
  final Club club;
  final String mode;
  const _ShieldGameView({required this.club, required this.mode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shieldGameProvider(club));
    final notifier = ref.read(shieldGameProvider(club).notifier);

    ref.listen(shieldGameProvider(club), (prev, next) {
      if (next.gameOver && !(prev?.gameOver ?? false)) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (!context.mounted) return;
          context.pushReplacement('/shield-result', extra: {
            'solved': next.solved,
            'wrongCount': next.wrongCount,
            'clubName': club.name,
            'shieldUrl': club.shieldUrl ?? '',
            'timeSeconds': next.elapsedSeconds,
            'mode': mode,
          });
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${state.wrongCount}/${kMaxWrongGuesses}',
                style: TextStyle(
                  color: state.wrongCount >= 6 ? kRed : kTextSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Conteúdo rolável (escudo + progresso + erros)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  children: [
                    Text(
                      state.canGuess
                          ? 'De qual time é esse escudo?'
                          : state.solved
                              ? '🎉 Você acertou!'
                              : '😢 Era ${club.name}',
                      style: TextStyle(
                        fontSize: 16,
                        color: state.solved ? kGreenLight : kTextSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ShieldRevealWidget(
                      shieldUrl: club.shieldUrl!,
                      revealedCells: state.revealedCells,
                      width: 220,
                      height: 300,
                    ),
                    const SizedBox(height: 16),

                    _RevealProgressBar(
                      revealed: state.revealedCells.length,
                      total: kTotalCells,
                    ),
                    const SizedBox(height: 12),

                    if (state.wrongGuesses.isNotEmpty)
                      _WrongGuessesList(guesses: state.wrongGuesses),
                  ],
                ),
              ),
            ),

            // Campo de busca fixo no rodapé — não sobe com o teclado
            if (state.canGuess)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: ClubSearchField(
                  onClubSelected: (c) => notifier.makeGuess(c.name),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RevealProgressBar extends StatelessWidget {
  final int revealed;
  final int total;
  const _RevealProgressBar({required this.revealed, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = revealed / total;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Revelado', style: TextStyle(color: kTextSecondary, fontSize: 11)),
            Text('${(pct * 100).round()}%',
                style: const TextStyle(
                    color: kGreenLight, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: const Color(0xFF1F2937),
            color: pct > 0.6 ? kRed : pct > 0.3 ? kYellow : kGreenLight,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _WrongGuessesList extends StatelessWidget {
  final List<String> guesses;
  const _WrongGuessesList({required this.guesses});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: guesses
            .map((g) => Chip(
                  label: Text(g,
                      style: const TextStyle(fontSize: 11, color: Colors.white70)),
                  backgroundColor: const Color(0xFF374151),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: const BorderSide(color: Colors.transparent),
                ))
            .toList(),
      ),
    );
  }
}
