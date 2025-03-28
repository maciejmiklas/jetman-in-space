from PIL import Image
import sys

def find_last_black_pixel(image_path, x_coord):
    try:
        with Image.open(image_path) as img:
            if img.mode != 'RGB':
                img = img.convert('RGB')
            width, height = img.size

            if x_coord < 0 or x_coord >= width:
                raise ValueError("x coordinate is out of image bounds.")

            for y in range(height):
                r, g, b = img.getpixel((x_coord, y))
                if r != 0 or g != 0 or b != 0:
                    return y - 1

            return height - 1  # If all pixels in the column are black
    except Exception as e:
        print(f"Error: {e}")
        return None

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python find_last_black_pixel.py <image_path> <x_coord>")
        sys.exit(1)

    image_path = sys.argv[1]
    x_coord = int(sys.argv[2])

    y_coord = find_last_black_pixel(image_path, x_coord)
    if y_coord is not None:
        print(f"The y-coordinate of the last black pixel from the top at x={x_coord} is {y_coord}.")
    else:
        print("An error occurred.")