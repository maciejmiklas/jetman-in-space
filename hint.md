That sounds like a fun project! Here are some ideas and techniques for implementing "natural" enemy following behavior in a ZX80 assembly game, especially given the constraints of the hardware:

### 1. **Simple Homing/Chasing Algorithm**
Start with the basics: have the enemy always move 1 pixel (or character cell) closer to the player each update.

#### Pseudocode:
```
if enemy_x < player_x: enemy_x += 1
if enemy_x > player_x: enemy_x -= 1
if enemy_y < player_y: enemy_y += 1
if enemy_y > player_y: enemy_y -= 1
```
This produces a simple "homing" effect.

---

### 2. **Add Some Inertia (Smoothing)**
Instead of moving immediately to the player's position, have the enemy "lag" behind a bit, e.g. by changing position only every N frames, or moving by more than 1 unit if far away.

#### Example:
- Store a direction (dx, dy) for the enemy.
- Every few frames, recalculate dx/dy based on the vector to the player.
- Move the enemy by dx/dy each frame.

#### Assembly Consideration:
- Use simple arithmetic (add/subtract) to update positions.
- Avoid division or multiplication unless you really need it; use shifts if possible.

---

### 3. **Random "Wobble"**
To make movement less predictable, add a small random offset to the enemy's direction every few frames. This can be as simple as picking a random direction and adding it to the movement vector, or just flipping direction with a small probability.

#### Example:
- With a 1/8 chance per frame, add +1 or -1 to the enemy's vertical or horizontal direction.

---

### 4. **Line of Sight or Obstacles**
If you have obstacles, you can make enemies avoid them by checking ahead before moving. On ZX80, this must be very simple: check if the next cell is empty before moving.

---

### 5. **Speed Variation**
Enemies can be made to move at different speeds (e.g. every Nth frame) to add variety.

---

### 6. **Pathfinding?**
Full pathfinding (like A*) is likely too heavy for ZX80, but you can simulate "smarter" movement by:
- Having the enemy "pause" when blocked, then pick a new direction.
- Letting enemies "patrol" until the player is close, then home in.

---

### Example (Pseudo-Assembly):

Suppose you store player and enemy positions as bytes:

```assembly
; Player: (PX, PY)
; Enemy: (EX, EY)
; Each frame:

LD A, [EX]
CP [PX]
JP Z, SkipX
JP C, IncEX ; EX < PX
DEC [EX]    ; EX > PX
JP SkipX
IncEX:
INC [EX]
SkipX:

LD A, [EY]
CP [PY]
JP Z, SkipY
JP C, IncEY ; EY < PY
DEC [EY]    ; EY > PY
JP SkipY
IncEY:
INC [EY]
SkipY:
```

---

### Tips for ZX80 Assembly
- Keep your enemy logic simple; the CPU is slow and memory is tight.
- If you want smoother movement, use fixed-point (byte + fractional) to store positions and apply movement.
- Consider updating enemies less frequently than the player (e.g. every 2nd or 3rd frame).

---

### References & Inspiration
- [Red Ghost AI in Pac-Man (simple tile-based chasing)](https://gameinternals.com/understanding-pac-man-ghost-behavior)
- [ZX80/81 Assembly Programming](https://sinclairzxworld.com/viewtopic.php?t=1194)

---

**Summary Table:**

| Technique         | Description                          | Complexity | Look/Feel         |
|-------------------|--------------------------------------|------------|-------------------|
| Direct Homing     | Always move toward player            | Low        | Simple, robotic   |
| Inertia/Smoothing | Lag behind, update direction slowly  | Low-Med    | Smoother, natural |
| Random Wobble     | Add random offset to movement        | Low        | Less predictable  |
| Speed Variation   | Move at different speeds             | Low        | Varied enemies    |
| Obstacles/LOS     | Avoid walls, simple checks           | Med        | Smarter           |

If you want a specific code example for a ZX80/81 assembler (like z80asm or z88dk), let me know your preference!