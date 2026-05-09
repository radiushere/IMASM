INCLUDE Irvine32.inc

; =========================================================================
; 1. WIN32 API CONSTANTS & STRUCTURES
; =========================================================================
WM_DESTROY          EQU 2
WM_CLOSE            EQU 10h
WM_COMMAND          EQU 0111h   
COLOR_WINDOW        EQU 5
CS_HREDRAW          EQU 2
CS_VREDRAW          EQU 1
CW_USEDEFAULT       EQU 80000000h
WS_OVERLAPPEDWINDOW EQU 00CF0000h
SW_SHOW             EQU 5
IDI_APPLICATION     EQU 32512
IDC_ARROW           EQU 32512

MF_STRING           EQU 00000000h
MF_POPUP            EQU 00000010h
IDM_FILE_OPEN       EQU 1001    
IDM_FILE_SAVE       EQU 1002    
IDM_FILE_EXIT       EQU 1003    
IDM_FILTER_NEG      EQU 2001    ; NEW: Filter ID

OFN_FILEMUSTEXIST   EQU 00001000h
OFN_PATHMUSTEXIST   EQU 00000800h
GENERIC_READ        EQU 80000000h
OPEN_EXISTING       EQU 3
FILE_ATTRIBUTE_NORMAL EQU 80h
INVALID_HANDLE_VALUE  EQU -1

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

GUI_MSG STRUCT
  hwnd      DWORD ?
  message   DWORD ?
  wParam    DWORD ?
  lParam    DWORD ?
  time      DWORD ?
  pt_x      DWORD ?
  pt_y      DWORD ?
GUI_MSG ENDS

GUI_OPENFILENAME STRUCT
  lStructSize       DWORD ?
  hwndOwner         DWORD ?
  hInstance         DWORD ?
  lpstrFilter       DWORD ?
  lpstrCustomFilter DWORD ?
  nMaxCustFilter    DWORD ?
  nFilterIndex      DWORD ?
  lpstrFile         DWORD ?
  nMaxFile          DWORD ?
  lpstrFileTitle    DWORD ?
  nMaxFileTitle     DWORD ?
  lpstrInitialDir   DWORD ?
  lpstrTitle        DWORD ?
  Flags             DWORD ?
  nFileOffset       WORD ?
  nFileExtension    WORD ?
  lpstrDefExt       DWORD ?
  lCustData         DWORD ?
  lpfnHook          DWORD ?
  lpTemplateName    DWORD ?
GUI_OPENFILENAME ENDS

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
CreateMenu       PROTO
CreatePopupMenu  PROTO
AppendMenuA      PROTO :DWORD, :DWORD, :DWORD, :DWORD
SetMenu          PROTO :DWORD, :DWORD
GetOpenFileNameA PROTO :DWORD

; --- FIX: Added GetFileSize prototype! ---
GetFileSize      PROTO :DWORD, :DWORD

; Graphics API (GDI32) for painting the image
SetDIBitsToDevice PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
GetDC            PROTO :DWORD
ReleaseDC        PROTO :DWORD, :DWORD

AppWinMain PROTO instHandle:DWORD, prevInst:DWORD, cmdLineStr:DWORD, showCmd:DWORD
AppWndProc PROTO winHandle:DWORD, msgID:DWORD, wPrm:DWORD, lPrm:DWORD
RenderImage PROTO winHandle:DWORD

; =========================================================================
; 3. DATA SECTION
; =========================================================================
.data
className   BYTE "IMASM_Class",0
windowTitle BYTE "IMASM - Professional Image Editor",0
guiMsg      GUI_MSG <>       
wc          GUI_WNDCLASS <>
globalInst  DWORD ?          

; Menus
fileMenuStr BYTE "File",0
filtMenuStr BYTE "Filters",0
openStr     BYTE "Open Image...",0
saveStr     BYTE "Save Image...",0
exitStr     BYTE "Exit",0
negStr      BYTE "Apply Negative / Invert",0

