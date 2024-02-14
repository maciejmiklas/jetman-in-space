import math


def rgb_to_next(r, g, b):
    vr = int(r / 32) << 6
    vg = int(g / 32) << 3
    vb = int(b / 32)
    return vr + vg + vb


def process(lines):
    palette = []
    for line in lines:
        line = line.strip()
        ir = int(line[1:3], 16)
        ig = int(line[3:5], 16)
        ib = int(line[5:7], 16)
        next_int = rgb_to_next(ir, ig, ib)
        next_hex = hex(next_int).upper().replace('0X', '$')
        palette.append(next_hex)
        print("RGB: {}-{}-{} -> {} -> {}".format(ir, ig, ib, next_int, next_hex))
    palette = list(dict.fromkeys(palette))
    print("OUT: {}".format(palette).replace('\'', ''))

process(open('rgb.txt', 'r').readlines())
