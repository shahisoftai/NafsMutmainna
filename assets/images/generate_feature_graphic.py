#!/usr/bin/env python3
"""Generate Google Play Feature Graphic for NafsMutmainna (1024x500)."""

import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter

W, H = 1024, 500
import os; output_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "feature_graphic.png")

# ── Colours ──────────────────────────────────────────────
BG_DEEP    = (9, 30, 40)       # deep teal-navy
BG_DARK    = (5, 18, 26)       # almost black navy
GOLD       = (201, 164, 91)    # warm gold
GOLD_LIGHT = (220, 190, 130)   # lighter gold
CREAM      = (240, 234, 214)   # warm cream/white
TEAL_MID   = (40, 95, 100)     # mid teal
TEAL_DIM   = (25, 65, 70, 28)  # subtle teal (for patterns)

# ── Create canvas with gradient ──────────────────────────
img = Image.new("RGBA", (W, H), BG_DEEP)
pixels = img.load()
for y in range(H):
    r = (y / H) * 0.55 + 0.45  # blend factor
    for x in range(W):
        br = int(BG_DEEP[0] * (1 - r) + BG_DARK[0] * r)
        bg = int(BG_DEEP[1] * (1 - r) + BG_DARK[1] * r)
        bb = int(BG_DEEP[2] * (1 - r) + BG_DARK[2] * r)
        # subtle horizontal light streak near top
        streak = math.exp(-((y - 60) / 90) ** 2) * 12
        pixels[x, y] = (
            min(255, br + int(streak)),
            min(255, bg + int(streak)),
            min(255, bb + int(streak)),
            255,
        )

draw = ImageDraw.Draw(img)

# ── Font helpers ─────────────────────────────────────────
def load_font(size, weight="Regular"):
    family = "LeagueSpartan" if weight == "Light" else "NimbusSans"
    paths = {
        ("LeagueSpartan", "Light"): "/usr/share/fonts/opentype/league-spartan/LeagueSpartan-Light.otf",
        ("LeagueSpartan", "SemiBold"): "/usr/share/fonts/opentype/league-spartan/LeagueSpartan-SemiBold.otf",
        ("LeagueSpartan", "Black"): "/usr/share/fonts/opentype/league-spartan/LeagueSpartan-Black.otf",
        ("NimbusSans", "Regular"): "/usr/share/fonts/opentype/urw-base35/NimbusSans-Regular.otf",
        ("NimbusSans", "Bold"): "/usr/share/fonts/opentype/urw-base35/NimbusSans-Bold.otf",
        ("NimbusMono", "Regular"): "/usr/share/fonts/opentype/urw-base35/NimbusMonoPS-Regular.otf",
    }
    key = (family, weight)
    if key in paths:
        try:
            return ImageFont.truetype(paths[key], size)
        except Exception:
            pass
    return ImageFont.load_default()

f_title = load_font(56, "Black")        # NafsMutmainna
f_sub   = load_font(22, "SemiBold")     # Heart OS
f_tag   = load_font(15, "Light")        # tagline
f_feat   = load_font(14, "SemiBold")    # feature titles
f_feat_sub = load_font(12, "Regular")   # feature subtitles
f_footer = load_font(11, "Light")

# ── Islamic geometric ornament (top-right) ───────────────
def draw_eight_point_star(cx, cy, radius, color, width=1):
    """Draw an 8-point Islamic star."""
    points = []
    for i in range(8):
        angle = math.pi / 2 - i * math.pi / 4
        points.append((cx + radius * math.cos(angle), cy - radius * math.sin(angle)))
    for i in range(8):
        angle_inner = math.pi / 2 - (i + 0.5) * math.pi / 4
        points.append((cx + radius * 0.4 * math.cos(angle_inner), cy - radius * 0.4 * math.sin(angle_inner)))
    for i in range(8):
        p1 = points[i]
        p2 = points[8 + i]
        p3 = points[8 + (i + 1) % 8]
        draw.polygon([p1, p2, p3], fill=color)

def draw_geometric_border():
    """Subtle geometric pattern on right edge."""
    ox, oy = W - 140, 250
    for r in [120, 100, 80]:
        alpha = 12 if r > 100 else 20
        draw_eight_point_star(ox, oy, r, (*GOLD, alpha), 1)
    # outer circle
    draw.ellipse([ox - 135, oy - 135, ox + 135, oy + 135], outline=(*GOLD, 20), width=1)
    draw.ellipse([ox - 115, oy - 115, ox + 115, oy + 115], outline=(*GOLD, 12), width=1)

