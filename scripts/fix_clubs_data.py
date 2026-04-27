"""
Corrige todos os dados dos clubes no banco:
- Traduz países para português
- Corrige cores, títulos e anos de fundação
Uso: python fix_clubs_data.py
"""
import os
import time
from dotenv import load_dotenv
from supabase import create_client, Client

load_dotenv()
sb: Client = create_client(os.environ["SUPABASE_URL"], os.environ["SUPABASE_SERVICE_KEY"])

# Tradução de países
COUNTRY_PT = {
    "England": "Inglaterra", "Germany": "Alemanha", "Spain": "Espanha",
    "Italy": "Itália", "France": "França", "Brazil": "Brasil",
    "Argentina": "Argentina", "México": "México", "Mexico": "México",
    "Monaco": "Mônaco", "Portugal": "Portugal",
}

# Dados completos por clube: { "nome_no_banco": { campos } }
# national_titles  = títulos da 1ª divisão nacional + copa nacional
# international_titles = competições oficiais FIFA/UEFA/CONMEBOL/CONCACAF
#   (UCL/EC, UEL/UEFA Cup, CWC, FIFA CWC, Intercontinental, Libertadores,
#    Sudamericana, Recopa Sudamericana, CONCACAF Champions League)
#   NÃO incluir: Supercopa nacional, Community Shield, UEFA Super Cup,
#                Copa Intercontinental de pré-temporada, Conference League
CLUBS_FIX = {
    # ── PREMIER LEAGUE ──────────────────────────────────────────────
    # national = Liga (1ª div) + FA Cup | international = UCL/EC + UEL/UEFA Cup + CWC + IC + FIFA CWC
    "Arsenal":                  {"primary_color":"#ef0107","secondary_color":"#9c824a","national_titles":27,"international_titles":1,"founded_year":1886},  # 13 liga + 14 FA Cup | 1 CWC (1994)
    "Aston Villa":              {"primary_color":"#670e36","secondary_color":"#95bfe5","national_titles":14,"international_titles":2,"founded_year":1874},  # 7+7 | 1 ECup + 1 IC
    "Bournemouth":              {"primary_color":"#da291c","secondary_color":"#000000","national_titles":0, "international_titles":0,"founded_year":1890},
    "Brentford":                {"primary_color":"#e30613","secondary_color":"#ffffff","national_titles":0, "international_titles":0,"founded_year":1889},
    "Brighton and Hove Albion": {"primary_color":"#0057b8","secondary_color":"#ffffff","national_titles":0, "international_titles":0,"founded_year":1901},
    "Burnley":                  {"primary_color":"#6c1d45","secondary_color":"#99d6ea","national_titles":3, "international_titles":0,"founded_year":1882},  # 2 liga + 1 FA Cup
    "Chelsea":                  {"primary_color":"#034694","secondary_color":"#dba111","national_titles":15,"international_titles":7,"founded_year":1905},  # 7 liga + 8 FA Cup | 2 UCL + 2 UEL + 2 CWC + 1 FIFA CWC
    "Crystal Palace":           {"primary_color":"#1b458f","secondary_color":"#eb1e23","national_titles":0, "international_titles":0,"founded_year":1905},
    "Everton":                  {"primary_color":"#003399","secondary_color":"#ffd100","national_titles":14,"international_titles":1,"founded_year":1878},  # 9 liga + 5 FA Cup | 1 CWC (1985)
    "Fulham":                   {"primary_color":"#ffffff","secondary_color":"#000000","national_titles":0, "international_titles":0,"founded_year":1879},
    "Leeds United":             {"primary_color":"#ffffff","secondary_color":"#1d428a","national_titles":4, "international_titles":0,"founded_year":1919},  # 3 liga + 1 FA Cup | Fairs Cup não conta (não era UEFA)
    "Liverpool":                {"primary_color":"#c8102e","secondary_color":"#f6eb61","national_titles":27,"international_titles":11,"founded_year":1892},  # 19 liga + 8 FA Cup | 6 UCL + 3 UEFA + 1 IC + 1 FIFA CWC
    "Manchester City":          {"primary_color":"#6cabdd","secondary_color":"#1c2c5b","national_titles":17,"international_titles":2,"founded_year":1880},  # 10 liga + 7 FA Cup | 1 UCL + 1 FIFA CWC
    "Manchester United":        {"primary_color":"#da291c","secondary_color":"#fbe122","national_titles":33,"international_titles":7,"founded_year":1878},  # 20 liga + 13 FA Cup | 3 UCL + 1 UEL + 1 CWC + 1 IC + 1 FIFA CWC
    "Newcastle United":         {"primary_color":"#000000","secondary_color":"#ffffff","national_titles":10,"international_titles":0,"founded_year":1892},  # 4 liga + 6 FA Cup | Fairs Cup não conta
    "Nottingham Forest":        {"primary_color":"#dd0000","secondary_color":"#ffffff","national_titles":3, "international_titles":2,"founded_year":1865},  # 1 liga + 2 FA Cup | 2 ECup
    "Sunderland":               {"primary_color":"#eb172b","secondary_color":"#000000","national_titles":8, "international_titles":0,"founded_year":1879},  # 6 liga + 2 FA Cup
    "Tottenham Hotspur":        {"primary_color":"#132257","secondary_color":"#ffffff","national_titles":10,"international_titles":3,"founded_year":1882},  # 2 liga + 8 FA Cup | 2 UEFA Cup + 1 CWC
    "West Ham United":          {"primary_color":"#7a263a","secondary_color":"#1bb1e7","national_titles":3, "international_titles":1,"founded_year":1895},  # 0 liga + 3 FA Cup | 1 CWC (Conference League não conta)
    "Wolverhampton Wanderers":  {"primary_color":"#fdb913","secondary_color":"#231f20","national_titles":7, "international_titles":0,"founded_year":1877},  # 3 liga + 4 FA Cup

    # ── LA LIGA ─────────────────────────────────────────────────────
    # national = La Liga + Copa del Rey | international = UCL/EC + UEL + CWC + IC + FIFA CWC
    "Athletic Bilbao":          {"primary_color":"#ee2523","secondary_color":"#ffffff","national_titles":31,"international_titles":0,"founded_year":1898},  # 8 liga + 23 Copa del Rey
    "Atl\u00e9tico Madrid":     {"primary_color":"#cb3524","secondary_color":"#003087","national_titles":21,"international_titles":3,"founded_year":1903},  # 11 liga + 10 Copa | 2 UEL + 1 CWC
    "Barcelona":                {"primary_color":"#004d98","secondary_color":"#a50044","national_titles":58,"international_titles":12,"founded_year":1899},  # 27 liga + 31 Copa | 5 UCL + 4 CWC + 3 FIFA CWC
    "Celta Vigo":               {"primary_color":"#75aadb","secondary_color":"#ffffff","national_titles":0, "international_titles":0,"founded_year":1923},
    "Deportivo Alav\u00e9s":    {"primary_color":"#0066cc","secondary_color":"#000000","national_titles":0, "international_titles":0,"founded_year":1921},
    "Elche":                    {"primary_color":"#007a33","secondary_color":"#ffffff","national_titles":0, "international_titles":0,"founded_year":1923},
    "Espanyol":                 {"primary_color":"#0042a9","secondary_color":"#ffffff","national_titles":4, "international_titles":0,"founded_year":1900},  # 0 liga + 4 Copa del Rey
    "Getafe":                   {"primary_color":"#0052a2","secondary_color":"#ffffff","national_titles":0, "international_titles":0,"founded_year":1946},
    "Girona":                   {"primary_color":"#cc0000","secondary_color":"#ffffff","national_titles":0, "international_titles":0,"founded_year":1930},
    "Levante":                  {"primary_color":"#003087","secondary_color":"#cc0000","national_titles":0, "international_titles":0,"founded_year":1909},
    "Mallorca":                 {"primary_color":"#cc0000","secondary_color":"#000000","national_titles":1, "international_titles":0,"founded_year":1916},  # 0 liga + 1 Copa del Rey
    "Osasuna":                  {"primary_color":"#cc0000","secondary_color":"#003087","national_titles":0, "international_titles":0,"founded_year":1920},
    "Rayo Vallecano":           {"primary_color":"#ffffff","secondary_color":"#cc0000","national_titles":0, "international_titles":0,"founded_year":1924},
    "Real Betis":               {"primary_color":"#00703c","secondary_color":"#ffffff","national_titles":4, "international_titles":0,"founded_year":1907},  # 1 liga + 3 Copa del Rey
    "Real Madrid":              {"primary_color":"#ffffff","secondary_color":"#7b2082","national_titles":56,"international_titles":23,"founded_year":1902},  # 36 liga + 20 Copa | 15 UCL + 3 IC + 5 FIFA CWC
    "Real Oviedo":              {"primary_color":"#003399","secondary_color":"#ffffff","national_titles":0, "international_titles":0,"founded_year":1926},
    "Real Sociedad":            {"primary_color":"#003087","secondary_color":"#ffffff","national_titles":4, "international_titles":0,"founded_year":1909},  # 2 liga + 2 Copa del Rey
    "Sevilla":                  {"primary_color":"#d91a21","secondary_color":"#ffffff","national_titles":6, "international_titles":7,"founded_year":1905},  # 1 liga + 5 Copa | 7 UEL/UEFA Cup
    "Valencia":                 {"primary_color":"#ee7203","secondary_color":"#000000","national_titles":14,"international_titles":1,"founded_year":1919},  # 6 liga + 8 Copa del Rey | 1 CWC (1980)
    "Villarreal":               {"primary_color":"#f5d130","secondary_color":"#003087","national_titles":0, "international_titles":1,"founded_year":1923},  # 1 UEL (2021)

    # ── BUNDESLIGA ──────────────────────────────────────────────────
    # national = Bundesliga + DFB-Pokal | international = UCL/EC + UEL + CWC + IC + FIFA CWC
    "Bayer Leverkusen":             {"primary_color":"#cc0000","secondary_color":"#000000","national_titles":2, "international_titles":0,"founded_year":1904},  # 1 Bundesliga + 1 DFB-Pokal (2024)
    "Bayern Munich":                {"primary_color":"#dc052d","secondary_color":"#0066b2","national_titles":55,"international_titles":11,"founded_year":1900},  # 34 Bundesliga + 21 DFB-Pokal | 6 UCL + 1 UEFA + 1 CWC + 2 IC + 1 FIFA CWC
    "Borussia Dortmund":            {"primary_color":"#fde100","secondary_color":"#000000","national_titles":13,"international_titles":3,"founded_year":1909},  # 8 Bundesliga + 5 DFB-Pokal | 1 UCL + 1 CWC + 1 IC
    "Borussia M\u00f6nchengladbach":{"primary_color":"#006633","secondary_color":"#ffffff","national_titles":8, "international_titles":2,"founded_year":1900},  # 5 Bundesliga + 3 DFB-Pokal | 2 UEFA Cup
    "Eintracht Frankfurt":          {"primary_color":"#000000","secondary_color":"#cc0000","national_titles":5, "international_titles":1,"founded_year":1899},  # 1 Bundesliga + 4 DFB-Pokal | 1 UEL (2022)
    "FC Augsburg":                  {"primary_color":"#cc0000","secondary_color":"#006437","national_titles":0, "international_titles":0,"founded_year":1907},
    "FC Heidenheim":                {"primary_color":"#cc0000","secondary_color":"#000000","national_titles":0, "international_titles":0,"founded_year":1846},
    "FC K\u00f6ln":                 {"primary_color":"#cc0000","secondary_color":"#ffffff","national_titles":5, "international_titles":0,"founded_year":1948},  # 3 Bundesliga + 2 DFB-Pokal
    "Freiburg":                     {"primary_color":"#cc0000","secondary_color":"#000000","national_titles":0, "international_titles":0,"founded_year":1904},
    "Hamburg":                      {"primary_color":"#cc0000","secondary_color":"#ffffff","national_titles":9, "international_titles":2,"founded_year":1887},  # 6 Bundesliga + 3 DFB-Pokal | 1 ECup + 1 CWC
    "Hoffenheim":                   {"primary_color":"#003087","secondary_color":"#ffffff","national_titles":0, "international_titles":0,"founded_year":1899},
    "Mainz":                        {"primary_color":"#cc0000","secondary_color":"#ffffff","national_titles":0, "international_titles":0,"founded_year":1905},
    "RB Leipzig":                   {"primary_color":"#cc0000","secondary_color":"#003087","national_titles":2, "international_titles":0,"founded_year":2009},  # 0 Bundesliga + 2 DFB-Pokal
    "St Pauli":                     {"primary_color":"#6e1a21","secondary_color":"#ffffff","national_titles":0, "international_titles":0,"founded_year":1910},
    "Stuttgart":                    {"primary_color":"#cc0000","secondary_color":"#ffffff","national_titles":8, "international_titles":0,"founded_year":1893},  # 5 liga + 3 DFB-Pokal
    "Union Berlin":                 {"primary_color":"#cc0000","secondary_color":"#ffffff","national_titles":0, "international_titles":0,"founded_year":1906},
    "Werder Bremen":                {"primary_color":"#1d8348","secondary_color":"#ffffff","national_titles":8, "international_titles":1,"founded_year":1899},  # 4 Bundesliga + 4 DFB-Pokal | 1 CWC (1992)
    "Wolfsburg":                    {"primary_color":"#65b32e","secondary_color":"#ffffff","national_titles":2, "international_titles":0,"founded_year":1945},  # 1 Bundesliga + 1 DFB-Pokal

    # ── SERIE A ─────────────────────────────────────────────────────
    # national = Serie A + Coppa Italia | international = UCL/EC + UEL + CWC + IC + FIFA CWC
    "AC Milan":       {"primary_color":"#fb090b","secondary_color":"#000000","national_titles":24,"international_titles":13,"founded_year":1899},  # 19 Serie A + 5 Coppa | 7 UCL + 2 CWC + 3 IC + 1 FIFA CWC
    "Atalanta":       {"primary_color":"#1e5799","secondary_color":"#000000","national_titles":1, "international_titles":1, "founded_year":1907},  # 0+1 Coppa (2024) | 1 UEL (2024)
    "Bologna":        {"primary_color":"#cc0000","secondary_color":"#003087","national_titles":9, "international_titles":0, "founded_year":1909},  # 7 Serie A + 2 Coppa
    "Cagliari":       {"primary_color":"#cc0000","secondary_color":"#003399","national_titles":1, "international_titles":0, "founded_year":1920},  # 1 Serie A + 0 Coppa
    "Como":           {"primary_color":"#003087","secondary_color":"#ffffff","national_titles":0, "international_titles":0, "founded_year":1907},
    "Cremonese":      {"primary_color":"#cc0000","secondary_color":"#f5d130","national_titles":0, "international_titles":0, "founded_year":1903},
    "Fiorentina":     {"primary_color":"#6b2d8b","secondary_color":"#ffffff","national_titles":8, "international_titles":1, "founded_year":1926},  # 2 Serie A + 6 Coppa | 1 CWC (1961)
    "Genoa":          {"primary_color":"#cc0000","secondary_color":"#003087","national_titles":10,"international_titles":0, "founded_year":1893},  # 9 Serie A (histórico) + 1 Coppa
    "Hellas Verona":  {"primary_color":"#003087","secondary_color":"#f5d130","national_titles":1, "international_titles":0, "founded_year":1903},  # 1 Serie A + 0 Coppa
    "Inter Milan":    {"primary_color":"#0068a8","secondary_color":"#000000","national_titles":29,"international_titles":6, "founded_year":1908},  # 20 Serie A + 9 Coppa | 3 UCL + 3 UEFA Cup
    "Juventus":       {"primary_color":"#000000","secondary_color":"#ffffff","national_titles":50,"international_titles":8, "founded_year":1897},  # 36 Serie A + 14 Coppa | 2 UCL + 3 UEFA + 1 CWC + 2 IC
    "Lazio":          {"primary_color":"#87ceeb","secondary_color":"#ffffff","national_titles":9, "international_titles":1, "founded_year":1900},  # 2 Serie A + 7 Coppa | 1 CWC (1999)
    "Lecce":          {"primary_color":"#cc0000","secondary_color":"#f5d130","national_titles":0, "international_titles":0, "founded_year":1908},
    "Napoli":         {"primary_color":"#12a0c3","secondary_color":"#ffffff","national_titles":9, "international_titles":1, "founded_year":1926},  # 3 Serie A + 6 Coppa | 1 UEFA Cup (1989)
    "Parma":          {"primary_color":"#f5d130","secondary_color":"#003087","national_titles":3, "international_titles":3, "founded_year":1913},  # 0+3 Coppa | 2 UEFA Cup + 1 CWC
    "Pisa":           {"primary_color":"#003087","secondary_color":"#000000","national_titles":0, "international_titles":0, "founded_year":1909},
    "Roma":           {"primary_color":"#8e1f2f","secondary_color":"#f5c518","national_titles":12,"international_titles":0, "founded_year":1927},  # 3 Serie A + 9 Coppa | Conference League não conta
    "Sassuolo":       {"primary_color":"#006437","secondary_color":"#000000","national_titles":0, "international_titles":0, "founded_year":1922},
    "Torino":         {"primary_color":"#8b1a1a","secondary_color":"#ffffff","national_titles":12,"international_titles":0, "founded_year":1906},  # 7 Serie A + 5 Coppa
    "Udinese":        {"primary_color":"#000000","secondary_color":"#ffffff","national_titles":0, "international_titles":0, "founded_year":1896},

    # ── LIGUE 1 ─────────────────────────────────────────────────────
    # national = Division 1/Ligue 1 + Coupe de France | international = UCL/EC + CWC
    "Angers":     {"primary_color":"#000000","secondary_color":"#ffffff","national_titles":0, "international_titles":0,"founded_year":1919},
    "Auxerre":    {"primary_color":"#003087","secondary_color":"#ffffff","national_titles":5, "international_titles":0,"founded_year":1905},  # 1 liga + 4 Coupe
    "Brest":      {"primary_color":"#cc0000","secondary_color":"#ffffff","national_titles":0, "international_titles":0,"founded_year":1950},
    "Le Havre":   {"primary_color":"#003087","secondary_color":"#ffffff","national_titles":0, "international_titles":0,"founded_year":1872},
    "Lens":       {"primary_color":"#cc0000","secondary_color":"#f5d130","national_titles":1, "international_titles":0,"founded_year":1906},  # 1 liga + 0 Coupe
    "Lille":      {"primary_color":"#cc0000","secondary_color":"#003087","national_titles":10,"international_titles":0,"founded_year":1944},  # 4 liga + 6 Coupe
    "Lorient":    {"primary_color":"#ff6600","secondary_color":"#000000","national_titles":0, "international_titles":0,"founded_year":1926},
    "Lyon":       {"primary_color":"#003087","secondary_color":"#cc0000","national_titles":12,"international_titles":0,"founded_year":1950},  # 7 liga + 5 Coupe
    "Marseille":  {"primary_color":"#009cde","secondary_color":"#ffffff","national_titles":19,"international_titles":1,"founded_year":1899},  # 9 liga + 10 Coupe | 1 UCL (1993)
    "Metz":       {"primary_color":"#8b1a1a","secondary_color":"#f5d130","national_titles":3, "international_titles":0,"founded_year":1932},  # 1 liga + 2 Coupe
    "Monaco":     {"primary_color":"#cc0000","secondary_color":"#ffffff","national_titles":13,"international_titles":0,"founded_year":1924},  # 8 liga + 5 Coupe
    "Nantes":     {"primary_color":"#f5d130","secondary_color":"#006437","national_titles":11,"international_titles":0,"founded_year":1943},  # 8 liga + 3 Coupe
    "Nice":       {"primary_color":"#cc0000","secondary_color":"#000000","national_titles":7, "international_titles":0,"founded_year":1904},  # 4 liga + 3 Coupe
    "Paris FC":   {"primary_color":"#003087","secondary_color":"#cc0000","national_titles":0, "international_titles":0,"founded_year":1969},
    "Paris SG":   {"primary_color":"#003370","secondary_color":"#e30613","national_titles":27,"international_titles":1,"founded_year":1970},  # 12 liga + 15 Coupe | 1 CWC (1996)
    "Rennes":     {"primary_color":"#cc0000","secondary_color":"#000000","national_titles":3, "international_titles":0,"founded_year":1901},  # 0 liga + 3 Coupe
    "Strasbourg": {"primary_color":"#003087","secondary_color":"#cc0000","national_titles":4, "international_titles":0,"founded_year":1906},  # 1 liga + 3 Coupe
    "Toulouse":   {"primary_color":"#6b2d8b","secondary_color":"#ffffff","national_titles":1, "international_titles":0,"founded_year":1970},  # 1 liga + 0 Coupe

    # ── BRASILEIRÃO ─────────────────────────────────────────────────
    # national = Brasileirão Série A + Copa do Brasil
    # international = Libertadores + Sudamericana + Recopa + IC + FIFA CWC
    "Athletico Paranaense": {"primary_color":"#cc0000","secondary_color":"#000000","national_titles":2, "international_titles":3,"founded_year":1924},  # 0+2 Copa | 2 Sudamericana + 1 Recopa
    "Atl\u00e9tico Mineiro":{"primary_color":"#000000","secondary_color":"#ffffff","national_titles":4, "international_titles":4,"founded_year":1908},  # 2 Brasileiro + 2 Copa | 1 Lib + 1 Sud + 2 Recopa
    "Bahia":                {"primary_color":"#003087","secondary_color":"#cc0000","national_titles":3, "international_titles":0,"founded_year":1931},  # 2 Brasileiro + 1 Copa do Brasil
    "Botafogo":             {"primary_color":"#000000","secondary_color":"#ffffff","national_titles":2, "international_titles":1,"founded_year":1894},  # 2 Brasileiro + 0 Copa | 1 Lib (2024)
    "Bragantino":           {"primary_color":"#cc0000","secondary_color":"#000000","national_titles":0, "international_titles":0,"founded_year":1928},
    "Chapecoense":          {"primary_color":"#006437","secondary_color":"#ffffff","national_titles":0, "international_titles":1,"founded_year":1973},  # 1 Sudamericana (2016)
    "Corinthians":          {"primary_color":"#000000","secondary_color":"#ffffff","national_titles":10,"international_titles":2,"founded_year":1910},  # 7 Brasileiro + 3 Copa | 1 Lib + 1 FIFA CWC
    "Coritiba":             {"primary_color":"#006437","secondary_color":"#ffffff","national_titles":0, "international_titles":0,"founded_year":1909},
    "Cruzeiro":             {"primary_color":"#003087","secondary_color":"#f5d130","national_titles":10,"international_titles":2,"founded_year":1921},  # 4 Brasileiro + 6 Copa | 2 Lib
    "Flamengo":             {"primary_color":"#e31d1a","secondary_color":"#000000","national_titles":12,"international_titles":6,"founded_year":1895},  # 8 Brasileiro + 4 Copa | 3 Lib + 1 IC + 2 Recopa
    "Fluminense":           {"primary_color":"#720000","secondary_color":"#6ca044","national_titles":5, "international_titles":1,"founded_year":1902},  # 4 Brasileiro + 1 Copa | 1 Lib (2023)
    "Gr\u00eamio":          {"primary_color":"#0041a0","secondary_color":"#000000","national_titles":7, "international_titles":5,"founded_year":1903},  # 2 Brasileiro + 5 Copa | 2 Lib + 1 IC + 1 Sud + 1 Recopa
    "Internacional":        {"primary_color":"#e31d1a","secondary_color":"#ffffff","national_titles":4, "international_titles":3,"founded_year":1909},  # 3 Brasileiro + 1 Copa | 2 Lib + 1 Recopa
    "Mirassol":             {"primary_color":"#f5d130","secondary_color":"#000000","national_titles":0, "international_titles":0,"founded_year":1925},
    "Palmeiras":            {"primary_color":"#006437","secondary_color":"#ffffff","national_titles":15,"international_titles":3,"founded_year":1914},  # 11 Brasileiro + 4 Copa | 3 Lib
    "Remo":                 {"primary_color":"#003087","secondary_color":"#ffffff","national_titles":0, "international_titles":0,"founded_year":1905},
    "Santos":               {"primary_color":"#000000","secondary_color":"#ffffff","national_titles":9, "international_titles":4,"founded_year":1912},  # 8 Brasileiro + 1 Copa | 2 Lib + 2 IC
    "S\u00e3o Paulo":       {"primary_color":"#cc0000","secondary_color":"#000000","national_titles":7, "international_titles":7,"founded_year":1930},  # 6 Brasileiro + 1 Copa | 3 Lib + 2 IC + 2 Recopa
    "Vasco da Gama":        {"primary_color":"#000000","secondary_color":"#ffffff","national_titles":5, "international_titles":1,"founded_year":1898},  # 4 Brasileiro + 1 Copa | 1 Lib
    "Vit\u00f3ria":         {"primary_color":"#cc0000","secondary_color":"#000000","national_titles":0, "international_titles":0,"founded_year":1899},

    # ── LIGA PROFESIONAL ARGENTINA ──────────────────────────────────
    # national = 1ª divisão + Copa Argentina
    # international = Lib + Sud + Recopa + IC + FIFA CWC
    "Boca Juniors":             {"primary_color":"#003087","secondary_color":"#f5d130","national_titles":41,"international_titles":13,"founded_year":1905},  # 35+6 | 6 Lib+1 Sud+3 Recopa+3 IC
    "River Plate":              {"primary_color":"#ffffff","secondary_color":"#eb0029","national_titles":42,"international_titles":9, "founded_year":1901},  # 38+4 | 4 Lib+1 Sud+3 Recopa+1 IC
    "Racing Club":              {"primary_color":"#00b0f0","secondary_color":"#ffffff","national_titles":20,"international_titles":2, "founded_year":1903},  # 18+2 | 1 Lib+1 IC
    "Independiente":            {"primary_color":"#cc0000","secondary_color":"#ffffff","national_titles":18,"international_titles":12,"founded_year":1905},  # 16+2 | 7 Lib+2 Sud+1 Recopa+2 IC
    "San Lorenzo":              {"primary_color":"#c41a2a","secondary_color":"#000080","national_titles":18,"international_titles":2, "founded_year":1908},  # 15+3 | 1 Lib+1 Recopa
    "Estudiantes de La Plata":  {"primary_color":"#cc0000","secondary_color":"#ffffff","national_titles":5, "international_titles":6, "founded_year":1905},  # 4+1 | 4 Lib+1 IC+1 Recopa
    "Velez Sarsfield":          {"primary_color":"#ffffff","secondary_color":"#003087","national_titles":11,"international_titles":3, "founded_year":1910},  # 10+1 | 1 Lib+1 IC+1 Recopa
    "Huracan":                  {"primary_color":"#cc3300","secondary_color":"#ffffff","national_titles":4, "international_titles":0, "founded_year":1908},  # 4+0

    # ── LIGA MX ─────────────────────────────────────────────────────
    # national = Liga MX + Copa MX | international = CONCACAF Champions League/Cup
    "Club America":       {"primary_color":"#f5d130","secondary_color":"#003087","national_titles":20,"international_titles":7,"founded_year":1916},  # 14+6 | 7 CONCACAF
    "Chivas Guadalajara": {"primary_color":"#cc0000","secondary_color":"#003087","national_titles":14,"international_titles":1,"founded_year":1906},  # 12+2 | 1 CONCACAF
    "Cruz Azul":          {"primary_color":"#003087","secondary_color":"#ffffff","national_titles":17,"international_titles":2,"founded_year":1927},  # 10+7 | 2 CONCACAF
    "Pumas UNAM":         {"primary_color":"#003087","secondary_color":"#f5d130","national_titles":9, "international_titles":1,"founded_year":1954},  # 7+2 | 1 CONCACAF
    "Tigres UANL":        {"primary_color":"#f5d130","secondary_color":"#003087","national_titles":9, "international_titles":1,"founded_year":1960},  # 8+1 | 1 CONCACAF
    "Monterrey":          {"primary_color":"#003087","secondary_color":"#cc0000","national_titles":8, "international_titles":3,"founded_year":1945},  # 5+3 | 3 CONCACAF
    "Santos Laguna":      {"primary_color":"#006437","secondary_color":"#ffffff","national_titles":8, "international_titles":1,"founded_year":1983},  # 6+2 | 1 CONCACAF
    "Toluca FC":          {"primary_color":"#cc0000","secondary_color":"#ffffff","national_titles":12,"international_titles":2,"founded_year":1917},  # 10+2 | 2 CONCACAF

    # ── PRIMEIRA LIGA (PORTUGAL) ─────────────────────────────────────
    # national = Primeira Liga + Taça de Portugal | international = UCL/EC + UEFA Cup + IC
    "Benfica":              {"primary_color":"#cc0000","secondary_color":"#ffffff","national_titles":64,"international_titles":2,"founded_year":1904},  # 38+26 | 2 ECup
    "FC Porto":             {"primary_color":"#003399","secondary_color":"#f5d130","national_titles":49,"international_titles":4,"founded_year":1893},  # 30+19 | 2 UCL+1 UEFA Cup+1 IC
    "Sporting CP":          {"primary_color":"#006600","secondary_color":"#f5d130","national_titles":36,"international_titles":1,"founded_year":1906},  # 19+17 | 1 CWC (1964)
    "Braga":                {"primary_color":"#cc0000","secondary_color":"#ffffff","national_titles":3, "international_titles":0,"founded_year":1921},  # 0+3 Taça
    "Vitória de Guimarães": {"primary_color":"#000000","secondary_color":"#ffffff","national_titles":1, "international_titles":0,"founded_year":1922},  # 0+1 Taça
    "Boavista":             {"primary_color":"#000000","secondary_color":"#ffffff","national_titles":6, "international_titles":0,"founded_year":1903},  # 1+5 Taça
    "Rio Ave":              {"primary_color":"#336600","secondary_color":"#ffffff","national_titles":0, "international_titles":0,"founded_year":1939},
    "Casa Pia":             {"primary_color":"#006633","secondary_color":"#ffffff","national_titles":0, "international_titles":0,"founded_year":1920},
    "Estoril Praia":        {"primary_color":"#ffff00","secondary_color":"#000000","national_titles":0, "international_titles":0,"founded_year":1939},
    "Famalicao":            {"primary_color":"#003366","secondary_color":"#ffffff","national_titles":0, "international_titles":0,"founded_year":1931},
    "Gil Vicente":          {"primary_color":"#000000","secondary_color":"#cc0000","national_titles":0, "international_titles":0,"founded_year":1924},
    "Moreirense":           {"primary_color":"#006600","secondary_color":"#ffffff","national_titles":0, "international_titles":0,"founded_year":1938},
    "Nacional de Madeira":  {"primary_color":"#000000","secondary_color":"#cc0000","national_titles":2, "international_titles":0,"founded_year":1910},  # 0+2 Taça
    "Santa Clara":          {"primary_color":"#cc0000","secondary_color":"#000000","national_titles":0, "international_titles":0,"founded_year":1921},
    "Arouca":               {"primary_color":"#006600","secondary_color":"#000000","national_titles":0, "international_titles":0,"founded_year":1952},
    "Estrela Amadora":      {"primary_color":"#cc0000","secondary_color":"#000000","national_titles":1, "international_titles":0,"founded_year":1932},  # 0+1 Taça (1990)
    "AVS":                  {"primary_color":"#cc0000","secondary_color":"#000000","national_titles":0, "international_titles":0,"founded_year":1930},
    "Alverca":              {"primary_color":"#cc0000","secondary_color":"#ffffff","national_titles":0, "international_titles":0,"founded_year":1892},
    "Tondela":              {"primary_color":"#006600","secondary_color":"#ffffff","national_titles":0, "international_titles":0,"founded_year":1933},

    # ── BRASILEIRÃO SÉRIE B ──────────────────────────────────────────
    "Sport Recife":        {"primary_color":"#cc0000","secondary_color":"#000000","national_titles":1,"international_titles":0,"founded_year":1905},  # 1 Brasileiro (1987)
    "Ceará":               {"primary_color":"#000000","secondary_color":"#ffffff","national_titles":0,"international_titles":0,"founded_year":1914},
    "Goiás":               {"primary_color":"#006600","secondary_color":"#ffffff","national_titles":0,"international_titles":0,"founded_year":1943},
    "Avaí":                {"primary_color":"#003399","secondary_color":"#ffffff","national_titles":0,"international_titles":0,"founded_year":1923},
    "Operário Ferroviário":{"primary_color":"#000000","secondary_color":"#ffffff","national_titles":0,"international_titles":0,"founded_year":1912},
    "Guarani":             {"primary_color":"#006600","secondary_color":"#ffffff","national_titles":1,"international_titles":0,"founded_year":1911},  # 1 Brasileiro (1978)
    "Paysandu":            {"primary_color":"#003399","secondary_color":"#ffffff","national_titles":0,"international_titles":0,"founded_year":1914},
    "Novorizontino":       {"primary_color":"#cc0000","secondary_color":"#000000","national_titles":0,"international_titles":0,"founded_year":1973},
    "Ponte Preta":         {"primary_color":"#000000","secondary_color":"#ffffff","national_titles":0,"international_titles":0,"founded_year":1900},
    "CRB":                 {"primary_color":"#cc0000","secondary_color":"#000000","national_titles":0,"international_titles":0,"founded_year":1912},
    "Mirassol":            {"primary_color":"#ffcc00","secondary_color":"#000000","national_titles":0,"international_titles":0,"founded_year":1925},
    "Vila Nova":           {"primary_color":"#cc0000","secondary_color":"#000000","national_titles":0,"international_titles":0,"founded_year":1943},
    "América Mineiro":     {"primary_color":"#006600","secondary_color":"#ffffff","national_titles":0,"international_titles":0,"founded_year":1912},
    "Botafogo-SP":         {"primary_color":"#cc0000","secondary_color":"#000000","national_titles":0,"international_titles":0,"founded_year":1918},
    "Crici\u00fama":       {"primary_color":"#ffcc00","secondary_color":"#000000","national_titles":1,"international_titles":0,"founded_year":1947},  # 1 Copa do Brasil (1991)
    "Cuiab\u00e1":         {"primary_color":"#006600","secondary_color":"#f5d130","national_titles":0,"international_titles":0,"founded_year":2001},
    "Fortaleza":           {"primary_color":"#cc0000","secondary_color":"#003399","national_titles":0,"international_titles":0,"founded_year":1918},
    "Juventude":           {"primary_color":"#006600","secondary_color":"#ffffff","national_titles":1,"international_titles":0,"founded_year":1913},  # 1 Copa do Brasil (1999)
    "Londrina":            {"primary_color":"#003399","secondary_color":"#cc0000","national_titles":0,"international_titles":0,"founded_year":1956},
    "N\u00e1utico":        {"primary_color":"#cc0000","secondary_color":"#ffffff","national_titles":0,"international_titles":0,"founded_year":1901},
    "Sampaio Corr\u00eaa": {"primary_color":"#003399","secondary_color":"#cc0000","national_titles":0,"international_titles":0,"founded_year":1923},
    "S\u00e3o Bernardo":   {"primary_color":"#cc0000","secondary_color":"#000000","national_titles":0,"international_titles":0,"founded_year":1914},
    "Athletic Club-MG":    {"primary_color":"#cc0000","secondary_color":"#000000","national_titles":0,"international_titles":0,"founded_year":1909},
    "Atl\u00e9tico Goianiense": {"primary_color":"#cc0000","secondary_color":"#000000","national_titles":0,"international_titles":0,"founded_year":1937},
}


def main():
    print("=== Futdle Fix: Corrigindo dados dos clubes ===\n")

    clubs = sb.table("clubs").select("id, name, country").execute().data
    updated = 0
    not_found = []

    for club in clubs:
        club_id = club["id"]
        name = club["name"]
        country_en = club["country"]

        # Traduzir país
        country_pt = COUNTRY_PT.get(country_en, country_en)

        # Buscar dados de correção
        fix = CLUBS_FIX.get(name)

        if fix:
            payload = {**fix, "country": country_pt}
        else:
            # Sem dados específicos: pelo menos traduz o país
            payload = {"country": country_pt}
            not_found.append(name)

        sb.table("clubs").update(payload).eq("id", club_id).execute()
        print(f"  OK {name}")
        updated += 1
        time.sleep(0.05)

    print(f"\n{updated} clubes atualizados.")
    if not_found:
        print(f"\nSem dados específicos para {len(not_found)} clubes (só país traduzido):")
        for n in not_found:
            print(f"  - {n}")


if __name__ == "__main__":
    main()
