#!/bin/bash

SIMULATOR=false
#SIMULATOR=true
BIOS_SYMBOLS=symbols_bios.txt

#APP=appload.s
#APP=app_clr.s
APP=app_cli.s
#APP=app_scroll.s

find_symbol () {
   echo 0x$(cat $BIOS_SYMBOLS | sed -n "s/^\([0-9A-Z]*\) $1$/\1/p")
}

S_START=$(find_symbol "start")
S_GET_CHAR=$(find_symbol "get_char")
S_WOZMON=$(find_symbol "wozmon")
S_LOAD_APP=$(find_symbol "load_app")
S_LIST_APP=$(find_symbol "list_app")
S_EXE_APP=$(find_symbol "exe_app")
S_SND_STR=$(find_symbol "snd_str")
S_SEND_CHAR=$(find_symbol "send_char")
S_SND_CR=$(find_symbol "snd_cr")
S_CLEAR_SCREEN=$(find_symbol "clear_screen")
S_PRBYTE=$(find_symbol "PRBYTE")

echo Compiling app

#../../../../tools/vasm/vasm6502_oldstyle -Fbin -ole -dotdir $APP -L symbols.txt -o app.o -wdc02 -Dget_char=$S_GET_CHAR -Dstart=$S_START -Dwozmon=$S_WOZMON -Dload_app=$S_LOAD_APP -Dlist_app=$S_LIST_APP -Dexe_app=$S_EXE_APP -Dsnd_str=$S_SND_STR -Dsend_char=$S_SEND_CHAR -Dsnd_cr=$S_SND_CR -Dclear_screen=$S_CLEAR_SCREEN
if [ "$SIMULATOR" == true ]; then
   echo Compiling for simulator
   ../../../../tools/vasm/vasm6502_oldstyle -Fbin -ole -dotdir $APP -L symbols.txt -o app.o -wdc02 \
   -DSIMULATOR=1
else
  echo Compile and send binary to GRU-10
  ../../../../tools/vasm/vasm6502_oldstyle -Fbin -ole -dotdir $APP -L symbols.txt -o app.o -wdc02 \
-Dget_char=$S_GET_CHAR \
-Dsend_char=$S_SEND_CHAR \
-Dsnd_str=$S_SND_STR \
-Dsnd_cr=$S_SND_CR \
-DPRBYTE=$S_PRBYTE
fi


size=$(ls -alF app.o | grep  -oP ".......... [0-9]* [a-z]* [a-z]* \K[0-9]*")

size_hex_l=$(printf "%02x" $(($size & 0xFF)))
size_hex_h=$(printf "%02x" $(($size >> 8)))

echo "big-endian" > app_header.txt
echo "FF00"$size_hex_l$size_hex_h >> app_header.txt
#echo "FF00"$size_hex_l >> app_header.txt

cat app_header.txt

echo Encode app.o size in bytes into app header. big-endian!
../../../../tools/binmake/bin/binmake app_header.txt  app_header.out

cat app_header.out app.o > app.exe

stty -F /dev/ttyUSB0  19200 cs8 parenb -cstopb

echo sending app...
cat app.exe > /dev/ttyUSB0
