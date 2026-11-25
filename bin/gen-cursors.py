#!/usr/bin/env python3
"""
Generate Paper & Ink XCursor themes from quickshell/assets/covers.tsv.

Creates three cursor styles (box, curly, ring), each in paper and ink modes,
for every cover listed in covers.tsv.
"""

from __future__ import annotations

import math
import os
import struct
import sys
from pathlib import Path
from typing import Callable

SIZES = (20, 24, 28, 32, 48, 64)
IMAGE_CHUNK_TYPE = 0xFFFD0002


def rgb(hex_color: str) -> tuple[int, int, int]:
    """Convert a six-digit hexadecimal color to an RGB tuple."""
    value = hex_color.strip().lstrip("#")
    if len(value) != 6:
        raise ValueError(f"Invalid color: {hex_color!r}")
    return tuple(int(value[i:i + 2], 16) for i in (0, 2, 4))


def mix_rgb(
    color_a: tuple[int, int, int],
    color_b: tuple[int, int, int],
    amount: float,
) -> tuple[int, int, int]:
    """Blend two RGB colors."""
    amount = max(0.0, min(1.0, amount))
    return tuple(
        round(a * (1.0 - amount) + b * amount)
        for a, b in zip(color_a, color_b)
    )


def load_covers(tsv_path: Path) -> dict[str, tuple[str, str]]:
    """Read cover name, light color, and dark color from a TSV file."""
    covers: dict[str, tuple[str, str]] = {}

    if tsv_path.is_file():
        with tsv_path.open("r", encoding="utf-8") as file:
            for line_number, line in enumerate(file, start=1):
                line = line.strip()
                if not line or line.startswith("#"):
                    continue

                parts = line.split("\t")
                if len(parts) < 3:
                    continue

                name, light_hex, dark_hex = parts[:3]
                try:
                    rgb(light_hex)
                    rgb(dark_hex)
                except ValueError as error:
                    print(
                        f"Warning: skipping invalid color on line "
                        f"{line_number}: {error}",
                        file=sys.stderr,
                    )
                    continue

                covers[name] = (light_hex, dark_hex)

    if not covers:
        print(
            f"Warning: no covers found in {tsv_path}; using fallback cover.",
            file=sys.stderr,
        )
        covers["sky"] = ("7DCFFF", "7DCFFF")

    return covers


def sd_capsule(
    px: float,
    py: float,
    ax: float,
    ay: float,
    bx: float,
    by: float,
    radius: float,
) -> float:
    """Signed distance from a point to a capsule."""
    pax, pay = px - ax, py - ay
    bax, bay = bx - ax, by - ay
    denominator = bax * bax + bay * bay
    h = 0.0 if denominator == 0 else max(
        0.0,
        min(1.0, (pax * bax + pay * bay) / denominator),
    )
    return math.hypot(pax - bax * h, pay - bay * h) - radius


def sd_round_box(
    px: float,
    py: float,
    cx: float,
    cy: float,
    half_width: float,
    half_height: float,
    radius: float,
) -> float:
    """Signed distance from a point to a rounded rectangle."""
    qx = abs(px - cx) - half_width + radius
    qy = abs(py - cy) - half_height + radius
    return (
        math.hypot(max(qx, 0.0), max(qy, 0.0))
        + min(max(qx, qy), 0.0)
        - radius
    )


