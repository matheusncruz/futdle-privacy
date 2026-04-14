import '../models/club.dart';

/// Gera dicas sobre um clube: apelidos, curiosidades e frases reais.
/// Usa dicas específicas por clube quando disponíveis,
/// e dicas genéricas baseadas nos atributos como fallback.
class HintService {
  static List<String> generateHints(Club club) {
    final specific = _specificHints[club.name];
    if (specific != null && specific.isNotEmpty) return specific;
    return _genericHints(club);
  }

  // ── Dicas específicas por clube ──────────────────────────────────────────

  static const Map<String, List<String>> _specificHints = {
    // Brasil
    'Flamengo': [
      'É o clube com maior número de torcedores do Brasil.',
      'Seu apelido é "Mengão" ou "Urubu".',
      'Venceu a Copa Libertadores em 2019 de forma épica, virando no último minuto.',
    ],
    'Palmeiras': [
      'Seu apelido é "Porco" ou "Verdão".',
      'É o clube com mais títulos do Campeonato Brasileiro.',
      'Sua torcida é chamada de "Palestra".',
    ],
    'Corinthians': [
      'Seu apelido é "Timão" ou "Alvinegro do Parque São Jorge".',
      'É um dos clubes mais populares do Brasil, com forte presença na periferia.',
      'Venceu o Mundial de Clubes em 2000 e 2012.',
    ],
    'São Paulo': [
      'Seu apelido é "Tricolor Paulista" ou "Soberano".',
      'É o único clube brasileiro a vencer 3 Copas Libertadores consecutivamente.',
      'Seu estádio é o Morumbi, um dos maiores do Brasil.',
    ],
    'Santos': [
      'Foi o clube de Pelé, considerado o maior jogador de todos os tempos.',
      'Seu apelido é "Peixe".',
      'Venceu 2 Copa Libertadores e 2 Mundiais na era de Pelé.',
    ],
    'Grêmio': [
      'Seu apelido é "Tricolor Gaúcho" ou "Imortal Tricolor".',
      'Venceu a Copa Libertadores em 2017 com Renato Gaúcho como técnico.',
      'É um dos maiores clubes do Sul do Brasil.',
    ],
    'Internacional': [
      'Seu apelido é "Colorado" ou "Inter".',
      'Venceu a Copa Libertadores e o Mundial de Clubes em 2006.',
      'É o maior rival do Grêmio no Grenal.',
    ],
    'Atlético Mineiro': [
      'Seu apelido é "Galo".',
      'Venceu a Copa Libertadores em 2013 nos pênaltis.',
      'Ronaldinho Gaúcho jogou no Galo no fim de sua carreira.',
    ],
    'Cruzeiro': [
      'Seu apelido é "Raposa".',
      'Venceu 4 Campeonatos Brasileiros e 2 Copas Libertadores.',
      'É um dos maiores clubes de Minas Gerais.',
    ],
    'Botafogo': [
      'Seu apelido é "Estrela Solitária" ou "Manequinho".',
      'Garrincha, considerado um dos maiores dribladores da história, jogou aqui.',
      'Recentemente conquistou sua primeira Copa Libertadores em 2024.',
    ],
    'Fluminense': [
      'Seu apelido é "Tricolor das Laranjeiras" ou "Flu".',
      'Venceu a Copa Libertadores em 2023 com um gol de Germán Cano na prorrogação.',
      'É um dos clubes mais tradicionais do Rio de Janeiro.',
    ],
    'Vasco da Gama': [
      'Seu apelido é "Cruz-Maltino" ou "Gigante da Colina".',
      'Foi um dos primeiros clubes a escalar jogadores negros no Brasil, quebrando barreiras raciais.',
      'Venceu a Copa Libertadores em 1998.',
    ],

    // Argentina
    'Boca Juniors': [
      'Seu apelido é "Xeneizes" e sua torcida é a "Doce".',
      'É o maior rival do River Plate no "Superclásico".',
      'Diego Maradona iniciou sua carreira profissional no Boca.',
    ],
    'River Plate': [
      'Seu apelido é "Millonario" por ter comprado jogadores caros.',
      'Venceu a Copa Libertadores 4 vezes, incluindo em 2018 no Bernabéu.',
      'É o maior rival do Boca Juniors no "Superclásico".',
    ],
    'Independiente': [
      'É conhecido como o "Rey de Copas" por vencer 7 Copas Libertadores.',
      'Seu apelido é "El Rojo".',
      'É o clube com mais títulos na Copa Libertadores da história.',
    ],
    'San Lorenzo': [
      'O Papa Francisco é torcedor declarado do San Lorenzo.',
      'Seu apelido é "El Ciclón".',
      'Venceu a Copa Libertadores em 2014.',
    ],

    // Europa — Espanha
    'Real Madrid': [
      'É o clube com mais títulos na Champions League, com 15 troféus.',
      'Seu estádio, o Santiago Bernabéu, é um dos mais famosos do mundo.',
      'Cristiano Ronaldo marcou 450 gols pelo clube, um recorde histórico.',
    ],
    'Barcelona': [
      'Johan Cruyff transformou o estilo de jogo do clube, criando a filosofia "tiki-taka".',
      'Lionel Messi marcou mais de 672 gols com a camisa do Barça.',
      'Seu estádio, o Camp Nou, é o maior da Europa.',
    ],
    'Atletico Madrid': [
      'Seu apelido é "Los Colchoneros" (os colchoeiros).',
      'É o eterno terceiro da Espanha, mas campeão em 2014 e 2021.',
      'Diego Simeone é o técnico mais longevo e vitorioso da história do clube.',
    ],
    'Sevilla': [
      'É o clube com mais títulos na Europa League/Copa UEFA, com 7 troféus.',
      'Seu apelido é "Los Nervionenses".',
      'Ramón Sánchez-Pizjuán é o nome do seu estádio histórico.',
    ],

    // Europa — Inglaterra
    'Manchester City': [
      'Venceu a tríplice coroa em 2023: Premier League, FA Cup e Champions League.',
      'Erling Haaland marcou 36 gols na Premier League em sua primeira temporada, um recorde.',
      'Ficou conhecido como o "clube dos xeques" após compra pelo grupo Abu Dhabi em 2008.',
    ],
    'Liverpool': [
      'Seu hino é "You\'ll Never Walk Alone", entoado por toda a torcida antes dos jogos.',
      'Venceu 6 Champions League, o segundo mais na Inglaterra.',
      'A rivalidade com o Manchester United é uma das mais famosas do futebol mundial.',
    ],
    'Manchester United': [
      'Sir Alex Ferguson treinou o clube por 26 anos e venceu 13 Premier Leagues.',
      'Seu apelido é "Red Devils".',
      'O Teatro dos Sonhos (Old Trafford) é sua casa histórica.',
    ],
    'Arsenal': [
      'Em 2003-04, ficou invicto na Premier League inteira, ganhando o apelido "The Invincibles".',
      'Seu apelido é "The Gunners" (os artilheiros).',
      'Foi o primeiro clube londrino a dominar o futebol inglês.',
    ],
    'Chelsea': [
      'Venceu 2 Champions League, em 2012 e 2021.',
      'Didier Drogba é o maior ídolo da história recente do clube.',
      'Seu estádio, Stamford Bridge, fica no bairro de Fulham, em Londres.',
    ],

    // Europa — Alemanha
    'Bayern Munich': [
      'É o único clube alemão a vencer uma temporada com 100% de aproveitamento (2015-16).',
      'Gerd Müller, lendário atacante, marcou 365 gols pelo Bayern.',
      'Conquistou 6 Champions League, mais que qualquer outro clube alemão.',
    ],
    'Borussia Dortmund': [
      'Seu estádio, o Signal Iduna Park, tem a maior arquibancada de pé da Europa — "A Muralha Amarela".',
      'Seu apelido é "Die Schwarzgelben" (preto e amarelo).',
      'Venceu a Champions League em 1997 contra a Juventus.',
    ],

    // Europa — Itália
    'Juventus': [
      'Seu apelido é "La Vecchia Signora" (A Velha Senhora).',
      'Venceu 9 Scudettos consecutivos entre 2012 e 2020.',
      'Cristiano Ronaldo jogou 3 temporadas no clube, de 2018 a 2021.',
    ],
    'AC Milan': [
      'Venceu 7 Champions League, o segundo maior número da história.',
      'Seu maior rival é a Internazionale, e o clássico é chamado de "Derby della Madonnina".',
      'Paulo Maldini, símbolo do clube, jogou 25 anos com a camisa rossonera.',
    ],
    'Inter Milan': [
      'Seu apelido é "La Beneamata" (A Bem-Amada).',
      'Venceu a tríplice coroa em 2010 com José Mourinho como técnico.',
      'A rivalidade com o AC Milan é um dos derbies mais famosos do mundo.',
    ],
    'Napoli': [
      'Diego Maradona é o maior ídolo da história do clube e do povo napolitano.',
      'Venceu o primeiro Scudetto em 1987, com Maradona.',
      'Em 2023, venceu o Campeonato Italiano após 33 anos de espera.',
    ],

    // Europa — França
    'Paris SG': [
      'Recebeu os maiores investimentos do futebol após compra pelo Qatar em 2011.',
      'Formou o trio mais caro da história: Messi, Neymar e Mbappé.',
      'Seu apelido é "Les Parisiens".',
    ],
    'Marseille': [
      'É o único clube francês a vencer a Champions League, em 1993.',
      'A rivalidade com o PSG é chamada de "Le Classique".',
      'Seu estádio, o Vélodrome, é um dos mais barulhentos da Europa.',
    ],

    // Sul América
    'Olimpia': [
      'É o clube mais vitorioso do Paraguai, com mais de 40 títulos nacionais.',
      'Seu apelido é "El Decano del Fútbol Paraguayo".',
      'Venceu a Copa Libertadores em 1979, 1990 e 2002.',
    ],
    'Peñarol': [
      'É um dos clubes mais titulados da América do Sul.',
      'Venceu a Copa Libertadores 5 vezes e o Mundial de Clubes 3 vezes.',
      'Seu apelido é "El Carbonero" (o carvoeiro).',
    ],
    'Nacional': [
      'É o maior rival do Peñarol no "Clásico" uruguaio.',
      'Venceu 3 Copas Libertadores.',
      'Seu apelido é "El Bolso".',
    ],
    'Colo-Colo': [
      'É o único clube chileno a vencer a Copa Libertadores, em 1991.',
      'Seu apelido é "El Cacique" (o chefe indígena).',
      'É o clube com mais títulos na história do Chile.',
    ],
    'Atletico Nacional': [
      'Venceu a Copa Libertadores em 1989 — o primeiro clube colombiano a conquistar o título.',
      'Seu apelido é "El Verde" ou "El Verdolaga".',
      'Pablo Escobar era torcedor do clube nos anos 1980.',
    ],
    'Barcelona SC': [
      'Não tem nenhuma relação com o Barcelona da Espanha — foi fundado por imigrantes catalães no Equador.',
      'É o clube com mais títulos na história do futebol equatoriano.',
      'Seu apelido é "El Ídolo".',
    ],
    'Alianza Lima': [
      'É o clube mais popular do Peru, com enorme torcida em todo o país.',
      'Em 1987, um avião com jogadores e membros do clube caiu no oceano Pacífico.',
      'Seu apelido é "Los Íntimos".',
    ],
  };

