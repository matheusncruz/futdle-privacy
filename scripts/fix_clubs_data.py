"""
Corrige todos os dados dos clubes no banco:
- Traduz países para português
- Corrige cores, títulos e anos de fundação
Uso: python fix_clubs_data.py
"""
import os
from dotenv import load_dotenv
from supabase import create_client, Client

load_dotenv()
sb: Client = create_client(os.environ["SUPABASE_URL"], os.environ["SUPABASE_SERVICE_KEY"])

# Tradução de países
COUNTRY_PT = {
    "England": "Inglaterra", "Germany": "Alemanha", "Spain": "Espanha",
    "Italy": "Itália", "France": "França", "Brazil": "Brasil",
    "Argentina": "Argentina", "México": "México", "Mexico": "México",
    "Monaco": "Mônaco",
}

# Dados completos por clube: { "nome_no_banco": { campos } }
CLUBS_FIX = {
    # ── PREMIER LEAGUE ──────────────────────────────────────────────
    "Arsenal":                  {"primary_color":"#ef0107","secondary_color":"#ffffff","national_titles":13,"international_titles":0,"founded_year":1886},
    "Aston Villa":              {"primary_color":"#670e36","secondary_color":"#95bfe5","national_titles":7,"international_titles":2,"founded_year":1874},
    "Bournemouth":              {"primary_color":"#da291c","secondary_color":"#000000","national_titles":0,"international_titles":0,"founded_year":1890},
    "Brentford":                {"primary_color":"#e30613","secondary_color":"#ffffff","national_titles":0,"international_titles":0,"founded_year":1889},
    "Brighton and Hove Albion": {"primary_color":"#0057b8","secondary_color":"#ffffff","national_titles":0,"international_titles":0,"founded_year":1901},
    "Burnley":                  {"primary_color":"#6c1d45","secondary_color":"#99d6ea","national_titles":2,"international_titles":0,"founded_year":1882},
    "Chelsea":                  {"primary_color":"#034694","secondary_color":"#ffffff","national_titles":6,"international_titles":5,"founded_year":1905},
    "Crystal Palace":           {"primary_color":"#1b458f","secondary_color":"#eb1e23","national_titles":0,"international_titles":0,"founded_year":1905},
    "Everton":                  {"primary_color":"#003399","secondary_color":"#ffffff","national_titles":9,"international_titles":1,"founded_year":1878},
    "Fulham":                   {"primary_color":"#ffffff","secondary_color":"#000000","national_titles":0,"international_titles":0,"founded_year":1879},
    "Leeds United":             {"primary_color":"#ffffff","secondary_color":"#1d428a","national_titles":3,"international_titles":1,"founded_year":1919},
    "Liverpool":                {"primary_color":"#c8102e","secondary_color":"#ffffff","national_titles":20,"international_titles":9,"founded_year":1892},
    "Manchester City":          {"primary_color":"#6cabdd","secondary_color":"#ffffff","national_titles":10,"international_titles":2,"founded_year":1880},
    "Manchester United":        {"primary_color":"#da291c","secondary_color":"#000000","national_titles":20,"international_titles":7,"founded_year":1878},
    "Newcastle United":         {"primary_color":"#000000","secondary_color":"#ffffff","national_titles":4,"international_titles":1,"founded_year":1892},
    "Nottingham Forest":        {"primary_color":"#dd0000","secondary_color":"#ffffff","national_titles":1,"international_titles":2,"founded_year":1865},
    "Sunderland":               {"primary_color":"#eb172b","secondary_color":"#ffffff","national_titles":6,"international_titles":0,"founded_year":1879},
    "Tottenham Hotspur":        {"primary_color":"#132257","secondary_color":"#ffffff","national_titles":2,"international_titles":2,"founded_year":1882},
    "West Ham United":          {"primary_color":"#7a263a","secondary_color":"#1bb1e7","national_titles":0,"international_titles":1,"founded_year":1895},
    "Wolverhampton Wanderers":  {"primary_color":"#fdb913","secondary_color":"#231f20","national_titles":3,"international_titles":1,"founded_year":1877},

    # ── LA LIGA ─────────────────────────────────────────────────────
    "Athletic Bilbao":          {"primary_color":"#ee2523","secondary_color":"#ffffff","national_titles":8,"international_titles":0,"founded_year":1898},
    "Atl\u00e9tico Madrid":     {"primary_color":"#cb3524","secondary_color":"#ffffff","national_titles":11,"international_titles":4,"founded_year":1903},
    "Barcelona":                {"primary_color":"#004d98","secondary_color":"#a50044","national_titles":27,"international_titles":19,"founded_year":1899},
    "Celta Vigo":               {"primary_color":"#75aadb","secondary_color":"#ffffff","national_titles":0,"international_titles":0,"founded_year":1923},
    "Deportivo Alav\u00e9s":    {"primary_color":"#0066cc","secondary_color":"#000000","national_titles":0,"international_titles":0,"founded_year":1921},
    "Elche":                    {"primary_color":"#007a33","secondary_color":"#ffffff","national_titles":0,"international_titles":0,"founded_year":1923},
    "Espanyol":                 {"primary_color":"#0042a9","secondary_color":"#ffffff","national_titles":0,"international_titles":0,"founded_year":1900},
    "Getafe":                   {"primary_color":"#0052a2","secondary_color":"#ffffff","national_titles":0,"international_titles":0,"founded_year":1946},
    "Girona":                   {"primary_color":"#cc0000","secondary_color":"#ffffff","national_titles":0,"international_titles":0,"founded_year":1930},
    "Levante":                  {"primary_color":"#003087","secondary_color":"#cc0000","national_titles":0,"international_titles":0,"founded_year":1909},
    "Mallorca":                 {"primary_color":"#cc0000","secondary_color":"#000000","national_titles":0,"international_titles":0,"founded_year":1916},
    "Osasuna":                  {"primary_color":"#cc0000","secondary_color":"#000000","national_titles":0,"international_titles":0,"founded_year":1920},
    "Rayo Vallecano":           {"primary_color":"#ffffff","secondary_color":"#cc0000","national_titles":0,"international_titles":0,"founded_year":1924},
    "Real Betis":               {"primary_color":"#00703c","secondary_color":"#ffffff","national_titles":1,"international_titles":0,"founded_year":1907},
    "Real Madrid":              {"primary_color":"#febe10","secondary_color":"#ffffff","national_titles":36,"international_titles":20,"founded_year":1902},
    "Real Oviedo":              {"primary_color":"#003399","secondary_color":"#ffffff","national_titles":0,"international_titles":0,"founded_year":1926},
    "Real Sociedad":            {"primary_color":"#003087","secondary_color":"#ffffff","national_titles":2,"international_titles":0,"founded_year":1909},
    "Sevilla":                  {"primary_color":"#d91a21","secondary_color":"#ffffff","national_titles":1,"international_titles":7,"founded_year":1905},
    "Valencia":                 {"primary_color":"#ee7203","secondary_color":"#000000","national_titles":6,"international_titles":4,"founded_year":1919},
    "Villarreal":               {"primary_color":"#f5d130","secondary_color":"#003087","national_titles":0,"international_titles":1,"founded_year":1923},

    # ── BUNDESLIGA ──────────────────────────────────────────────────
    "Bayer Leverkusen":             {"primary_color":"#cc0000","secondary_color":"#000000","national_titles":1,"international_titles":0,"founded_year":1904},
    "Bayern Munich":                {"primary_color":"#dc052d","secondary_color":"#ffffff","national_titles":34,"international_titles":11,"founded_year":1900},
    "Borussia Dortmund":            {"primary_color":"#fde100","secondary_color":"#000000","national_titles":8,"international_titles":2,"founded_year":1909},
    "Borussia M\u00f6nchengladbach":{"primary_color":"#000000","secondary_color":"#ffffff","national_titles":5,"international_titles":2,"founded_year":1900},
    "Eintracht Frankfurt":          {"primary_color":"#000000","secondary_color":"#cc0000","national_titles":1,"international_titles":2,"founded_year":1899},
    "FC Augsburg":                  {"primary_color":"#cc0000","secondary_color":"#006437","national_titles":0,"international_titles":0,"founded_year":1907},
    "FC Heidenheim":                {"primary_color":"#cc0000","secondary_color":"#ffffff","national_titles":0,"international_titles":0,"founded_year":1846},
    "FC K\u00f6ln":                 {"primary_color":"#cc0000","secondary_color":"#ffffff","national_titles":2,"international_titles":0,"founded_year":1948},
    "Freiburg":                     {"primary_color":"#cc0000","secondary_color":"#000000","national_titles":0,"international_titles":0,"founded_year":1904},
    "Hamburg":                      {"primary_color":"#cc0000","secondary_color":"#ffffff","national_titles":6,"international_titles":2,"founded_year":1887},
    "Hoffenheim":                   {"primary_color":"#003087","secondary_color":"#ffffff","national_titles":0,"international_titles":0,"founded_year":1899},
    "Mainz":                        {"primary_color":"#cc0000","secondary_color":"#ffffff","national_titles":0,"international_titles":0,"founded_year":1905},
    "RB Leipzig":                   {"primary_color":"#cc0000","secondary_color":"#003087","national_titles":0,"international_titles":0,"founded_year":2009},
    "St Pauli":                     {"primary_color":"#6e1a21","secondary_color":"#ffffff","national_titles":0,"international_titles":0,"founded_year":1910},
    "Stuttgart":                    {"primary_color":"#cc0000","secondary_color":"#ffffff","national_titles":3,"international_titles":1,"founded_year":1893},
    "Union Berlin":                 {"primary_color":"#cc0000","secondary_color":"#ffffff","national_titles":0,"international_titles":0,"founded_year":1906},
    "Werder Bremen":                {"primary_color":"#1d8348","secondary_color":"#ffffff","national_titles":4,"international_titles":1,"founded_year":1899},
    "Wolfsburg":                    {"primary_color":"#65b32e","secondary_color":"#003087","national_titles":1,"international_titles":0,"founded_year":1945},

    # ── SERIE A ─────────────────────────────────────────────────────
    "AC Milan":       {"primary_color":"#fb090b","secondary_color":"#000000","national_titles":19,"international_titles":11,"founded_year":1899},
    "Atalanta":       {"primary_color":"#1e5799","secondary_color":"#000000","national_titles":0,"international_titles":1,"founded_year":1907},
    "Bologna":        {"primary_color":"#cc0000","secondary_color":"#000000","national_titles":7,"international_titles":0,"founded_year":1909},
    "Cagliari":       {"primary_color":"#cc0000","secondary_color":"#000000","national_titles":1,"international_titles":0,"founded_year":1920},
    "Como":           {"primary_color":"#003087","secondary_color":"#ffffff","national_titles":0,"international_titles":0,"founded_year":1907},
    "Cremonese":      {"primary_color":"#cc0000","secondary_color":"#f5d130","national_titles":0,"international_titles":0,"founded_year":1903},
    "Fiorentina":     {"primary_color":"#6b2d8b","secondary_color":"#ffffff","national_titles":2,"international_titles":0,"founded_year":1926},
    "Genoa":          {"primary_color":"#cc0000","secondary_color":"#003087","national_titles":9,"international_titles":0,"founded_year":1893},
    "Hellas Verona":  {"primary_color":"#003087","secondary_color":"#f5d130","national_titles":1,"international_titles":0,"founded_year":1903},
    "Inter Milan":    {"primary_color":"#0068a8","secondary_color":"#000000","national_titles":20,"international_titles":7,"founded_year":1908},
    "Juventus":       {"primary_color":"#000000","secondary_color":"#ffffff","national_titles":36,"international_titles":9,"founded_year":1897},
    "Lazio":          {"primary_color":"#87ceeb","secondary_color":"#ffffff","national_titles":2,"international_titles":1,"founded_year":1900},
    "Lecce":          {"primary_color":"#cc0000","secondary_color":"#f5d130","national_titles":0,"international_titles":0,"founded_year":1908},
    "Napoli":         {"primary_color":"#12a0c3","secondary_color":"#ffffff","national_titles":3,"international_titles":1,"founded_year":1926},
    "Parma":          {"primary_color":"#f5d130","secondary_color":"#003087","national_titles":0,"international_titles":3,"founded_year":1913},
    "Pisa":           {"primary_color":"#000000","secondary_color":"#000080","national_titles":0,"international_titles":0,"founded_year":1909},
    "Roma":           {"primary_color":"#8e1f2f","secondary_color":"#f5c518","national_titles":3,"international_titles":1,"founded_year":1927},
    "Sassuolo":       {"primary_color":"#006437","secondary_color":"#000000","national_titles":0,"international_titles":0,"founded_year":1922},
    "Torino":         {"primary_color":"#8b1a1a","secondary_color":"#ffffff","national_titles":7,"international_titles":0,"founded_year":1906},
    "Udinese":        {"primary_color":"#000000","secondary_color":"#ffffff","national_titles":0,"international_titles":0,"founded_year":1896},

    # ── LIGUE 1 ─────────────────────────────────────────────────────
    "Angers":     {"primary_color":"#000000","secondary_color":"#ffffff","national_titles":0,"international_titles":0,"founded_year":1919},
    "Auxerre":    {"primary_color":"#003087","secondary_color":"#ffffff","national_titles":1,"international_titles":0,"founded_year":1905},
    "Brest":      {"primary_color":"#cc0000","secondary_color":"#ffffff","national_titles":0,"international_titles":0,"founded_year":1950},
    "Le Havre":   {"primary_color":"#003087","secondary_color":"#ffffff","national_titles":0,"international_titles":0,"founded_year":1872},
    "Lens":       {"primary_color":"#cc0000","secondary_color":"#f5d130","national_titles":1,"international_titles":0,"founded_year":1906},
    "Lille":      {"primary_color":"#cc0000","secondary_color":"#003087","national_titles":4,"international_titles":0,"founded_year":1944},
    "Lorient":    {"primary_color":"#ff6600","secondary_color":"#000000","national_titles":0,"international_titles":0,"founded_year":1926},
    "Lyon":       {"primary_color":"#003087","secondary_color":"#cc0000","national_titles":7,"international_titles":0,"founded_year":1950},
    "Marseille":  {"primary_color":"#009cde","secondary_color":"#ffffff","national_titles":9,"international_titles":1,"founded_year":1899},
    "Metz":       {"primary_color":"#8b1a1a","secondary_color":"#f5d130","national_titles":0,"international_titles":0,"founded_year":1932},
    "Monaco":     {"primary_color":"#cc0000","secondary_color":"#ffffff","national_titles":8,"international_titles":0,"founded_year":1924},
    "Nantes":     {"primary_color":"#f5d130","secondary_color":"#006437","national_titles":8,"international_titles":0,"founded_year":1943},
    "Nice":       {"primary_color":"#cc0000","secondary_color":"#000000","national_titles":4,"international_titles":0,"founded_year":1904},
    "Paris FC":   {"primary_color":"#003087","secondary_color":"#cc0000","national_titles":0,"international_titles":0,"founded_year":1969},
    "Paris SG":   {"primary_color":"#003370","secondary_color":"#e30613","national_titles":12,"international_titles":0,"founded_year":1970},
    "Rennes":     {"primary_color":"#cc0000","secondary_color":"#000000","national_titles":0,"international_titles":0,"founded_year":1901},
    "Strasbourg": {"primary_color":"#003087","secondary_color":"#ffffff","national_titles":1,"international_titles":0,"founded_year":1906},
    "Toulouse":   {"primary_color":"#6b2d8b","secondary_color":"#ffffff","national_titles":0,"international_titles":0,"founded_year":1970},

    # ── BRASILEIRÃO ─────────────────────────────────────────────────
    "Athletico Paranaense": {"primary_color":"#cc0000","secondary_color":"#000000","national_titles":1,"international_titles":0,"founded_year":1924},
    "Atl\u00e9tico Mineiro":{"primary_color":"#000000","secondary_color":"#ffffff","national_titles":2,"international_titles":1,"founded_year":1908},
    "Bahia":                {"primary_color":"#003087","secondary_color":"#cc0000","national_titles":2,"international_titles":0,"founded_year":1931},
    "Botafogo":             {"primary_color":"#000000","secondary_color":"#ffffff","national_titles":2,"international_titles":0,"founded_year":1894},
    "Bragantino":           {"primary_color":"#cc0000","secondary_color":"#000000","national_titles":0,"international_titles":0,"founded_year":1928},
    "Chapecoense":          {"primary_color":"#006437","secondary_color":"#ffffff","national_titles":0,"international_titles":0,"founded_year":1973},
    "Corinthians":          {"primary_color":"#000000","secondary_color":"#ffffff","national_titles":7,"international_titles":2,"founded_year":1910},
    "Coritiba":             {"primary_color":"#006437","secondary_color":"#ffffff","national_titles":1,"international_titles":0,"founded_year":1909},
    "Cruzeiro":             {"primary_color":"#003087","secondary_color":"#ffffff","national_titles":4,"international_titles":2,"founded_year":1921},
    "Flamengo":             {"primary_color":"#e31d1a","secondary_color":"#000000","national_titles":8,"international_titles":4,"founded_year":1895},
    "Fluminense":           {"primary_color":"#720000","secondary_color":"#6ca044","national_titles":4,"international_titles":1,"founded_year":1902},
    "Gr\u00eamio":          {"primary_color":"#0041a0","secondary_color":"#000000","national_titles":2,"international_titles":5,"founded_year":1903},
    "Internacional":        {"primary_color":"#e31d1a","secondary_color":"#ffffff","national_titles":3,"international_titles":3,"founded_year":1909},
    "Mirassol":             {"primary_color":"#f5d130","secondary_color":"#000000","national_titles":0,"international_titles":0,"founded_year":1925},
    "Palmeiras":            {"primary_color":"#006437","secondary_color":"#ffffff","national_titles":11,"international_titles":3,"founded_year":1914},
    "Remo":                 {"primary_color":"#003087","secondary_color":"#ffffff","national_titles":0,"international_titles":0,"founded_year":1905},
    "Santos":               {"primary_color":"#000000","secondary_color":"#ffffff","national_titles":8,"international_titles":3,"founded_year":1912},
    "S\u00e3o Paulo":       {"primary_color":"#ff0000","secondary_color":"#000000","national_titles":6,"international_titles":3,"founded_year":1930},
    "Vasco da Gama":        {"primary_color":"#000000","secondary_color":"#ffffff","national_titles":4,"international_titles":1,"founded_year":1898},
    "Vit\u00f3ria":         {"primary_color":"#cc0000","secondary_color":"#000000","national_titles":0,"international_titles":0,"founded_year":1899},

    # ── LIGA PROFESIONAL ARGENTINA ──────────────────────────────────
    "Boca Juniors":             {"primary_color":"#003087","secondary_color":"#f5d130","national_titles":35,"international_titles":6,"founded_year":1905},
    "River Plate":              {"primary_color":"#eb0029","secondary_color":"#ffffff","national_titles":38,"international_titles":4,"founded_year":1901},
    "Racing Club":              {"primary_color":"#00b0f0","secondary_color":"#ffffff","national_titles":18,"international_titles":1,"founded_year":1903},
    "Independiente":            {"primary_color":"#cc0000","secondary_color":"#ffffff","national_titles":16,"international_titles":7,"founded_year":1905},
    "San Lorenzo":              {"primary_color":"#c41a2a","secondary_color":"#000080","national_titles":15,"international_titles":1,"founded_year":1908},
    "Estudiantes de La Plata":  {"primary_color":"#cc0000","secondary_color":"#ffffff","national_titles":4,"international_titles":4,"founded_year":1905},
    "Velez Sarsfield":          {"primary_color":"#ffffff","secondary_color":"#003087","national_titles":10,"international_titles":1,"founded_year":1910},
    "Huracan":                  {"primary_color":"#cc3300","secondary_color":"#ffffff","national_titles":4,"international_titles":0,"founded_year":1908},

    # ── LIGA MX ─────────────────────────────────────────────────────
    "Club America":       {"primary_color":"#f5d130","secondary_color":"#003087","national_titles":14,"international_titles":0,"founded_year":1916},
    "Chivas Guadalajara": {"primary_color":"#cc0000","secondary_color":"#003087","national_titles":12,"international_titles":0,"founded_year":1906},
    "Cruz Azul":          {"primary_color":"#003087","secondary_color":"#ffffff","national_titles":10,"international_titles":0,"founded_year":1927},
    "Pumas UNAM":         {"primary_color":"#003087","secondary_color":"#f5d130","national_titles":7,"international_titles":0,"founded_year":1954},
    "Tigres UANL":        {"primary_color":"#f5d130","secondary_color":"#003087","national_titles":8,"international_titles":0,"founded_year":1960},
    "Monterrey":          {"primary_color":"#003087","secondary_color":"#cc0000","national_titles":5,"international_titles":0,"founded_year":1945},
    "Santos Laguna":      {"primary_color":"#006437","secondary_color":"#ffffff","national_titles":6,"international_titles":0,"founded_year":1983},
    "Toluca FC":          {"primary_color":"#cc0000","secondary_color":"#ffffff","national_titles":10,"international_titles":0,"founded_year":1917},
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

    print(f"\n{updated} clubes atualizados.")
    if not_found:
        print(f"\nSem dados específicos para {len(not_found)} clubes (só país traduzido):")
        for n in not_found:
            print(f"  - {n}")


if __name__ == "__main__":
    main()
