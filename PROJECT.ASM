;------------------------------------------
; PURPOSE : Project
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
MaxX			equ (EndScreen - PlayerWidth)
MinX			equ 0
MaxY			equ 20

PlayerFloorDist		equ 1
PlayerJumpHeight	equ (100 - PlayerHeight)

FloorColor		equ 15
FloorSize		equ 10
FlatFloor		equ 0

TallFloor		equ 1
TallFloorHeightRangeMin	equ 40
TallFloorHeightRangeMax	equ 65
TallFloorWidthRangeMin	equ 40
TallFloorWidthRangeMax	equ 70
TallLowerFlatLength	equ 50
TallUpperFlatLength	equ 50

LavaFloor		equ 2
LavaHeight		equ 25
LavaColor		equ 41
LavaLowerFlatLength	equ 20
LavaLength		equ (160 - LavaLowerFlatLength * 2 - FloorSize * 2)
LavaUpperWidthRangeMin  equ 20
LavaUpperWidthRangeMax  equ (LavaLength - 20)
LavaUpperHeightRangeMin equ 80
LavaUpperHeightRangeMax equ 105
LavaWallsHeight		equ 45

MaxHVelocity		equ 15
MaxHDelay		equ 17
MaxVVelocity		equ 8
MaxVDelay		equ 9

False			equ 0
True			equ 1

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
MapData1	 dw 0, 0, 0
MapData2	 dw 0, 0, 0

PlayerPic db 53,53,53,53,53,53,53,53,53,53,53,53,53
          db 53,53,53,17,17,18,18,17,17,53,53,53,53
          db 53,53,17,18,18,18,226,18,18,53,53,53,53
          db 53,53,17,18,226,226,226,18,226,17,53,53,53
          db 53,17,18,18,129,226,226,17,17,18,17,53,53
          db 53,17,17,18,129,18,18,17,90,18,17,53,53
          db 53,17,18,18,226,18,17,90,90,17,17,53,53
          db 53,17,17,90,65,90,136,65,90,18,53,53,53
          db 53,17,17,90,65,90,11,18,90,53,53,53,53
          db 53,53,53,18,90,90,90,90,90,53,53,53,53
          db 53,53,22,24,64,65,90,65,136,53,53,53,53
          db 53,17,27,30,17,136,136,136,209,53,53,53,53
          db 53,17,22,24,22,17,140,140,140,53,53,53,53
          db 53,19,17,17,17,138,140,140,140,53,53,53,53
          db 53,22,28,27,138,138,164,164,164,53,53,53,53
          db 53,53,22,25,15,15,28,28,22,53,53,53,53
          db 53,53,17,24,15,14,17,28,225,53,53,53,53
          db 53,53,53,138,42,66,17,138,185,53,53,53,53
          db 53,53,18,185,185,185,18,172,172,53,53,53,53
          db 53,53,145,26,18,18,53,145,172,53,53,53,53
          db 53,25,17,17,53,53,53,53,17,27,30,19,53
          db 53,8,24,19,53,53,53,53,17,24,28,17,53
          db 53,17,19,25,53,53,53,53,53,17,53,53,53
          db 53,53,53,53,53,53,53,53,53,53,53,53,53

PlayerHeight            equ 24
PlayerWidth             equ 13

PlayerX          	dw ?
PlayerY          	dw ?
PlayerDead	 	db 0

PlayerXDelta	 	dw 0
PlayerHVelocity	 	dw 0
CurrentHDelay	 	dw 0
PlayerStop	 	db 0

PlayerVVelocity	 	dw 0
CurrentVDelay	 	dw 0
PlayerJumpMaxY		dw 0
PlayerJumping	 	db 0
PlayerStopJumping  	db 0
PlayerOnGround 		db 1

OpeningFileName  	db 'open.pcx'
OpeningNameLen   	equ 8

MenuFileName     	db 'menu.pcx'
MenuNameLen      	equ 8

DotPic  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
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

