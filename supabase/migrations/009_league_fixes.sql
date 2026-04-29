-- supabase/migrations/009_league_fixes.sql
-- Fix security: enforce total_points = 0 on client-side inserts to friend_league_scores

DROP POLICY IF EXISTS "fls_insert_own" ON friend_league_scores;

CREATE POLICY "fls_insert_own"
  ON friend_league_scores FOR INSERT
  WITH CHECK (auth.uid() = user_id AND total_points = 0);
