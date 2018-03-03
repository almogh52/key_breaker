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

	push dx
	push ax
	push cx
        call DrawRectangle
	pop cx
	pop ax
	pop dx
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
FloorSize		equ 10
FlatFloor		equ 0

TallFloor		equ 1
TallFloorSizeRangeMin	equ 20
TallFloorSizeRangeMax	equ 70
TallLowerFlatLength	equ 60
TallUpperFlatLength	equ 40

LavaFloor		equ 2
LavaHeight		equ 25
LavaColor		equ 41
LavaLowerFlatLength	equ 30
LavaLength		equ 160 - LavaLowerFlatLength * 2 - FloorSize * 2
LavaUpperWidthRangeMin  equ 20
LavaUpperWidthRangeMax  equ 70
LavaUpperY		equ 80
LavaWallsHeight		equ 45

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

MapOrder	 db FlatFloor, LavaFloor, FlatFloor
MapOffset	 dw 0, MidScreen, EndScreen
MapData		 dw 0, 50, 0

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

;------------------------
;Game - This proc is starting the game
;------------------------
;Input:
;       None
;Output:
;       The game
;Registers:
;       AX, BX, CX, DX, SI, DI, ES
;------------------------
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

;------------------------
;PrintMap - This is printing the map on the screen
;------------------------
;Input:
;       None
;Output:
;       The map on the screen
;Registers:
;       AX, BX, CX, DX, SI, DI, ES
;------------------------
PROC PrintMap
;-----	Init
	lea si, [MapOrder]
	lea bx, [MapOffset]
	mov [Temp], 0

@@Print:
;-----	If current part is a flat part
	cmp [byte si], FlatFloor
	je @@Flat

;-----	If current part is a tall part
	cmp [byte si], TallFloor
	je @@Tall

;-----	If current part is a lava part
	cmp [byte si], LavaFloor
	je @@Lava

	ret

@@Flat:
;-----	Draw a flat floor
	mov ax, [bx]
	DrawRect ax, FloorY, MidScreen, FloorSize, FloorColor
	jmp @@Increase

@@Tall:
	call DrawTallPart

	jmp @@Increase

@@Lava:
	call DrawLavaPart

@@Increase:
;-----	Point to next map part
	inc si
	add bx, 2
	inc [Temp]
    
	cmp [Temp], 3
	jne @@Print

	ret
    
ENDP PrintMap

;------------------------
;TallPartRandomHeight - Creating a random height for the tall part
;------------------------
;Input:
;       BX <- Min, CX <- Max, Temp <- The part' number
;Output:
;       Random height
;Registers:
;       AX, DI
;------------------------
PROC RandomData
;------	Random height
	in ax, 40h ; Random number from clock

;-----	Set in cx the max - min
	sub cx, bx
	inc cx ; Range + 1

	xor dx, dx ; Reset dx for result
	div cx ; Divide ax in dx, the modulo will be in dx

	add dx, bx ; Add minimum for fixed range

;-----	Set di to point to current map info
	lea di, [MapData]
	shl [Temp], 1 ; Mul by 2
	add di, [Temp] ; Temp holds the current part number
	shr [Temp], 1 ; Return original value, divide by 2

	mov [di], dx

	ret
ENDP RandomData

;------------------------
;DrawTallPart - This is drawing the tall part on the screen in it's location
;------------------------
;Input:
;       BX <- The address of the map offset, Temp <- The part' number
;Output:
;       The tall part on the screen
;Registers:
;       AX, BX, CX, DX, DI, ES
;------------------------
PROC DrawTallPart	
;-----	Drawing first flat
	mov ax, [bx]
	DrawRect ax, FloorY, TallLowerFlatLength, FloorSize, FloorColor

;-----	Set di to point to current map info
	lea di, [MapData]
	shl [Temp], 1 ; Mul by 2
	add di, [Temp] ; Temp holds the current part number
	shr [Temp], 1 ; Return original value, divide by 2

