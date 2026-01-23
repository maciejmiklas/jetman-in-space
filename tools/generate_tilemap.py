#!/usr/bin/env python3

# make sure that image consists of 8x8 pixels tiles (show 8x8 grid im gimp)
# .\gfx2next.exe -tile-size=8x8 -colors-4bit -preview -map-y .\image.bmp
# python generate_tilemap.py --base-id 2 --start-line 5 --offset 3 --tiles-per-line 16 --lines 13
# use test.nxt as sprite file, do not use ntx_to_tilemap_spr.py

import argparse
import sys
from pathlib import Path

WIDTH = 40
HEIGHT = 32
COLOR = 8  # 0b00001000
OUT_FILE = "tile.map"
EMPTY_TILE = 198

def clamp_byte(value: int, name: str) -> int:
    if not (0 <= value <= 255):
        raise ValueError(f"{name} must be in range 0..255, got {value}")
    return value

def index(row: int, col: int) -> int:
    # Row-major tile index
    return row * WIDTH + col

def apply_pattern(buffer: bytearray, start_line: int, offset: int, tiles_per_line: int, lines: int):
    # pattern tile IDs start at 1 and increment left-to-right, top-to-bottom
    next_id = 0
    for r in range(start_line, start_line + lines):
        for c in range(offset, offset + tiles_per_line):
            tile_pos = index(r, c)
            byte_pos = tile_pos * 2
            buffer[byte_pos] = next_id & 0xFF
            buffer[byte_pos + 1] = COLOR
            next_id += 1

def validate_pattern_args(start_line, offset, tiles_per_line, lines):
    # Basic bounds checks to avoid out-of-range writes
    if not (0 <= start_line < HEIGHT):
        raise ValueError(f"start-line must be 0..{HEIGHT-1}")
    if not (0 <= offset < WIDTH):
        raise ValueError(f"offset must be 0..{WIDTH-1}")
    if tiles_per_line <= 0 or lines <= 0:
        raise ValueError("tiles-per-line and lines must be positive")
    if offset + tiles_per_line > WIDTH:
        raise ValueError(f"Pattern exceeds width: offset({offset}) + tiles-per-line({tiles_per_line}) > {WIDTH}")
    if start_line + lines > HEIGHT:
        raise ValueError(f"Pattern exceeds height: start-line({start_line}) + lines({lines}) > {HEIGHT}")
    # Also ensure generated IDs fit into a byte (1..N)
    total_tiles = tiles_per_line * lines
    if total_tiles > 255:
        raise ValueError(f"Pattern too large: total tiles {total_tiles} exceed 255 (tile ID is 1 byte)")

def main(argv=None):
    parser = argparse.ArgumentParser(
        description="Generate a 40x96 tilemap as binary file 'tile.map'. Each tile is [tile_id, 8]."
    )
    parser.add_argument("--base-id", type=int, default=EMPTY_TILE, help="Base fill tile ID for entire map (0..255)")
    parser.add_argument("--start-line", type=int, help="Pattern start line (0-based)")
    parser.add_argument("--offset", type=int, help="Pattern offset from the left (0-based)")
    parser.add_argument("--tiles-per-line", type=int, help="Number of tiles in each line of the pattern")
    parser.add_argument("--lines", type=int, help="Number of lines in the pattern")
    parser.add_argument("--out", type=Path, default=OUT_FILE, help=f"Output file path (default: {OUT_FILE})")

    args = parser.parse_args(argv)

    try:
        base_id = clamp_byte(args.base_id, "base-id")
    except ValueError as e:
        print(f"Error: {e}", file=sys.stderr)
        return 2

    # Initialize buffer: WIDTH*HEIGHT tiles * 2 bytes per tile
    total_tiles = WIDTH * HEIGHT
    buf = bytearray(total_tiles * 2)

    # Fill with base tile and color
    for t in range(total_tiles):
        pos = t * 2
        buf[pos] = base_id
        buf[pos + 1] = COLOR

    # If pattern args are provided, apply the pattern
    pattern_args = [args.start_line, args.offset, args.tiles_per_line, args.lines]
    if any(a is not None for a in pattern_args):
        if not all(a is not None for a in pattern_args):
            print("Error: To use a pattern, provide --start-line, --offset, --tiles-per-line, and --lines.", file=sys.stderr)
            return 2
        try:
            validate_pattern_args(args.start_line, args.offset, args.tiles_per_line, args.lines)
        except ValueError as e:
            print(f"Error: {e}", file=sys.stderr)
            return 2
        apply_pattern(buf, args.start_line, args.offset, args.tiles_per_line, args.lines)

    # Write to file
    try:
        args.out.write_bytes(buf)
    except OSError as e:
        print(f"Error writing file '{args.out}': {e}", file=sys.stderr)
        return 1

    print(f"Generated {args.out} ({len(buf)} bytes).")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
