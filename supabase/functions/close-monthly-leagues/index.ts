import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
)

Deno.serve(async (_req) => {
  const now = new Date()

  // Last month (this function runs on the 1st of the new month)
  const lastMonthDate = new Date(now.getFullYear(), now.getMonth() - 1, 1)
  const monthStr = `${lastMonthDate.getFullYear()}-${String(lastMonthDate.getMonth() + 1).padStart(2, '0')}-01`

  // Champion badge valid until end of the current month
  const lastDayOfCurrentMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0)
  const championUntil = lastDayOfCurrentMonth.toISOString().slice(0, 10)

  for (const mode of ['classic', 'shield'] as const) {
    // 1. Get top 3 for this mode and month
    const { data: top3, error } = await supabase
      .from('league_scores')
      .select('user_id, total_points, current_streak')
      .eq('mode', mode)
      .eq('month', monthStr)
      .order('total_points', { ascending: false })
      .limit(3)

    if (error || !top3 || top3.length === 0) continue

    // 2. Copy rankings to monthly_results (idempotent)
    const { error: resultsError } = await supabase.from('monthly_results').upsert(
      top3.map((row, i) => ({
        user_id:      row.user_id,
        mode,
        month:        monthStr,
        final_points: row.total_points,
        rank:         i + 1,
      })),
      { onConflict: 'user_id,mode,month' }
    )
    if (resultsError) {
      console.error(`monthly_results upsert error (${mode}):`, resultsError.message)
    }

    // 3. Award trophies to top 3
    const typeMap: Record<number, string> = {
      1: `official_${mode}_1st`,
      2: `official_${mode}_2nd`,
      3: `official_${mode}_3rd`,
    }
    await supabase.from('user_trophies').upsert(
      top3.map((row, i) => ({
        user_id:    row.user_id,
        type:       typeMap[i + 1],
        month:      monthStr,
        awarded_at: new Date().toISOString(),
      })),
      { onConflict: 'user_id,type,month' }
    )

    // 4. Set champion badge (1st place only)
    const badgeCol = mode === 'classic' ? 'classic_champion_until' : 'shield_champion_until'
    await supabase
      .from('user_profiles')
      .update({ [badgeCol]: championUntil })
      .eq('user_id', top3[0].user_id)

    // 5. Award full-month trophy to anyone with streak >= 30
    const { data: streakers } = await supabase
      .from('league_scores')
      .select('user_id')
      .eq('mode', mode)
      .eq('month', monthStr)
      .gte('current_streak', 30)

    if (streakers && streakers.length > 0) {
      await supabase.from('user_trophies').upsert(
        streakers.map(row => ({
          user_id:    row.user_id,
          type:       'full_month',
          month:      monthStr,
          awarded_at: new Date().toISOString(),
        })),
        { onConflict: 'user_id,type,month' }
      )
    }
  }

  return new Response(JSON.stringify({ ok: true, month: monthStr }), {
    headers: { 'Content-Type': 'application/json' },
  })
})
