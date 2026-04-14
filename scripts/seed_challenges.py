"""
Cria desafios diários para os próximos N dias escolhendo clubes aleatoriamente.
Uso: python seed_challenges.py --days 30
"""
import os
import random
import argparse
from datetime import date, timedelta
from dotenv import load_dotenv
from supabase import create_client, Client

load_dotenv()

SUPABASE_URL = os.environ["SUPABASE_URL"]
SUPABASE_KEY = os.environ["SUPABASE_SERVICE_KEY"]

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)


def fetch_all_club_ids() -> list:
    result = supabase.table("clubs").select("id").execute()
    return [row["id"] for row in result.data]


def fetch_existing_challenge_dates() -> set:
    result = supabase.table("daily_challenges").select("date").execute()
    return {row["date"] for row in result.data}


def create_challenges(days: int) -> None:
    club_ids = fetch_all_club_ids()
    if not club_ids:
        print("Nenhum clube encontrado. Execute seed_clubs.py primeiro.")
        return

    existing_dates = fetch_existing_challenge_dates()
    today = date.today()
    inserted = 0

    for i in range(days):
        challenge_date = today + timedelta(days=i)
        date_str = challenge_date.isoformat()

        if date_str in existing_dates:
            print(f"  Pulando {date_str} (ja existe)")
            continue

        club_id = random.choice(club_ids)
        supabase.table("daily_challenges").insert({
            "date": date_str,
            "club_id": club_id,
            "mode": "classic",
        }).execute()

        inserted += 1
        print(f"  + {date_str}")

    print(f"\n{inserted} desafios criados.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--days", type=int, default=30, help="Quantos dias gerar (padrao: 30)")
    args = parser.parse_args()
    create_challenges(args.days)
