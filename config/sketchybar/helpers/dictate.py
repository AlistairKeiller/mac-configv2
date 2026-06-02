#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = ["mlx-whisper", "sounddevice", "numpy"]
# ///
"""Record while /tmp/dictate.flag exists; on flag removal, transcribe and paste."""
import os, subprocess, time, numpy as np, sounddevice as sd, mlx_whisper

SR, FLAG, buf = 16000, "/tmp/dictate.flag", []
def cb(d, *_): buf.append(d.copy())
with sd.InputStream(samplerate=SR, channels=1, dtype="float32", callback=cb):
    while os.path.exists(FLAG): time.sleep(0.05)
a = np.concatenate(buf).flatten() if buf else np.empty(0, "float32")
if a.size < SR // 4: raise SystemExit
t = mlx_whisper.transcribe(a, path_or_hf_repo="mlx-community/whisper-large-v3-turbo")["text"].strip()
if not t: raise SystemExit
old = subprocess.run(["pbpaste"], capture_output=True).stdout
subprocess.run(["pbcopy"], input=(t + " ").encode())
subprocess.run(["osascript", "-e", 'tell app "System Events" to keystroke "v" using command down'])
time.sleep(0.08)
subprocess.run(["pbcopy"], input=old)
