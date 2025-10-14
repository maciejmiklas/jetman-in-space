def read_tilemap(filename, width, height):
    tilemap = []
    tile_count = (width * height) * 2
    start_offset = 0x00

    with open(filename, "rb") as file:
        file.seek(start_offset)
        data = file.read(tile_count)

    for i, byte in enumerate(data):
        if i % 2 != 0:
            continue
        if byte == 57:
            tilemap.append(0)
        else:
            tilemap.append(1)
        print(len(tilemap))
    return tilemap