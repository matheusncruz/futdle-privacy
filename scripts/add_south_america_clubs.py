"""
Adiciona ligas e clubes da América do Sul (Chile, Colômbia, Uruguai, Equador,
Paraguai, Peru e Brasil Série B) ao banco Supabase, depois estende os desafios
diários para cobrir 365 dias a partir de hoje.

Uso: python add_south_america_clubs.py
"""

import os
import random
from datetime import date, timedelta
from dotenv import load_dotenv
from supabase import create_client, Client

load_dotenv()

SUPABASE_URL = os.environ["SUPABASE_URL"]
SUPABASE_KEY = os.environ["SUPABASE_SERVICE_KEY"]

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# ---------------------------------------------------------------------------
# League definitions
# ---------------------------------------------------------------------------

LEAGUES = [
    {"name": "Primera División de Chile",       "country": "Chile",    "continent": "América do Sul"},
    {"name": "Liga BetPlay Dimayor",            "country": "Colômbia", "continent": "América do Sul"},
    {"name": "Primera División de Uruguay",     "country": "Uruguai",  "continent": "América do Sul"},
    {"name": "LigaPro Ecuador",                 "country": "Equador",  "continent": "América do Sul"},
    {"name": "División Profesional Paraguay",   "country": "Paraguai", "continent": "América do Sul"},
    {"name": "Liga 1 Peru",                     "country": "Peru",     "continent": "América do Sul"},
    {"name": "Brasileirão Série B",             "country": "Brasil",   "continent": "América do Sul"},
]

# ---------------------------------------------------------------------------
# Club definitions  (keyed by league name)
# ---------------------------------------------------------------------------

