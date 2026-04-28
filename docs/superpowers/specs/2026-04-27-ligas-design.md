# Futdle — Sistema de Ligas

> Data: 2026-04-27 | Versão: 1.0

---

## Visão Geral

O sistema de ligas adiciona camada competitiva ao Futdle com dois tipos de disputa:

1. **Liga Oficial Mensal** — ranking global de todos os jogadores, separado por modo (Clássico e Escudo), com reset automático todo mês
2. **Ligas de Amigos** — grupos privados criados por usuários, com código de convite, duração customizável e modo configurável pelo criador

Ao fim de cada temporada, os top 3 da liga oficial e o vencedor de cada liga de amigos recebem troféus visíveis no perfil. Campeões exibem insígnia ao lado do nickname no ranking durante o mês seguinte.

---

## Sistema de Pontuação

### Pontos por desempenho diário

**Modo Clássico** (baseado em tentativas para acertar):

| Tentativas | Pontos |
|---|---|
| 1 | 20 |
| 2 | 18 |
| 3 | 16 |
| 4 | 14 |
| 5 | 12 |
| 6 | 10 |
| 7 | 8 |
| 8 | 6 |
| 9 | 4 |
| 10 | 2 |
| 11+ | 1 |
| Não acertou / não jogou | 0 |

**Modo Escudo** (baseado em erros cometidos): mesma tabela invertida — 0 erros = 20 pts, 1 erro = 18 pts, ..., 7+ erros = 1 pt. Não acertou = 0.

### Bônus de sequência (por mês)

Concedido **uma única vez** ao atingir cada marco de dias consecutivos no mês. Jogar sem acertar **não quebra** a sequência — apenas não jogar quebra.

| Marco | Bônus |
|---|---|
| 10 dias consecutivos | +50 pts |
| 20 dias consecutivos | +100 pts |
| 30 dias consecutivos (mês completo) | +200 pts |

**Máximo possível por mês:** 600 pts (base) + 350 pts (todos os bônus) = **950 pts**

---

## Liga Oficial

- Dois rankings independentes: **Liga Clássico** e **Liga Escudo**
- Cada ranking acumula pontos de todos os jogadores do app durante o mês do calendário (dia 1 ao último dia)
- Reset automático via Edge Function agendada para meia-noite do dia 1 de cada mês
- Top 3 de cada liga recebem troféus (🥇🥈🥉) registrados em `user_trophies`
- Campeão (1º lugar) exibe insígnia 👑 ao lado do nickname no ranking pelo mês seguinte

---

## Ligas de Amigos

### Criação

O criador define:
- **Nome** da liga (texto livre)
- **Modo**: Clássico / Escudo / Ambos combinados
- **Duração**: 7 dias, 14 dias, 30 dias ou data de fim personalizada
- **Modo de entrada**: `open` (entrada livre com código) ou `approval` (criador aprova cada solicitante)

### Entrada via código

- Liga recebe código único de 6 letras maiúsculas gerado no momento da criação (ex: `FUTD42`)
- Criador compartilha o código; amigos digitam no app para solicitar entrada
- **Entrada livre**: usuário entra direto ao digitar o código
- **Aprovação manual**: usuário fica pendente; criador recebe push notification e aprova ✓ ou rejeita ✕ individualmente

### Ranking

- Um único placar por liga (mesmo quando modo = "Ambos", os pontos do Clássico e Escudo somam)
- Vencedor de cada temporada recebe troféu 👥 registrado em `user_trophies`

---

## Troféus e Insígnias

### Troféus (perfil)

Acumulados historicamente na tela de perfil como vitrine. Cada mês o jogador pode ganhar:

| Troféu | Condição |
|---|---|
| 🥇 1º Liga Clássico | 1º lugar na liga oficial clássico |
| 🥈 2º Liga Clássico | 2º lugar na liga oficial clássico |
| 🥉 3º Liga Clássico | 3º lugar na liga oficial clássico |
| 🥇 1º Liga Escudo | 1º lugar na liga oficial escudo |
| 🥈 2º Liga Escudo | 2º lugar na liga oficial escudo |
| 🥉 3º Liga Escudo | 3º lugar na liga oficial escudo |
| 👥 Campeão de Liga | 1º em qualquer liga de amigos |
| 🔥 Mês Completo | Jogou os 30 dias do mês |

### Insígnia (ranking)

O campeão (1º lugar) de cada liga oficial exibe 👑 ao lado do nickname em todos os rankings durante o mês seguinte ao título.

---

## Arquitetura — Banco de Dados

### Novas tabelas

