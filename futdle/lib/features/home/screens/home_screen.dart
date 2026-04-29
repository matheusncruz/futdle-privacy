import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../energy/widgets/energy_bar.dart';
import '../../energy/providers/energy_provider.dart';
import '../../game/providers/today_progress_provider.dart';
import '../../game/providers/streak_provider.dart';
import '../../game/providers/clubs_provider.dart';
import '../../shield/providers/shield_free_club_provider.dart';
import '../../shield/providers/shield_today_progress_provider.dart';
import '../../../core/theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  bool _dailyExpanded = false;
  bool _freeExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(todayProgressProvider);
    }
  }

  void _toggleDaily() => setState(() {
        _dailyExpanded = !_dailyExpanded;
        if (_dailyExpanded) _freeExpanded = false;
      });

  void _toggleFree() => setState(() {
        _freeExpanded = !_freeExpanded;
        if (_freeExpanded) _dailyExpanded = false;
      });

  String _formattedDate() {
    final now = DateTime.now();
    final months = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
    ];
    return '${now.day} de ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final todayAsync = ref.watch(todayProgressProvider);
    final streakAsync = ref.watch(streakProvider);
    final currentStreak = streakAsync.valueOrNull?.current ?? 0;

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
            _HeroSection(dateLabel: _formattedDate(), streak: currentStreak),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: Column(
                children: [
                  // ── Desafios Diários ──────────────────────────────────────
                  _CategoryCard(
                    icon: Icons.calendar_today_rounded,
                    title: 'Desafios Diários',
                    subtitle: 'Um novo desafio todo dia',
                    accentColor: kGreenLight,
                    expanded: _dailyExpanded,
                    onTap: _toggleDaily,
                    children: [
                      // Modo Clássico diário
                      todayAsync.when(
                        loading: () => const _SubModeLoading(),
                        error: (_, __) => _SubModeButton(
                          icon: Icons.grid_view_rounded,
                          label: 'Modo Clássico',
                          description: 'Adivinhe pelas características',
                          color: kGreenLight,
                          onTap: () => context.push('/game?mode=daily'),
                        ),
                        data: (today) => today.played
                            ? _DailyDoneCard(
                                solved: today.solved,
                                attempts: today.attempts,
                              )
                            : _SubModeButton(
                                icon: Icons.grid_view_rounded,
                                label: 'Modo Clássico',
                                description: 'Adivinhe pelas características',
                                color: kGreenLight,
                                onTap: () async {
                                  await context.push('/game?mode=daily');
                                  ref.invalidate(todayProgressProvider);
                                },
                              ),
                      ),

                      const SizedBox(height: 10),

                      // Modo Escudo diário
                      ref.watch(shieldTodayProgressProvider).when(
                        loading: () => const _SubModeLoading(),
                        error: (_, __) => _SubModeButton(
                          icon: Icons.shield_outlined,
                          label: 'Modo Escudo',
                          description: 'Adivinhe pelo escudo do clube',
                          color: const Color(0xFF60A5FA),
                          onTap: () async {
                            await context.push('/shield-game?mode=daily');
                            ref.invalidate(shieldTodayProgressProvider);
                          },
                        ),
                        data: (shieldToday) => shieldToday.played
                            ? _ShieldDoneCard(
                                solved: shieldToday.solved,
                                wrongCount: shieldToday.wrongCount,
                              )
                            : _SubModeButton(
                                icon: Icons.shield_outlined,
                                label: 'Modo Escudo',
                                description: 'Adivinhe pelo escudo do clube',
                                color: const Color(0xFF60A5FA),
                                onTap: () async {
                                  await context.push('/shield-game?mode=daily');
                                  ref.invalidate(shieldTodayProgressProvider);
                                },
                              ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Modos Livres ──────────────────────────────────────────
                  _CategoryCard(
                    icon: Icons.shuffle_rounded,
                    title: 'Modos Livres',
                    subtitle: 'Jogue à vontade • −1 energia por partida',
                    accentColor: kYellow,
                    expanded: _freeExpanded,
                    onTap: _toggleFree,
                    children: [
                      // Modo Clássico livre
                      _SubModeButton(
                        icon: Icons.grid_view_rounded,
                        label: 'Modo Clássico',
                        description: 'Adivinhe pelas características',
                        color: kGreenLight,
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
                          // Invalida o cache para sortear um novo clube a cada partida
                          ref.invalidate(randomClubProvider);
                          if (context.mounted) context.push('/game?mode=free');
                        },
                      ),

                      const SizedBox(height: 10),

                      // Modo Escudo livre
                      _SubModeButton(
                        icon: Icons.shield_outlined,
                        label: 'Modo Escudo',
                        description: 'Adivinhe pelo escudo do clube',
                        color: const Color(0xFF60A5FA),
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
                          // Invalida o cache para sortear um novo clube a cada partida
                          ref.invalidate(shieldFreeClubProvider);
                          if (context.mounted) {
                            context.push('/shield-game?mode=free');
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Ligas ────────────────────────────────────────────────────────────
                  InkWell(
                    onTap: () => context.push('/leagues'),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      decoration: BoxDecoration(
                        color: kSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFFf59e0b).withOpacity(0.35)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFf59e0b).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.emoji_events_rounded,
                                color: Color(0xFFf59e0b), size: 22),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('🏆 Ligas',
                                    style: TextStyle(
                                        color: kTextPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 2),
                                Text('Ranking oficial e ligas de amigos',
                                    style: TextStyle(
                                        color: kTextSecondary, fontSize: 12)),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded,
                              color: Color(0xFFf59e0b), size: 14),
                        ],
                      ),
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

// ── Hero Section ────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final String dateLabel;
  final int streak;
  const _HeroSection({required this.dateLabel, this.streak = 0});

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
              // Bola com brilho
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
                      Shadow(color: Color(0xFF22c55e), blurRadius: 24),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),

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

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: kGreenLight.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kGreenLight.withOpacity(0.3)),
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
              if (streak > 0) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFf97316).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFf97316).withOpacity(0.35)),
                  ),
                  child: Text(
                    '🔥 $streak dia${streak == 1 ? '' : 's'} acertando',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFfb923c),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Category Card (expansível) ───────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final bool expanded;
  final VoidCallback onTap;
  final List<Widget> children;

  const _CategoryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.expanded,
    required this.onTap,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: expanded
              ? accentColor.withOpacity(0.45)
              : const Color(0xFF1F2937),
          width: 1.5,
        ),
        boxShadow: expanded
            ? [
                BoxShadow(
                  color: accentColor.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Column(
        children: [
          // Header (sempre visível)
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: accentColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: kTextPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: kTextSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: accentColor,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Conteúdo expansível
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(children: children),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-mode button ──────────────────────────────────────────────────────────

class _SubModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _SubModeButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kBackground,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: kTextPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      description,
                      style: const TextStyle(
                        color: kTextSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: color, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-mode loading ─────────────────────────────────────────────────────────

class _SubModeLoading extends StatelessWidget {
  const _SubModeLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: kBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: kGreenLight),
        ),
      ),
    );
  }
}

