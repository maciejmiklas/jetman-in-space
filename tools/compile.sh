#!/bin/bash

cd /Users/mmiklas/Development/ZX_Spectrum/prj/jetman-in-space
sjasmplus src/main.asm --lst=bin/jetmal.lst --zxnext=cspect --outprefix=bin/ || {
  echo "Build failed, exiting" >&2
  exit 1
}

cp /Users/mmiklas/Development/ZX_Spectrum/prj/jetman-in-space/bin/jetman.nex /Volumes/SystemNext/prj/
cp -fr /Users/mmiklas/Development/ZX_Spectrum/prj/jetman-in-space/bin/assets /Volumes/SystemNext/prj/

cd /Users/mmiklas/Development/ZX_Spectrum/opt/cspect

# -fullscreen
mono cspect.exe -brk -w6 -zxnext -nextrom -mmc=/Users/mmiklas/Development/ZX_Spectrum/opt/cspect-next/cspect-next-2g.img -map=/Users/mmiklas/Development/ZX_Spectrum/prj/jetman-in-space/bin/jetman.map