  // ── Dicas genéricas baseadas em atributos ────────────────────────────────

  static List<String> _genericHints(Club club) {
    final hints = <String>[];

    hints.add('Este clube está localizado na ${club.continent}.');

    final decade = (club.foundedYear ~/ 10) * 10;
    hints.add('Este clube foi fundado na década de $decade.');

    if (club.nationalTitles == 0) {
      hints.add('Este clube ainda não conquistou nenhum título nacional.');
    } else if (club.nationalTitles <= 5) {
      hints.add('Este clube tem poucos títulos nacionais (até 5).');
    } else if (club.nationalTitles <= 15) {
      hints.add('Este clube tem entre 6 e 15 títulos nacionais.');
    } else {
      hints.add('Este clube é um grande campeão, com mais de 15 títulos nacionais.');
    }

    if (club.internationalTitles == 0) {
      hints.add('Este clube ainda não conquistou títulos internacionais.');
    } else {
      hints.add('Este clube já conquistou ${club.internationalTitles} título${club.internationalTitles > 1 ? 's' : ''} internacionais.');
    }

    hints.add('A cor principal do escudo deste clube é ${_colorFamily(club.primaryColor)}.');
    hints.add('Este clube fica no país: ${club.country}.');

    return hints;
  }

  static String _colorFamily(String hex) {
    final h = hex.toLowerCase().replaceAll('#', '');
    if (h.length < 6) return 'indefinida';
    final r = int.tryParse(h.substring(0, 2), radix: 16) ?? 0;
    final g = int.tryParse(h.substring(2, 4), radix: 16) ?? 0;
    final b = int.tryParse(h.substring(4, 6), radix: 16) ?? 0;
    if (r > 180 && g < 80 && b < 80) return 'vermelha';
    if (r > 180 && g > 100 && b < 80) return 'laranja';
    if (r > 180 && g > 180 && b < 80) return 'amarela ou dourada';
    if (r < 80 && g > 150 && b < 80) return 'verde';
    if (r < 80 && g < 80 && b > 150) return 'azul';
    if (r > 100 && b > 150 && g < 80) return 'roxa';
    if (r > 200 && g > 200 && b > 200) return 'branca ou clara';
    if (r < 50 && g < 50 && b < 50) return 'preta';
    return 'escura ou mista';
  }
}
