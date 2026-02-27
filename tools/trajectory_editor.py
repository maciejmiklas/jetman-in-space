#!/usr/bin/env python3
import argparse
import os
import sys
from dataclasses import dataclass
from math import comb
from typing import TypeAlias, ClassVar

import pygame

PointFl: TypeAlias = tuple[float, float]
Step: TypeAlias = tuple[str, int]


@dataclass(frozen=True, slots=True)
class Point:
    # screen coordinates of the point.
    xs: int
    ys: int

    # native coordinates of the point (320x256).
    xn: int = 0
    yn: int = 0

    # true for a user inserted point, false for a generated point.
    user: bool = True

    UI_SCALE: ClassVar[int] = 3

    @classmethod
    def from_native(cls, xn: int, yn: int, user=True) -> "Point":
        return cls(xn * Point.UI_SCALE, yn * Point.UI_SCALE, xn, yn, user)

    @classmethod
    def from_screen(cls, xs: int, ys: int, user=True) -> "Point":
        return cls(xs, ys, round(xs / Point.UI_SCALE), round(ys / Point.UI_SCALE), user)

    @classmethod
    def from_screen_tuple(cls, inp: tuple[float, float], user=True) -> "Point":
        return cls(round(inp[0]), round(inp[1]), round(inp[0] / Point.UI_SCALE), round(inp[1] / Point.UI_SCALE), user)


