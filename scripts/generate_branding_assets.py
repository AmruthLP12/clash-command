#!/usr/bin/env python3
"""
Clash Command — Brand Asset & Launcher Icon Generator.

Generates high-contrast, scalable raster assets for Clash Command:
- Master App Icon (512x512)
- Android Legacy Launcher Icons (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- Android Adaptive Foreground Icons (108x108 dp safe-zone compliant)
- Android Adaptive Background (XML & color values)
- Web favicon & PWA icons
"""

import math
import os
from PIL import Image, ImageDraw, ImageFilter

# Theme Colors
COLOR_BG = (26, 26, 26, 255)         # #1A1A1A Dark Charcoal
COLOR_BG_CARD = (36, 36, 36, 255)    # #242424 Surface
COLOR_GOLD_DARK = (138, 101, 32, 255) # #8A6520 Accent Dim
COLOR_GOLD = (183, 138, 46, 255)     # #B78A2E Accent Gold
COLOR_GOLD_LIGHT = (212, 168, 75, 255)# #D4A84B Accent Light
COLOR_EMERALD = (76, 175, 80, 255)   # #4CAF50 Active Upgrade Green
COLOR_WHITE = (245, 245, 245, 255)

SCALE = 4  # 4x supersampling for ultra-crisp antialiasing


def draw_master_icon(size=512, transparent_bg=False):
    """Draws the master emblem."""
    s = size * SCALE
    center = s / 2

    img = Image.new("RGBA", (s, s), (0, 0, 0, 0) if transparent_bg else COLOR_BG)
    draw = ImageDraw.Draw(img)

    if not transparent_bg:
        # Subtle rounded background container
        pad = s * 0.04
        draw.rounded_rectangle(
            [pad, pad, s - pad, s - pad],
            radius=s * 0.22,
            fill=(32, 32, 32, 255),
            outline=COLOR_GOLD_DARK,
            width=int(s * 0.015),
        )

    # 1. Hexagonal / Heraldic Shield Outline
    # Points for a strong fortress shield
    top = s * 0.16
    bottom = s * 0.84
    left = s * 0.18
    right = s * 0.82
    mid_y = s * 0.58

    shield_pts = [
        (center, top),
        (right, top + s * 0.08),
        (right, mid_y),
        (center, bottom),
        (left, mid_y),
        (left, top + s * 0.08),
    ]

    # Shield background fill
    draw.polygon(shield_pts, fill=(24, 24, 24, 255))

    # Outer Shield border (Gold)
    draw.polygon(shield_pts, outline=COLOR_GOLD, width=int(s * 0.024))

    # Inner shield accent border
    inner_inset = s * 0.03
    inner_shield_pts = [
        (center, top + inner_inset * 1.5),
        (right - inner_inset, top + s * 0.08 + inner_inset * 0.7),
        (right - inner_inset, mid_y - inner_inset * 0.3),
        (center, bottom - inner_inset * 1.4),
        (left + inner_inset, mid_y - inner_inset * 0.3),
        (left + inner_inset, top + s * 0.08 + inner_inset * 0.7),
    ]
    draw.polygon(inner_shield_pts, outline=COLOR_GOLD_DARK, width=int(s * 0.008))

    # 2. Architectural Fortress Tower (Silhouette)
    tower_w = s * 0.32
    tower_left = center - tower_w / 2
    tower_right = center + tower_w / 2
    tower_top = s * 0.30
    tower_bottom = s * 0.70

    # Tower body
    tower_pts = [
        (tower_left, tower_top + s * 0.06),
        (tower_left + tower_w * 0.1, tower_top + s * 0.06),
        (tower_left + tower_w * 0.1, tower_bottom),
        (tower_right - tower_w * 0.1, tower_bottom),
        (tower_right - tower_w * 0.1, tower_top + s * 0.06),
        (tower_right, tower_top + s * 0.06),
        (tower_right, tower_top),
        # Crenellations
        (tower_right - tower_w * 0.22, tower_top),
        (tower_right - tower_w * 0.22, tower_top + s * 0.025),
        (tower_left + tower_w * 0.45, tower_top + s * 0.025),
        (tower_left + tower_w * 0.45, tower_top),
        (tower_left + tower_w * 0.22, tower_top),
        (tower_left + tower_w * 0.22, tower_top + s * 0.025),
        (tower_left, tower_top + s * 0.025),
    ]
    draw.polygon(tower_pts, fill=(42, 42, 42, 255), outline=COLOR_GOLD_LIGHT, width=int(s * 0.01))

    # 3. Dynamic Upgrade Chevron / Arrow (Emerald & Gold)
    # Dual ascending chevrons symbolizing level progression
    ch_center_y = s * 0.48
    ch_w = s * 0.22
    ch_h = s * 0.09
    ch_thick = s * 0.045

    def draw_chevron(y_pos, color, fill_color):
        pts = [
            (center, y_pos - ch_h),
            (center + ch_w / 2, y_pos),
            (center + ch_w / 2, y_pos + ch_thick),
            (center, y_pos - ch_h + ch_thick),
            (center - ch_w / 2, y_pos + ch_thick),
            (center - ch_w / 2, y_pos),
        ]
        draw.polygon(pts, fill=fill_color, outline=color, width=int(s * 0.008))

    # Lower chevron: Gold
    draw_chevron(ch_center_y + s * 0.08, COLOR_GOLD_LIGHT, COLOR_GOLD)

    # Upper chevron: Vibrant Emerald (Upgrade in Progress)
    draw_chevron(ch_center_y - s * 0.02, (120, 220, 125, 255), COLOR_EMERALD)

    # 4. Timer / Gauge Accent Arc (Command timer motif)
    arc_rad = s * 0.35
    arc_box = [center - arc_rad, center - arc_rad - s * 0.03, center + arc_rad, center + arc_rad - s * 0.03]
    draw.arc(arc_box, start=210, end=330, fill=COLOR_GOLD_LIGHT, width=int(s * 0.012))

    # Downsample with Lanczos filter for crisp rendering
    return img.resize((size, size), Image.Resampling.LANCZOS)


