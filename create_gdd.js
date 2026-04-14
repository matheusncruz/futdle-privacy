const { Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
        AlignmentType, BorderStyle, WidthType, ShadingType, VerticalAlign,
        HeadingLevel, PageBreak, Header, Footer, PageNumber } = require('docx');
const fs = require('fs');

// Color definitions
const darkGreen = "1a472a";
const lightGray = "f0f0f0";
const borderColor = "cccccc";

// Border style for tables
const tableBorder = {
  style: BorderStyle.SINGLE,
  size: 6,
  color: borderColor
};

const borders = {
  top: tableBorder,
  bottom: tableBorder,
  left: tableBorder,
  right: tableBorder
};

// Helper function to create table cells
function createCell(text, width, headerStyle = false, colspan = null) {
  const cellWidth = width;
  return new TableCell({
    borders,
    width: { size: cellWidth, type: WidthType.DXA },
    shading: headerStyle ? { fill: darkGreen, type: ShadingType.CLEAR } : undefined,
    margins: { top: 80, bottom: 80, left: 120, right: 120 },
    children: [new Paragraph({
      children: [new TextRun({
        text: text,
        bold: headerStyle,
        color: headerStyle ? "ffffff" : "000000"
      })]
    })]
  });
}

// Helper to create simple table rows
function createTableRow(cells, isHeader = false) {
  return new TableRow({
    children: cells.map((cell, idx) =>
      createCell(cell.text, cell.width, isHeader)
    )
  });
}

