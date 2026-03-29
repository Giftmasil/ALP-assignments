#!/bin/bash
# ============================================================================
# build.sh — Assemble, link, and run NASM programs
#
# Usage:
#   ./build.sh filename        → builds 32-bit (matches course slides)
#   ./build.sh filename 64     → builds 64-bit (matches lecturer's code)
#
# Examples:
#   ./build.sh hello            → assembles hello.asm as 32-bit
#   ./build.sh 01_registers 64  → assembles 01_registers.asm as 64-bit
# ============================================================================

if [ -z "$1" ]; then
    echo "Usage: ./build.sh filename [64]"
    echo "  ./build.sh hello        (32-bit)"
    echo "  ./build.sh hello 64     (64-bit)"
    exit 1
fi

if [ "$2" = "64" ]; then
    echo "Building 64-bit: $1.asm"
    nasm -f elf64 $1.asm -o $1.o
    ld -o $1 $1.o
else
    echo "Building 32-bit: $1.asm"
    nasm -f elf $1.asm -o $1.o
    ld -m elf_i386 -s -o $1 $1.o
fi

if [ $? -eq 0 ]; then
    echo "Running $1..."
    echo "---"
    ./$1
else
    echo "Build failed!"
fi