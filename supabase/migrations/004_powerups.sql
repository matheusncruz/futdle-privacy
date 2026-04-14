-- Powerups: usos de dica e revelação de atributo
ALTER TABLE user_profiles
  ADD COLUMN IF NOT EXISTS hint_uses int NOT NULL DEFAULT 3,
  ADD COLUMN IF NOT EXISTS reveal_uses int NOT NULL DEFAULT 3;