```sql
-- Pontuação acumulada na liga oficial (atualizada por trigger)
league_scores (
  id             uuid PK,
  user_id        uuid → auth.users,
  mode           text,           -- 'classic' | 'shield'
  month          date,           -- sempre dia 1 do mês
  total_points   int DEFAULT 0,
  streak_bonus   int DEFAULT 0,  -- bônus já concedidos no mês
  current_streak int DEFAULT 0,  -- dias consecutivos no mês atual
  UNIQUE (user_id, mode, month)
)

-- Snapshot final ao fechar o mês (para histórico e troféus)
monthly_results (
  id            uuid PK,
  user_id       uuid → auth.users,
  mode          text,
  month         date,
  final_points  int,
  rank          int
)

-- Troféus conquistados
user_trophies (
  id          uuid PK,
  user_id     uuid → auth.users,
  type        text,       -- 'official_classic_1st', 'official_shield_2nd', etc.
  month       date,
  awarded_at  timestamptz
)

-- Ligas de amigos
friend_leagues (
  id          uuid PK,
  code        text UNIQUE,  -- 'FUTD42'
  name        text,
  created_by  uuid → auth.users,
  mode        text,         -- 'classic' | 'shield' | 'both'
  entry_mode  text,         -- 'open' | 'approval'
  starts_at   date,
  ends_at     date
)

-- Membros e solicitações pendentes
friend_league_members (
  league_id  uuid → friend_leagues,
  user_id    uuid → auth.users,
  status     text DEFAULT 'pending',  -- 'pending' | 'approved' | 'rejected'
  joined_at  timestamptz,
  UNIQUE (league_id, user_id)
)

-- Pontuação por liga de amigos (atualizada por trigger)
friend_league_scores (
  id            uuid PK,
  league_id     uuid → friend_leagues,
  user_id       uuid → auth.users,
  total_points  int DEFAULT 0,
  UNIQUE (league_id, user_id)
)
```

### Trigger de atualização de pontos

Dispara toda vez que `user_progress` ou `shield_user_progress` recebe insert/update com `solved = true`:

1. Calcula pontos do dia com base em `attempts_count` / `wrong_count`
2. Incrementa `current_streak` em `league_scores`
3. Verifica marcos de bônus (10/20/30 dias) e adiciona `streak_bonus` se ainda não concedido
4. Atualiza `total_points` na linha correspondente de `league_scores`
5. Para cada `friend_league_scores` ativo que o usuário participa e cobre o modo jogado, atualiza `total_points`

### Edge Functions — fechamento de temporadas

**Fechamento mensal** — agendada para meia-noite do dia 1 de cada mês:
1. Copia rankings finais da liga oficial para `monthly_results`
2. Distribui troféus em `user_trophies` para top 3 de cada liga oficial (Clássico e Escudo)
3. Atualiza insígnia ativa do campeão de cada modo
4. Zera `league_scores` para o novo mês

**Fechamento de ligas de amigos** — agendada para rodar diariamente à meia-noite:
1. Busca todas as `friend_leagues` com `ends_at = yesterday` e que ainda não foram encerradas
2. Identifica o vencedor de cada liga (maior `total_points` em `friend_league_scores`)
3. Distribui troféu 👥 em `user_trophies` para o vencedor
4. Marca a liga como encerrada

### RLS

- `league_scores`: leitura pública, escrita apenas via trigger (service role)
- `friend_leagues`: leitura pública; insert apenas pelo `created_by`
- `friend_league_members`: leitura pública; insert pelo próprio usuário; update de `status` apenas pelo criador da liga
- `friend_league_scores`: leitura pública; escrita apenas via trigger
- `user_trophies`: leitura pública; insert apenas via Edge Function (service role)

---

## Arquitetura — Flutter

### Novos providers

- `officialLeagueProvider(mode)` — `FutureProvider.family` que busca `league_scores` do mês atual para o modo informado
- `friendLeaguesProvider` — lista de ligas de amigos do usuário (aprovadas)
- `friendLeagueDetailProvider(leagueId)` — ranking e membros de uma liga específica
- `pendingRequestsProvider(leagueId)` — solicitações pendentes (apenas para o criador)
- `userTrophiesProvider` — troféus do usuário logado

### Novas telas

| Tela | Rota |
|---|---|
| Hub de Ligas | `/leagues` |
| Liga Oficial (Clássico ou Escudo) | `/leagues/official/:mode` |
| Criar Liga de Amigos | `/leagues/create` |
| Entrar com Código | `/leagues/join` |
| Detalhe de Liga de Amigos | `/leagues/friend/:id` |

### Notificações push

- Aprovação/rejeição de solicitação de entrada
- Entrada de novo membro (em ligas com aprovação manual)
- Aviso de fim de temporada (D-3 e D-1)
- Conquista de troféu

---

## Navegação

Botão **🏆 Ligas** adicionado à `HomeScreen`, levando ao hub central que exibe:
- Cards das duas ligas oficiais com posição atual do usuário
- Lista de ligas de amigos ativas
- Botões "Criar liga" e "Entrar com código"

---

## Fora de escopo (v1)

- Ligas por liga de futebol (Brasileirão, Premier League...)
- Liga paga / premiação em dinheiro
- Chat dentro da liga
- Histórico de temporadas anteriores das ligas de amigos
