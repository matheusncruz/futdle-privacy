import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../core/supabase_client.dart';
import '../providers/stats_provider.dart';
import '../../auth/widgets/auth_modal.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(playerStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FUTDLE',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 3)),
        centerTitle: true,
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('Erro ao carregar stats: $e')),
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Avatar + nickname
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFF1F2937),
                child: Icon(Icons.person, size: 44, color: kGreenLight),
              ),
              const SizedBox(height: 12),
              Text(
                stats.nickname,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kTextPrimary),
              ),
              const SizedBox(height: 8),
              _AccountStatusBadge(),
              const SizedBox(height: 32),

              // Grid de stats
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  _StatCard(
                    label: 'Partidas',
                    value: '${stats.totalGames}',
                    icon: Icons.sports_soccer,
                    color: kGreenLight,
                  ),
                  _StatCard(
                    label: 'Vitórias',
                    value: '${stats.wins}',
                    icon: Icons.emoji_events,
                    color: kYellow,
                  ),
                  _StatCard(
                    label: 'Taxa de acerto',
                    value: '${stats.winRate.toStringAsFixed(0)}%',
                    icon: Icons.percent,
                    color: kGreen,
                  ),
                  _StatCard(
                    label: 'Média tent.',
                    value: stats.avgAttempts > 0
                        ? stats.avgAttempts.toStringAsFixed(1)
                        : '-',
                    icon: Icons.bar_chart,
                    color: const Color(0xFF60A5FA),
                  ),
                  _StatCard(
                    label: 'Melhor result.',
                    value: stats.bestAttempts > 0
                        ? '${stats.bestAttempts} tent.'
                        : '-',
                    icon: Icons.star,
                    color: kYellow,
                  ),
                  _StatCard(
                    label: 'Melhor tempo',
                    value: stats.bestTime,
                    icon: Icons.timer,
                    color: const Color(0xFFF87171),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Mensagem motivacional
              if (stats.totalGames == 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2937),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Jogue seu primeiro desafio para ver suas estatísticas aqui!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: kTextSecondary, fontSize: 14),
                  ),
                )
              else if (stats.winRate >= 80)
                _Badge(
                    emoji: '🏆',
                    label: 'Craque!',
                    sub: 'Acerta mais de 80% dos desafios')
              else if (stats.winRate >= 50)
                _Badge(
                    emoji: '⚽',
                    label: 'Em forma!',
                    sub: 'Mais da metade de acertos')
              else
                _Badge(
                    emoji: '📚',
                    label: 'Aprendendo!',
                    sub: 'Continue jogando para melhorar'),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(label,
                    style: TextStyle(color: color, fontSize: 11),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kTextPrimary),
          ),
        ],
      ),
    );
  }
}

class _AccountStatusBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    final hasEmail = user?.email != null && user!.email!.isNotEmpty;

    if (!hasEmail) {
      return OutlinedButton.icon(
        onPressed: () => showAuthModal(context),
        icon: const Icon(Icons.cloud_upload_outlined, size: 16),
        label: const Text('Criar conta e salvar progresso'),
        style: OutlinedButton.styleFrom(
          foregroundColor: kGreenLight,
          side: const BorderSide(color: kGreenLight),
          textStyle: const TextStyle(fontSize: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.verified, color: kGreenLight, size: 16),
        const SizedBox(width: 6),
        Text(
          user?.email ?? 'Conta salva',
          style: const TextStyle(color: kGreenLight, fontSize: 12),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String emoji;
  final String label;
  final String sub;

  const _Badge({required this.emoji, required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kYellow.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: kTextPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              Text(sub,
                  style: const TextStyle(
                      color: kTextSecondary, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