DotPicWidth		    equ 15
DotPicHeight		    equ 15
DotJump			    equ 33
DotStartX		    equ 105
DotStartY		    equ 75

DotOffset		    dw 0
OptionSelected		    db 1

UpArrowScanCode		    equ 72
DownArrowScanCode	    equ 80
RightArrowScanCode	    equ 77
LeftArrowScanCode	    equ 75
ReleasedRightArrowScanCode  equ 11001101b
ReleasedLeftArrowScanCode   equ 11001011b
EnterScanCode		    equ 28
SpaceScanCode		    equ 57

ScanCode		    dw ?

HelpText		    db "Get help here!", 13, 10, '$'
AboutText		    db "Made by Almog Hamdani!", 13, 10, '$'

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
        mov [Y], DotStartY

        mov ax, [DotOffset]
        add [Y], ax

        ; Set dot' size
        mov cx, DotPicHeight
        mov dx, DotPicWidth

        lea si, [DotPic] ; Set dot pic offset

        call PrintSprite ; Print dot

CheckArrows:
        ; Get input from keyboard
        xor ah, ah
        int 16h

        cmp ah, EnterScanCode ; Check if enter is pressed
        je JumpToSelected

        cmp ah, UpArrowScanCode ; Check if up arrow was pressed
        je HandleUp

        cmp ah, DownArrowScanCode ; Check if down arrow was pressed
        je HandleDown

        jmp CheckArrows

HandleUp:
        ; If current option is the first, don't go up
        cmp [OptionSelected], 1
        je CheckArrows

        ; Set dot' position
        mov [X], dotStartX
        mov [Y], DotStartY

        mov ax, [DotOffset]
        add [Y], ax

        ; Set dot' size
        mov cx, DotPicHeight
        mov dx, DotPicWidth

        call ClearSprite

        dec [OptionSelected] ; Set option to be the previous
        sub [DotOffset], DotJump ; Set currect offset

        jmp PrintSelectDot ; Print dot again

HandleDown:
        ; If current option is the last, don't go down
        cmp [OptionSelected], 4
        je CheckArrows

        ; Set dot' position
        mov [X], dotStartX
        mov [Y], DotStartY

        mov ax, [DotOffset]
        add [Y], ax

        ; Set dot' size
        mov cx, DotPicHeight
        mov dx, DotPicWidth

        call ClearSprite

        inc [OptionSelected] ; Set option to be the next
        add [DotOffset], DotJump ; Set currect offset

        jmp PrintSelectDot ; Print dot again

JumpToSelected:
        ; Jump to the selected option

        ; Set text mode
        mov ax, 13h
        int 10h

        cmp [OptionSelected], 1
        je StartGame

        cmp [OptionSelected], 2
        je ShowHelp

        cmp [OptionSelected], 3
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
;-----	Initialize variables
	mov [PlayerDead], 0

	; Reset parts
	mov [MapOrder], FlatFloor
	mov [MapOrder + 1], FlatFloor
	mov [MapOrder + 2], FlatFloor

	; Reset offsets
	mov [MapOffset], 0
	mov [MapOffset + 2], MidScreen
	mov [MapOffset + 4], EndScreen

	; Reset data
	mov [MapData1], 0
	mov [MapData1 + 2], 0
	mov [MapData1 + 4], 0

;-----	Game
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

;----- 	Check if the player is dead
	cmp [PlayerDead], True
	je @@Return

        cmp al, SpaceScanCode
        je @@JumpCheck

;-----	Checking if escapse is pressed, for now it's leaving the game
	dec al
	jz @@Return

@@Normal:
;----- 	Calling all movement functions because they all know how to handle according to boolean variables
	call StopPlayer
	call PlayerJump
	call PlayerStopJump
	call PlayerGravity

        DrawPlayer

        jmp @@Key

@@JumpCheck:
;-----	Check if the player is on the ground, if it isn't skip the jump to prevent multiple jumps and bugs.
	cmp [PlayerOnGround], True
	jne @@Normal ; Return if not on ground

