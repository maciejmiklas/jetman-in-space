#!/usr/bin/env python3

import os
import struct
import sys

# Global variable to shift ASCII values
ASCII_SHIFT = -34
LINE_WIDTH = 40

SPACE_TILE = 57
SPACE_CODE = 32


def convert_to_binary(input_file, out_file_name):
    # Remove the file
    if os.path.exists(out_file_name):
        os.remove(out_file_name)

    with open(input_file, 'r') as infile:
        lines = infile.readlines()

    # Create a binary output file
    with open(out_file_name, 'wb') as out_file:
        lines_cnt = 0
        for line in lines:
            lines_cnt += 1
            # out_file.write(bytes([SPACE_TILE, 0] * LINE_WIDTH))

            # Remove line breaks and pad the line with spaces to 40 characters
            padded_line = line.replace("\n", "").replace("\r", "").ljust(LINE_WIDTH)

            #print(padded_line)
            for char in padded_line:
                ch_code = ord(char)
                if ch_code > 255 or ch_code < 0:
                    print(f"Skipping unsupported char:{char} in line:{padded_line}")
                    continue

                if ch_code == SPACE_CODE:
                    out_char = SPACE_TILE
                else:
                    out_char = ch_code + ASCII_SHIFT
                    if ch_code <= 42:
                        out_char += 1  # Tilemap characters are missing the + sign that is at 43

                if out_char > 255 or out_char < 0:
                    print(f"Skipping unsupported out char:{char} wit value:{out_char} in line:{padded_line}")
                    out_char = SPACE_TILE

                # Pack the shifted value as a single binary byte
                out_file.write(struct.pack('B', out_char))
                # Insert a null byte after each character (tile color offset and rotation)
                out_file.write(struct.pack('B', 0))

    print(f"Conversion successful!. Tilemap size: 40x{lines_cnt} Output file: {out_file_name}")


def main():
    if len(sys.argv) != 2:
        print("Usage: python ascii_to_binary_map_converter.py <input_file>")
        sys.exit(1)

    input_file = sys.argv[1]

    if not input_file.endswith('.txt'):
        print("Input file must have a .txt extension")
        sys.exit(1)

    if not os.path.exists(input_file):
        print("Input file does not exist")
        sys.exit(1)

    # Generate output file name with .map extension
    output_file = os.path.splitext(input_file)[0] + '.map'

    convert_to_binary(input_file, output_file)


if __name__ == "__main__":
    main()
