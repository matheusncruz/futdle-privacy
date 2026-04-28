-- supabase/migrations/008_league_trigger.sql

-- Shared internal function called by both classic and shield triggers.
-- p_mode: 'classic' | 'shield'
-- p_count: attempts_count (classic) or wrong_count (shield)
CREATE OR REPLACE FUNCTION _update_league_score(
  p_user_id    uuid,
  p_challenge_id uuid,
  p_mode       text,
  p_count      int,
  p_solved     bool,
  p_op         text   -- 'INSERT' or 'UPDATE'
) RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_date          date;
  v_month         date;
  v_points        int := 0;
  v_played_yesterday bool := false;
  v_old_streak    int := 0;
  v_old_bonus     int := 0;
  v_new_streak    int;
  v_new_bonus     int;
  v_bonus_delta   int;
BEGIN
  -- Get the date of this challenge
  SELECT date INTO v_date FROM daily_challenges WHERE id = p_challenge_id;
  IF NOT FOUND THEN RETURN; END IF;

  -- Only count today's daily challenge — free-mode uses past challenges
  IF v_date != CURRENT_DATE THEN RETURN; END IF;

  v_month := date_trunc('month', v_date)::date;

  -- Calculate points if solved
  IF p_solved THEN
    IF p_mode = 'classic' THEN
      v_points := CASE
        WHEN p_count <= 0  THEN 0
        WHEN p_count >= 11 THEN 1
        ELSE 22 - p_count * 2
      END;
    ELSE -- shield
      v_points := CASE
        WHEN p_count >= 7 THEN 1
        ELSE 20 - p_count * 2
      END;
    END IF;
  END IF;

  -- Check if user played yesterday in the same mode (for streak)
  IF p_op = 'INSERT' THEN
    IF p_mode = 'classic' THEN
      SELECT EXISTS (
        SELECT 1 FROM user_progress up
        JOIN daily_challenges dc ON dc.id = up.challenge_id
        WHERE up.user_id = p_user_id
          AND dc.date = CURRENT_DATE - 1
      ) INTO v_played_yesterday;
    ELSE
      SELECT EXISTS (
        SELECT 1 FROM shield_user_progress sup
        JOIN daily_challenges dc ON dc.id = sup.challenge_id
        WHERE sup.user_id = p_user_id
          AND dc.date = CURRENT_DATE - 1
      ) INTO v_played_yesterday;
    END IF;
  END IF;

  -- Read existing league_scores row
  SELECT current_streak, streak_bonus
  INTO v_old_streak, v_old_bonus
  FROM league_scores
  WHERE user_id = p_user_id AND mode = p_mode AND month = v_month;

  IF NOT FOUND THEN
    v_old_streak := 0;
    v_old_bonus  := 0;
  END IF;

  -- Update streak only on INSERT (first play of this challenge)
  IF p_op = 'INSERT' THEN
    v_new_streak := CASE WHEN v_played_yesterday THEN v_old_streak + 1 ELSE 1 END;
  ELSE
    v_new_streak := v_old_streak;
  END IF;

  -- Calculate streak bonus delta
  v_new_bonus := v_old_bonus;
  IF v_new_streak >= 30 AND v_new_bonus < 350 THEN v_new_bonus := 350;
  ELSIF v_new_streak >= 20 AND v_new_bonus < 150 THEN v_new_bonus := 150;
  ELSIF v_new_streak >= 10 AND v_new_bonus < 50  THEN v_new_bonus := 50;
  END IF;
  v_bonus_delta := v_new_bonus - v_old_bonus;

  -- Upsert league_scores
  INSERT INTO league_scores (user_id, mode, month, total_points, streak_bonus, current_streak)
  VALUES (p_user_id, p_mode, v_month, v_points + v_new_bonus, v_new_bonus, v_new_streak)
  ON CONFLICT (user_id, mode, month) DO UPDATE SET
    total_points   = league_scores.total_points + v_points + v_bonus_delta,
    streak_bonus   = v_new_bonus,
    current_streak = v_new_streak;

  -- Update friend league scores for active leagues the user is in
  IF v_points > 0 THEN
    INSERT INTO friend_league_scores (league_id, user_id, total_points)
    SELECT fl.id, p_user_id, v_points
    FROM friend_leagues fl
    JOIN friend_league_members flm ON flm.league_id = fl.id
    WHERE flm.user_id  = p_user_id
      AND flm.status   = 'approved'
      AND fl.starts_at <= CURRENT_DATE
      AND fl.ends_at   >= CURRENT_DATE
      AND (fl.mode = p_mode OR fl.mode = 'both')
    ON CONFLICT (league_id, user_id) DO UPDATE SET
      total_points = friend_league_scores.total_points + v_points;
  END IF;
END;
$$;

-- ── Classic trigger ───────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION update_league_scores_classic()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    PERFORM _update_league_score(
      NEW.user_id, NEW.challenge_id, 'classic',
      NEW.attempts_count, NEW.solved, 'INSERT'
    );
  ELSIF TG_OP = 'UPDATE' AND NOT OLD.solved AND NEW.solved THEN
    PERFORM _update_league_score(
      NEW.user_id, NEW.challenge_id, 'classic',
      NEW.attempts_count, true, 'UPDATE'
    );
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER league_scores_classic_trigger
  AFTER INSERT OR UPDATE ON user_progress
  FOR EACH ROW EXECUTE FUNCTION update_league_scores_classic();

-- ── Shield trigger ────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION update_league_scores_shield()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    PERFORM _update_league_score(
      NEW.user_id, NEW.challenge_id, 'shield',
      NEW.wrong_count, NEW.solved, 'INSERT'
    );
  ELSIF TG_OP = 'UPDATE' AND NOT OLD.solved AND NEW.solved THEN
    PERFORM _update_league_score(
      NEW.user_id, NEW.challenge_id, 'shield',
      NEW.wrong_count, true, 'UPDATE'
    );
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER league_scores_shield_trigger
  AFTER INSERT OR UPDATE ON shield_user_progress
  FOR EACH ROW EXECUTE FUNCTION update_league_scores_shield();