def generate_all():
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    assets_dir = os.path.join(base_dir, "assets", "branding")
    os.makedirs(assets_dir, exist_ok=True)

    # 1. Master Logo (512x512)
    master = draw_master_icon(size=512, transparent_bg=False)
    master_path = os.path.join(assets_dir, "logo.png")
    master.save(master_path, "PNG")
    print(f"Created: {master_path}")

    # Master Transparent Logo
    master_trans = draw_master_icon(size=512, transparent_bg=True)
    master_trans_path = os.path.join(assets_dir, "logo_transparent.png")
    master_trans.save(master_trans_path, "PNG")
    print(f"Created: {master_trans_path}")

    # 2. Android Legacy Launcher Icons (ic_launcher.png)
    android_res = os.path.join(base_dir, "android", "app", "src", "main", "res")
    densities = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }

    for folder, size in densities.items():
        target_dir = os.path.join(android_res, folder)
        os.makedirs(target_dir, exist_ok=True)
        icon = draw_master_icon(size=size, transparent_bg=False)
        out_path = os.path.join(target_dir, "ic_launcher.png")
        icon.save(out_path, "PNG")
        print(f"Created: {out_path} ({size}x{size})")

    # 3. Android Adaptive Foreground (108dp safe zone)
    # The inner 66/72dp is safe from circular/squircle masking
    adaptive_densities = {
        "mipmap-mdpi": 108,
        "mipmap-hdpi": 162,
        "mipmap-xhdpi": 216,
        "mipmap-xxhdpi": 324,
        "mipmap-xxxhdpi": 432,
    }

    for folder, size in adaptive_densities.items():
        target_dir = os.path.join(android_res, folder)
        os.makedirs(target_dir, exist_ok=True)
        # In adaptive icons, emblem should occupy ~66% of canvas to fit within safe zone
        fg_icon = draw_master_icon(size=int(size * 0.76), transparent_bg=True)
        canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        offset = ((size - fg_icon.width) // 2, (size - fg_icon.height) // 2)
        canvas.paste(fg_icon, offset, fg_icon)
        out_path = os.path.join(target_dir, "ic_launcher_foreground.png")
        canvas.save(out_path, "PNG")
        print(f"Created: {out_path} ({size}x{size})")

    # 4. Adaptive XML definition in mipmap-anydpi-v26
    anydpi_dir = os.path.join(android_res, "mipmap-anydpi-v26")
    os.makedirs(anydpi_dir, exist_ok=True)
    xml_content = """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
"""
    with open(os.path.join(anydpi_dir, "ic_launcher.xml"), "w") as f:
        f.write(xml_content)
    print(f"Created: {os.path.join(anydpi_dir, 'ic_launcher.xml')}")

    # Colors.xml for background
    values_dir = os.path.join(android_res, "values")
    colors_xml = os.path.join(values_dir, "colors.xml")
    colors_content = """<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#1A1A1A</color>
</resources>
"""
    with open(colors_xml, "w") as f:
        f.write(colors_content)
    print(f"Created: {colors_xml}")

    # 5. Web Icons
    web_icons_dir = os.path.join(base_dir, "web", "icons")
    os.makedirs(web_icons_dir, exist_ok=True)
    draw_master_icon(size=192, transparent_bg=False).save(os.path.join(web_icons_dir, "Icon-192.png"))
    draw_master_icon(size=512, transparent_bg=False).save(os.path.join(web_icons_dir, "Icon-512.png"))
    draw_master_icon(size=192, transparent_bg=True).save(os.path.join(web_icons_dir, "Icon-maskable-192.png"))
    draw_master_icon(size=512, transparent_bg=True).save(os.path.join(web_icons_dir, "Icon-maskable-512.png"))
    draw_master_icon(size=64, transparent_bg=False).save(os.path.join(base_dir, "web", "favicon.png"))
    print("Created web icons and favicon.")


if __name__ == "__main__":
    generate_all()

