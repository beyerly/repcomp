
# 1-page app
../../../tools/vasm/vasm6502_oldstyle -Fbin -ole -dotdir app.s -L symbols.txt -o 
# Encode app.o size in bytes into app header. big-endian!
../../../binmake/bin/binmake app_header.txt  app_header.out 
app.o 
cat app_header.out app.o > app.exe
stty -F /dev/ttyUSB0  19200 cs8 parenb -cstopb
cat app.exe > /dev/ttyUSB0


# kernel
../../../tools/vasm/vasm6502_oldstyle -Fbin -dotdir bios.s -L symbols.txt
minipro -p "AT28C256" -w a.out 


cp symbols.txt ../../../Downloads/
cp a.out ../../../Downloads/

