from math import comb

def bezier_curve(points, steps=100):
    n = len(points) - 1
    curve = []

    for step in range(steps + 1):
        t = step / steps
        x, y = 0.0, 0.0

        for i, (px, py) in enumerate(points):
            coeff = comb(n, i) * (1 - t)**(n - i) * t**i
            x += coeff * px
            y += coeff * py

        curve.append((x, y))

    return curve