;-----	Check if the current y + jump height is after max y
	mov dx, [PlayerY]
	sub dx, PlayerJumpHeight

	cmp dx, MaxY
	jge @@Jump

	mov dx, MaxY ; Set max jump y as max y

@@Jump:
	mov [PlayerJumpMaxY], dx ; Set the jump max as dx, defined before
        mov [PlayerJumping], True
	mov [PlayerOnGround], False

        jmp @@Normal ; Do as normal as well

@@Return:
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
;       None
;------------------------
PROC PrintMap
	; Draw 2 flat parts
	DrawRect 0, FloorY, MidScreen, FloorSize, FloorColor
	DrawRect MidScreen, FloorY, MidScreen, FloorSize, FloorColor
	ret
ENDP PrintMap

;------------------------
;TallPartRandomHeight - Creating a random height for the tall part
;------------------------
;Input:
;       BX <- Min, CX <- Max, Temp <- The part' number, DI <- The pointer to the data
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
	shl [Temp], 1 ; Mul by 2
	add di, [Temp] ; Temp holds the current part number
	shr [Temp], 1 ; Return original value, divide by 2

	mov [di], dx

	ret
ENDP RandomData

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
	mov ax, [MapData1 + 2]
	mov [MapData1], ax

	mov ax, [MapData1 + 4]
	mov [MapData1 + 2], ax

;-----	Move all parts' data by 1 backwards and randomize the new one
	mov ax, [MapData2 + 2]
	mov [MapData2], ax

	mov ax, [MapData2 + 4]
	mov [MapData2 + 2], ax

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
	lea di, [MapData1] ; Set pointer to data
	mov [Temp], 2
	mov bx, TallFloorHeightRangeMin ; Set min
	mov cx, TallFloorHeightRangeMax ; Set max
	call RandomData

;-----	Get a random width for the new part
	lea di, [MapData2] ; Set pointer to data
	mov [Temp], 2
	mov bx, TallFloorWidthRangeMin ; Set min
	mov cx, TallFloorWidthRangeMax ; Set max
	call RandomData

	jmp @@ResetOffsets

@@Lava:
;-----	Get a random height for the new part
	lea di, [MapData1] ; Set pointer to data
	mov [Temp], 2
	mov bx, LavaUpperHeightRangeMin ; Set min
	mov cx, LavaUpperHeightRangeMax ; Set max
	call RandomData

;-----	Get a random width for the new part
	lea di, [MapData2] ; Set pointer to data
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
;-----	Set x
	mov ax, [bx]
	add ax, TallLowerFlatLength + 1

;-----	Set di to point to current map info (height)
	lea di, [MapData1]
	shl [Temp], 1 ; Mul by 2
	add di, [Temp] ; Temp holds the current part number
	shr [Temp], 1 ; Return original value, divide by 2

;-----	Set y
	mov cx, FloorY
	sub cx, [di]

;-----	Set di to point to current map info (width)
	lea di, [MapData2]
	shl [Temp], 1 ; Mul by 2
	add di, [Temp] ; Temp holds the current part number
	shr [Temp], 1 ; Return original value, divide by 2

;-----	Set hole size
	mov dx, [di]

	DrawRect ax, cx, 1, FloorSize, FloorColor ; Add a part

	add ax, dx ; Set x as in the end of the hole which is the length of the upper part

	DrawRect ax, cx, 1, FloorSize, GameBackgroundColor ; Remove a part

;-----	Set y as the floor y and remove a part there to create the hole
	mov cx, FloorY

	DrawRect ax, cx, 1, FloorSize, FloorColor ; Add a part

	sub ax, dx ; Return x to start of hole

	DrawRect ax, cx, 1, FloorSize, GameBackgroundColor ; Remove a part

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
;-----	Adding a part before first wall
	mov ax, [bx]
	add ax, LavaLowerFlatLength + 1 ; Set x

	mov dx, FloorY - LavaWallsHeight - 1 ; Set y as under the first flat

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

