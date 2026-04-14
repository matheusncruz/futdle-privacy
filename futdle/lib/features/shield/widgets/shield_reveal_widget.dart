import 'package:flutter/material.dart';
import '../providers/shield_game_provider.dart';

class ShieldRevealWidget extends StatelessWidget {
  final String shieldUrl;
  final Set<int> revealedCells;
  final double size;

  const ShieldRevealWidget({
    super.key,
    required this.shieldUrl,
    required this.revealedCells,
    this.size = 280,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Escudo por baixo
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              shieldUrl,
              width: size,
              height: size,
              fit: BoxFit.contain,
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.sports_soccer, size: 80, color: Colors.white30),
              ),
            ),
          ),

          // Grid preto por cima — células reveladas ficam transparentes
          CustomPaint(
            size: Size(size, size),
            painter: _ShieldGridPainter(
              revealedCells: revealedCells,
              gridSize: kGridSize,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShieldGridPainter extends CustomPainter {
  final Set<int> revealedCells;
  final int gridSize;

  const _ShieldGridPainter({
    required this.revealedCells,
    required this.gridSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / gridSize;
    final cellH = size.height / gridSize;
    final paint = Paint()..color = const Color(0xFF0d1f12); // fundo escuro do app

    for (int i = 0; i < gridSize * gridSize; i++) {
      if (revealedCells.contains(i)) continue; // célula revelada = pula

      final row = i ~/ gridSize;
      final col = i % gridSize;
      final rect = Rect.fromLTWH(
        col * cellW,
        row * cellH,
        cellW - 1, // 1px de gap entre células
        cellH - 1,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ShieldGridPainter old) =>
      old.revealedCells != revealedCells;
}
