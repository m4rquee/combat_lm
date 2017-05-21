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
; structs
;=================
pair struct ;Par ordenado:
    x  db ?
    y  db ?
pair ends

gameObj struct ;Objeto primário:
	x  dw ?
    y  dw ?
    
	speed pair <>
gameObj ends

player struct ;Dados de um jogador:
    life db ?
    playerObj gameObj <>
player ends

;=================
; consts
;=================
.const
	WIN_WD equ 1500 ;Largura da janela
	WIN_HT equ 1000 ;Altura da janela

    SPEED equ 1 ;Velocidade dos jogadores
	MAX_SCORE equ 5 ;Score máximo para o termino do jogo
    MAX_LIFE equ 100 ;Vida inicial dos jogadores
    TRACKED_SHOTS equ 15 ;Número máximo de tiros na tela, 
    					 ;antes deles desaparecerem (para cada jogador)

;=================
; data
;=================
.data                     		
ClassName db "CombatClass", 0 
AppName db "Combat", 0 ;Título da janela

.data?                
hInstance HINSTANCE ?  

;=================
; prototypes
;=================

WinMain proto :DWORD, :DWORD, :DWORD, :DWORD    
movAll proto ;Atualiza as posições dos tiros e jogadores
