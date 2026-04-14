import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase_client.dart';
import '../../../core/theme.dart';

/// Bottom sheet com abas: Criar conta / Entrar
Future<void> showAuthModal(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1F2937),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _AuthModal(),
  );
}

class _AuthModal extends StatefulWidget {
  const _AuthModal();

  @override
  State<_AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends State<_AuthModal> {
  int _tab = 0;
  bool _loading = false;
  String? _error;

  // Criar conta
  final _regEmail = TextEditingController();
  final _regPass = TextEditingController();
  final _regPass2 = TextEditingController();

  // Entrar
  final _loginEmail = TextEditingController();
  final _loginPass = TextEditingController();

  @override
  void dispose() {
    _regEmail.dispose();
    _regPass.dispose();
    _regPass2.dispose();
    _loginEmail.dispose();
    _loginPass.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final email = _regEmail.text.trim();
    final pass = _regPass.text;
    final pass2 = _regPass2.text;

    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Preencha todos os campos');
      return;
    }
    if (pass != pass2) {
      setState(() => _error = 'Senhas não conferem');
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = 'Senha mínima: 6 caracteres');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Converte usuário anônimo em conta permanente (mantém user_id e progresso)
      await supabase.auth.updateUser(
        UserAttributes(email: email, password: pass),
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta criada e progresso salvo!'),
            backgroundColor: kGreenLight,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } on AuthException catch (e) {
      setState(() => _error = _translateError(e.message));
    } catch (e) {
      setState(() => _error = 'Erro: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _login() async {
    final email = _loginEmail.text.trim();
    final pass = _loginPass.text;

    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Preencha todos os campos');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Encerra sessão anônima atual antes de logar com conta real
      await supabase.auth.signOut();
      await supabase.auth.signInWithPassword(email: email, password: pass);
      if (mounted) {
        Navigator.pop(context);
        context.go('/');
      }
    } on AuthException catch (e) {
      // Se falhou o login, garante sessão anônima de volta
      if (supabase.auth.currentUser == null) {
        await supabase.auth.signInAnonymously();
      }
      setState(() => _error = _translateError(e.message));
    } catch (e) {
      if (supabase.auth.currentUser == null) {
        await supabase.auth.signInAnonymously();
      }
      setState(() => _error = 'Erro: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _translateError(String msg) {
    if (msg.contains('already registered')) return 'E-mail já cadastrado';
    if (msg.contains('Invalid login') || msg.contains('invalid_credentials')) {
      return 'E-mail ou senha incorretos';
    }
    if (msg.contains('Email not confirmed')) {
      return 'Confirme seu e-mail antes de entrar';
    }
    if (msg.contains('rate limit')) return 'Muitas tentativas. Aguarde um momento.';
    return msg;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Salvar progresso',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Crie uma conta para não perder seu histórico.',
            style: TextStyle(fontSize: 13, color: kTextSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Seletor de modo
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() { _tab = 0; _error = null; }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _tab == 0 ? kGreenLight : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      'Criar conta',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _tab == 0 ? kGreenLight : kTextSecondary,
                        fontWeight: _tab == 0 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() { _tab = 1; _error = null; }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _tab == 1 ? kGreenLight : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      'Entrar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _tab == 1 ? kGreenLight : kTextSecondary,
                        fontWeight: _tab == 1 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Erro
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _error!,
                style: const TextStyle(color: kRed, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),

          // Formulários — IndexedStack mostra só um por vez
          IndexedStack(
            index: _tab,
            children: [
              // ── Criar conta ──
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _field(_regEmail, 'E-mail', TextInputType.emailAddress),
                  const SizedBox(height: 10),
                  _field(_regPass, 'Senha', TextInputType.text, obscure: true),
                  const SizedBox(height: 10),
                  _field(_regPass2, 'Confirmar senha', TextInputType.text, obscure: true),
                ],
              ),
              // ── Entrar ──
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _field(_loginEmail, 'E-mail', TextInputType.emailAddress),
                  const SizedBox(height: 10),
                  _field(_loginPass, 'Senha', TextInputType.text, obscure: true),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading
                  ? null
                  : () => _tab == 0 ? _register() : _login(),
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_tab == 0 ? 'Criar conta' : 'Entrar'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String hint,
    TextInputType type, {
    bool obscure = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      obscureText: obscure,
      style: const TextStyle(color: kTextPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: kTextSecondary),
        filled: true,
        fillColor: const Color(0xFF111827),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kGreenLight),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
