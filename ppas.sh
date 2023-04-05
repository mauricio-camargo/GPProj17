#!/bin/sh
DoExitAsm ()
{ echo "An error occurred while assembling $1"; exit 1; }
DoExitLink ()
{ echo "An error occurred while linking $1"; exit 1; }
echo Linking /home/mauricio/Dropbox/Lazarus/aaaGPProj15/GPProj15
OFS=$IFS
IFS="
"
/usr/bin/ld -b elf64-x86-64 -m elf_x86_64  --dynamic-linker=/lib64/ld-linux-x86-64.so.2   -s  -L. -o /home/mauricio/Dropbox/Lazarus/aaaGPProj15/GPProj15 -T /home/mauricio/Dropbox/Lazarus/aaaGPProj15/link.res -e _start
if [ $? != 0 ]; then DoExitLink /home/mauricio/Dropbox/Lazarus/aaaGPProj15/GPProj15; fi
IFS=$OFS
