;------------------------------------------
; PURPOSE : Project Menu 
; SYSTEM  : Turbo Assembler Ideal Mode  
; AUTHOR  : Almog Hamdani
;------------------------------------------

        %TITLE "Key Breaker"

		IDEAL

		MODEL small

		STACK 256

;------------------------
; ClearScreen - Clears the screen in graphic mode
;------------------------
; Input:
;       None
; Output:
;       None
; Registers:
;       AX
;------------------------
MACRO ClearScreen
        mov ax, 13h
        int 10h
ENDM ClearScreen

;------------------------
; CopyString - Copy a string to string
;------------------------
; Input:
;       STR1 - The src string, STR2 - The dst string, LEN - The length of the src string
; Output:
;       The src in the dst string
; Registers:
;       AX
;------------------------
MACRO CopyString STR1, STR2, LEN

        mov dx, es ; Save extra segment original

;-----  Set es as data segment
        mov ax, ds
        mov es, ax

        lea si, [STR1]
        lea di, [STR2]
        mov cx, LEN
        rep movsb
 
        mov es, dx

ENDM CopyString

;------------------------
; DrawRect - Draws a rectangle on the screen
;------------------------
; Input:
;       X, Y, SizeHeight, SizeWidth      
; Output:
;       The rectangle on the screen
; Registers:
;       AX, DI, ES
;------------------------
MACRO DrawRect X, Y, Width, Height, Clr
        mov [Color], Clr
        mov [StartX], X
        mov [StartY], Y
        mov [SizeWidth], Width
        mov [SizeHeight], Height

        call DrawRectangle
ENDM DrawRect

;------------------------
; DrawPlayer - Draws the player
;------------------------
; Input:
;       PlayerX, PlayerY      
; Output:
;       The player on the screen
; Registers:
;       AX, CX, DX, SI, ES
;------------------------
MACRO DrawPlayer
;-----  Set player' position

        mov ax, [PlayerX]
        mov [X], ax

        mov ax, [PlayerY]
        mov [Y], ax

        mov cx, PlayerHeight
        mov dx, PlayerWidth
        lea si, [PlayerPic]

        call PrintSprite
ENDM

;----Constants-----

GameBackgroundColor     equ 53
FloorY                  equ 150
DistanceFromWall	equ 5
MidScreen		equ 160
EndScreen		equ 320
MaxX			equ EndScreen - PlayerWidth
MinX			equ 0
MaxY			equ 20
PlayerFloorDist		equ 1
PlayerJumpHeight	equ 50
FloorColor		equ 15
FloorHeight		equ 10
FlatFloor		equ 0
TallFloor		equ 1
TallFloorHeightRangeMin equ 30
TallFloorHeightRangeMax equ 70
TallLowerFlatLength	equ 60
TallUpperFlatLength	equ 40

;------------------

		DATASEG

PCXErrorMSG      db 'An error occurred during drawing PCX file! Please try again!$'
FileHandle       dw ?
FileName         db 100 dup (?)
FileSize         dw ?
ImageHeight      dw ?
ImageWidth       dw ?
StartX           dw ?
StartY           dw ?

X                dw ?
Y                dw ?
Color            db ?

SizeHeight       dw ?
SizeWidth        dw ?

Temp             dw ?

MapOrder	 db FlatFloor, TallFloor, FlatFloor
MapOffset	 dw 0, MidScreen, EndScreen
MapData		 db 0, 0, 0

