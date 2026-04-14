"""
Importa ligas e clubes da TheSportsDB API e insere no Supabase.
Uso: python seed_clubs.py
"""
import os
import requests
from dotenv import load_dotenv
from supabase import create_client, Client
from clubs_data import LEAGUE_MAP, LEAGUE_IDS, CLUBS_OVERRIDES

load_dotenv()

SUPABASE_URL = os.environ["SUPABASE_URL"]
SUPABASE_KEY = os.environ["SUPABASE_SERVICE_KEY"]
SPORTSDB_BASE = "https://www.thesportsdb.com/api/v1/json/3"

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)


def fetch_teams_from_api(league_api_name: str) -> list:
    url = f"{SPORTSDB_BASE}/search_all_teams.php?l={league_api_name.replace(' ', '+')}"
    response = requests.get(url, timeout=10)
    response.raise_for_status()
    data = response.json()
    return data.get("teams") or []


def insert_league(league_api_name: str) -> str:
    """Insere a liga no banco e retorna o UUID gerado."""
    league_info = LEAGUE_MAP[league_api_name]
    result = (
        supabase.table("leagues")
        .insert({
            "name": league_info["name"],
            "country": league_info["country"],
            "continent": league_info["continent"],
        })
        .execute()
    )
    return result.data[0]["id"]


def insert_club(team: dict, league_id: str, league_api_name: str) -> None:
    name = team.get("strTeam", "")
    override = CLUBS_OVERRIDES.get(name, {})
    league_info = LEAGUE_MAP[league_api_name]

    club_data = {
        "name": name,
        "alt_name": override.get("alt_name"),
        "country": team.get("strCountry") or league_info["country"],
        "continent": league_info["continent"],
        "league_id": league_id,
        "founded_year": int(team["intFormedYear"]) if team.get("intFormedYear") else None,
        "primary_color": override.get("primary_color", "#000000"),
        "secondary_color": override.get("secondary_color", "#ffffff"),
        "national_titles": override.get("national_titles", 0),
        "international_titles": override.get("international_titles", 0),
        "shield_url": team.get("strTeamBadge"),
    }

    supabase.table("clubs").insert(club_data).execute()
    print(f"  + {name}")


def insert_manual_clubs(manual_clubs: list) -> None:
    """Insere times manualmente (ligas sem dados na API gratuita)."""
    for club in manual_clubs:
        supabase.table("clubs").insert(club).execute()
        print(f"  + {club['name']} (manual)")


def main():
    print("=== Futdle Seed: Ligas e Clubes ===\n")

    # Ligar com dados na API gratuita
    api_leagues = [k for k in LEAGUE_IDS if k not in ("Argentine Primera Division", "Mexican Primera Division")]

    for league_api_name in api_leagues:
        league_display = LEAGUE_MAP[league_api_name]["name"]
        print(f"Processando {league_display}...")

        league_db_id = insert_league(league_api_name)
        teams = fetch_teams_from_api(league_api_name)

        if not teams:
            print(f"  Nenhum time encontrado para {league_display}\n")
            continue

        for team in teams:
            insert_club(team, league_db_id, league_api_name)

        print(f"  -> {len(teams)} times inseridos\n")

    # Argentina — inserção manual dos principais clubes
    print("Processando Liga Profesional Argentina (manual)...")
    arg_league = insert_league("Argentine Primera Division")
    insert_manual_clubs([
        {"name": "Boca Juniors", "country": "Argentina", "continent": "América do Sul", "league_id": arg_league, "founded_year": 1905, "primary_color": "#003087", "secondary_color": "#f5d130", "national_titles": 35, "international_titles": 6},
        {"name": "River Plate", "country": "Argentina", "continent": "América do Sul", "league_id": arg_league, "founded_year": 1901, "primary_color": "#eb0029", "secondary_color": "#ffffff", "national_titles": 38, "international_titles": 4},
        {"name": "Racing Club", "country": "Argentina", "continent": "América do Sul", "league_id": arg_league, "founded_year": 1903, "primary_color": "#00b0f0", "secondary_color": "#ffffff", "national_titles": 18, "international_titles": 1},
        {"name": "Independiente", "country": "Argentina", "continent": "América do Sul", "league_id": arg_league, "founded_year": 1905, "primary_color": "#cc0000", "secondary_color": "#ffffff", "national_titles": 16, "international_titles": 7},
        {"name": "San Lorenzo", "country": "Argentina", "continent": "América do Sul", "league_id": arg_league, "founded_year": 1908, "primary_color": "#c41a2a", "secondary_color": "#000080", "national_titles": 15, "international_titles": 1},
        {"name": "Estudiantes de La Plata", "country": "Argentina", "continent": "América do Sul", "league_id": arg_league, "founded_year": 1905, "primary_color": "#cc0000", "secondary_color": "#ffffff", "national_titles": 4, "international_titles": 4},
        {"name": "Velez Sarsfield", "country": "Argentina", "continent": "América do Sul", "league_id": arg_league, "founded_year": 1910, "primary_color": "#ffffff", "secondary_color": "#003087", "national_titles": 9, "international_titles": 4},
        {"name": "Huracan", "country": "Argentina", "continent": "América do Sul", "league_id": arg_league, "founded_year": 1908, "primary_color": "#cc3300", "secondary_color": "#ffffff", "national_titles": 1, "international_titles": 0},
    ])
    print("  -> 8 times inseridos\n")

    # México — inserção manual dos principais clubes
    print("Processando Liga MX (manual)...")
    mex_league = insert_league("Mexican Primera Division")
    insert_manual_clubs([
        {"name": "Club America", "country": "México", "continent": "América do Norte", "league_id": mex_league, "founded_year": 1916, "primary_color": "#f5d130", "secondary_color": "#003087", "national_titles": 14, "international_titles": 0, "alt_name": "Las Águilas"},
        {"name": "Chivas Guadalajara", "country": "México", "continent": "América do Norte", "league_id": mex_league, "founded_year": 1906, "primary_color": "#cc0000", "secondary_color": "#ffffff", "national_titles": 12, "international_titles": 0, "alt_name": "Chivas"},
        {"name": "Cruz Azul", "country": "México", "continent": "América do Norte", "league_id": mex_league, "founded_year": 1927, "primary_color": "#003087", "secondary_color": "#ffffff", "national_titles": 9, "international_titles": 0},
        {"name": "Pumas UNAM", "country": "México", "continent": "América do Norte", "league_id": mex_league, "founded_year": 1954, "primary_color": "#003087", "secondary_color": "#f5d130", "national_titles": 7, "international_titles": 0},
        {"name": "Tigres UANL", "country": "México", "continent": "América do Norte", "league_id": mex_league, "founded_year": 1960, "primary_color": "#f5d130", "secondary_color": "#003087", "national_titles": 8, "international_titles": 0},
        {"name": "Monterrey", "country": "México", "continent": "América do Norte", "league_id": mex_league, "founded_year": 1945, "primary_color": "#003087", "secondary_color": "#cc0000", "national_titles": 5, "international_titles": 0},
        {"name": "Santos Laguna", "country": "México", "continent": "América do Norte", "league_id": mex_league, "founded_year": 1983, "primary_color": "#006437", "secondary_color": "#ffffff", "national_titles": 6, "international_titles": 0},
        {"name": "Toluca FC", "country": "México", "continent": "América do Norte", "league_id": mex_league, "founded_year": 1917, "primary_color": "#cc0000", "secondary_color": "#ffffff", "national_titles": 10, "international_titles": 0},
    ])
    print("  -> 8 times inseridos\n")

    print("Seed concluido!")


if __name__ == "__main__":
    main()
