#!/usr/bin/env python3
"""
Create a clean, professional DMG background for Pomo
"""

from PIL import Image, ImageDraw, ImageFilter
import os

# DMG window size
WIDTH = 660
HEIGHT = 400

# Colors - dark theme matching the app
BG_TOP = (22, 22, 26)
BG_BOTTOM = (32, 32, 38)
TEAL = (13, 148, 136)


def create_background():
    # Create base image with gradient
    img = Image.new('RGB', (WIDTH, HEIGHT), BG_TOP)
    draw = ImageDraw.Draw(img)
    
    # Smooth vertical gradient
    for y in range(HEIGHT):
        ratio = y / HEIGHT
        r = int(BG_TOP[0] + (BG_BOTTOM[0] - BG_TOP[0]) * ratio)
        g = int(BG_TOP[1] + (BG_BOTTOM[1] - BG_TOP[1]) * ratio)
        b = int(BG_TOP[2] + (BG_BOTTOM[2] - BG_TOP[2]) * ratio)
        draw.line([(0, y), (WIDTH, y)], fill=(r, g, b))
    
    # Add subtle glow behind where app icon will be
    glow = Image.new('RGBA', (WIDTH, HEIGHT), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    
    # Glow at app icon position (x=165)
    for i in range(100, 0, -2):
        alpha = int(8 * (1 - i/100))
        glow_draw.ellipse([165-i, 180-i, 165+i, 180+i], fill=(TEAL[0], TEAL[1], TEAL[2], alpha))
    
    glow = glow.filter(ImageFilter.GaussianBlur(radius=30))
    
    # Composite glow onto background
    img = img.convert('RGBA')
    img = Image.alpha_composite(img, glow)
    
    # Draw the arrow
    draw = ImageDraw.Draw(img)
    arrow_y = 180
    arrow_start = 270
    arrow_end = 390
    
    # Dashed line
    dash_len = 12
    gap_len = 8
    x = arrow_start
    while x < arrow_end - 25:
        end_x = min(x + dash_len, arrow_end - 25)
        draw.line([(x, arrow_y), (end_x, arrow_y)], fill=TEAL, width=3)
        x += dash_len + gap_len
    
    # Arrow head
    draw.polygon([
        (arrow_end, arrow_y),
        (arrow_end - 18, arrow_y - 10),
        (arrow_end - 18, arrow_y + 10)
    ], fill=TEAL)
    
    return img.convert('RGB')


def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    build_path = os.path.join(project_root, "build")
    
    os.makedirs(build_path, exist_ok=True)
    
    print("🎨 Creating clean DMG background...")
    bg = create_background()
    bg.save(os.path.join(build_path, "dmg_background.png"), "PNG")
    print("  ✓ Done!")


if __name__ == "__main__":
    main()