PlayerPic db 053,053,053,053,053,053,053,053,053,053,053,053,053,053,053
          db 053,018,018,018,018,018,018,018,018,018,018,018,018,018,053
          db 053,018,018,025,018,018,018,025,018,018,018,018,018,018,053
          db 053,018,018,018,018,018,018,018,018,018,031,031,018,018,053
          db 053,018,018,018,018,025,018,018,018,018,031,031,018,018,053
          db 053,018,025,018,018,018,018,018,025,018,018,018,018,018,053
          db 053,018,018,018,018,018,018,018,018,018,025,018,018,018,053
          db 053,018,018,018,018,025,018,018,018,018,018,018,018,018,053
          db 053,018,018,018,018,018,018,025,018,018,018,018,025,018,053
          db 053,018,018,018,025,018,018,018,018,018,018,018,018,018,053
          db 053,018,018,018,018,018,018,018,018,018,025,018,018,018,053
          db 053,018,025,018,018,018,018,025,018,018,018,018,018,018,053
          db 053,018,018,018,025,018,018,018,018,018,018,018,018,018,053
          db 053,053,053,053,053,053,053,053,053,053,053,053,053,053,053

PlayerHeight equ 14
PlayerWidth  equ 15

PlayerX          dw ?
PlayerY          dw ?

OpeningFileName  db 'open.pcx'
OpeningNameLen   equ 8

MenuFileName     db 'menu.pcx'
MenuNameLen      equ 8

dotPic  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,48,48,48,49,49,49,50,0,0,0,0
        db 0,0,0,48,48,48,49,49,50,50,50,51,0,0,0
        db 0,0,48,48,48,49,49,50,50,51,51,51,52,0,0
        db 0,48,48,48,49,49,50,50,51,51,51,52,52,53,0
        db 0,48,48,49,49,50,50,51,51,52,52,52,53,53,0
        db 0,48,49,49,50,50,51,51,52,52,53,53,53,54,0
        db 0,49,49,50,50,51,51,52,52,53,53,53,54,54,0
        db 0,49,50,50,51,51,52,52,53,53,53,54,54,55,0
        db 0,50,50,51,51,52,52,53,53,54,54,54,55,55,0
        db 0,50,51,51,52,52,53,53,54,54,54,55,55,55,0
        db 0,0,51,52,52,53,53,54,54,54,55,55,56,0,0
        db 0,0,0,52,53,53,54,54,54,55,55,56,0,0,0
        db 0,0,0,0,53,53,54,54,55,55,56,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

dotPicWidth       equ 15
dotPicHeight      equ 15
dotJump           equ 33
dotStartX         equ 105
dotStartY         equ 75

dotOffset         dw 0
optionSelected    db 1

upArrowScanCode    equ 72
downArrowScanCode  equ 80
rightArrowScanCode equ 77
leftArrowScanCode  equ 75
enterScanCode      equ 28
spaceScanCode      equ 57

ScanCode dw ?

helpText          db "Get help here!", 13, 10, '$'
aboutText         db "Made by Almog Hamdani!", 13, 10, '$'

		CODESEG
Start:
        ; Set data segment
        mov ax, @data
        mov ds, ax

        ; Set video memory as extra segment
        mov ax, 0A000h
        mov es, ax

        ; Set graphic mode
        mov ax, 13h
        int 10h

PrintOpeningScreen:
        CopyString OpeningFileName, FileName, OpeningNameLen
        mov [StartX], 0
        mov [StartY], 0

        call DrawPCX

        ; Wait for input
        xor ah, ah
        int 16h

PrintMenu:
        ClearScreen

        CopyString MenuFileName, FileName, MenuNameLen
        mov [StartX], 0
        mov [StartY], 0

        call DrawPCX

PrintSelectDot:
        ; Set dot' position
        mov [X], dotStartX
        mov [Y], dotStartY

        mov ax, [dotOffset]
        add [Y], ax

        ; Set dot' size
        mov cx, dotPicHeight
        mov dx, dotPicWidth

        lea si, [dotPic] ; Set dot pic offset

        call PrintSprite ; Print dot

CheckArrows:
        ; Get input from keyboard
        xor ah, ah
        int 16h

        cmp ah, enterScanCode ; Check if enter is pressed
        je JumpToSelected

        cmp ah, upArrowScanCode ; Check if up arrow was pressed
        je HandleUp

        cmp ah, downArrowScanCode ; Check if down arrow was pressed
        je HandleDown

        jmp CheckArrows

