#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11,<3.14"
# dependencies = ["pillow", "torch", "torchvision", "timm>=1,<2", "huggingface-hub", "safetensors"]
# ///
"""Filter wallpapers by resolution and estimated AI score. Preview with --dry-run."""

import argparse
import re
import subprocess
from collections import Counter
from pathlib import Path

import timm
import torch
from huggingface_hub import hf_hub_download
from PIL import Image, ImageOps
from safetensors.torch import load_file
from torchvision import transforms

WALLS_DIR = Path(__file__).parent / "wallpapers"
IMAGE_EXTS = {".jpg", ".jpeg", ".png", ".gif", ".webp"}
# Official Community Forensics checkpoint (MIT): https://huggingface.co/OwensLab/commfor-model-384
MODEL = "OwensLab/commfor-model-384"
MODEL_REVISION = "6076002bf0d9dd37537f965ee2f06f826c333b61"
# Match the authors' test preprocessing: resize short side, crop, normalize.
PREPROCESS = transforms.Compose([
    transforms.Resize(440), transforms.CenterCrop(384), transforms.ToTensor(),
    transforms.Normalize((0.485, 0.456, 0.406), (0.229, 0.224, 0.225)),
])


def get_display_resolution() -> tuple[int, int]:
    out = subprocess.run(
        ["system_profiler", "SPDisplaysDataType"],
        capture_output=True, text=True, check=True,
    ).stdout
    sizes = re.findall(r"Resolution:\s*(\d+)\s*x\s*(\d+)", out)
    if not sizes:
        raise RuntimeError("Cannot determine display resolution; use --min-size WIDTH HEIGHT")
    return max(int(w) for w, _ in sizes), max(int(h) for _, h in sizes)


def assess(img, min_size, detector, threshold) -> tuple[str, str]:
    """Return one category per image, checking resolution before AI."""
    img = ImageOps.exif_transpose(img)
    if img.width < min_size[0] or img.height < min_size[1]:
        return "Resolution", f"{img.width}×{img.height}"
    img = img.convert("RGBA")
    rgb = Image.alpha_composite(Image.new("RGBA", img.size, "black"), img).convert("RGB")
    pixels = PREPROCESS(rgb).unsqueeze(0).to(next(detector.parameters()).device)
    with torch.inference_mode():
        score = detector(pixels).sigmoid().item()
    return "Suspected AI" if score >= threshold else "Kept", f"AI score {score:.3f}"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true", help="Preview without deleting")
    parser.add_argument("--min-size", type=int, nargs=2, metavar=("WIDTH", "HEIGHT"),
                        help="Minimum pixel dimensions (default: attached displays)")
    parser.add_argument("--ai-threshold", type=float, default=0.5,
                        help="Reject AI scores at or above this cutoff (default: 0.5)")
    args = parser.parse_args()
    if args.min_size and min(args.min_size) <= 0:
        parser.error("--min-size dimensions must be positive")
    if not 0 < args.ai_threshold <= 1:
        parser.error("--ai-threshold must be greater than 0 and at most 1")
    min_size = args.min_size or get_display_resolution()
    print(f"Minimum: {min_size[0]}×{min_size[1]}; AI cutoff: {args.ai_threshold:.3f}", flush=True)
    detector = timm.create_model("vit_small_patch16_384", pretrained=False, num_classes=1)
    weights = load_file(hf_hub_download(MODEL, "model.safetensors", revision=MODEL_REVISION))
    detector.load_state_dict({key.removeprefix("vit."): value for key, value in weights.items()})
    detector.to("mps" if torch.backends.mps.is_available() else "cpu").eval()
    counts = Counter()
    action = "Would delete" if args.dry_run else "Deleted"
    for path in sorted(WALLS_DIR.iterdir()):
        if not path.is_file() or path.suffix.lower() not in IMAGE_EXTS:
            continue
        try:
            with Image.open(path) as img:
                category, detail = assess(img, min_size, detector, args.ai_threshold)
            if category != "Kept" and not args.dry_run:
                path.unlink()
        except (OSError, ValueError, Image.DecompressionBombError) as exc:
            print(f"  Error: {path.name} ({exc})")
            counts["Errors"] += 1
            continue
        counts[category] += 1
        print(f"  {'Keeping' if category == 'Kept' else action}: {path.name} ({category}: {detail})")
    print(f"\n{'Dry run — no files deleted' if args.dry_run else 'Cleanup complete'}")
    print(f"  Images processed: {counts.total()}")
    print(f"  {action}: {counts['Resolution'] + counts['Suspected AI']}")
    print(f"    Resolution:   {counts['Resolution']}")
    print(f"    Suspected AI: {counts['Suspected AI']}")
    print(f"  {'Would keep' if args.dry_run else 'Kept'}: {counts['Kept']}")
    print(f"  Errors: {counts['Errors']}")
    print("  Each rejection is counted once; resolution is checked before AI.")
    if counts["Errors"]:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
