INCLUDE Irvine32.inc

; =========================================================================
; 1. CONSTANTS
; =========================================================================
WM_DESTROY          EQU 2
WM_PAINT            EQU 000Fh
WM_CLOSE            EQU 10h
WM_COMMAND          EQU 0111h
WM_CTLCOLORSTATIC   EQU 0138h
TRANSPARENT         EQU 1
CS_HREDRAW          EQU 2
CS_VREDRAW          EQU 1
CW_USEDEFAULT       EQU 80000000h
WS_OVERLAPPEDWINDOW EQU 00CF0000h
WS_CHILD            EQU 40000000h
WS_VISIBLE          EQU 10000000h
WS_BORDER           EQU 00800000h
ES_NUMBER           EQU 2000h
SW_SHOW             EQU 5
IDI_APPLICATION     EQU 32512
IDC_ARROW           EQU 32512

MF_STRING           EQU 00000000h
MF_POPUP            EQU 00000010h
MF_SEPARATOR        EQU 00000800h

IDM_FILE_OPEN       EQU 1001
IDM_FILE_SAVE       EQU 1002
IDM_FILE_EXIT       EQU 1003
IDM_FILTER_NEG      EQU 2001
IDM_FILTER_GRAY     EQU 2002
IDM_FILTER_BRIGHT   EQU 2003
IDM_FILTER_DARK     EQU 2004
IDM_FILTER_SEPIA    EQU 2005
IDM_EDIT_FLIP_H     EQU 3001
IDM_EDIT_FLIP_V     EQU 3002
IDM_EDIT_CROP       EQU 3003
IDM_EXECUTE_CROP    EQU 4001

OFN_FILEMUSTEXIST   EQU 00001000h
OFN_PATHMUSTEXIST   EQU 00000800h
OFN_OVERWRITEPROMPT EQU 00000002h

GENERIC_READ        EQU 80000000h
GENERIC_WRITE       EQU 40000000h
OPEN_EXISTING       EQU 3
CREATE_ALWAYS       EQU 2
FILE_ATTRIBUTE_NORMAL EQU 80h
INVALID_HANDLE_VALUE  EQU -1
SWP_NOMOVE          EQU 2
SWP_NOZORDER        EQU 4

; =========================================================================
; 2. STRUCTURES
; =========================================================================
GUI_RECT STRUCT
  left      DWORD ?
  top       DWORD ?
  right     DWORD ?
  bottom    DWORD ?
GUI_RECT ENDS

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
; 3. PROTOTYPES
; =========================================================================
GetModuleHandleA PROTO :DWORD
CreateSolidBrush PROTO :DWORD
LoadIconA        PROTO :DWORD, :DWORD
LoadCursorA      PROTO :DWORD, :DWORD
RegisterClassA   PROTO :DWORD
CreateWindowExA  PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CreateMenu       PROTO
CreatePopupMenu  PROTO
AppendMenuA      PROTO :DWORD, :DWORD, :DWORD, :DWORD
SetMenu          PROTO :DWORD, :DWORD
ShowWindow       PROTO :DWORD, :DWORD
UpdateWindow     PROTO :DWORD
GetMessageA      PROTO :DWORD, :DWORD, :DWORD, :DWORD
TranslateMessage PROTO :DWORD
DispatchMessageA PROTO :DWORD
AdjustWindowRect PROTO :DWORD, :DWORD, :DWORD
DestroyWindow    PROTO :DWORD
PostQuitMessage  PROTO :DWORD
DefWindowProcA   PROTO :DWORD, :DWORD, :DWORD, :DWORD
GetDC            PROTO :DWORD
SetDIBitsToDevice PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ReleaseDC        PROTO :DWORD, :DWORD
SetWindowTextA   PROTO :DWORD, :DWORD

GetOpenFileNameA  PROTO :DWORD
GetSaveFileNameA  PROTO :DWORD
GetFileSize       PROTO :DWORD, :DWORD
SetWindowPos      PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
InvalidateRect    PROTO :DWORD, :DWORD, :DWORD
GetWindowTextA    PROTO :DWORD, :DWORD, :DWORD

