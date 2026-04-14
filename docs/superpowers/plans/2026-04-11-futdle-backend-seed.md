# Futdle — Plano 1: Backend + Seed de Dados

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Configurar o Supabase (schema, RLS, Storage) e popular o banco com ~160 clubes de 8 ligas via script Python, além de criar os desafios diários dos primeiros 30 dias.

**Architecture:** Supabase como backend completo (PostgreSQL + Auth anônimo + Storage para escudos). Script Python consome TheSportsDB API gratuita para importar dados base, faz curadoria e insere no Supabase via SDK.

**Tech Stack:** Supabase (PostgreSQL, Auth, Storage), Python 3, supabase-py, requests, Pillow (resize de escudos)

---

## Arquivos que serão criados

```
Futdle/
  scripts/
    seed_clubs.py          -- importa ligas + clubes da TheSportsDB e insere no Supabase
    seed_challenges.py     -- cria desafios diários para os próximos 30 dias
    clubs_data.py          -- dados curados manualmente (cores, títulos) por clube
    requirements.txt       -- dependências Python do seed
  supabase/
    migrations/
      001_initial_schema.sql   -- tabelas completas
      002_rls_policies.sql     -- Row Level Security
```

---

## Task 1: Criar projeto no Supabase e obter credenciais

**Files:**
- Nenhum arquivo criado — configuração via dashboard web