// Document sections
const doc = new Document({
  styles: {
    default: {
      document: {
        run: { font: "Arial", size: 22 }
      }
    },
    paragraphStyles: [
      {
        id: "Heading1",
        name: "Heading 1",
        basedOn: "Normal",
        next: "Normal",
        quickFormat: true,
        run: { size: 32, bold: true, font: "Arial" },
        paragraph: { spacing: { before: 240, after: 120 }, outlineLevel: 0 }
      },
      {
        id: "Heading2",
        name: "Heading 2",
        basedOn: "Normal",
        next: "Normal",
        quickFormat: true,
        run: { size: 28, bold: true, font: "Arial" },
        paragraph: { spacing: { before: 200, after: 100 }, outlineLevel: 1 }
      }
    ]
  },
  sections: [{
    properties: {
      page: {
        margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 }
      }
    },
    footers: {
      default: new Footer({
        children: [
          new Paragraph({
            alignment: AlignmentType.CENTER,
            border: { top: { style: BorderStyle.SINGLE, size: 6, color: borderColor } },
            children: [
              new TextRun({
                text: "Futdle GDD v0.1 — Confidencial | Página ",
                size: 18
              }),
              new TextRun({
                children: [PageNumber.CURRENT],
                size: 18
              })
            ]
          })
        ]
      })
    },
    children: [
      // Title
      new Paragraph({
        alignment: AlignmentType.CENTER,
        spacing: { after: 120 },
        children: [new TextRun({
          text: "FUTDLE",
          bold: true,
          size: 48,
          color: darkGreen
        })]
      }),
      new Paragraph({
        alignment: AlignmentType.CENTER,
        spacing: { after: 240 },
        children: [new TextRun({
          text: "Game Design Document v0.1",
          italic: true,
          size: 24
        })]
      }),

      // Section 1: Visão Geral
      new Paragraph({
        heading: HeadingLevel.HEADING_1,
        children: [new TextRun("1. Visão Geral")]
      }),

      new Paragraph({
        spacing: { after: 120 },
        children: [new TextRun({
          text: "Nome: ",
          bold: true
        }), new TextRun("Futdle")]
      }),
      new Paragraph({
        spacing: { after: 120 },
        children: [new TextRun({
          text: "Plataforma: ",
          bold: true
        }), new TextRun("Android e iOS (Flutter)")]
      }),
      new Paragraph({
        spacing: { after: 120 },
        children: [new TextRun({
          text: "Gênero: ",
          bold: true
        }), new TextRun("Quiz / Puzzle diário")]
      }),
      new Paragraph({
        spacing: { after: 120 },
        children: [new TextRun({
          text: "Público-alvo: ",
          bold: true
        }), new TextRun("Fãs de futebol, principalmente brasileiro, com expansão internacional")]
      }),
      new Paragraph({
        spacing: { after: 240 },
        children: [new TextRun({
          text: "Conceito: ",
          bold: true
        }), new TextRun("Jogo diário de adivinhação de clubes de futebol. O jogador tenta descobrir o time do dia digitando nomes de clubes — a cada tentativa, o jogo revela quais características do time digitado correspondem ao time correto.")]
      }),

      // Section 2: Conceito e Inspiração
      new Paragraph({
        heading: HeadingLevel.HEADING_1,
        children: [new TextRun("2. Conceito e Inspiração")]
      }),
      new Paragraph({
        spacing: { after: 240 },
        children: [new TextRun("Inspirado no Wordle e no Loldle (loldle.net), o Futdle traz a mecânica de \"adivinhe com pistas\" para o universo do futebol. A cada tentativa, o jogador recebe feedback visual sobre atributos do time que tentou — direcionando-o ao time correto.")]
      }),

      // Section 3: Modos de Jogo
      new Paragraph({
        heading: HeadingLevel.HEADING_1,
        children: [new TextRun("3. Modos de Jogo")]
      }),

      new Paragraph({
        heading: HeadingLevel.HEADING_2,
        children: [new TextRun("3.1 Modo Clássico (MVP)")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• O jogador digita o nome de qualquer time do banco de dados")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• O jogo exibe uma linha com os atributos do time digitado, comparados ao time correto")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Verde = correto | Amarelo = parcial | Vermelho = errado")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Setas ↑↓ para atributos numéricos (ex: ano de fundação mais antigo = ↑)")]
      }),
      new Paragraph({
        spacing: { after: 240 },
        children: [new TextRun("• Sem limite de tentativas no modo livre; desafio diário com registro de score")]
      }),

      new Paragraph({
        heading: HeadingLevel.HEADING_2,
        children: [new TextRun("3.2 Modo Escudo (v2)")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• O escudo do time aparece coberto/pixelado")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• A cada tentativa errada, uma parte é revelada")]
      }),
      new Paragraph({
        spacing: { after: 240 },
        children: [new TextRun("• O jogador tenta adivinhar o time pela imagem progressiva")]
      }),

      new Paragraph({
        heading: HeadingLevel.HEADING_2,
        children: [new TextRun("3.3 Desafio Diário")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Um time fixo por dia, igual para todos os jogadores")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Sem custo de energia")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Resultado compartilhável (estilo Wordle)")]
      }),
      new Paragraph({
        spacing: { after: 240 },
        children: [new TextRun("• Ranking diário")]
      }),

      new Paragraph({
        heading: HeadingLevel.HEADING_2,
        children: [new TextRun("3.4 Modo Livre")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Joga quantas rodadas quiser")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Consome 1 energia por partida")]
      }),
      new Paragraph({
        spacing: { after: 240 },
        children: [new TextRun("• Rodadas ilimitadas enquanto tiver energia")]
      }),

      // Section 4: Atributos do Modo Clássico
      new Paragraph({
        heading: HeadingLevel.HEADING_1,
        children: [new TextRun("4. Atributos do Modo Clássico")]
      }),

      new Table({
        width: { size: 9026, type: WidthType.DXA },
        columnWidths: [2256, 2256, 4514],
        rows: [
          createTableRow([
            { text: "Atributo", width: 2256 },
            { text: "Tipo", width: 2256 },
            { text: "Feedback", width: 4514 }
          ], true),
          createTableRow([
            { text: "País", width: 2256 },
            { text: "Texto", width: 2256 },
            { text: "Verde/Vermelho", width: 4514 }
          ]),
          createTableRow([
            { text: "Continente", width: 2256 },
            { text: "Texto", width: 2256 },
            { text: "Verde/Vermelho", width: 4514 }
          ]),
          createTableRow([
            { text: "Liga", width: 2256 },
            { text: "Texto", width: 2256 },
            { text: "Verde/Amarelo/Vermelho", width: 4514 }
          ]),
          createTableRow([
            { text: "Ano de fundação", width: 2256 },
            { text: "Número", width: 2256 },
            { text: "Verde + seta ↑↓", width: 4514 }
          ]),
          createTableRow([
            { text: "Cor principal", width: 2256 },
            { text: "Cor", width: 2256 },
            { text: "Verde/Amarelo/Vermelho", width: 4514 }
          ]),
          createTableRow([
            { text: "Cor secundária", width: 2256 },
            { text: "Cor", width: 2256 },
            { text: "Verde/Amarelo/Vermelho", width: 4514 }
          ]),
          createTableRow([
            { text: "Títulos nacionais", width: 2256 },
            { text: "Número", width: 2256 },
            { text: "Verde + seta ↑↓", width: 4514 }
          ]),
          createTableRow([
            { text: "Títulos internacionais", width: 2256 },
            { text: "Número", width: 2256 },
            { text: "Verde + seta ↑↓", width: 4514 }
          ])
        ]
      }),

      new Paragraph({
        spacing: { before: 120, after: 60 },
        children: [new TextRun({
          text: "Legenda:",
          bold: true
        })]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Verde: igual ao time correto")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Amarelo: parcialmente correto (ex: mesma confederação, cor similar)")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Vermelho: diferente")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• ↑: o valor correto é maior")]
      }),
      new Paragraph({
        spacing: { after: 240 },
        children: [new TextRun("• ↓: o valor correto é menor")]
      }),

      // Section 5: Banco de Dados de Clubes
      new Paragraph({
        heading: HeadingLevel.HEADING_1,
        children: [new TextRun("5. Banco de Dados de Clubes (MVP)")]
      }),

      new Paragraph({
        heading: HeadingLevel.HEADING_2,
        children: [new TextRun("Ligas incluídas na v1:")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Premier League (Inglaterra) — 20 times")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• La Liga (Espanha) — 20 times")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Bundesliga (Alemanha) — 18 times")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Serie A (Itália) — 20 times")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Ligue 1 (França) — 18 times")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Brasileirão Série A — 20 times")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Liga Profesional Argentina — 28 times")]
      }),
      new Paragraph({
        spacing: { after: 120 },
        children: [new TextRun("• Liga MX (México) — 18 times")]
      }),

      new Paragraph({
        spacing: { after: 120 },
        children: [new TextRun({
          text: "Total estimado: ~160 times",
          bold: true
        })]
      }),

      new Paragraph({
        heading: HeadingLevel.HEADING_2,
        children: [new TextRun("Estrutura de dados de cada clube:")]
      }),
      new Paragraph({
        spacing: { after: 240 },
        children: [new TextRun("id, nome, nome_alternativo, país, continente, liga, ano_fundação, cor_principal (hex), cor_secundária (hex), títulos_nacionais, títulos_internacionais, url_escudo")]
      }),

      // Section 6: Sistema de Energia
      new Paragraph({
        heading: HeadingLevel.HEADING_1,
        children: [new TextRun("6. Sistema de Energia")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Energia máxima: 5 vidas")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Regeneração: 1 vida a cada 30 minutos")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Custo por partida no modo livre: 1 energia")]
      }),
      new Paragraph({
        spacing: { after: 120 },
        children: [new TextRun("• Desafio diário: gratuito, não consome energia")]
      }),

      new Paragraph({
        heading: HeadingLevel.HEADING_2,
        children: [new TextRun("Formas de recuperar energia:")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Assistir anúncio (+1 energia, limitado a 3x por dia)")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Comprar pacote de energia (IAP)")]
      }),
      new Paragraph({
        spacing: { after: 240 },
        children: [new TextRun("• Aguardar regeneração")]
      }),

      // Section 7: Monetização
      new Paragraph({
        heading: HeadingLevel.HEADING_1,
        children: [new TextRun("7. Monetização")]
      }),

      new Paragraph({
        heading: HeadingLevel.HEADING_2,
        children: [new TextRun("Ads")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Banner discreto na tela principal")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Rewarded ad para ganhar energia extra")]
      }),
      new Paragraph({
        spacing: { after: 240 },
        children: [new TextRun("• Interstitial ocasional entre partidas no modo livre")]
      }),

      new Paragraph({
        heading: HeadingLevel.HEADING_2,
        children: [new TextRun("In-App Purchases")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Pacote Pequeno: 5 energias")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Pacote Médio: 15 energias + remoção de banner por 7 dias")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Pacote Grande: energia ilimitada por 30 dias")]
      }),
      new Paragraph({
        spacing: { after: 240 },
        children: [new TextRun("• Remove Ads: compra única permanente")]
      }),

      // Section 8: UX / Fluxo de Telas
      new Paragraph({
        heading: HeadingLevel.HEADING_1,
        children: [new TextRun("8. UX / Fluxo de Telas")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("1. Splash / Onboarding")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("2. Tela principal — escolha do modo (Clássico / Escudo / Desafio Diário)")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("3. Tela de jogo — campo de busca + grid de tentativas")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("4. Resultado — compartilhar / jogar novamente / ranking")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("5. Loja — energia e IAPs")]
      }),
      new Paragraph({
        spacing: { after: 240 },
        children: [new TextRun("6. Perfil — histórico, streak, conquistas")]
      }),

      // Section 9: Arquitetura Técnica
      new Paragraph({
        heading: HeadingLevel.HEADING_1,
        children: [new TextRun("9. Arquitetura Técnica")]
      }),

      new Paragraph({
        heading: HeadingLevel.HEADING_2,
        children: [new TextRun("Mobile")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Framework: Flutter (Dart)")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Gerenciamento de estado: Riverpod ou BLoC")]
      }),
      new Paragraph({
        spacing: { after: 240 },
        children: [new TextRun("• Navegação: GoRouter")]
      }),

      new Paragraph({
        heading: HeadingLevel.HEADING_2,
        children: [new TextRun("Backend")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Plataforma: Supabase (PostgreSQL + Auth + Storage + Realtime)")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• API: REST via Supabase SDK para Flutter")]
      }),
      new Paragraph({
        spacing: { after: 240 },
        children: [new TextRun("• Armazenamento de escudos: Supabase Storage + CDN")]
      }),

      new Paragraph({
        heading: HeadingLevel.HEADING_2,
        children: [new TextRun("Banco de Dados (Supabase)")]
      }),
      new Paragraph({
        spacing: { after: 120 },
        children: [new TextRun("Tabelas principais:")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• clubs (id, name, country, continent, league_id, founded_year, primary_color, secondary_color, national_titles, international_titles, shield_url)")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• leagues (id, name, country, continent)")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• daily_challenges (id, date, club_id, mode)")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• user_progress (user_id, challenge_id, attempts, solved, time_taken)")]
      }),
      new Paragraph({
        spacing: { after: 240 },
        children: [new TextRun("• user_energy (user_id, current_energy, last_regen_at)")]
      }),

      new Paragraph({
        heading: HeadingLevel.HEADING_2,
        children: [new TextRun("Seed de Dados")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Usar TheSportsDB API (gratuita) para importar dados base dos clubes")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Curadoria manual para cores, títulos e inconsistências")]
      }),
      new Paragraph({
        spacing: { after: 240 },
        children: [new TextRun("• Script Python para importação e limpeza dos dados")]
      }),

      // Section 10: Roadmap
      new Paragraph({
        heading: HeadingLevel.HEADING_1,
        children: [new TextRun("10. Roadmap")]
      }),

      new Paragraph({
        heading: HeadingLevel.HEADING_2,
        children: [new TextRun("v1 — MVP")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Modo Clássico com desafio diário")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• 8 ligas / ~160 times")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Sistema de energia")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Ads + IAPs básicos")]
      }),
      new Paragraph({
        spacing: { after: 240 },
        children: [new TextRun("• Android + iOS")]
      }),

      new Paragraph({
        heading: HeadingLevel.HEADING_2,
        children: [new TextRun("v2")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Modo Escudo (revelação progressiva)")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Mais ligas (Champions League pool, Copa Libertadores pool)")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Conquistas e streaks")]
      }),
      new Paragraph({
        spacing: { after: 240 },
        children: [new TextRun("• Melhorias de UX com base em feedback")]
      }),

      new Paragraph({
        heading: HeadingLevel.HEADING_2,
        children: [new TextRun("v3")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Multiplayer assíncrono (dois jogadores, mesmo desafio, quem acerta mais rápido/com menos tentativas vence)")]
      }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun("• Ranking global e por amigos")]
      }),
      new Paragraph({
        spacing: { after: 240 },
        children: [new TextRun("• Temporadas semanais")]
      }),

      // Section 11: Considerações Finais
      new Paragraph({
        heading: HeadingLevel.HEADING_1,
        children: [new TextRun("11. Considerações Finais")]
      }),
      new Paragraph({
        spacing: { after: 240 },
        children: [new TextRun("O Futdle tem potencial de viralização orgânica pelo mecanismo de compartilhamento do resultado diário (igual ao Wordle). O foco inicial no público brasileiro, com expansão internacional natural pelo uso de ligas globais, posiciona bem o produto para crescimento orgânico. A ausência de multiplayer no MVP reduz complexidade técnica e acelera o lançamento.")]
      })
    ]
  }]
});

Packer.toBuffer(doc).then(buffer => {
  const outputPath = "C:\\Users\\mathe\\AppData\\Roaming\\Claude\\local-agent-mode-sessions\\71d8c341-6e45-4f2a-8425-d7a6ea165739\\faf2a8bb-0170-4bfd-a844-6c30b7ce3f9e\\agent\\local_ditto_faf2a8bb-0170-4bfd-a844-6c30b7ce3f9e\\outputs\\Futdle_GDD.docx";
  fs.writeFileSync(outputPath, buffer);
  console.log("✓ Documento criado com sucesso em: " + outputPath);
  process.exit(0);
});
