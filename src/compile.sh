#!/bin/bash

echo compiling

../../../tools/vasm/vasm6502_oldstyle -Fbin -dotdir bios.s -L symbols.txt

#hexdump a.out

minipro -p "AT28C256" -w a.out 
