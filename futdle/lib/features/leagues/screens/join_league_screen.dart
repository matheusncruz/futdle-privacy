// futdle/lib/features/leagues/screens/join_league_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/supabase_client.dart';
import '../providers/friend_leagues_provider.dart';

class JoinLeagueScreen extends ConsumerStatefulWidget {
  const JoinLeagueScreen({super.key});

  @override
  ConsumerState<JoinLeagueScreen> createState() => _JoinLeagueScreenState();
}

class _JoinLeagueScreenState extends ConsumerState<JoinLeagueScreen> {
  final _codeController = TextEditingController();
  bool   _loading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('O código deve ter 6 caracteres.')));
      return;
    }

    setState(() => _loading = true);
    try {
      final userId = supabase.auth.currentUser!.id;

      // Look up league
      final league = await supabase
          .from('friend_leagues')
          .select('id, name, entry_mode, ends_at')
          .eq('code', code)
          .maybeSingle();

      if (league == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Código inválido.')));
        }
        return;
      }

      final endsAt = DateTime.parse(league['ends_at'] as String);
      if (endsAt.isBefore(DateTime.now())) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Esta liga já encerrou.')));
        }
        return;
      }

      final leagueId  = league['id'] as String;
      final leagueName = league['name'] as String;
      final entryMode = league['entry_mode'] as String;
      final status    = entryMode == 'open' ? 'approved' : 'pending';

      // Upsert membership
      await supabase.from('friend_league_members').upsert({
        'league_id': leagueId,
        'user_id':   userId,
        'status':    status,
        'joined_at': entryMode == 'open'
            ? DateTime.now().toIso8601String()
            : null,
      }, onConflict: 'league_id,user_id');

      // Create score row if approved
      if (entryMode == 'open') {
        await supabase.from('friend_league_scores').upsert({
          'league_id':    leagueId,
          'user_id':      userId,
          'total_points': 0,
        }, onConflict: 'league_id,user_id');
      }

      ref.invalidate(friendLeaguesProvider);

      if (!mounted) return;

      if (entryMode == 'open') {
        context.go('/leagues/friend/$leagueId');
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: kSurface,
            title: const Text('Solicitação enviada!',
                style: TextStyle(color: kTextPrimary)),
            content: Text(
              'Aguardando o criador da liga "$leagueName" aprovar sua entrada. Você será notificado.',
              style: const TextStyle(color: kTextSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/leagues');
                },
                child: const Text('OK', style: TextStyle(color: kGreenLight)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
          title: const Text('Entrar em uma liga',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Digite o código que seu amigo compartilhou',
                style: TextStyle(color: kTextSecondary, fontSize: 14),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              style: const TextStyle(
                color: kTextPrimary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: kSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: kGreenLight.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: kGreenLight.withOpacity(0.3)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _join,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreenLight,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.black))
                    : const Text('Entrar na liga',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