- [ ] **Step 1: Acessar o Supabase**

  Abra [supabase.com](https://supabase.com), faça login e clique em **New Project**.

- [ ] **Step 2: Preencher dados do projeto**

  - Name: `futdle`
  - Database Password: escolha uma senha forte e **anote em lugar seguro**
  - Region: `South America (São Paulo)` — menor latência para usuários BR
  - Clique em **Create new project** e aguarde ~2 minutos

- [ ] **Step 3: Coletar credenciais**

  No painel do projeto, acesse **Settings → API**. Anote:
  - `Project URL` → ex: `https://xyzxyzxyz.supabase.co`
  - `anon public` key → chave longa começando com `eyJ...`
  - `service_role` key → chave secreta (só para scripts server-side)

- [ ] **Step 4: Criar arquivo `.env` na pasta scripts/**

  Crie `Futdle/scripts/.env` com o conteúdo:
  ```
  SUPABASE_URL=https://SEU_PROJETO.supabase.co
  SUPABASE_SERVICE_KEY=sua_service_role_key_aqui
  ```

  > ⚠️ Nunca commite esse arquivo. Adicione ao `.gitignore`.

- [ ] **Step 5: Criar `.gitignore` na raiz do projeto**

  Crie `Futdle/.gitignore`:
  ```
  scripts/.env
  __pycache__/
  *.pyc
  .dart_tool/
  build/
  .flutter-plugins
  .flutter-plugins-dependencies
  ```

- [ ] **Step 6: Commit**

  ```bash
  cd "C:/Users/mathe/OneDrive/Desktop/Futdle"
  git init
  git add .gitignore docs/
  git commit -m "chore: init repo with architecture docs and gitignore"
  ```

---

## Task 2: Criar schema do banco de dados

**Files:**
- Create: `supabase/migrations/001_initial_schema.sql`

- [ ] **Step 1: Criar o arquivo SQL**

  Crie `Futdle/supabase/migrations/001_initial_schema.sql`:

  ```sql
  -- Extensão para UUID
  create extension if not exists "pgcrypto";

  -- Ligas
  create table leagues (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    country text not null,
    continent text not null,
    created_at timestamptz default now()
  );

  -- Clubes
  create table clubs (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    alt_name text,
    country text not null,
    continent text not null,
    league_id uuid references leagues(id) on delete set null,
    founded_year int,
    primary_color text not null default '#000000',
    secondary_color text not null default '#ffffff',
    national_titles int not null default 0,
    international_titles int not null default 0,
    shield_url text,
    created_at timestamptz default now()
  );

  -- Desafios diários
  create table daily_challenges (
    id uuid primary key default gen_random_uuid(),
    date date unique not null,
    club_id uuid references clubs(id) on delete cascade,
    mode text not null default 'classic',
    created_at timestamptz default now()
  );

  -- Progresso do jogador por desafio
  create table user_progress (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references auth.users(id) on delete cascade,
    challenge_id uuid references daily_challenges(id) on delete cascade,
    attempts jsonb not null default '[]',
    solved bool not null default false,
    finished_at timestamptz,
    unique (user_id, challenge_id)
  );

  -- Energia do jogador
  create table user_energy (
    user_id uuid primary key references auth.users(id) on delete cascade,
    current_energy int not null default 5,
    last_regen_at timestamptz not null default now(),
    constraint energy_max check (current_energy >= 0 and current_energy <= 5)
  );

  -- Índices de busca
  create index clubs_name_idx on clubs using gin (to_tsvector('simple', name));
  create index clubs_league_idx on clubs (league_id);
  create index daily_challenges_date_idx on daily_challenges (date);
  create index user_progress_user_idx on user_progress (user_id);
  ```

- [ ] **Step 2: Executar no Supabase**

  No dashboard Supabase: **SQL Editor → New query**.
  Cole o conteúdo do arquivo e clique em **Run**.

  Esperado: mensagem `Success. No rows returned.`

- [ ] **Step 3: Verificar tabelas criadas**

  No dashboard: **Table Editor**. Você deve ver as tabelas:
  `leagues`, `clubs`, `daily_challenges`, `user_progress`, `user_energy`

- [ ] **Step 4: Commit**

  ```bash
  git add supabase/
  git commit -m "feat: add initial database schema"
  ```

---

## Task 3: Configurar Row Level Security (RLS)

**Files:**
- Create: `supabase/migrations/002_rls_policies.sql`

- [ ] **Step 1: Criar o arquivo de políticas**

  Crie `Futdle/supabase/migrations/002_rls_policies.sql`:

  ```sql
  -- Habilitar RLS em todas as tabelas
  alter table leagues enable row level security;
  alter table clubs enable row level security;
  alter table daily_challenges enable row level security;
  alter table user_progress enable row level security;
  alter table user_energy enable row level security;

  -- leagues: leitura pública
  create policy "leagues_read_public"
    on leagues for select
    using (true);

  -- clubs: leitura pública
  create policy "clubs_read_public"
    on clubs for select
    using (true);

  -- daily_challenges: leitura pública
  create policy "daily_challenges_read_public"
    on daily_challenges for select
    using (true);

  -- user_progress: cada usuário vê e edita só os próprios dados
  create policy "user_progress_select_own"
    on user_progress for select
    using (auth.uid() = user_id);

  create policy "user_progress_insert_own"
    on user_progress for insert
    with check (auth.uid() = user_id);

  create policy "user_progress_update_own"
    on user_progress for update
    using (auth.uid() = user_id);

  -- user_energy: cada usuário vê e edita só a própria energia
  create policy "user_energy_select_own"
    on user_energy for select
    using (auth.uid() = user_id);

  create policy "user_energy_insert_own"
    on user_energy for insert
    with check (auth.uid() = user_id);

  create policy "user_energy_update_own"
    on user_energy for update
    using (auth.uid() = user_id);
  ```

- [ ] **Step 2: Executar no SQL Editor do Supabase**

  Cole o conteúdo e clique **Run**.
  Esperado: `Success. No rows returned.`

- [ ] **Step 3: Configurar Auth anônimo**

  No dashboard: **Authentication → Providers → Anonymous Sign Ins** → habilite a opção.

- [ ] **Step 4: Commit**

  ```bash
  git add supabase/migrations/002_rls_policies.sql
  git commit -m "feat: add RLS policies and enable anonymous auth"
  ```

---

## Task 4: Criar Storage bucket para escudos

**Files:**
- Nenhum arquivo criado — configuração via dashboard

- [ ] **Step 1: Criar bucket**

  No dashboard Supabase: **Storage → New bucket**
  - Name: `shields`
  - Public bucket: **SIM** (escudos são imagens públicas)
  - Clique em **Save**

- [ ] **Step 2: Configurar política de leitura pública via SQL**

  No SQL Editor:
  ```sql
  create policy "shields_public_read"
    on storage.objects for select
    using (bucket_id = 'shields');
  ```

  Clique em **Run**. Esperado: `Success.`

---

## Task 5: Configurar ambiente Python e dependências

**Files:**
- Create: `scripts/requirements.txt`

- [ ] **Step 1: Criar requirements.txt**

  Crie `Futdle/scripts/requirements.txt`:
  ```
  supabase==2.5.0
  requests==2.31.0
  python-dotenv==1.0.1
  Pillow==10.3.0
  ```

- [ ] **Step 2: Instalar dependências**

  ```bash
  cd "C:/Users/mathe/OneDrive/Desktop/Futdle/scripts"
  python -m pip install -r requirements.txt
  ```

  Esperado: `Successfully installed supabase-2.5.0 ...`

- [ ] **Step 3: Commit**

  ```bash
  git add scripts/requirements.txt
  git commit -m "chore: add Python seed dependencies"
  ```

---

## Task 6: Criar dados curados dos clubes

**Files:**
- Create: `scripts/clubs_data.py`

Este arquivo contém as correções manuais de cores e títulos que a TheSportsDB API não fornece com precisão.

- [ ] **Step 1: Criar clubs_data.py**

  Crie `Futdle/scripts/clubs_data.py`:

  ```python
  # Mapeamento manual: nome do clube (TheSportsDB) -> dados curados
  # Formato: { "nome_exato_api": { "primary_color": "#hex", "secondary_color": "#hex",
  #             "national_titles": int, "international_titles": int, "alt_name": "apelido" } }

  CLUBS_OVERRIDES = {
      # Brasil
      "Flamengo": {
          "primary_color": "#e31d1a",
          "secondary_color": "#000000",
          "national_titles": 9,
          "international_titles": 3,
          "alt_name": "Mengão",
      },
      "Palmeiras": {
          "primary_color": "#006437",
          "secondary_color": "#ffffff",
          "national_titles": 12,
          "international_titles": 3,
          "alt_name": "Verdão",
      },
      "Corinthians": {
          "primary_color": "#000000",
          "secondary_color": "#ffffff",
          "national_titles": 7,
          "international_titles": 2,
          "alt_name": "Timão",
      },
      "São Paulo FC": {
          "primary_color": "#ff0000",
          "secondary_color": "#000000",
          "national_titles": 6,
          "international_titles": 3,
          "alt_name": "Tricolor",
      },
      "Santos FC": {
          "primary_color": "#000000",
          "secondary_color": "#ffffff",
          "national_titles": 8,
          "international_titles": 2,
          "alt_name": "Peixe",
      },
      "Fluminense FC": {
          "primary_color": "#720000",
          "secondary_color": "#6ca044",
          "national_titles": 4,
          "international_titles": 1,
          "alt_name": "Flu",
      },
      "Atletico Mineiro": {
          "primary_color": "#000000",
          "secondary_color": "#ffffff",
          "national_titles": 3,
          "international_titles": 2,
          "alt_name": "Galo",
      },
      "Gremio": {
          "primary_color": "#0041a0",
          "secondary_color": "#000000",
          "national_titles": 2,
          "international_titles": 3,
          "alt_name": "Tricolor Gaúcho",
      },
      "Internacional": {
          "primary_color": "#e31d1a",
          "secondary_color": "#ffffff",
          "national_titles": 3,
          "international_titles": 2,
          "alt_name": "Colorado",
      },
      "Cruzeiro EC": {
          "primary_color": "#003087",
          "secondary_color": "#ffffff",
          "national_titles": 3,
          "international_titles": 2,
          "alt_name": "Raposa",
      },
      # Inglaterra
      "Manchester City": {
          "primary_color": "#6cabdd",
          "secondary_color": "#ffffff",
          "national_titles": 10,
          "international_titles": 1,
      },
      "Liverpool FC": {
          "primary_color": "#c8102e",
          "secondary_color": "#ffffff",
          "national_titles": 19,
          "international_titles": 6,
      },
      "Arsenal": {
          "primary_color": "#ef0107",
          "secondary_color": "#ffffff",
          "national_titles": 13,
          "international_titles": 0,
      },
      "Chelsea FC": {
          "primary_color": "#034694",
          "secondary_color": "#ffffff",
          "national_titles": 6,
          "international_titles": 2,
      },
      "Manchester United": {
          "primary_color": "#da291c",
          "secondary_color": "#000000",
          "national_titles": 20,
          "international_titles": 3,
      },
      "Tottenham Hotspur": {
          "primary_color": "#132257",
          "secondary_color": "#ffffff",
          "national_titles": 2,
          "international_titles": 0,
      },
      # Espanha
      "Real Madrid CF": {
          "primary_color": "#febe10",
          "secondary_color": "#ffffff",
          "national_titles": 35,
          "international_titles": 14,
      },
      "FC Barcelona": {
          "primary_color": "#004d98",
          "secondary_color": "#a50044",
          "national_titles": 27,
          "international_titles": 5,
      },
      "Atletico Madrid": {
          "primary_color": "#cb3524",
          "secondary_color": "#ffffff",
          "national_titles": 11,
          "international_titles": 3,
      },
      "Sevilla FC": {
          "primary_color": "#ffffff",
          "secondary_color": "#d91a21",
          "national_titles": 1,
          "international_titles": 7,
      },
      # Alemanha
      "Bayern Munich": {
          "primary_color": "#dc052d",
          "secondary_color": "#ffffff",
          "national_titles": 32,
          "international_titles": 6,
      },
      "Borussia Dortmund": {
          "primary_color": "#fde100",
          "secondary_color": "#000000",
          "national_titles": 8,
          "international_titles": 1,
      },
      # Itália
      "Juventus FC": {
          "primary_color": "#000000",
          "secondary_color": "#ffffff",
          "national_titles": 36,
          "international_titles": 2,
      },
      "AC Milan": {
          "primary_color": "#fb090b",
          "secondary_color": "#000000",
          "national_titles": 19,
          "international_titles": 7,
      },
      "Inter Milan": {
          "primary_color": "#0068a8",
          "secondary_color": "#000000",
          "national_titles": 19,
          "international_titles": 3,
      },
      "AS Roma": {
          "primary_color": "#8e1f2f",
          "secondary_color": "#f5c518",
          "national_titles": 3,
          "international_titles": 0,
      },
      "SSC Napoli": {
          "primary_color": "#12a0c3",
          "secondary_color": "#ffffff",
          "national_titles": 3,
          "international_titles": 0,
      },
      # França
      "Paris Saint-Germain FC": {
          "primary_color": "#003370",
          "secondary_color": "#e30613",
          "national_titles": 12,
          "international_titles": 0,
          "alt_name": "PSG",
      },
      "Olympique de Marseille": {
          "primary_color": "#009cde",
          "secondary_color": "#ffffff",
          "national_titles": 9,
          "international_titles": 1,
          "alt_name": "OM",
      },
      # Argentina
      "Boca Juniors": {
          "primary_color": "#003087",
          "secondary_color": "#f5d130",
          "national_titles": 35,
          "international_titles": 6,
      },
      "River Plate": {
          "primary_color": "#eb0029",
          "secondary_color": "#ffffff",
          "national_titles": 38,
          "international_titles": 4,
      },
  }

  # Mapeamento de liga TheSportsDB → nome padronizado e continente
  LEAGUE_MAP = {
      "English Premier League": {
          "name": "Premier League",
          "country": "Inglaterra",
          "continent": "Europa",
      },
      "Spanish La Liga": {
          "name": "La Liga",
          "country": "Espanha",
          "continent": "Europa",
      },
      "German Bundesliga": {
          "name": "Bundesliga",
          "country": "Alemanha",
          "continent": "Europa",
      },
      "Italian Serie A": {
          "name": "Serie A",
          "country": "Itália",
          "continent": "Europa",
      },
      "French Ligue 1": {
          "name": "Ligue 1",
          "country": "França",
          "continent": "Europa",
      },
      "Brazilian Série A": {
          "name": "Brasileirão Série A",
          "country": "Brasil",
          "continent": "América do Sul",
      },
      "Argentine Primera Division": {
          "name": "Liga Profesional Argentina",
          "country": "Argentina",
          "continent": "América do Sul",
      },
      "Mexican Primera Division": {
          "name": "Liga MX",
          "country": "México",
          "continent": "América do Norte",
      },
  }

  # IDs das ligas na TheSportsDB API
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
  ```

- [ ] **Step 2: Commit**

  ```bash
  git add scripts/clubs_data.py
  git commit -m "feat: add curated clubs color and titles data"
  ```

---

## Task 7: Script de seed de ligas e clubes

**Files:**
- Create: `scripts/seed_clubs.py`

- [ ] **Step 1: Criar seed_clubs.py**

  Crie `Futdle/scripts/seed_clubs.py`:

  ```python
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


  def fetch_teams_from_api(league_id: str) -> list[dict]:
      url = f"{SPORTSDB_BASE}/lookup_all_teams.php?id={league_id}"
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
      print(f"  ✓ {name}")


  def main():
      print("=== Futdle Seed: Ligas e Clubes ===\n")

      for league_api_name, league_id_str in LEAGUE_IDS.items():
          league_display = LEAGUE_MAP[league_api_name]["name"]
          print(f"Processando {league_display}...")

          league_db_id = insert_league(league_api_name)
          teams = fetch_teams_from_api(league_id_str)

          if not teams:
              print(f"  ⚠ Nenhum time encontrado para {league_display}")
              continue

          for team in teams:
              insert_club(team, league_db_id, league_api_name)

          print(f"  → {len(teams)} times inseridos\n")

      print("Seed concluído!")


  if __name__ == "__main__":
      main()
  ```

- [ ] **Step 2: Executar o script**

  ```bash
  cd "C:/Users/mathe/OneDrive/Desktop/Futdle/scripts"
  python seed_clubs.py
  ```

  Esperado:
  ```
  === Futdle Seed: Ligas e Clubes ===

  Processando Premier League...
    ✓ Arsenal
    ✓ Chelsea FC
    ...
    → 20 times inseridos

  Processando La Liga...
  ...
  Seed concluído!
  ```

- [ ] **Step 3: Verificar no Supabase**

  No dashboard: **Table Editor → clubs**. Deve ter ~160 linhas.

- [ ] **Step 4: Commit**

  ```bash
  git add scripts/seed_clubs.py
  git commit -m "feat: add clubs seed script (TheSportsDB → Supabase)"
  ```

---

## Task 8: Script de criação dos desafios diários

**Files:**
- Create: `scripts/seed_challenges.py`

- [ ] **Step 1: Criar seed_challenges.py**

  Crie `Futdle/scripts/seed_challenges.py`:

  ```python
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


  def fetch_all_club_ids() -> list[str]:
      result = supabase.table("clubs").select("id").execute()
      return [row["id"] for row in result.data]


  def fetch_existing_challenge_dates() -> set[str]:
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
              print(f"  Pulando {date_str} (já existe)")
              continue

          club_id = random.choice(club_ids)
          supabase.table("daily_challenges").insert({
              "date": date_str,
              "club_id": club_id,
              "mode": "classic",
          }).execute()

          inserted += 1
          print(f"  ✓ {date_str}")

      print(f"\n{inserted} desafios criados.")


  if __name__ == "__main__":
      parser = argparse.ArgumentParser()
      parser.add_argument("--days", type=int, default=30, help="Quantos dias gerar (padrão: 30)")
      args = parser.parse_args()
      create_challenges(args.days)
  ```

- [ ] **Step 2: Executar o script**

  ```bash
  cd "C:/Users/mathe/OneDrive/Desktop/Futdle/scripts"
  python seed_challenges.py --days 30
  ```

  Esperado:
  ```
    ✓ 2026-04-11
    ✓ 2026-04-12
    ...
  30 desafios criados.
  ```

- [ ] **Step 3: Verificar no Supabase**

  **Table Editor → daily_challenges** — deve ter 30 linhas com datas sequenciais.

- [ ] **Step 4: Commit**

  ```bash
  git add scripts/seed_challenges.py
  git commit -m "feat: add daily challenges seed script"
  ```

---

## Task 9: Teste de consulta pública (validação final)

Antes de partir para o Flutter, confirme que o banco está acessível com a chave pública (`anon key`).

**Files:**
- Create: `scripts/test_public_query.py` (temporário — deletar após o teste)

- [ ] **Step 1: Criar script de teste**

  Crie `Futdle/scripts/test_public_query.py`:

  ```python
  """Valida que clubs e daily_challenges são legíveis com a chave anônima."""
  import os
  from dotenv import load_dotenv
  from supabase import create_client

  load_dotenv()

  # Usar ANON key (não service key) para simular o app
  SUPABASE_URL = os.environ["SUPABASE_URL"]
  SUPABASE_ANON_KEY = input("Cole sua ANON KEY aqui: ").strip()

  supabase = create_client(SUPABASE_URL, SUPABASE_ANON_KEY)

  # Teste 1: listar clubes
  clubs = supabase.table("clubs").select("name, country, league_id").limit(5).execute()
  print(f"Clubes (5 primeiros): {[c['name'] for c in clubs.data]}")

  # Teste 2: desafio de hoje
  from datetime import date
  today = date.today().isoformat()
  challenge = (
      supabase.table("daily_challenges")
      .select("date, clubs(name)")
      .eq("date", today)
      .single()
      .execute()
  )
  print(f"Desafio de hoje ({today}): {challenge.data}")

  print("\n✓ Banco público acessível com anon key!")
  ```

- [ ] **Step 2: Executar**

  ```bash
  python test_public_query.py
  ```

  Esperado:
  ```
  Clubes (5 primeiros): ['Arsenal', 'Chelsea FC', 'Liverpool FC', ...]
  Desafio de hoje (2026-04-11): {'date': '2026-04-11', 'clubs': {'name': 'Flamengo'}}

  ✓ Banco público acessível com anon key!
  ```

  Se receber erro `permission denied`, volte à Task 3 e verifique se as políticas RLS foram aplicadas corretamente.

- [ ] **Step 3: Deletar o script de teste e commitar**

  ```bash
  rm scripts/test_public_query.py
  git add -A
  git commit -m "feat: backend setup complete — schema, seed, RLS validated"
  ```

---

## Resultado esperado ao final deste plano

- Projeto Supabase configurado com schema completo
- ~160 clubes de 8 ligas populados no banco
- Escudos acessíveis via URL pública do Supabase Storage
- 30 desafios diários criados
- RLS validado com anon key
- Repositório GitHub com histórico limpo

**Próximo passo:** Plano 2 — Flutter App
