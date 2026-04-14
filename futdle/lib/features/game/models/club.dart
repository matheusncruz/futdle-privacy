class Club {
  final String id;
  final String name;
  final String? altName;
  final String country;
  final String continent;
  final String leagueName;
  final int foundedYear;
  final String primaryColor;
  final String secondaryColor;
  final int nationalTitles;
  final int internationalTitles;
  final String? shieldUrl;

  const Club({
    required this.id,
    required this.name,
    this.altName,
    required this.country,
    required this.continent,
    required this.leagueName,
    required this.foundedYear,
    required this.primaryColor,
    required this.secondaryColor,
    required this.nationalTitles,
    required this.internationalTitles,
    this.shieldUrl,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    final league = json['leagues'];
    return Club(
      id: json['id'] as String,
      name: json['name'] as String,
      altName: json['alt_name'] as String?,
      country: json['country'] as String,
      continent: json['continent'] as String,
      leagueName: league != null ? (league as Map<String, dynamic>)['name'] as String : '',
      foundedYear: json['founded_year'] as int? ?? 0,
      primaryColor: json['primary_color'] as String,
      secondaryColor: json['secondary_color'] as String,
      nationalTitles: json['national_titles'] as int,
      internationalTitles: json['international_titles'] as int,
      shieldUrl: json['shield_url'] as String?,
    );
  }
}
