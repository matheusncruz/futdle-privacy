-- Permite leitura pública do progresso do modo escudo para o ranking
ALTER TABLE shield_user_progress ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "shield_progress_select_own" ON shield_user_progress;

CREATE POLICY "shield_progress_select_public"
  ON shield_user_progress FOR SELECT
  USING (true);

-- Garante que insert/update só é permitido para o próprio usuário
CREATE POLICY IF NOT EXISTS "shield_progress_insert_own"
  ON shield_user_progress FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "shield_progress_update_own"
  ON shield_user_progress FOR UPDATE
  USING (auth.uid() = user_id);
