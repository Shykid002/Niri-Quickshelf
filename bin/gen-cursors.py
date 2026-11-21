#!/usr/bin/env python3
"""Generates the two XCursor themes, "the mark":
     rice-ink-dark   dark mark   (for the paper theme)
     rice-ink-light  light mark  (for the ink theme)
   arrow/default = small solid square   pointer/hand = bracketed reticle with a vermilion centre
   text = thin I-beam                   everything else falls back to the square
Usage: gen-cursors.py [output_dir]      (default: ../cursors next to this script)"""
import os, struct, sys

SIZES = [24, 32, 48, 64]
THEMES = {
    "rice-ink-dark":  {"ink": (0x1D, 0x1C, 0x1A), "red": (0xCA, 0x4C, 0x29)},
    "rice-ink-light": {"ink": (0xE7, 0xE2, 0xD5), "red": (0xDE, 0x60, 0x3B)},
}

class Canvas:
    def __init__(self, n): self.n = n; self.px = [[(0, 0, 0, 0)] * n for _ in range(n)]
    def rect(self, x, y, w, h, rgb):
        for yy in range(max(0, y), min(self.n, y + h)):
            for xx in range(max(0, x), min(self.n, x + w)):
                self.px[yy][xx] = (*rgb, 255)

def mark(s, c):
    cv = Canvas(s); side = max(4, round(s * 0.25)); o = (s - side) // 2
    cv.rect(o, o, side, side, c["ink"]); return cv, s // 2, s // 2

def reticle(s, c):
    cv = Canvas(s); box = round(s * 0.75); arm = max(4, round(s * 0.2)); t = max(1, s // 24)
    o = (s - box) // 2; far = o + box - t
    for (x, y, dx, dy) in ((o, o, 1, 1), (far, o, -1, 1), (o, far, 1, -1), (far, far, -1, -1)):   # four corner ticks
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

def xcursor(images):
    """images: [(size, canvas, xhot, yhot)] -> bytes of one XCursor file."""
    ntoc = len(images); head = b"Xcur" + struct.pack("<III", 16, 0x10000, ntoc)
    pos = 16 + 12 * ntoc; toc = b""; body = b""
    for size, cv, xh, yh in images:
        toc += struct.pack("<III", 0xFFFD0002, size, pos + len(body))
        chunk = struct.pack("<IIIIIIIII", 36, 0xFFFD0002, size, 1, cv.n, cv.n, xh, yh, 0)
        for row in cv.px:
            for (r, g, b, a) in row:                       # premultiplied ARGB, little endian
                chunk += struct.pack("<I", (a << 24) | (r * a // 255) << 16 | (g * a // 255) << 8 | (b * a // 255))
        body += chunk
    return head + toc + body

ALIASES = {
    "left_ptr": ["default", "arrow", "top_left_arrow", "left_ptr_watch", "wait", "watch", "progress", "half-busy",
                 "help", "question_arrow", "whats_this", "not-allowed", "crossed_circle", "no-drop", "dnd-none",
                 "move", "fleur", "all-scroll", "grab", "grabbing", "openhand", "closedhand", "dnd-move", "dnd-copy",
                 "dnd-link", "copy", "alias", "context-menu", "zoom-in", "zoom-out",
                 "sb_h_double_arrow", "sb_v_double_arrow", "col-resize", "row-resize", "ew-resize", "ns-resize",
                 "nesw-resize", "nwse-resize", "size_hor", "size_ver", "size_bdiag", "size_fdiag",
                 "top_side", "bottom_side", "left_side", "right_side",
                 "top_left_corner", "top_right_corner", "bottom_left_corner", "bottom_right_corner", "e-resize",
                 "n-resize", "s-resize", "w-resize", "ne-resize", "nw-resize", "se-resize", "sw-resize"],
    "pointer": ["hand1", "hand2", "pointing_hand"],
    "text":    ["xterm", "ibeam", "vertical-text"],
    "cross":   ["crosshair", "tcross", "cell", "plus"],
}
BASE = {"left_ptr": mark, "pointer": reticle, "text": ibeam, "cross": cross}

def main():
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "cursors")
    for name, c in THEMES.items():
        d = os.path.join(out, name, "cursors"); os.makedirs(d, exist_ok=True)
        for base, fn in BASE.items():
            data = xcursor([(s, *fn(s, c)) for s in SIZES])
            with open(os.path.join(d, base), "wb") as f: f.write(data)
            for alias in ALIASES[base]:
                p = os.path.join(d, alias)
                if os.path.lexists(p): os.remove(p)
                os.symlink(base, p)
        with open(os.path.join(out, name, "index.theme"), "w") as f:
            f.write("[Icon Theme]\nName=%s\nComment=The mark: a small square (rice, paper and ink)\n" % name)
        print("wrote", name)

if __name__ == "__main__": main()
