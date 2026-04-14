import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/supabase_client.dart';
import '../../../core/theme.dart';

class NicknameScreen extends StatefulWidget {
  const NicknameScreen({super.key});

  @override
  State<NicknameScreen> createState() => _NicknameScreenState();
}

class _NicknameScreenState extends State<NicknameScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final name = _controller.text.trim();
    if (name.length < 3) {
      setState(() => _error = 'Mínimo 3 caracteres');
      return;
    }
    if (name.length > 20) {
      setState(() => _error = 'Máximo 20 caracteres');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final userId = supabase.auth.currentUser!.id;
      await supabase.from('user_profiles').upsert({
        'user_id': userId,
        'nickname': name,
      }, onConflict: 'user_id');

      if (mounted) context.go('/');
    } catch (e) {
      setState(() => _error = 'Erro ao salvar. Tente novamente.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.sports_soccer, size: 56, color: kGreenLight),
              const SizedBox(height: 24),
              const Text(
                'Como quer ser\nchamado?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: kTextPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Seu nome aparece no ranking do desafio diário.',
                style: TextStyle(fontSize: 14, color: kTextSecondary),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _controller,
                autofocus: true,
                maxLength: 20,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(color: kTextPrimary, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Seu nome ou apelido',
                  counterStyle: const TextStyle(color: kTextSecondary),
                  errorText: _error,
                  filled: true,
                  fillColor: const Color(0xFF1F2937),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: kGreenLight, width: 2),
                  ),
                ),
                onSubmitted: (_) => _confirm(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _confirm,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Entrar no jogo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