AppWinMain  PROTO :DWORD, :DWORD, :DWORD, :DWORD
AppWndProc  PROTO :DWORD, :DWORD, :DWORD, :DWORD
RenderImage PROTO :DWORD
AsciiToInt  PROTO :DWORD

; =========================================================================
; 4. DATA
; =========================================================================
.data
className    BYTE "IMASM_Class",0
windowTitle  BYTE "IMASM  |  Image Editor  v2.0",0
guiMsg       GUI_MSG <>
wc           GUI_WNDCLASS <>
globalInst   DWORD ?

fileMenuStr  BYTE "  File  ",0
editMenuStr  BYTE "  Edit  ",0
filtMenuStr  BYTE "  Filters  ",0
openStr      BYTE "Open Image...",0
saveStr      BYTE "Save Image As...",0
exitStr      BYTE "Exit",0
negStr       BYTE "Invert Colors",0
grayStr      BYTE "Grayscale",0
brightStr    BYTE "Brightness +50",0
darkStr      BYTE "Darken -50",0
sepiaStr     BYTE "Sepia Tone",0
flipHStr     BYTE "Flip Horizontal",0
flipVStr     BYTE "Flip Vertical",0
cropStr      BYTE "Crop Image...",0

ofn          GUI_OPENFILENAME <>
szFileName   BYTE 260 DUP(0)
szFilter     BYTE "Bitmap Files (*.bmp)",0,"*.bmp",0,"All Files (*.*)",0,"*.*",0,0
saveSuccess  BYTE "Image saved successfully!",0
msgTitle     BYTE "IMASM",0

hBgBrush     DWORD ?
editClass    BYTE "EDIT",0
btnClass     BYTE "BUTTON",0
lblClass     BYTE "STATIC",0
lblWText     BYTE "W (px):",0
lblHText     BYTE "H (px):",0
btnText      BYTE "Crop",0

hwndLblW     DWORD ?
hwndLblH     DWORD ?
hwndEditW    DWORD ?
hwndEditH    DWORD ?
hwndBtnCrop  DWORD ?
winRect      GUI_RECT <>

; Title update strings
szDimBuffer  BYTE 64 DUP(0)
szTitleBase  BYTE "IMASM | Current: ",0
szX          BYTE " x ",0

szWidthStr   BYTE 10 DUP(0)
szHeightStr  BYTE 10 DUP(0)
cropW        DWORD ?
cropH        DWORD ?
newRowSize   DWORD ?
newFileSize  DWORD ?
pNewHeap     DWORD ?

hFile        DWORD ?
bytesRead    DWORD ?
fileSize     DWORD ?
hHeap        DWORD ?
pHeap        DWORD 0
pHeader      DWORD ?
pPixels      DWORD ?
imgWidth     DWORD ?
imgHeight    DWORD ?
pixelOffset  DWORD ?
rowSize      DWORD ?

sepR         DWORD ?
sepG         DWORD ?
sepB         DWORD ?