ofn         GUI_OPENFILENAME <>
szFileName  BYTE 260 DUP(0)      
szFilter    BYTE "Bitmap Files (*.bmp)",0,"*.bmp",0,"All Files (*.*)",0,"*.*",0,0

; MEGA ENGINE VARIABLES 
hFile       DWORD ?                 
bytesRead   DWORD ?                 
fileSize    DWORD ?                 
hHeap       DWORD ?                 
pHeap       DWORD 0                 
pHeader     DWORD ?                 
pPixels     DWORD ?                 
imgWidth    DWORD ?                 
imgHeight   DWORD ?                 
pixelOffset DWORD ?

; =========================================================================
; 4. CODE SECTION
; =========================================================================
.code
main PROC
    INVOKE GetModuleHandleA, 0
    mov globalInst, eax
    INVOKE AppWinMain, globalInst, 0, 0, SW_SHOW
    INVOKE ExitProcess, eax
main ENDP

AppWinMain PROC instHandle:DWORD, prevInst:DWORD, cmdLineStr:DWORD, showCmd:DWORD
    LOCAL mainHwnd:DWORD     
    LOCAL hMenu:DWORD
    LOCAL hFileMenu:DWORD
    LOCAL hFiltMenu:DWORD

    mov eax, prevInst
    mov eax, cmdLineStr

    mov wc.style, CS_HREDRAW or CS_VREDRAW
    mov wc.lpfnWndProc, OFFSET AppWndProc  
    mov wc.cbClsExtra, 0
    mov wc.cbWndExtra, 0
    mov eax, instHandle
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
        0, ADDR className, ADDR windowTitle, WS_OVERLAPPEDWINDOW,        
        CW_USEDEFAULT, CW_USEDEFAULT, 1024, 768, 0, 0, instHandle, 0
    mov mainHwnd, eax

    ; BUILD THE MENUS 
    INVOKE CreateMenu                       
    mov hMenu, eax
    INVOKE CreatePopupMenu                  
    mov hFileMenu, eax
    INVOKE CreatePopupMenu
    mov hFiltMenu, eax

    INVOKE AppendMenuA, hFileMenu, MF_STRING, IDM_FILE_OPEN, ADDR openStr
    INVOKE AppendMenuA, hFileMenu, MF_STRING, IDM_FILE_SAVE, ADDR saveStr
    INVOKE AppendMenuA, hFileMenu, MF_STRING, IDM_FILE_EXIT, ADDR exitStr
    INVOKE AppendMenuA, hFiltMenu, MF_STRING, IDM_FILTER_NEG, ADDR negStr
    
    INVOKE AppendMenuA, hMenu, MF_POPUP, hFileMenu, ADDR fileMenuStr
    INVOKE AppendMenuA, hMenu, MF_POPUP, hFiltMenu, ADDR filtMenuStr
    INVOKE SetMenu, mainHwnd, hMenu

    INVOKE ShowWindow, mainHwnd, showCmd
    INVOKE UpdateWindow, mainHwnd

MessageLoop:
    INVOKE GetMessageA, ADDR guiMsg, 0, 0, 0
    test eax, eax
    je ExitLoop                     
    INVOKE TranslateMessage, ADDR guiMsg
    INVOKE DispatchMessageA, ADDR guiMsg
    jmp MessageLoop                 

ExitLoop:
    mov eax, guiMsg.wParam
    ret
AppWinMain ENDP

