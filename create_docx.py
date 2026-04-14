#!/usr/bin/env python3
import zipfile
import os
from pathlib import Path

# Create the DOCX structure
output_path = r"C:\Users\mathe\AppData\Roaming\Claude\local-agent-mode-sessions\71d8c341-6e45-4f2a-8425-d7a6ea165739\faf2a8bb-0170-4bfd-a844-6c30b7ce3f9e\agent\local_ditto_faf2a8bb-0170-4bfd-a844-6c30b7ce3f9e\outputs\Futdle_GDD.docx"

# Create temporary directory structure
import tempfile
import shutil

temp_dir = tempfile.mkdtemp()

try:
    # Create the directory structure
    os.makedirs(os.path.join(temp_dir, '_rels'))
    os.makedirs(os.path.join(temp_dir, 'word', '_rels'))
    os.makedirs(os.path.join(temp_dir, 'docProps'))

    # [Content_Types].xml
    content_types = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
</Types>'''

    with open(os.path.join(temp_dir, '[Content_Types].xml'), 'w', encoding='utf-8') as f:
        f.write(content_types)

    # _rels/.rels
    rels = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
</Relationships>'''

    with open(os.path.join(temp_dir, '_rels', '.rels'), 'w', encoding='utf-8') as f:
        f.write(rels)

    # word/_rels/document.xml.rels
    doc_rels = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
