#!/bin/bash

SD_CARD=/dev/disk8
CP_FROM=bin/jetman.nex 
CP_TO=/Volumes/ZX_NEXT/home/DEV/prj/test_asm/project.nex
SJASMPLUS=/Users/mmiklas/Development/ZX_Spectrum/opt/sjasmplus/sjasmplus 
set -e

echo "Compiling Jetman in Space into bin"

$SJASMPLUS src/main.asm --lst=bin/jetmal.lst --zxnext=cspectpwd --outprefix=bin/

#read -p "Copy to SD card ? (Y/n)?" -n 1 -r
#echo
#if [[ $REPLY =~ ^[Nn]$ ]]
#then
#    echo Skipping
#else
    cp -v $CP_FROM $CP_TO
    diskutil unmountDisk $SD_CARD
    diskutil eject $SD_CARD
#fi

