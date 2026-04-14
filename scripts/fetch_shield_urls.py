"""
Busca URLs dos escudos na TheSportsDB e atualiza shield_url no Supabase.
Uso: python fetch_shield_urls.py
"""
import os
import time
import requests
from dotenv import load_dotenv
from supabase import create_client, Client

load_dotenv()

SUPABASE_URL = os.environ["SUPABASE_URL"]
SUPABASE_KEY = os.environ["SUPABASE_SERVICE_KEY"]
SPORTSDB_BASE = "https://www.thesportsdb.com/api/v1/json/3"

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)


def search_team(name: str) -> str | None:
    """Busca o badge URL de um time pelo nome na TheSportsDB."""
    url = f"{SPORTSDB_BASE}/searchteams.php?t={requests.utils.quote(name)}"
    try:
        r = requests.get(url, timeout=10)
        r.raise_for_status()
        teams = r.json().get("teams") or []
        if teams:
            badge = teams[0].get("strTeamBadge") or teams[0].get("strBadge")
            return badge if badge else None
    except Exception as e:
        print(f"  Erro buscando '{name}': {e}")
    return None


def main():
    # Busca todos os clubes sem shield_url
    result = supabase.table("clubs").select("id, name, alt_name").execute()
    clubs = result.data

    total = len(clubs)
    updated = 0
    not_found = []

    print(f"Total de clubes: {total}\n")

    for i, club in enumerate(clubs, 1):
        club_id = club["id"]
        name = club["name"]
        alt = club.get("alt_name") or ""

        print(f"[{i}/{total}] {name}", end=" ... ")

        badge_url = search_team(name)

        # Tenta pelo alt_name se não achou
        if not badge_url and alt:
            badge_url = search_team(alt)

        if badge_url:
            supabase.table("clubs").update({"shield_url": badge_url}).eq("id", club_id).execute()
            print(f"OK")
            updated += 1
        else:
            print(f"NAO ENCONTRADO")
            not_found.append(name)

        # Respeita rate limit da API gratuita
        time.sleep(0.5)

    print(f"\n✅ Atualizados: {updated}/{total}")
    if not_found:
        print(f"\n❌ Não encontrados ({len(not_found)}):")
        for n in not_found:
            print(f"  - {n}")


if __name__ == "__main__":
    main()