class Canvas:
    """Small RGBA canvas with basic drawing and antialiasing helpers."""

    def __init__(self, size: int) -> None:
        self.n = size
        self.px = [
            [(0, 0, 0, 0) for _ in range(size)]
            for _ in range(size)
        ]

    def blend(
        self,
        x: int,
        y: int,
        color: tuple[int, int, int],
        alpha: float,
    ) -> None:
        if not (0 <= x < self.n and 0 <= y < self.n and alpha > 0):
            return

        alpha = max(0, min(255, round(alpha)))
        red, green, blue = color
        old_red, old_green, old_blue, old_alpha = self.px[y][x]

        if old_alpha == 0:
            self.px[y][x] = (red, green, blue, alpha)
            return

        out_alpha = alpha + old_alpha * (255 - alpha) // 255
        if out_alpha == 0:
            return

        out_red = (
            red * alpha
            + old_red * old_alpha * (255 - alpha) // 255
        ) // out_alpha
        out_green = (
            green * alpha
            + old_green * old_alpha * (255 - alpha) // 255
        ) // out_alpha
        out_blue = (
            blue * alpha
            + old_blue * old_alpha * (255 - alpha) // 255
        ) // out_alpha

        self.px[y][x] = (out_red, out_green, out_blue, out_alpha)

    def rect(
        self,
        x: int,
        y: int,
        width: int,
        height: int,
        color: tuple[int, int, int],
        alpha: int = 255,
    ) -> None:
        for yy in range(max(0, y), min(self.n, y + height)):
            for xx in range(max(0, x), min(self.n, x + width)):
                self.blend(xx, yy, color, alpha)

    def circle(
        self,
        cx: float,
        cy: float,
        radius: float,
        color: tuple[int, int, int],
        alpha: int = 255,
        stroke: float = 0,
    ) -> None:
        outer_radius = radius + 0.75
        inner_radius = (
            max(0.0, radius - stroke - 0.75)
            if stroke > 0 else 0.0
        )

        y_start = max(0, int(cy - outer_radius - 1))
        y_end = min(self.n, int(cy + outer_radius + 2))
        x_start = max(0, int(cx - outer_radius - 1))
        x_end = min(self.n, int(cx + outer_radius + 2))

        for y in range(y_start, y_end):
            for x in range(x_start, x_end):
                distance = math.hypot(
                    (x + 0.5) - cx,
                    (y + 0.5) - cy,
                )

                if stroke > 0:
                    if inner_radius <= distance <= outer_radius:
                        edge = min(
                            1.0,
                            (outer_radius - distance) / 1.1,
                            (distance - inner_radius) / 1.1,
                        )
                        self.blend(x, y, color, alpha * max(0.0, edge))
                elif distance <= outer_radius:
                    edge = min(1.0, (outer_radius - distance) / 1.1)
                    self.blend(x, y, color, alpha * max(0.0, edge))

    def render_sdf(
        self,
        sdf_fn: Callable[[float, float], float],
        fill_color: tuple[int, int, int],
        fill_alpha: int = 255,
        outline_color: tuple[int, int, int] | None = None,
        outline_width: float = 0.0,
    ) -> None:
        for y in range(self.n):
            py = y + 0.5
            for x in range(self.n):
                px = x + 0.5
                distance = sdf_fn(px, py)

                if outline_color is not None and outline_width > 0:
                    if distance <= 0.65:
                        coverage = max(
                            0.0,
                            min(1.0, (0.65 - distance) / 1.1),
                        )
                        self.blend(x, y, outline_color, 255 * coverage)

                    if distance <= -outline_width + 0.55 and fill_alpha > 0:
                        coverage = max(
                            0.0,
                            min(
                                1.0,
                                (-outline_width + 0.55 - distance) / 1.1,
                            ),
                        )
                        self.blend(
                            x, y, fill_color, fill_alpha * coverage
                        )
                elif distance <= 0.65 and fill_alpha > 0:
                    coverage = max(
                        0.0,
                        min(1.0, (0.65 - distance) / 1.1),
                    )
                    self.blend(x, y, fill_color, fill_alpha * coverage)


def box_arrow(size: int, colors: dict) -> tuple[Canvas, int, int]:
    canvas = Canvas(size)
    margin = max(1, round(size * 0.04))
    unit = round(size * 0.30)
    offset = round(unit * 0.667)
    extent = round(unit * 2.33)

    canvas.rect(margin + offset, margin + offset, extent, extent, colors["cov"])
    canvas.rect(margin, margin, unit, unit, colors["ink"])
    return canvas, margin, margin


