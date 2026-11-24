#!/usr/bin/env python3
"""Generates the XCursor themes, "the mark", one per theme and cover colour."""
import os, struct, sys

SIZES = (24, 32, 48, 64)
def rgb(h): return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16))
COVERS = {
    "sky":    ("7DCFFF", "7DCFFF"),
    "indigo": ("2C3E60", "6D84AF"),
    "ochre":  ("CF9C42", "D7AD59"),
    "pine":   ("486455", "7C9987"),
    "plum":   ("7D3B56", "C47A98"),
    "umber":  ("6B4C3B", "B58E79"),
    "mint":   ("A6E3A1", "A6E3A1"),
    "sakura": ("F5C2E7", "F5C2E7"),
    "sand":   ("E1D2B0", "E1D2B0"),
}
THEMES = {}
for _n, (_p, _i) in COVERS.items():
    THEMES["rice-paper-" + _n] = {"ink": (0x1D, 0x1C, 0x1A), "red": rgb(_p)}
    THEMES["rice-ink-" + _n]   = {"ink": (0xE7, 0xE2, 0xD5), "red": rgb(_i)}

class Canvas:
    def __init__(self, n): self.n = n; self.px = list(list((0, 0, 0, 0) for _ in range(n)) for _ in range(n))
    def rect(self, x, y, w, h, rgb):
        for yy in range(max(0, y), min(self.n, y + h)):
            for xx in range(max(0, x), min(self.n, x + w)):
                self.px[yy][xx] = (*rgb, 255)

def arrow(s, c):
    cv = Canvas(s); m = max(1, round(s * 0.04)); u = round(s * 0.30); o = round(u * 0.667); r = round(u * 2.33)
    cv.rect(m + o, m + o, r, r, c["red"])
    cv.rect(m, m, u, u, c["ink"])
    return cv, m, m

