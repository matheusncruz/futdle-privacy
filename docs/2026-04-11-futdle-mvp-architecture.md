# Futdle MVP — Arquitetura Técnica

> Versão: 0.1 | Data: 2026-04-11 | Escopo: v1 MVP (Android)

---

## 1. Visão Geral

Futdle é um jogo diário de adivinhação de clubes de futebol (estilo Wordle). O jogador tenta descobrir o time do dia — a cada tentativa recebe feedback visual por atributo (verde / amarelo / vermelho + setas para valores numéricos).

**Abordagem de desenvolvimento:** Backend primeiro (Supabase), depois Flutter por cima com dados reais.

---

## 2. Arquitetura Geral

```
[Supabase]
  ├── PostgreSQL  →  tabelas de clubes, ligas, desafios, progresso, energia
  ├── Auth        →  autenticação anônima (MVP); email/social na v2
  └── Storage     →  escudos dos clubes (PNG)

[Flutter Android App]
  ├── Riverpod    →  gerenciamento de estado
  ├── GoRouter    →  navegação entre telas
  ├── Supabase Flutter SDK  →  dados + auth
  └── Google Mobile Ads SDK →  banner + rewarded ad

[GitHub]
  └── repositório único: app Flutter + scripts Python de seed
```

---

## 3. Schema do Banco de Dados (Supabase / PostgreSQL)

```sql
-- Ligas
leagues (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name          text NOT NULL,   -- "Brasileirão Série A"
  country       text NOT NULL,   -- "Brasil"
  continent     text NOT NULL    -- "América do Sul"
)

-- Clubes (~160 no MVP)
clubs (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name                  text NOT NULL,        -- "Flamengo"
  alt_name              text,                 -- "Mengão" (busca alternativa)
  country               text NOT NULL,
  continent             text NOT NULL,
  league_id             uuid REFERENCES leagues(id),
  founded_year          int,
  primary_color         text,                 -- "#e31d1a"
  secondary_color       text,                 -- "#000000"
  national_titles       int DEFAULT 0,
  international_titles  int DEFAULT 0,
  shield_url            text                  -- URL no Supabase Storage
)

-- Desafios diários
daily_challenges (
  id        uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  date      date UNIQUE NOT NULL,   -- um desafio por dia
  club_id   uuid REFERENCES clubs(id),
  mode      text DEFAULT 'classic'  -- 'classic' | 'shield' (v2)
)

-- Progresso do jogador por desafio
user_progress (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       uuid REFERENCES auth.users(id),
  challenge_id  uuid REFERENCES daily_challenges(id),
  attempts      jsonb,              -- [{ club_id, feedback }, ...]
  solved        bool DEFAULT false,
  finished_at   timestamptz,
  UNIQUE (user_id, challenge_id)
)

-- Energia do jogador (modo livre)
user_energy (
  user_id         uuid PRIMARY KEY REFERENCES auth.users(id),
  current_energy  int DEFAULT 5,    -- máx: 5
  last_regen_at   timestamptz DEFAULT now()
)
```

### Regras de energia
- Máximo: 5 vidas
- Regeneração: +1 a cada 30 minutos
- Desafio diário: gratuito (não consome energia)
- Modo livre: -1 por partida
- Recargas: assistir rewarded ad (+1, máx 3x/dia) ou IAP

---

## 4. Seed de Dados

Script Python (`scripts/seed_clubs.py`) que:
1. Busca dados base na **TheSportsDB API** (gratuita, sem chave para dados básicos)
2. Mapeia para o schema acima
3. Faz curadoria manual de cores (hex) e contagem de títulos
4. Faz upload dos escudos para o Supabase Storage
5. Insere via Supabase Python SDK

**Ligas do MVP (~160 clubes):**
| Liga | País | Times |
|------|------|-------|
| Premier League | Inglaterra | 20 |
| La Liga | Espanha | 20 |
| Bundesliga | Alemanha | 18 |
| Serie A | Itália | 20 |
| Ligue 1 | França | 18 |
| Brasileirão Série A | Brasil | 20 |
| Liga Profesional | Argentina | 28 |
| Liga MX | México | 18 |

