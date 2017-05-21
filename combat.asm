.386
.model flat, stdcall
option casemap :none

include combat.inc

.data
    ;Estruturas dos jogadores:
    player1 player <MAX_LIFE, <?, WIN_HT / 2, <SPEED, 0>>>
    player2 player <MAX_LIFE, <?, WIN_HT / 2, <0, -SPEED>>>

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

;Carrega os bitmaps:
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

invoke WinMain, hInstance, SW_SHOWDEFAULT
invoke ExitProcess, eax

WinMain proc hInst:HINSTANCE, CmdShow:dword
	local wc:WNDCLASSEX                                            
    local msg:MSG 
    local hwnd:HWND

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

    mov Wwd, WIN_WD
    mov Wht, WIN_HT

    invoke CreateWindowEx, NULL, addr ClassName, addr AppName,\ 
                WS_OVERLAPPED or WS_SYSMENU or WS_MINIMIZEBOX,\ 
                CW_USEDEFAULT, CW_USEDEFAULT,\
                Wwd, Wht,\ 
                NULL, NULL, hInst, NULL 

    mov hwnd, eax 
    invoke ShowWindow, hwnd, CmdShow ;Display our window on desktop 
    invoke UpdateWindow, hwnd ;Refresh the client area

    ;Enter message loop
	.while TRUE  
        invoke GetMessage, addr msg, NULL, 0, 0 
        .break .if (!eax) 

        invoke TranslateMessage, addr msg 
        invoke DispatchMessage, addr msg

        invoke canMov, player1.playerObj, player2.playerObj

        .if canPlyrsMov.x
		  invoke movObj, addr player1.playerObj
        .endif

        .if canPlyrsMov.y
          invoke movObj, addr player2.playerObj
        .endif
	.endw 

    mov eax, msg.wParam ;Return exit code in eax 
    ret 
WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM ;wParam - Parametro recebido 
                                                                ;do Windows
    locaL hdc:HDC 
    locaL ps:PAINTSTRUCT

    ;invoke InvalidateRect, hWnd, NULL, TRUE ;Dispara o evento de paint da tela

    .if uMsg == WM_DESTROY ;If the user closes the window 
        invoke PostQuitMessage, NULL ;Quit the application 
    .elseif uMsg == WM_CHAR ;Keydown printable:
        ;Teclas de movimento player1:
        .if (wParam == 77h) ;w
            mov player1.playerObj.speed.y, -SPEED 
        .elseif (wParam == 61h) ;a
            mov player1.playerObj.speed.x, -SPEED
        .elseif (wParam == 73h) ;s
            mov player1.playerObj.speed.y, SPEED
        .elseif (wParam == 64h) ;d
            mov player1.playerObj.speed.x, SPEED

        .elseif (wParam == 79h) ;y - Tiro player1:
            mov isShooting.x, TRUE
        .elseif (wParam == 75h) ;u - Especial player1:
        .elseif (wParam == 32h) ;2 - Tiro player2:
            mov isShooting.y, TRUE
        .elseif (wParam == 33h) ;3 - Especial player2:
        .endif

    .elseif uMsg == WM_DEADCHAR ;Keyup printable:
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
            .if (player1.playerObj.speed.y < 80h)
                mov player1.playerObj.speed.y, 0 
            .endif
        .elseif (wParam == 64h) ;d
            .if (player1.playerObj.speed.x < 80h)
                mov player1.playerObj.speed.x, 0 
            .endif

        .elseif (wParam == 79h) ;y - Tiro player1:
            mov isShooting.x, FALSE
        .elseif (wParam == 75h) ;u - Especial player1:
        .elseif (wParam == 32h) ;2 - Tiro player2:
            mov isShooting.y, FALSE
        .elseif (wParam == 33h) ;3 - Especial player2:
        .endif

    .elseif uMsg == WM_KEYDOWN ;Keydown nonprintable:
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

    .elseif uMsg == WM_KEYUP ;Keyup nonprintable:
        ;Teclas de movimento player2:
        .if (wParam == VK_UP) ;seta cima
            .if (player2.playerObj.speed.y > 7fh) ;Caso seja negativo:
                mov player2.playerObj.speed.y, 0 
            .endif
        .elseif (wParam == VK_DOWN) ;seta baixo
            .if (player2.playerObj.speed.y < 80h)
                mov player2.playerObj.speed.y, 0 
            .endif
        .elseif (wParam == VK_LEFT) ;seta esquerda
            .if (player2.playerObj.speed.x > 7fh) ;Caso seja negativo:
                mov player2.playerObj.speed.x, 0 
            .endif
        .elseif (wParam == VK_RIGHT) ;seta direita
            .if (player2.playerObj.speed.x < 80h)
                mov player2.playerObj.speed.x, 0 
            .endif
        .endif

    ;.elseif uMsg == WM_PAINT ;Atualizar da página:  
    .else ;Default:
        invoke DefWindowProc, hWnd, uMsg, wParam, lParam ;Default processing 
        ret 
    .endif 

    xor eax, eax 
    ret 
WndProc endp

movObj proc addrObj:dword ;Atualiza a posição de um gameObj:
	assume ecx:ptr gameObj
    mov ecx, addrObj
    
    ;Eixo x:
    mov ax, [ecx].x
    movzx bx, [ecx].speed.x

    .if bx > 7fh ;Caso seja negativo:
        or bx, 65280
    .endif

    add ax, bx
    mov [ecx].x, ax

    ;Eixo y:
    mov ax, [ecx].y
    movzx bx, [ecx].speed.y

    .if bx > 7fh ;Caso seja negativo:
        or bx, 65280
    .endif

    add ax, bx
    mov [ecx].y, ax
    
    assume ecx:nothing
	ret
movObj endp

canMov proc p1:gameObj, p2:gameObj ;Atualiza se cada jogador pode se mover:
    local d2:dword

    invoke movObj, addr p1
    invoke movObj, addr p2   

    mov ax, p2.x 
    sub ax, p1.x
    invoke mult, ax, ax
    mov d2, eax

    mov ax, p2.y 
    sub ax, p1.y
    invoke mult, ax, ax
    add d2, eax

    .if d2 < IMG_SIZE2
        mov canPlyrsMov.x, 0
        mov canPlyrsMov.y, 0
        ret
    .endif
    
    mov canPlyrsMov.x, 0
    .if p1.x > OFFSETX && p1.x < IMG_SIZE\
        && p1.y > OFFSETY && p1.y < IMG_SIZE
        mov canPlyrsMov.x, 1    
    .endif

    mov canPlyrsMov.y, 0
    .if p2.x > OFFSETX && p2.x < IMG_SIZE\
        && p2.y > OFFSETY && p2.y < IMG_SIZE
        mov canPlyrsMov.y, 1    
    .endif

    ret
canMov endp

mult proc n1:word, n2:word
	xor eax, eax 
    mov ax, n1
    mov bx, n2

    imul bx
    add eax, edx

    ret
mult endp

end start