def box_reticle(size: int, colors: dict) -> tuple[Canvas, int, int]:
    canvas = Canvas(size)
    box_size = round(size * 0.75)
    arm = max(4, round(size * 0.20))
    thickness = max(1, size // 24)
    origin = (size - box_size) // 2
    far = origin + box_size - thickness

    corners = (
        (origin, origin, 1, 1),
        (far, origin, -1, 1),
        (origin, far, 1, -1),
        (far, far, -1, -1),
    )

    for x, y, dx, dy in corners:
        canvas.rect(
            x if dx > 0 else x - arm + thickness,
            y,
            arm,
            thickness,
            colors["ink"],
        )
        canvas.rect(
            x,
            y if dy > 0 else y - arm + thickness,
            thickness,
            arm,
            colors["ink"],
        )

    center_size = max(4, round(size * 0.25))
    center_origin = (size - center_size) // 2
    canvas.rect(
        center_origin,
        center_origin,
        center_size,
        center_size,
        colors["cov"],
    )
    return canvas, size // 2, size // 2


def box_ibeam(size: int, colors: dict) -> tuple[Canvas, int, int]:
    canvas = Canvas(size)
    thickness = max(1, size // 24)
    height = round(size * 0.70)
    width = round(size * 0.30)
    top = (size - height) // 2
    center_x = size // 2

    canvas.rect(
        center_x - thickness // 2, top,
        thickness, height, colors["ink"],
    )
    canvas.rect(
        center_x - width // 2, top,
        width, thickness, colors["ink"],
    )
    canvas.rect(
        center_x - width // 2, top + height - thickness,
        width, thickness, colors["ink"],
    )
    return canvas, size // 2, size // 2


def curly_arrow(size: int, colors: dict) -> tuple[Canvas, int, int]:
    canvas = Canvas(size)
    p0 = (0.14 * size, 0.13 * size)
    p1 = (0.44 * size, 0.16 * size)
    p2 = (0.58 * size, 0.35 * size)
    p3 = (0.61 * size, 0.56 * size)

    samples = []
    segments = 48

    for index in range(segments + 1):
        t = index / segments
        inverse = 1.0 - t

        x = (
            inverse**3 * p0[0]
            + 3 * inverse**2 * t * p1[0]
            + 3 * inverse * t**2 * p2[0]
            + t**3 * p3[0]
        )
        y = (
            inverse**3 * p0[1]
            + 3 * inverse**2 * t * p1[1]
            + 3 * inverse * t**2 * p2[1]
            + t**3 * p3[1]
        )
        radius = size * (
            0.012 + 0.088 * math.sin((math.pi * 0.62) * t**0.75)
        )
        samples.append((x, y, radius))

    def horn_sdf(px: float, py: float) -> float:
        best = float("inf")
        for first, second in zip(samples, samples[1:]):
            ax, ay, ar = first
            bx, by, br = second
            distance = sd_capsule(
                px, py, ax, ay, bx, by, 0.5 * (ar + br)
            )
            best = min(best, distance)
        return best

    outline_width = max(1.1, size * 0.042)
    canvas.render_sdf(
        horn_sdf,
        fill_color=colors["cov"],
        outline_color=colors["ink"],
        outline_width=outline_width,
    )

    square_cx, square_cy = 0.35 * size, 0.73 * size
    square_half = 0.105 * size
    square_radius = 0.025 * size

    canvas.render_sdf(
        lambda px, py: sd_round_box(
            px, py,
            square_cx, square_cy,
            square_half, square_half,
            square_radius,
        ),
        fill_color=colors["ink"],
    )
    canvas.circle(
        0.66 * size, 0.73 * size, 0.105 * size, colors["cov"]
    )
    return canvas, max(1, round(0.13 * size)), max(1, round(0.13 * size))


def curly_pointer(size: int, colors: dict) -> tuple[Canvas, int, int]:
    canvas = Canvas(size)
    pastel = mix_rgb(colors["cov"], (255, 255, 255), 0.76)
    outline = (0x1D, 0x1C, 0x1A)

    def hand_sdf(px: float, py: float) -> float:
        index_finger = sd_capsule(
            px, py, 0.43 * size, 0.21 * size,
            0.43 * size, 0.56 * size, 0.095 * size,
        )
        middle_finger = sd_capsule(
            px, py, 0.57 * size, 0.43 * size,
            0.57 * size, 0.64 * size, 0.088 * size,
        )
        ring_finger = sd_capsule(
            px, py, 0.69 * size, 0.47 * size,
            0.69 * size, 0.68 * size, 0.082 * size,
        )
        thumb = sd_capsule(
            px, py, 0.23 * size, 0.54 * size,
            0.39 * size, 0.64 * size, 0.085 * size,
        )
        palm = sd_round_box(
            px, py, 0.54 * size, 0.66 * size,
            0.22 * size, 0.20 * size, 0.12 * size,
        )
        return min(index_finger, middle_finger, ring_finger, thumb, palm)

    canvas.render_sdf(
        hand_sdf,
        fill_color=pastel,
        outline_color=outline,
        outline_width=max(1.4, size * 0.058),
    )
    return canvas, round(0.43 * size), max(1, round(0.14 * size))


def curly_ibeam(size: int, colors: dict) -> tuple[Canvas, int, int]:
    canvas = Canvas(size)
    thickness = max(2, round(size * 0.085))
    height = round(size * 0.72)
    width = round(size * 0.36)
    top = (size - height) // 2
    center_x = size // 2

    canvas.rect(
        center_x - thickness // 2, top,
        thickness, height, colors["ink"],
    )
    canvas.rect(
        center_x - width // 2, top,
        width, thickness, colors["ink"],
    )
    canvas.rect(
        center_x - width // 2, top + height - thickness,
        width, thickness, colors["ink"],
    )
    return canvas, center_x, size // 2


def ring_dot(size: int, colors: dict) -> tuple[Canvas, int, int]:
    canvas = Canvas(size)
    center = size * 0.5
    canvas.circle(center, center, size * 0.155, colors["cov"])
    return canvas, size // 2, size // 2


def ring_pointer(size: int, colors: dict) -> tuple[Canvas, int, int]:
    canvas = Canvas(size)
    center = size * 0.5
    radius = size * 0.33
    stroke = max(1.6, size * 0.082)

    canvas.circle(
        center, center, radius - stroke * 0.4,
        colors["cov"], 78,
    )
    canvas.circle(
        center, center, radius,
        colors["cov"], 255, stroke=stroke,
    )
    return canvas, size // 2, size // 2


def ring_ibeam(size: int, colors: dict) -> tuple[Canvas, int, int]:
    canvas = Canvas(size)
    center_x = size * 0.5
    half_height = size * 0.32
    radius = max(1.2, size * 0.045)

    canvas.render_sdf(
        lambda px, py: sd_capsule(
            px, py,
            center_x,
            size * 0.5 - half_height,
            center_x,
            size * 0.5 + half_height,
            radius,
        ),
        fill_color=colors["cov"],
    )
    return canvas, size // 2, size // 2


def std_cross(size: int, colors: dict) -> tuple[Canvas, int, int]:
    canvas = Canvas(size)
    thickness = max(1, size // 24)
    extent = round(size * 0.70)
    origin = (size - extent) // 2
    center = size // 2

    canvas.rect(
        origin, center - thickness // 2,
        extent, thickness, colors["ink"],
    )
    canvas.rect(
        center - thickness // 2, origin,
        thickness, extent, colors["ink"],
    )
    return canvas, center, center


def draw_line(
    canvas: Canvas,
    x0: float,
    y0: float,
    x1: float,
    y1: float,
    thickness: int,
    color: tuple[int, int, int],
) -> None:
    steps = int(max(abs(x1 - x0), abs(y1 - y0))) * 2 or 1

    for step in range(steps + 1):
        x = x0 + (x1 - x0) * step / steps
        y = y0 + (y1 - y0) * step / steps
        canvas.rect(
            round(x - thickness / 2),
            round(y - thickness / 2),
            thickness,
            thickness,
            color,
        )


def dumbbell(kind: str) -> Callable:
    """Build horizontal, vertical, or diagonal resize cursors."""

    def make(size: int, colors: dict) -> tuple[Canvas, int, int]:
        canvas = Canvas(size)
        thickness = max(2, round(size / 12))
        end_size = max(5, round(size * 0.22))
        start = round(size * 0.14)
        end = round(size * 0.86)
        middle = size // 2

        endpoints = {
            "h": (start, middle, end, middle),
            "v": (middle, start, middle, end),
            "d1": (start, start, end, end),
            "d2": (end, start, start, end),
        }

        x0, y0, x1, y1 = endpoints[kind]
        draw_line(canvas, x0, y0, x1, y1, thickness, colors["ink"])

        for x, y in ((x0, y0), (x1, y1)):
            canvas.rect(
                x - end_size // 2,
                y - end_size // 2,
                end_size,
                end_size,
                colors["ink"],
            )

        return canvas, middle, middle

    return make


def held(size: int, colors: dict) -> tuple[Canvas, int, int]:
    canvas = Canvas(size)
    box_size = round(size * 0.58)
    arm = max(3, round(size * 0.15))
    thickness = max(1, size // 24)
    origin = (size - box_size) // 2
    far = origin + box_size - thickness

    corners = (
        (origin, origin, 1, 1),
        (far, origin, -1, 1),
        (origin, far, 1, -1),
        (far, far, -1, -1),
    )

    for x, y, dx, dy in corners:
        canvas.rect(
            x if dx > 0 else x - arm + thickness,
            y,
            arm,
            thickness,
            colors["ink"],
        )
        canvas.rect(
            x,
            y if dy > 0 else y - arm + thickness,
            thickness,
            arm,
            colors["ink"],
        )

    side = round(size * 0.32)
    center_origin = (size - side) // 2
    canvas.rect(
        center_origin, center_origin, side, side, colors["cov"]
    )
    return canvas, size // 2, size // 2


def xcursor(images: list[tuple[int, Canvas, int, int]]) -> bytes:
    """Encode rendered cursor images in the Xcursor file format."""
    image_count = len(images)
    header = b"Xcur" + struct.pack(
        "<III", 16, 0x00010000, image_count
    )

    position = 16 + 12 * image_count
    table_of_contents = bytearray()
    image_data = bytearray()

    for nominal_size, canvas, hot_x, hot_y in images:
        table_of_contents.extend(
            struct.pack(
                "<III",
                IMAGE_CHUNK_TYPE,
                nominal_size,
                position + len(image_data),
            )
        )

        chunk = bytearray(
            struct.pack(
                "<IIIIIIIII",
                36,
                IMAGE_CHUNK_TYPE,
                nominal_size,
                1,
                canvas.n,
                canvas.n,
                hot_x,
                hot_y,
                0,
            )
        )

        for row in canvas.px:
            for red, green, blue, alpha in row:
                # Xcursor stores premultiplied ARGB pixels.
                pixel = (
                    (alpha << 24)
                    | ((red * alpha // 255) << 16)
                    | ((green * alpha // 255) << 8)
                    | (blue * alpha // 255)
                )
                chunk.extend(struct.pack("<I", pixel))

        image_data.extend(chunk)

    return header + bytes(table_of_contents) + bytes(image_data)


ALIASES = {
    "left_ptr": (
        "default", "arrow", "top_left_arrow", "left_ptr_watch",
        "wait", "watch", "progress", "half-busy", "help",
        "question_arrow", "whats_this", "not-allowed",
        "crossed_circle", "no-drop", "dnd-none", "copy",
        "alias", "context-menu", "zoom-in", "zoom-out",
    ),
    "pointer": (
        "hand1", "hand2", "pointing_hand", "grab", "openhand",
    ),
    "held": (
        "grabbing", "closedhand", "move", "fleur", "all-scroll",
        "dnd-move", "dnd-copy", "dnd-link",
    ),
    "text": ("xterm", "ibeam", "vertical-text"),
    "cross": ("crosshair", "tcross", "cell", "plus"),
    "resize_h": (
        "e-resize", "w-resize", "ew-resize", "col-resize",
        "sb_h_double_arrow", "size_hor", "left_side", "right_side",
        "h_double_arrow", "split_h",
    ),
    "resize_v": (
        "n-resize", "s-resize", "ns-resize", "row-resize",
        "sb_v_double_arrow", "size_ver", "top_side", "bottom_side",
        "v_double_arrow", "split_v",
    ),
    "resize_d1": (
        "nwse-resize", "nw-resize", "se-resize", "size_fdiag",
        "top_left_corner", "bottom_right_corner", "fd_double_arrow",
    ),
    "resize_d2": (
        "nesw-resize", "ne-resize", "sw-resize", "size_bdiag",
        "top_right_corner", "bottom_left_corner", "bd_double_arrow",
    ),
}


STYLE_BASES = {
    "box": {
        "left_ptr": box_arrow,
        "pointer": box_reticle,
        "held": held,
        "text": box_ibeam,
        "cross": std_cross,
        "resize_h": dumbbell("h"),
        "resize_v": dumbbell("v"),
        "resize_d1": dumbbell("d1"),
        "resize_d2": dumbbell("d2"),
    },
    "curly": {
        "left_ptr": curly_arrow,
        "pointer": curly_pointer,
        "held": held,
        "text": curly_ibeam,
        "cross": std_cross,
        "resize_h": dumbbell("h"),
        "resize_v": dumbbell("v"),
        "resize_d1": dumbbell("d1"),
        "resize_d2": dumbbell("d2"),
    },
    "ring": {
        "left_ptr": ring_dot,
        "pointer": ring_pointer,
        "held": held,
        "text": ring_ibeam,
        "cross": std_cross,
        "resize_h": dumbbell("h"),
        "resize_v": dumbbell("v"),
        "resize_d1": dumbbell("d1"),
        "resize_d2": dumbbell("d2"),
    },
}


def generate_theme(
    output_dir: Path,
    theme_name: str,
    style: str,
    cover_name: str,
    mode_name: str,
    light_hex: str,
    dark_hex: str,
    cursor_map: dict,
) -> None:
    """Render all cursor roles and write one complete theme."""
    paper_ink = (0x1D, 0x1C, 0x1A)
    paper_background = (0xEE, 0xEA, 0xE1)
    dark_ink = (0xE7, 0xE2, 0xD5)
    dark_background = (0x17, 0x16, 0x19)

    if mode_name == "paper":
        ink_color = paper_ink
        cover_color = rgb(light_hex)
    else:
        ink_color = dark_ink
        cover_color = rgb(dark_hex)

    colors = {
        "ink": ink_color,
        "paper": paper_background if mode_name == "paper" else dark_background,
        "cov": cover_color,
    }

    cursor_dir = output_dir / theme_name / "cursors"
    cursor_dir.mkdir(parents=True, exist_ok=True)

    for cursor_name, renderer in cursor_map.items():
        rendered_images = [
            (size, *renderer(size, colors))
            for size in SIZES
        ]
        cursor_data = xcursor(rendered_images)

        cursor_path = cursor_dir / cursor_name
        cursor_path.write_bytes(cursor_data)

        for alias in ALIASES.get(cursor_name, ()):
            alias_path = cursor_dir / alias
            if alias_path.is_symlink() or alias_path.is_file():
                alias_path.unlink()
            elif alias_path.exists():
                raise OSError(
                    f"Cannot replace non-file cursor alias: {alias_path}"
                )
            alias_path.symlink_to(cursor_name)

    index_path = cursor_dir.parent / "index.theme"
    index_path.write_text(
        "[Icon Theme]\n"
        f"Name={theme_name}\n"
        f"Comment=Paper & Ink ({style} style, {cover_name}, {mode_name})\n",
        encoding="utf-8",
    )


def main() -> int:
    script_dir = Path(__file__).resolve().parent
    project_root = script_dir.parent
    default_output = project_root / "cursors"
    output_dir = Path(sys.argv[1]).expanduser() if len(sys.argv) > 1 else default_output

    covers_path = project_root / "quickshell" / "assets" / "covers.tsv"
    covers = load_covers(covers_path)

    generated = 0

    for style, cursor_map in STYLE_BASES.items():
        for cover_name, (light_hex, dark_hex) in covers.items():
            for mode_name in ("paper", "ink"):
                theme_name = f"rice-{mode_name}-{style}-{cover_name}"

                generate_theme(
                    output_dir=output_dir,
                    theme_name=theme_name,
                    style=style,
                    cover_name=cover_name,
                    mode_name=mode_name,
                    light_hex=light_hex,
                    dark_hex=dark_hex,
                    cursor_map=cursor_map,
                )
                generated += 1

    print(
        f"Generated {generated} XCursor themes "
        f"(3 styles × {len(covers)} covers × 2 modes)."
    )
    print(f"Output directory: {output_dir.resolve()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
