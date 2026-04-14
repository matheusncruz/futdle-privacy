-- Adicionar colunas de tempo e contagem de tentativas no progresso
ALTER TABLE user_progress
  ADD COLUMN IF NOT EXISTS attempts_count int not null default 0,
  ADD COLUMN IF NOT EXISTS time_seconds int not null default 0;

-- Tabela de perfis (nickname anônimo gerado automaticamente)
CREATE TABLE IF NOT EXISTS user_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  nickname text not null,
  created_at timestamptz default now()
);

ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Qualquer um pode ler nicknames (necessário para o leaderboard)
CREATE POLICY "profiles_read_public"
  ON user_profiles FOR SELECT
  USING (true);

-- Usuário só insere/atualiza o próprio perfil
CREATE POLICY "profiles_insert_own"
  ON user_profiles FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "profiles_update_own"
  ON user_profiles FOR UPDATE
  USING (auth.uid() = user_id);

-- Permitir leitura pública do progresso para o ranking
-- (antes era só o próprio usuário)
DROP POLICY IF EXISTS "user_progress_select_own" ON user_progress;

CREATE POLICY "user_progress_select_public"
  ON user_progress FOR SELECT
  USING (true);

-- View do leaderboard: junta progresso com nickname
CREATE OR REPLACE VIEW leaderboard_view AS
SELECT
  up.challenge_id,
  up.user_id,
  up.attempts_count,
  up.time_seconds,
  up.solved,
  up.finished_at,
  COALESCE(prof.nickname, 'Anônimo') AS nickname
FROM user_progress up
LEFT JOIN user_profiles prof ON prof.user_id = up.user_id
WHERE up.solved = true;
