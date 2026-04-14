import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../game/models/club.dart';

const int kGridSize = 8;           // 8x8 = 64 células
const int kCellsPerWrongGuess = 5; // células reveladas por erro
const int kMaxWrongGuesses = 8;    // máx erros antes do game over

class ShieldGameState {
  final List<String> wrongGuesses;   // nomes dos times errados
  final Set<int> revealedCells;      // índices das células reveladas (0–63)
  final bool solved;
  final bool gameOver;
  final DateTime? startedAt;
  final int elapsedSeconds;

  const ShieldGameState({
    this.wrongGuesses = const [],
    this.revealedCells = const {},
    this.solved = false,
    this.gameOver = false,
    this.startedAt,
    this.elapsedSeconds = 0,
  });

  int get wrongCount => wrongGuesses.length;
  bool get canGuess => !solved && !gameOver;

  ShieldGameState copyWith({
    List<String>? wrongGuesses,
    Set<int>? revealedCells,
    bool? solved,
    bool? gameOver,
    DateTime? startedAt,
    int? elapsedSeconds,
  }) {
    return ShieldGameState(
      wrongGuesses: wrongGuesses ?? this.wrongGuesses,
      revealedCells: revealedCells ?? this.revealedCells,
      solved: solved ?? this.solved,
      gameOver: gameOver ?? this.gameOver,
      startedAt: startedAt ?? this.startedAt,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }
}

class ShieldGameNotifier extends StateNotifier<ShieldGameState> {
  final Club target;
  final _random = Random();

  ShieldGameNotifier(this.target) : super(const ShieldGameState());

  void makeGuess(String clubName) {
    if (!state.canGuess) return;

    final now = DateTime.now();
    final startedAt = state.startedAt ?? now;

    final isCorrect = clubName.trim().toLowerCase() == target.name.toLowerCase() ||
        (target.altName != null &&
            clubName.trim().toLowerCase() == target.altName!.toLowerCase());

    if (isCorrect) {
      final elapsed = now.difference(startedAt).inSeconds;
      // Revela todas as células ao acertar
      state = state.copyWith(
        solved: true,
        gameOver: true,
        startedAt: startedAt,
        elapsedSeconds: elapsed,
        revealedCells: Set.generate(kGridSize * kGridSize, (i) => i),
      );
      return;
    }

    // Resposta errada — revela N células aleatórias ainda cobertas
    final newWrong = [...state.wrongGuesses, clubName];
    final newRevealed = Set<int>.from(state.revealedCells);
    final covered = List.generate(kGridSize * kGridSize, (i) => i)
        .where((i) => !newRevealed.contains(i))
        .toList()
      ..shuffle(_random);

    for (int i = 0; i < kCellsPerWrongGuess && i < covered.length; i++) {
      newRevealed.add(covered[i]);
    }

    final isOver = newWrong.length >= kMaxWrongGuesses;
    if (isOver) {
      // Revela tudo no game over
      newRevealed.addAll(List.generate(kGridSize * kGridSize, (i) => i));
    }

    state = state.copyWith(
      wrongGuesses: newWrong,
      revealedCells: newRevealed,
      gameOver: isOver,
      startedAt: startedAt,
    );
  }
}

final shieldGameProvider =
    StateNotifierProvider.family<ShieldGameNotifier, ShieldGameState, Club>(
  (ref, target) => ShieldGameNotifier(target),
);