</Relationships>'''

    with open(os.path.join(temp_dir, 'word', '_rels', 'document.xml.rels'), 'w', encoding='utf-8') as f:
        f.write(doc_rels)

    # docProps/core.xml
    core_props = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/officeDocument/2006/custom-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <dc:title>Futdle - Game Design Document</dc:title>
  <dc:subject>Game Design</dc:subject>
  <dc:creator>Game Design Team</dc:creator>
</cp:coreProperties>'''

    with open(os.path.join(temp_dir, 'docProps', 'core.xml'), 'w', encoding='utf-8') as f:
        f.write(core_props)

    # Main document content - word/document.xml
    document_xml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
            xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
            xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
            xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
            xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
  <w:body>
    <w:p>
      <w:pPr>
        <w:jc w:val="center"/>
        <w:spacing w:after="240"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="96"/>
          <w:color w:val="1a472a"/>
        </w:rPr>
        <w:t>FUTDLE</w:t>
      </w:r>
    </w:p>
    <w:p>
      <w:pPr>
        <w:jc w:val="center"/>
        <w:spacing w:after="480"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:i/>
          <w:sz w:val="48"/>
        </w:rPr>
        <w:t>Game Design Document v0.1</w:t>
      </w:r>
    </w:p>
    <w:p>
      <w:pPr>
        <w:spacing w:after="240"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="64"/>
        </w:rPr>
        <w:t>1. Visão Geral</w:t>
      </w:r>
    </w:p>
    <w:p>
      <w:spacing w:after="120"/>
      <w:r>
        <w:rPr>
          <w:b/>
        </w:rPr>
        <w:t>Nome: </w:t>
      </w:r>
      <w:r>
        <w:t>Futdle</w:t>
      </w:r>
    </w:p>
    <w:p>
      <w:spacing w:after="120"/>
      <w:r>
        <w:rPr>
          <w:b/>
        </w:rPr>
        <w:t>Plataforma: </w:t>
      </w:r>
      <w:r>
        <w:t>Android e iOS (Flutter)</w:t>
      </w:r>
    </w:p>
    <w:p>
      <w:spacing w:after="120"/>
      <w:r>
        <w:rPr>
          <w:b/>
        </w:rPr>
        <w:t>Gênero: </w:t>
      </w:r>
      <w:r>
        <w:t>Quiz / Puzzle diário</w:t>
      </w:r>
    </w:p>
    <w:p>
      <w:spacing w:after="120"/>
      <w:r>
        <w:rPr>
          <w:b/>
        </w:rPr>
        <w:t>Público-alvo: </w:t>
      </w:r>
      <w:r>
        <w:t>Fãs de futebol, principalmente brasileiro, com expansão internacional</w:t>
      </w:r>
    </w:p>
    <w:p>
      <w:spacing w:after="240"/>
      <w:r>
        <w:rPr>
          <w:b/>
        </w:rPr>
        <w:t>Conceito: </w:t>
      </w:r>
      <w:r>
        <w:t>Jogo diário de adivinhação de clubes de futebol. O jogador tenta descobrir o time do dia digitando nomes de clubes — a cada tentativa, o jogo revela quais características do time digitado correspondem ao time correto.</w:t>
      </w:r>
    </w:p>
    <w:p>
      <w:pPr>
        <w:spacing w:after="240"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="64"/>
        </w:rPr>
        <w:t>2. Conceito e Inspiração</w:t>
      </w:r>
    </w:p>
    <w:p>
      <w:spacing w:after="240"/>
      <w:r>
        <w:t>Inspirado no Wordle e no Loldle (loldle.net), o Futdle traz a mecânica de "adivinhe com pistas" para o universo do futebol. A cada tentativa, o jogador recebe feedback visual sobre atributos do time que tentou — direcionando-o ao time correto.</w:t>
      </w:r>
    </w:p>
    <w:p>
      <w:pPr>
        <w:spacing w:after="240"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="64"/>
        </w:rPr>
        <w:t>3. Modos de Jogo</w:t>
      </w:r>
    </w:p>
    <w:p>
      <w:pPr>
        <w:spacing w:before="200" w:after="100"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="56"/>
        </w:rPr>
        <w:t>3.1 Modo Clássico (MVP)</w:t>
      </w:r>
    </w:p>
    <w:p><w:r><w:t>• O jogador digita o nome de qualquer time do banco de dados</w:t></w:r></w:p>
    <w:p><w:r><w:t>• O jogo exibe uma linha com os atributos do time digitado, comparados ao time correto</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Verde = correto | Amarelo = parcial | Vermelho = errado</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Setas ↑↓ para atributos numéricos (ex: ano de fundação mais antigo = ↑)</w:t></w:r></w:p>
    <w:p><w:spacing w:after="240"/><w:r><w:t>• Sem limite de tentativas no modo livre; desafio diário com registro de score</w:t></w:r></w:p>
    <w:p>
      <w:pPr>
        <w:spacing w:before="200" w:after="100"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="56"/>
        </w:rPr>
        <w:t>3.2 Modo Escudo (v2)</w:t>
      </w:r>
    </w:p>
    <w:p><w:r><w:t>• O escudo do time aparece coberto/pixelado</w:t></w:r></w:p>
    <w:p><w:r><w:t>• A cada tentativa errada, uma parte é revelada</w:t></w:r></w:p>
    <w:p><w:spacing w:after="240"/><w:r><w:t>• O jogador tenta adivinhar o time pela imagem progressiva</w:t></w:r></w:p>
    <w:p>
      <w:pPr>
        <w:spacing w:before="200" w:after="100"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="56"/>
        </w:rPr>
        <w:t>3.3 Desafio Diário</w:t>
      </w:r>
    </w:p>
    <w:p><w:r><w:t>• Um time fixo por dia, igual para todos os jogadores</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Sem custo de energia</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Resultado compartilhável (estilo Wordle)</w:t></w:r></w:p>
    <w:p><w:spacing w:after="240"/><w:r><w:t>• Ranking diário</w:t></w:r></w:p>
    <w:p>
      <w:pPr>
        <w:spacing w:before="200" w:after="100"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="56"/>
        </w:rPr>
        <w:t>3.4 Modo Livre</w:t>
      </w:r>
    </w:p>
    <w:p><w:r><w:t>• Joga quantas rodadas quiser</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Consome 1 energia por partida</w:t></w:r></w:p>
    <w:p><w:spacing w:after="240"/><w:r><w:t>• Rodadas ilimitadas enquanto tiver energia</w:t></w:r></w:p>
    <w:p>
      <w:pPr>
        <w:spacing w:after="240"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="64"/>
        </w:rPr>
        <w:t>4. Atributos do Modo Clássico</w:t>
      </w:r>
    </w:p>
    <w:tbl>
      <w:tblPr>
        <w:tblW w:w="9026" w:type="dxa"/>
        <w:tblBorders>
          <w:top w:val="single" w:sz="6" w:space="0" w:color="cccccc"/>
          <w:left w:val="single" w:sz="6" w:space="0" w:color="cccccc"/>
          <w:bottom w:val="single" w:sz="6" w:space="0" w:color="cccccc"/>
          <w:right w:val="single" w:sz="6" w:space="0" w:color="cccccc"/>
          <w:insideH w:val="single" w:sz="6" w:space="0" w:color="cccccc"/>
          <w:insideV w:val="single" w:sz="6" w:space="0" w:color="cccccc"/>
        </w:tblBorders>
      </w:tblPr>
      <w:tr>
        <w:trPr/>
        <w:tc>
          <w:tcPr>
            <w:tcW w:w="2256" w:type="dxa"/>
            <w:shd w:fill="1a472a"/>
            <w:tcMar>
              <w:top w:w="80" w:type="dxa"/>
              <w:left w:w="120" w:type="dxa"/>
              <w:bottom w:w="80" w:type="dxa"/>
              <w:right w:w="120" w:type="dxa"/>
            </w:tcMar>
          </w:tcPr>
          <w:p><w:r><w:rPr><w:b/><w:color w:val="ffffff"/></w:rPr><w:t>Atributo</w:t></w:r></w:p>
        </w:tc>
        <w:tc>
          <w:tcPr>
            <w:tcW w:w="2256" w:type="dxa"/>
            <w:shd w:fill="1a472a"/>
            <w:tcMar>
              <w:top w:w="80" w:type="dxa"/>
              <w:left w:w="120" w:type="dxa"/>
              <w:bottom w:w="80" w:type="dxa"/>
              <w:right w:w="120" w:type="dxa"/>
            </w:tcMar>
          </w:tcPr>
          <w:p><w:r><w:rPr><w:b/><w:color w:val="ffffff"/></w:rPr><w:t>Tipo</w:t></w:r></w:p>
        </w:tc>
        <w:tc>
          <w:tcPr>
            <w:tcW w:w="4514" w:type="dxa"/>
            <w:shd w:fill="1a472a"/>
            <w:tcMar>
              <w:top w:w="80" w:type="dxa"/>
              <w:left w:w="120" w:type="dxa"/>
              <w:bottom w:w="80" w:type="dxa"/>
              <w:right w:w="120" w:type="dxa"/>
            </w:tcMar>
          </w:tcPr>
          <w:p><w:r><w:rPr><w:b/><w:color w:val="ffffff"/></w:rPr><w:t>Feedback</w:t></w:r></w:p>
        </w:tc>
      </w:tr>
      <w:tr>
        <w:trPr/>
        <w:tc><w:tcPr><w:tcW w:w="2256" w:type="dxa"/><w:tcMar><w:top w:w="80" w:type="dxa"/><w:left w:w="120" w:type="dxa"/><w:bottom w:w="80" w:type="dxa"/><w:right w:w="120" w:type="dxa"/></w:tcMar></w:tcPr><w:p><w:r><w:t>País</w:t></w:r></w:p></w:tc>
        <w:tc><w:tcPr><w:tcW w:w="2256" w:type="dxa"/><w:tcMar><w:top w:w="80" w:type="dxa"/><w:left w:w="120" w:type="dxa"/><w:bottom w:w="80" w:type="dxa"/><w:right w:w="120" w:type="dxa"/></w:tcMar></w:tcPr><w:p><w:r><w:t>Texto</w:t></w:r></w:p></w:tc>
        <w:tc><w:tcPr><w:tcW w:w="4514" w:type="dxa"/><w:tcMar><w:top w:w="80" w:type="dxa"/><w:left w:w="120" w:type="dxa"/><w:bottom w:w="80" w:type="dxa"/><w:right w:w="120" w:type="dxa"/></w:tcMar></w:tcPr><w:p><w:r><w:t>Verde/Vermelho</w:t></w:r></w:p></w:tc>
      </w:tr>
      <w:tr>
        <w:trPr/>
        <w:tc><w:tcPr><w:tcW w:w="2256" w:type="dxa"/><w:tcMar><w:top w:w="80" w:type="dxa"/><w:left w:w="120" w:type="dxa"/><w:bottom w:w="80" w:type="dxa"/><w:right w:w="120" w:type="dxa"/></w:tcMar></w:tcPr><w:p><w:r><w:t>Continente</w:t></w:r></w:p></w:tc>
        <w:tc><w:tcPr><w:tcW w:w="2256" w:type="dxa"/><w:tcMar><w:top w:w="80" w:type="dxa"/><w:left w:w="120" w:type="dxa"/><w:bottom w:w="80" w:type="dxa"/><w:right w:w="120" w:type="dxa"/></w:tcMar></w:tcPr><w:p><w:r><w:t>Texto</w:t></w:r></w:p></w:tc>
        <w:tc><w:tcPr><w:tcW w:w="4514" w:type="dxa"/><w:tcMar><w:top w:w="80" w:type="dxa"/><w:left w:w="120" w:type="dxa"/><w:bottom w:w="80" w:type="dxa"/><w:right w:w="120" w:type="dxa"/></w:tcMar></w:tcPr><w:p><w:r><w:t>Verde/Vermelho</w:t></w:r></w:p></w:tc>
      </w:tr>
      <w:tr>
        <w:trPr/>
        <w:tc><w:tcPr><w:tcW w:w="2256" w:type="dxa"/><w:tcMar><w:top w:w="80" w:type="dxa"/><w:left w:w="120" w:type="dxa"/><w:bottom w:w="80" w:type="dxa"/><w:right w:w="120" w:type="dxa"/></w:tcMar></w:tcPr><w:p><w:r><w:t>Liga</w:t></w:r></w:p></w:tc>
        <w:tc><w:tcPr><w:tcW w:w="2256" w:type="dxa"/><w:tcMar><w:top w:w="80" w:type="dxa"/><w:left w:w="120" w:type="dxa"/><w:bottom w:w="80" w:type="dxa"/><w:right w:w="120" w:type="dxa"/></w:tcMar></w:tcPr><w:p><w:r><w:t>Texto</w:t></w:r></w:p></w:tc>
        <w:tc><w:tcPr><w:tcW w:w="4514" w:type="dxa"/><w:tcMar><w:top w:w="80" w:type="dxa"/><w:left w:w="120" w:type="dxa"/><w:bottom w:w="80" w:type="dxa"/><w:right w:w="120" w:type="dxa"/></w:tcMar></w:tcPr><w:p><w:r><w:t>Verde/Amarelo/Vermelho</w:t></w:r></w:p></w:tc>
      </w:tr>
      <w:tr>
        <w:trPr/>
        <w:tc><w:tcPr><w:tcW w:w="2256" w:type="dxa"/><w:tcMar><w:top w:w="80" w:type="dxa"/><w:left w:w="120" w:type="dxa"/><w:bottom w:w="80" w:type="dxa"/><w:right w:w="120" w:type="dxa"/></w:tcMar></w:tcPr><w:p><w:r><w:t>Ano de fundação</w:t></w:r></w:p></w:tc>
        <w:tc><w:tcPr><w:tcW w:w="2256" w:type="dxa"/><w:tcMar><w:top w:w="80" w:type="dxa"/><w:left w:w="120" w:type="dxa"/><w:bottom w:w="80" w:type="dxa"/><w:right w:w="120" w:type="dxa"/></w:tcMar></w:tcPr><w:p><w:r><w:t>Número</w:t></w:r></w:p></w:tc>
        <w:tc><w:tcPr><w:tcW w:w="4514" w:type="dxa"/><w:tcMar><w:top w:w="80" w:type="dxa"/><w:left w:w="120" w:type="dxa"/><w:bottom w:w="80" w:type="dxa"/><w:right w:w="120" w:type="dxa"/></w:tcMar></w:tcPr><w:p><w:r><w:t>Verde + seta ↑↓</w:t></w:r></w:p></w:tc>
      </w:tr>
      <w:tr>
        <w:trPr/>
        <w:tc><w:tcPr><w:tcW w:w="2256" w:type="dxa"/><w:tcMar><w:top w:w="80" w:type="dxa"/><w:left w:w="120" w:type="dxa"/><w:bottom w:w="80" w:type="dxa"/><w:right w:w="120" w:type="dxa"/></w:tcMar></w:tcPr><w:p><w:r><w:t>Cor principal</w:t></w:r></w:p></w:tc>
        <w:tc><w:tcPr><w:tcW w:w="2256" w:type="dxa"/><w:tcMar><w:top w:w="80" w:type="dxa"/><w:left w:w="120" w:type="dxa"/><w:bottom w:w="80" w:type="dxa"/><w:right w:w="120" w:type="dxa"/></w:tcMar></w:tcPr><w:p><w:r><w:t>Cor</w:t></w:r></w:p></w:tc>
        <w:tc><w:tcPr><w:tcW w:w="4514" w:type="dxa"/><w:tcMar><w:top w:w="80" w:type="dxa"/><w:left w:w="120" w:type="dxa"/><w:bottom w:w="80" w:type="dxa"/><w:right w:w="120" w:type="dxa"/></w:tcMar></w:tcPr><w:p><w:r><w:t>Verde/Amarelo/Vermelho</w:t></w:r></w:p></w:tc>
      </w:tr>
      <w:tr>
        <w:trPr/>
        <w:tc><w:tcPr><w:tcW w:w="2256" w:type="dxa"/><w:tcMar><w:top w:w="80" w:type="dxa"/><w:left w:w="120" w:type="dxa"/><w:bottom w:w="80" w:type="dxa"/><w:right w:w="120" w:type="dxa"/></w:tcMar></w:tcPr><w:p><w:r><w:t>Cor secundária</w:t></w:r></w:p></w:tc>
        <w:tc><w:tcPr><w:tcW w:w="2256" w:type="dxa"/><w:tcMar><w:top w:w="80" w:type="dxa"/><w:left w:w="120" w:type="dxa"/><w:bottom w:w="80" w:type="dxa"/><w:right w:w="120" w:type="dxa"/></w:tcMar></w:tcPr><w:p><w:r><w:t>Cor</w:t></w:r></w:p></w:tc>
        <w:tc><w:tcPr><w:tcW w:w="4514" w:type="dxa"/><w:tcMar><w:top w:w="80" w:type="dxa"/><w:left w:w="120" w:type="dxa"/><w:bottom w:w="80" w:type="dxa"/><w:right w:w="120" w:type="dxa"/></w:tcMar></w:tcPr><w:p><w:r><w:t>Verde/Amarelo/Vermelho</w:t></w:r></w:p></w:tc>
      </w:tr>
      <w:tr>
        <w:trPr/>
        <w:tc><w:tcPr><w:tcW w:w="2256" w:type="dxa"/><w:tcMar><w:top w:w="80" w:type="dxa"/><w:left w:w="120" w:type="dxa"/><w:bottom w:w="80" w:type="dxa"/><w:right w:w="120" w:type="dxa"/></w:tcMar></w:tcPr><w:p><w:r><w:t>Títulos nacionais</w:t></w:r></w:p></w:tc>
        <w:tc><w:tcPr><w:tcW w:w="2256" w:type="dxa"/><w:tcMar><w:top w:w="80" w:type="dxa"/><w:left w:w="120" w:type="dxa"/><w:bottom w:w="80" w:type="dxa"/><w:right w:w="120" w:type="dxa"/></w:tcMar></w:tcPr><w:p><w:r><w:t>Número</w:t></w:r></w:p></w:tc>
        <w:tc><w:tcPr><w:tcW w:w="4514" w:type="dxa"/><w:tcMar><w:top w:w="80" w:type="dxa"/><w:left w:w="120" w:type="dxa"/><w:bottom w:w="80" w:type="dxa"/><w:right w:w="120" w:type="dxa"/></w:tcMar></w:tcPr><w:p><w:r><w:t>Verde + seta ↑↓</w:t></w:r></w:p></w:tc>
      </w:tr>
      <w:tr>
        <w:trPr/>
        <w:tc><w:tcPr><w:tcW w:w="2256" w:type="dxa"/><w:tcMar><w:top w:w="80" w:type="dxa"/><w:left w:w="120" w:type="dxa"/><w:bottom w:w="80" w:type="dxa"/><w:right w:w="120" w:type="dxa"/></w:tcMar></w:tcPr><w:p><w:r><w:t>Títulos internacionais</w:t></w:r></w:p></w:tc>
        <w:tc><w:tcPr><w:tcW w:w="2256" w:type="dxa"/><w:tcMar><w:top w:w="80" w:type="dxa"/><w:left w:w="120" w:type="dxa"/><w:bottom w:w="80" w:type="dxa"/><w:right w:w="120" w:type="dxa"/></w:tcMar></w:tcPr><w:p><w:r><w:t>Número</w:t></w:r></w:p></w:tc>
        <w:tc><w:tcPr><w:tcW w:w="4514" w:type="dxa"/><w:tcMar><w:top w:w="80" w:type="dxa"/><w:left w:w="120" w:type="dxa"/><w:bottom w:w="80" w:type="dxa"/><w:right w:w="120" w:type="dxa"/></w:tcMar></w:tcPr><w:p><w:r><w:t>Verde + seta ↑↓</w:t></w:r></w:p></w:tc>
      </w:tr>
    </w:tbl>
    <w:p>
      <w:spacing w:before="120" w:after="60"/>
      <w:r>
        <w:rPr><w:b/></w:rPr>
        <w:t>Legenda:</w:t>
      </w:r>
    </w:p>
    <w:p><w:r><w:t>• Verde: igual ao time correto</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Amarelo: parcialmente correto (ex: mesma confederação, cor similar)</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Vermelho: diferente</w:t></w:r></w:p>
    <w:p><w:r><w:t>• ↑: o valor correto é maior</w:t></w:r></w:p>
    <w:p>
      <w:spacing w:after="240"/>
      <w:r><w:t>• ↓: o valor correto é menor</w:t></w:r>
    </w:p>
    <w:p>
      <w:pPr>
        <w:spacing w:after="240"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="64"/>
        </w:rPr>
        <w:t>5. Banco de Dados de Clubes (MVP)</w:t>
      </w:r>
    </w:p>
    <w:p>
      <w:pPr>
        <w:spacing w:before="200" w:after="100"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="56"/>
        </w:rPr>
        <w:t>Ligas incluídas na v1:</w:t>
      </w:r>
    </w:p>
    <w:p><w:r><w:t>• Premier League (Inglaterra) — 20 times</w:t></w:r></w:p>
    <w:p><w:r><w:t>• La Liga (Espanha) — 20 times</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Bundesliga (Alemanha) — 18 times</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Serie A (Itália) — 20 times</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Ligue 1 (França) — 18 times</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Brasileirão Série A — 20 times</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Liga Profesional Argentina — 28 times</w:t></w:r></w:p>
    <w:p>
      <w:spacing w:after="120"/>
      <w:r><w:t>• Liga MX (México) — 18 times</w:t></w:r>
    </w:p>
    <w:p>
      <w:spacing w:after="120"/>
      <w:r>
        <w:rPr><w:b/></w:rPr>
        <w:t>Total estimado: ~160 times</w:t>
      </w:r>
    </w:p>
    <w:p>
      <w:pPr>
        <w:spacing w:before="200" w:after="100"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="56"/>
        </w:rPr>
        <w:t>Estrutura de dados de cada clube:</w:t>
      </w:r>
    </w:p>
    <w:p>
      <w:spacing w:after="240"/>
      <w:r><w:t>id, nome, nome_alternativo, país, continente, liga, ano_fundação, cor_principal (hex), cor_secundária (hex), títulos_nacionais, títulos_internacionais, url_escudo</w:t></w:r>
    </w:p>
    <w:p>
      <w:pPr>
        <w:spacing w:after="240"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="64"/>
        </w:rPr>
        <w:t>6. Sistema de Energia</w:t>
      </w:r>
    </w:p>
    <w:p><w:r><w:t>• Energia máxima: 5 vidas</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Regeneração: 1 vida a cada 30 minutos</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Custo por partida no modo livre: 1 energia</w:t></w:r></w:p>
    <w:p>
      <w:spacing w:after="120"/>
      <w:r><w:t>• Desafio diário: gratuito, não consome energia</w:t></w:r>
    </w:p>
    <w:p>
      <w:pPr>
        <w:spacing w:before="200" w:after="100"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="56"/>
        </w:rPr>
        <w:t>Formas de recuperar energia:</w:t>
      </w:r>
    </w:p>
    <w:p><w:r><w:t>• Assistir anúncio (+1 energia, limitado a 3x por dia)</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Comprar pacote de energia (IAP)</w:t></w:r></w:p>
    <w:p>
      <w:spacing w:after="240"/>
      <w:r><w:t>• Aguardar regeneração</w:t></w:r>
    </w:p>
    <w:p>
      <w:pPr>
        <w:spacing w:after="240"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="64"/>
        </w:rPr>
        <w:t>7. Monetização</w:t>
      </w:r>
    </w:p>
    <w:p>
      <w:pPr>
        <w:spacing w:before="200" w:after="100"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="56"/>
        </w:rPr>
        <w:t>Ads</w:t>
      </w:r>
    </w:p>
    <w:p><w:r><w:t>• Banner discreto na tela principal</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Rewarded ad para ganhar energia extra</w:t></w:r></w:p>
    <w:p>
      <w:spacing w:after="240"/>
      <w:r><w:t>• Interstitial ocasional entre partidas no modo livre</w:t></w:r>
    </w:p>
    <w:p>
      <w:pPr>
        <w:spacing w:before="200" w:after="100"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="56"/>
        </w:rPr>
        <w:t>In-App Purchases</w:t>
      </w:r>
    </w:p>
    <w:p><w:r><w:t>• Pacote Pequeno: 5 energias</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Pacote Médio: 15 energias + remoção de banner por 7 dias</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Pacote Grande: energia ilimitada por 30 dias</w:t></w:r></w:p>
    <w:p>
      <w:spacing w:after="240"/>
      <w:r><w:t>• Remove Ads: compra única permanente</w:t></w:r>
    </w:p>
    <w:p>
      <w:pPr>
        <w:spacing w:after="240"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="64"/>
        </w:rPr>
        <w:t>8. UX / Fluxo de Telas</w:t>
      </w:r>
    </w:p>
    <w:p><w:r><w:t>1. Splash / Onboarding</w:t></w:r></w:p>
    <w:p><w:r><w:t>2. Tela principal — escolha do modo (Clássico / Escudo / Desafio Diário)</w:t></w:r></w:p>
    <w:p><w:r><w:t>3. Tela de jogo — campo de busca + grid de tentativas</w:t></w:r></w:p>
    <w:p><w:r><w:t>4. Resultado — compartilhar / jogar novamente / ranking</w:t></w:r></w:p>
    <w:p><w:r><w:t>5. Loja — energia e IAPs</w:t></w:r></w:p>
    <w:p>
      <w:spacing w:after="240"/>
      <w:r><w:t>6. Perfil — histórico, streak, conquistas</w:t></w:r>
    </w:p>
    <w:p>
      <w:pPr>
        <w:spacing w:after="240"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="64"/>
        </w:rPr>
        <w:t>9. Arquitetura Técnica</w:t>
      </w:r>
    </w:p>
    <w:p>
      <w:pPr>
        <w:spacing w:before="200" w:after="100"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="56"/>
        </w:rPr>
        <w:t>Mobile</w:t>
      </w:r>
    </w:p>
    <w:p><w:r><w:t>• Framework: Flutter (Dart)</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Gerenciamento de estado: Riverpod ou BLoC</w:t></w:r></w:p>
    <w:p>
      <w:spacing w:after="240"/>
      <w:r><w:t>• Navegação: GoRouter</w:t></w:r>
    </w:p>
    <w:p>
      <w:pPr>
        <w:spacing w:before="200" w:after="100"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="56"/>
        </w:rPr>
        <w:t>Backend</w:t>
      </w:r>
    </w:p>
    <w:p><w:r><w:t>• Plataforma: Supabase (PostgreSQL + Auth + Storage + Realtime)</w:t></w:r></w:p>
    <w:p><w:r><w:t>• API: REST via Supabase SDK para Flutter</w:t></w:r></w:p>
    <w:p>
      <w:spacing w:after="240"/>
      <w:r><w:t>• Armazenamento de escudos: Supabase Storage + CDN</w:t></w:r>
    </w:p>
    <w:p>
      <w:pPr>
        <w:spacing w:before="200" w:after="100"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="56"/>
        </w:rPr>
        <w:t>Banco de Dados (Supabase)</w:t>
      </w:r>
    </w:p>
    <w:p>
      <w:spacing w:after="120"/>
      <w:r><w:t>Tabelas principais:</w:t>
    </w:p>
    <w:p><w:r><w:t>• clubs (id, name, country, continent, league_id, founded_year, primary_color, secondary_color, national_titles, international_titles, shield_url)</w:t></w:r></w:p>
    <w:p><w:r><w:t>• leagues (id, name, country, continent)</w:t></w:r></w:p>
    <w:p><w:r><w:t>• daily_challenges (id, date, club_id, mode)</w:t></w:r></w:p>
    <w:p><w:r><w:t>• user_progress (user_id, challenge_id, attempts, solved, time_taken)</w:t></w:r></w:p>
    <w:p>
      <w:spacing w:after="240"/>
      <w:r><w:t>• user_energy (user_id, current_energy, last_regen_at)</w:t></w:r>
    </w:p>
    <w:p>
      <w:pPr>
        <w:spacing w:before="200" w:after="100"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="56"/>
        </w:rPr>
        <w:t>Seed de Dados</w:t>
      </w:r>
    </w:p>
    <w:p><w:r><w:t>• Usar TheSportsDB API (gratuita) para importar dados base dos clubes</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Curadoria manual para cores, títulos e inconsistências</w:t></w:r></w:p>
    <w:p>
      <w:spacing w:after="240"/>
      <w:r><w:t>• Script Python para importação e limpeza dos dados</w:t></w:r>
    </w:p>
    <w:p>
      <w:pPr>
        <w:spacing w:after="240"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="64"/>
        </w:rPr>
        <w:t>10. Roadmap</w:t>
      </w:r>
    </w:p>
    <w:p>
      <w:pPr>
        <w:spacing w:before="200" w:after="100"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="56"/>
        </w:rPr>
        <w:t>v1 — MVP</w:t>
      </w:r>
    </w:p>
    <w:p><w:r><w:t>• Modo Clássico com desafio diário</w:t></w:r></w:p>
    <w:p><w:r><w:t>• 8 ligas / ~160 times</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Sistema de energia</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Ads + IAPs básicos</w:t></w:r></w:p>
    <w:p>
      <w:spacing w:after="240"/>
      <w:r><w:t>• Android + iOS</w:t></w:r>
    </w:p>
    <w:p>
      <w:pPr>
        <w:spacing w:before="200" w:after="100"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="56"/>
        </w:rPr>
        <w:t>v2</w:t>
      </w:r>
    </w:p>
    <w:p><w:r><w:t>• Modo Escudo (revelação progressiva)</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Mais ligas (Champions League pool, Copa Libertadores pool)</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Conquistas e streaks</w:t></w:r></w:p>
    <w:p>
      <w:spacing w:after="240"/>
      <w:r><w:t>• Melhorias de UX com base em feedback</w:t></w:r>
    </w:p>
    <w:p>
      <w:pPr>
        <w:spacing w:before="200" w:after="100"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="56"/>
        </w:rPr>
        <w:t>v3</w:t>
      </w:r>
    </w:p>
    <w:p><w:r><w:t>• Multiplayer assíncrono (dois jogadores, mesmo desafio, quem acerta mais rápido/com menos tentativas vence)</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Ranking global e por amigos</w:t></w:r></w:p>
    <w:p>
      <w:spacing w:after="240"/>
      <w:r><w:t>• Temporadas semanais</w:t></w:r>
    </w:p>
    <w:p>
      <w:pPr>
        <w:spacing w:after="240"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="64"/>
        </w:rPr>
        <w:t>11. Considerações Finais</w:t>
      </w:r>
    </w:p>
    <w:p>
      <w:spacing w:after="240"/>
      <w:r><w:t>O Futdle tem potencial de viralização orgânica pelo mecanismo de compartilhamento do resultado diário (igual ao Wordle). O foco inicial no público brasileiro, com expansão internacional natural pelo uso de ligas globais, posiciona bem o produto para crescimento orgânico. A ausência de multiplayer no MVP reduz complexidade técnica e acelera o lançamento.</w:t></w:r>
    </w:p>
    <w:sectPr>
      <w:pgSz w:w="12240" w:h="15840"/>
      <w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440"/>
      <w:footerReference w:type="default" r:id="rId1"/>
    </w:sectPr>
  </w:body>
</w:document>'''

    with open(os.path.join(temp_dir, 'word', 'document.xml'), 'w', encoding='utf-8') as f:
        f.write(document_xml)

    # Create the DOCX file
    with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED) as docx:
        for root, dirs, files in os.walk(temp_dir):
            for file in files:
                file_path = os.path.join(root, file)
                arcname = os.path.relpath(file_path, temp_dir)
                docx.write(file_path, arcname)

    print(f"✓ Documento criado com sucesso: {output_path}")

finally:
    # Clean up
    shutil.rmtree(temp_dir)
