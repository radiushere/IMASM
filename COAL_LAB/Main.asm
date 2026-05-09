INCLUDE Irvine32.inc

; =========================================================================
; 1. WIN32 API CONSTANTS & STRUCTURES
; (Prefixed with GUI_ to avoid collisions with Irvine's library)
; =========================================================================
WM_DESTROY          EQU 2
WM_CLOSE            EQU 10h
COLOR_WINDOW        EQU 5
CS_HREDRAW          EQU 2
CS_VREDRAW          EQU 1
CW_USEDEFAULT       EQU 80000000h
WS_OVERLAPPEDWINDOW EQU 00CF0000h
SW_SHOW             EQU 5
IDI_APPLICATION     EQU 32512
IDC_ARROW           EQU 32512

; Renamed to GUI_WNDCLASS
GUI_WNDCLASS STRUCT
  style         DWORD ?
  lpfnWndProc   DWORD ?
  cbClsExtra    DWORD ?
  cbWndExtra    DWORD ?
  hInstance     DWORD ?
  hIcon         DWORD ?
  hCursor       DWORD ?
  hbrBackground DWORD ?
  lpszMenuName  DWORD ?
  lpszClassName DWORD ?
GUI_WNDCLASS ENDS

; Renamed to GUI_MSG
GUI_MSG STRUCT
  hwnd      DWORD ?
  message   DWORD ?
  wParam    DWORD ?
  lParam    DWORD ?
  time      DWORD ?
  pt_x      DWORD ?
  pt_y      DWORD ?
GUI_MSG ENDS

; =========================================================================
; 2. WIN32 API PROTOTYPES
; =========================================================================
GetModuleHandleA PROTO :DWORD
LoadIconA        PROTO :DWORD, :DWORD
LoadCursorA      PROTO :DWORD, :DWORD
RegisterClassA   PROTO :DWORD
CreateWindowExA  PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
ShowWindow       PROTO :DWORD, :DWORD
UpdateWindow     PROTO :DWORD
GetMessageA      PROTO :DWORD, :DWORD, :DWORD, :DWORD
TranslateMessage PROTO :DWORD
DispatchMessageA PROTO :DWORD
PostQuitMessage  PROTO :DWORD
DestroyWindow    PROTO :DWORD
DefWindowProcA   PROTO :DWORD, :DWORD, :DWORD, :DWORD

WinMain PROTO :DWORD, :DWORD, :DWORD, :DWORD
WndProc PROTO :DWORD, :DWORD, :DWORD, :DWORD

; =========================================================================
; 3. DATA SECTION
; =========================================================================
.data
className   BYTE "IMASM_Class",0
windowTitle BYTE "IMASM - Professional Image Editor",0
msg         GUI_MSG <>       ; Using our custom structure
wc          GUI_WNDCLASS <>  ; Using our custom structure
hInstance   DWORD ?

; =========================================================================
; 4. CODE SECTION
; =========================================================================
.code
main PROC
    INVOKE GetModuleHandleA, 0
    mov hInstance, eax
    INVOKE WinMain, hInstance, 0, 0, SW_SHOW
    INVOKE ExitProcess, eax
main ENDP

WinMain PROC hInst:DWORD, hPrevInst:DWORD, CmdLine:DWORD, CmdShow:DWORD
    LOCAL hwnd:DWORD 

    ; --- Fix for the Warnings ---
    ; We move them into EAX to tell MASM "Yes, we referenced them"
    mov eax, hPrevInst
    mov eax, CmdLine
    ; ----------------------------

    mov wc.style, CS_HREDRAW or CS_VREDRAW
    mov wc.lpfnWndProc, OFFSET WndProc  
    mov wc.cbClsExtra, 0
    mov wc.cbWndExtra, 0
    mov eax, hInst
    mov wc.hInstance, eax
    
    INVOKE LoadIconA, 0, IDI_APPLICATION
    mov wc.hIcon, eax
    
    INVOKE LoadCursorA, 0, IDC_ARROW
    mov wc.hCursor, eax
    
    mov wc.hbrBackground, COLOR_WINDOW + 1  
    mov wc.lpszMenuName, 0
    mov wc.lpszClassName, OFFSET className

    INVOKE RegisterClassA, ADDR wc

    INVOKE CreateWindowExA,
        0,
        ADDR className,
        ADDR windowTitle,
        WS_OVERLAPPEDWINDOW,        
        CW_USEDEFAULT, CW_USEDEFAULT, 800, 600, 
        0, 0, hInst, 0
    mov hwnd, eax

    INVOKE ShowWindow, hwnd, CmdShow
    INVOKE UpdateWindow, hwnd

MessageLoop:
    INVOKE GetMessageA, ADDR msg, 0, 0, 0
    test eax, eax
    je ExitLoop                     
    INVOKE TranslateMessage, ADDR msg
    INVOKE DispatchMessageA, ADDR msg
    jmp MessageLoop                 

ExitLoop:
    mov eax, msg.wParam
    ret
WinMain ENDP

WndProc PROC hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
    .IF uMsg == WM_DESTROY
        INVOKE PostQuitMessage, 0
        
    .ELSEIF uMsg == WM_CLOSE
        INVOKE DestroyWindow, hWnd

    .ELSE
        INVOKE DefWindowProcA, hWnd, uMsg, wParam, lParam
        ret
    .ENDIF

    xor eax, eax
    ret
WndProc ENDP

END main