def reticle(s, c):
    cv = Canvas(s); box = round(s * 0.75); arm = max(4, round(s * 0.2)); t = max(1, s // 24)
    o = (s - box) // 2; far = o + box - t
    for (x, y, dx, dy) in ((o, o, 1, 1), (far, o, -1, 1), (o, far, 1, -1), (far, far, -1, -1)):
        cv.rect(x if dx > 0 else x - arm + t, y, arm, t, c["ink"])
        cv.rect(x, y if dy > 0 else y - arm + t, t, arm, c["ink"])
    side = max(4, round(s * 0.25)); oc = (s - side) // 2
    cv.rect(oc, oc, side, side, c["red"]); return cv, s // 2, s // 2

def ibeam(s, c):
    cv = Canvas(s); t = max(1, s // 24); h = round(s * 0.7); w = round(s * 0.3)
    top = (s - h) // 2; cx = s // 2
    cv.rect(cx - t // 2, top, t, h, c["ink"])
    cv.rect(cx - w // 2, top, w, t, c["ink"]); cv.rect(cx - w // 2, top + h - t, w, t, c["ink"])
    return cv, s // 2, s // 2

def cross(s, c):
    cv = Canvas(s); t = max(1, s // 24); a = round(s * 0.7); o = (s - a) // 2
    cv.rect(o, s // 2 - t // 2, a, t, c["ink"]); cv.rect(s // 2 - t // 2, o, t, a, c["ink"])
    return cv, s // 2, s // 2

def _line(cv, x0, y0, x1, y1, t, rgb):
    n = int(max(abs(x1 - x0), abs(y1 - y0))) * 2 or 1
    for k in range(n + 1):
        x = x0 + (x1 - x0) * k / n; y = y0 + (y1 - y0) * k / n
        cv.rect(round(x - t / 2), round(y - t / 2), t, t, rgb)

def dumbbell(kind):
    def make(s, c):
        cv = Canvas(s); t = max(2, round(s / 12)); e = max(5, round(s * 0.22)); a, b = round(s * 0.14), round(s * 0.86)
        m = s // 2
        pts = {"h": (a, m, b, m), "v": (m, a, m, b), "d1": (a, a, b, b), "d2": (b, a, a, b)}.get(kind)
        x0, y0, x1, y1 = pts
        _line(cv, x0, y0, x1, y1, t, c["ink"])
        for (x, y) in ((x0, y0), (x1, y1)): cv.rect(x - e // 2, y - e // 2, e, e, c["ink"])
        return cv, s // 2, s // 2
    return make

def held(s, c):
    cv = Canvas(s); box = round(s * 0.58); arm = max(3, round(s * 0.15)); t = max(1, s // 24)
    o = (s - box) // 2; far = o + box - t
    for (x, y, dx, dy) in ((o, o, 1, 1), (far, o, -1, 1), (o, far, 1, -1), (far, far, -1, -1)):
        cv.rect(x if dx > 0 else x - arm + t, y, arm, t, c["ink"])
        cv.rect(x, y if dy > 0 else y - arm + t, t, arm, c["ink"])
    side = round(s * 0.32); oc = (s - side) // 2
    cv.rect(oc, oc, side, side, c["red"]); return cv, s // 2, s // 2

def xcursor(images):
    ntoc = len(images); head = b"Xcur" + struct.pack("<III", 16, 0x10000, ntoc)
    pos = 16 + 12 * ntoc; toc = b""; body = b""
    for size, cv, xh, yh in images:
        toc += struct.pack("<III", 0xFFFD0002, size, pos + len(body))
        chunk = struct.pack("<IIIIIIIII", 36, 0xFFFD0002, size, 1, cv.n, cv.n, xh, yh, 0)
        for row in cv.px:
            for (r, g, b, a) in row:
                chunk += struct.pack("<I", (a << 24) | (r * a // 255) << 16 | (g * a // 255) << 8 | (b * a // 255))
        body += chunk
    return head + toc + body

ALIASES = {
    "left_ptr": ("default", "arrow", "top_left_arrow", "left_ptr_watch", "wait", "watch", "progress", "half-busy",
                 "help", "question_arrow", "whats_this", "not-allowed", "crossed_circle", "no-drop", "dnd-none",
                 "copy", "alias", "context-menu", "zoom-in", "zoom-out"),
    "pointer": ("hand1", "hand2", "pointing_hand", "grab", "openhand"),
    "held":    ("grabbing", "closedhand", "move", "fleur", "all-scroll", "dnd-move", "dnd-copy", "dnd-link"),
    "text":    ("xterm", "ibeam", "vertical-text"),
    "cross":   ("crosshair", "tcross", "cell", "plus"),
    "resize_h":  ("e-resize", "w-resize", "ew-resize", "col-resize", "sb_h_double_arrow", "size_hor", "left_side",
                  "right_side", "h_double_arrow", "split_h"),
    "resize_v":  ("n-resize", "s-resize", "ns-resize", "row-resize", "sb_v_double_arrow", "size_ver", "top_side",
                  "bottom_side", "v_double_arrow", "split_v"),
    "resize_d1": ("nwse-resize", "nw-resize", "se-resize", "size_fdiag", "top_left_corner", "bottom_right_corner",
                  "fd_double_arrow"),
    "resize_d2": ("nesw-resize", "ne-resize", "sw-resize", "size_bdiag", "top_right_corner", "bottom_left_corner",
                  "bd_double_arrow"),
}
BASE = {"left_ptr": arrow, "pointer": reticle, "held": held, "text": ibeam, "cross": cross,
        "resize_h": dumbbell("h"), "resize_v": dumbbell("v"), "resize_d1": dumbbell("d1"), "resize_d2": dumbbell("d2")}

def main():
    it = iter(sys.argv); next(it, None)
    out = next(it, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "cursors"))
    for name, c in THEMES.items():
        d = os.path.join(out, name, "cursors"); os.makedirs(d, exist_ok=True)
        for base, fn in BASE.items():
            data = xcursor(list((s, *fn(s, c)) for s in SIZES))
            with open(os.path.join(d, base), "wb") as f: f.write(data)
            for alias in ALIASES.get(base, ()):
                p = os.path.join(d, alias)
                if os.path.lexists(p): os.remove(p)
                os.symlink(base, p)
        with open(os.path.join(out, name, "index.theme"), "w") as f:
            f.write("[Icon Theme]\nName=%s\nComment=The mark: a small square (rice, paper and ink)\n" % name)
        print("wrote", name)

if __name__ == "__main__": main()
