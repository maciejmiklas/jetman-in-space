#!/usr/bin/env python3

import argparse
import sys
import re

# Accepts space-separated colors in either $YZ or $XYZ form.
# Encoding:
# - X is Red MSB (bit 2 of the 3-bit Red channel), X ∈ {0,1}
# - YZ byte is laid out as: R(1:0) G(2:0) B(2:0) => bits: [7..6]=R_low2, [5..3]=G, [2..0]=B
#   So the full 9-bit color is: RRGGGBBB where R = (X << 2) | R_low2
# Darkening decreases R, G, B by N steps (default 1), clamped to 0.
# Outputs $YZ when X=0, or $1YZ when X=1.

SPACE_RE = re.compile(r"\s+", flags=re.UNICODE)
HEX2_RE = re.compile(r"^[0-9A-F]{2}$")
HEX3_RE = re.compile(r"^[01][0-9A-F]{2}$")  # X must be 0 or 1

def parse_token(token: str):
    t = token.strip()
    if t.startswith("$"):
        t = t[1:]
    t = t.upper()
    if HEX2_RE.match(t):
        yz = int(t, 16)
        red_msb = 0
    elif HEX3_RE.match(t):
        red_msb = int(t[0], 16) & 1
        yz = int(t[1:], 16)
    else:
        raise ValueError(f"Invalid token '{token}'. Expected $YZ or $XYZ (X=0/1).")
    return yz, red_msb

def split_channels(yz: int, red_msb: int):
    # YZ = R_low2 (bits 7..6), G (5..3), B (2..0); X = R_msb
    r_low2 = (yz >> 6) & 0b11
    g = (yz >> 3) & 0b111
    b = yz & 0b111
    r = ((red_msb & 1) << 2) | r_low2
    return r, g, b

def join_channels(r: int, g: int, b: int):
    r &= 0b111; g &= 0b111; b &= 0b111
    red_msb = (r >> 2) & 1
    r_low2 = r & 0b11
    yz = (r_low2 << 6) | (g << 3) | b
    return yz, red_msb

def encode_token(yz: int, red_msb: int) -> str:
    return f"${yz:02X}" if (red_msb & 1) == 0 else f"$1{yz:02X}"

def darken(r: int, g: int, b: int, steps: int):
    return max(0, r - steps), max(0, g - steps), max(0, b - steps)

def process_str(s: str, steps: int) -> str:
    tokens = [t for t in SPACE_RE.split(s.strip()) if t]
    out = []
    for tok in tokens:
        yz, red_msb = parse_token(tok)
        r, g, b = split_channels(yz, red_msb)
        r, g, b = darken(r, g, b, steps)
        yz2, rm2 = join_channels(r, g, b)
        out.append(encode_token(yz2, rm2))
    return " ".join(out)

def main():
    p = argparse.ArgumentParser(
        description="Darken 9-bit palette: $YZ or $XYZ where YZ=R_low2 G B and X=Red MSB."
    )
    p.add_argument("colors", nargs="*", help='Colors like $38, $A0, $1A0 or a single quoted string "$38 $A0 $1A0".')
    p.add_argument("--steps", type=int, default=1)
    args = p.parse_args()

    if args.colors:
        s = " ".join(args.colors)
    else:
        if sys.stdin.isatty():
            p.error("No colors provided.")
        s = sys.stdin.read()

    print(process_str(s, args.steps))

if __name__ == "__main__":
    main()
