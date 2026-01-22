#!/usr/bin/env python3

# Converts 'nxt' file to 4 bit 4x4 tilemap sprite file
# 'nxt' was created with: .\gfx2next.exe -tile-size=8x8 -colors-4bit -preview -map-y .\chroma-noir.bmp

import os
import sys


def read_chunks(filename, chunk_size=64):
    chunks = []
    with open(filename, "rb") as f:
        while True:
            chunk = f.read(chunk_size)
            if not chunk:
                break
            chunks.append(chunk)
    return chunks


def write_chunks(filename, chunks):
    with open(filename, "wb") as f:
        for chunk in chunks:
            f.write(chunk)


def get_output_filename(input_file):
    base, _ = os.path.splitext(input_file)
    return base + ".spr"


def convert(chunks):
    size =  len(chunks)
    out = []
    i = 0
    j = 0
    while i < size-4:
        out.append(chunks[i])
        out.append(chunks[i+4])
        if j == 3:
            j = 0
            i += 5  # Jump 4 elements every 4th iteration (skipp on row that has been copied by i+4
        else:
            i += 1
            j += 1
    return out


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <input_file>")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = get_output_filename(input_file)

    chunks = read_chunks(input_file)
    out = convert(chunks)
    write_chunks(output_file, out)
    print(f"Processed {2*len(chunks)} tiles.")


if __name__ == "__main__":
    main()