HandleUp:
        ; If current option is the first, don't go up
        cmp [optionSelected], 1
        je CheckArrows

        ; Set dot' position
        mov [X], dotStartX
        mov [Y], dotStartY

        mov ax, [dotOffset]
        add [Y], ax

        ; Set dot' size
        mov cx, dotPicHeight
        mov dx, dotPicWidth

        call ClearSprite

        dec [optionSelected] ; Set option to be the previous
        sub [dotOffset], dotJump ; Set currect offset

        jmp PrintSelectDot ; Print dot again

HandleDown:
        ; If current option is the last, don't go down
        cmp [optionSelected], 4
        je CheckArrows

        ; Set dot' position
        mov [X], dotStartX
        mov [Y], dotStartY

        mov ax, [dotOffset]
        add [Y], ax

        ; Set dot' size
        mov cx, dotPicHeight
        mov dx, dotPicWidth

        call ClearSprite

        inc [optionSelected] ; Set option to be the next
        add [dotOffset], dotJump ; Set currect offset

        jmp PrintSelectDot ; Print dot again

JumpToSelected:
        ; Jump to the selected option

        ; Set text mode
        mov ax, 13h
        int 10h

        cmp [optionSelected], 1
        je StartGame

        cmp [optionSelected], 2
        je ShowHelp

        cmp [optionSelected], 3
        je ShowAbout

        jmp Exit

StartGame:

        call Game

ShowHelp:

        call Help

ShowAbout:

        call About

Exit:
;-----  Set text mode
        mov ax, 3h
        int 10h

        ; Exit
        mov ax, 4C00h
        int 21h

PROC Game
        ; Setting background color
        mov [Color], GameBackgroundColor
        call PaintScreen

	call PrintMap

;-----	Set player' position
        mov [PlayerX], 50
        mov [PlayerY], FloorY - PlayerHeight - PlayerFloorDist

        DrawPlayer

@@Key:
        call CheckPlayerMove

        cmp al, spaceScanCode
        je @@Jump

	call PlayerGravity

        DrawPlayer

        jmp @@Key

@@Jump:
        call PlayerJump
	call PlayerGravity

        jmp @@Key ; Return to key tap

        ret
ENDP Game

PROC PrintMap
;-----	Init
	lea si, [MapOrder]
	lea bx, [MapOffset]
	mov [Temp], 0

@@Print:
;-----	If current part is a flat part
	cmp [byte si], FlatFloor
	je @@Flat

	cmp [byte si], TallFloor
	je @@Tall

	ret

@@Flat:
;-----	Draw a flat floor
	mov ax, [bx]
	DrawRect ax, FloorY, MidScreen, FloorHeight, FloorColor
	jmp @@Increase

@@Tall:
	call DrawTallPart

@@Increase:
;-----	Point to next map part
	inc si
	add bx, 2
	inc [Temp]
    
	cmp [Temp], 3
	jne @@Print

	ret
    
ENDP PrintMap

; BX <- The address of the map offset
PROC DrawTallPart	
;-----	Drawing first flat
	mov ax, [bx]
	DrawRect ax, FloorY, TallLowerFlatLength, FloorHeight, FloorColor

;------	Random height
	in al, 40h ; Random number from clock
	and ax, TallFloorHeightRangeMax - TallFloorHeightRangeMin ; Getting random between range
	add al, TallFloorHeightRangeMin ; Add minimum for fixed range

;-----	Set si to point to current map info
	lea di, [MapData]
	add di, [Temp] ; Temp holds the current part number

	mov [di], al

