import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
)

Deno.serve(async (_req) => {
  const yesterday = new Date()
  yesterday.setDate(yesterday.getDate() - 1)
  const yesterdayStr = yesterday.toISOString().slice(0, 10)

  // Find leagues that ended yesterday
  const { data: leagues } = await supabase
    .from('friend_leagues')
    .select('id')
    .eq('ends_at', yesterdayStr)

  if (!leagues || leagues.length === 0) {
    return new Response(JSON.stringify({ ok: true, closed: 0 }), {
      headers: { 'Content-Type': 'application/json' },
    })
  }

  for (const league of leagues) {
    // Get winner (highest total_points)
    const { data: scores } = await supabase
      .from('friend_league_scores')
      .select('user_id, total_points')
      .eq('league_id', league.id)
      .order('total_points', { ascending: false })
      .limit(1)

    if (!scores || scores.length === 0) continue

    await supabase.from('user_trophies').upsert({
      user_id:    scores[0].user_id,
      type:       'friend_champion',
      month:      yesterdayStr,
      awarded_at: new Date().toISOString(),
    }, { onConflict: 'user_id,type,month' })
  }

  return new Response(JSON.stringify({ ok: true, closed: leagues.length }), {
    headers: { 'Content-Type': 'application/json' },
  })
})
