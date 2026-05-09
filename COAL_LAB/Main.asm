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
IDM_FILTER_NEG      EQU 2001    
IDM_FILTER_GRAY     EQU 2002    
IDM_EDIT_ROTATE     EQU 3001    ; NEW: Rotate ID
IDM_EDIT_CROP       EQU 3002    ; NEW: Crop ID

OFN_FILEMUSTEXIST   EQU 00001000h
OFN_PATHMUSTEXIST   EQU 00000800h
OFN_OVERWRITEPROMPT EQU 00000002h 

GENERIC_READ        EQU 80000000h
GENERIC_WRITE       EQU 40000000h 
OPEN_EXISTING       EQU 3
CREATE_ALWAYS       EQU 2         
FILE_ATTRIBUTE_NORMAL EQU 80h
INVALID_HANDLE_VALUE  EQU -1

; NEW: Window Positioning Constants
SWP_NOMOVE          EQU 2
SWP_NOZORDER        EQU 4

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
GetSaveFileNameA PROTO :DWORD       
GetFileSize      PROTO :DWORD, :DWORD

; NEW: Prototype to dynamically resize the window!
SetWindowPos     PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD

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

fileMenuStr BYTE "File",0
editMenuStr BYTE "Edit",0            ; NEW: Edit Menu
filtMenuStr BYTE "Filters",0
openStr     BYTE "Open Image...",0
saveStr     BYTE "Save Image As...",0
exitStr     BYTE "Exit",0
negStr      BYTE "Apply Negative / Invert",0
grayStr     BYTE "Apply Grayscale (B&W)",0   
rotStr      BYTE "Rotate 90 Degrees",0       ; NEW
cropStr     BYTE "Crop Image",0              ; NEW

ofn         GUI_OPENFILENAME <>
szFileName  BYTE 260 DUP(0)      
szFilter    BYTE "Bitmap Files (*.bmp)",0,"*.bmp",0,"All Files (*.*)",0,"*.*",0,0
saveSuccess BYTE "Image successfully saved to disk!",0
msgTitle    BYTE "IMASM Notice",0
buildMsg    BYTE "Architectural choice required! Do we use mouse dragging or manual numbers?",0

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
    LOCAL hEditMenu:DWORD
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

    ; Start with a small default window
    INVOKE CreateWindowExA,
        0, ADDR className, ADDR windowTitle, WS_OVERLAPPEDWINDOW,        
        CW_USEDEFAULT, CW_USEDEFAULT, 400, 300, 0, 0, instHandle, 0
    mov mainHwnd, eax

    INVOKE CreateMenu                       
    mov hMenu, eax
    INVOKE CreatePopupMenu                  
    mov hFileMenu, eax
    INVOKE CreatePopupMenu                  
    mov hEditMenu, eax
    INVOKE CreatePopupMenu
    mov hFiltMenu, eax

    INVOKE AppendMenuA, hFileMenu, MF_STRING, IDM_FILE_OPEN, ADDR openStr
    INVOKE AppendMenuA, hFileMenu, MF_STRING, IDM_FILE_SAVE, ADDR saveStr
    INVOKE AppendMenuA, hFileMenu, MF_STRING, IDM_FILE_EXIT, ADDR exitStr
    
    INVOKE AppendMenuA, hEditMenu, MF_STRING, IDM_EDIT_ROTATE, ADDR rotStr
    INVOKE AppendMenuA, hEditMenu, MF_STRING, IDM_EDIT_CROP, ADDR cropStr
    
    INVOKE AppendMenuA, hFiltMenu, MF_STRING, IDM_FILTER_NEG, ADDR negStr
    INVOKE AppendMenuA, hFiltMenu, MF_STRING, IDM_FILTER_GRAY, ADDR grayStr
    
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
            mov ofn.lpstrFile, OFFSET szFileName
            mov ofn.nMaxFile, 260
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
                    mov eax, DWORD PTR [esi + 18]
                    mov imgWidth, eax
                    mov eax, DWORD PTR [esi + 22]
                    mov imgHeight, eax
                    mov eax, DWORD PTR [esi + 10]
                    mov pixelOffset, eax
                    
                    mov eax, pHeap
                    add eax, pixelOffset
                    mov pPixels, eax
                    
                    mov eax, pHeap
                    add eax, 14
                    mov pHeader, eax

                    ; =====================================================================
                    ; NEW: DYNAMIC WINDOW RESIZING
                    ; =====================================================================
                    ; We want the window to be the image width + 40px for margins
                    mov eax, imgWidth
                    add eax, 40
                    
                    ; We want the height to be image height + 80px (for title bar + menus)
                    mov ebx, imgHeight
                    add ebx, 80
                    
                    ; Resize it! (6 = SWP_NOMOVE | SWP_NOZORDER, meaning don't move it, just resize)
                    INVOKE SetWindowPos, winHandle, 0, 0, 0, eax, ebx, 6
                    ; =====================================================================

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
                mov ofn.lpstrFile, OFFSET szFileName
                mov ofn.nMaxFile, 260
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
            
        ; --- EDIT MENU PLACEHOLDERS ---
        .ELSEIF eax == IDM_EDIT_ROTATE
            INVOKE MessageBoxA, winHandle, ADDR buildMsg, ADDR msgTitle, 0
            
        .ELSEIF eax == IDM_EDIT_CROP
            INVOKE MessageBoxA, winHandle, ADDR buildMsg, ADDR msgTitle, 0

        .ELSEIF eax == IDM_FILTER_NEG
            .IF pHeap != 0
                mov ecx, fileSize
                sub ecx, pixelOffset
                mov esi, pPixels
                
            InvertLoop:
                mov al, BYTE PTR [esi]   
                not al                   
                mov BYTE PTR [esi], al   
                inc esi                  
                loop InvertLoop          
                
                INVOKE RenderImage, winHandle
            .ENDIF

        .ELSEIF eax == IDM_FILTER_GRAY
            .IF pHeap != 0
                mov ecx, fileSize
                sub ecx, pixelOffset
                
                mov eax, ecx
                mov edx, 0
                mov ebx, 3
                div ebx
                mov ecx, eax    

                mov esi, pPixels
                
            GrayLoop:
                movzx ax, BYTE PTR [esi]      
                movzx bx, BYTE PTR [esi+1]    
                movzx dx, BYTE PTR [esi+2]    
                
                add ax, bx
                add ax, dx
                
                mov bl, 3
                div bl          
                
                mov BYTE PTR [esi], al
                mov BYTE PTR [esi+1], al
                mov BYTE PTR [esi+2], al
                
                add esi, 3
                dec ecx
                cmp ecx, 0
                jg GrayLoop
                
                INVOKE RenderImage, winHandle
            .ENDIF

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

RenderImage PROC winHandle:DWORD
    LOCAL hdc:DWORD
    
    INVOKE GetDC, winHandle
    mov hdc, eax
    
    INVOKE SetDIBitsToDevice, 
        hdc, 20, 20, imgWidth, imgHeight, 0, 0, 0, imgHeight, 
        pPixels, pHeader, 0                   
        
    INVOKE ReleaseDC, winHandle, hdc
    ret
RenderImage ENDP

END main