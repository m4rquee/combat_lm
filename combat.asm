.386
title combat
.model flat, stdcall
option casemap :none

include combat.inc

point struct
    x  DB ?
    y  DB ?
point ends

player struct 
    pos point <>
    direc DB ?
    life DB ?
player ends

.data
    player1 player <<?, ?>, 3, 100>
    player2 player <<?, ?>, 7, 100>

    score point <0, 0>

.data?

.code
start:
end start

