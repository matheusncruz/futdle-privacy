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