;-----	Drawing tall
	; Setting start x
	mov ax, [bx]
	add ax, TallLowerFlatLength

	; Setting start y
	mov dx, FloorY
	sub dx, [di]

	mov cx, [di] ; Set height
	add cx, FloorHeight

	; Save registers
	push dx
	push ax
	push cx
	DrawRect ax, dx, FloorHeight, cx, FloorColor ; Drawing first part
	pop cx
	pop ax
	pop dx

	; Save registers
	push dx
	push ax
	push cx
	DrawRect ax, dx, TallUpperFlatLength, FloorHeight, FloorColor ; Drawing upper part
	pop cx
	pop ax
	pop dx

	add ax, TallUpperFlatLength - FloorHeight ; Set in ax the x of the second part

	DrawRect ax, dx, FloorHeight, cx, FloorColor ; Drawing second part

;-----	Drawing second flat
	mov ax, [bx]
	add ax, TallLowerFlatLength + TallUpperFlatLength

	DrawRect ax, FloorY, TallLowerFlatLength, FloorHeight, FloorColor

	ret
ENDP DrawTallPart

PROC MoveMap
;-----	Decrease all parts' offsets
	lea bx, [MapOffset]
	dec [word bx]

	add bx, 2
	dec [word bx]

	add bx, 2
	dec [word bx]

;-----	Check if the middle part is now the first part
	sub bx, 2
	cmp [word bx], 0
	je @@NewMapPart

	ret

@@NewMapPart:
;-----	Move all parts by 1 backwards and randomize the new one
	mov al, [MapOrder + 1]
	mov [MapOrder], al

	mov al, [MapOrder + 2]
	mov [MapOrder + 1], al

;-----	Move all parts' data by 1 backwards and randomize the new one
	mov al, [MapData + 1]
	mov [MapData], al

	mov al, [MapData + 2]
	mov [MapData + 1], al

;-----	Random new part, 0 - 1 for now
	xor ax, ax
	in al, 40h
	and ax, 0

	mov [MapOrder + 2], al

;-----	Reset offsets
	mov [MapOffset], 0
	mov [MapOffset + 2], MidScreen
	mov [MapOffset + 4], EndScreen

	ret

ENDP MoveMap

PROC FixMap
;-----	Init
    	lea si, [MapOrder]
	lea bx, [MapOffset]
	mov [Temp], 0

@@Print:
;-----	If current part is a flat part
	cmp [byte si], FlatFloor
	je @@Flat

	cmp [byte si], TallFloor
	je @@Tall

	ret

@@Flat:
;-----	Add a part in the start
	mov ax, [bx]
	DrawRect ax, FloorY, 1, FloorHeight, FloorColor

;-----	Remove a part from the end
	mov ax, [bx]
	add ax, MidScreen
	DrawRect ax, FloorY, 1, FloorHeight, GameBackgroundColor
	jmp @@Increase

@@Tall:
	call FixTallPart
	jmp @@Flat ; Do as flat as well

@@Increase:
;-----	Point to next map part
	inc si
	add bx, 2
	inc [Temp]
    
	cmp [Temp], 3
	jne @@Print

	ret
ENDP FixMap

; BX <- The address of the map offset
PROC FixTallPart
;-----	Set x
	mov ax, [bx]
	add ax, TallLowerFlatLength + 1

;-----	Point to part' data
	lea di, [MapData]
	add di, [Temp]

;-----	Set y
	mov cx, FloorY
	sub cx, [di]

;-----	Set height
	mov dx, [di] ; Take height from map data
	dec dx

	; Save registers
	push ax
	push dx
	push cx
	DrawRect ax, cx, 1, dx, FloorColor ; Add a part
	pop cx
	pop dx
	pop ax

	add ax, FloorHeight ; Set new x
	add cx, FloorHeight + 1 ; Set new y
	
	; Save registers
	push ax
	push dx
	push cx
	DrawRect ax, cx, 1, dx, GameBackgroundColor ; Remove a part
	pop cx
	pop dx
	pop ax

	add ax, TallUpperFlatLength - FloorHeight * 2 ; Set new x

	; Save registers
	push ax
	push dx
	push cx
	DrawRect ax, cx, 1, dx, FloorColor ; Add a part
	pop cx
	pop dx
	pop ax

	add ax, FloorHeight ; Set new x
	sub cx, FloorHeight + 1 ; Set new y
	
	; Save registers
	push ax
	push dx
	push cx
	DrawRect ax, cx, 1, dx, GameBackgroundColor ; Remove a part
	pop cx
	pop dx
	pop ax

	ret
