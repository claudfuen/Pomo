#!/usr/bin/env python3
"""
Generate app icon for Pomo - a minimal Pomodoro timer
Creates a beautiful tomato-inspired timer icon
"""

import os
import math

try:
    from PIL import Image, ImageDraw
except ImportError:
    print("Installing Pillow...")
    os.system("pip3 install Pillow")
    from PIL import Image, ImageDraw


def create_icon(size):
    """Create a tomato/timer icon at the specified size"""
    # Create image with transparency
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Colors - teal theme matching the app
    primary = (13, 148, 136)      # Teal #0D9488
    primary_dark = (15, 118, 110)  # Darker teal
    primary_light = (20, 184, 166) # Lighter teal
    stem_color = (34, 197, 94)     # Green for stem
    white = (255, 255, 255)
    
    padding = size * 0.08
    center = size / 2
    radius = (size - padding * 2) / 2
    
    # Draw main circle (tomato body) with gradient effect
    # Outer shadow/depth
    for i in range(3):
        offset = size * 0.01 * (3 - i)
        shadow_alpha = 30 + i * 10
        draw.ellipse(
            [padding + offset, padding + offset, 
             size - padding + offset, size - padding + offset],
            fill=(*primary_dark, shadow_alpha)
        )
    
    # Main body
    draw.ellipse(
        [padding, padding, size - padding, size - padding],
        fill=primary
    )
    
    # Highlight on top-left
    highlight_size = radius * 0.3
    highlight_offset = radius * 0.3
    draw.ellipse(
        [center - highlight_offset - highlight_size/2,
         center - highlight_offset - highlight_size/2,
         center - highlight_offset + highlight_size/2,
         center - highlight_offset + highlight_size/2],
        fill=(*primary_light, 100)
    )
    
    # Draw stem
    stem_width = size * 0.08
    stem_height = size * 0.12
    stem_x = center - stem_width / 2
    stem_y = padding - stem_height * 0.3
    
    # Stem rectangle with rounded top
    draw.rectangle(
        [stem_x, stem_y + stem_height * 0.3, 
         stem_x + stem_width, stem_y + stem_height],
        fill=stem_color
    )
    draw.ellipse(
        [stem_x, stem_y,
         stem_x + stem_width, stem_y + stem_height * 0.6],
        fill=stem_color
    )
    
    # Draw timer arc/progress indicator (white arc)
    arc_padding = size * 0.2
    arc_width = size * 0.06
    
    # Draw arc background (darker)
    draw.arc(
        [arc_padding, arc_padding, 
         size - arc_padding, size - arc_padding],
        start=-90, end=270,
        fill=(*primary_dark, 150),
        width=int(arc_width)
    )
    
    # Draw progress arc (white, 75% complete)
    draw.arc(
        [arc_padding, arc_padding, 
         size - arc_padding, size - arc_padding],
        start=-90, end=180,
        fill=white,
        width=int(arc_width)
    )
    
    # Add a small dot at the progress end
    angle = math.radians(180 - 90)  # Convert to radians, offset by -90
    dot_radius = arc_width * 0.6
    arc_radius = (size - arc_padding * 2) / 2
    dot_x = center + arc_radius * math.cos(angle)
    dot_y = center + arc_radius * math.sin(angle)
    
    draw.ellipse(
        [dot_x - dot_radius, dot_y - dot_radius,
         dot_x + dot_radius, dot_y + dot_radius],
        fill=white
    )
    
    return img


def create_dmg_background(width=600, height=400):
    """Create a beautiful DMG background"""
    img = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Gradient background - dark to darker
    for y in range(height):
        ratio = y / height
        r = int(24 + (18 - 24) * ratio)
        g = int(24 + (18 - 24) * ratio)
        b = int(27 + (22 - 27) * ratio)
        draw.line([(0, y), (width, y)], fill=(r, g, b))
    
    # Add subtle pattern
    primary = (13, 148, 136, 20)
    for i in range(0, width, 40):
        draw.line([(i, 0), (i + height, height)], fill=primary, width=1)
    
    # Arrow from left to right
    arrow_y = height // 2
    arrow_start = width * 0.35
    arrow_end = width * 0.65
    arrow_color = (13, 148, 136, 180)
    
    # Arrow line
    draw.line(
        [(arrow_start, arrow_y), (arrow_end - 20, arrow_y)],
        fill=arrow_color, width=3
    )
    
    # Arrow head
    draw.polygon([
        (arrow_end, arrow_y),
        (arrow_end - 25, arrow_y - 15),
        (arrow_end - 25, arrow_y + 15)
    ], fill=arrow_color)
    
    # Text hints
    # Left side: "Pomo" label area
    # Right side: "Applications" label area
    
    return img.convert('RGB')


def main():
    # Paths
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    iconset_path = os.path.join(project_root, "Pomo", "Assets.xcassets", "AppIcon.appiconset")
    assets_path = os.path.join(project_root, "assets")
    build_path = os.path.join(project_root, "build")
    
    # Create directories
    os.makedirs(assets_path, exist_ok=True)
    os.makedirs(build_path, exist_ok=True)
    
    # Icon sizes needed for macOS
    sizes = [
        (16, "icon_16x16.png"),
        (32, "icon_16x16@2x.png"),
        (32, "icon_32x32.png"),
        (64, "icon_32x32@2x.png"),
        (128, "icon_128x128.png"),
        (256, "icon_128x128@2x.png"),
        (256, "icon_256x256.png"),
        (512, "icon_256x256@2x.png"),
        (512, "icon_512x512.png"),
        (1024, "icon_512x512@2x.png"),
    ]
    
    print("🎨 Creating app icons...")
    for size, filename in sizes:
        icon = create_icon(size)
        filepath = os.path.join(iconset_path, filename)
        icon.save(filepath, "PNG")
        print(f"  ✓ {filename} ({size}x{size})")
    
    # Create README icon (larger, for GitHub)
    print("\n📁 Creating assets for README...")
    readme_icon = create_icon(512)
    readme_icon.save(os.path.join(assets_path, "icon.png"), "PNG")
    print("  ✓ assets/icon.png")
    
    # Create DMG background
    print("\n🖼️  Creating DMG background...")
    dmg_bg = create_dmg_background(600, 400)
    dmg_bg.save(os.path.join(build_path, "dmg_background.png"), "PNG")
    print("  ✓ build/dmg_background.png")
    
    # Update Contents.json with filenames
    contents_json = """{
  "images" : [
    {
      "filename" : "icon_16x16.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "16x16"
    },
    {
      "filename" : "icon_16x16@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "16x16"
    },
    {
      "filename" : "icon_32x32.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "32x32"
    },
    {
      "filename" : "icon_32x32@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "32x32"
    },
    {
      "filename" : "icon_128x128.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "128x128"
    },
    {
      "filename" : "icon_128x128@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "128x128"
    },
    {
      "filename" : "icon_256x256.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "256x256"
    },
    {
      "filename" : "icon_256x256@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "256x256"
    },
    {
      "filename" : "icon_512x512.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "512x512"
    },
    {
      "filename" : "icon_512x512@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "512x512"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
"""
    
    with open(os.path.join(iconset_path, "Contents.json"), "w") as f:
        f.write(contents_json)
    print("  ✓ Updated Contents.json")
    
    print("\n✅ All icons created successfully!")
    print("\nNext steps:")
    print("  1. Rebuild the app: xcodebuild -project Pomo.xcodeproj -scheme Pomo -configuration Release build")
    print("  2. Run create_dmg.sh to package the app")


if __name__ == "__main__":
    main()

