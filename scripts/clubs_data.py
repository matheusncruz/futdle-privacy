# Mapeamento manual: nome do clube (TheSportsDB) -> dados curados
CLUBS_OVERRIDES = {
    # Brasil
    "Flamengo": {"primary_color": "#e31d1a", "secondary_color": "#000000", "national_titles": 9, "international_titles": 3, "alt_name": "Mengão"},
    "Palmeiras": {"primary_color": "#006437", "secondary_color": "#ffffff", "national_titles": 12, "international_titles": 3, "alt_name": "Verdão"},
    "Corinthians": {"primary_color": "#000000", "secondary_color": "#ffffff", "national_titles": 7, "international_titles": 2, "alt_name": "Timão"},
    "São Paulo FC": {"primary_color": "#ff0000", "secondary_color": "#000000", "national_titles": 6, "international_titles": 3, "alt_name": "Tricolor"},
    "Santos FC": {"primary_color": "#000000", "secondary_color": "#ffffff", "national_titles": 8, "international_titles": 2, "alt_name": "Peixe"},
    "Fluminense FC": {"primary_color": "#720000", "secondary_color": "#6ca044", "national_titles": 4, "international_titles": 1, "alt_name": "Flu"},
    "Atletico Mineiro": {"primary_color": "#000000", "secondary_color": "#ffffff", "national_titles": 3, "international_titles": 2, "alt_name": "Galo"},
    "Gremio": {"primary_color": "#0041a0", "secondary_color": "#000000", "national_titles": 2, "international_titles": 3, "alt_name": "Tricolor Gaúcho"},
    "Internacional": {"primary_color": "#e31d1a", "secondary_color": "#ffffff", "national_titles": 3, "international_titles": 2, "alt_name": "Colorado"},
    "Cruzeiro EC": {"primary_color": "#003087", "secondary_color": "#ffffff", "national_titles": 3, "international_titles": 2, "alt_name": "Raposa"},
    # Inglaterra
    "Manchester City": {"primary_color": "#6cabdd", "secondary_color": "#ffffff", "national_titles": 10, "international_titles": 1},
    "Liverpool FC": {"primary_color": "#c8102e", "secondary_color": "#ffffff", "national_titles": 19, "international_titles": 6},
    "Arsenal": {"primary_color": "#ef0107", "secondary_color": "#ffffff", "national_titles": 13, "international_titles": 0},
    "Chelsea FC": {"primary_color": "#034694", "secondary_color": "#ffffff", "national_titles": 6, "international_titles": 2},
    "Manchester United": {"primary_color": "#da291c", "secondary_color": "#000000", "national_titles": 20, "international_titles": 3},
    "Tottenham Hotspur": {"primary_color": "#132257", "secondary_color": "#ffffff", "national_titles": 2, "international_titles": 0},
    # Espanha
    "Real Madrid CF": {"primary_color": "#febe10", "secondary_color": "#ffffff", "national_titles": 35, "international_titles": 14},
    "FC Barcelona": {"primary_color": "#004d98", "secondary_color": "#a50044", "national_titles": 27, "international_titles": 5},
    "Atletico Madrid": {"primary_color": "#cb3524", "secondary_color": "#ffffff", "national_titles": 11, "international_titles": 3},
    "Sevilla FC": {"primary_color": "#ffffff", "secondary_color": "#d91a21", "national_titles": 1, "international_titles": 7},
    # Alemanha
    "Bayern Munich": {"primary_color": "#dc052d", "secondary_color": "#ffffff", "national_titles": 32, "international_titles": 6},
    "Borussia Dortmund": {"primary_color": "#fde100", "secondary_color": "#000000", "national_titles": 8, "international_titles": 1},
    # Itália
    "Juventus FC": {"primary_color": "#000000", "secondary_color": "#ffffff", "national_titles": 36, "international_titles": 2},
    "AC Milan": {"primary_color": "#fb090b", "secondary_color": "#000000", "national_titles": 19, "international_titles": 7},
    "Inter Milan": {"primary_color": "#0068a8", "secondary_color": "#000000", "national_titles": 19, "international_titles": 3},
    "AS Roma": {"primary_color": "#8e1f2f", "secondary_color": "#f5c518", "national_titles": 3, "international_titles": 0},
    "SSC Napoli": {"primary_color": "#12a0c3", "secondary_color": "#ffffff", "national_titles": 3, "international_titles": 0},
    # França
    "Paris Saint-Germain FC": {"primary_color": "#003370", "secondary_color": "#e30613", "national_titles": 12, "international_titles": 0, "alt_name": "PSG"},
    "Olympique de Marseille": {"primary_color": "#009cde", "secondary_color": "#ffffff", "national_titles": 9, "international_titles": 1, "alt_name": "OM"},
    # Argentina
    "Boca Juniors": {"primary_color": "#003087", "secondary_color": "#f5d130", "national_titles": 35, "international_titles": 6},
    "River Plate": {"primary_color": "#eb0029", "secondary_color": "#ffffff", "national_titles": 38, "international_titles": 4},
}

LEAGUE_MAP = {
    "English Premier League": {"name": "Premier League", "country": "Inglaterra", "continent": "Europa"},
    "Spanish La Liga": {"name": "La Liga", "country": "Espanha", "continent": "Europa"},
    "German Bundesliga": {"name": "Bundesliga", "country": "Alemanha", "continent": "Europa"},
    "Italian Serie A": {"name": "Serie A", "country": "Itália", "continent": "Europa"},
    "French Ligue 1": {"name": "Ligue 1", "country": "França", "continent": "Europa"},
    "Brazilian Série A": {"name": "Brasileirão Série A", "country": "Brasil", "continent": "América do Sul"},
    "Argentine Primera Division": {"name": "Liga Profesional Argentina", "country": "Argentina", "continent": "América do Sul"},
    "Mexican Primera Division": {"name": "Liga MX", "country": "México", "continent": "América do Norte"},
}

LEAGUE_IDS = {
    "English Premier League": "4328",
    "Spanish La Liga": "4335",
    "German Bundesliga": "4331",
    "Italian Serie A": "4332",
    "French Ligue 1": "4334",
    "Brazilian Série A": "4351",
    "Argentine Primera Division": "4406",
    "Mexican Primera Division": "4350",
}
