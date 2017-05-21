.386
.model flat, stdcall
option casemap :none

include combat.inc

.data
    ;Estruturas dos jogadores:
    player1 player <MAX_LIFE, <?, WIN_HT / 2, <0, 0>>>
    player2 player <MAX_LIFE, <?, WIN_HT / 2, <0, 0>>>

    isShooting pair <0, 0> ;Indica se cada jogador está atirando
    score pair <0, 0> ;Score de cada jogador

    ;Lista de tiros de cada jogador:
    shots1 gameObj TRACKED_SHOTS dup (<?, ?, <0, 0>>)  
    shots2 gameObj TRACKED_SHOTS dup (<?, ?, <0, 0>>)

.code 
start:

invoke GetModuleHandle, NULL
mov hInstance, eax

invoke WinMain, hInstance, NULL, NULL, SW_SHOWDEFAULT
invoke ExitProcess, eax

WinMain proc hInst:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD
	local wc:WNDCLASSEX                                            
    local msg:MSG 
    local hwnd:HWND

    local Wwd  :DWORD
    local Wht  :DWORD

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

    invoke CreateWindowEx, NULL,\ 
                addr ClassName,\ 
                addr AppName,\ 
                WS_OVERLAPPED or WS_SYSMENU or WS_MINIMIZEBOX,\ 
                CW_USEDEFAULT, CW_USEDEFAULT,\
                Wwd, Wht,\ 
                NULL,\ 
                NULL,\ 
                hInst,\ 
                NULL 

    mov hwnd, eax 
    invoke ShowWindow, hwnd, CmdShow ;Display our window on desktop 
    invoke UpdateWindow, hwnd ;Refresh the client area

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
            .if (player1.playerObj.speed.y < 0)
                mov player1.playerObj.speed.y, 0 
            .endif
        .elseif (wParam == 61h) ;a
            .if (player1.playerObj.speed.x < 0)
                mov player1.playerObj.speed.x, 0 
            .endif
        .elseif (wParam == 73h) ;s
            .if (player1.playerObj.speed.y > 0)
                mov player1.playerObj.speed.y, 0 
            .endif
        .elseif (wParam == 64h) ;d
            .if (player1.playerObj.speed.x > 0)
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
            mov player1.playerObj.speed.y, -SPEED
        .elseif (wParam == VK_DOWN) ;seta baixo
            mov player1.playerObj.speed.y, SPEED
        .elseif (wParam == VK_LEFT) ;seta esquerda
            mov player1.playerObj.speed.x, -SPEED
        .elseif (wParam == VK_RIGHT) ;seta direita
            mov player1.playerObj.speed.x, SPEED
        .endif

    .elseif uMsg == WM_KEYUP ;Keyup nonprintable:
        ;Teclas de movimento player2:
        .if (wParam == VK_UP) ;seta cima
            .if (player2.playerObj.speed.y < 0)
                mov player2.playerObj.speed.y, 0 
            .endif
        .elseif (wParam == VK_DOWN) ;seta baixo
            .if (player2.playerObj.speed.y > 0)
                mov player2.playerObj.speed.y, 0 
            .endif
        .elseif (wParam == VK_LEFT) ;seta esquerda
            .if (player2.playerObj.speed.x < 0)
                mov player2.playerObj.speed.x, 0 
            .endif
        .elseif (wParam == VK_RIGHT) ;seta direita
            .if (player2.playerObj.speed.x > 0)
                mov player2.playerObj.speed.x, 0 
            .endif
        .endif

    .elseif uMsg == WM_PAINT ;Atualizar da página:  
    .else ;Default:
        invoke DefWindowProc, hWnd, uMsg, wParam, lParam ;Default processing 
        ret 
    .endif 

    xor eax, eax 
    ret 
WndProc endp

movAll proc ;Atualiza as posições dos tiros e jogadores
    ;Movimenta jogadores no eixo x:
    ;Player1:
    mov ax, player1.playerObj.x

    .if player1.playerObj.speed.x < 0
        ;Remove complemento de dois:
        mov bl, player1.playerObj.speed.x
        xor bl, 1
        not bl

        shr ebx, 16

        sub ax, bx
    .else
        movzx bx, player1.playerObj.speed.x
        add ax, bx
    .endif

    mov player1.playerObj.x, ax

    ;Player2:
    mov ax, player2.playerObj.x

    .if player2.playerObj.speed.x < 0
        ;Remove complemento de dois:
        mov bl, player2.playerObj.speed.x
        xor bl, 1
        not bl

        shr ebx, 16

        sub ax, bx
    .else
        movzx bx, player2.playerObj.speed.x
        add ax, bx
    .endif

    mov player2.playerObj.x, ax

    ;Movimenta jogadores no eixo y:
    ;Player1:
    mov ax, player1.playerObj.y

    .if player1.playerObj.speed.y < 0
        ;Remove complemento de dois:
        mov bl, player1.playerObj.speed.y
        xor bl, 1
        not bl

        shr ebx, 16

        sub ax, bx
    .else
        movzx bx, player1.playerObj.speed.y
        add ax, bx
    .endif

    mov player1.playerObj.y, ax

    ;Player2:
    mov ax, player2.playerObj.y

    .if player2.playerObj.speed.y < 0
        ;Remove complemento de dois:
        mov bl, player2.playerObj.speed.y
        xor bl, 1
        not bl

        shr ebx, 16

        sub ax, bx
    .else
        movzx bx, player2.playerObj.speed.y
        add ax, bx
    .endif

    mov player2.playerObj.y, ax

    ;Movimenta os tiros:

movAll endp

end start