;-----	Set di to point to current map info and get the width of the upper part
	lea di, [MapData2]
	shl [Temp], 1 ; Mul by 2
	add di, [Temp] ; Temp holds the current part number
	shr [Temp], 1 ; Return original value, divide by 2

;-----	Add a part in the upper flat
	; Setting start x
	mov ax, [bx] ; Get part' offset
	add ax, LavaLowerFlatLength + FloorSize + LavaLength / 2 ; Set x in the middle of the lava
	mov cx, [di] ; Set upper length
	shr cx, 1 ; Div the length by 2
	sub ax, cx ; Set the x axis of the upper flat (Middle Lava - Upper length / 2)
	shl cx, 1 ; Return original value

	mov dx, FloorY ; Set y axis as the floor

;-----	Set di to point to current map info and get the height of the upper part
	lea di, [MapData1]
	shl [Temp], 1 ; Mul by 2
	add di, [Temp] ; Temp holds the current part number
	shr [Temp], 1 ; Return original value, divide by 2

	sub dx, [di] ; Set the y as the floor height - the height of the upper flat

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
;	PlayerJumping <- 1 To start jumping or 0 otherwise
;Output:
;       The player to jump
;Registers:
;       DX
;------------------------
PROC PlayerJump
;-----	Check if need to jump, if not return, else continue
	cmp [PlayerJumping], False
	je @@Return

;-----	Set in dx, the current delay(max delay - currrent velocity)
	mov dx, MaxVDelay
	sub dx, [PlayerVVelocity]

;-----	Check if the current delay reached the needed delay, if it didn't increase and return, else continue
	cmp dx, [CurrentVDelay]
	je @@VelocityCheck

;-----	Increase and return
	inc [CurrentVDelay]
	ret

@@VelocityCheck:
;-----	Resetting the current delay
	mov [CurrentVDelay], 0

;-----	Check if reached max velocity, if reached just move without increasing speed, else continue
	cmp [PlayerVVelocity], MaxVVelocity
	je @@Jump

	inc [PlayerVVelocity] ; Increasing velocity

@@Jump:
        dec [PlayerY] ; Jumping

;-----	Changed if reached the max y jump
	mov dx, [PlayerJumpMaxY]
        cmp [PlayerY], dx
	je @@StopJumping

@@Return:
	ret

@@StopJumping:
	mov [PlayerJumping], False ; Stop jumping
	mov [PlayerStopJumping], True ; Make player to stop jumping smoothly
	jmp @@Return
ENDP PlayerJump

;------------------------
;PlayerStopJump - This is making the player to stop jumping smoothly
;------------------------
;Input:
;	PlayerStopJump <- 1 To stop jumping or 0 otherwise
;Output:
;       The player to stop jumping
;Registers:
;       DX
;------------------------
PROC PlayerStopJump
;-----	Check if need to stop jumping, if not return, else continue
	cmp [PlayerStopJumping], False
	je @@Return

;-----	Set in dx, the current delay(max delay - currrent velocity)
	mov dx, MaxVDelay
	sub dx, [PlayerVVelocity]

;-----	Check if the current delay reached the needed delay, if it didn't increase and return, else continue
	cmp dx, [CurrentVDelay]
	je @@VelocityCheck

;-----	Increase and return
	inc [CurrentVDelay]
	ret

@@VelocityCheck:
;-----	Resetting the current delay
	mov [CurrentVDelay], 0

;-----	Check if reached zero velocity, if reached stop, else continue
	cmp [PlayerVVelocity], 0
	je @@StopJumping

	dec [PlayerVVelocity] ; Decreasing velocity

@@Jump:
        dec [PlayerY] ; Jumping

        cmp [PlayerY], MaxY ; Changed if reached the top
	je @@StopJumping

@@Return:
	ret

@@StopJumping:
	mov [PlayerStopJumping], False ; Make player to stop jumping smoothly
	jmp @@Return
ENDP PlayerStopJump

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
;-----	Check if jumping, if yes, return, else continue
	cmp [PlayerJumping], False
	jne @@MidReturn

