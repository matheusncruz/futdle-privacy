import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/club.dart';
import '../models/attempt_result.dart';
import '../services/game_service.dart';

class GameState {
  final List<AttemptResult> attempts;
  final bool solved;
  final bool gameOver;
  final DateTime? startedAt;
  final int elapsedSeconds;
  /// Índices dos atributos revelados pelo powerup (0–7)
  final List<int> revealedAttributes;
  /// Índice da próxima dica a ser exibida
  final int nextHintIndex;
  /// Última dica exibida (null = nenhuma ainda)
  final String? currentHint;

  const GameState({
    this.attempts = const [],
    this.solved = false,
    this.gameOver = false,
    this.startedAt,
    this.elapsedSeconds = 0,
    this.revealedAttributes = const [],
    this.nextHintIndex = 0,
    this.currentHint,
  });

  GameState copyWith({
    List<AttemptResult>? attempts,
    bool? solved,
    bool? gameOver,
    DateTime? startedAt,
    int? elapsedSeconds,
    List<int>? revealedAttributes,
    int? nextHintIndex,
    String? currentHint,
  }) {
    return GameState(
      attempts: attempts ?? this.attempts,
      solved: solved ?? this.solved,
      gameOver: gameOver ?? this.gameOver,
      startedAt: startedAt ?? this.startedAt,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      revealedAttributes: revealedAttributes ?? this.revealedAttributes,
      nextHintIndex: nextHintIndex ?? this.nextHintIndex,
      currentHint: currentHint ?? this.currentHint,
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  final Club target;
  GameNotifier(this.target) : super(const GameState());

  void makeAttempt(Club attempt) {
    if (state.solved || state.gameOver) return;

    final now = DateTime.now();
    final startedAt = state.startedAt ?? now;

    final result = evaluateAttempt(attempt, target);
    final newAttempts = [...state.attempts, result];

    final isOver = result.isCorrect;
    final elapsed = isOver ? now.difference(startedAt).inSeconds : 0;

    state = state.copyWith(
      attempts: newAttempts,
      solved: result.isCorrect,
      gameOver: isOver,
      startedAt: startedAt,
      elapsedSeconds: elapsed,
    );
  }

  /// Exibe a próxima dica sequencial
  void showHint(String hint) {
    state = state.copyWith(
      currentHint: hint,
      nextHintIndex: state.nextHintIndex + 1,
    );
  }

  /// Revela um atributo aleatório ainda não revelado
  /// Retorna o índice revelado, ou -1 se todos já foram revelados
  int revealAttribute() {
    const total = 8;
    final unrevealed = List.generate(total, (i) => i)
        .where((i) => !state.revealedAttributes.contains(i))
        .toList();

    if (unrevealed.isEmpty) return -1;

    unrevealed.shuffle();
    final idx = unrevealed.first;

    state = state.copyWith(
      revealedAttributes: [...state.revealedAttributes, idx],
    );

    return idx;
  }

  void reset() => state = const GameState();
}

final gameProvider = StateNotifierProvider.family<GameNotifier, GameState, Club>(
  (ref, target) => GameNotifier(target),
);
