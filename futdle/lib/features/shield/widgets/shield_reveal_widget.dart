import 'package:flutter/material.dart';
import '../providers/shield_game_provider.dart';

class ShieldRevealWidget extends StatelessWidget {
  final String shieldUrl;
  final Set<int> revealedCells;
  final double width;
  final double height;

  const ShieldRevealWidget({
    super.key,
    required this.shieldUrl,
    required this.revealedCells,
    this.width = 220,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Camada 1 (baixo): escudo COLORIDO — sempre visível por inteiro
          _ShieldImage(shieldUrl: shieldUrl, width: width, height: height),

          // Camada 2 (cima): silhueta PRETA clipeada apenas nas células NÃO reveladas.
          // Conforme células são reveladas o preto some → colorido aparece.
          // O ColorFiltered preserva a transparência do PNG →
          // o preto só existe dentro do shape real do escudo.
          ClipPath(
            clipper: _UnrevealedCellsClipper(
              revealedCells: revealedCells,
              cols: kGridCols,
              rows: kGridRows,
            ),
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                0, 0, 0, 0, 0, // R = 0
                0, 0, 0, 0, 0, // G = 0
                0, 0, 0, 0, 0, // B = 0
                0, 0, 0, 1, 0, // A = alpha original
              ]),
              child: _ShieldImage(shieldUrl: shieldUrl, width: width, height: height),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Imagem do escudo ──────────────────────────────────────────────────────────

class _ShieldImage extends StatelessWidget {
  final String shieldUrl;
  final double width;
  final double height;

  const _ShieldImage({
    required this.shieldUrl,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      shieldUrl,
      width: width,
      height: height,
      fit: BoxFit.contain,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: CircularProgressIndicator(color: Colors.black26),
        );
      },
      errorBuilder: (_, __, ___) => const Center(
        child: Icon(Icons.shield_outlined, size: 80, color: Colors.black26),
      ),
    );
  }
}

// ── Clipper: cobre apenas as células NÃO reveladas ───────────────────────────

class _UnrevealedCellsClipper extends CustomClipper<Path> {
  final Set<int> revealedCells;
  final int cols;
  final int rows;

  const _UnrevealedCellsClipper({
    required this.revealedCells,
    required this.cols,
    required this.rows,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final cellW = size.width / cols;
    final cellH = size.height / rows;
    const gap = 0.0; // sem gap — sem vazamento de cor entre células

    for (int i = 0; i < cols * rows; i++) {
      if (revealedCells.contains(i)) continue; // revelada → sem preto
      final row = i ~/ cols;
      final col = i % cols;
      path.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(
          col * cellW + gap / 2,
          row * cellH + gap / 2,
          cellW - gap,
          cellH - gap,
        ),
        const Radius.circular(2),
      ));
    }
    return path;
  }

  @override
  bool shouldReclip(_UnrevealedCellsClipper old) =>
      old.revealedCells != revealedCells;
}
