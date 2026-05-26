#!/usr/bin/env -S uv run --with pillow
"""Delete wallpapers that are too small, upscaled, or not dark-mode Catppuccin Mocha."""

import subprocess
import sys
from pathlib import Path
from PIL import Image, ImageFilter, ImageStat

WALLS_DIR = Path(__file__).parent / "walls-catppuccin-mocha"
IMAGE_EXTS = {".jpg", ".jpeg", ".png", ".gif"}
MAX_BRIGHTNESS = 80  # avg pixel brightness 0–255; above this = not dark mode
MIN_SHARPNESS = 30   # edge-map variance; below this = upscaled/blurry


def get_display_resolution() -> tuple[int, int]:
    try:
        from Quartz import CGGetActiveDisplayList, CGDisplayPixelsWide, CGDisplayPixelsHigh
        _, ids, _ = CGGetActiveDisplayList(8, None, None)
        return max(CGDisplayPixelsWide(d) for d in ids), max(CGDisplayPixelsHigh(d) for d in ids)
    except ImportError:
        pass
    out = subprocess.run(["system_profiler", "SPDisplaysDataType"], capture_output=True, text=True).stdout
    for line in out.splitlines():
        if "Resolution:" in line and "x" in line:
            parts = line.split(":")[1].split("x")
            return int(parts[0].strip().split()[0]), int(parts[1].strip().split()[0])
    raise RuntimeError("Cannot determine display resolution")


def deletion_reason(img: Image.Image, screen_w: int, screen_h: int) -> str | None:
    if img.width < screen_w or img.height < screen_h:
        return f"too small ({img.width}×{img.height})"

    gray = img.convert("L")

    brightness = ImageStat.Stat(gray).mean[0]
    if brightness > MAX_BRIGHTNESS:
        return f"not dark mode (avg brightness {brightness:.0f})"

    # Resize to fixed size so sharpness is comparable across resolutions
    edges = gray.resize((512, 512), Image.LANCZOS).filter(ImageFilter.FIND_EDGES)
    sharpness = ImageStat.Stat(edges).var[0]
    if sharpness < MIN_SHARPNESS:
        return f"upscaled/blurry (sharpness {sharpness:.1f})"

    return None


def main() -> None:
    dry_run = "--dry-run" in sys.argv
    screen_w, screen_h = get_display_resolution()
    print(f"Display: {screen_w}×{screen_h}")
    if dry_run:
        print("Dry run — nothing will be deleted\n")

    deleted = kept = 0
    for path in sorted(WALLS_DIR.iterdir()):
        if path.suffix.lower() not in IMAGE_EXTS:
            continue
        with Image.open(path) as img:
            reason = deletion_reason(img, screen_w, screen_h)
        if reason:
            print(f"  {'Would delete' if dry_run else 'Deleting'}: {path.name} ({reason})")
            if not dry_run:
                path.unlink()
            deleted += 1
        else:
            kept += 1

    print(f"\n{'Would delete' if dry_run else 'Deleted'} {deleted}, kept {kept}")


if __name__ == "__main__":
    main()
