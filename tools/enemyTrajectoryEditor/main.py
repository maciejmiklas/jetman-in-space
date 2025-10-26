import pygame
import sys
import fileReader
import bezier
import math
import os


class app:
    def __init__(self):
        self.grid = [40, 32]
        self.screenSizeMultiply = 3
        self.box_size = (320 / 40) * self.screenSizeMultiply
        self.points = []
        self.mouseTogrid = [pygame.mouse.get_pos()[0] // self.box_size, pygame.mouse.get_pos()[1] // self.box_size]
        self.curve = [[0,0], [0,0]]

        self.pointToMove = None

        self.screen = pygame.display.set_mode((320 * self.screenSizeMultiply,256 * self.screenSizeMultiply))

        self.startApp()


    def drawGrid(self): #drawing grid to see the map clearly
        for i in range(self.grid[0]):
            pygame.draw.rect(self.screen, (255,0,0), (i*self.box_size,0,self.box_size, self.grid[1] * self.box_size), 1)
        for i in range(self.grid[1]):
            pygame.draw.rect(self.screen, (255,0,0), (0,i*self.box_size,self.grid[0] * self.box_size, self.box_size), 1)
    

    def startApp(self): # starts the app
        self.map = fileReader.read_tilemap("assets/01/tiles.map", self.grid[0], self.grid[1])
        self.map[0] = 1
        self.draw_map()

        while True:
            self.mouseTogrid = [pygame.mouse.get_pos()[0] // self.box_size, pygame.mouse.get_pos()[1] // self.box_size]
            self.mainLoop()

    def drawCurve(self, c1):
        if len(c1) > 1:
            pygame.draw.lines(self.screen, (0, 255, 0), False, c1, 2)
        for i in range(len(self.points)):
            pygame.draw.rect(self.screen, (0, 255, 0), (self.points[i][0], self.points[i][1], 5, 5))
    def mainLoop(self): # makes a main loop for the program
        for event in pygame.event.get(): # event handling 
            self.draw_map()
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_a: # adding a point for the curve
                    self.points.append(pygame.mouse.get_pos())
                if event.key == pygame.K_s: # drawing the curve form points
                    self.curve = bezier.bezier_curve(self.points)
                    print(len(self.curve))
                    print(self.points)
                    self.curveToMove(self.curve)
                    
                    
                if event.key == pygame.K_c:
                    self.points = []
                    self.curve = []
                if event.key == pygame.K_e:
                    if self.pointToMove != None:
                        self.pointToMove = None
                    else:
                        for i in range(len(self.points)):
                            if pygame.Rect(pygame.mouse.get_pos()[0], pygame.mouse.get_pos()[1], 1,1).colliderect(pygame.Rect(self.points[i][0], self.points[i][1],15,15)):
                                self.pointToMove = i
            if self.pointToMove != None:
                self.points[self.pointToMove] = pygame.mouse.get_pos()

        if pygame.mouse.get_pressed()[0] and self.mouseTogrid[0] < self.grid[0] and self.mouseTogrid[1] < self.grid[1]:
            self.map[int(self.mouseTogrid[0] + self.mouseTogrid[1] * self.grid[0])] = 0
            print(pygame.mouse.get_pos()[0] // self.screenSizeMultiply, pygame.mouse.get_pos()[1] // self.screenSizeMultiply)
        
        self.drawCurve(self.curve)
            
  
        pygame.display.flip()


    def draw_map(self): # draw the map from file
        for y in range(self.grid[1]):
            for x in range(self.grid[0]):
                try:
                    if self.map[y*self.grid[0] + x] == 0:
                        pygame.draw.rect(self.screen, (0, 0, 0), (x * self.box_size, y * self.box_size, self.box_size, self.box_size))

                    else:
                        pygame.draw.rect(self.screen, (255,255,255), (x*self.box_size, y * self.box_size, self.box_size, self.box_size))
                except:
                    pygame.draw.rect(self.screen, (0, 255, 0), (x * self.box_size, y * self.box_size, self.box_size, self.box_size))
                    
        self.drawGrid()
    

    def ToBase2(self, num):
        if num > 7:
            num = 7
        if (num < 0):
            test = -num // 2
            wynik = str(int(-num % 2))
        else:
            test = num // 2
            wynik = str(int(num % 2))
        
        while test > 0:
            wynik = str(int(test % 2)) + wynik
            test = test//2
        return ('0' * (3 - len(wynik))) + wynik

    def fixCurve(self, curve, tab=[]):
        maxi = 0
        if len(curve) > 0:
            for i in range(1,len(curve)):
                x, y = curve[i][0] - curve[0][0], curve[i][1] - curve[0][1]
                if x > 7 or y > 7:
                    maxi = i-1
                    tab.append((curve[i-1][0],curve[i-1][1]))
                    break
        else:
            return tab
        return self.fixCurve(curve[maxi + 1:], tab)


    def curveToMove(self, curven):
        curve = self.fixCurve(curven, [])
        os.remove("tools/enemyTrajectoryEditor/plik.txt")
        with open("tools/enemyTrajectoryEditor/plik.txt", "w") as file:
            for i in range(len(curve) - 1):
                movement = ""
                c1 = [curve[i+1][0] // self.screenSizeMultiply, curve[i+1][1] // self.screenSizeMultiply]
                c0 = [curve[i][0] // self.screenSizeMultiply, curve[i][1] // self.screenSizeMultiply]
                pygame.draw.rect(self.screen, (0, 0, 255), (c0[0], c0[1], 5, 5))

                x = int(c1[0] - c0[0])
                y = int(c1[1] - c0[1])

                if y < 0:
                    movement += "1"
                    y = -y
                else:
                    movement += "0"
                movement += self.ToBase2(y)

                if x < 0:
                    movement += "1"
                    x = -x
                else:
                    movement += "0"
                movement += self.ToBase2(x)

                file.write(movement + "\n")


            
                


if __name__ == "__main__":
    pygame.init()
    window = app()