// ── Daily done card ──────────────────────────────────────────────────────────

// ── Shield daily done card ───────────────────────────────────────────────────

class _ShieldDoneCard extends StatelessWidget {
  final bool solved;
  final int wrongCount;
  const _ShieldDoneCard({required this.solved, required this.wrongCount});

  @override
  Widget build(BuildContext context) {
    final accent = solved ? const Color(0xFF60A5FA) : kRed;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withOpacity(0.35), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: solved
                      ? [const Color(0xFF1d4ed8), const Color(0xFF60A5FA)]
                      : [const Color(0xFFb91c1c), kRed],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Icon(
                    solved ? Icons.shield : Icons.shield_outlined,
                    color: solved ? const Color(0xFF60A5FA) : kTextSecondary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          solved ? 'Escudo acertado!' : 'Não foi dessa vez',
                          style: const TextStyle(
                            color: kTextPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          solved
                              ? '$wrongCount erro${wrongCount == 1 ? '' : 's'}'
                              : 'Tente novamente amanhã',
                          style: const TextStyle(color: kTextSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.lock_outline, color: kTextSecondary, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Classic daily done card ───────────────────────────────────────────────────

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
        color: kBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withOpacity(0.35), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.solved
                      ? [const Color(0xFF16a34a), kGreenLight]
                      : [const Color(0xFFb91c1c), kRed],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Icon(
                    widget.solved ? Icons.emoji_events : Icons.sports_soccer,
                    color: widget.solved ? kYellow : kTextSecondary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.solved ? 'Concluído!' : 'Não foi dessa vez',
                          style: const TextStyle(
                            color: kTextPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          widget.solved
                              ? '${widget.attempts} tentativa${widget.attempts == 1 ? '' : 's'}'
                              : 'Tente novamente amanhã',
                          style: const TextStyle(
                              color: kTextSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined,
                          size: 13, color: kTextSecondary),
                      const SizedBox(width: 4),
                      Text(
                        _format(_timeLeft),
                        style: const TextStyle(
                          color: kTextPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
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
