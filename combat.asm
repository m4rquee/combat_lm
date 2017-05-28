.386
.model flat, stdcall
option casemap :none

include combat.inc

.data
    ;Estruturas dos jogadores:
    player1 player <MAX_LIFE, 7, <IMG_SIZE, WIN_HT / 2, <0, 0>>>
    player2 player <MAX_LIFE, 3, <WIN_WD - IMG_SIZE, WIN_HT / 2, <0, 0>>>

    canPlyrsMov pair <0, 0> ;Indica se cada jogador pode se mover
    isShooting pair <0, 0> ;Indica se cada jogador está atirando
    score pair <0, 0> ;Score de cada jogador

    ;Lista de tiros de cada jogador:
    shots1 gameObj TRACKED_SHOTS dup (<?, ?, <0, 0>>)  
    shots2 gameObj TRACKED_SHOTS dup (<?, ?, <0, 0>>)

.code 
start:

invoke GetModuleHandle, NULL
mov hInstance, eax

invoke WinMain, hInstance, SW_SHOWDEFAULT
invoke ExitProcess, eax

loadBitmaps proc ;Carrega os bitmaps do jogo:
    invoke LoadBitmap, hInstance, 100
    mov h100, eax

    invoke LoadBitmap, hInstance, 101
    mov h101, eax

    invoke LoadBitmap, hInstance, 102
    mov h102, eax

    invoke LoadBitmap, hInstance, 103
    mov h103, eax

    invoke LoadBitmap, hInstance, 104
    mov h104, eax

    invoke LoadBitmap, hInstance, 105
    mov h105, eax

    invoke LoadBitmap, hInstance, 106
    mov h106, eax

    invoke LoadBitmap, hInstance, 107
    mov h107, eax

    ret
loadBitmaps endp

WinMain proc hInst:HINSTANCE, CmdShow:dword
	local wc:WNDCLASSEX                                            
    local msg:MSG 

    local Wwd:dword
    local Wht:dword

	;Fill values in members of wc
    mov wc.cbSize, SIZEOF WNDCLASSEX  
    mov wc.style, CS_BYTEALIGNWINDOW or CS_BYTEALIGNCLIENT
    mov wc.lpfnWndProc, OFFSET WndProc 
    mov wc.cbClsExtra, NULL 
    mov wc.cbWndExtra, NULL 

    push hInstance 
    pop wc.hInstance 

    mov wc.hbrBackground, COLOR_WINDOW + 1 
    mov wc.lpszMenuName, NULL 
    mov wc.lpszClassName, OFFSET ClassName 

    invoke LoadIcon, hInstance, 500 
    mov wc.hIcon, eax 
    mov wc.hIconSm, eax

    invoke LoadCursor, NULL, IDC_ARROW 
    mov wc.hCursor, eax 

    invoke RegisterClassEx, addr wc ;Register our window class 

    mov Wwd, WIN_WD + 16
    mov Wht, WIN_HT + 39
    invoke CreateWindowEx, NULL, addr ClassName, addr AppName,\ 
        WS_OVERLAPPED or WS_SYSMENU or WS_MINIMIZEBOX,\ 
        CW_USEDEFAULT, CW_USEDEFAULT,\
        Wwd, Wht,\ 
        NULL, NULL, hInst, NULL 

    mov hWnd, eax 
    invoke ShowWindow, hWnd, CmdShow ;Display our window on desktop 
    invoke UpdateWindow, hWnd ;Refresh the client area

    ;Enter message loop
	.while TRUE  
        invoke GetMessage, addr msg, NULL, 0, 0 
        .break .if (!eax) 

        invoke TranslateMessage, addr msg 
        invoke DispatchMessage, addr msg
	.endw 

    mov eax, msg.wParam ;Return exit code in eax 

    ret 
WinMain endp

WndProc proc _hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM ;wParam -  
                                                            ;Parametro recebido
                                                            ;do Windows
    .if uMsg == WM_CREATE ;Carrega as imagens e cria a thread principal:---------
;________________________________________________________________________________

        invoke loadBitmaps

        mov eax, offset gameHandler 
        invoke CreateThread, NULL, NULL, eax, 0, 0, addr threadID 

        invoke CloseHandle, eax 
;________________________________________________________________________________

    .elseif uMsg == WM_DESTROY ;If the user closes the window  
        invoke PostQuitMessage, NULL ;Quit the application 
    .elseif uMsg == WM_CHAR ;Keydown printable:----------------------------------
;________________________________________________________________________________

        ;Teclas de movimento player1:
        .if (wParam == 77h) ;w
            mov player1.playerObj.speed.y, -SPEED 
        .elseif (wParam == 61h) ;a
            mov player1.playerObj.speed.x, -SPEED
        .elseif (wParam == 73h) ;s
            mov player1.playerObj.speed.y, SPEED
        .elseif (wParam == 64h) ;d
            mov player1.playerObj.speed.x, SPEED
