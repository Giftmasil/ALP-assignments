#!/bin/bash
# ============================================================================
# build_c.sh — Build assembly programs that call C functions (printf, scanf)
#
# Usage:
#   ./build_c.sh filename
#
# Example:
#   ./build_c.sh factorial_recursive
#   ./build_c.sh triangular_loop
#
# IMPORTANT: These programs use 'main' not '_start', and need gcc not ld.
# Regular build.sh won't work for these!
#
# First time setup — run this once:
#   sudo apt-get install gcc
# ============================================================================

if [ -z "$1" ]; then
    echo "Usage: ./build_c.sh filename (without .asm)"
    exit 1
fi

echo "Building (with C library): $1.asm"
nasm -f elf64 $1.asm -o $1.o -i$(dirname $1)/

if [ $? -ne 0 ]; then
    echo "Assembly failed!"
    exit 1
fi

gcc -o $1 $1.o -no-pie

if [ $? -ne 0 ]; then
    echo "Linking failed!"
    echo "If you get errors about gcc, run: sudo apt-get install gcc"
    exit 1
fi

echo "Running $1..."
echo "---"
./$1