; =========================================================================
; 5. CODE
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
    LOCAL hEditMenu:DWORD
    LOCAL hFiltMenu:DWORD

    mov eax, prevInst
    mov eax, cmdLineStr

    INVOKE CreateSolidBrush, 002D231Ch
    mov hBgBrush, eax

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
    mov eax, hBgBrush
    mov wc.hbrBackground, eax
    mov wc.lpszMenuName, 0
    mov wc.lpszClassName, OFFSET className
    INVOKE RegisterClassA, ADDR wc

    INVOKE CreateWindowExA, 0, ADDR className, ADDR windowTitle,
        WS_OVERLAPPEDWINDOW,
        CW_USEDEFAULT, CW_USEDEFAULT, 620, 480,
        0, 0, instHandle, 0
    mov mainHwnd, eax

    INVOKE CreateMenu
    mov hMenu, eax
    INVOKE CreatePopupMenu
    mov hFileMenu, eax
    INVOKE CreatePopupMenu
    mov hEditMenu, eax
    INVOKE CreatePopupMenu
    mov hFiltMenu, eax

    INVOKE AppendMenuA, hFileMenu, MF_STRING,    IDM_FILE_OPEN,  ADDR openStr
    INVOKE AppendMenuA, hFileMenu, MF_STRING,    IDM_FILE_SAVE,  ADDR saveStr
    INVOKE AppendMenuA, hFileMenu, MF_SEPARATOR, 0,              0
    INVOKE AppendMenuA, hFileMenu, MF_STRING,    IDM_FILE_EXIT,  ADDR exitStr

    INVOKE AppendMenuA, hEditMenu, MF_STRING,    IDM_EDIT_FLIP_H, ADDR flipHStr
    INVOKE AppendMenuA, hEditMenu, MF_STRING,    IDM_EDIT_FLIP_V, ADDR flipVStr
    INVOKE AppendMenuA, hEditMenu, MF_SEPARATOR, 0,               0
    INVOKE AppendMenuA, hEditMenu, MF_STRING,    IDM_EDIT_CROP,   ADDR cropStr

    INVOKE AppendMenuA, hFiltMenu, MF_STRING,    IDM_FILTER_NEG,   ADDR negStr
    INVOKE AppendMenuA, hFiltMenu, MF_STRING,    IDM_FILTER_GRAY,  ADDR grayStr
    INVOKE AppendMenuA, hFiltMenu, MF_SEPARATOR, 0,                0
    INVOKE AppendMenuA, hFiltMenu, MF_STRING,    IDM_FILTER_BRIGHT, ADDR brightStr
    INVOKE AppendMenuA, hFiltMenu, MF_STRING,    IDM_FILTER_DARK,   ADDR darkStr
    INVOKE AppendMenuA, hFiltMenu, MF_STRING,    IDM_FILTER_SEPIA,  ADDR sepiaStr

    INVOKE AppendMenuA, hMenu, MF_POPUP, hFileMenu, ADDR fileMenuStr
    INVOKE AppendMenuA, hMenu, MF_POPUP, hEditMenu, ADDR editMenuStr
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
            mov ofn.lpstrFile,   OFFSET szFileName
            mov ofn.nMaxFile,    260
            mov ofn.Flags, OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST
            INVOKE GetOpenFileNameA, ADDR ofn
            .IF eax != 0
                INVOKE CreateFileA, ADDR szFileName, GENERIC_READ, 0, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
                mov hFile, eax
                .IF eax != INVALID_HANDLE_VALUE
                    INVOKE GetFileSize, hFile, 0
                    mov fileSize, eax
                    INVOKE GetProcessHeap
                    mov hHeap, eax
                    INVOKE HeapAlloc, hHeap, 8, fileSize
                    mov pHeap, eax
                    INVOKE ReadFile, hFile, pHeap, fileSize, ADDR bytesRead, 0
                    INVOKE CloseHandle, hFile

                    mov esi, pHeap
                    mov eax, DWORD PTR [esi+18]
                    mov imgWidth, eax
                    mov eax, DWORD PTR [esi+22]
                    mov imgHeight, eax
                    mov eax, DWORD PTR [esi+10]
                    mov pixelOffset, eax

                    mov eax, pHeap
                    add eax, pixelOffset
                    mov pPixels, eax
                    mov eax, pHeap
                    add eax, 14
                    mov pHeader, eax

                    mov eax, imgWidth
                    mov ebx, 3
                    mul ebx
                    add eax, 3
                    and eax, 0FFFFFFFCh
                    mov rowSize, eax

                    mov winRect.left,   0
                    mov winRect.top,    0
                    mov eax, imgWidth
                    add eax, 40
                    mov winRect.right,  eax
                    mov eax, imgHeight
                    add eax, 80
                    mov winRect.bottom, eax
                    INVOKE AdjustWindowRect, ADDR winRect, WS_OVERLAPPEDWINDOW, 1
                    mov eax, winRect.right
                    sub eax, winRect.left
                    mov ebx, winRect.bottom
                    sub ebx, winRect.top
                    INVOKE SetWindowPos, winHandle, 0, 0, 0, eax, ebx, 6
                    
                    INVOKE SetWindowTextA, winHandle, ADDR windowTitle
                    INVOKE UpdateWindow, winHandle
                    INVOKE InvalidateRect, winHandle, 0, 1
                    INVOKE RenderImage, winHandle
                .ENDIF
            .ENDIF

        .ELSEIF eax == IDM_FILE_SAVE
            .IF pHeap != 0
                mov szFileName[0], 0
                mov ofn.lStructSize, 76
                mov eax, winHandle
                mov ofn.hwndOwner, eax
                mov ofn.lpstrFilter, OFFSET szFilter
                mov ofn.lpstrFile,   OFFSET szFileName
                mov ofn.nMaxFile,    260
                mov ofn.Flags, OFN_OVERWRITEPROMPT
                INVOKE GetSaveFileNameA, ADDR ofn
                .IF eax != 0
                    INVOKE CreateFileA, ADDR szFileName, GENERIC_WRITE, 0, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
                    mov hFile, eax
                    .IF eax != INVALID_HANDLE_VALUE
                        INVOKE WriteFile, hFile, pHeap, fileSize, ADDR bytesRead, 0
                        INVOKE CloseHandle, hFile
                        INVOKE MessageBoxA, winHandle, ADDR saveSuccess, ADDR msgTitle, 0
                    .ENDIF
                .ENDIF
            .ENDIF

        .ELSEIF eax == IDM_EDIT_CROP
            .IF pHeap != 0
                ; Display current dimensions in title bar
                mov edi, OFFSET szDimBuffer
                mov esi, OFFSET szTitleBase
                mov ecx, 17
                rep movsb
                
                mov eax, imgWidth
                mov edi, OFFSET szDimBuffer + 17
                call WriteDimToBuffer ; Helper call
                
                mov esi, OFFSET szX
                mov ecx, 3
                rep movsb
                
                mov eax, imgHeight
                call WriteDimToBuffer
                
                INVOKE SetWindowTextA, winHandle, ADDR szDimBuffer

                INVOKE CreateWindowExA, 0, ADDR lblClass, ADDR lblWText, WS_CHILD or WS_VISIBLE, 20, 12, 55, 20, winHandle, 0, globalInst, 0
                mov hwndLblW, eax
                INVOKE CreateWindowExA, 0, ADDR lblClass, ADDR lblHText, WS_CHILD or WS_VISIBLE, 165, 12, 55, 20, winHandle, 0, globalInst, 0
                mov hwndLblH, eax
                INVOKE CreateWindowExA, 0, ADDR editClass, 0, WS_CHILD or WS_VISIBLE or WS_BORDER or ES_NUMBER, 78, 9, 70, 24, winHandle, 5001, globalInst, 0
                mov hwndEditW, eax
                INVOKE CreateWindowExA, 0, ADDR editClass, 0, WS_CHILD or WS_VISIBLE or WS_BORDER or ES_NUMBER, 223, 9, 70, 24, winHandle, 5002, globalInst, 0
                mov hwndEditH, eax
                INVOKE CreateWindowExA, 0, ADDR btnClass, ADDR btnText, WS_CHILD or WS_VISIBLE, 308, 8, 80, 26, winHandle, IDM_EXECUTE_CROP, globalInst, 0
                mov hwndBtnCrop, eax
            .ENDIF

        .ELSEIF eax == IDM_EXECUTE_CROP
            .IF pHeap != 0
                INVOKE GetWindowTextA, hwndEditW, ADDR szWidthStr,  10
                INVOKE GetWindowTextA, hwndEditH, ADDR szHeightStr, 10
                INVOKE AsciiToInt, ADDR szWidthStr
                mov cropW, eax
                INVOKE AsciiToInt, ADDR szHeightStr
                mov cropH, eax

                mov eax, cropW
                cmp eax, imgWidth
                jle _CheckH
                mov eax, imgWidth
                mov cropW, eax
            _CheckH:
                mov eax, cropH
                cmp eax, imgHeight
                jle _MathTime
                mov eax, imgHeight
                mov cropH, eax

            _MathTime:
                mov eax, cropW
                mov ebx, 3
                mul ebx
                add eax, 3
                and eax, 0FFFFFFFCh
                mov newRowSize, eax
                mov eax, newRowSize
                mov ebx, cropH
                mul ebx
                add eax, pixelOffset
                mov newFileSize, eax

                INVOKE HeapAlloc, hHeap, 8, newFileSize
                mov pNewHeap, eax
                cld
                mov ecx, pixelOffset
                mov esi, pHeap
                mov edi, pNewHeap
                rep movsb

                mov edi, pNewHeap
                mov eax, cropW
                mov [edi+18], eax
                mov eax, cropH
                mov [edi+22], eax
                mov eax, newFileSize
                mov [edi+2], eax

                mov edx, cropH
                mov esi, pPixels
                mov eax, pNewHeap
                add eax, pixelOffset
                mov edi, eax
            _CropRowLoop:
                push edx
                push esi
                push edi
                mov eax, cropW
                mov ebx, 3
                mul ebx
                mov ecx, eax
                rep movsb
                pop edi
                pop esi
                add esi, rowSize
                add edi, newRowSize
                pop edx
                dec edx
                jnz _CropRowLoop

                INVOKE HeapFree, hHeap, 0, pHeap
                mov eax, pNewHeap
                mov pHeap, eax
                mov eax, cropW
                mov imgWidth, eax
                mov eax, cropH
                mov imgHeight, eax
                mov eax, newRowSize
                mov rowSize, eax
                mov eax, newFileSize
                mov fileSize, eax
                mov eax, pHeap
                add eax, pixelOffset
                mov pPixels, eax
                mov eax, pHeap
                add eax, 14
                mov pHeader, eax

                INVOKE ShowWindow, hwndLblW,    0
                INVOKE ShowWindow, hwndLblH,    0
                INVOKE ShowWindow, hwndEditW,   0
                INVOKE ShowWindow, hwndEditH,   0
                INVOKE ShowWindow, hwndBtnCrop, 0

                INVOKE SetWindowTextA, winHandle, ADDR windowTitle
                mov winRect.left,   0
                mov winRect.top,    0
                mov eax, imgWidth
                add eax, 40
                mov winRect.right,  eax
                mov eax, imgHeight
                add eax, 80
                mov winRect.bottom, eax
                INVOKE AdjustWindowRect, ADDR winRect, WS_OVERLAPPEDWINDOW, 1
                mov eax, winRect.right
                sub eax, winRect.left
                mov ebx, winRect.bottom
                sub ebx, winRect.top
                INVOKE SetWindowPos, winHandle, 0, 0, 0, eax, ebx, 6
                INVOKE UpdateWindow, winHandle
                INVOKE InvalidateRect, winHandle, 0, 1
                INVOKE RenderImage, winHandle
            .ENDIF

        .ELSEIF eax == IDM_EDIT_FLIP_V
            .IF pHeap != 0
                mov esi, pPixels
                mov eax, imgHeight
                dec eax
                mov ebx, rowSize
                mul ebx
                add eax, pPixels
                mov edi, eax
                mov ecx, imgHeight
                shr ecx, 1
            _Vert_Outer:
                push ecx
                push esi
                push edi
                mov ecx, rowSize
            _Vert_Inner:
                mov al, [esi]
                mov bl, [edi]
                mov [esi], bl
                mov [edi], al
                inc esi
                inc edi
                loop _Vert_Inner
                pop edi
                pop esi
                add esi, rowSize
                sub edi, rowSize
                pop ecx
                dec ecx
                jnz _Vert_Outer
                INVOKE RenderImage, winHandle
            .ENDIF

        .ELSEIF eax == IDM_EDIT_FLIP_H
            .IF pHeap != 0
                mov edx, imgHeight
                mov esi, pPixels
            _Horiz_Outer:
                push edx
                mov eax, imgWidth
                dec eax
                mov ebx, 3
                mul ebx
                add eax, esi
                mov ebx, eax
                mov edi, esi
                mov ecx, imgWidth
                shr ecx, 1
            _Horiz_Inner:
                mov al, [edi]
                mov ah, [ebx]
                mov [edi], ah
                mov [ebx], al
                mov al, [edi+1]
                mov ah, [ebx+1]
                mov [edi+1], ah
                mov [ebx+1], al
                mov al, [edi+2]
                mov ah, [ebx+2]
                mov [edi+2], ah
                mov [ebx+2], al
                add edi, 3
                sub ebx, 3
                dec ecx
                jnz _Horiz_Inner
                add esi, rowSize
                pop edx
                dec edx
                jnz _Horiz_Outer
                INVOKE RenderImage, winHandle
            .ENDIF

        .ELSEIF eax == IDM_FILTER_NEG
            .IF pHeap != 0
                mov ecx, fileSize
                sub ecx, pixelOffset
                mov esi, pPixels
            _InvertLoop:
                mov al, BYTE PTR [esi]
                not al
                mov BYTE PTR [esi], al
                inc esi
                loop _InvertLoop
                INVOKE RenderImage, winHandle
            .ENDIF

        .ELSEIF eax == IDM_FILTER_GRAY
            .IF pHeap != 0
                mov eax, fileSize
                sub eax, pixelOffset
                xor edx, edx
                mov ebx, 3
                div ebx
                mov ecx, eax
                mov esi, pPixels
            _GrayLoop:
                movzx ax, BYTE PTR [esi]
                movzx bx, BYTE PTR [esi+1]
                add ax, bx
                movzx bx, BYTE PTR [esi+2]
                add ax, bx
                mov bl, 3
                div bl
                mov BYTE PTR [esi],   al
                mov BYTE PTR [esi+1], al
                mov BYTE PTR [esi+2], al
                add esi, 3
                dec ecx
                jnz _GrayLoop
                INVOKE RenderImage, winHandle
            .ENDIF

        .ELSEIF eax == IDM_FILTER_BRIGHT
            .IF pHeap != 0
                mov ecx, fileSize
                sub ecx, pixelOffset
                mov esi, pPixels
            _BrightLoop:
                movzx eax, BYTE PTR [esi]
                add eax, 50
                cmp eax, 255
                jle _BrightOk
                mov eax, 255
            _BrightOk:
                mov BYTE PTR [esi], al
                inc esi
                loop _BrightLoop
                INVOKE RenderImage, winHandle
            .ENDIF

        .ELSEIF eax == IDM_FILTER_DARK
            .IF pHeap != 0
                mov ecx, fileSize
                sub ecx, pixelOffset
                mov esi, pPixels
            _DarkLoop:
                movzx eax, BYTE PTR [esi]
                sub eax, 50
                jge _DarkOk
                xor eax, eax
            _DarkOk:
                mov BYTE PTR [esi], al
                inc esi
                loop _DarkLoop
                INVOKE RenderImage, winHandle
            .ENDIF

        .ELSEIF eax == IDM_FILTER_SEPIA
            .IF pHeap != 0
                mov eax, fileSize
                sub eax, pixelOffset
                xor edx, edx
                mov ebx, 3
                div ebx
                mov ecx, eax
                mov esi, pPixels
            _SepiaLoop:
                push ecx
                push esi
                movzx eax, BYTE PTR [esi+2]
                mov ebx, 393
                mul ebx
                mov ecx, eax
                movzx eax, BYTE PTR [esi+1]
                mov ebx, 769
                mul ebx
                add ecx, eax
                movzx eax, BYTE PTR [esi]
                mov ebx, 189
                mul ebx
                add ecx, eax
                mov eax, ecx
                xor edx, edx
                mov ebx, 1000
                div ebx
                cmp eax, 255
                jle _SepR_ok
                mov eax, 255
            _SepR_ok:
                mov sepR, eax
                pop esi
                push esi
                movzx eax, BYTE PTR [esi+2]
                mov ebx, 349
                mul ebx
                mov ecx, eax
                movzx eax, BYTE PTR [esi+1]
                mov ebx, 686
                mul ebx
                add ecx, eax
                movzx eax, BYTE PTR [esi]
                mov ebx, 168
                mul ebx
                add ecx, eax
                mov eax, ecx
                xor edx, edx
                mov ebx, 1000
                div ebx
                cmp eax, 255
                jle _SepG_ok
                mov eax, 255
            _SepG_ok:
                mov sepG, eax
                pop esi
                push esi
                movzx eax, BYTE PTR [esi+2]
                mov ebx, 272
                mul ebx
                mov ecx, eax
                movzx eax, BYTE PTR [esi+1]
                mov ebx, 534
                mul ebx
                add ecx, eax
                movzx eax, BYTE PTR [esi]
                mov ebx, 131
                mul ebx
                add ecx, eax
                mov eax, ecx
                xor edx, edx
                mov ebx, 1000
                div ebx
                cmp eax, 255
                jle _SepB_ok
                mov eax, 255
            _SepB_ok:
                mov sepB, eax
                pop esi
                mov eax, sepB
                mov BYTE PTR [esi],   al
                mov eax, sepG
                mov BYTE PTR [esi+1], al
                mov eax, sepR
                mov BYTE PTR [esi+2], al
                add esi, 3
                pop ecx
                dec ecx
                jnz _SepiaLoop
                INVOKE RenderImage, winHandle
            .ENDIF

        .ELSEIF eax == IDM_FILE_EXIT
            INVOKE DestroyWindow, winHandle
        .ENDIF

    .ELSEIF msgID == WM_PAINT
        .IF pHeap != 0
            INVOKE RenderImage, winHandle
        .ENDIF

    .ELSEIF msgID == WM_CTLCOLORSTATIC
        mov eax, hBgBrush
        ret

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

