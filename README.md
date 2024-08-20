ZX Spectrum Next game inspired by Jetpack

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







https://wiki.specnext.dev/Palettes
https://colordesigner.io/gradient-generator

export function next512FromRGB({ r, g, b }) {
  r = ((r / 32) | 0) << 6;
  g = ((g / 32) | 0) << 3;
  b = (b / 32) | 0;

  return r + g + b;
}

#292F56
#29325A
#29355D
#293860
#283B64
#283E67
#27416A
#26446E
#254871
#244B74
#234E77
#21517A
#20547D
#1E5880
#1C5B82
#1A5E85
#186188
#15658A
#12688D
#0F6B8F
#0C6E91
#087293
#057595
#017897
#007C99
#007F9B
#00829C
#00869E
#00899F
#008CA1
#0090A2
#0093A3
#0097A5
#009BA6
#009EA7
#00A2A8
#00A6A8
#00AAA8
#00ADA8
#00B1A8
#00B5A8
#00B8A7
#00BCA6
#00C0A5
#00C3A3
#00C7A2
#03CAA0
#18CE9E
#26D19C
#31D499
#3CD897
#46DB94
#4FDE91
#58E18E
#62E48B
#6BE788
#74EA85
#7DED81
#86F07E
#90F27A
#99F577
#A2F873
#ACFA70