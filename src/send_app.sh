#!/bin/bash


# Compile and send binary to GRU-10

#APP=appload.s
#APP=app_clr.s
APP=app_cli.s
#APP=app_scroll.s


S_START=0x8054
S_GET_CHAR=0x826D
S_LED_PATTERN1=0x8096
S_LED_PATTERN=0x8072
S_WOZMON=0x8228
S_LOAD_APP=0x8153
S_LIST_APP=0x8133
S_EXE_APP=0x8122
S_SND_STR=0x8195
S_SEND_CHAR=0x8291
S_SND_CR=0x819C
S_CLEAR_SCREEN=0x8608

echo Compiling 1-page app

../../../tools/vasm/vasm6502_oldstyle -Fbin -ole -dotdir $APP -L symbols.txt -o app.o -wdc02 -Dget_char=$S_GET_CHAR -Dstart=$S_START -Dled_pattern1=$S_LED_PATTERN1 -Dled_pattern=$S_LED_PATTERN -Dwozmon=$S_WOZMON -Dload_app=$S_LOAD_APP -Dlist_app=$S_LIST_APP -Dexe_app=$S_EXE_APP -Dsnd_str=$S_SND_STR -Dsend_char=$S_SEND_CHAR -Dsnd_cr=$S_SND_CR -Dclear_screen=$S_CLEAR_SCREEN


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