def draw_horizontal_rules():
    """Subtle gold horizontal lines."""
    y_positions = [95, 430]
    for yp in y_positions:
        for i in range(0, W, 40):
            draw.rectangle([i, yp, i + 20, yp + 1], fill=(*GOLD, 40))

# ── Geometric pattern background ─────────────────────────
draw_horizontal_rules()
draw_geometric_border()

# ── LEFT COLUMN: App name + logo ─────────────────────────
# Place logo (scaled)
try:
    logo = Image.open("/home/najeeb/Linux-Dev/NafsMutmainna/NafsMutmainna/assets/images/heartos_logo.png")
    logo_h = 120
    logo_w = int(logo_h * logo.width / logo.height)
    logo = logo.resize((logo_w, logo_h), Image.LANCZOS)
    # Center vertically in the left area
    logo_y = (H - logo_h) // 2
    img.paste(logo, (50, logo_y), logo)
    text_x = 50 + logo_w + 30
except Exception:
    text_x = 80

# App Title
title_y = 128
draw.text((text_x, title_y), "NafsMutmainna", fill=CREAM, font=f_title)

# Subtle gold underline
title_w = draw.textlength("NafsMutmainna", font=f_title)
draw.rectangle(
    [text_x, title_y + 68, text_x + title_w, title_y + 70],
    fill=GOLD,
)

# Subtitle
draw.text((text_x + 4, title_y + 82), "H E A R T   O S", fill=GOLD_LIGHT, font=f_sub)

# Tagline
draw.text((text_x + 4, title_y + 116), "Privacy-first Islamic Spiritual Self-Improvement", fill=TEAL_MID, font=f_tag)

# ── RIGHT COLUMN: Feature cards ──────────────────────────
# 6 features in a 3×2 grid
features = [
    ("Daily Check-In",    "50 emotions, intensity slider",        "🫀"),
    ("Nafs Meter",        "4 stations of the soul, live score",   "📊"),
    ("Sacred Remedies",   "Quran · Hadith · Dua · Dhikr",        "📖"),
    ("Growth Pathways",   "8 master spiritual pathways",          "🗺️"),
    ("Progress Tracking", "15-day journey, streak counter",       "📈"),
    ("100% Offline",      "No account, no ads, no AI needed",     "🔒"),
]

card_w = 220
card_h = 78
start_x = 550
start_y = 60
gap_x = 20
gap_y = 12
card_radius = 10

for i, (title, desc, icon) in enumerate(features):
    col = i % 3
    row = i // 3
    cx = start_x + col * (card_w + gap_x)
    cy = start_y + row * (card_h + gap_y)

    # Card background
    card_bg = Image.new("RGBA", (card_w, card_h), (255, 255, 255, 0))
    card_draw = ImageDraw.Draw(card_bg)
    card_draw.rounded_rectangle(
        [0, 0, card_w, card_h],
        radius=card_radius,
        fill=(10, 35, 45, 200),
        outline=(*GOLD, 70),
        width=1,
    )
    img.paste(card_bg, (cx, cy), card_bg)

    # Icon
    icon_size = 28
    icon_bg = Image.new("RGBA", (icon_size + 8, icon_size + 8), (0, 0, 0, 0))
    icon_draw = ImageDraw.Draw(icon_bg)
    icon_draw.rounded_rectangle(
        [0, 0, icon_size + 8, icon_size + 8],
        radius=6,
        fill=(*GOLD, 30),
    )
    img.paste(icon_bg, (cx + 10, cy + 12), icon_bg)
    draw.text((cx + 14 + icon_size // 2 - 6, cy + 14), icon, font=load_font(16, "Regular"))

    # Title
    draw.text((cx + 54, cy + 16), title, fill=CREAM, font=f_feat)
    # Description
    draw.text((cx + 54, cy + 40), desc, fill=(140, 188, 184), font=f_feat_sub)

# ── Bottom bar ────────────────────────────────────────────
draw.rectangle([0, H - 44, W, H], fill=(5, 15, 22, 255))
draw.text((30, H - 32), "Offline-First  ·  No Ads  ·  English / Urdu / Arabic  ·  Android  ·  iOS  ·  Web", fill=(100, 140, 138), font=f_footer)
draw.text((W - 150, H - 32), "v1.1.17", fill=(100, 140, 138), font=f_footer)

# ── Save ──────────────────────────────────────────────────
img = img.convert("RGB")
img.save(output_path, "PNG", optimize=True)
print(f"Saved {output_path} ({W}x{H})")
