import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/club.dart';
import '../providers/game_provider.dart' show GameState, gameProvider;
import '../providers/powerups_provider.dart';
import '../services/hint_service.dart';
import '../../../core/theme.dart';

// ID do anúncio premiado (teste — troque pelo real antes de publicar)
const _kRewardedAdId = 'ca-app-pub-3940256099942544/5224354917';

class PowerupBar extends ConsumerStatefulWidget {
  final Club target;

  const PowerupBar({super.key, required this.target});

  @override
  ConsumerState<PowerupBar> createState() => _PowerupBarState();
}

class _PowerupBarState extends ConsumerState<PowerupBar> {
  RewardedAd? _rewardedAd;
  bool _adLoading = false;
  _PowerupType? _pendingReward; // qual powerup vai ganhar ao fechar o ad

  @override
  void initState() {
    super.initState();
    _loadRewardedAd();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _kRewardedAdId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (_) {
              _rewardedAd?.dispose();
              _rewardedAd = null;
              _loadRewardedAd(); // pré-carrega o próximo
            },
            onAdFailedToShowFullScreenContent: (_, __) {
              _rewardedAd?.dispose();
              _rewardedAd = null;
              _loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (_) => _rewardedAd = null,
      ),
    );
  }

  Future<void> _showRewardedAd(_PowerupType type) async {
    if (_rewardedAd == null) {
      _showSnack('Anúncio ainda carregando. Tente em instantes.');
      return;
    }
    _pendingReward = type;
    await _rewardedAd!.show(
      onUserEarnedReward: (_, __) async {
        // Concede +2 usos do powerup selecionado
        if (_pendingReward == _PowerupType.hint) {
          await ref.read(powerupsProvider.notifier).rewardHint();
        } else {
          await ref.read(powerupsProvider.notifier).rewardReveal();
        }
        if (mounted) _showSnack('+2 usos adicionados!');
      },
    );
  }

  void _onHintPressed() async {
    final powers = ref.read(powerupsProvider).valueOrNull;
    if (powers == null) return;

    if (powers.hintUses <= 0) {
      _showRefillDialog(_PowerupType.hint);
      return;
    }

    final gameState = ref.read(gameProvider(widget.target));
    final hints = HintService.generateHints(widget.target);
    final hint = hints[gameState.nextHintIndex % hints.length];

    final consumed = await ref.read(powerupsProvider.notifier).useHint();
    if (consumed) {
      ref.read(gameProvider(widget.target).notifier).showHint(hint);
    }
  }

  void _onRevealPressed() async {
    final powers = ref.read(powerupsProvider).valueOrNull;
    if (powers == null) return;

    if (powers.revealUses <= 0) {
      _showRefillDialog(_PowerupType.reveal);
      return;
    }

    final consumed = await ref.read(powerupsProvider.notifier).useReveal();
    if (consumed) {
      final idx = ref.read(gameProvider(widget.target).notifier).revealAttribute();
      if (idx == -1 && mounted) {
        _showSnack('Todos os atributos já foram revelados!');
      }
    }
  }

  void _showRefillDialog(_PowerupType type) {
    final label = type == _PowerupType.hint ? 'dicas' : 'revelações';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: Text(
          'Sem $label',
          style: const TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Assista um anúncio para ganhar +2 $label.',
          style: const TextStyle(color: kTextSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: kTextSecondary)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showRewardedAd(type);
            },
            icon: const Icon(Icons.play_circle_outline, size: 18),
            label: const Text('Assistir (+2)'),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final powersAsync = ref.watch(powerupsProvider);
    final gameState = ref.watch(gameProvider(widget.target));

    if (gameState.gameOver) return const SizedBox.shrink();

    final powers = powersAsync.valueOrNull ??
        const PowerupsState(hintUses: 3, revealUses: 3);

    if (powersAsync.isLoading) return const SizedBox.shrink();

    return powersAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => _buildButtons(powers, gameState),
      data: (powers) => _buildButtons(powers, gameState),
    );
  }

  Widget _buildButtons(PowerupsState powers, GameState gameState) {
    return Column(
      children: [
        // Dica exibida
        if (gameState.currentHint != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: kYellow.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kYellow.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb, color: kYellow, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    gameState.currentHint!,
                    style: const TextStyle(color: kYellow, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

        // Botões
        Row(
          children: [
            Expanded(
              child: _PowerupButton(
                icon: Icons.lightbulb_outline,
                label: 'Dica',
                uses: powers.hintUses,
                color: kYellow,
                onPressed: _onHintPressed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PowerupButton(
                icon: Icons.visibility_outlined,
                label: 'Revelar',
                uses: powers.revealUses,
                color: const Color(0xFF60A5FA),
                onPressed: _onRevealPressed,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

enum _PowerupType { hint, reveal }

class _PowerupButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int uses;
  final Color color;
  final VoidCallback onPressed;

  const _PowerupButton({
    required this.icon,
    required this.label,
    required this.uses,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final empty = uses <= 0;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: empty ? const Color(0xFF1F2937) : color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: empty ? Colors.white12 : color.withOpacity(0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: empty ? kTextSecondary : color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: empty ? kTextSecondary : color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: empty ? Colors.white10 : color.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                empty ? '+' : '$uses',
                style: TextStyle(
                  color: empty ? kTextSecondary : color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
