import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../game/models/club.dart';

const int kGridCols = 6;           // colunas
const int kGridRows = 16;          // linhas — 6×16 = 96 células
const int kTotalCells = kGridCols * kGridRows;
const int kCellsPerWrongGuess = 2; // 2 células reveladas por erro
const int kMaxWrongGuesses = 20;   // máx erros antes do game over

// ── Células válidas ──────────────────────────────────────────────────────────

Set<int> _allCells() => Set.from(List.generate(kTotalCells, (i) => i));

/// Carrega o PNG do escudo e retorna os índices das células da grade que
/// possuem ao menos um pixel opaco (alpha > 20).
/// Isso garante que só revelamos células visualmente dentro do escudo.
/// Em caso de erro (timeout, SVG, rede, etc.) retorna todas as células.
Future<Set<int>> _analyzeShieldCells(String url) async {
  try {
    final completer = Completer<ui.Image>();
    final stream = NetworkImage(url).resolve(const ImageConfiguration());
    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (ImageInfo info, bool _) {
        stream.removeListener(listener);
        if (!completer.isCompleted) completer.complete(info.image);
      },
      onError: (Object error, StackTrace? _) {
        stream.removeListener(listener);
        if (!completer.isCompleted) completer.completeError(error);
      },
    );
    stream.addListener(listener);

    final image =
        await completer.future.timeout(const Duration(seconds: 15));
    final byteData =
        await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return _allCells();

    final bytes = byteData.buffer.asUint8List();
    final imgW = image.width;
    final imgH = image.height;
    final valid = <int>{};

    for (int idx = 0; idx < kTotalCells; idx++) {
      final row = idx ~/ kGridCols;
      final col = idx % kGridCols;
      final x0 = (col * imgW / kGridCols).floor();
      final y0 = (row * imgH / kGridRows).floor();
      final x1 = ((col + 1) * imgW / kGridCols).ceil().clamp(0, imgW);
      final y1 = ((row + 1) * imgH / kGridRows).ceil().clamp(0, imgH);

      bool found = false;
      for (int y = y0; y < y1 && !found; y++) {
        for (int x = x0; x < x1 && !found; x++) {
          final alphaIdx = (y * imgW + x) * 4 + 3;
          if (alphaIdx < bytes.length && bytes[alphaIdx] > 20) {
            valid.add(idx);
            found = true;
          }
        }
      }
    }

    return valid.isEmpty ? _allCells() : valid;
  } catch (_) {
    // Falha silenciosa — usa todas as células como fallback
    return _allCells();
  }
}

// ── Estado ───────────────────────────────────────────────────────────────────

class ShieldGameState {
  final List<String> wrongGuesses;   // nomes dos times errados
  final Set<int> revealedCells;      // índices das células reveladas (0–95)
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

// ── Notifier ─────────────────────────────────────────────────────────────────

class ShieldGameNotifier extends StateNotifier<ShieldGameState> {
  final Club target;
  final _random = Random();

  /// Células dentro do shape do escudo — populado assincronamente.
  /// Enquanto a análise não termina, usa todas as células como fallback.
  Set<int> _validCells = _allCells();

  ShieldGameNotifier(this.target) : super(const ShieldGameState()) {
    _initValidCells();
  }

  Future<void> _initValidCells() async {
    final url = target.shieldUrl;
    if (url == null || url.isEmpty) return;
    final valid = await _analyzeShieldCells(url);
    _validCells = valid;
  }

  void makeGuess(String clubName) {
    if (!state.canGuess) return;

    final now = DateTime.now();
    final startedAt = state.startedAt ?? now;

    final isCorrect =
        clubName.trim().toLowerCase() == target.name.toLowerCase() ||
            (target.altName != null &&
                clubName.trim().toLowerCase() ==
                    target.altName!.toLowerCase());

    if (isCorrect) {
      final elapsed = now.difference(startedAt).inSeconds;
      // Revela todas as células ao acertar
      state = state.copyWith(
        solved: true,
        gameOver: true,
        startedAt: startedAt,
        elapsedSeconds: elapsed,
        revealedCells: Set.from(List.generate(kTotalCells, (i) => i)),
      );
      return;
    }

    // Resposta errada — revela células aleatórias dentre as válidas ainda cobertas
    final newWrong = [...state.wrongGuesses, clubName];
    final newRevealed = Set<int>.from(state.revealedCells);

    final covered = _validCells
        .where((i) => !newRevealed.contains(i))
        .toList()
      ..shuffle(_random);

    for (int i = 0; i < kCellsPerWrongGuess && i < covered.length; i++) {
      newRevealed.add(covered[i]);
    }

    final isOver = newWrong.length >= kMaxWrongGuesses;
    if (isOver) {
      // Revela tudo no game over
      newRevealed.addAll(List.generate(kTotalCells, (i) => i));
    }

    state = state.copyWith(
      wrongGuesses: newWrong,
      revealedCells: newRevealed,
      gameOver: isOver,
      startedAt: startedAt,
    );
  }
}

// ── Provider ─────────────────────────────────────────────────────────────────

final shieldGameProvider =
    StateNotifierProvider.family<ShieldGameNotifier, ShieldGameState, Club>(
  (ref, target) => ShieldGameNotifier(target),
);
