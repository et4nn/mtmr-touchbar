#!/usr/bin/env python3
"""Draws the small Touch Bar icons that items.json points to.

usage: make_icons.py <output dir>
Files that already exist are left alone, so you can drop in your own PNGs.
"""
import math
import os
import struct
import sys
import zlib

SIZE = 40
SS = 4  # samples per axis for antialiasing
GRAY = (185, 185, 185)


def write_png(path, shape):
    rows = []
    for y in range(SIZE):
        row = bytearray([0])
        for x in range(SIZE):
            r = g = b = hits = 0
            for i in range(SS):
                for j in range(SS):
                    c = shape(x + (i + .5) / SS, y + (j + .5) / SS)
                    if c:
                        r += c[0]; g += c[1]; b += c[2]; hits += 1
            if hits:
                row += bytes([round(r / hits), round(g / hits), round(b / hits),
                              round(255 * hits / (SS * SS))])
            else:
                row += bytes(4)
        rows.append(bytes(row))

    def chunk(tag, data):
        body = struct.pack('>I', len(data)) + tag + data
        return body + struct.pack('>I', zlib.crc32(tag + data) & 0xffffffff)

    png = (b'\x89PNG\r\n\x1a\n'
           + chunk(b'IHDR', struct.pack('>IIBBBBB', SIZE, SIZE, 8, 6, 0, 0, 0))
           + chunk(b'IDAT', zlib.compress(b''.join(rows)))
           + chunk(b'IEND', b''))
    with open(path, 'wb') as f:
        f.write(png)


def moon(x, y):
    x = (x - 20) / 0.82 + 20
    y = (y - 20) / 0.82 + 20
    outer = math.hypot(x - 19, y - 21)
    cut = math.hypot(x - 24.5, y - 16.5)
    if outer <= 15 and cut > 15.2:
        return (235, 195, 95) if outer >= 14 else GRAY


def shot(x, y):
    for cx, sx in ((8, 1), (32, -1)):
        for cy, sy in ((8, 1), (32, -1)):
            if abs(y - cy) <= 1.2 and -1.2 <= (x - cx) * sx <= 7.2:
                return GRAY
            if abs(x - cx) <= 1.2 and -1.2 <= (y - cy) * sy <= 7.2:
                return GRAY
    if math.hypot(x - 20, y - 20) <= 2.2:
        return GRAY


def lock(x, y):
    d = math.hypot(x - 20, y - 19)
    body = 11 <= x <= 29 and 19 <= y <= 33
    shackle = 5.2 <= d <= 7.8 and y <= 19
    hole = math.hypot(x - 20, y - 25) <= 2.2 or (abs(x - 20) <= 0.9 and 25 <= y <= 29.5)
    if (body or shackle) and not hole:
        return GRAY


def spark(x, y):
    dx, dy = x - 20, y - 20
    if math.hypot(dx, dy) <= 3:
        return GRAY
    for k in range(4):
        a = k * math.pi / 4
        along = dx * math.cos(a) + dy * math.sin(a)
        across = -dx * math.sin(a) + dy * math.cos(a)
        if abs(along) <= 15 and abs(across) <= 1.4:
            return GRAY


def note(x, y):
    head = ((x - 14) / 5.5) ** 2 + ((y - 29) / 4.2) ** 2 <= 1
    stem = 17.8 <= x <= 20.2 and 9 <= y <= 29
    t = x - 20.2
    flag = 0 <= t <= 9 and 9 + t * 0.55 <= y <= 14 + t * 0.55
    if head or stem or flag:
        return GRAY


def play(x, y):
    cx = min(max(x, 12), 28)
    cy = min(max(y, 17), 23)
    box = math.hypot(x - cx, y - cy) <= 6
    tri = x >= 16 and abs(y - 20) <= 5 * (26 - x) / 10
    if box and not tri:
        return GRAY


ICONS = {
    'moon.png': moon,
    'icon-shot.png': shot,
    'icon-lock.png': lock,
    'claude.png': spark,
    'icon-sp.png': note,
    'icon-yt.png': play,
}

if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else '.'
    os.makedirs(out, exist_ok=True)
    for name, fn in ICONS.items():
        path = os.path.join(out, name)
        if os.path.exists(path):
            continue
        write_png(path, fn)
        print('wrote', name)