;-----	Drawing tall
	; Setting start x
	add ax, TallLowerFlatLength

	; Setting start y
	mov dx, FloorY
	sub dx, [di]

	mov cx, [di] ; Set height
	add cx, FloorSize

	DrawRect ax, dx, FloorSize, cx, FloorColor ; Drawing first part

	DrawRect ax, dx, TallUpperFlatLength, FloorSize, FloorColor ; Drawing upper part

	add ax, TallUpperFlatLength - FloorSize ; Set in ax the x of the second part

	DrawRect ax, dx, FloorSize, cx, FloorColor ; Drawing second part

;-----	Drawing second flat
	mov ax, [bx]
	add ax, TallLowerFlatLength + TallUpperFlatLength

	DrawRect ax, FloorY, TallLowerFlatLength, FloorSize, FloorColor

	ret
ENDP DrawTallPart

;------------------------
;DrawLavaPart - This is drawing the lava part on the screen in it's location
;------------------------
;Input:
;       BX <- The address of the map offset, Temp <- The part' number
;Output:
;       The lava part on the screen
;Registers:
;       AX, BX, CX, DX, DI, ES
;------------------------
PROC DrawLavaPart	
;-----	Drawing flat
	mov ax, [bx]
	DrawRect ax, FloorY, MidScreen, FloorSize, FloorColor

;-----	Drawing first lava wall
	add ax, LavaLowerFlatLength ; Set the x axis of the first wall
	mov dx, FloorY - LavaWallsHeight - 1 ; Set y axis
	DrawRect ax, dx, FloorSize, LavaWallsHeight, FloorColor ; Draw first lava wall

