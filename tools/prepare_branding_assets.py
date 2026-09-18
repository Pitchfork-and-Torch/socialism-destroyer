"""Prepare app icon + splash masters from the selected concept image."""

from __future__ import annotations

import os
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
BRANDING = ROOT / "assets" / "images" / "branding"
CONCEPT = BRANDING / "concepts" / "concept_c_scales_star.jpg"
NAVY = (10, 22, 40)  # #0A1628


def _is_navy(px: tuple[int, int, int], tol: int = 28) -> bool:
    return all(abs(px[i] - NAVY[i]) <= tol for i in range(3))


def make_foreground(src: Image.Image, size: int = 1024) -> Image.Image:
    """Gold motif on transparent background for adaptive icons."""
    rgb = src.convert("RGB")
    rgba = Image.new("RGBA", rgb.size)
    pixels = rgb.load()
    out = rgba.load()
    for y in range(rgb.height):
        for x in range(rgb.width):
            px = pixels[x, y]
            if _is_navy(px):
                out[x, y] = (0, 0, 0, 0)
            else:
                out[x, y] = (*px, 255)
    # Trim transparent margins, then pad to square with safe zone.
    bbox = rgba.getbbox()
    if not bbox:
        return rgba
    cropped = rgba.crop(bbox)
    side = max(cropped.width, cropped.height)
    canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    ox = (side - cropped.width) // 2
    oy = (side - cropped.height) // 2
    canvas.paste(cropped, (ox, oy))
    padded = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    scale = int(size * 0.72)
    resized = canvas.resize((scale, scale), Image.Resampling.LANCZOS)
    px = (size - scale) // 2
    padded.paste(resized, (px, px), resized)
    return padded


def make_splash_logo(foreground: Image.Image, size: int = 512) -> Image.Image:
    """Centered motif for native splash overlay."""
    logo = foreground.resize((int(size * 0.42), int(size * 0.42)), Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    px = (size - logo.width) // 2
    py = (size - logo.height) // 2
    canvas.paste(logo, (px, py), logo)
    return canvas


def make_maskable(src: Image.Image, size: int = 1024) -> Image.Image:
    """Android maskable icon with extra padding."""
    fg = make_foreground(src, size=size)
    canvas = Image.new("RGBA", (size, size), (*NAVY, 255))
    scale = int(size * 0.58)
    logo = fg.resize((scale, scale), Image.Resampling.LANCZOS)
    px = (size - scale) // 2
    py = (size - scale) // 2
    canvas.paste(logo, (px, py), logo)
    return canvas


def main() -> None:
    BRANDING.mkdir(parents=True, exist_ok=True)
    src = Image.open(CONCEPT).convert("RGB")
    src.save(BRANDING / "app_icon.png", optimize=True)

    foreground = make_foreground(src)
    foreground.save(BRANDING / "app_icon_foreground.png", optimize=True)

    splash = make_splash_logo(foreground)
    splash.save(BRANDING / "splash_logo.png", optimize=True)

    maskable = make_maskable(src)
    maskable.save(BRANDING / "app_icon_maskable.png", optimize=True)

    # README / docs preview (splash composition).
    splash_preview = Image.new("RGB", (1280, 720), NAVY)
    logo = splash.resize((220, 220), Image.Resampling.LANCZOS)
    px = (splash_preview.width - logo.width) // 2
    py = (splash_preview.height - logo.height) // 2 - 20
    splash_preview.paste(logo, (px, py), logo)
    splash_preview.save(BRANDING / "splash_preview.png", optimize=True)
    src.resize((256, 256), Image.Resampling.LANCZOS).save(
        BRANDING / "app_icon_preview.png", optimize=True
    )

    print("Branding assets written to", BRANDING)


if __name__ == "__main__":
    main()