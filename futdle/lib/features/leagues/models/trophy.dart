// futdle/lib/features/leagues/models/trophy.dart

class UserTrophy {
  final String type;
  final DateTime month;
  final DateTime awardedAt;

  const UserTrophy({
    required this.type,
    required this.month,
    required this.awardedAt,
  });

  String get emoji {
    if (type.endsWith('_1st'))        return '🥇';
    if (type.endsWith('_2nd'))        return '🥈';
    if (type.endsWith('_3rd'))        return '🥉';
    if (type == 'friend_champion')    return '👥';
    if (type == 'full_month')         return '🔥';
    return '🏆';
  }

  String get label {
    switch (type) {
      case 'official_classic_1st': return '1º Liga Clássico';
      case 'official_classic_2nd': return '2º Liga Clássico';
      case 'official_classic_3rd': return '3º Liga Clássico';
      case 'official_shield_1st':  return '1º Liga Escudo';
      case 'official_shield_2nd':  return '2º Liga Escudo';
      case 'official_shield_3rd':  return '3º Liga Escudo';
      case 'friend_champion':      return 'Campeão de Liga';
      case 'full_month':           return 'Mês Completo';
      default:                     return type;
    }
  }

  String get monthLabel {
    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
    ];
    return '${months[month.month - 1]}/${month.year.toString().substring(2)}';
  }
}
