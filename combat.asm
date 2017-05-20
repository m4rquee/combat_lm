.386
.model flat, stdcall
option casemap :none

include combat.inc

.data
    player1 player <MAX_LIFE, <?, WIN_HT / 2, 7>>
    player2 player <MAX_LIFE, <?, WIN_HT / 2, 3>>

    plyrsMoving pair <0, 0> ;Indica se cada jogador está se movendo
    score pair <0, 0>

    ;Lista de tiros de cada jogador:
    shots1 oriObj TRACKED_SHOTS dup (<?, ?, -1>)  
    shots2 oriObj TRACKED_SHOTS dup (<?, ?, -1>)

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

        .elseif (wParam == 61h) ;a

        .elseif (wParam == 73h) ;s

        .elseif (wParam == 64h) ;d

        .elseif (wParam == 79h) ;y - Tiro player1:

        .elseif (wParam == 75h) ;u - Especial player1:

        .elseif (wParam == 32h) ;2 - Tiro player2:

        .elseif (wParam == 33h) ;3 - Especial player2:
        .endif

    .elseif uMsg == WM_DEADCHAR ;Keyup printable:

    .elseif uMsg == WM_KEYDOWN ;Keydown nonprintable:
        ;Teclas de movimento player2:
        .if (wParam == VK_UP) ;seta cima

        .elseif (wParam == VK_DOWN) ;seta baixo

        .elseif (wParam == VK_LEFT) ;seta esquerda

        .elseif (wParam == VK_RIGHT) ;seta direita

        .endif

    .elseif uMsg == WM_KEYUP ;Keyup nonprintable:

    .elseif uMsg == WM_PAINT ;Atualizar da página:  
    .else ;Default:
        invoke DefWindowProc, hWnd, uMsg, wParam, lParam ;Default message processing 
        ret 
    .endif 

    xor eax, eax 
    ret 
WndProc endp

movAll proc ;Atualiza as posições dos tiros e jogadores
    ;Movimenta jogadores:
    .if (plyrsMoving[0])
        mov al, player1.playerObj.direc

        .if (al >= 0 && al <= 2) ;Movimento para cima direc = 0, 1 ou 2
            sub player1.playerObj.y, SPEED
        .elseif (al >= 4 && al <= 6) ;Movimento para baixo direc = 4, 5 ou 6
            add player1.playerObj.y, SPEED
        .endif

        .if (al >= 2 && al <= 4) ;Movimento para direita direc = 2, 3 ou 4
            add player1.playerObj.x, SPEED
        .elseif (al >= 6 || al == 0) ;Movimento para esquerda direc = 6, 7 ou 0
            sub player1.playerObj.x, SPEED
        .endif
    .endif

    .if (plyrsMoving[1])
        mov al, player2.playerObj.direc

        .if (al >= 0 && al <= 2) ;Movimento para cima direc = 0, 1 ou 2
            sub player2.playerObj.y, SPEED
        .elseif (al >= 4 && al <= 6) ;Movimento para baixo direc = 4, 5 ou 6
            add player2.playerObj.y, SPEED
        .endif

        .if (al >= 2 && al <= 4) ;Movimento para direita direc = 2, 3 ou 4
            add player2.playerObj.x, SPEED
        .elseif (al >= 6 || al == 0) ;Movimento para esquerda direc = 6, 7 ou 0
            sub player2.playerObj.x, SPEED
        .endif
    .endif

    ;Movimenta os tiros:

movAll endp

end start