---

## 5. Estrutura do Projeto Flutter

```
futdle/
  lib/
    main.dart
    core/
      supabase_client.dart    -- inicialização Supabase
      router.dart             -- GoRouter: definição de rotas
      theme.dart              -- cores, tipografia, tema global
    features/
      home/
        screens/
          home_screen.dart    -- tela principal (escolha de modo + energia)
      game/
        models/
          club.dart           -- modelo de clube
          attempt.dart        -- tentativa + feedback
        providers/
          game_provider.dart  -- estado da partida (Riverpod)
          clubs_provider.dart -- busca de clubes
        screens/
          game_screen.dart    -- tela de jogo
        widgets/
          search_field.dart   -- campo de busca com autocomplete
          attempt_row.dart    -- linha de tentativa com feedback
          feedback_cell.dart  -- célula individual (verde/amarelo/vermelho)
      result/
        screens/
          result_screen.dart  -- resultado + compartilhar + ranking
      energy/
        providers/
          energy_provider.dart
      store/
        screens/
          store_screen.dart   -- loja de energia e IAPs
  assets/
    fonts/
    images/
  pubspec.yaml
scripts/
  seed_clubs.py
docs/
  2026-04-11-futdle-mvp-architecture.md
```

---

## 6. Fluxo de Telas (MVP)

```
Splash
  └── Home
        ├── [Desafio Diário] → Jogo (mode: daily)
        │                         └── Resultado → Home
        ├── [Modo Livre] → Jogo (mode: free, -1 energia)
        │                     └── Resultado → Home
        └── [Loja] → Store Screen
```

---

## 7. Mecânica de Feedback (Modo Clássico)

| Atributo | Tipo | Feedback |
|---|---|---|
| País | Texto | Verde / Vermelho |
| Continente | Texto | Verde / Vermelho |
| Liga | Texto | Verde / Amarelo (mesma confederação) / Vermelho |
| Ano de fundação | Número | Verde + ↑ (correto é mais antigo) / ↓ |
| Cor principal | Cor | Verde / Amarelo (cor similar) / Vermelho |
| Cor secundária | Cor | Verde / Amarelo / Vermelho |
| Títulos nacionais | Número | Verde + ↑↓ |
| Títulos internacionais | Número | Verde + ↑↓ |

---

## 8. Monetização (MVP)

**Ads (Google AdMob)**
- Banner discreto na Home
- Rewarded ad: +1 energia (máx 3x/dia)
- Interstitial ocasional entre partidas no modo livre

**IAP**
- Pacote Pequeno: 5 energias
- Pacote Médio: 15 energias + sem banner por 7 dias
- Pacote Grande: energia ilimitada por 30 dias
- Remove Ads: compra única permanente

---

## 9. Ordem de Desenvolvimento (Backend First)

1. **Supabase**: criar projeto, tabelas, RLS básico, Storage bucket
2. **Seed**: script Python para popular ligas e clubes (~160)
3. **Desafios diários**: inserir manualmente os primeiros 30 dias
4. **Flutter**: scaffold do projeto, integração Supabase, auth anônimo
5. **Tela de jogo**: busca de times, grid de tentativas, lógica de feedback
6. **Tela de resultado**: compartilhar resultado (formato Wordle)
7. **Sistema de energia**: lógica de regeneração + rewarded ad
8. **Home + navegação**: GoRouter, tela principal
9. **Ads**: integração AdMob (banner + rewarded)
10. **Testes**: emulador Android + ajustes finais

---

## 10. Ferramentas e Contas Necessárias

| Ferramenta | Status | Obs |
|---|---|---|
| Flutter SDK | Instalar | flutter.dev |
| Android Studio | Instalar | emulador Android |
| Supabase | Tem conta | criar novo projeto |
| GitHub | Tem | criar repositório |
| Google AdMob | Criar conta | gratuito |
| Codemagic | Criar conta | build iOS futuro |
| Apple Developer | Pendente | $99/ano — só quando for lançar no iOS |
