import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../game/models/club.dart';
import '../../game/providers/daily_challenge_provider.dart';
import '../../game/widgets/club_search_field.dart';
import '../providers/shield_game_provider.dart';
import '../widgets/shield_reveal_widget.dart';

// Tela de carregamento do desafio
class ShieldGameScreen extends ConsumerWidget {
  const ShieldGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengeAsync = ref.watch(dailyChallengeProvider);

    return challengeAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Erro: $e')),
      ),
      data: (challenge) {
        if (challenge.club.shieldUrl == null || challenge.club.shieldUrl!.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('FUTDLE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 3)),
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
        return _ShieldGameView(club: challenge.club);
      },
    );
  }
}

class _ShieldGameView extends ConsumerWidget {
  final Club club;
  const _ShieldGameView({required this.club});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shieldGameProvider(club));
    final notifier = ref.read(shieldGameProvider(club).notifier);

    // Navega para resultado quando acabar
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
          });
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('FUTDLE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 3)),
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Instrução
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
              const SizedBox(height: 20),

              // Escudo com revelação
              ShieldRevealWidget(
                shieldUrl: club.shieldUrl!,
                revealedCells: state.revealedCells,
                size: 280,
              ),
              const SizedBox(height: 20),

              // Barra de progresso de revelação
              _RevealProgressBar(
                revealed: state.revealedCells.length,
                total: kGridSize * kGridSize,
              ),
              const SizedBox(height: 20),

              // Lista de erros
              if (state.wrongGuesses.isNotEmpty)
                _WrongGuessesList(guesses: state.wrongGuesses),

              const Spacer(),

              // Campo de busca
              if (state.canGuess)
                ClubSearchField(
                  onClubSelected: (c) => notifier.makeGuess(c.name),
                ),
            ],
          ),
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
                style: const TextStyle(color: kGreenLight, fontSize: 11, fontWeight: FontWeight.bold)),
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
        children: guesses.map((g) => Chip(
          label: Text(g, style: const TextStyle(fontSize: 11, color: Colors.white70)),
          backgroundColor: const Color(0xFF374151),
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: const BorderSide(color: Colors.transparent),
        )).toList(),
      ),
    );
  }
}