CLUBS_BY_LEAGUE = {
    "Primera División de Chile": [
        {"name": "Colo-Colo",          "country": "Chile",    "continent": "América do Sul", "founded_year": 1925, "primary_color": "#FFFFFF", "secondary_color": "#000000", "national_titles": 33, "international_titles": 1},
        {"name": "Universidad de Chile","country": "Chile",    "continent": "América do Sul", "founded_year": 1927, "primary_color": "#0033A0", "secondary_color": "#FF0000", "national_titles": 18, "international_titles": 0},
        {"name": "Universidad Católica","country": "Chile",    "continent": "América do Sul", "founded_year": 1937, "primary_color": "#003DA5", "secondary_color": "#FFFFFF", "national_titles": 14, "international_titles": 0},
        {"name": "Audax Italiano",      "country": "Chile",    "continent": "América do Sul", "founded_year": 1910, "primary_color": "#008000", "secondary_color": "#FFFFFF", "national_titles": 4,  "international_titles": 0},
        {"name": "Cobreloa",            "country": "Chile",    "continent": "América do Sul", "founded_year": 1977, "primary_color": "#FF6600", "secondary_color": "#000000", "national_titles": 8,  "international_titles": 0},
        {"name": "Unión Española",      "country": "Chile",    "continent": "América do Sul", "founded_year": 1897, "primary_color": "#FF0000", "secondary_color": "#000000", "national_titles": 4,  "international_titles": 0},
        {"name": "Palestino",           "country": "Chile",    "continent": "América do Sul", "founded_year": 1920, "primary_color": "#009736", "secondary_color": "#CE1126", "national_titles": 3,  "international_titles": 0},
        {"name": "Huachipato",          "country": "Chile",    "continent": "América do Sul", "founded_year": 1947, "primary_color": "#0033A0", "secondary_color": "#FFFFFF", "national_titles": 2,  "international_titles": 0},
    ],
    "Liga BetPlay Dimayor": [
        {"name": "Atlético Nacional",       "country": "Colômbia", "continent": "América do Sul", "founded_year": 1947, "primary_color": "#008000", "secondary_color": "#FFFFFF", "national_titles": 17, "international_titles": 2},
        {"name": "Millonarios",             "country": "Colômbia", "continent": "América do Sul", "founded_year": 1946, "primary_color": "#003DA5", "secondary_color": "#FFFFFF", "national_titles": 16, "international_titles": 0},
        {"name": "América de Cali",         "country": "Colômbia", "continent": "América do Sul", "founded_year": 1927, "primary_color": "#FF0000", "secondary_color": "#FFFFFF", "national_titles": 13, "international_titles": 0},
        {"name": "Independiente Medellín",  "country": "Colômbia", "continent": "América do Sul", "founded_year": 1913, "primary_color": "#FF0000", "secondary_color": "#0000FF", "national_titles": 5,  "international_titles": 0},
        {"name": "Deportivo Cali",          "country": "Colômbia", "continent": "América do Sul", "founded_year": 1912, "primary_color": "#007A33", "secondary_color": "#FFFFFF", "national_titles": 9,  "international_titles": 0},
        {"name": "Junior de Barranquilla",  "country": "Colômbia", "continent": "América do Sul", "founded_year": 1924, "primary_color": "#FF0000", "secondary_color": "#FFD700", "national_titles": 9,  "international_titles": 0},
        {"name": "Santa Fe",                "country": "Colômbia", "continent": "América do Sul", "founded_year": 1941, "primary_color": "#FF0000", "secondary_color": "#FFFFFF", "national_titles": 9,  "international_titles": 0},
        {"name": "Once Caldas",             "country": "Colômbia", "continent": "América do Sul", "founded_year": 1961, "primary_color": "#FFFFFF", "secondary_color": "#000000", "national_titles": 6,  "international_titles": 1},
    ],
    "Primera División de Uruguay": [
        {"name": "Nacional",                  "country": "Uruguai", "continent": "América do Sul", "founded_year": 1899, "primary_color": "#003DA5", "secondary_color": "#FFFFFF", "national_titles": 49, "international_titles": 3},
        {"name": "Peñarol",                   "country": "Uruguai", "continent": "América do Sul", "founded_year": 1891, "primary_color": "#000000", "secondary_color": "#FFD700", "national_titles": 51, "international_titles": 5},
        {"name": "Defensor Sporting",         "country": "Uruguai", "continent": "América do Sul", "founded_year": 1913, "primary_color": "#9400D3", "secondary_color": "#FFFFFF", "national_titles": 7,  "international_titles": 0},
        {"name": "Danubio",                   "country": "Uruguai", "continent": "América do Sul", "founded_year": 1932, "primary_color": "#FF0000", "secondary_color": "#FFFFFF", "national_titles": 6,  "international_titles": 0},
        {"name": "River Plate Uruguay",       "country": "Uruguai", "continent": "América do Sul", "founded_year": 1897, "primary_color": "#FFFFFF", "secondary_color": "#FF0000", "national_titles": 3,  "international_titles": 0},
        {"name": "Montevideo City Torque",    "country": "Uruguai", "continent": "América do Sul", "founded_year": 2015, "primary_color": "#00BFFF", "secondary_color": "#000000", "national_titles": 2,  "international_titles": 0},
    ],
    "LigaPro Ecuador": [
        {"name": "Barcelona SC",                "country": "Equador", "continent": "América do Sul", "founded_year": 1925, "primary_color": "#FFD700", "secondary_color": "#000000", "national_titles": 16, "international_titles": 0},
        {"name": "Liga Deportiva Universitaria", "country": "Equador", "continent": "América do Sul", "founded_year": 1930, "primary_color": "#FF0000", "secondary_color": "#003DA5", "national_titles": 11, "international_titles": 1},
        {"name": "Emelec",                      "country": "Equador", "continent": "América do Sul", "founded_year": 1929, "primary_color": "#003DA5", "secondary_color": "#FFFFFF", "national_titles": 14, "international_titles": 0},
        {"name": "Independiente del Valle",     "country": "Equador", "continent": "América do Sul", "founded_year": 1958, "primary_color": "#FF0000", "secondary_color": "#000000", "national_titles": 3,  "international_titles": 1},
        {"name": "Aucas",                       "country": "Equador", "continent": "América do Sul", "founded_year": 1945, "primary_color": "#FF6600", "secondary_color": "#000000", "national_titles": 2,  "international_titles": 0},
        {"name": "Deportivo Cuenca",            "country": "Equador", "continent": "América do Sul", "founded_year": 1971, "primary_color": "#FF0000", "secondary_color": "#FFFFFF", "national_titles": 1,  "international_titles": 0},
    ],
    "División Profesional Paraguay": [
        {"name": "Olimpia",           "country": "Paraguai", "continent": "América do Sul", "founded_year": 1902, "primary_color": "#000000", "secondary_color": "#FFFFFF", "national_titles": 44, "international_titles": 3},
        {"name": "Cerro Porteño",     "country": "Paraguai", "continent": "América do Sul", "founded_year": 1912, "primary_color": "#003DA5", "secondary_color": "#FF0000", "national_titles": 33, "international_titles": 0},
        {"name": "Guaraní",           "country": "Paraguai", "continent": "América do Sul", "founded_year": 1903, "primary_color": "#000000", "secondary_color": "#FFD700", "national_titles": 12, "international_titles": 0},
        {"name": "Libertad",          "country": "Paraguai", "continent": "América do Sul", "founded_year": 1905, "primary_color": "#000000", "secondary_color": "#FF0000", "national_titles": 22, "international_titles": 0},
        {"name": "Nacional Asunción", "country": "Paraguai", "continent": "América do Sul", "founded_year": 1904, "primary_color": "#003DA5", "secondary_color": "#FFFFFF", "national_titles": 6,  "international_titles": 0},
    ],
    "Liga 1 Peru": [
        {"name": "Alianza Lima",               "country": "Peru", "continent": "América do Sul", "founded_year": 1901, "primary_color": "#000000", "secondary_color": "#003DA5", "national_titles": 24, "international_titles": 0},
        {"name": "Universitario de Deportes",  "country": "Peru", "continent": "América do Sul", "founded_year": 1924, "primary_color": "#8B0000", "secondary_color": "#FFFFFF", "national_titles": 27, "international_titles": 0},
        {"name": "Sporting Cristal",           "country": "Peru", "continent": "América do Sul", "founded_year": 1955, "primary_color": "#003DA5", "secondary_color": "#FFFFFF", "national_titles": 20, "international_titles": 0},
        {"name": "Cienciano",                  "country": "Peru", "continent": "América do Sul", "founded_year": 1901, "primary_color": "#FF0000", "secondary_color": "#FFFFFF", "national_titles": 1,  "international_titles": 1},
        {"name": "Melgar",                     "country": "Peru", "continent": "América do Sul", "founded_year": 1915, "primary_color": "#FF0000", "secondary_color": "#000000", "national_titles": 4,  "international_titles": 0},
    ],
    "Brasileirão Série B": [
        {"name": "Sport Recife",    "country": "Brasil", "continent": "América do Sul", "founded_year": 1905, "primary_color": "#FF0000", "secondary_color": "#000000", "national_titles": 1,  "international_titles": 0},
        {"name": "América MG",      "country": "Brasil", "continent": "América do Sul", "founded_year": 1912, "primary_color": "#008000", "secondary_color": "#000000", "national_titles": 0,  "international_titles": 0},
        {"name": "Guarani",         "country": "Brasil", "continent": "América do Sul", "founded_year": 1911, "primary_color": "#008000", "secondary_color": "#FFFFFF", "national_titles": 1,  "international_titles": 0},
        {"name": "Avaí",            "country": "Brasil", "continent": "América do Sul", "founded_year": 1923, "primary_color": "#003DA5", "secondary_color": "#FFFFFF", "national_titles": 0,  "international_titles": 0},
        {"name": "CRB",             "country": "Brasil", "continent": "América do Sul", "founded_year": 1912, "primary_color": "#FF0000", "secondary_color": "#000000", "national_titles": 0,  "international_titles": 0},
        {"name": "Ponte Preta",     "country": "Brasil", "continent": "América do Sul", "founded_year": 1900, "primary_color": "#000000", "secondary_color": "#FFFFFF", "national_titles": 0,  "international_titles": 0},
        {"name": "Goiás",           "country": "Brasil", "continent": "América do Sul", "founded_year": 1943, "primary_color": "#008000", "secondary_color": "#FFFFFF", "national_titles": 0,  "international_titles": 0},
        {"name": "Ceará",           "country": "Brasil", "continent": "América do Sul", "founded_year": 1914, "primary_color": "#000000", "secondary_color": "#FFFFFF", "national_titles": 0,  "international_titles": 0},
        {"name": "Sampaio Corrêa",  "country": "Brasil", "continent": "América do Sul", "founded_year": 1923, "primary_color": "#003DA5", "secondary_color": "#FF0000", "national_titles": 0,  "international_titles": 0},
        {"name": "Vila Nova",       "country": "Brasil", "continent": "América do Sul", "founded_year": 1919, "primary_color": "#FF6600", "secondary_color": "#000000", "national_titles": 0,  "international_titles": 0},
    ],
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def fetch_existing_league_names() -> dict:
    """Returns {league_name: league_id} for all leagues already in DB."""
    result = supabase.table("leagues").select("id,name").execute()
    return {row["name"]: row["id"] for row in result.data}


def fetch_existing_club_names() -> set:
    """Returns the set of all club names already in DB."""
    result = supabase.table("clubs").select("name").execute()
    return {row["name"] for row in result.data}


def insert_league(league_def: dict) -> str:
    result = (
        supabase.table("leagues")
        .insert(league_def)
        .execute()
    )
    return result.data[0]["id"]


def fetch_all_club_ids() -> list:
    result = supabase.table("clubs").select("id").execute()
    return [row["id"] for row in result.data]


def fetch_existing_challenge_info() -> tuple:
    """Returns (count, last_date_str)."""
    result = supabase.table("daily_challenges").select("date").execute()
    dates = [row["date"] for row in result.data]
    if not dates:
        return 0, None
    return len(dates), max(dates)


def fetch_existing_challenge_dates() -> set:
    result = supabase.table("daily_challenges").select("date").execute()
    return {row["date"] for row in result.data}


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    print("=" * 60)
    print("  Futdle — Adicionar Clubes América do Sul + Série B")
    print("=" * 60)

    # --- Step 0: Diagnose current state ---
    count, last_date = fetch_existing_challenge_info()
    today = date.today()
    end_target = today + timedelta(days=364)  # 365 days inclusive of today

    print(f"\n[Estado atual]")
    print(f"  Desafios no banco : {count}")
    print(f"  Último desafio    : {last_date or 'nenhum'}")
    print(f"  Hoje              : {today.isoformat()}")
    print(f"  Meta (365 dias)   : {end_target.isoformat()}")

    # --- Step 1: Insert leagues ---
    print("\n[1/3] Inserindo ligas...")
    existing_leagues = fetch_existing_league_names()
    league_id_map: dict = {}  # league_name -> uuid

    for league_def in LEAGUES:
        lname = league_def["name"]
        if lname in existing_leagues:
            league_id_map[lname] = existing_leagues[lname]
            print(f"  ~ {lname} (já existe, id={existing_leagues[lname][:8]}...)")
        else:
            new_id = insert_league(league_def)
            league_id_map[lname] = new_id
            print(f"  + {lname} (inserida, id={new_id[:8]}...)")

    # --- Step 2: Insert clubs ---
    print("\n[2/3] Inserindo clubes...")
    existing_clubs = fetch_existing_club_names()
    clubs_inserted = 0
    clubs_skipped = 0

    for league_name, clubs in CLUBS_BY_LEAGUE.items():
        league_id = league_id_map[league_name]
        print(f"\n  Liga: {league_name}")
        for club in clubs:
            if club["name"] in existing_clubs:
                print(f"    ~ {club['name']} (já existe, pulando)")
                clubs_skipped += 1
                continue
            payload = {**club, "league_id": league_id}
            supabase.table("clubs").insert(payload).execute()
            print(f"    + {club['name']}")
            clubs_inserted += 1

    print(f"\n  Clubes inseridos : {clubs_inserted}")
    print(f"  Clubes pulados   : {clubs_skipped}")

    # --- Step 3: Extend daily challenges to 365 days from today ---
    print("\n[3/3] Estendendo desafios diários para 365 dias a partir de hoje...")
    club_ids = fetch_all_club_ids()
    if not club_ids:
        print("  ERRO: Nenhum clube encontrado.")
        return

    existing_dates = fetch_existing_challenge_dates()
    challenges_inserted = 0

    for offset in range(365):
        challenge_date = today + timedelta(days=offset)
        date_str = challenge_date.isoformat()
        if date_str in existing_dates:
            continue
        club_id = random.choice(club_ids)
        supabase.table("daily_challenges").insert({
            "date": date_str,
            "club_id": club_id,
            "mode": "classic",
        }).execute()
        print(f"  + {date_str}")
        challenges_inserted += 1

    # --- Summary ---
    final_count, final_last = fetch_existing_challenge_info()
    print(f"\n{'=' * 60}")
    print("  RESUMO FINAL")
    print(f"{'=' * 60}")
    print(f"  Ligas inseridas          : {sum(1 for l in LEAGUES if l['name'] not in existing_leagues)}")
    print(f"  Clubes inseridos         : {clubs_inserted}")
    print(f"  Desafios novos criados   : {challenges_inserted}")
    print(f"  Total desafios no banco  : {final_count}")
    print(f"  Último desafio           : {final_last}")
    print(f"{'=' * 60}")
    print("  Concluído!")


if __name__ == "__main__":
    main()
