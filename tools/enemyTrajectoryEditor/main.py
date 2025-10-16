import pygame
import sys
import fileReader
import bezier



class app:
    def __init__(self, screen, dimensions):
        self.dimensions = dimensions
        self.screen = screen
        self.grid = [40, 32]
        self.box_size = 15
        self.points = []
        self.mouseTogrid = [pygame.mouse.get_pos()[0] // self.box_size, pygame.mouse.get_pos()[1] // self.box_size]

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


    def mainLoop(self): # makes a main loop for the program
        for event in pygame.event.get(): # event handling 
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_a: # adding a point for the curve
                    self.points.append(pygame.mouse.get_pos())
                if event.key == pygame.K_s: # drawing the curve form points
                    self.draw_map()
                    print(self.points)
                    curve = bezier.bezier_curve(self.points)
                    pygame.draw.lines(screen, (0, 255, 0), False, curve, 2)
                    for i in range(len(self.points)):
                        pygame.draw.rect(self.screen, (0, 255, 0), (self.points[i][0], self.points[i][1], 5, 5))
                if event.key == pygame.K_c:
                    self.draw_map()
                    self.points = []

        if pygame.mouse.get_pressed()[0] and self.mouseTogrid[0] < self.grid[0] and self.mouseTogrid[1] < self.grid[1]:
            self.map[self.mouseTogrid[0] + self.mouseTogrid[1] * self.grid[0]] = 0
            self.draw_map()
  
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
             



if __name__ == "__main__":
    pygame.init()
    x,y = 800, 700
    screen = pygame.display.set_mode((x,y))
    window = app(screen, [x,y])
