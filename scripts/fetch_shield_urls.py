"""
Busca URLs dos escudos e atualiza shield_url no Supabase.

APIs usadas (em ordem de prioridade):
  1. TheSportsDB (gratuita, sem chave)
  2. football-data.org (gratuita, requer token — registre em football-data.org)
  3. Mapa manual para times que as APIs não cobrem

Para usar a football-data.org, crie uma conta gratuita em:
  https://www.football-data.org/client/register
E adicione no .env:  FOOTBALL_DATA_TOKEN=seu_token_aqui

Uso: py fetch_shield_urls.py
"""
import os
import time
import requests
from dotenv import load_dotenv
from supabase import create_client, Client

load_dotenv()

SUPABASE_URL = os.environ["SUPABASE_URL"]
SUPABASE_KEY = os.environ["SUPABASE_SERVICE_KEY"]
FOOTBALL_DATA_TOKEN = os.environ.get("FOOTBALL_DATA_TOKEN", "")

SPORTSDB_BASE = "https://www.thesportsdb.com/api/v1/json/3"
FOOTBALL_DATA_BASE = "https://api.football-data.org/v4"

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# ── Mapa manual para times problemáticos ────────────────────────────────────
# Adicione aqui times que ambas as APIs não encontram.
# Use URLs diretas de escudos (Wikimedia, site oficial, etc.)
MANUAL_SHIELDS: dict[str, str] = {
    "Club America":             "https://upload.wikimedia.org/wikipedia/en/a/a4/Club_Am%C3%A9rica_crest.svg",
    "Pumas UNAM":               "https://upload.wikimedia.org/wikipedia/en/b/b6/Pumas_UNAM_shield.svg",
    "Tigres UANL":              "https://upload.wikimedia.org/wikipedia/en/0/08/Tigres_UANL_logo.svg",
    "Toluca FC":                "https://upload.wikimedia.org/wikipedia/en/a/a6/Toluca_F%C3%BAtbol_Club_logo.svg",
    "Peñarol":                  "https://upload.wikimedia.org/wikipedia/en/5/5b/Club_Atletico_Penarol.svg",
    "Nacional":                 "https://upload.wikimedia.org/wikipedia/en/5/54/Club_Nacional_de_Football_logo.svg",
    "Olimpia":                  "https://upload.wikimedia.org/wikipedia/en/a/a6/Club_Olimpia.svg",
    "Cerro Porteño":            "https://upload.wikimedia.org/wikipedia/en/0/01/CerroPorte%C3%B1o.svg",
    "Alianza Lima":             "https://upload.wikimedia.org/wikipedia/en/3/3d/Alianza_Lima.svg",
    "Universitario de Deportes":"https://upload.wikimedia.org/wikipedia/en/6/6e/Universitario_de_Deportes_logo.svg",
    "Barcelona SC":             "https://upload.wikimedia.org/wikipedia/en/f/fb/Barcelona_SC_%28Ecuador%29_crest.svg",
    "Emelec":                   "https://upload.wikimedia.org/wikipedia/en/8/8f/Club_Sport_Emelec.svg",
    "Atlético Nacional":        "https://upload.wikimedia.org/wikipedia/en/5/57/Atletico_Nacional.svg",
    "Millonarios":              "https://upload.wikimedia.org/wikipedia/en/3/35/Millonarios_FC_logo.svg",
    "Junior de Barranquilla":   "https://upload.wikimedia.org/wikipedia/en/4/4d/Junior_de_Barranquilla.svg",
    "Colo-Colo":                "https://upload.wikimedia.org/wikipedia/en/8/8c/Colo-colo_nuevo_escudo.svg",
    "Universidad de Chile":     "https://upload.wikimedia.org/wikipedia/en/2/27/Club_Universidad_de_Chile_logo.svg",
    "Universidad Católica":     "https://upload.wikimedia.org/wikipedia/en/3/37/Club_Deportivo_Universidad_Cat%C3%B3lica.svg",
    "Chivas Guadalajara":       "https://upload.wikimedia.org/wikipedia/en/5/59/CD_Guadalajara_logo.svg",
}


DELAY_NORMAL = 2.0    # segundos entre requisições normais
DELAY_BACKOFF = 60.0  # segundos de espera ao receber 429


def _get_with_backoff(url: str, headers: dict = {}) -> requests.Response | None:
    """GET com retry automático em caso de 429."""
    while True:
        try:
            r = requests.get(url, headers=headers, timeout=10)
            if r.status_code == 429:
                print(f"\n  ⚠ Rate limit. Aguardando {int(DELAY_BACKOFF)}s...", end="", flush=True)
                time.sleep(DELAY_BACKOFF)
                print(" Continuando.")
                continue
            return r
        except Exception as e:
            print(f"  Erro de conexão: {e}")
            return None


def search_sportsdb(name: str) -> str | None:
    """Busca badge na TheSportsDB."""
    url = f"{SPORTSDB_BASE}/searchteams.php?t={requests.utils.quote(name)}"
    r = _get_with_backoff(url)
    if not r or not r.ok:
        return None
    teams = r.json().get("teams") or []
    if teams:
        return teams[0].get("strTeamBadge") or teams[0].get("strBadge")
    return None


def search_football_data(name: str) -> str | None:
    """Busca badge na football-data.org (requer token no .env)."""
    if not FOOTBALL_DATA_TOKEN:
        return None
    url = f"{FOOTBALL_DATA_BASE}/teams?name={requests.utils.quote(name)}"
    r = _get_with_backoff(url, headers={"X-Auth-Token": FOOTBALL_DATA_TOKEN})
    if not r or not r.ok:
        return None
    teams = r.json().get("teams") or []
    if teams:
        return teams[0].get("crest")
    return None


def main():
    # Busca apenas clubes SEM shield_url (pula os que já têm)
    result = supabase.table("clubs").select("id, name, alt_name, shield_url").execute()
    all_clubs = result.data
    clubs = [c for c in all_clubs if not c.get("shield_url")]

    total_db = len(all_clubs)
    total = len(clubs)
    skipped = total_db - total

    print(f"Total no banco: {total_db} | Já com escudo: {skipped} | Para buscar: {total}\n")

    updated = 0
    not_found = []

    for i, club in enumerate(clubs, 1):
        club_id = club["id"]
        name = club["name"]
        alt = club.get("alt_name") or ""

        print(f"[{i}/{total}] {name}", end=" ... ", flush=True)

        # 1) Mapa manual
        badge_url = MANUAL_SHIELDS.get(name)
        if badge_url:
            print("MANUAL ", end="", flush=True)

        # 2) TheSportsDB
        if not badge_url:
            badge_url = search_sportsdb(name)
            time.sleep(DELAY_NORMAL)

        # 3) TheSportsDB com alt_name
        if not badge_url and alt:
            badge_url = search_sportsdb(alt)
            time.sleep(DELAY_NORMAL)

        # 4) football-data.org
        if not badge_url:
            badge_url = search_football_data(name)
            if badge_url:
                time.sleep(DELAY_NORMAL)

        if badge_url:
            supabase.table("clubs").update({"shield_url": badge_url}).eq("id", club_id).execute()
            print("OK")
            updated += 1
        else:
            print("NAO ENCONTRADO")
            not_found.append(name)

    print(f"\n✅ Atualizados: {updated}/{total}")
    if not_found:
        print(f"\n❌ Não encontrados ({len(not_found)}):")
        for n in not_found:
            print(f"  - {n}")


if __name__ == "__main__":
    main()
