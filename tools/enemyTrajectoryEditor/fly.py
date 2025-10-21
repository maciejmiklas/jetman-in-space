import pygame
import sys

# Inicjalizacja Pygame
pygame.init()

# Ustawienia okna
szerokosc = 500
wysokosc = 500
ekran = pygame.display.set_mode((szerokosc, wysokosc))
pygame.display.set_caption("Moja gra")

# Kolory
bialy = (255, 255, 255)
czarny = (0, 0, 0)

player = [50,100]

# Zegar do kontrolowania FPS
zegar = pygame.time.Clock()


gra_dziala = True
with open("tools/enemyTrajectoryEditor/plik.txt", "r")as f:
        tab = f.readlines()
curindex = 0
while gra_dziala:
    
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            gra_dziala = False

    

    
    ekran.fill(bialy)  # Czyszczenie ekranu
    
    if tab[curindex][0] == 1:
         player[1] -= int(tab[curindex][1] + tab[curindex][2] + tab[curindex][3], 2)
    else:
         player[1] += int(tab[curindex][1] + tab[curindex][2] + tab[curindex][3], 2)
    
    if tab[curindex][4] == 1:
         player[0] -= int(tab[curindex][5] + tab[curindex][6] + tab[curindex][7], 2)
    else:
         player[0] += int(tab[curindex][5] + tab[curindex][6] + tab[curindex][7], 2)

    curindex += 1
    if curindex == len(tab):
         player = [50,100]
         curindex = 0
         
    pygame.draw.rect(ekran, (0,0,0), (player[0], player[1], 20, 20))

    pygame.display.flip()  # Aktualizacja ekranu

    # Utrzymanie 60 klatek na sekundę
    zegar.tick(30)

# Zamykanie gry
pygame.quit()
sys.exit()