;-----	Check if stop to jumping, if stopping, return, else continue
	cmp [PlayerStopJumping], False
	jne @@MidReturn

;-----	Set in dx, the current delay(max delay - currrent velocity)
	mov dx, MaxVDelay
	sub dx, [PlayerVVelocity]

;-----	Check if the current delay reached the needed delay, if it didn't increase and return, else continue
	cmp dx, [CurrentVDelay]
	je @@VelocityCheck

;-----	Increase and return
	inc [CurrentVDelay]

@@MidReturn:
	ret

@@VelocityCheck:
;-----	Resetting the current delay
	mov [CurrentVDelay], 0

;-----	Check if reached max velocity, if reached just move without increasing speed, else continue
	cmp [PlayerVVelocity], MaxVVelocity
	je @@Gravity

	inc [PlayerVVelocity] ; Increasing velocity

@@Gravity:
;-----	Check if reached floor, first point, start of player
        mov ax, [PlayerX]
        mov [X], ax

        mov ax, [PlayerY]
        add ax, PlayerHeight + PlayerFloorDist
        mov [Y], ax

        call GetPixel
        cmp [Color], FloorColor

	je @@StopGravity

;-----	Check if reached floor, second point, middle of player
        mov ax, [PlayerX]
	add ax, PlayerWidth / 2
        mov [X], ax

        mov ax, [PlayerY]
        add ax, PlayerHeight + PlayerFloorDist
        mov [Y], ax

        call GetPixel
        cmp [Color], FloorColor

	je @@StopGravity

;-----	Check if reached floor, third point, end of player
        mov ax, [PlayerX]
	add ax, PlayerWidth
        mov [X], ax

        mov ax, [PlayerY]
        add ax, PlayerHeight + PlayerFloorDist
        mov [Y], ax

        call GetPixel
	cmp [Color], FloorColor

	je @@StopGravity

	mov [PlayerOnGround], False ; Set player to be not on ground, just found it using the conditions

	inc [PlayerY] ; Go down

@@Return:
        ret

@@StopGravity:
	mov [PlayerVVelocity], 0 ; Reset velocity
	mov [CurrentVDelay], 0 ; Reset MaxHDelay
	mov [PlayerOnGround], True

	jmp @@Return
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
	push ax ; Save al for restore later

;-----	Check if the right arrow is pressed
        cmp al, RightArrowScanCode
        je @@MoveRight

;-----	Check if the left arrow is pressed
        cmp al, LeftArrowScanCode
        je @@MoveLeft

;-----	Check if the left arrow is released
	cmp al, ReleasedLeftArrowScanCode
	je @@StopMoving

;-----	Check if the left arrow is released
	cmp al, ReleasedRightArrowScanCode
	je @@StopMoving

        jmp @@Return

@@MoveRight:
	mov [PlayerXDelta], 1 ; Set delta, go right
	call CheckIfReachedWall

	call MovePlayer
	jmp @@Return

@@MoveLeft:
        mov [PlayerXDelta], -1 ; Set delta, go left
	call CheckIfReachedWall

	call MovePlayer
	jmp @@Return

@@StopMoving:
	mov [PlayerStop], True

@@Return:
	pop ax ; Restore al to be used for checks later
	ret
ENDP CheckPlayerMove

PROC MovePlayer
;-----	Check if have delta x
	cmp [PlayerXDelta], 0
	je @@Return

;-----	Set in dx, the current delay(max delay - currrent velocity)
	mov dx, MaxHDelay
	sub dx, [PlayerHVelocity]

;-----	Check if the current delay reached the needed delay, if it didn't increase and return, else continue
	cmp dx, [CurrentHDelay]
	je @@VelocityCheck

;-----	Increase and return
	inc [CurrentHDelay]
	ret

@@VelocityCheck:
;-----	Resetting the current delay
	mov [CurrentHDelay], 0

