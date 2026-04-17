import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_client.dart';
import '../../game/models/club.dart';

/// Busca um clube aleatório com escudo disponível para o modo livre.
final shieldFreeClubProvider = FutureProvider<Club>((ref) async {
  final data = await supabase
      .from('clubs')
      .select('*, leagues(name)')
      .not('shield_url', 'is', null);

  final list = (data as List)
      .map((j) => Club.fromJson(j as Map<String, dynamic>))
      .toList();

  if (list.isEmpty) throw Exception('Nenhum clube com escudo disponível');

  final rng = Random();
  return list[rng.nextInt(list.length)];
});
