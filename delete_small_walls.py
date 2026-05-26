#!/usr/bin/env python3
"""Delete wallpapers too small to fill the display without upscaling."""

import subprocess
import sys
from pathlib import Path

WALLS_DIR = Path(__file__).parent / "walls-catppuccin-mocha"
IMAGE_EXTS = {".jpg", ".jpeg", ".png", ".gif"}


def get_display_resolution() -> tuple[int, int]:
    try:
        from Quartz import CGGetActiveDisplayList, CGDisplayPixelsWide, CGDisplayPixelsHigh
        _, ids, _ = CGGetActiveDisplayList(8, None, None)
        w = max(CGDisplayPixelsWide(d) for d in ids)
        h = max(CGDisplayPixelsHigh(d) for d in ids)
        return w, h
    except ImportError:
        pass

    out = subprocess.run(
        ["system_profiler", "SPDisplaysDataType"],
        capture_output=True, text=True,
    ).stdout
    for line in out.splitlines():
        if "Resolution:" in line and "x" in line:
            parts = line.split(":")[1].split("x")
            return int(parts[0].strip().split()[0]), int(parts[1].strip().split()[0])

    raise RuntimeError("Cannot determine display resolution")


def image_size(path: Path) -> tuple[int, int]:
    out = subprocess.run(
        ["sips", "-g", "pixelWidth", "-g", "pixelHeight", str(path)],
        capture_output=True, text=True,
    ).stdout
    w = h = 0
    for line in out.splitlines():
        line = line.strip()
        if line.startswith("pixelWidth:"):
            w = int(line.split(":")[1])
        elif line.startswith("pixelHeight:"):
            h = int(line.split(":")[1])
    return w, h


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
        w, h = image_size(path)
        # Fill mode: upscaling needed if either dimension is smaller than screen
        if w < screen_w or h < screen_h:
            print(f"  {'Would delete' if dry_run else 'Deleting'}: {path.name} ({w}×{h})")
            if not dry_run:
                path.unlink()
            deleted += 1
        else:
            kept += 1

    print(f"\n{'Would delete' if dry_run else 'Deleted'} {deleted}, kept {kept}")


if __name__ == "__main__":
    main()
