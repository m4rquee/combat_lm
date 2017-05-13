include C:\masm32\include\windows.inc
include C:\masm32\include\masm32.inc
include C:\masm32\include\gdi32.inc
include C:\masm32\include\user32.inc
include C:\masm32\include\kernel32.inc
include C:\masm32\include\Comctl32.inc
include C:\masm32\include\comdlg32.inc
include C:\masm32\include\shell32.inc

includelib C:\masm32\lib\masm32.lib
includelib C:\masm32\lib\gdi32.lib
includelib C:\masm32\lib\user32.lib
includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\Comctl32.lib
includelib C:\masm32\lib\comdlg32.lib
includelib C:\masm32\lib\shell32.lib

;=================
; Local structs
;=================
pair struct
    x  DB ?
    y  DB ?
pair ends

player struct 
    pos pair <>
    direc DB ?
    life DB ?
player ends

;=================
; Local data
;=================
.data                     		
ClassName db "CombatClass", 0 
AppName db "Combat", 0 

.data?                
hInstance HINSTANCE ?  

;=================
; Local prototypes
;=================

WinMain proto :DWORD, :DWORD, :DWORD, :DWORD    