.386
.model flat, stdcall
option casemap :none

include combat.inc

.data
    player1 player <<?, ?>, 3, 100>
    player2 player <<?, ?>, 7, 100>

    score pair <0, 0>

.data?

.code 
start:

invoke GetModuleHandle, NULL
mov hInstance, eax

invoke WinMain, hInstance, NULL, NULL, SW_SHOWDEFAULT
invoke ExitProcess, eax

WinMain proc hInst:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD
	LOCAL wc:WNDCLASSEX                                            
    LOCAL msg:MSG 
    LOCAL hwnd:HWND

    LOCAL Wwd  :DWORD
    LOCAL Wht  :DWORD

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

    mov Wwd, 1500
    mov Wht, 1000

    invoke CreateWindowEx, NULL,\ 
                ADDR ClassName,\ 
                ADDR AppName,\ 
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
	.WHILE TRUE  
        invoke GetMessage, ADDR msg, NULL, 0, 0 
        .BREAK .IF (!eax) 

        invoke TranslateMessage, ADDR msg 
        invoke DispatchMessage, ADDR msg 
	.ENDW 

    mov eax, msg.wParam ;Return exit code in eax 
    ret 
WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
    .IF uMsg == WM_DESTROY ;If the user closes our window 
        invoke PostQuitMessage, NULL ;Quit our application 
    .ELSE 
        invoke DefWindowProc, hWnd, uMsg, wParam, lParam ;Default message processing 
        ret 
    .ENDIF 

    xor eax, eax 
    ret 
WndProc endp

end start

