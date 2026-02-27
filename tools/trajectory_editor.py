#!/usr/bin/env python3
import argparse
import os
import sys
from math import comb
from typing import TypeAlias, Sequence, Any

import pygame

Point: TypeAlias = tuple[float, float]
Step: TypeAlias = tuple[str, int]

# Keys:
# a - add point
# s - draw curve
# c - clear points
# e - edit point
class app:

    def __init__(self, tilemap_path: str):
        self.tilemap_path = tilemap_path
        self.grid = [40, 32]
        self.screenSizeMultiply = 3
        self.reduce_by = 5
        self.box_size = (320 / 40) * self.screenSizeMultiply
        self.points = []
        self.mouseTogrid = [pygame.mouse.get_pos()[0] // self.box_size, pygame.mouse.get_pos()[1] // self.box_size]
        self.curve = [[0, 0], [0, 0]]
        self.pointToMove = None
        self.screen = pygame.display.set_mode((320 * self.screenSizeMultiply, 256 * self.screenSizeMultiply))

        self.start_app()

    #  computes a Bezier curve defined by a list of control points (param points) and returns a list of sampled points
    #  along that smooth curve.
    @staticmethod
    def bezier_curve(points: list[Point], steps=500) -> list[Point]:
        n = len(points) - 1
        curve = []

        for step in range(steps + 1):
            t = step / steps
            x, y = 0.0, 0.0

            for i, (px, py) in enumerate(points):
                coeff = comb(n, i) * (1 - t) ** (n - i) * t ** i
                x += coeff * px
                y += coeff * py

            curve.append((x, y))

        return curve

    @staticmethod
    def read_tilemap(filename: str, width: int, height: int):
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
        return tilemap

    def draw_grid(self):  # drawing grid to see the map clearly
        for i in range(self.grid[0]):
            pygame.draw.rect(self.screen, (255, 100, 40),
                             (i * self.box_size, 0, self.box_size, self.grid[1] * self.box_size), 1)
        for i in range(self.grid[1]):
            pygame.draw.rect(self.screen, (255, 100, 40),
                             (0, i * self.box_size, self.grid[0] * self.box_size, self.box_size), 1)

    def start_app(self):  # starts the app
        self.map = self.read_tilemap(self.tilemap_path, self.grid[0], self.grid[1])
        self.map[0] = 1
        self.draw_map()

        while True:
            self.mouseTogrid = [pygame.mouse.get_pos()[0] // self.box_size, pygame.mouse.get_pos()[1] // self.box_size]
            self.main_loop()

    def draw_curve(self, c1):
        if len(c1) > 1:
            pygame.draw.lines(self.screen, (0, 255, 0), False, c1, 2)
        for i in range(len(self.points)):
            pygame.draw.rect(self.screen, (0, 255, 0), (self.points[i][0], self.points[i][1], 5, 5))

    def main_loop(self):  # makes a main loop for the program
        for event in pygame.event.get():  # event handling
            self.draw_map()
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_a:  # adding a point for the curve
                    self.points.append(pygame.mouse.get_pos())
                if event.key == pygame.K_s:  # drawing the curve form points
                    self.curve = self.bezier_curve(self.points)
                    self.curve_to_asm(self.curve)

                if event.key == pygame.K_c:
                    self.points = []
                    self.curve = []
                if event.key == pygame.K_e:
                    if self.pointToMove != None:
                        self.pointToMove = None
                    else:
                        for i in range(len(self.points)):
                            if pygame.Rect(pygame.mouse.get_pos()[0], pygame.mouse.get_pos()[1], 1, 1).colliderect(
                                    pygame.Rect(self.points[i][0], self.points[i][1], 15, 15)):
                                self.pointToMove = i
            if self.pointToMove != None:
                self.points[self.pointToMove] = pygame.mouse.get_pos()

        if pygame.mouse.get_pressed()[0] and self.mouseTogrid[0] < self.grid[0] and self.mouseTogrid[1] < self.grid[1]:
            self.map[int(self.mouseTogrid[0] + self.mouseTogrid[1] * self.grid[0])] = 0

        self.draw_curve(self.curve)
        pygame.display.flip()

    def draw_map(self):  # draw the map from file
        for y in range(self.grid[1]):
            for x in range(self.grid[0]):
                try:
                    if self.map[y * self.grid[0] + x] == 0:
                        pygame.draw.rect(self.screen, (0, 0, 0),
                                         (x * self.box_size, y * self.box_size, self.box_size, self.box_size))
                    else:
                        pygame.draw.rect(self.screen, (255, 255, 255),
                                         (x * self.box_size, y * self.box_size, self.box_size, self.box_size))
                except:
                    pygame.draw.rect(self.screen, (0, 255, 0),
                                     (x * self.box_size, y * self.box_size, self.box_size, self.box_size))

        self.draw_grid()

    # ToBase2 converts an integer num into a binary string, left‑padded with zeros to a fixed width b (default b=3),
    # with one extra behavior: it clamps any value > 7 down to 7.
    # ToBase2(0)  -> "000"
    # ToBase2(1)  -> "001"
    # ToBase2(2)  -> "010"
    # ToBase2(5)  -> "101"
    # ToBase2(7)  -> "111"
    # ToBase2(9)  -> "111"
    @staticmethod
    def to_base2(num:int, b=3):
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
    def reduce_curve(self, curve: list[Point], tab=None) -> list[Point]:
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

    def curve_to_asm(self, curve_full: list[Point]):
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
                file.write("%"+i[0] + ",$3" + f"{i[1]:X}")
                file.write(", ")
        print("Created ", entry_cnd, "entries.")

    # IN: ['00100010', '00100010', '00100010', '00100010', '00010010', '00010010', '00010010', '00010010', '00010010',...
    # OUT: [['00100010', 3], ['00010010', 4], ['00000010', 15], ['00000010', 1], ['10010010', 15], ['10010010', 4],...
    @staticmethod
    def reduce_curve_bin(curve_bin: list[str]) -> list[Step]:
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

    # The output list has the same length as the input list. Input list contains the coordinates of the curve points.
    # The output list contains the binary representation of the curve points, but not as coordinates, but the number of
    # steps to travel from the current point to the next point.
    # Example:
    # IN: [[72.993485776, 327.936370984], [80.927648784, 324.006986056], [88.79730132799999, 320.25300695199996]
    # OUT: ['10010010', '10010010', '10010010', '10010010', '10010010', '10010010', '00000010', '00000010', '00000010'
    def curve_to_bin(self, curve: list[Point]) -> list[str]:
        tab = []
        for i in range(len(curve) - 1):
            movement = ""
            c1 = [curve[i + 1][0] / self.screenSizeMultiply, curve[i + 1][1] / self.screenSizeMultiply]
            c0 = [curve[i][0] / self.screenSizeMultiply, curve[i][1] / self.screenSizeMultiply]

            x = round(c1[0] - c0[0])
            y = round(c1[1] - c0[1])

            print(x, y)
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
    args = parser.parse_args()

    window = app(args.tilemap)
