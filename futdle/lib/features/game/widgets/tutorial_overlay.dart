import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme.dart';

const String _kTutorialSeen = 'tutorial_seen';

Future<bool> shouldShowTutorial() async {
  final prefs = await SharedPreferences.getInstance();
  return !(prefs.getBool(_kTutorialSeen) ?? false);
}

Future<void> markTutorialSeen() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kTutorialSeen, true);
}

Future<void> showTutorialOverlay(BuildContext context) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.75),
    builder: (_) => const _TutorialDialog(),
  );
}

class _TutorialDialog extends StatefulWidget {
  const _TutorialDialog();

  @override
  State<_TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<_TutorialDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _dontShowAgain = false;

  static const int _totalPages = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _dismiss() async {
    if (_dontShowAgain) {
      await markTutorialSeen();
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _totalPages - 1;

    return Dialog(
      backgroundColor: kSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header bar with close button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: kGreenLight,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'FUTDLE',
                  style: TextStyle(
                    color: kGreenLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _dismiss,
                  icon: const Icon(Icons.close, color: kTextSecondary, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Page content
          SizedBox(
            height: 340,
            child: PageView(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: const [
                _Page1(),
                _Page2(),
                _Page3(),
                _Page4(),
              ],
            ),
          ),

          // Dots indicator
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_totalPages, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i ? kGreenLight : kTextSecondary.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),

          // Checkbox (last page only)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isLastPage
                ? Padding(
                    key: const ValueKey('checkbox'),
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => setState(() => _dontShowAgain = !_dontShowAgain),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: _dontShowAgain,
                                onChanged: (v) => setState(() => _dontShowAgain = v ?? false),
                                activeColor: kGreenLight,
                                checkColor: kBackground,
                                side: const BorderSide(color: kTextSecondary),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Não exibir novamente',
                              style: TextStyle(color: kTextSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox(key: ValueKey('empty'), height: 10),
          ),

          // Action button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLastPage ? _dismiss : _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreenLight,
                  foregroundColor: kBackground,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  isLastPage ? 'Entendi!' : 'Próximo',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page helpers ──────────────────────────────────────────────────────────────

class _PageShell extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _PageShell({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  final Widget leading;
  final String text;

  const _BulletRow({required this.leading, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leading,
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(color: kTextPrimary, fontSize: 13, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

Widget _colorDot(Color color) => Container(
      width: 18,
      height: 18,
      margin: const EdgeInsets.only(top: 1),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );

// ── Pages ─────────────────────────────────────────────────────────────────────

class _Page1 extends StatelessWidget {
  const _Page1();

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      title: 'Como jogar',
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'Tente adivinhar o clube de futebol misterioso.\nCada tentativa revela pistas sobre os atributos do clube através de células coloridas.',
            style: TextStyle(color: kTextPrimary, fontSize: 13, height: 1.5),
          ),
        ),
        const SizedBox(height: 14),
        _BulletRow(
          leading: const Text('⚽', style: TextStyle(fontSize: 16)),
          text: 'Digite o nome de qualquer clube no campo de busca.',
        ),
        _BulletRow(
          leading: const Text('🔍', style: TextStyle(fontSize: 16)),
          text: 'Compare os atributos revelados com o clube alvo.',
        ),
        _BulletRow(
          leading: const Text('🏆', style: TextStyle(fontSize: 16)),
          text: 'Use as pistas para chegar ao clube correto!',
        ),
      ],
    );
  }
}

class _Page2 extends StatelessWidget {
  const _Page2();

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      title: 'Cores do feedback',
      children: [
        _BulletRow(
          leading: _colorDot(kGreenLight),
          text: 'Verde — atributo correto! Igual ao do clube alvo.',
        ),
        _BulletRow(
          leading: _colorDot(kYellow),
          text: 'Amarelo — parcialmente correto. Para a liga, significa que o clube joga no mesmo país que o alvo.',
        ),
        _BulletRow(
          leading: _colorDot(kRed),
          text: 'Vermelho — atributo errado.',
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: kBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Text('↑ ↓', style: TextStyle(fontSize: 22, color: kTextPrimary, fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Setas indicam direção para valores numéricos (Ano, Nac., Int.)',
                  style: TextStyle(color: kTextSecondary, fontSize: 12, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Page3 extends StatelessWidget {
  const _Page3();

  @override
  Widget build(BuildContext context) {
    final attrs = [
      ('País', 'País sede do clube'),
      ('Cont.', 'Continente do clube'),
      ('Liga', 'Liga em que disputa (🟡 = mesma liga do mesmo país)'),
      ('Ano', 'Ano de fundação (↑ = alvo mais recente, ↓ = mais antigo)'),
      ('Cor 1 / Cor 2', 'Cores do escudo do clube (não do uniforme)'),
      ('Nac.', 'Títulos nacionais (campeonatos do país) — valor aproximado'),
      ('Int.', 'Títulos internacionais (ex: Libertadores, Champions) — valor aproximado'),
    ];

    return _PageShell(
      title: 'As características',
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: attrs.length,
            itemBuilder: (_, i) {
              final (label, desc) = attrs[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: kGreen,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: kTextPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        desc,
                        style: const TextStyle(color: kTextPrimary, fontSize: 12, height: 1.4),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Page4 extends StatelessWidget {
  const _Page4();

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      title: 'Dica',
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kGreenLight.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('❤️', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  const Text(
                    'Modo Livre',
                    style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Cada partida no Modo Livre custa 1 coração de energia. Gerencie bem seus corações!',
                style: TextStyle(color: kTextSecondary, fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kYellow.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('📅', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  const Text(
                    'Desafio Diário',
                    style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'O Desafio Diário é gratuito! Um novo clube misterioso a cada dia para todos os jogadores.',
                style: TextStyle(color: kTextSecondary, fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
