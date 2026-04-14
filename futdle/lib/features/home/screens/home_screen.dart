import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../energy/widgets/energy_bar.dart';
import '../../energy/providers/energy_provider.dart';
import '../../game/providers/today_progress_provider.dart';
import '../../../core/theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _formattedDate() {
    final now = DateTime.now();
    final months = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
    ];
    return 'Desafio de ${now.day} de ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todayProgressProvider);

    return Scaffold(
      backgroundColor: kBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'FUTDLE',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 6,
            color: kTextPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          const Padding(padding: EdgeInsets.only(right: 8), child: EnergyBar()),
          IconButton(
            icon: const Icon(Icons.person_outline, color: kTextSecondary),
            onPressed: () => context.push('/profile'),
            tooltip: 'Meu perfil',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Hero section ──────────────────────────────────────────────
            _HeroSection(dateLabel: _formattedDate()),

            // ── Content ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: Column(
                children: [
                  // Daily challenge button / done card
                  todayAsync.when(
                    loading: () => const _LoadingButton(),
                    error: (_, __) => _DailyChallengeButton(
                      onTap: () => context.push('/game?mode=daily'),
                    ),
                    data: (today) {
                      if (today.played) {
                        return _DailyDoneCard(
                          solved: today.solved,
                          attempts: today.attempts,
                        );
                      }
                      return _DailyChallengeButton(
                        onTap: () => context.push('/game?mode=daily'),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Shield mode button
                  _ShieldModeButton(
                    onTap: () => context.push('/shield-game'),
                  ),
                  const SizedBox(height: 16),

                  // Free mode button
                  _FreeModeButton(
                    onTap: () async {
                      final energy = ref.read(energyProvider).valueOrNull;
                      if (energy == null || !energy.canPlay) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sem energia! Aguarde a recarga.'),
                          ),
                        );
                        return;
                      }
                      await ref.read(energyProvider.notifier).consume();
                      if (context.mounted) context.push('/game?mode=free');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero Section ────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final String dateLabel;
  const _HeroSection({required this.dateLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0d2718), kBackground],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            children: [
              // Glowing soccer ball
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: kGreenLight.withOpacity(0.35),
                          blurRadius: 48,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          kGreenLight.withOpacity(0.18),
                          Colors.transparent,
                        ],
                      ),
                      border: Border.all(
                        color: kGreenLight.withOpacity(0.25),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.sports_soccer,
                      size: 52,
                      color: kGreenLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // FUTDLE title with glow
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [kGreenLight, Color(0xFF86efac)],
                ).createShader(bounds),
                child: const Text(
                  'FUTDLE',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 10,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Color(0xFF22c55e),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Tagline
              Text(
                'O Wordle do Futebol',
                style: TextStyle(
                  fontSize: 15,
                  color: kTextSecondary,
                  letterSpacing: 2,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 14),

              // Date chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: kGreenLight.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: kGreenLight.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  dateLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: kGreenLight,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Decorative attribute preview row ────────────────────────────────────────

class _AttributePreviewRow extends StatelessWidget {
  const _AttributePreviewRow();

  static const _cells = [
    (color: Color(0xFF22c55e), label: '🟩'),
    (color: Color(0xFFEAB308), label: '🟨'),
    (color: Color(0xFFEF4444), label: '🟥'),
    (color: Color(0xFF22c55e), label: '🟩'),
    (color: Color(0xFFEF4444), label: '🟥'),
    (color: Color(0xFFEAB308), label: '🟨'),
    (color: Color(0xFF22c55e), label: '🟩'),
    (color: Color(0xFF22c55e), label: '🟩'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Como funciona',
          style: TextStyle(
            fontSize: 11,
            color: kTextSecondary,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _cells.map((c) {
            return Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: c.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: c.color.withOpacity(0.5), width: 1.2),
              ),
              child: Center(
                child: Text(c.label, style: const TextStyle(fontSize: 14)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          '🟩 Certo  🟨 Parcial  🟥 Errado',
          style: TextStyle(fontSize: 11, color: kTextSecondary),
        ),
      ],
    );
  }
}

// ── Loading button placeholder ───────────────────────────────────────────────

class _LoadingButton extends StatelessWidget {
  const _LoadingButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: kGreenLight),
        ),
      ),
    );
  }
}

// ── Daily challenge gradient button ─────────────────────────────────────────

class _DailyChallengeButton extends StatelessWidget {
  final VoidCallback onTap;
  const _DailyChallengeButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF16a34a), Color(0xFF22c55e)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: kGreenLight.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.sports_soccer, color: Colors.white, size: 22),
            SizedBox(width: 10),
            Text(
              'Desafio Diário',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shield mode button ───────────────────────────────────────────────────────

class _ShieldModeButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ShieldModeButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF60A5FA).withOpacity(0.5), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.shield_outlined, color: Color(0xFF60A5FA), size: 20),
            SizedBox(width: 10),
            Text(
              'Modo Escudo',
              style: TextStyle(
                color: kTextPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'diário',
              style: TextStyle(color: kTextSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Free mode outlined button ────────────────────────────────────────────────

class _FreeModeButton extends StatelessWidget {
  final VoidCallback onTap;
  const _FreeModeButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kGreenLight.withOpacity(0.45), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.shuffle, color: kGreenLight, size: 20),
            SizedBox(width: 10),
            Text(
              'Modo Livre',
              style: TextStyle(
                color: kTextPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8),
            Text(
              '−1 energia',
              style: TextStyle(
                color: kTextSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Daily done card ──────────────────────────────────────────────────────────

class _DailyDoneCard extends StatefulWidget {
  final bool solved;
  final int attempts;

  const _DailyDoneCard({required this.solved, required this.attempts});

  @override
  State<_DailyDoneCard> createState() => _DailyDoneCardState();
}

class _DailyDoneCardState extends State<_DailyDoneCard> {
  late Timer _timer;
  late Duration _timeLeft;

  @override
  void initState() {
    super.initState();
    _timeLeft = _calcTimeLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _timeLeft = _calcTimeLeft());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Duration _calcTimeLeft() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    return midnight.difference(now);
  }

  String _format(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.solved ? kGreenLight : kRed;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Colored top strip
            Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.solved
                      ? [const Color(0xFF16a34a), kGreenLight]
                      : [const Color(0xFFb91c1c), kRed],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.solved ? Icons.emoji_events : Icons.sports_soccer,
                          color: widget.solved ? kYellow : kTextSecondary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.solved ? 'Desafio concluído!' : 'Não foi dessa vez',
                              style: const TextStyle(
                                color: kTextPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.solved
                                  ? '${widget.attempts} ${widget.attempts == 1 ? 'tentativa' : 'tentativas'}'
                                  : 'Tente novamente amanhã',
                              style: const TextStyle(color: kTextSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: kBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.timer_outlined, size: 15, color: kTextSecondary),
                        const SizedBox(width: 6),
                        const Text(
                          'Próximo desafio em ',
                          style: TextStyle(color: kTextSecondary, fontSize: 13),
                        ),
                        Text(
                          _format(_timeLeft),
                          style: const TextStyle(
                            color: kTextPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
