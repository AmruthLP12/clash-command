#!/usr/bin/env python3
"""
Generates lightweight, subtle, original procedural 16-bit mono 44.1kHz WAV sound effects
for Clash Command interactions. 100% royalty-free and copyright-safe.
"""

import math
import os
import struct
import wave

SAMPLE_RATE = 44100

def create_wav(filename, samples):
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with wave.open(filename, 'wb') as wf:
        wf.setnchannels(1)        # mono
        wf.setsampwidth(2)        # 16-bit
        wf.setframerate(SAMPLE_RATE)
        packed = struct.pack(f'<{len(samples)}h', *[int(max(-32767, min(32767, s))) for s in samples])
        wf.writeframes(packed)

def generate_button_tap(path):
    # Short subtle soft pop / click (40ms)
    duration = 0.045
    total_frames = int(SAMPLE_RATE * duration)
    samples = []
    freq = 600.0
    for i in range(total_frames):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 80.0)
        # Sine with slight frequency drop
        f = freq * (1.0 - t * 5.0)
        s = math.sin(2.0 * math.pi * f * t) * env * 14000
        samples.append(s)
    create_wav(path, samples)

def generate_village_switch(path):
    # Gentle double-tone swoosh / bubble pop (120ms)
    duration = 0.12
    total_frames = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(total_frames):
        t = i / SAMPLE_RATE
        if t < 0.06:
            env = math.sin(math.pi * (t / 0.06))
            f = 440.0 + t * 800.0
        else:
            t2 = t - 0.06
            env = math.exp(-t2 * 35.0)
            f = 660.0 + t2 * 400.0
        s = math.sin(2.0 * math.pi * f * t) * env * 15000
        samples.append(s)
    create_wav(path, samples)

def generate_upgrade_start(path):
    # Uplifting resonant harmonic chime (250ms)
    duration = 0.28
    total_frames = int(SAMPLE_RATE * duration)
    samples = []
    # Two harmonic notes: C5 (523Hz) -> G5 (784Hz)
    for i in range(total_frames):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 9.0)
        f1 = 523.25
        f2 = 783.99
        s = (math.sin(2.0 * math.pi * f1 * t) * 0.5 + 
             math.sin(2.0 * math.pi * f2 * t) * 0.5) * env * 18000
        samples.append(s)
    create_wav(path, samples)

def generate_upgrade_complete(path):
    # Rewarding victory chime arpeggio: C5 -> E5 -> G5 -> C6 (450ms)
    duration = 0.45
    total_frames = int(SAMPLE_RATE * duration)
    samples = []
    notes = [523.25, 659.25, 783.99, 1046.50]
    note_dur = duration / len(notes)
    for i in range(total_frames):
        t = i / SAMPLE_RATE
        note_idx = min(int(t / note_dur), len(notes) - 1)
        local_t = t - (note_idx * note_dur)
        f = notes[note_idx]
        env = math.exp(-local_t * 12.0)
        s = math.sin(2.0 * math.pi * f * t) * env * 19000
        samples.append(s)
    create_wav(path, samples)

def generate_item_add(path):
    # Quick pleasant ascending pop (150ms)
    duration = 0.15
    total_frames = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(total_frames):
        t = i / SAMPLE_RATE
        env = math.sin(math.pi * (t / duration)) ** 1.5
        f = 480.0 + (t / duration) * 360.0
        s = math.sin(2.0 * math.pi * f * t) * env * 16000
        samples.append(s)
    create_wav(path, samples)

def generate_confirm(path):
    # Affirmative gentle chime (180ms)
    duration = 0.20
    total_frames = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(total_frames):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 14.0)
        f = 880.0
        s = math.sin(2.0 * math.pi * f * t) * env * 17000
        samples.append(s)
    create_wav(path, samples)

def generate_error(path):
    # Subtle muted low double thud (160ms)
    duration = 0.16
    total_frames = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(total_frames):
        t = i / SAMPLE_RATE
        if t < 0.08:
            env = math.exp(-t * 30.0)
            f = 160.0
        else:
            t2 = t - 0.08
            env = math.exp(-t2 * 30.0)
            f = 130.0
        s = math.sin(2.0 * math.pi * f * t) * env * 17000
        samples.append(s)
    create_wav(path, samples)

def generate_ambient_music(path):
    # Gentle calm looping ambient acoustic drone/arpeggio (5 seconds, seamless loop)
    duration = 5.0
    total_frames = int(SAMPLE_RATE * duration)
    samples = []
    # Peaceful harmonic drone chord: D3 (146.8Hz), A3 (220.0Hz), D4 (293.7Hz), F#4 (370.0Hz)
    freqs = [146.83, 220.00, 293.66, 369.99]
    for i in range(total_frames):
        t = i / SAMPLE_RATE
        # Loopable modulation (integer cycles across 5 seconds)
        lfo = 0.7 + 0.3 * math.sin(2.0 * math.pi * (1.0 / duration) * t)
        val = 0.0
        for f in freqs:
            val += math.sin(2.0 * math.pi * f * t)
        val = (val / len(freqs)) * lfo * 7000
        samples.append(val)
    create_wav(path, samples)

if __name__ == '__main__':
    base_dir = os.path.join(os.path.dirname(__file__), '..', 'assets', 'audio')
    generate_button_tap(os.path.join(base_dir, 'button_tap.wav'))
    generate_village_switch(os.path.join(base_dir, 'village_switch.wav'))
    generate_upgrade_start(os.path.join(base_dir, 'upgrade_start.wav'))
    generate_upgrade_complete(os.path.join(base_dir, 'upgrade_complete.wav'))
    generate_item_add(os.path.join(base_dir, 'item_add.wav'))
    generate_confirm(os.path.join(base_dir, 'confirm.wav'))
    generate_error(os.path.join(base_dir, 'error.wav'))
    generate_ambient_music(os.path.join(base_dir, 'ambient_loop.wav'))
    print("Successfully generated all audio assets.")