AppWndProc PROC winHandle:DWORD, msgID:DWORD, wPrm:DWORD, lPrm:DWORD
    
    .IF msgID == WM_COMMAND
        mov eax, wPrm             
        and eax, 0FFFFh     
        
        .IF eax == IDM_FILE_OPEN
            mov szFileName[0], 0
            mov ofn.lStructSize, 76     
            mov eax, winHandle
            mov ofn.hwndOwner, eax
            mov ofn.lpstrFilter, OFFSET szFilter
            mov ofn.lpstrFile, OFFSET szFileName
            mov ofn.nMaxFile, 260
            mov ofn.Flags, OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST
            
            INVOKE GetOpenFileNameA, ADDR ofn
            .IF eax != 0
                ; 1. OPEN FILE
                INVOKE CreateFileA, ADDR szFileName, GENERIC_READ, 0, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
                mov hFile, eax
                
                .IF eax != INVALID_HANDLE_VALUE
                    ; 2. GET EXACT FILE SIZE
                    INVOKE GetFileSize, hFile, 0
                    mov fileSize, eax

                    ; 3. ALLOCATE HEAP MEMORY FOR THE WHOLE FILE
                    INVOKE GetProcessHeap
                    mov hHeap, eax
                    INVOKE HeapAlloc, hHeap, 8, fileSize
                    mov pHeap, eax

                    ; 4. READ EVERYTHING INTO RAM
                    INVOKE ReadFile, hFile, pHeap, fileSize, ADDR bytesRead, 0
                    INVOKE CloseHandle, hFile

                    ; 5. SETUP POINTERS (The Magic Math)
                    mov esi, pHeap
                    mov eax, DWORD PTR [esi + 18]
                    mov imgWidth, eax
                    mov eax, DWORD PTR [esi + 22]
                    mov imgHeight, eax
                    
                    mov eax, DWORD PTR [esi + 10]
                    mov pixelOffset, eax
                    
                    ; Set pPixels exactly to where the colors start
                    mov eax, pHeap
                    add eax, pixelOffset
                    mov pPixels, eax
                    
                    ; Set pHeader to the start of the BitmapInfoHeader
                    mov eax, pHeap
                    add eax, 14
                    mov pHeader, eax

                    ; 6. DRAW IT!
                    INVOKE RenderImage, winHandle
                .ENDIF
            .ENDIF
            
        ; =====================================================================
        ; THE NEGATIVE FILTER (Raw Assembly Power)
        ; =====================================================================
        .ELSEIF eax == IDM_FILTER_NEG
            .IF pHeap != 0
                
                ; Calculate exactly how many color bytes we have
                mov ecx, fileSize
                sub ecx, pixelOffset
                
                ; Set source pointer to the start of the colors
                mov esi, pPixels
                
                ; THE LOOP
            InvertLoop:
                mov al, BYTE PTR [esi]   ; Grab 1 byte of color (R, G, or B)
                not al                   ; Flip its bits! (0 to 1, 1 to 0)
                mov BYTE PTR [esi], al   ; Put it back in memory
                inc esi                  ; Move to the next byte
                loop InvertLoop          ; Repeat until ECX hits 0
                
                ; Redraw the new mutated memory to the screen!
                INVOKE RenderImage, winHandle
            .ENDIF
        ; =====================================================================

        .ELSEIF eax == IDM_FILE_EXIT
            INVOKE DestroyWindow, winHandle
        .ENDIF

    .ELSEIF msgID == WM_DESTROY
        INVOKE PostQuitMessage, 0
    .ELSEIF msgID == WM_CLOSE
        INVOKE DestroyWindow, winHandle
    .ELSE
        INVOKE DefWindowProcA, winHandle, msgID, wPrm, lPrm
        ret
    .ENDIF

    xor eax, eax
    ret
AppWndProc ENDP

; --- CUSTOM PROCEDURE: Paints RAM to the GUI ---
RenderImage PROC winHandle:DWORD
    LOCAL hdc:DWORD
    
    INVOKE GetDC, winHandle
    mov hdc, eax
    
    INVOKE SetDIBitsToDevice, 
        hdc, 
        20, 20,             ; X, Y position on window
        imgWidth, imgHeight,; Width/Height
        0, 0, 0, imgHeight, ; Source rectangle
        pPixels,            ; Pointer to raw colors
        pHeader,            ; Pointer to header rules
        0                   ; DIB_RGB_COLORS
        
    INVOKE ReleaseDC, winHandle, hdc
    ret
RenderImage ENDP

END main