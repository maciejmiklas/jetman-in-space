#!/usr/bin/env python3
import argparse
import os
import sys
from dataclasses import dataclass
from typing import TypeAlias, ClassVar

import pygame

PointFl: TypeAlias = tuple[float, float]
Step: TypeAlias = tuple[str, int]


@dataclass(frozen=True, slots=True)
class Distance:
    """
    Distance between two points. Consists of the number of pixels to travel in X and Y directions,
    and the amount of repetition. For example, Distance(3, 2, 4) means that we have to travel 3 pixels in X direction,
    2 pixels in Y direction, and repeat is 4 times. In total, we have to travel 3*4 pixels in the X direction
    and 2*4 pixels in the Y direction.
    """

    # Distance in pixels in X direction, value 0 to 7.
    x: int

    # Distance in pixels in Y direction, value 0 to 7.
    y: int

    # Value from 0 to 15. 0 means no repetition, just travel single Distance.
    repeat: int


@dataclass(frozen=True, slots=True)
class Point:
    """
    X,Y coordinates of a point.
    """
    x: int
    y: int


@dataclass(frozen=True, slots=True)
class Coordinate:
    """
    Screen and native coordinates of a point.
    """
    # screen coordinates of the point.
    screen: Point = Point(0, 0)

    # native coordinates of the point (320x256).
    native: Point = Point(0, 0)

    # true for a user inserted point, false for a generated point.
    user: bool = True

    UI_SCALE: ClassVar[int] = 3

    @classmethod
    def from_native(cls, xn: int, yn: int, user=True) -> "Coordinate":
        return cls(Point(xn * Coordinate.UI_SCALE, yn * Coordinate.UI_SCALE),
                   Point(xn, yn), user)

    @classmethod
    def from_screen(cls, xs: int, ys: int, user=True) -> "Coordinate":
        return cls(Point(xs, ys),
                   Point(round(xs / Coordinate.UI_SCALE), round(ys / Coordinate.UI_SCALE)), user)

    @classmethod
    def from_screen_tuple(cls, inp: tuple[float, float], user=True) -> "Coordinate":
        return cls(Point(round(inp[0]), round(inp[1])),
                   Point(round(inp[0] / Coordinate.UI_SCALE), round(inp[1] / Coordinate.UI_SCALE)), user)

    @staticmethod
    def to_native(points: list["Coordinate"]) -> list[Point]:
        return [p.native for p in points]


