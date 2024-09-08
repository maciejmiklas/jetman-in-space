# ZX Spectrum Next game inspired by Jetpack
<img src="/img/cover.jpg" width="800px"/>


BMP must have 320256 with 8bit palette (Image -> Mode -> Indexed)
gfx2next -bitmap -pal-std -preview l002_background.bmp


AI text for title:
Headline text "Jetman in Space". Jetman flying from one planet to another. Carries backpack shooting down flames. Carries laser gun that shuts blue beam. Background contains space and planets, highly detailed retro graphics, dynamic movement across space

AI text for planetes:
retro planet, black background

Based on:
* [[Dougie Do][https://github.com/robgmoran/DougieDoSource]]
* ZX Spectrum Next Assembly Developer Guide by Tomaˇz Kragelj
* https://www.specnext.com/tbblue-io-port-system/
* https://github.com/ped7g/SpecBong


# Bank Organization
 * 18 - 23		In game background image
 * 24			Pallette for in game background image
 * 40 - 41		Sprites
 * 42			Tilemap
