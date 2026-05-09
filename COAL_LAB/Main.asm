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
WS_CHILD            EQU 40000000h   ; NEW: Allows UI elements to live inside our window
WS_VISIBLE          EQU 10000000h   ; NEW: Makes UI elements visible
WS_BORDER           EQU 00800000h   ; NEW: Gives the text boxes a border
ES_NUMBER           EQU 2000h       ; NEW: Forces text boxes to only accept digits!
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
IDM_EDIT_FLIP_H     EQU 3001    
IDM_EDIT_FLIP_V     EQU 3002    
IDM_EDIT_CROP       EQU 3003    
IDM_EXECUTE_CROP    EQU 4001        ; NEW: ID for our physical Crop Button

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
SetWindowPos     PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD

; NEW: Heap Management & Text Box APIs
HeapFree         PROTO :DWORD, :DWORD, :DWORD
GetWindowTextA   PROTO :DWORD, :DWORD, :DWORD

SetDIBitsToDevice PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
GetDC            PROTO :DWORD
ReleaseDC        PROTO :DWORD, :DWORD

AppWinMain PROTO instHandle:DWORD, prevInst:DWORD, cmdLineStr:DWORD, showCmd:DWORD
AppWndProc PROTO winHandle:DWORD, msgID:DWORD, wPrm:DWORD, lPrm:DWORD
RenderImage PROTO winHandle:DWORD
AsciiToInt PROTO pString:DWORD      ; NEW: Our custom string parsing function

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
editMenuStr BYTE "Edit",0            
filtMenuStr BYTE "Filters",0
openStr     BYTE "Open Image...",0
saveStr     BYTE "Save Image As...",0
exitStr     BYTE "Exit",0
negStr      BYTE "Apply Negative / Invert",0
grayStr     BYTE "Apply Grayscale (B&W)",0   
flipHStr    BYTE "Flip Horizontally",0       
flipVStr    BYTE "Flip Vertically",0         
cropStr     BYTE "Crop Image (Manual)",0     

ofn         GUI_OPENFILENAME <>
szFileName  BYTE 260 DUP(0)      
szFilter    BYTE "Bitmap Files (*.bmp)",0,"*.bmp",0,"All Files (*.*)",0,"*.*",0,0
saveSuccess BYTE "Image successfully saved to disk!",0
msgTitle    BYTE "IMASM Notice",0

; --- NEW: UI Elements for Crop Tool ---
editClass   BYTE "EDIT",0
btnClass    BYTE "BUTTON",0
btnText     BYTE "CROP!",0
hwndEditW   DWORD ?
hwndEditH   DWORD ?
hwndBtnCrop DWORD ?

