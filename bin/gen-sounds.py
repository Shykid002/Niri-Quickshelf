#!/usr/bin/env python3
"""Generates the rice's sounds (soft sine tones) into quickshell/assets/sounds:
   plug.wav (charger in), unplug.wav (charger out), tick.wav (volume step), alarm.wav (timer), notify.wav (new notification)."""
import math, os, struct, sys, wave
R = 44100
def tone(freq, dur, amp=0.45, fade=0.012):
    n = int(R * dur); out = []
    for i in range(n):
        t = i / R; env = min(1.0, t / fade, (dur - t) / fade)
        out.append(amp * env * math.sin(2 * math.pi * freq * t))
    return out
def bell(freq, dur, amp=0.42):
    n = int(R * dur); out = []
    for i in range(n):
        t = i / R; env = min(1.0, t / 0.004) * math.exp(-t * 9)
        out.append(amp * env * (math.sin(2 * math.pi * freq * t) + 0.25 * math.sin(2 * math.pi * freq * 2 * t)))
    return out
def mix(a, b, offset):
    out = list(a) + [0.0] * max(0, offset + len(b) - len(a))
    for i, v in enumerate(b): out[offset + i] += v
    return out
def gap(dur): return [0.0] * int(R * dur)
def save(name, samples, d):
    with wave.open(os.path.join(d, name), "wb") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(R)
        w.writeframes(b"".join(struct.pack("<h", int(max(-1, min(1, s)) * 32767)) for s in samples))
d = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "quickshell", "assets", "sounds")
os.makedirs(d, exist_ok=True)
save("plug.wav",   tone(660, 0.09) + tone(990, 0.16), d)
save("unplug.wav", tone(990, 0.09) + tone(660, 0.16), d)
save("tick.wav",   tone(1400, 0.035, amp=0.35, fade=0.006), d)
save("notify.wav", mix(bell(988, 0.42), bell(1319, 0.5), int(R * 0.11)), d)
alarm = []
for _ in range(4): alarm += tone(1000, 0.16, amp=0.5) + gap(0.10)
save("alarm.wav",  alarm, d)
print("wrote sounds to", d)
