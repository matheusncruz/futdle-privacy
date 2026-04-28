-- supabase/migrations/007_league_tables.sql

-- Champion badge columns on user_profiles
ALTER TABLE user_profiles
  ADD COLUMN IF NOT EXISTS classic_champion_until date,
  ADD COLUMN IF NOT EXISTS shield_champion_until  date;

-- Official league monthly scores (updated by trigger)
CREATE TABLE league_scores (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  mode           text NOT NULL CHECK (mode IN ('classic', 'shield')),
  month          date NOT NULL,  -- always the 1st of the month
  total_points   int  NOT NULL DEFAULT 0,
  streak_bonus   int  NOT NULL DEFAULT 0,
  current_streak int  NOT NULL DEFAULT 0,
  UNIQUE (user_id, mode, month)
);

-- Snapshot at season close (for history & trophy logic)
CREATE TABLE monthly_results (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  mode         text NOT NULL CHECK (mode IN ('classic', 'shield')),
  month        date NOT NULL,
  final_points int  NOT NULL,
  rank         int  NOT NULL,
  UNIQUE (user_id, mode, month)
);

-- Trophies earned by users
CREATE TABLE user_trophies (
  id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type       text        NOT NULL,
  month      date        NOT NULL,
  awarded_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, type, month)
);

-- Friend leagues
CREATE TABLE friend_leagues (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code        text NOT NULL UNIQUE,
  name        text NOT NULL,
  created_by  uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  mode        text NOT NULL CHECK (mode IN ('classic', 'shield', 'both')),
  entry_mode  text NOT NULL DEFAULT 'open' CHECK (entry_mode IN ('open', 'approval')),
  starts_at   date NOT NULL,
  ends_at     date NOT NULL,
  CHECK (ends_at > starts_at)
);

-- League membership + join requests
CREATE TABLE friend_league_members (
  league_id  uuid NOT NULL REFERENCES friend_leagues(id) ON DELETE CASCADE,
  user_id    uuid NOT NULL REFERENCES auth.users(id)     ON DELETE CASCADE,
  status     text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  joined_at  timestamptz,
  PRIMARY KEY (league_id, user_id)
);

-- Running score per member (updated by trigger)
CREATE TABLE friend_league_scores (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  league_id    uuid NOT NULL REFERENCES friend_leagues(id) ON DELETE CASCADE,
  user_id      uuid NOT NULL REFERENCES auth.users(id)     ON DELETE CASCADE,
  total_points int  NOT NULL DEFAULT 0,
  UNIQUE (league_id, user_id)
);

-- ── RLS ──────────────────────────────────────────────────────────────────────

ALTER TABLE league_scores         ENABLE ROW LEVEL SECURITY;
ALTER TABLE monthly_results       ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_trophies         ENABLE ROW LEVEL SECURITY;
ALTER TABLE friend_leagues        ENABLE ROW LEVEL SECURITY;
ALTER TABLE friend_league_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE friend_league_scores  ENABLE ROW LEVEL SECURITY;

-- league_scores: public read; write only via trigger (service role)
CREATE POLICY "league_scores_read_public"
  ON league_scores FOR SELECT USING (true);

-- monthly_results: public read
CREATE POLICY "monthly_results_read_public"
  ON monthly_results FOR SELECT USING (true);

-- user_trophies: public read
CREATE POLICY "user_trophies_read_public"
  ON user_trophies FOR SELECT USING (true);

-- friend_leagues: public read; creator inserts
CREATE POLICY "friend_leagues_read_public"
  ON friend_leagues FOR SELECT USING (true);

CREATE POLICY "friend_leagues_insert_own"
  ON friend_leagues FOR INSERT WITH CHECK (auth.uid() = created_by);

-- friend_league_members: public read; user inserts own row; creator updates status
CREATE POLICY "flm_read_public"
  ON friend_league_members FOR SELECT USING (true);

CREATE POLICY "flm_insert_own"
  ON friend_league_members FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "flm_update_creator"
  ON friend_league_members FOR UPDATE
  USING (
    auth.uid() = (
      SELECT created_by FROM friend_leagues WHERE id = league_id
    )
  );

-- friend_league_scores: public read; write only via trigger (service role)
CREATE POLICY "fls_read_public"
  ON friend_league_scores FOR SELECT USING (true);

CREATE POLICY "fls_insert_own"
  ON friend_league_scores FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ── Indexes ──────────────────────────────────────────────────────────────────

-- league_scores: leaderboard queries by mode+month, and trigger upsert by user
CREATE INDEX league_scores_mode_month_idx ON league_scores (mode, month, total_points DESC);
CREATE INDEX league_scores_user_id_idx    ON league_scores (user_id);

-- monthly_results: history queries
CREATE INDEX monthly_results_mode_month_idx ON monthly_results (mode, month);

-- user_trophies: profile display
CREATE INDEX user_trophies_user_id_idx ON user_trophies (user_id);

-- friend_league_members: trigger join (leagues this user is approved in)
CREATE INDEX friend_league_members_user_id_idx ON friend_league_members (user_id);

-- friend_league_scores: ranking queries by league
CREATE INDEX friend_league_scores_league_id_idx ON friend_league_scores (league_id, total_points DESC);
