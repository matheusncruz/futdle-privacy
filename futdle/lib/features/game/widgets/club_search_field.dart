import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/club.dart';
import '../providers/clubs_provider.dart';
import '../../../core/theme.dart';

class ClubSearchField extends ConsumerStatefulWidget {
  final void Function(Club club) onClubSelected;
  const ClubSearchField({super.key, required this.onClubSelected});

  @override
  ConsumerState<ClubSearchField> createState() => _ClubSearchFieldState();
}

class _ClubSearchFieldState extends ConsumerState<ClubSearchField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _controller.text;
    final suggestions = ref.watch(clubSearchProvider(query));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Lista cresce para CIMA — fica visível acima do teclado
        if (suggestions.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              reverse: false,
              itemCount: suggestions.length,
              itemBuilder: (context, i) {
                final club = suggestions[i];
                return ListTile(
                  dense: true,
                  title: Text(club.name, style: const TextStyle(fontSize: 14)),
                  subtitle: Text(
                    '${club.leagueName} · ${club.country}',
                    style: const TextStyle(fontSize: 12, color: kTextSecondary),
                  ),
                  onTap: () {
                    _controller.clear();
                    setState(() {});
                    _focusNode.unfocus();
                    widget.onClubSelected(club);
                  },
                );
              },
            ),
          ),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: const InputDecoration(
            hintText: 'Digite o nome do time...',
            prefixIcon: Icon(Icons.search, color: kTextSecondary),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }
}
