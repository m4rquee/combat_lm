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
pair struct ;Par ordenado (<a, b>): 
    x  db ?
    y  db ?
pair ends

gameObj struct ;Objeto primário (<x, y, <Vx, Vy>>):
	x  dw ?
    y  dw ?
    
	speed pair <>
gameObj ends

player struct ;Dados de um jogador (<Life, <x, y, <Vx, Vy>>>):
    life db ?
    playerObj gameObj <>
player ends

;=================
; consts
;=================
.const
	WIN_WD equ 1500 ;Largura da janela
	WIN_HT equ 1000 ;Altura da janela

    OFFSETX equ WIN_WD - HALF_SIZE
    OFFSETY equ WIN_HT - HALF_SIZE

    IMG_SIZE equ 32 ;Altura e largura da img do jogador
    IMG_SIZE2 equ IMG_SIZE * IMG_SIZE ;Quadrado de IMG_SIZE
    HALF_SIZE equ IMG_SIZE / 2 

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

h100 dd 0
h101 dd 0
h102 dd 0
h103 dd 0
h104 dd 0
h105 dd 0
h106 dd 0
h107 dd 0

.data?                
hInstance HINSTANCE ?  

;=================
; prototypes
;=================
WinMain proto :DWORD, :DWORD   
loadBitmaps proto ;Carrega os bitmaps do jogo

printPlyr proto :gameObj, :HDC, :HDC  ;Desenha o jogador indicado (0 ou 1)
updateScreen proto :HWND ;Desenha na tela todos os objetos

canMov proto :gameObj, :gameObj ;Atualiza se cada jogador pode se mover
mult proto :WORD, :WORD ;Multiplica dois números (16 b) e coloca em eax
movObj proto :DWORD ;Atualiza a posição de um gameObj


