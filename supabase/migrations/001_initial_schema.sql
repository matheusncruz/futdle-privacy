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