ENDP FixTallPart

PROC PlayerJump
	mov dx, MaxY

@@Jump: 
        dec [PlayerY] ; Jumping
        call CheckPlayerMove ; Check player movement

        DrawPlayer ; Draw player after axis changed

        cmp [PlayerY], dx ; Changed if reached the top
        jne @@Jump

	ret
	
ENDP PlayerJump

PROC PlayerGravity
    mov dx, 0 ; Will be used to fix the double movement issue

    @@Gravity:
;-----	Check if reached floor
        mov ax, [PlayerX]
        mov [X], ax

        mov ax, [PlayerY]
        add ax, PlayerHeight + PlayerFloorDist
        mov [Y], ax

        call GetPixel
        cmp [Color], FloorColor

	je @@Stop

	;-----	Check if reached floor ( second point )
        mov ax, [PlayerX]
	add ax, PlayerWidth
        mov [X], ax

        mov ax, [PlayerY]
        add ax, PlayerHeight + PlayerFloorDist
        mov [Y], ax

        call GetPixel
	cmp [Color], FloorColor

	je @@Stop

	inc [PlayerY] ; Go down
	
	cmp dx, 0 ; If it's the first time, jump to fix issue which will skip the check player movement again
	je @@FixIssue

        call CheckPlayerMove ; Check player movement
	
	DrawPlayer ; Draw player after axis changed

        jmp @@Gravity

@@FixIssue:
	inc dx
	DrawPlayer ; Draw player after axis changed

        jmp @@Gravity

@@Stop:

        ret
ENDP PlayerGravity

PROC CheckPlayerMove
        in al, 60h ; Get scan code from keybaord port

;-----	Check if the right arrow is pressed
        cmp al, rightArrowScanCode
        je @@MoveRight

;-----	Check if the left arrow is pressed
        cmp al, leftArrowScanCode
        je @@MoveLeft

        ret

@@MoveRight:

	cmp [PlayerX], MaxX - DistanceFromWall
	je @@Return

	;-----	Check if reached wall
        mov ax, [PlayerX]
	add ax, PlayerWidth + DistanceFromWall
        mov [X], ax

        mov ax, [PlayerY]
	add ax, PlayerHeight ; Bottom point
        mov [Y], ax

        call GetPixel
	cmp [Color], FloorColor
	je @@Return

	cmp [PlayerX], EndScreen / 2 - PlayerWidth / 2 ; Check if player in middle of screen, if it is, move map
	je @@Map

        inc [PlayerX] ; Move player right
	ret

@@Map:
;-----	Move map and fix it on the screen
	call MoveMap
	call FixMap
	ret

@@MoveLeft:
	cmp [PlayerX], MinX + DistanceFromWall
	je @@Return

	;-----	Check if reached wall
        mov ax, [PlayerX]
	sub ax, DistanceFromWall
        mov [X], ax

        mov ax, [PlayerY]
	add ax, PlayerHeight ; Bottom point
        mov [Y], ax

        call GetPixel
	cmp [Color], FloorColor
	je @@Return

        dec [PlayerX] ; Move player left
        ret

@@Return:
	ret

ENDP CheckPlayerMove

PROC Help

        ; Print text
        mov dx, offset helpText
        mov ah, 09h
        int 21h

        ; Wait for keyboard tap
        xor ah, ah
        int 16h

        jmp PrintMenu ; Return to menu

        ret
ENDP Help

PROC About

        ; Print text
        mov dx, offset aboutText
        mov ah, 09h
        int 21h

        ; Wait for keyboard tap
        xor ah, ah
        int 16h

        jmp PrintMenu ; Return to menu

        ret
ENDP About

INCLUDE 'DRAW.INC'

                END Start