# Keys:
# A - add point
# S - store to file
# C - clear points
# E - edit point
class App:

    def __init__(self, tilemap_path: str, ui_scale=3):
        self.tilemap: list[int] = []
        self.tilemap_path = tilemap_path
        self.grid = [40, 32]
        Coordinate.UI_SCALE = ui_scale
        self.reduce_by = 5
        self.box_size = (320 / 40) * Coordinate.UI_SCALE

        # Points inserted by the user
        self.points: list[Coordinate] = []

        # Point being dragged by the user/mause.
        self.point_to_drag: int | None = None

        # gird has the size of the tilemap: 40x32, but counts from 0, so 39x41
        self.mouse_to_grid: Point = Point(0, 0)
        self.screen = pygame.display.set_mode((320 * Coordinate.UI_SCALE, 256 * Coordinate.UI_SCALE))
        self.curve: list[Coordinate] | None = None
        self.start_app()

    def start_app(self):  # starts the app
        self.tilemap = self.read_tilemap(self.tilemap_path, self.grid[0], self.grid[1])
        self.tilemap[0] = 1
        self.draw_tilemap()

        while True:
            self.main_loop()

    def main_loop(self):  # makes a main loop for the program
        self.mouse_to_grid = Point(round(pygame.mouse.get_pos()[0] // self.box_size),
                                   round(pygame.mouse.get_pos()[1] // self.box_size))

        event = pygame.event.wait()
        self.draw_tilemap()
        if event.type == pygame.QUIT:
            self.on_exit()
        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_a:  # adding a point for the curve
                self.on_key_add_point()

            elif event.key == pygame.K_s:  # drawing the curve form points
                self.on_key_store()

            elif event.key == pygame.K_c:
                self.on_key_clear()

            elif event.key == pygame.K_e:
                self.on_key_move_point()

        self.drag_point()

        if pygame.mouse.get_pressed()[0] and self.mouse_to_grid.screen.x < self.grid[
            0] and self.mouse_to_grid.screen.y < self.grid[
            1]:
            self.tilemap[int(self.mouse_to_grid.screen.x + self.mouse_to_grid.screen.y * self.grid[0])] = 0

        self.curve = self.join_points_with_lines(self.points)
        self.draw_points(self.curve)
        pygame.display.flip()

    @staticmethod
    def to_base2(num: int, b=3):
        """
        ToBase2 converts an integer num into a binary string, left‑padded with zeros to a fixed width b (default b=3),
        with one extra behavior: it clamps any value > 7 down to 7.
            ToBase2(0) -> "000"
            ToBase2(1) -> "001"
            ToBase2(2) -> "010"
            ToBase2(5) -> "101"
            ToBase2(7) -> "111"
            ToBase2(9) -> "111"
        """
        if num > 7:
            num = 7
        if num < 0:
            test = -num // 2
            wynik = str(int(-num % 2))
        else:
            test = num // 2
            wynik = str(int(num % 2))

        while test > 0:
            wynik = str(int(test % 2)) + wynik
            test = test // 2
        return ('0' * (b - len(wynik))) + wynik

    @staticmethod
    def join_points_with_lines(points: list[Coordinate]) -> list[Coordinate]:
        """
        Returns a new list of integer Points that contains all intermediate points
        on straight lines between consecutive input points (inclusive).

        Input points (user-inserted) keep user=True in the output.
        Generated intermediate points have user=False.
        """
        if not points:
            return []
        if len(points) == 1:
            return [points[0]]

        def bresenham(a: Coordinate, b: Coordinate) -> list[Coordinate]:
            x0, y0 = a.native.x, a.native.y
            x1, y1 = b.native.x, b.native.y

            dx = abs(x1 - x0)
            dy = abs(y1 - y0)
            sx = 1 if x0 < x1 else -1
            sy = 1 if y0 < y1 else -1

            err = dx - dy
            out: list[Coordinate] = []

            while True:
                is_endpoint = (x0 == a.native.x and y0 == a.native.y) or (x0 == b.native.x and y0 == b.native.y)
                if x0 == a.native.x and y0 == a.native.y:
                    user_flag = a.user
                elif x0 == b.native.x and y0 == b.native.y:
                    user_flag = b.user
                else:
                    user_flag = False

                out.append(Coordinate.from_native(x0, y0, user_flag if is_endpoint else False))

                if x0 == x1 and y0 == y1:
                    break

                e2 = 2 * err
                if e2 > -dy:
                    err -= dy
                    x0 += sx
                if e2 < dx:
                    err += dx
                    y0 += sy

            return out

        out: list[Coordinate] = []
        for i in range(len(points) - 1):
            segment = bresenham(points[i], points[i + 1])
            if i > 0:
                segment = segment[1:]  # avoid duplicating the shared endpoint
            out.extend(segment)

        return out

    @staticmethod
    def distances_to_asm(distances: list[Distance]) -> list[str]:
        asm: list[str] = []
        for dis in distances:
            dis_x = App.to_base2(dis.x)
            dis_y = App.to_base2(dis.y)
            asm.append(
                f"%{'1' if dis.x > 0 else '0'}'{dis_x}'{'1' if dis.y > 0 else '0'}'{dis_y},$3{dis.repeat:X}")
        return asm

    @staticmethod
    def points_to_distances(points: list[Point]) -> list[Distance]:
        """
        ### How it works:
        1. Raw Deltas: First, it calculates the `X` and `Y` step differences (dx, dy) between each consecutive Point.
        2. Chunking into Limits: It accumulates these single steps into chunks. If a chunk goes beyond 7/-7, or if it
            changes a direction (e.g.: from moving right to moving left), the current accumulated distance is finalized,
            and a new one starts.
        3. Compression/Repetition: Finally, it iterates through the chunks and groups matching adjacent movements.
           Each time it sees the exact same Distance chunk, it increments `repeat` (capping at 15).
        """
        if not points:
            return []

        # Calculate raw deltas step-by-step
        deltas = []
        for i in range(1, len(points)):
            dx = points[i].x - points[i - 1].x
            dy = points[i].y - points[i - 1].y
            deltas.append((dx, dy))

        # Aggregate deltas into chunks of max size 7
        # Assuming dx, dy are either 1, 0, or -1 per step from Bresenham
        chunks = []
        current_dx, current_dy = 0, 0

        for dx, dy in deltas:
            # If adding the next step exceeds the maximum allowed distance of 7 (or -7),
            # or if the direction changes, we start a new chunk.
            if (abs(current_dx + dx) > 7 or abs(current_dy + dy) > 7 or
                    (dx != 0 and current_dx != 0 and (dx > 0) != (current_dx > 0)) or
                    (dy != 0 and current_dy != 0 and (dy > 0) != (current_dy > 0))):

                if current_dx != 0 or current_dy != 0:
                    chunks.append((current_dx, current_dy))
                current_dx, current_dy = dx, dy
            else:
                current_dx += dx
                current_dy += dy

        if current_dx != 0 or current_dy != 0:
            chunks.append((current_dx, current_dy))

        # Reduce consecutive identical distances using the `repeat` field
        distances = []
        if not chunks:
            return []

        current_chunk = chunks[0]
        repeat_count = 0

        for i in range(1, len(chunks)):
            # Max repeat value is 15
            if chunks[i] == current_chunk and repeat_count < 15:
                repeat_count += 1
            else:
                distances.append(Distance(x=current_chunk[0], y=current_chunk[1], repeat=repeat_count))
                current_chunk = chunks[i]
                repeat_count = 0

        # Append the last accumulated distance
        distances.append(Distance(x=current_chunk[0], y=current_chunk[1], repeat=repeat_count))
        return distances

    def draw_grid(self):  # drawing grid to see the map clearly
        for i in range(self.grid[0]):
            pygame.draw.rect(self.screen, (255, 100, 40),
                             (i * self.box_size, 0, self.box_size, self.grid[1] * self.box_size), 1)
        for i in range(self.grid[1]):
            pygame.draw.rect(self.screen, (255, 100, 40),
                             (0, i * self.box_size, self.grid[0] * self.box_size, self.box_size), 1)

    def draw_points(self, points: list[Coordinate]):
        for i in range(len(points)):
            point = points[i]
            color = (0, 255, 0) if point.user else (0, 0, 255)
            ps = 4 if point.user else Coordinate.UI_SCALE
            pygame.draw.rect(self.screen, color, (point.screen.x, point.screen.y, ps, ps))

    @staticmethod
    def write_file(asm: list[str]):
        file_name = "trajectory.asm"
        if os.path.exists(file_name):
            os.remove(file_name)

        with open(file_name, "w") as file:
            file.write(f"DB {len(asm)}, ")
            file.write(", ".join(asm))
        print("Created ", len(asm), "entries.")

    def store(self):
        if not self.curve:
            return

        native = Coordinate.to_native(self.curve)
        distances = self.points_to_distances(native)
        asm = self.distances_to_asm(distances)
        self.write_file(asm)

    @staticmethod
    def read_tilemap(filename: str, width: int, height: int) -> list[int]:
        tilemap: list[int] = []
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
        return tilemap

    def draw_tilemap(self):  # draw the map from file
        for y in range(self.grid[1]):
            for x in range(self.grid[0]):
                try:
                    if self.tilemap[y * self.grid[0] + x] == 0:
                        pygame.draw.rect(self.screen, (0, 0, 0),
                                         (x * self.box_size, y * self.box_size, self.box_size, self.box_size))
                    else:
                        pygame.draw.rect(self.screen, (255, 255, 255),
                                         (x * self.box_size, y * self.box_size, self.box_size, self.box_size))
                except:
                    pygame.draw.rect(self.screen, (0, 255, 0),
                                     (x * self.box_size, y * self.box_size, self.box_size, self.box_size))

        self.draw_grid()

    @staticmethod
    def on_exit():
        pygame.quit()
        sys.exit()

    def on_key_clear(self):
        self.points = []
        self.curve = []

    def on_key_store(self):
        self.store()

    def on_key_add_point(self):
        self.points.append(Coordinate.from_screen_tuple(pygame.mouse.get_pos()))

    def drag_point(self):
        if self.point_to_drag is not None:
            self.points[self.point_to_drag] = Coordinate.from_screen_tuple(pygame.mouse.get_pos())

    def on_key_move_point(self):
        if self.point_to_drag is not None:
            self.point_to_drag = None
        else:
            for i in range(len(self.points)):
                if pygame.Rect(pygame.mouse.get_pos()[0], pygame.mouse.get_pos()[1], 1, 1).colliderect(
                        pygame.Rect(self.points[i].screen.x, self.points[i].screen.y, 10, 10)):
                    self.point_to_drag = i


if __name__ == "__main__":
    pygame.init()

    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-tm", "--tilemap",
        required=True,
        help="Path to tiles.map",
    )
    parser.add_argument(
        "-sc", "--scale",
        required=False,
        default=3,
        help="UI scale",
    )
    args = parser.parse_args()

    window = App(args.tilemap, int(args.scale))
