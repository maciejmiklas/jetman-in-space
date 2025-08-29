import sys
import struct
import shutil

def html_color_to_bgr(color_str):
    """Convert #RRGGBB html color to (B, G, R) tuple."""
    if color_str.startswith('#'):
        color_str = color_str[1:]
    if len(color_str) != 6:
        raise ValueError("Incorrect color format: should be #RRGGBB")
    r = int(color_str[0:2], 16)
    g = int(color_str[2:4], 16)
    b = int(color_str[4:6], 16)
    return (b, g, r)  # BMP uses BGR

def replace_color_in_bmp(filename, old_color, new_color):
    with open(filename, 'rb') as f:
        bmp = bytearray(f.read())

    # BMP Header
    if bmp[0:2] != b'BM':
        raise ValueError("Not a BMP file")

    # Get pixel array offset (bytes 10-13)
    pixel_offset = struct.unpack_from('<I', bmp, 10)[0]
    width = struct.unpack_from('<I', bmp, 18)[0]
    height = struct.unpack_from('<I', bmp, 22)[0]
    bpp = struct.unpack_from('<H', bmp, 28)[0]

    if bpp != 24:
        raise NotImplementedError("Only 24 bpp BMP files are supported.")

    row_padded = (width * 3 + 3) & (~3)
    old_bgr = bytes(html_color_to_bgr(old_color))
    new_bgr = bytes(html_color_to_bgr(new_color))

    for y in range(height):
        for x in range(width):
            offset = pixel_offset + y * row_padded + x * 3
            if bmp[offset:offset+3] == old_bgr:
                bmp[offset:offset+3] = new_bgr

    # Backup
    backup_filename = filename.rsplit('.', 1)[0] + '_backup.bmp'
    shutil.copy2(filename, backup_filename)
    print(f"Backup written to {filename}")

    # Write the result
    with open(filename, 'wb') as f:
        f.write(bmp)
    print(f"Color replaced. Output written to {filename}")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python replace_color_in_bmp.py <bmp_file> <old_color> <new_color>")
        print("Colors must be in #RRGGBB notation.")
        sys.exit(1)
    bmp_file = sys.argv[1]
    old_color = sys.argv[2]
    new_color = sys.argv[3]
    replace_color_in_bmp(bmp_file, old_color, new_color)