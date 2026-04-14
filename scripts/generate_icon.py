"""
Gera o ícone do app Futdle (1024x1024 px).
Requer: pip install Pillow
"""
from PIL import Image, ImageDraw, ImageFont
import os

SIZE = 1024
OUT_DIR = os.path.join(os.path.dirname(__file__), '..', 'futdle', 'assets', 'icons')
os.makedirs(OUT_DIR, exist_ok=True)

# Cores do tema
BG      = (17, 24, 39)    # #111827
GREEN   = (34, 197, 94)   # #22C55E
WHITE   = (255, 255, 255)

img  = Image.new('RGBA', (SIZE, SIZE), BG)
draw = ImageDraw.Draw(img)

# --- Círculo verde de fundo ---
margin = 80
draw.ellipse([margin, margin, SIZE - margin, SIZE - margin],
             fill=GREEN)

# --- Letra "F" centralizada ---
cx, cy = SIZE // 2, SIZE // 2

# Tenta carregar fonte bold; cai de volta para a padrão do Pillow
font = None
for path in [
    "C:/Windows/Fonts/arialbd.ttf",
    "C:/Windows/Fonts/Arial Bold.ttf",
    "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
]:
    if os.path.exists(path):
        try:
            font = ImageFont.truetype(path, 560)
            break
        except Exception:
            pass

if font is None:
    font = ImageFont.load_default()

text = "F"
bbox = draw.textbbox((0, 0), text, font=font)
tw = bbox[2] - bbox[0]
th = bbox[3] - bbox[1]
x = cx - tw // 2 - bbox[0]
y = cy - th // 2 - bbox[1] - 20   # ajuste visual

draw.text((x, y), text, font=font, fill=BG)

# --- Salva ---
out_path = os.path.join(OUT_DIR, 'icon.png')
img.save(out_path)
print(f"Icone salvo em: {out_path}")
