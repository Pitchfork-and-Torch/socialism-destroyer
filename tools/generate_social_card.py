"""Generate 1200x630 Open Graph / Twitter Card preview for Socialism Destroyer."""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
WEB = ROOT / "web"
ICON = WEB / "icons" / "Icon-512.png"
OUT = WEB / "twitter-card.png"

NAVY = (10, 22, 40)
GOLD = (232, 201, 106)
SILVER = (184, 194, 206)
WIDTH, HEIGHT = 1200, 630


def _font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = []
    if bold:
        candidates += [
            "C:/Windows/Fonts/georgiab.ttf",
            "C:/Windows/Fonts/timesbd.ttf",
            "/usr/share/fonts/truetype/dejavu/DejaVuSerif-Bold.ttf",
        ]
    else:
        candidates += [
            "C:/Windows/Fonts/georgia.ttf",
            "C:/Windows/Fonts/times.ttf",
            "/usr/share/fonts/truetype/dejavu/DejaVuSerif.ttf",
        ]
    for path in candidates:
        if Path(path).exists():
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()


def main() -> None:
    canvas = Image.new("RGB", (WIDTH, HEIGHT), NAVY)
    draw = ImageDraw.Draw(canvas)

    # Subtle gold accent line
    draw.rectangle((0, 0, WIDTH, 6), fill=GOLD)

    icon = Image.open(ICON).convert("RGBA")
    icon_size = 280
    icon = icon.resize((icon_size, icon_size), Image.Resampling.LANCZOS)
    canvas.paste(icon, (72, (HEIGHT - icon_size) // 2), icon)

    x = 72 + icon_size + 48
    title_font = _font(54, bold=True)
    sub_font = _font(28)
    tag_font = _font(22)

    draw.text((x, 168), "Socialism Destroyer", font=title_font, fill=GOLD)
    draw.text(
        (x, 238),
        "The Pro-America Liberty",
        font=sub_font,
        fill=SILVER,
    )
    draw.text((x, 276), "Argument Engine", font=sub_font, fill=SILVER)

    bullets = [
        "Fully sourced claim vs. counterclaim",
        "Argument Crusher · 35+ PD classics",
        "100% free — no account required",
    ]
    y = 340
    for line in bullets:
        draw.ellipse((x, y + 10, x + 8, y + 18), fill=GOLD)
        draw.text((x + 20, y), line, font=tag_font, fill=SILVER)
        y += 38

    draw.text((x, HEIGHT - 56), "destroyer.jonbailey.xyz", font=tag_font, fill=GOLD)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(OUT, format="PNG", optimize=True)
    print(f"Wrote {OUT} ({WIDTH}x{HEIGHT})")


if __name__ == "__main__":
    main()