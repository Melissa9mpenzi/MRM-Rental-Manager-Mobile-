"""Generate Flutter web favicon/PWA icons from RentDirect logo."""

from __future__ import annotations

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "assets" / "images" / "rentdirect-logo.png"
WEB = ROOT / "web"


def crop_mark(source: Image.Image) -> Image.Image:
    w, h = source.size
    icon_h = int(h * 0.52)
    size = min(w, icon_h)
    left = (w - size) // 2
    return source.crop((left, 0, left + size, size))


def resize_square(source: Image.Image, size: int) -> Image.Image:
    return source.resize((size, size), Image.Resampling.LANCZOS)


def save_png(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, format="PNG", optimize=True)


def main() -> None:
    if not SOURCE.exists():
        raise SystemExit(f"Missing source logo: {SOURCE}")

    mark = crop_mark(Image.open(SOURCE).convert("RGBA"))

    save_png(resize_square(mark, 32), WEB / "favicon.png")
    save_png(resize_square(mark, 192), WEB / "icons" / "Icon-192.png")
    save_png(resize_square(mark, 512), WEB / "icons" / "Icon-512.png")
    save_png(resize_square(mark, 192), WEB / "icons" / "Icon-maskable-192.png")
    save_png(resize_square(mark, 512), WEB / "icons" / "Icon-maskable-512.png")

    print("Generated web icons from", SOURCE)


if __name__ == "__main__":
    main()