;-----	Check if reached max velocity, if reached just move without increasing speed, else continue
	cmp [PlayerHVelocity], MaxHVelocity
	je @@MapCheck

	inc [PlayerHVelocity] ; Increasing velocity

@@MapCheck:
	cmp [PlayerX], EndScreen / 2 - PlayerWidth / 2 ; Check if player in middle of screen, if it is, move map
	je @@Map

@@Move:
	mov dx, [PlayerXDelta]
        add [PlayerX], dx ; Move player according to the delta
	jmp @@Return

@@Map:
;-----	Check if the player is going right, if it is so move map, else just regular move
	cmp [PlayerXDelta], 1
	jne @@Move

;-----	Move map and fix it on the screen
	call MoveMap
	call FixMap
	jmp @@Return

@@Return:
	ret
ENDP MovePlayer

PROC CheckIfReachedWall
;-----	Check if moving right
	cmp [PlayerXDelta], 1
	je @@Right

;-----	Check if moving left
	cmp [PlayerXDelta], -1
	je @@Left

	jmp @@Return

@@Right:
;-----	Check if reached wall
        mov dx, [PlayerX]
	add dx, PlayerWidth + DistanceFromWall
        mov [X], dx

        mov dx, [PlayerY]
	add dx, PlayerHeight ; Bottom point
        mov [Y], dx

        call GetPixel
	cmp [Color], FloorColor
	je @@Stop

	jmp @@Return

@@Left:
	cmp [PlayerX], MinX + DistanceFromWall
	je @@Stop

;-----	Check if reached wall
        mov dx, [PlayerX]
	sub dx, DistanceFromWall
        mov [X], dx

        mov dx, [PlayerY]
	add dx, PlayerHeight ; Bottom point
        mov [Y], dx

        call GetPixel
	cmp [Color], FloorColor
	je @@Stop

	jmp @@Return

@@Stop:
	mov [PlayerStop], False ; Setting player to be stopped
	mov [PlayerXDelta], 0 ; Resetting delta x
	mov [PlayerHVelocity], 0 ; Reset velocity
	mov [CurrentHDelay], 0 ; Reset delay

@@Return:
	ret
ENDP CheckIfReachedWall

PROC StopPlayer
	call CheckIfReachedWall

;-----	Check if should stop player, if shouldn't return, else continue
	cmp [PlayerStop], False
	je @@Return

;-----	Set in dx, the current delay(max delay - currrent velocity)
	mov dx, MaxHDelay
	sub dx, [PlayerHVelocity]

;-----	Check if the current delay reached the needed delay, if it didn't increase and return, else continue
	cmp dx, [CurrentHDelay]
	je @@VelocityCheck

;-----	Increase and return
	inc [CurrentHDelay]
	ret

@@VelocityCheck:
;-----	Resetting the current delay
	mov [CurrentHDelay], 0

;-----	Check if reached zero velocity, if reached stop, else continue
	cmp [PlayerHVelocity], 0
	je @@Stop

	dec [PlayerHVelocity] ; Decreasing velocity

@@MapCheck:
	cmp [PlayerX], EndScreen / 2 - PlayerWidth / 2 ; Check if player in middle of screen, if it is, move map
	je @@Map

@@Move:
	mov dx, [PlayerXDelta]
        add [PlayerX], dx ; Move player according to the delta
	jmp @@Return

@@Map:
;-----	Check if the player is going right, if it is so move map, else just regular move
	cmp [PlayerXDelta], 1
	jne @@Move

;-----	Move map and fix it on the screen
	call MoveMap
	call FixMap
	jmp @@Return

@@Stop:
	mov [PlayerStop], False ; Setting player to be stopped
	mov [PlayerXDelta], 0 ; Resetting delta x
	mov [PlayerHVelocity], 0 ; Reset velocity
	mov [CurrentHDelay], 0 ; Reset delay

@@Return:
	ret
ENDP StopPlayer

PROC Help

        ; Print text
        mov dx, offset HelpText
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
        mov dx, offset AboutText
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