szWidthStr  BYTE 10 DUP(0)
szHeightStr BYTE 10 DUP(0)
cropW       DWORD ?
cropH       DWORD ?
newRowSize  DWORD ?
newFileSize DWORD ?
pNewHeap    DWORD ?

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
rowSize     DWORD ?                 

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
    INVOKE CreateWindowExA, 0, ADDR className, ADDR windowTitle, WS_OVERLAPPEDWINDOW,        
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
    INVOKE AppendMenuA, hEditMenu, MF_STRING, IDM_EDIT_FLIP_H, ADDR flipHStr
    INVOKE AppendMenuA, hEditMenu, MF_STRING, IDM_EDIT_FLIP_V, ADDR flipVStr
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

                    mov eax, imgWidth
                    mov ebx, 3
                    mul ebx
                    add eax, 3
                    and eax, 0FFFFFFFCh
                    mov rowSize, eax

                    ; We add extra height for the crop toolbar
                    mov eax, imgWidth
                    add eax, 40
                    mov ebx, imgHeight
                    add ebx, 110    
                    INVOKE SetWindowPos, winHandle, 0, 0, 0, eax, ebx, 6

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
            
        ; =====================================================================
        ; NEW: SPAWN THE CROP TOOLBAR UI
        ; =====================================================================
        .ELSEIF eax == IDM_EDIT_CROP
            .IF pHeap != 0
                ; Create Width Text Box
                INVOKE CreateWindowExA, 0, ADDR editClass, 0, WS_CHILD or WS_VISIBLE or WS_BORDER or ES_NUMBER, 20, 10, 80, 25, winHandle, 5001, globalInst, 0
                mov hwndEditW, eax
                
                ; Create Height Text Box
                INVOKE CreateWindowExA, 0, ADDR editClass, 0, WS_CHILD or WS_VISIBLE or WS_BORDER or ES_NUMBER, 110, 10, 80, 25, winHandle, 5002, globalInst, 0
                mov hwndEditH, eax
                
                ; Create CROP Button
                INVOKE CreateWindowExA, 0, ADDR btnClass, ADDR btnText, WS_CHILD or WS_VISIBLE, 200, 10, 80, 25, winHandle, IDM_EXECUTE_CROP, globalInst, 0
                mov hwndBtnCrop, eax
            .ENDIF

        ; =====================================================================
        ; NEW: EXECUTE THE CROP (MEMORY REALLOCATION)
        ; =====================================================================
        .ELSEIF eax == IDM_EXECUTE_CROP
            .IF pHeap != 0
                ; 1. Read strings from the text boxes
                INVOKE GetWindowTextA, hwndEditW, ADDR szWidthStr, 10
                INVOKE GetWindowTextA, hwndEditH, ADDR szHeightStr, 10
                
                ; 2. Convert strings to integers using our custom PROC
                INVOKE AsciiToInt, ADDR szWidthStr
                mov cropW, eax
                INVOKE AsciiToInt, ADDR szHeightStr
                mov cropH, eax
                
                ; Basic Safety Check (Don't crop larger than the image!)
                mov eax, cropW
                cmp eax, imgWidth
                jle CheckH
                mov eax, imgWidth
                mov cropW, eax
            CheckH:
                mov eax, cropH
                cmp eax, imgHeight
                jle MathTime
                mov eax, imgHeight
                mov cropH, eax

            MathTime:
                ; 3. Calculate new Padding and File Size
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

                ; 4. ALLOCATE NEW HEAP!
                INVOKE HeapAlloc, hHeap, 8, newFileSize
                mov pNewHeap, eax

                ; 5. Copy the Header over
                cld
                mov ecx, pixelOffset
                mov esi, pHeap
                mov edi, pNewHeap
                rep movsb

                ; 6. Update the new header with new dimensions
                mov edi, pNewHeap
                mov eax, cropW
                mov [edi+18], eax
                mov eax, cropH
                mov [edi+22], eax
                mov eax, newFileSize
                mov [edi+2], eax

                ; 7. THE PIXEL COPY LOOP (Copies Bottom-Left up to Width/Height)
                mov edx, cropH      
                mov esi, pPixels    
                mov eax, pNewHeap
                add eax, pixelOffset
                mov edi, eax        

            CropRowLoop:
                push edx
                push esi
                push edi

                mov ecx, cropW
                mov ebx, 3
                mov eax, ecx
                mul ebx
                mov ecx, eax        ; Bytes to copy = cropW * 3
                rep movsb           ; Fast memory copy!

                pop edi
                pop esi
                add esi, rowSize    ; Jump down one row in OLD image
                add edi, newRowSize ; Jump down one row in NEW image
                pop edx
                dec edx
                jnz CropRowLoop

                ; 8. SWAP THE HEAP AND DESTROY THE OLD ONE!
                INVOKE HeapFree, hHeap, 0, pHeap
                mov eax, pNewHeap
                mov pHeap, eax
                
                mov eax, cropW
                mov imgWidth, eax
                mov eax, cropH
                mov imgHeight, eax
                mov eax, newRowSize
                mov rowSize, eax

                mov eax, pHeap
                add eax, pixelOffset
                mov pPixels, eax
                mov eax, pHeap
                add eax, 14
                mov pHeader, eax

                ; 9. Hide UI and Resize Window
                INVOKE ShowWindow, hwndEditW, 0
                INVOKE ShowWindow, hwndEditH, 0
                INVOKE ShowWindow, hwndBtnCrop, 0

                mov eax, imgWidth
                add eax, 40
                mov ebx, imgHeight
                add ebx, 110
                INVOKE SetWindowPos, winHandle, 0, 0, 0, eax, ebx, 6

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
            VertOuterLoop:
                push ecx        
                mov ecx, rowSize
                push esi        
                push edi
                VertInnerLoop:
                    mov al, [esi]   
                    mov bl, [edi]
                    mov [esi], bl
                    mov [edi], al
                    inc esi
                    inc edi
                    loop VertInnerLoop
                pop edi         
                pop esi
                add esi, rowSize
                sub edi, rowSize
                pop ecx         
                dec ecx
                jnz VertOuterLoop
                INVOKE RenderImage, winHandle
            .ENDIF

        .ELSEIF eax == IDM_EDIT_FLIP_H
            .IF pHeap != 0
                mov edx, imgHeight 
                mov esi, pPixels   
            HorizOuterLoop:
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
                HorizInnerLoop:
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
                    jnz HorizInnerLoop
                add esi, rowSize    
                pop edx             
                dec edx
                jnz HorizOuterLoop
                INVOKE RenderImage, winHandle
            .ENDIF

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

; --- CUSTOM PROCEDURE: Paints RAM to the GUI ---
RenderImage PROC winHandle:DWORD
    LOCAL hdc:DWORD
    INVOKE GetDC, winHandle
    mov hdc, eax
    ; Notice we changed Y offset to 50 so it doesn't overlap the new toolbar!
    INVOKE SetDIBitsToDevice, hdc, 20, 50, imgWidth, imgHeight, 0, 0, 0, imgHeight, pPixels, pHeader, 0                   
    INVOKE ReleaseDC, winHandle, hdc
    ret
RenderImage ENDP

; =====================================================================
; CUSTOM PROCEDURE: String to Integer Converter
; Reads an ASCII string and converts it to a DWORD number in EAX
; =====================================================================
AsciiToInt PROC uses ebx ecx edx esi, pString:DWORD
    mov esi, pString
    xor eax, eax        ; Clear EAX (This will hold the final number)
ParseLoop:
    movzx ecx, byte ptr [esi]
    cmp ecx, 0          ; End of string?
    je Done
    cmp ecx, '0'        ; Is it less than '0'?
    jl Done
    cmp ecx, '9'        ; Is it greater than '9'?
    jg Done
    sub ecx, '0'        ; Convert ASCII char to real number (e.g., '5' becomes 5)
    imul eax, 10        ; Multiply current total by 10
    add eax, ecx        ; Add the new digit
    inc esi
    jmp ParseLoop
Done:
    ret
AsciiToInt ENDP

END main