;________________________________________________________________________________

        .elseif (wParam == 79h) ;y - Tiro player1:
            mov isShooting.x, TRUE
        .elseif (wParam == 75h) ;u - Especial player1:
;________________________________________________________________________________

        .elseif (wParam == 32h) ;2 - Tiro player2:
            mov isShooting.y, TRUE
        .elseif (wParam == 33h) ;3 - Especial player2:
        .endif

    .elseif uMsg == WM_DEADCHAR ;Keyup printable:--------------------------------
;________________________________________________________________________________

        ;Teclas de movimento player1:
        .if (wParam == 77h) ;w
            .if (player1.playerObj.speed.y > 7fh) ;Caso seja negativo:
                mov player1.playerObj.speed.y, 0 
            .endif
        .elseif (wParam == 61h) ;a
            .if (player1.playerObj.speed.x > 7fh) ;Caso seja negativo:
                mov player1.playerObj.speed.x, 0 
            .endif
        .elseif (wParam == 73h) ;s
            .if (player1.playerObj.speed.y < 80h) ;Caso seja positivo:
                mov player1.playerObj.speed.y, 0 
            .endif
        .elseif (wParam == 64h) ;d
            .if (player1.playerObj.speed.x < 80h) ;Caso seja positivo:
                mov player1.playerObj.speed.x, 0 
            .endif
;________________________________________________________________________________

        .elseif (wParam == 79h) ;y - Tiro player1:
            mov isShooting.x, FALSE
        .elseif (wParam == 75h) ;u - Especial player1:
;________________________________________________________________________________

        .elseif (wParam == 32h) ;2 - Tiro player2:
            mov isShooting.y, FALSE
        .elseif (wParam == 33h) ;3 - Especial player2:
        .endif

    .elseif uMsg == WM_KEYDOWN ;Keydown nonprintable:----------------------------
;________________________________________________________________________________

        ;Teclas de movimento player2:
        .if (wParam == VK_UP) ;seta cima
            mov player2.playerObj.speed.y, -SPEED
        .elseif (wParam == VK_DOWN) ;seta baixo
            mov player2.playerObj.speed.y, SPEED
        .elseif (wParam == VK_LEFT) ;seta esquerda
            mov player2.playerObj.speed.x, -SPEED
        .elseif (wParam == VK_RIGHT) ;seta direita
            mov player2.playerObj.speed.x, SPEED
        .endif

    .elseif uMsg == WM_KEYUP ;Keyup nonprintable:--------------------------------
;________________________________________________________________________________

        ;Teclas de movimento player2:
        .if (wParam == VK_UP) ;seta cima
            .if (player2.playerObj.speed.y > 7fh) ;Caso seja negativo:
                mov player2.playerObj.speed.y, 0 
            .endif
        .elseif (wParam == VK_DOWN) ;seta baixo
            .if (player2.playerObj.speed.y < 80h) ;Caso seja positivo:
                mov player2.playerObj.speed.y, 0 
            .endif
        .elseif (wParam == VK_LEFT) ;seta esquerda
            .if (player2.playerObj.speed.x > 7fh) ;Caso seja negativo:
                mov player2.playerObj.speed.x, 0 
            .endif
        .elseif (wParam == VK_RIGHT) ;seta direita
            .if (player2.playerObj.speed.x < 80h) ;Caso seja positivo:
                mov player2.playerObj.speed.x, 0 
            .endif
        .endif
;________________________________________________________________________________

	.elseif uMsg == WM_PAINT ;Atualizar da página:-------------------------------  
         invoke updateScreen
    .else ;Default:
        invoke DefWindowProc, _hWnd, uMsg, wParam, lParam ;Default processing 
        ret 
    .endif 

    xor eax, eax 

    ret 
WndProc endp

mult proc n1:word, n2:word ;Multiplica dois números (16 b) e coloca em eax:
    xor eax, eax 
	xor edx, edx

    mov ax, n1
    mov bx, n2

    imul bx
	shl edx, 16

    add eax, edx

    ret
mult endp

movObj proc addrObj:dword ;Atualiza a posição de um gameObj de acordo com sua
                        ;velocidade:
	assume ecx:ptr gameObj
    mov ecx, addrObj

    ;Eixo x:---------------------------------------------------------------------
;________________________________________________________________________________

    mov ax, [ecx].x
    movzx bx, [ecx].speed.x

    .if bx > 7fh ;Caso seja negativo:
        or bx, 65280
    .endif

    add ax, bx
    mov [ecx].x, ax

    ;Eixo y:---------------------------------------------------------------------