RenderImage PROC winHandle:DWORD
    LOCAL hdc:DWORD
    INVOKE GetDC, winHandle
    mov hdc, eax
    .IF pPixels != 0
        INVOKE SetDIBitsToDevice, hdc, 20, 50, imgWidth, imgHeight,
            0, 0, 0, imgHeight, pPixels, pHeader, 0
    .ENDIF
    INVOKE ReleaseDC, winHandle, hdc
    ret
RenderImage ENDP

; --- Number to Buffer Helper (for Title Bar) ---
WriteDimToBuffer PROC
    push ebx
    push ecx
    push edx
    mov ebx, 10
    mov ecx, 0
Divide:
    xor edx, edx
    div ebx
    push edx
    inc ecx
    test eax, eax
    jnz Divide
PopLoop:
    pop eax
    add al, '0'
    mov [edi], al
    inc edi
    loop PopLoop
    pop edx
    pop ecx
    pop ebx
    ret
WriteDimToBuffer ENDP

AsciiToInt PROC pString:DWORD
    push ebx
    push ecx
    push edx
    push esi
    mov esi, pString
    xor eax, eax
_ParseLoop:
    movzx ecx, BYTE PTR [esi]
    cmp ecx, 0
    je  _ParseDone
    cmp ecx, '0'
    jl  _ParseDone
    cmp ecx, '9'
    jg  _ParseDone
    sub ecx, '0'
    imul eax, 10
    add eax, ecx
    inc esi
    jmp _ParseLoop
_ParseDone:
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
AsciiToInt ENDP

END main