#!/usr/bin/env python3

import sys
import subprocess
import time
import random

# ---------------------------------
# Faster + Shorter + More Natural Curved Mouse Signal Tool
# ---------------------------------

DISTANCE_SCALE = 0.8       # 20% shorter movement
DURATION_SCALE = 0.64      # additional 20% faster than previous 0.8
CURVE_RANDOMNESS = 70      # more curve variation


def get_cursor():
    out = subprocess.check_output(
        ["hyprctl", "cursorpos"],
        text=True
    ).strip()

    x, y = out.split(", ")
    return int(float(x)), int(float(y))


def move_cursor(x, y):
    subprocess.run(
        ["hyprctl", "dispatch", "movecursor", str(x), str(y)],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL
    )


def bezier_point(p0, p1, p2, t):
    x = (1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t ** 2 * p2[0]
    y = (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t ** 2 * p2[1]
    return x, y


def bezier_move(x1, y1, x2, y2, duration=0.64, fps=144):
    frames = max(1, int(duration * fps))

    ctrl_x = (x1 + x2) / 2 + random.randint(-CURVE_RANDOMNESS, CURVE_RANDOMNESS)
    ctrl_y = (y1 + y2) / 2 + random.randint(-CURVE_RANDOMNESS, CURVE_RANDOMNESS)

    p0 = (x1, y1)
    p1 = (ctrl_x, ctrl_y)
    p2 = (x2, y2)

    for i in range(frames + 1):
        t = i / frames
        x, y = bezier_point(p0, p1, p2, t)
        move_cursor(round(x), round(y))
        time.sleep(1 / fps)


def signal(letter):
    base_mapping = {
        "A": (0, -250),
        "B": (250, 0),
        "C": (0, 250),
        "D": (-250, 0)
    }

    if letter not in base_mapping:
        print(f"Invalid letter: {letter}")
        return

    dx, dy = base_mapping[letter]
    dx *= DISTANCE_SCALE
    dy *= DISTANCE_SCALE

    cx, cy = get_cursor()
    tx, ty = cx + dx, cy + dy

    print(f"Signal {letter}: moving to ({int(tx)}, {int(ty)})")

    bezier_move(cx, cy, tx, ty, duration=1.0 * DURATION_SCALE)
    time.sleep(0.16)
    bezier_move(tx, ty, cx, cy, duration=1.0 * DURATION_SCALE)
    time.sleep(0.20)


def main():
    if len(sys.argv) < 2:
        print("Usage: python bezier_mouse.py B")
        print("   or: python bezier_mouse.py A,C")
        sys.exit(1)

    raw = sys.argv[1].upper()
    chars = [x.strip() for x in raw.split(",") if x.strip() in ["A", "B", "C", "D"]]

    if not chars:
        print("No valid letters found.")
        sys.exit(1)

    for ch in chars:
        signal(ch)


if __name__ == "__main__":
    main()