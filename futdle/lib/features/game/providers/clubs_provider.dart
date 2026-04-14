import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_client.dart';
import '../models/club.dart';

final allClubsProvider = FutureProvider<List<Club>>((ref) async {
  final data = await supabase
      .from('clubs')
      .select('*, leagues(name)')
      .order('name');
  return (data as List).map((e) => Club.fromJson(e)).toList();
});

/// Remove acentos e normaliza para comparação (ex: "são paulo" → "sao paulo")
String _normalize(String s) {
  return s
      .toLowerCase()
      .replaceAll(RegExp(r'[àáâãäå]'), 'a')
      .replaceAll(RegExp(r'[èéêë]'), 'e')
      .replaceAll(RegExp(r'[ìíîï]'), 'i')
      .replaceAll(RegExp(r'[òóôõö]'), 'o')
      .replaceAll(RegExp(r'[ùúûü]'), 'u')
      .replaceAll(RegExp(r'[ç]'), 'c')
      .replaceAll(RegExp(r'[ñ]'), 'n');
}

final clubSearchProvider = Provider.family<List<Club>, String>((ref, query) {
  final clubs = ref.watch(allClubsProvider).valueOrNull ?? [];
  if (query.isEmpty) return [];
  final normalizedQuery = _normalize(query);
  return clubs
      .where((c) =>
          _normalize(c.name).contains(normalizedQuery) ||
          _normalize(c.altName ?? '').contains(normalizedQuery))
      .take(8)
      .toList();
});

/// Retorna um clube aleatório para o modo livre
final randomClubProvider = FutureProvider<Club>((ref) async {
  final clubs = await ref.watch(allClubsProvider.future);
  return clubs[Random().nextInt(clubs.length)];
});
