import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/energy_provider.dart';
import '../../../core/constants.dart';
import '../../../core/theme.dart';

// ID de teste — troque pelo real antes de publicar
const _kRewardedAdId = 'ca-app-pub-3940256099942544/5224354917';
const _kEnergyReward = 2;

class EnergyBar extends ConsumerStatefulWidget {
  const EnergyBar({super.key});

  @override
  ConsumerState<EnergyBar> createState() => _EnergyBarState();
}

class _EnergyBarState extends ConsumerState<EnergyBar> {
  Timer? _ticker;
  RewardedAd? _rewardedAd;
  bool _adLoading = false;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      // Dispara regen quando o countdown chega a zero
      final energy = ref.read(energyProvider).valueOrNull;
      if (energy != null && !energy.isFull && energy.nextRegenIn <= Duration.zero) {
        ref.read(energyProvider.notifier).triggerRegen();
      }
      setState(() {});
    });
    _loadAd();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _rewardedAd?.dispose();
    super.dispose();
  }

  void _loadAd() {
    RewardedAd.load(
      adUnitId: _kRewardedAdId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          if (!mounted) return;
          _rewardedAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (_) {
              _rewardedAd?.dispose();
              _rewardedAd = null;
              _loadAd();
            },
            onAdFailedToShowFullScreenContent: (_, __) {
              _rewardedAd?.dispose();
              _rewardedAd = null;
              _loadAd();
            },
          );
        },
        onAdFailedToLoad: (_) {
          if (mounted) setState(() => _adLoading = false);
        },
      ),
    );
  }

  Future<void> _showAd() async {
    if (_rewardedAd == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anúncio ainda carregando. Tente em instantes.')),
        );
      }
      return;
    }
    setState(() => _adLoading = true);
    await _rewardedAd!.show(
      onUserEarnedReward: (_, __) async {
        await ref.read(energyProvider.notifier).addEnergy(_kEnergyReward);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('+$_kEnergyReward energias adicionadas!'),
              backgroundColor: kGreenLight,
            ),
          );
        }
      },
    );
    if (mounted) setState(() => _adLoading = false);
  }

  void _showEnergyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.bolt, color: kYellow, size: 22),
            SizedBox(width: 8),
            Text(
              'Recarregar energia',
              style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
        content: Text(
          'Assista um breve vídeo e ganhe +$_kEnergyReward energias instantaneamente.',
          style: const TextStyle(color: kTextSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Agora não', style: TextStyle(color: kTextSecondary)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: kGreenLight,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _adLoading
                ? null
                : () {
                    Navigator.pop(ctx);
                    _showAd();
                  },
            icon: _adLoading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.play_circle_outline, size: 18),
            label: Text('Assistir (+$_kEnergyReward)'),
          ),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    if (d <= Duration.zero) return '00:00';
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final energyAsync = ref.watch(energyProvider);
    return energyAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (energy) {
        const totalHearts = kMaxEnergy ~/ kEnergyPerHeart;

        final hearts = Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 2,
          children: List.generate(totalHearts, (i) {
            final fill = ((energy.current - i * kEnergyPerHeart) / kEnergyPerHeart)
                .clamp(0.0, 1.0);
            return _HeartIcon(fill: fill);
          }),
        );

        if (energy.isFull) return hearts;

        // Energia não cheia: corações + countdown + botão [+]
        return Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            hearts,
            Text(
              _fmt(energy.nextRegenIn),
              style: const TextStyle(
                fontSize: 11,
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            GestureDetector(
              onTap: _showEnergyDialog,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: kGreenLight.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: kGreenLight.withOpacity(0.6), width: 1),
                ),
                child: const Icon(Icons.add, size: 14, color: kGreenLight),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HeartIcon extends StatelessWidget {
  final double fill;
  const _HeartIcon({required this.fill});

  @override
  Widget build(BuildContext context) {
    const size = 18.0;
    const color = Colors.red;

    if (fill >= 1.0) return const Icon(Icons.favorite, color: color, size: size);
    if (fill <= 0.0) return const Icon(Icons.favorite_border, color: color, size: size);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          const Icon(Icons.favorite_border, color: color, size: size),
          ClipRect(
            clipper: _FillClipper(fill),
            child: const Icon(Icons.favorite, color: color, size: size),
          ),
        ],
      ),
    );
  }
}

class _FillClipper extends CustomClipper<Rect> {
  final double fill;
  const _FillClipper(this.fill);

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width * fill, size.height);

  @override
  bool shouldReclip(_FillClipper old) => old.fill != fill;
}
