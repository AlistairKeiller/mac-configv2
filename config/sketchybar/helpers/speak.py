#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = ["mlx-audio", "numpy", "misaki[en]", "soundfile"]
# ///
"""Copy the current selection and read it aloud via Kokoro TTS in IINA."""
import subprocess, tempfile, time, numpy as np, soundfile as sf
from mlx_audio.tts.utils import load_model

subprocess.run(["osascript", "-e", 'tell app "System Events" to keystroke "c" using command down'])
time.sleep(0.3)
t = subprocess.run(["pbpaste"], capture_output=True).stdout.decode().strip()
if not t: raise SystemExit
m = load_model("prince-canuma/Kokoro-82M")
p = tempfile.mktemp(suffix=".wav")
sf.write(p, np.concatenate([np.asarray(r.audio).flatten() for r in m.generate(text=t, voice="af_heart", speed=1.0, lang_code="a")]), 24000)
subprocess.Popen(["open", "-a", "IINA", p])
