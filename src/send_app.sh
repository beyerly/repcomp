#!/bin/bash

echo Compiling 1-page app
../../../tools/vasm/vasm6502_oldstyle -Fbin -ole -dotdir app.s -L symbols.txt -o app.o


size=$(ls -alF app.o | grep  -oP ".......... [0-9]* [a-z]* [a-z]* \K[0-9]*")



echo "big-endian" > app_header.txt
echo "FF"$size >> app_header.txt

cat app_header.txt


echo Encode app.o size in bytes into app header. big-endian!
../../../binmake/bin/binmake app_header.txt  app_header.out


cat app_header.out app.o > app.exe

stty -F /dev/ttyUSB0  19200 cs8 parenb -cstopb

echo sending app...
#echo "z" >  /dev/ttyUSB0
cat app.exe > /dev/ttyUSB0



