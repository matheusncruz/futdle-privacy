// futdle/lib/features/leagues/screens/create_league_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/supabase_client.dart';
import '../providers/friend_leagues_provider.dart';

class CreateLeagueScreen extends ConsumerStatefulWidget {
  const CreateLeagueScreen({super.key});

  @override
  ConsumerState<CreateLeagueScreen> createState() => _CreateLeagueScreenState();
}

class _CreateLeagueScreenState extends ConsumerState<CreateLeagueScreen> {
  final _nameController = TextEditingController();
  String _mode      = 'classic';
  int    _days      = 30;
  String _entryMode = 'open';
  bool   _loading   = false;
  String? _createdCode;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rng   = Random();
    return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Digite um nome para a liga.')));
      return;
    }

    setState(() => _loading = true);
    try {
      final userId   = supabase.auth.currentUser!.id;
      final code     = _generateCode();
      final today    = DateTime.now();
      final startsAt = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final endsDate = today.add(Duration(days: _days - 1));
      final endsAt   = '${endsDate.year}-${endsDate.month.toString().padLeft(2, '0')}-${endsDate.day.toString().padLeft(2, '0')}';

      // Insert league
      final result = await supabase
          .from('friend_leagues')
          .insert({
            'code':       code,
            'name':       name,
            'created_by': userId,
            'mode':       _mode,
            'entry_mode': _entryMode,
            'starts_at':  startsAt,
            'ends_at':    endsAt,
          })
          .select('id')
          .single();

      final leagueId = result['id'] as String;

      // Creator auto-joins as approved
      await supabase.from('friend_league_members').insert({
        'league_id': leagueId,
        'user_id':   userId,
        'status':    'approved',
        'joined_at': DateTime.now().toIso8601String(),
      });

      // Create score row for creator
      await supabase.from('friend_league_scores').insert({
        'league_id':    leagueId,
        'user_id':      userId,
        'total_points': 0,
      });

      ref.invalidate(friendLeaguesProvider);
      setState(() => _createdCode = code);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao criar liga: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_createdCode != null) return _SuccessView(code: _createdCode!);

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
          title: const Text('Criar Liga',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('NOME DA LIGA'),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: kTextPrimary),
              decoration: InputDecoration(
                hintText: 'Ex: Galera do Fut ⚽',
                hintStyle: const TextStyle(color: kTextSecondary),
                filled: true,
                fillColor: kSurface,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            _label('MODO'),
            const SizedBox(height: 8),
            _SegmentedPicker(
              options: const [
                ('classic', '🎮 Clássico'),
                ('shield',  '🛡️ Escudo'),
                ('both',    '⚡ Ambos'),
              ],
              selected: _mode,
              onChanged: (v) => setState(() => _mode = v),
            ),
            const SizedBox(height: 20),
            _label('DURAÇÃO'),
            const SizedBox(height: 8),
            _SegmentedPicker(
              options: const [
                ('7',  '7 dias'),
                ('14', '14 dias'),
                ('30', '30 dias'),
              ],
              selected: _days.toString(),
              onChanged: (v) => setState(() => _days = int.parse(v)),
            ),
            const SizedBox(height: 20),
            _label('ENTRADA NA LIGA'),
            const SizedBox(height: 10),
            _EntryModeOption(
              value:       'open',
              groupValue:  _entryMode,
              title:       '🔓 Entrada livre',
              subtitle:    'Qualquer um com o código entra direto',
              accentColor: kGreenLight,
              onChanged:   (v) => setState(() => _entryMode = v),
            ),
            const SizedBox(height: 8),
            _EntryModeOption(
              value:       'approval',
              groupValue:  _entryMode,
              title:       '🔒 Aprovação manual',
              subtitle:    'Você aprova cada solicitação antes de entrar',
              accentColor: const Color(0xFF60a5fa),
              onChanged:   (v) => setState(() => _entryMode = v),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
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
                    : const Text('Criar liga',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          color: kTextSecondary, fontSize: 10, letterSpacing: 1));
}

// ── Success view ─────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  final String code;
  const _SuccessView({required this.code});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
          title: const Text('Liga criada!',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          automaticallyImplyLeading: false),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Compartilhe o código com seus amigos',
                  style: TextStyle(color: kTextSecondary, fontSize: 14),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: code));
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Código copiado!')));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 20),
                  decoration: BoxDecoration(
                    color: kSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: kGreenLight.withOpacity(0.4), width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(code,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 10,
                            color: kGreenLight,
                          )),
                      const SizedBox(height: 4),
                      const Text('toque para copiar',
                          style:
                              TextStyle(color: kTextSecondary, fontSize: 11)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/leagues'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreenLight,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Ver minha liga →',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _SegmentedPicker extends StatelessWidget {
  final List<(String, String)> options;
  final String selected;
  final void Function(String) onChanged;
  const _SegmentedPicker(
      {required this.options,
      required this.selected,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.map((opt) {
        final isSelected = opt.$1 == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(opt.$1),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF1d4ed8)
                    : kSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(opt.$2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : kTextSecondary,
                    fontSize: 12,
                  )),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _EntryModeOption extends StatelessWidget {
  final String value;
  final String groupValue;
  final String title;
  final String subtitle;
  final Color accentColor;
  final void Function(String) onChanged;
  const _EntryModeOption({
    required this.value,
    required this.groupValue,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? accentColor.withOpacity(0.6) : kSurface,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? accentColor : Colors.transparent,
                border: Border.all(
                  color: selected ? accentColor : kTextSecondary,
                  width: 2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: selected ? kTextPrimary : kTextSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  Text(subtitle,
                      style: const TextStyle(
                          color: kTextSecondary, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