;-----	Drawing lava
	add ax, FloorSize ; Set the x axis of the lava (the wall + it's width)
	mov dx, FloorY - LavaHeight - 1 ; Set y axis
	DrawRect ax, dx, LavaLength, LavaHeight, LavaColor ; Draw the lava

;-----	Set di to point to current map info
	lea di, [MapData]
	shl [Temp], 1 ; Mul by 2
	add di, [Temp] ; Temp holds the current part number
	shr [Temp], 1 ; Return original value, divide by 2

;-----	Drawing upper flat
	; Setting start x
	mov ax, [bx] ; Get part' offset
	add ax, LavaLowerFlatLength + FloorSize + (LavaLength) / 2 ; Set x in the middle of the lava
	mov cx, [di] ; Set upper length
	shr cx, 1 ; Div the length by 2
	sub ax, cx ; Set the x axis of the upper flat (Middle Lava - Upper length / 2)
	shl cx, 1 ; Return original value

	mov dx, FloorY - LavaUpperY ; Set y axis
	DrawRect ax, dx, cx, FloorSize, FloorColor ; Drawing upper flat

;-----	Drawing second wall
	mov ax, [bx] ; Get part' offset
	add ax, LavaLowerFlatLength + FloorSize + LavaLength ; Set the x of the second wall (Lava first flat width + first wall width + lava width)

	mov dx, FloorY - LavaWallsHeight - 1 ; Set y axis
	DrawRect ax, dx, FloorSize, LavaWallsHeight, FloorColor ; Draw second lava wall

	ret
ENDP DrawLavaPart

;------------------------
;MoveMap - This is moving the map left and adding new part if needed
;------------------------
;Input:
;       None
;Output:
;       The map will be moved but not redrawen
;Registers:
;       AX, BX, SI
;------------------------
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
	mov ax, [MapData + 2]
	mov [MapData], ax

	mov ax, [MapData + 4]
	mov [MapData + 2], ax

;-----	Random new part, 0 - 1 for now
	in ax, 40h ; Get number from time port
	xor dx, dx
	mov cx, 2 + 1 ; Between 0 - 2
	div cx ; Divide ax in cx, the modulo will be in dx
	mov al, dl ; Result is stored in dl becuase of the div

	mov [MapOrder + 2], al ; Set new part

;-----	Check if the new part is a tall floor
	cmp al, TallFloor
	je @@Tall

;-----	Check if the new part is a lava floor
	cmp al, LavaFloor
	je @@Lava

	jmp @@ResetOffsets ; If none of the above, just jump to reset offsets

@@Tall:
;-----	Get a random height for the new part
	mov [Temp], 2
	mov bx, TallFloorSizeRangeMin ; Set min
	mov cx, TallFloorSizeRangeMax ; Set max
	call RandomData

	jmp @@ResetOffsets

@@Lava:
;-----	Get a random width for the new part
	mov [Temp], 2
	mov bx, LavaUpperWidthRangeMin ; Set min
	mov cx, LavaUpperWidthRangeMax ; Set max
	call RandomData

@@ResetOffsets:
;-----	Reset offsets
	mov [MapOffset], 0
	mov [MapOffset + 2], MidScreen
	mov [MapOffset + 4], EndScreen

	ret

ENDP MoveMap

;------------------------
;FixMap - This is fixing the map on movement
;------------------------
;Input:
;       None
;Output:
;       The map on the screen fixed after movement
;Registers:
;       AX, BX, SI
;------------------------
PROC FixMap
;-----	Init
    	lea si, [MapOrder]
	lea bx, [MapOffset]
	mov [Temp], 0

@@Print:
;-----	If current part is a flat part
	cmp [byte si], FlatFloor
	je @@Flat

;-----	If current part is a tall part
	cmp [byte si], TallFloor
	je @@Tall

;-----	If current part is a lava part
	cmp [byte si], LavaFloor
	je @@Lava

	ret

@@Flat:
;-----	Add a part in the start
	mov ax, [bx]
	DrawRect ax, FloorY, 1, FloorSize, FloorColor

;-----	Remove a part from the end
	mov ax, [bx]
	add ax, MidScreen
	DrawRect ax, FloorY, 1, FloorSize, GameBackgroundColor

	jmp @@Increase

@@Tall:
	call FixTallPart
	jmp @@Flat ; Do as flat as well to fix the flat sides of the part

@@Lava:
	call FixLavaPart
	jmp @@Flat ; Do as flat as well to fix the flat sides of the part

@@Increase:
;-----	Point to next map part
	inc si
	add bx, 2
	inc [Temp]
    
	cmp [Temp], 3
	jne @@Print

	ret
ENDP FixMap

;------------------------
;FixTallPart - This is fixing the tall part on movement
;------------------------
;Input:
;       BX <- The address of the map offset, Temp <- The part' number
;Output:
;       The tall part on the screen fixed
;Registers:
;       AX, BX, CX, DX, SI, DI, ES
;------------------------
PROC FixTallPart
;-----	Check if the entire tall part except the last flat part is inside the screen, if not, it needs to be drawn
	cmp [word bx], EndScreen - TallLowerFlatLength - TallUpperFlatLength
	jg @@DrawPart

	jmp @@FixPart

@@DrawPart:
	call DrawTallPart ; Draw part and then fix it

@@FixPart:
;-----	Set x
	mov ax, [bx]
	add ax, TallLowerFlatLength + 1

;-----	Set di to point to current map info
	lea di, [MapData]
	shl [Temp], 1 ; Mul by 2
	add di, [Temp] ; Temp holds the current part number
	shr [Temp], 1 ; Return original value, divide by 2

;-----	Set y
	mov cx, FloorY
	sub cx, [di]

;-----	Set height
	mov dx, [di] ; Take height from map data
	dec dx

	DrawRect ax, cx, 1, dx, FloorColor ; Add a part

	add ax, FloorSize ; Set new x
	add cx, FloorSize + 1 ; Set new y
	
	DrawRect ax, cx, 1, dx, GameBackgroundColor ; Remove a part

	add ax, TallUpperFlatLength - FloorSize * 2 ; Set new x

	DrawRect ax, cx, 1, dx, FloorColor ; Add a part

	add ax, FloorSize ; Set new x
	sub cx, FloorSize + 1 ; Set new y
	
	DrawRect ax, cx, 1, dx, GameBackgroundColor ; Remove a part

	ret
ENDP FixTallPart

;------------------------
;FixLavaPart - This is fixing the lava part on movement
;------------------------
;Input:
;       BX <- The address of the map offset, Temp <- The part' number
;Output:
;       The tall part on the screen fixed
;Registers:
;       AX, BX, CX, DX, SI, DI, ES
;------------------------
PROC FixLavaPart
;-----	Check if the entire lava part except the last flat part is inside the screen, if not, it needs to be drawn
	cmp [word bx], EndScreen - LavaLowerFlatLength - FloorSize * 2 - (LavaLength)
	jg @@DrawPart

	jmp @@FixPart

@@DrawPart:
	call DrawLavaPart ; Draw part and then fix it

@@FixPart:
;-----	Adding a part before first wall
	mov ax, [bx]
	add ax, LavaLowerFlatLength + 1 ; Set x

	mov dx, FloorY - LavaWallsHeight - 1 ; Set y

	DrawRect ax, dx, 1, LavaWallsHeight, FloorColor ; Add a part

;-----	Adding a lava part after first wall
	add ax, FloorSize ; Set x

	mov dx, FloorY - LavaHeight - 1 ; Set y

	DrawRect ax, dx, 1, LavaHeight, LavaColor ; Add a part

;-----	Removing a part on top the last part in case there is floor color there
	mov cx, LavaWallsHeight - LavaHeight ; Set height as the diff between the lava height and the wall
	sub dx, cx ; Set y
	dec cx

	DrawRect ax, dx, 1, cx, GameBackgroundColor ; Remove a part

;-----	Add a part before second wall
	add ax, LavaLength ; Set x as after the lava
	mov dx, FloorY - LavaWallsHeight - 1 ; Set y

	DrawRect ax, dx, 1, LavaWallsHeight, FloorColor ; Add a part

;-----	Remove a part after second wall
	add ax, FloorSize ; Set x as after the wall

	DrawRect ax, dx, 1, LavaWallsHeight, GameBackgroundColor ; Remove a part

;-----	Set di to point to current map info
	lea di, [MapData]
	shl [Temp], 1 ; Mul by 2
	add di, [Temp] ; Temp holds the current part number
	shr [Temp], 1 ; Return original value, divide by 2

;-----	Add a part in the upper flat
	; Setting start x
	mov ax, [bx] ; Get part' offset
	add ax, LavaLowerFlatLength + FloorSize + (LavaLength) / 2 ; Set x in the middle of the lava
	mov cx, [di] ; Set upper length
	shr cx, 1 ; Div the length by 2
	sub ax, cx ; Set the x axis of the upper flat (Middle Lava - Upper length / 2)
	shl cx, 1 ; Return original value

	mov dx, FloorY - LavaUpperY ; Set y axis

	DrawRect ax, dx, 1, FloorSize, FloorColor ; Add a part

;-----	Remove a part from the end of the upper flat
	add ax, cx ; Add the size of the part to the x to get the end

	DrawRect ax, dx, 1, FloorSize, GameBackgroundColor ; Remove a part

	ret
ENDP FixLavaPart

;------------------------
;PlayerJump - This is making the player jump
;------------------------
;Input:
;	None
;Output:
;       The player to jump
;Registers:
;       DX
;------------------------
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

;------------------------
;PlayerGravity - This is making the player to jump down
;------------------------
;Input:
;       None
;Output:
;       The player to jump down
;Registers:
;       AX, DX
;------------------------
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

;------------------------
;CheckPlayerMove - This is checking if the player has moved and moving it if needed
;------------------------
;Input:
;       None
;Output:
;       The player to be moved but not redrawen
;Registers:
;       AX
;------------------------
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