# Keys:
# A - add point
# S - draw a curve
# C - clear points
# E - edit point
class TrajectoryEditor:

    def __init__(self, tilemap_path: str, ui_scale=3):
        self.tilemap: list[int] = []
        self.tilemap_path = tilemap_path
        self.grid = [40, 32]
        Point.UI_SCALE = ui_scale
        self.reduce_by = 5
        self.box_size = (320 / 40) * Point.UI_SCALE

        # Points inserted by the user
        self.points: list[Point] = []

        # Point being dragged by the user/mause.
        self.point_to_drag: int | None = None

        # gird has the size of the tilemap: 40x32, but counts from 0, so 39x41
        self.mouse_to_grid: Point = Point(0, 0)
        self.curve = [[0, 0], [0, 0]]
        self.screen = pygame.display.set_mode((320 * Point.UI_SCALE, 256 * Point.UI_SCALE))

        self.start_app()

    #  computes a Bézier curve defined by a list of control points (param points) and returns a list of sampled points
    #  along that smooth curve.
    @staticmethod
    def bezier_curve(points: list[Point], steps=500) -> list[PointFl]:
        n = len(points) - 1
        curve = []

        for step in range(steps + 1):
            t = step / steps
            x, y = 0.0, 0.0

            for i, p in enumerate(points):
                coeff = comb(n, i) * (1 - t) ** (n - i) * t ** i
                x += coeff * p.xs
                y += coeff * p.ys

            curve.append((x, y))

        return curve

    @staticmethod
    def join_points_with_lines(points: list[Point]) -> list[Point]:
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

        def bresenham(a: Point, b: Point) -> list[Point]:
            x0, y0 = a.xn, a.yn
            x1, y1 = b.xn, b.yn

            dx = abs(x1 - x0)
            dy = abs(y1 - y0)
            sx = 1 if x0 < x1 else -1
            sy = 1 if y0 < y1 else -1

            err = dx - dy
            out: list[Point] = []

            while True:
                is_endpoint = (x0 == a.xn and y0 == a.yn) or (x0 == b.xn and y0 == b.yn)
                if x0 == a.xn and y0 == a.yn:
                    user_flag = a.user
                elif x0 == b.xn and y0 == b.yn:
                    user_flag = b.user
                else:
                    user_flag = False

                out.append(Point.from_native(x0, y0, user_flag if is_endpoint else False))

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

        out: list[Point] = []
        for i in range(len(points) - 1):
            segment = bresenham(points[i], points[i + 1])
            if i > 0:
                segment = segment[1:]  # avoid duplicating the shared endpoint
            out.extend(segment)

        return out

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

    def draw_grid(self):  # drawing grid to see the map clearly
        for i in range(self.grid[0]):
            pygame.draw.rect(self.screen, (255, 100, 40),
                             (i * self.box_size, 0, self.box_size, self.grid[1] * self.box_size), 1)
        for i in range(self.grid[1]):
            pygame.draw.rect(self.screen, (255, 100, 40),
                             (0, i * self.box_size, self.grid[0] * self.box_size, self.box_size), 1)

    def start_app(self):  # starts the app
        self.tilemap = self.read_tilemap(self.tilemap_path, self.grid[0], self.grid[1])
        self.tilemap[0] = 1
        self.draw_tilemap()

        while True:
            self.main_loop()

    def draw_curve(self, c1):
        if len(c1) > 1:
            pygame.draw.lines(self.screen, (0, 255, 0), False, c1, 2)
        for i in range(len(self.points)):
            pygame.draw.rect(self.screen, (0, 255, 0), (self.points[i].xs, self.points[i].ys, 5, 5))

    def draw_points(self, points: list[Point]):
        for i in range(len(points)):
            point = points[i]
            color = (0, 255, 0) if point.user else (0, 0, 255)
            ps = 4 if point.user else Point.UI_SCALE
            pygame.draw.rect(self.screen, color, (point.xs, point.ys, ps, ps))

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
                self.on_key_draw_curve()

            elif event.key == pygame.K_c:
                self.on_key_clear()

            elif event.key == pygame.K_e:
                self.on_key_move_point()

        self.drag_point()

        if pygame.mouse.get_pressed()[0] and self.mouse_to_grid.xs < self.grid[0] and self.mouse_to_grid.ys < self.grid[
            1]:
            self.tilemap[int(self.mouse_to_grid.xs + self.mouse_to_grid.ys * self.grid[0])] = 0

        #self.draw_curve(self.curve)

        full = self.join_points_with_lines(self.points)
        print(">>", len(full))
        self.draw_points(full)

        pygame.display.flip()

    @staticmethod
    def on_exit():
        pygame.quit()
        sys.exit()

    def on_key_clear(self):
        self.points = []
        self.curve = []

    def on_key_draw_curve(self):
        self.curve = self.bezier_curve(self.points)
        self.curve_to_asm(self.curve)

    def on_key_add_point(self):
        self.points.append(Point.from_screen_tuple(pygame.mouse.get_pos()))

    def drag_point(self):
        if self.point_to_drag is not None:
            self.points[self.point_to_drag] = Point.from_screen_tuple(pygame.mouse.get_pos())

    def on_key_move_point(self):
        if self.point_to_drag is not None:
            self.point_to_drag = None
        else:
            for i in range(len(self.points)):
                if pygame.Rect(pygame.mouse.get_pos()[0], pygame.mouse.get_pos()[1], 1, 1).colliderect(
                        pygame.Rect(self.points[i].xs, self.points[i].ys, 10, 10)):
                    self.point_to_drag = i

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

    #  down-samples a dense list of curve points into a shorter list whare distance between points is less than 7.
    def reduce_curve(self, curve: list[PointFl], tab=None) -> list[PointFl]:
        if tab is None:
            tab = []
        maxi = 0
        if len(curve) > 0:
            for i in range(1, len(curve)):
                x, y = curve[i][0] - curve[0][0], curve[i][1] - curve[0][1]
                if x > self.reduce_by or y > self.reduce_by:
                    maxi = i - 1
                    tab.append([curve[i - 1][0], curve[i - 1][1]])
                    break
        else:
            return tab
        return self.reduce_curve(curve[maxi + 1:], tab)

    def curve_to_asm(self, curve_full: list[PointFl]):
        curve = self.reduce_curve(curve_full, [])
        curve_bin = self.curve_to_bin(curve)

        result = self.reduce_curve_bin(curve_bin)
        trajectory_file_name = "trajectory.asm"
        if os.path.exists("trajectory.asm"):
            os.remove(trajectory_file_name)

        entry_cnd = 0
        with open(trajectory_file_name, "w") as file:
            for i in result:
                entry_cnd = entry_cnd + 1
                file.write("%" + i[0] + ",$3" + f"{i[1]:X}")
                file.write(", ")
        print("Created ", entry_cnd, "entries.")

    @staticmethod
    def reduce_curve_bin(curve_bin: list[str]) -> list[Step]:
        """
        # IN: ['00100010', '00100010', '00100010', '00100010', '00010010', '00010010', '00010010', '00010010',...
        # OUT: [['00100010', 3], ['00010010', 4], ['00000010', 15], ['00000010', 1], ['10010010', 15],...
        """
        result = []
        count = 0
        for i in range(1, len(curve_bin)):
            if curve_bin[i] == curve_bin[i - 1]:
                count += 1
                if count == 15:
                    result.append([curve_bin[i - 1], count])
                    count = 0
            else:
                result.append([curve_bin[i - 1], count])
                count = 0
        return result

    def curve_to_bin(self, curve: list[PointFl]) -> list[str]:
        """
        The output list has the same length as the input list. Input list contains the coordinates of the curve points.
        The output list contains the binary representation of the curve points, but not as coordinates, but the number
        of steps to travel from the current point to the next point.
        Example:
            IN: [[72.993485776, 327.936370984], [80.927648784, 324.006986056], [88.79730132799999, 320.25300695199996], ...
            OUT: ['10010010', '10010010', '10010010', '10010010', '10010010', '10010010', '00000010', '00000010', ...
        """
        tab = []
        for i in range(len(curve) - 1):
            movement = ""
            c1 = [curve[i + 1][0] / Point.UI_SCALE, curve[i + 1][1] / Point.UI_SCALE]
            c0 = [curve[i][0] / Point.UI_SCALE, curve[i][1] / Point.UI_SCALE]

            x = round(c1[0] - c0[0])
            y = round(c1[1] - c0[1])

            if y < 0:
                movement += "0'"
                y = -y
            else:
                movement += "1'"
            movement += self.to_base2(y)

            if x < 0:
                movement += "'0'"
                x = -x
            else:
                movement += "'1'"
            movement += self.to_base2(x)
            tab.append(movement)
        return tab


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

    window = TrajectoryEditor(args.tilemap, int(args.scale))