;________________________________________________________________________________

    mov ax, [ecx].y
    movzx bx, [ecx].speed.y

    .if bx > 7fh ;Caso seja negativo:
        or bx, 65280
    .endif

    add ax, bx
    mov [ecx].y, ax
;________________________________________________________________________________
    
    assume ecx:nothing

	ret
movObj endp

canMov proc p1:gameObj, p2:gameObj ;Atualiza se cada jogador pode se mover:
    local d2:dword ;Quadrado da distância entre os jogadores
                   ;d^2 = (x2 - x1)^2 + (y2 - y1)^2

    ;Move a cópia dos jogadores para uma posição futura:-------------------------
;________________________________________________________________________________

    invoke movObj, addr p1 
    invoke movObj, addr p2   

    ;Calcula d2:-----------------------------------------------------------------
;________________________________________________________________________________

    ;Calcula (x2 - x1)^2 e coloca em d2:
    mov ax, p2.x 
    sub ax, p1.x
    invoke mult, ax, ax
    mov d2, eax

    ;Calcula (y2 - y1)^2 e soma em d2:
    mov ax, p2.y 
    sub ax, p1.y
    invoke mult, ax, ax
    add d2, eax

    ;Checa se os jogadores vão colidir:------------------------------------------
;________________________________________________________________________________	

    .if d2 < IMG_SIZE2
        mov canPlyrsMov.x, FALSE
        mov canPlyrsMov.y, FALSE
        ret
    .endif
    
    ;Checa se cada jogador vai sair da tela:-------------------------------------
;________________________________________________________________________________

    ;Player1:
    mov canPlyrsMov.x, FALSE
    .if p1.x <= OFFSETX 
        .if p1.x >= HALF_SIZE
            .if p1.y <= OFFSETY
                .if p1.y >= HALF_SIZE
                    mov canPlyrsMov.x, TRUE    
                .endif
            .endif
        .endif
    .endif

    ;Player2:
    mov canPlyrsMov.y, FALSE
    .if p2.x <= OFFSETX 
        .if p2.x >= HALF_SIZE
            .if p2.y <= OFFSETY
                .if p2.y >= HALF_SIZE
                    mov canPlyrsMov.y, TRUE    
                .endif
            .endif
        .endif
    .endif

    ret
canMov endp

printPlyr proc plyr:player, _hdc:HDC, _hMemDC:HDC ;Desenha na tela um jogador:
    ;Seleciona qual imagem vai ser desenhada:
;________________________________________________________________________________

    .if plyr.direc == 0
        invoke SelectObject, _hMemDC, h100
    .elseif plyr.direc == 1
        invoke SelectObject, _hMemDC, h101
    .elseif plyr.direc == 2
        invoke SelectObject, _hMemDC, h102
    .elseif plyr.direc == 3
        invoke SelectObject, _hMemDC, h103
    .elseif plyr.direc == 4
        invoke SelectObject, _hMemDC, h104
    .elseif plyr.direc == 5
        invoke SelectObject, _hMemDC, h105
    .elseif plyr.direc == 6
        invoke SelectObject, _hMemDC, h106
    .else
        invoke SelectObject, _hMemDC, h107
    .endif

    ;Calcula as coordenadas do ponto superior esquerdo:
;________________________________________________________________________________

    movzx eax, plyr.playerObj.x
    movzx ebx, plyr.playerObj.y
    sub eax, HALF_SIZE
    sub ebx, HALF_SIZE
;________________________________________________________________________________

    invoke BitBlt, _hdc, eax, ebx,\
        IMG_SIZE, IMG_SIZE, _hMemDC,\ 
        0, 0, SRCCOPY

    ret
printPlyr endp

updateScreen proc ;Desenha na tela todos os objetos:
    locaL ps:PAINTSTRUCT
    locaL hMemDC:HDC 
    locaL hdc:HDC 

    invoke BeginPaint, hWnd, addr ps 
    mov hdc, eax 

    invoke CreateCompatibleDC, hdc 
    mov hMemDC, eax 
    
    ;Desenha os jogadores:-------------------------------------------------------
;________________________________________________________________________________

    invoke printPlyr, player1, hdc, hMemDC 
    invoke printPlyr, player2, hdc, hMemDC

    invoke DeleteDC, hMemDC 
    invoke EndPaint, hWnd, addr ps 
    
    ret
updateScreen endp

gameHandler proc p:dword
    .while TRUE
        invoke canMov, player1.playerObj, player2.playerObj

        .if canPlyrsMov.x 
            invoke movObj, addr player1.playerObj
        .endif

        .if canPlyrsMov.y
            invoke movObj, addr player2.playerObj
        .endif

        .if canPlyrsMov.x || canPlyrsMov.y
            invoke InvalidateRect, hWnd, NULL, TRUE
        .endif 
    .endw

    ret
gameHandler endp
    
end start

