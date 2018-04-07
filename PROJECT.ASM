;------------------------------------------
; PURPOSE : Final Project - Key Breaker
; SYSTEM  : Turbo Assembler Ideal Mode
; AUTHOR  : Almog Hamdani
;------------------------------------------

		%TITLE "Key Breaker"

		IDEAL

		MODEL small

		STACK 256

		P386

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
;       AX, DX, ES, SI, DI, CX
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

	pusha
        call DrawRectangle
	popa
ENDM DrawRect

;------------------------
; FillArray - Fills an array with a specific value
;------------------------
; Input:
;       Array, Value, Len, Size <- The size of each element in the array, Offset <- The distance from each element to element
; Output:
;       The values in the array
; Registers:
;       DI, CX
;------------------------
MACRO FillArray Array, Value, Len, Size, Offset
	local ValueLoop
	lea di, [Array] ; Point to array
	mov cx, Len ; Set the amount of values to be changed

ValueLoop:
	mov [Size di], Value ; Set the value

	add di, Offset
	loop ValueLoop
ENDM FillArray

;------------------------
; PrintStringWithNumbers - Fills an array with a specific value
;------------------------
; Input:
;       String <- The name of the string var
;	Number <- The name of the number var
;	BG <- The background color
;	FG <- The foreground color
;	Numoffset <- Where to put the number in the string
;	MinChars <- Minimum amount of characters
;	Position: X, Y
; Output:
;       The values in the array
; Registers:
;       DI, CX
;------------------------
MACRO PrintStringWithNumbers String, Number, BG, FG, NumOffset, MinChars, X, Y
;-----	Copy the number to the string by converting it
	lea si, [String]
	add si, NumOffset ; Set where to set the score in the string
	mov ax, [Number]
	mov bp, MinChars ; Minimum amount of chars
	call NumberToString
	mov [byte si], 0 ; Set end of the string

;-----	Print the string onto the screen
	lea si, [String]
	mov dl, BG ; Background color
	mov dh, FG ; Foreground color

;-----	Set position of the text
	mov [StartX], X
	mov [StartY], Y

	call PrintColorfulText
ENDM PrintStringWithNumbers

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
        mov [StartX], ax

        mov ax, [PlayerY]
        mov [StartY], ax

;-----	Set the size of the player
        mov [SizeHeight], PlayerHeight
        mov [SizeWidth], PlayerWidth

        lea si, [PlayerPic]

;-----	Calculate the frame offset using mul with the current frame and the size of each frame
	xor ax, ax
	mov al, [PlayerCurrentFrame]
	xor dx, dx
	mov cx, PlayerHeight * PlayerWidth
	mul cx

	add si, ax

;-----	Set whatever the player should be drawn flipped
	mov al, [PlayerFlipped]
	mov [ImageFlipped], al

	clc ; Clear carry flag so that the function won't check for overflow and negetive position
        call PrintSprite
ENDM

;----Constants-----

PlayerMaxFrameDelay	    equ 7

DotJump			    equ 33
DotStartX		    equ 105
DotStartY		    equ 75

ScreenWidth		    equ 320
GameBackgroundColor         equ 53
FloorY                      equ 150
DistanceFromWall	    equ 5
MidScreen		    equ 160
EndScreen		    equ 320
MaxX			    equ (ScreenWidth - PlayerWidth)
MinX			    equ 0
MaxY			    equ 20

PlayerFloorDist		    equ 0
PlayerJumpHeight	    equ (100 - PlayerHeight)

FloorColor		    equ 15
FloorSize		    equ 10
FlatFloor		    equ 1
FlatFloorCoinXRangeMin	    equ 20
FlatFloorCoinXRangeMax	    equ MidScreen - 20
FlatFloorCoinYRangeMin	    equ (FloorY - PlayerJumpHeight) + 20
FlatFloorCoinYRangeMax	    equ (FloorY - CoinMinDist - CoinPicHeight)

TallFloor		    equ 3
TallFloorHeightRangeMin	    equ 40
TallFloorHeightRangeMax	    equ 65
TallFloorWidthRangeMin	    equ 40
TallFloorWidthRangeMax	    equ 70
TallLowerFlatLength	    equ 50
TallUpperFlatLength	    equ 50

LavaFloor		    equ 5
LavaHeight		    equ 25
LavaColorRangeStart	    equ 40
LavaColorRangeEnd	    equ 42
LavaColorBlocksChange	    equ 2
LavaLowerFlatLength	    equ 20
LavaLength		    equ (160 - LavaLowerFlatLength * 2 - FloorSize * 2)
LavaUpperWidthRangeMin      equ 20
LavaUpperWidthRangeMax      equ (LavaLength - 20)
LavaUpperHeightRangeMin     equ 80
LavaUpperHeightRangeMax     equ 105
LavaWallsHeight		    equ 45

MaxHVelocity		    equ 15
MaxHDelay		    equ 19
MaxVVelocity		    equ 8
MaxVDelay		    equ 10

False			    equ 0
True			    equ 1

ScoreX			    equ 5
ScoreY			    equ 5

TimeX			    equ (ScreenWidth - 45)
TimeY			    equ 5

CoinsX			    equ (ScreenWidth - 90)
CoinsY			    equ 5

EscapeScanCode		    equ 1
RScanCode		    equ 13h
UpArrowScanCode		    equ 72
DownArrowScanCode	    equ 80
RightArrowScanCode	    equ 77
LeftArrowScanCode	    equ 75
ReleasedRightArrowScanCode  equ 11001101b
ReleasedLeftArrowScanCode   equ 11001011b
EnterScanCode		    equ 28
SpaceScanCode		    equ 57

AnimationCountMax	    equ 15
CoinMinDist		    equ 5

KeyRangeStart		    equ 0
KeyRangeEnd		    equ 9

GameMenuInfoX		    equ MidScreen - 70
GameMenuInfoY		    equ MidScreen - 55

CurrentDigitTextX	    equ GameMenuInfoX
CurrentDigitTextY	    equ GameMenuInfoY

TargetScoreTextX	    equ GameMenuInfoX
TargetScoreTextY	    equ CurrentDigitTextY + 13

TargetCoinsTextX	    equ GameMenuInfoX
TargetCoinsTextY	    equ TargetScoreTextY + 13

TotalScoreTextX	    	    equ GameMenuInfoX
TotalScoreTextY	    	    equ TargetCoinsTextY + 25

DigitTimeY		    equ 80

CoinYellowColor		    equ 42
WhiteColor		    equ 15
GameMenuBGColor		    equ 21
RedColor		    equ 40

CoinValue		    equ 2
CoinBorderColor		    equ 0

KeyBorderColor		    equ 17

KeyInitialX		    equ EndScreen + MidScreen + 20
KeyInitialY		    equ FloorY - KeyPicHeight - 10

;------------------

		DATASEG

PCXErrorMSG      	db 'An error occurred during drawing PCX file! Please try again!$'
FileHandle       	dw ?
FileName         	db 100 dup (?)
FileSize         	dw ?
ImageHeight      	dw ?
ImageWidth       	dw ?
ImageFlipped		db False
StartX           	dw ?
StartY           	dw ?

X                	dw ?
Y                	dw ?
Color            	db ?

SizeHeight       	dw ?
SizeWidth        	dw ?
SkipColumns		dw 0

Temp             	dw ?
TempByte	 	db ?

MapOrder	 	db FlatFloor, FlatFloor, FlatFloor
MapOffset	 	dw 0, MidScreen, EndScreen
MapData1	 	dw 0, 0, 0
MapData2	 	dw 0, 0, 0
MapCoin			db False, False, False
MapCoinX		dw 0, 0, 0
MapCoinY		dw 0, 0, 0

LavaColorBlocksCounter  db 0
LavaCurrentColor	db LavaColorRangeStart
LavaCurrentColorOffset  db 1

PlayerFrameCurrentDelay db 0
PlayerCurrentFrame	db 0

PlayerFlipped		db False
PlayerX          	dw ?
PlayerY          	dw ?
PlayerDead	 	db False

PlayerXDelta	 	dw 0
PlayerHVelocity	 	dw 0
CurrentHDelay	 	dw 0
PlayerStop	 	db False

PlayerVVelocity	 	dw 0
CurrentVDelay	 	dw 0
PlayerJumpMaxY		dw 0
PlayerJumping	 	db False
PlayerStopJumping  	db False
PlayerOnGround 		db True

OpeningFileName  	db 'visuals\open.pcx$'
OpeningNameLen   	equ 17

MenuFileName     	db 'visuals\menu.pcx$'
MenuNameLen      	equ 17

LostFileName		db 'visuals\lost.pcx$'
LostNameLen		equ 17

GameMenuFileName 	db 'visuals\game.pcx$'
GameMenuNameLen		equ 17

DigitUnlockFileName 	db 'visuals\digit.pcx$'
DigitUnlockNameLen	equ 17

WinFileName 		db 'visuals\win.pcx$'
WinNameLen		equ 17

DotOffset		dw 0
OptionSelected		db 1

ScanCode		dw ?

HelpText		db "Get help here!", 13, 10, '$'
AboutText		db "Made by Almog Hamdani!", 13, 10, '$'

Score 			dw 0
ScoreText		db "Score: ", 20 dup(0)

Time 			dw 0
TimeText		db 20 dup(0)

Coins			dw 0
CoinsText		db 20 dup(0)

TextBitmap		dw 4 dup(?)

PreviousSeconds 	db 0

AnimationCounter	db 0
CoinFrame		dw 0

Key			dw 6 dup(0)
KeyUnlocked		db True, 5 dup(True)
KeyTimes		dw 6 dup(?)

TargetScore		dw 150
TargetScoreText		db 'Target score : ', 10 dup(?)

TargetCoins		dw 15
TargetCoinsText		db 'Target coins : ', 10 dup(?)

CurrentDigitText	db 'Current digit: ', 5 dup(?)
CurrentDigit		dw 1

TotalScore		dw 0
TotalScoreText		db 'Total score  : ', 10 dup (?)

DigitX			dw ?
DigitY			dw ?

GameScoreRangeStart	dw 10, 20, 80, 90, 160, 170
GameScoreRangeEnd	dw 50, 80, 160, 180, 270, 300

GameCoinsRangeStart	dw 5, 10, 15, 20, 25, 30
GameCoinsRangeEnd	dw 10, 20, 30, 40, 50, 60

KeyX			dw KeyInitialX
KeyY			dw KeyInitialY

KeyFound		db False
PlayerFinishedLevel	db False

KeyDigitFileName	db 'digits\0.pcx$'
KeyDigitNameDigitOffset equ 7
KeyDigitNameLen		equ 13

QuestionMarkFilename	db 'digits\ques.pcx$'
QuestionMarkNameLen	equ 16

INCLUDE 'PICS.INC'

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
        mov [StartX], dotStartX
        mov [StartY], DotStartY

        mov ax, [DotOffset]
        add [StartY], ax

        ; Set dot' size
        mov [SizeHeight], DotPicHeight
        mov [SizeWidth], DotPicWidth

        lea si, [DotPic] ; Set dot pic offset

	clc ; Clear carry flag so that the function won't check for overflow and negetive position
	mov [ImageFlipped], False
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
;-----	Set text mode
        mov ax, 13h
        int 10h

;-----	Jump to the selected option
        cmp [OptionSelected], 1
        je StartGame

        cmp [OptionSelected], 2
        je ShowHelp

        cmp [OptionSelected], 3
        je ShowAbout

        jmp Exit

StartGame:
        call GameMenu
	jmp PrintMenu

ShowHelp:
        call Help
	jmp PrintMenu

ShowAbout:
        call About
	jmp PrintMenu

Exit:
;-----  Set text mode
        mov ax, 3h
        int 10h

        ; Exit
        mov ax, 4C00h
        int 21h

;----------PROC----------

;------------------------
;GameMenu - This is handling the menu of the game.
;------------------------
;Input:
;       None
;Output:
;       The game and it's menu
;Registers:
;       AX, SI
;------------------------
PROC GameMenu
;-----	Initialize variables
	mov [TotalScore], 0
	mov [CurrentDigit], 1
	FillArray KeyUnlocked, False, 6, byte, 1
	FillArray KeyTimes, 100, 6, word, 2

;-----	Randomize key
	call RandomizeKey

@@DrawUI:
;-----	Print the game menu picture
	CopyString GameMenuFileName, FileName, GameMenuNameLen
	mov [StartX], 0
	mov [StartY], 0
	call DrawPCX

;-----	Print UI
	call DrawKeyNumbers
	call RandomizeDigitInfo
	call DrawCurrentDigitInfo

@@GetKey:
;-----	Wait for keyboard press
	xor ah, ah
	int 16h

;-----	Check if enter is pressed
	cmp ah, EnterScanCode
	je @@StartGame

;-----	If escape is pressed, return to main menu
	cmp ah, EscapeScanCode
	je @@Return

	jmp @@GetKey

@@StartGame:
	call Game

;-----	Clean keyboard buffer
	mov ah, 0Ch
	mov al, 0
	int 21h

;-----	Check if the key was found, if it is found, reveal the digit, else just return to menu
	cmp [KeyFound], True
	je @@AfterGame

	jmp @@DrawUI

@@AfterGame:
;-----	Print the digit unlock picture before adding the new one
	CopyString DigitUnlockFileName, FileName, DigitUnlockNameLen
	mov [StartX], 0
	mov [StartY], 0
	call DrawPCX

;-----	Wait for keyboard press
	xor ah, ah
	int 16h

;-----	Get offset for the digit
	mov si, [CurrentDigit] ; Get the current digit
	dec si ; The array of ranges is starting with 0
	mov [KeyUnlocked + si], True

;-----	Get the time that the level took for the user
	mov ax, 180
	sub ax, [Time]

	shl si, 1 ; Get the offset in words so mul by 2
	mov [KeyTimes + si], ax ; Set time
	inc [CurrentDigit] ; Move to next digit

;-----	Add score to total score
	mov ax, [Score]
	add [TotalScore], ax

	cmp [CurrentDigit], 6 + 1
	jge @@FinishGame

	jmp @@DrawUI

@@FinishGame:
;-----	Print the win picture
	CopyString WinFileName, FileName, WinNameLen
	mov [StartX], 0
	mov [StartY], 0
	call DrawPCX

;-----	Printing keys and total score
	call DrawKeyNumbers
	PrintStringWithNumbers TotalScoreText, TotalScore, GameMenuBGColor, RedColor, 15, 0, TotalScoreTextX, TotalScoreTextY

;-----	Wait for keyboard press
	xor ah, ah
	int 16h


@@Return:
	ret
ENDP GameMenu

;------------------------
;RandomizeDigitInfo - This is giving a random score and coins based on the specific digit (level)
;------------------------
;Input:
;       None
;Output:
;       TargetScore and TargetCoins for the level
;Registers:
;       BX, CX, SI, DI
;------------------------
PROC RandomizeDigitInfo
;-----	Get offset
	mov si, [CurrentDigit] ; Get the current digit
	dec si ; The array of ranges is starting with 0
	shl si, 1 ; Get the offset in words so mul by 2

;-----	Get random score for level
	mov bx, [GameScoreRangeStart + si] ; Min
	mov cx, [GameScoreRangeEnd + si] ; Max
	lea di, [TargetScore]
	call RandomData

;-----	Get random coins for level
	mov bx, [GameCoinsRangeStart + si] ; Min
	mov cx, [GameCoinsRangeEnd + si] ; Max
	lea di, [TargetCoins]
	call RandomData

	ret
ENDP RandomizeDigitInfo

;------------------------
;PrintTimeForDigit - This is drawing the time for a given digit
;------------------------
;Input:
;       SI <- Pointer to the current digit in key
;Output:
;       The time under the digit
;Registers:
;       AX, CX, DX, BP, SI
;------------------------
PROC PrintTimeForDigit
;-----	Get the time for the digit
	sub si, offset Key ; Get the offset of the current key
	add si, offset KeyTimes ; Add the var to the offset to get the time
	mov ax, [word si] ; Take the time

;-----	Get minutes and seconds from time
	xor dx, dx ; Reset dx for div
	mov cx, 60 ; Divide by 60 seconds
	div cx

;-----	Convert minutes to text
	push dx ; Save seconds
	mov bp, 2 ; Amount of chars
	lea si, [TimeText] ; Point to the text holder of the Time
	call NumberToString

	mov [byte si], ':' ; Put divider between minutes and seconds
	inc si

;-----	Convert minutes to text
	pop ax ; Get seconds from stack
	mov bp, 2 ; Amount of chars
	call NumberToString

	mov [byte si], 0 ; Set end of the string

;-----	Get the x for the time from the digit x
	mov ax, [DigitX]
	add ax, 5
	mov [StartX], ax

	mov [StartY], DigitTimeY

;-----	Print time
	lea si, [TimeText]
	mov dl, GameMenuBGColor ; Set text background
	mov dh, WhiteColor ; Set foreground color, red color
	call PrintColorfulText

@@Return:
	ret
ENDP PrintTimeForDigit

;------------------------
;DrawCurrentDigitInfo - This is drawing the info for the current digit (level) and the total score
;------------------------
;Input:
;       None
;Output:
;       The info on the screen
;Registers:
;       None
;------------------------
PROC DrawCurrentDigitInfo
	PrintStringWithNumbers CurrentDigitText, CurrentDigit, GameMenuBGColor, GameBackgroundColor, 15, 0, CurrentDigitTextX, CurrentDigitTextY
	PrintStringWithNumbers TargetScoreText, TargetScore, GameMenuBGColor, WhiteColor, 15, 0, TargetScoreTextX, TargetScoreTextY
	PrintStringWithNumbers TargetCoinsText, TargetCoins, GameMenuBGColor, CoinYellowColor, 15, 0, TargetCoinsTextX, TargetCoinsTextY
	PrintStringWithNumbers TotalScoreText, TotalScore, GameMenuBGColor, RedColor, 15, 0, TotalScoreTextX, TotalScoreTextY
	ret
ENDP DrawCurrentDigitInfo

;------------------------
;DrawKeyNumbers - This is drawing the digits of the key or ? if not unlocked yet
;------------------------
;Input:
;       None
;Output:
;       The digits or the ? on the screen in the key position
;Registers:
;       AX, BP, DI, SI
;------------------------
PROC DrawKeyNumbers
	lea di, [KeyUnlocked] ; Point to the array that contains the whatever the digit is unlocked or not
	lea si, [Key] ; Point to the current key' digit
	mov [Temp], 6 ; Move 6 times as there is 6 digits

;-----	Set first digit position
	mov [DigitX], 18
	mov [DigitY], 17

@@DigitLoop:
;-----	Check if the current digit is unlocked, if it is draw it
	cmp [byte di], True
	je @@DrawDigit

@@DrawQuestionMark:
;-----	Set position of the question mark to be drawn
	mov ax, [DigitX]
	mov [StartX], ax

	mov ax, [DigitY]
	mov [StartY], ax

;-----	Draw the question mark
	pusha
	CopyString QuestionMarkFilename, FileName, QuestionMarkNameLen ; Set the name of the file
	popa

	pusha
	call DrawPCX
	popa

	jmp @@LoopCheck

@@DrawDigit:
;-----	Set position of the question mark to be drawn
	mov ax, [DigitX]
	mov [StartX], ax

	mov ax, [DigitY]
	mov [StartY], ax

;-----	Get the file name for the digit
	pusha
	mov ax, [si] ; Take the current key' digit
	mov bp, 0 ; No need for leading zeros
	lea si, [KeyDigitFileName + KeyDigitNameDigitOffset] ; Get where to put the digit
	call NumberToString
	popa

;-----	Draw the digit
	pusha
	CopyString KeyDigitFileName, FileName, KeyDigitNameLen ; Set the name of the file
	popa

	pusha
	call DrawPCX
	popa

;-----	Print time for the digit
	pusha
	call PrintTimeForDigit
	popa

@@LoopCheck:
	add [DigitX], 47

	inc di
	add si, 2

;-----	Check if the finished 6 digits to print
	dec [Temp]
	jnz @@DigitLoop

	ret
ENDP DrawKeyNumbers

;------------------------
;RandomizeKey - This is getting a random key
;------------------------
;Input:
;       None
;Output:
;       The random key in the key var
;Registers:
;       AX, BX, CX, DI
;------------------------
PROC RandomizeKey
	lea di, [Key] ; Point to the key holder

@@GenerateKey:
;-----	Set min and max for the digit
	mov bx, KeyRangeStart
	mov cx, KeyRangeEnd

	call RandomData ; Generate random digit

	add di, 2 ; Move to next digit

;-----	Get the last byte that contains the key
	lea ax, [Key]
	add ax, 5 * 2

;-----	Loop the generator until finished 6 digits
	cmp di, ax
	jbe @@GenerateKey

	ret
ENDP RandomizeKey

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
@@InitGame:
;-----	Set video memory
	mov ax, 0A000h
	mov es, ax

;-----	Initialize variables
	mov [PlayerDead], False
	mov [Time], 180
	mov [Score], 0
	mov [Coins], 0

	mov [KeyFound], False
	mov [PlayerFinishedLevel], False

	mov [KeyX], KeyInitialX
	mov [KeyY], KeyInitialY

	mov [PlayerXDelta], 0
	mov [PlayerHVelocity], 0
	mov [CurrentHDelay], 0
	mov [PlayerStop], False

	mov [PlayerVVelocity], 0
	mov [CurrentVDelay], 0
	mov [PlayerJumpMaxY], 0
	mov [PlayerJumping], False
	mov [PlayerStopJumping], False
	mov [PlayerOnGround], True

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

	; Reset data
	mov [MapData2], 0
	mov [MapData2 + 2], 0
	mov [MapData2 + 4], 0

	; Reset data
	mov [MapCoin], False
	mov [MapCoin + 1], False
	mov [MapCoin + 1], False

;-----	Game
        ; Setting background color
        mov [Color], GameBackgroundColor
        call PaintScreen

;-----	Printing UI
	call PrintScore
	call PrintCoins
	call PrintTime

;-----	Printing the coin besides the coins amount
	mov [StartY], CoinsY - 3
	mov [StartX], CoinsX - CoinPicWidth - 3
	mov [SizeWidth], CoinPicWidth
	mov [SizeHeight], CoinPicHeight
	lea si, [CoinPic]
	clc ; Clear carry so that additional checks will not be executed
	mov [ImageFlipped], False ; Print the coin normal without flip
	call PrintSprite

;-----	Printing the time icon besides the coins amount
	mov [StartY], TimeY - 3
	mov [StartX], TimeX - TimePicWidth - 3
	mov [SizeWidth], TimePicWidth
	mov [SizeHeight], TimePicHeight
	lea si, [TimePic]
	clc ; Clear carry so that additional checks will not be executed
	mov [ImageFlipped], False ; Print the coin normal without flip
	call PrintSprite

	call PrintMap

;-----	Set player' position
	mov [PlayerFlipped], False
        mov [PlayerX], 50
        mov [PlayerY], FloorY - PlayerHeight - PlayerFloorDist

        DrawPlayer

;-----	Reset real time clock to 00:00:00
	mov ah, 03h
	xor cx, cx
	xor dx, dx
	int 1Ah

@@Loop:
	call AnimationHandler

;-----	Get real time clock
	mov ah, 02h
	int 1Ah

;-----	Check if the seconds were changed, if it wasn't, countinue, else, handle time
	cmp dh, [PreviousSeconds]
	je @@Key
	call TimeHandler

@@Key:
        call CheckPlayerMove

;----- 	Check if the player is dead
	cmp [PlayerDead], True
	je @@ShowLostPic

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
	call CheckPlayerDeath
	call CheckPlayerWin

;-----	If the key was found, return
	cmp [KeyFound], True
	je @@Return

        DrawPlayer

        jmp @@Loop

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

@@ShowLostPic:
;-----	Print the you lost picture
	CopyString LostFileName, FileName, LostNameLen
	mov [StartX], 0
	mov [StartY], 0

	call DrawPCX

;-----	Clear buffer
	mov ah,0ch
	mov al,0h
	int 21h

@@GetKey:
;-----	Get a key from the user
	xor ah, ah
	int 16h

;-----	Restart game
	cmp ah, RScanCode
	je @@InitGame

;-----	Return to menu
	cmp ah, EscapeScanCode
	je @@Return

	jmp @@GetKey
ENDP Game

PROC DrawKeyIfNeeded
;-----	Check if player finished the level
	cmp [PlayerFinishedLevel], True
	jne @@Return

;-----	Set position
	mov ax, [KeyX]
	mov [StartX], ax

	mov ax, [KeyY]
	mov [StartY], ax

;-----	Draw the key
	mov [SizeWidth], KeyPicWidth
	mov [SizeHeight], KeyPicHeight
	lea si, [KeyPic]
	stc ; Check for overflows
	call PrintSprite

	dec [KeyX]

@@Return:
	ret
ENDP DrawKeyIfNeeded

;------------------------
;CheckPlayerWin - This is checking if the player reached the target score and coins
;------------------------
;Input:
;       Score, Coins
;Output:
;       PlayerFinishedLevel <- If the player finished it is true, else false
;Registers:
;       None
;------------------------
PROC CheckPlayerWin
;-----	Check if player hasn't reached the target score yet
	mov ax, [TargetScore]
	cmp [Score], ax
	jl @@Return

;-----	Check if player hasn't reached the target coins yet
	mov ax, [TargetCoins]
	cmp [Coins], ax
	jl @@Return

@@Finished:
	mov [PlayerFinishedLevel], True
	ret

@@Return:
	mov [PlayerFinishedLevel], False
	ret
ENDP CheckPlayerWin

;------------------------
;CheckPlayerDeath - This is checking if the player should die (checking if fell of map)
;------------------------
;Input:
;       PlayerX, PlayerY
;Output:
;       PlayerDead <- Is the player dead or alive
;Registers:
;       None
;------------------------
PROC CheckPlayerDeath
	cmp [PlayerY], FloorY + 20
	jg @@PlayerDeath
	ret

@@PlayerDeath:
	mov [PlayerDead], True
	ret
ENDP CheckPlayerDeath

;------------------------
;AnimationHandler - This is handling the animations in the game (The spinning coin - gif)
;------------------------
;Input:
;       None
;Output:
;       The animation in the game
;Registers:
;       None
;------------------------
PROC AnimationHandler
;-----	Increase the animation delay counter until reached max
	inc [AnimationCounter]
	cmp [AnimationCounter], AnimationCountMax
	je @@Animate
	jmp @@Return

@@Animate:
	mov [AnimationCounter], 0

	call DrawCoinsForMap

;-----	Move to the next coin' frame
	inc [CoinFrame]
	cmp [CoinFrame], 6
	je @@ResetCoinFrame
	jmp @@Return

@@ResetCoinFrame:
	mov [CoinFrame], 0

@@Return:
	ret
ENDP AnimationHandler

;------------------------
;DrawCoinsForMap - This is drawing the coins in the map
;------------------------
;Input:
;       None
;Output:
;       The coins on the screen
;Registers:
;       AX, CX, SI, DI
;------------------------
PROC DrawCoinsForMap
;-----	Init
	lea si, [MapCoin]
	mov di, 0
	mov cx, 3 ; Only three parts on screen

@@CheckForCoin:
;-----	Checking if need to draw a coin in this current part
	cmp [byte si], True
	jne @@Next ; Skip the print

;----- 	Draw the wanted coin
	; Set the coin' x
	mov ax, [MapCoinX + di]
	add ax, [MapOffset + di] ; Add the part' offset
	mov [StartX], ax

	; Set the coin' y
	mov ax, [MapCoinY + di]
	mov [StartY], ax

;-----	Save registers
	pusha

	call DrawCoin

;-----	Return registers
	popa

@@Next:
	inc si ; Move to next map coin boolean indicator
	add di, 2 ; Move to next coin' info
	loop @@CheckForCoin

	ret
ENDP DrawCoinsForMap

;------------------------
;ChangePlayerFrame - This is changes the player' pic frame if needed
;------------------------
;Input:
;       PlayerXDelta <- Is the player moving left or right (-1, 1)
;Output:
;       The player frame changed
;Registers:
;       AX, CX, SI, DI
;------------------------
PROC ChangePlayerFrame
;-----	Check if the player is going left
	cmp [PlayerXDelta], -1
	je @@FlipPlayer

	mov [PlayerFlipped], False ; The normal state of the player is not flipped
	jmp @@FrameDelay

@@FlipPlayer:
	mov [PlayerFlipped], True ; Set player flipped if delta is -1, which means the player is going left

@@FrameDelay:
	inc [PlayerFrameCurrentDelay] ; Increase current delay

;-----	If reached max frame delay, change frame and reset
	cmp [PlayerFrameCurrentDelay], PlayerMaxFrameDelay
	je @@ChangeFrame

	jmp @@Return

@@ChangeFrame:
	xor [PlayerCurrentFrame], 1 ; Change frame using xor (0 -> 1 and 1 -> 0)
	mov [PlayerFrameCurrentDelay], 0 ; Reset delay

@@Return:
	ret
ENDP ChangePlayerFrame

;------------------------
;DrawCoin - This is drawing a coin in a given position on the screen
;------------------------
;Input:
;       StartX, StartY
;Output:
;       The coin on the screen
;Registers:
;       SI, DX, AX, CX
;------------------------
PROC DrawCoin
	lea si, [CoinPic] ; Point to the coin' frames array

;-----	Get Offset for current frame
	xor dx, dx ; Reset dx for mul
	mov ax, CoinPicHeight * CoinPicWidth ; Set the size of each frame (height * width)
	mov cx, [CoinFrame]
	mul cx

	add si, ax ; Add the calculated offset to the pointer to get the wanted frame

;-----	Draw the coin to the screen
	mov [SizeWidth], CoinPicWidth
	mov [SizeHeight], CoinPicHeight
	stc ; Turn on carry flag so that overflow and negetive will be checked for better optimization
	mov [ImageFlipped], False
	call PrintSprite
	ret
ENDP DrawCoin

;------------------------
;TimeHandler - This is handles the time, it is called every time a second passed
;------------------------
;Input:
;       DH <- New seconds
;Output:
;       The time changed on the screen
;Registers:
;       None
;------------------------
PROC TimeHandler
;-----	Set the new previous seconds
	mov [PreviousSeconds], dh

;-----	Decrease the time and print it again
	dec [Time]
	call PrintTime

	cmp [Time], 0
	je @@KillPlayer

	jmp @@Return

@@KillPlayer:
	mov [PlayerDead], True

@@Return:
	ret
ENDP TimeHandler

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
;       BX <- Min, CX <- Max, DI <- The pointer to the data
;Output:
;       Random height
;Registers:
;       AX, CX, DX, DI
;------------------------
PROC RandomData
;------	Random height
	in ax, 40h ; Random number from clock

;-----	Set in cx the max - min
	sub cx, bx

	xor dx, dx ; Reset dx for result
	div cx ; Divide ax in dx, the modulo will be in dx

	add dx, bx ; Add minimum for fixed range

	mov [di], dx ; Move random number to data

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
;-----	Take the part of the last part and add it as a score
	xor ax, ax
	mov al, [MapOrder]
	add [Score], ax

	call PrintScore

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

;-----	Move all parts' coin indicator by 1 backwards and randomize the new one
	mov al, [MapCoin + 1]
	mov [MapCoin], al

	mov al, [MapCoin + 2]
	mov [MapCoin + 1], al

;-----	Move all parts' coin x by 1 backwards and randomize the new one
	mov ax, [MapCoinX + 2]
	mov [MapCoinX], ax

	mov ax, [MapCoinX + 4]
	mov [MapCoinX + 2], ax

;-----	Move all parts' coin y by 1 backwards and randomize the new one
	mov ax, [MapCoinY + 2]
	mov [MapCoinY], ax

	mov ax, [MapCoinY + 4]
	mov [MapCoinY + 2], ax

	cmp [PlayerFinishedLevel], True
	je @@FinishFlat

;-----	Random new part, 0 - 1 for now
	in ax, 40h ; Get number from time port
	xor dx, dx
	mov cx, 2 + 1 ; Between 0 - 2
	div cx ; Divide ax in cx, the modulo will be in dx

;-----	Random boolean(true or false), should this part have a coin
	in ax, 40h ; Get number from time port
	and ax, 1 ; Get a number that is 0 or 1
	mov ax, True

	cmp ax, True
	je @@AddCoin

@@ClearCoin:
;-----	Set in the new part, is coin available to false
	mov [MapCoin + 2], False
	jmp @@PartCheck

@@AddCoin:
;-----	Set in the new part, is coin available to true
	mov [MapCoin + 2], True

@@PartCheck:
	cmp dl, 0
	je @@Flat

;-----	Check if the new part is a tall floor
	cmp dl, 1
	je @@Tall

;-----	Check if the new part is a lava floor
	cmp dl, 2
	je @@Lava

@@Flat:
	mov [MapOrder + 2], FlatFloor ; Set new part as flat floor

;-----	Get a random x for the coin
	lea di, [MapCoinX + 4] ; Set pointer to coin' x
	mov bx, FlatFloorCoinXRangeMin ; Set range min
	mov cx, FlatFloorCoinXRangeMax ; Set range max
	call RandomData

;-----	Get a random y for the coin
	lea di, [MapCoinY + 4] ; Set pointer to coin' y
	mov bx, FlatFloorCoinYRangeMin ; Set range min
	mov cx, FlatFloorCoinYRangeMax ; Set range max
	call RandomData

	jmp @@ResetOffsets ; If none of the above, just jump to reset offsets

@@Tall:
	mov [MapOrder + 2], TallFloor ; Set new part as tall floor

;-----	Get a random height for the new part
	lea di, [MapData1 + 4] ; Set pointer to data
	mov bx, TallFloorHeightRangeMin ; Set min
	mov cx, TallFloorHeightRangeMax ; Set max
	call RandomData

;-----	Get a random width for the new part
	lea di, [MapData2 + 4] ; Set pointer to data
	mov bx, TallFloorWidthRangeMin ; Set min
	mov cx, TallFloorWidthRangeMax ; Set max
	call RandomData

;-----	Set x as the middle of the part
	mov [MapCoinX + 4], (MidScreen / 2) - (CoinPicHeight / 2)

;-----	Get a random y for the coin
	lea di, [MapCoinY + 4] ; Set pointer to coin' y
	mov bx, (MaxY + CoinMinDist) ; Set min as the max y in the game + the minimum distance of the coin
	mov cx, [MapData1 + 4] ; Get the part' random height
	sub cx, (CoinPicHeight + CoinMinDist) ; Subtracte from it the height and the distance of the coin to get the max
	call RandomData

	jmp @@ResetOffsets

@@Lava:
	mov [MapOrder + 2], LavaFloor ; Set new part as lava floor

;-----	Get a random height for the new part
	lea di, [MapData1 + 4] ; Set pointer to data
	mov bx, LavaUpperHeightRangeMin ; Set min
	mov cx, LavaUpperHeightRangeMax ; Set max
	call RandomData

;-----	Get a random width for the new part
	lea di, [MapData2 + 4] ; Set pointer to data
	mov bx, LavaUpperWidthRangeMin ; Set min
	mov cx, LavaUpperWidthRangeMax ; Set max
	call RandomData

;-----	Set x as the middle of the part
	mov [MapCoinX + 4], (MidScreen / 2) - (CoinPicHeight / 2)

;-----	Get a random y for the coin
	lea di, [MapCoinY + 4] ; Set pointer to coin' y
	mov bx, (MaxY + CoinMinDist) ; Set min as the max y in the game + the minimum distance of the coin
	mov cx, FloorY
	sub cx, [MapData1 + 4] ; Get the part' random height which is the floor y - the random height
	sub cx, (CoinPicHeight + CoinMinDist) ; Subtracte from it the height and the distance of the coin to get the max
	call RandomData

@@ResetOffsets:
;-----	Reset offsets
	mov [MapOffset], 0
	mov [MapOffset + 2], MidScreen
	mov [MapOffset + 4], EndScreen

	ret

@@FinishFlat:
	mov dx, 0 ; Set flat
	jmp @@ClearCoin
ENDP MoveMap

;------------------------
;PrintScore - This is printing the score on the screen
;------------------------
;Input:
;       Score
;Output:
;       The score on the screen
;Registers:
;       None
;------------------------
PROC PrintScore
	PrintStringWithNumbers ScoreText, Score, GameBackgroundColor, WhiteColor, 7, 0, ScoreX, ScoreY
	ret
ENDP PrintScore

;------------------------
;PrintCoins - This is printing the coins on the screen
;------------------------
;Input:
;       Coins
;Output:
;       The coins on the screen
;Registers:
;       None
;------------------------
PROC PrintCoins
	PrintStringWithNumbers CoinsText, Coins, GameBackgroundColor, CoinYellowColor, 0, 1, CoinsX, CoinsY
	ret
ENDP PrintCoins

;------------------------
;PrintTime - This is printing the time on the screen
;------------------------
;Input:
;       Time
;Output:
;       The time on the screen
;Registers:
;       AX, CX, DX, SI, BP
;------------------------
PROC PrintTime
;-----	Get minutes and seconds from time
	xor dx, dx ; Reset dx for div
	mov ax, [Time]
	mov cx, 60 ; Divide by 60 seconds
	div cx

;-----	Convert minutes to text
	push dx ; Save seconds
	mov bp, 2 ; Amount of chars
	lea si, [TimeText] ; Point to the text holder of the Time
	call NumberToString

	mov [byte si], ':' ; Put divider between minutes and seconds
	inc si

;-----	Convert minutes to text
	pop ax ; Get seconds from stack
	mov bp, 2 ; Amount of chars
	call NumberToString

	mov [byte si], 0 ; Set end of the string

	mov [StartX], TimeX
	mov [StartY], TimeY
	lea si, [TimeText]
	mov dl, GameBackgroundColor ; Set text background
	mov dh, RedColor ; Set foreground color, red color
	call PrintColorfulText

	ret
ENDP PrintTime

;------------------------
;NumberToString - This is converts a number to a string
;------------------------
;Input:
;       AX <- Number, BP <- The minimum characters, SI <- Pointer to the string that will hold the number
;Output:
;       The number in the given string
;Registers:
;       AX, BX, SI, DX
;------------------------
PROC NumberToString
	mov cx, 0 ; Reset counter

@@DigitLoop:
;-----	Divide in 10
	mov bx, 10
	xor dx, dx
	div bx

	add dx, '0' ; Add the zero in ascii to the digit, to get the digit in ascii

	push dx ; Save char in stack
	inc cx ; Increase counter

;-----	Check if the number isn't 0
	cmp ax, 0
	jne @@DigitLoop

;-----	Check if has more digits than minimum digits
	cmp cx, bp
	jge @@DigitCharLoop

	sub bp, cx ; Get the amount of needed leading zero's

@@AddLeadingZero:
;-----	Add leading zero to string
	mov [byte si], '0'
	inc si

;-----	Check if done adding leading zero's
	dec bp
	jnz @@AddLeadingZero

@@DigitCharLoop:
	pop dx ; Get char from stack

	mov [byte si], dl ; Set in the string the character
	inc si ; Move to next char

	loop @@DigitCharLoop
	ret
ENDP NumberToString

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
	call DrawCoinsForMap
	call DrawKeyIfNeeded

;-----	Init
    	lea si, [MapOrder]
	lea bx, [MapOffset]
	mov [Temp], 0

@@Fix:
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
	jne @@Fix

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
	mov cl, [LavaCurrentColor]

	DrawRect ax, dx, 1, LavaHeight, cl ; Add a part

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

	call HandleLavaColor

	ret
ENDP FixLavaPart

;------------------------
;HandleLavaColor - This is handles the lava color and returns it
;------------------------
;Input:
;      	None
;Output:
;       LavaCurrentColor <- The lava color
;Registers:
;       AX
;------------------------
PROC HandleLavaColor
;-----	Increase and check if reached the maximum blocks to change color
	inc [LavaColorBlocksCounter]
	cmp [LavaColorBlocksCounter], LavaColorBlocksChange
	je @@ChangeColor
	ret

@@ChangeColor:
	mov [LavaColorBlocksCounter], 0 ; Reset counter

;-----	Add the current color offset to the color
	mov al, [LavaCurrentColorOffset]
	add [LavaCurrentColor], al

;-----	Check if reached the end of the color range of the lava, if we did, set offset to -1 (go back)
	cmp [LavaCurrentColor], LavaColorRangeEnd
	je @@GoBack

;-----	Check if reached the start of the color range, if yes, set offset to 1 (go forward)
	cmp [LavaCurrentColor], LavaColorRangeStart
	je @@GoForward

	ret

@@GoBack:
	mov [LavaCurrentColorOffset], -1 ; Go back next time
	ret

@@GoForward:
	mov [LavaCurrentColorOffset], 1 ; Go forward next time
	ret
ENDP HandleLavaColor

;------------------------
;HandleCoinFound - This is handles when a player founds a coin
;------------------------
;Input:
;       (X, Y) <- Interaction point with the coin
;Output:
;       The coin removed from the screen and increased amount of coins
;Registers:
;       AX, BX, CX, DX
;------------------------
PROC HandleCoinFound
	inc [Coins] ; Increase the amout of coins found
	add [Score], CoinValue ; Add to the score to value of the coin

;-----	Check if the coin is in the first part of the screen
	mov ax, [MapOffset]
	add ax, MidScreen
	cmp [X], ax

	jg @@SecondPart

	mov [MapCoin], False
	jmp @@UndrawCoin

@@SecondPart:
;-----	If the coin isn't in the first part, it must be in the second part because the player cannot reach the coin in the third part so just remove the coin
	mov [MapCoin + 1], False

@@UndrawCoin:
;-----	Get the x and y of the block that will be twice the size of the coin
	mov ax, [X]
	mov bx, [Y]

	sub ax, CoinPicWidth
	sub bx, CoinPicHeight

;-----	Set block size as twice the size of the coin
	mov cx, CoinPicWidth * 2
	mov dx, CoinPicHeight * 2

;-----	Drawing the block that is twice that size of the coin where the middle of the block will be the interaction point so that the block will remove the coin
	DrawRect ax, bx, cx, dx, GameBackgroundColor

	call PrintCoins
	call PrintScore
	ret
ENDP HandleCoinFound

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
	je @@CheckJump

	inc [PlayerVVelocity] ; Increasing velocity

@@CheckJump:
	mov cx, PlayerWidth ; Set the amount of points that are needed to be checked which is the width of the player

;-----	Check if reached floor, first point, start of player
        mov ax, [PlayerX]
        mov [X], ax

        mov ax, [PlayerY]
	dec ax
        mov [Y], ax

@@CheckLoop:
	call GetPixel ; Get the current pixel

;-----	Check if the current pixel is a wall, if it is, stop the player
	cmp [Color], FloorColor
	je @@StopJumping

;-----	Check if touched black which is the border of a coin
	cmp [Color], CoinBorderColor
	je @@CoinFound

;-----	Check if took key
	cmp [Color], KeyBorderColor
	je @@KeyFound

	inc [X] ; Go to next point
	loop @@CheckLoop

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

@@CoinFound:
	call HandleCoinFound
	jmp @@Jump

@@KeyFound:
	mov [KeyFound], True
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

@@CheckJump:
	mov cx, PlayerWidth ; Set the amount of points that are needed to be checked which is the width of the player

;-----	Check if reached floor, first point, start of player
        mov ax, [PlayerX]
        mov [X], ax

        mov ax, [PlayerY]
	dec ax
        mov [Y], ax

@@CheckLoop:
	call GetPixel ; Get the current pixel

;-----	Check if the current pixel is a wall, if it is, stop the player
	cmp [Color], FloorColor
	je @@StopJumping

;-----	Check if touched black which is the border of a coin
	cmp [Color], CoinBorderColor
	je @@CoinFound

;-----	Check if took key
	cmp [Color], KeyBorderColor
	je @@KeyFound

	inc [X] ; Go to next point
	loop @@CheckLoop

@@Jump:
        dec [PlayerY] ; Jumping

        cmp [PlayerY], MaxY ; Changed if reached the top
	je @@StopJumping

@@Return:
	ret

@@StopJumping:
	mov [PlayerStopJumping], False ; Make player to stop jumping smoothly
	jmp @@Return

@@CoinFound:
	call HandleCoinFound
	jmp @@Jump

@@KeyFound:
	mov [KeyFound], True
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
	je @@GravityCheck

	inc [PlayerVVelocity] ; Increasing velocity

@@GravityCheck:
	mov cx, PlayerWidth ; Set the amount of points that are needed to be checked which is the width of the player

;-----	Check if reached floor, first point, start of player
        mov ax, [PlayerX]
        mov [X], ax

        mov ax, [PlayerY]
        add ax, PlayerHeight + PlayerFloorDist
        mov [Y], ax

@@CheckLoop:
	call GetPixel ; Get the current pixel

;-----	Check if the current pixel is a wall, if it is, stop the player
	cmp [Color], FloorColor
	je @@StopGravity

;-----	Check if touched black which is the border of a coin
	cmp [Color], CoinBorderColor
	je @@CoinFound

;-----	Check if took key
	cmp [Color], KeyBorderColor
	je @@KeyFound

	cmp [Color], LavaColorRangeStart
	je @@PlayerDie

	inc [X] ; Go to next point
	loop @@CheckLoop

@@Gravity:
	mov [PlayerOnGround], False ; Set player to be not on ground, just found it using the conditions
	inc [PlayerY] ; Go down

@@Return:
        ret

@@StopGravity:
	mov [PlayerVVelocity], 0 ; Reset velocity
	mov [CurrentVDelay], 0 ; Reset MaxHDelay
	mov [PlayerOnGround], True

	jmp @@Return

@@CoinFound:
	call HandleCoinFound
	jmp @@Gravity

@@PlayerDie:
	mov [PlayerDead], True
	jmp @@Return

@@KeyFound:
	mov [KeyFound], True
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

;------------------------
;MovePlayer - This is handling whatever the player should move or just the map and it's moving what's neccessary + it's handling the acceleration of the player
;------------------------
;Input:
;       PlayerXDelta <- The delta of the player, right or left
;Output:
;       The player moved
;Registers:
;       DX
;------------------------
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
	call ChangePlayerFrame

;-----	Resetting the current delay
	mov [CurrentHDelay], 0

;-----	Check if reached max velocity, if reached just move without increasing speed, else continue
	cmp [PlayerHVelocity], MaxHVelocity
	je @@MapCheck

	inc [PlayerHVelocity] ; Increasing velocity

@@MapCheck:
	cmp [PlayerX], ScreenWidth / 2 - PlayerWidth / 2 ; Check if player in middle of screen, if it is, move map
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

;------------------------
;CheckIfReachedWall - This is checking if the player hit a wall
;------------------------
;Input:
;       PlayerXDelta <- The delta of the player, right or left
;Output:
;       The player stopped or if a coin found
;Registers:
;       CX, DX
;------------------------
PROC CheckIfReachedWall
	mov cx, PlayerHeight ; Check all the points in the player' side(the amount it's the player's height)

;-----	Check if moving right
	cmp [PlayerXDelta], 1
	je @@Right

;-----	Check if moving left
	cmp [PlayerXDelta], -1
	je @@Left

	jmp @@Return

@@Right:
;-----	Prepare for check by setting the x of the points and the initial y axis
        mov dx, [PlayerX]
	add dx, PlayerWidth + DistanceFromWall
        mov [X], dx

        mov dx, [PlayerY]
        mov [Y], dx

	jmp @@CheckLoop

@@Left:
;-----	If reached the end of the screen (left side), stop player
	cmp [PlayerX], MinX + DistanceFromWall
	je @@Stop

;-----	Prepare for check by setting the x of the points and the initial y axis
        mov dx, [PlayerX]
	sub dx, DistanceFromWall
        mov [X], dx

        mov dx, [PlayerY]
        mov [Y], dx

@@CheckLoop:
;-----	Get the current pixel
        call GetPixel

;-----	If touched a wall, stop the player
	cmp [Color], FloorColor
	je @@Stop

;-----	Check if touched black which is the border of a coin
	cmp [Color], CoinBorderColor
	je @@CoinFound

;-----	Check if took key
	cmp [Color], KeyBorderColor
	je @@KeyFound

	inc [Y] ; Go to next point
	loop @@CheckLoop
	jmp @@Return

@@Stop:
	mov [PlayerStop], False ; Setting player to be stopped
	mov [PlayerXDelta], 0 ; Resetting delta x
	mov [PlayerHVelocity], 0 ; Reset velocity
	mov [CurrentHDelay], 0 ; Reset delay

	jmp @@Return

@@CoinFound:
	call HandleCoinFound
	jmp @@Return

@@KeyFound:
	mov [KeyFound], True

@@Return:
	ret
ENDP CheckIfReachedWall

;------------------------
;StopPlayer - This is stopping the player using acceleration
;------------------------
;Input:
;       PlayerStop <- Should the player stop or not
;Output:
;       The player stopped on the screen
;Registers:
;       DX
;------------------------
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
	cmp [PlayerX], ScreenWidth / 2 - PlayerWidth / 2 ; Check if player in middle of screen, if it is, move map
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

;------------------------
;PrintColorfulText - This is checking if the player has moved and moving it if needed
;------------------------
;Input:
;       SI <- Pointer to the string, DL <- Background color, DH <- Foreground color, StartX, StartY
;Output:
;       The text in the colors wanted
;Registers:
;       AX, ES
;------------------------
PROC PrintColorfulText
;-----	Set in x and y the start x and start y
	mov ax, [StartX]
	mov [X], ax

	mov ax, [StartY]
	mov [Y], ax

@@CharLoop:
;-----	Set extra segment as ascii table in memory
	mov ax, 0F000h
	mov es, ax

;-----	Set in bx, the character * 8 (Each character takes up 8 bytes)
	mov bx, 0FA6Eh ; Initial ascii table in memory
	xor cx, cx
	mov cl, [byte si]
	shl cx, 3
	add bx, cx

;-----	Load the bitmap to a variable
	lea di, [TextBitmap] ; Set in di the text bitmap where we hold the bitmap to

	mov cx, 4 ; Get the rows (2 at the time)

@@GetBitmap:
	mov ax, [es:bx] ; Get two rows from the bitmap

;-----	Fix the bug where the two rows are swapped, so swap them back
	mov [TempByte], al
	mov al, ah
	mov ah, [TempByte]

	mov [di], ax ; Put in the bitmap var the 2 rows

	add bx, 2
	add di, 2

	loop @@GetBitmap

;-----	Set extra segment as video memory
	mov ax, 0A000h
	mov es, ax

	mov bx, 8 / 2 ; Set as the bitmap' rows size / 2 (Printing 2 rows at 1 time)
	lea di, [TextBitmap] ; Set di to point at the bitmap

@@BitmapPrint:
	mov cx, 2 ; Set as the rows in one word

@@BitmapRowPrint:
	shl [word di], 1 ; Shift left the bitmap
	jc @@Foreground ; If the carry is on then it means we need to print the foreground color

;-----	Print background color if carry is 0
	mov [Color], dl

	push di
	call PutPixel
	pop di

	jmp @@IncreaseX

@@Foreground:
;-----	Print foreground color
	mov [Color], dh

	push di
	call PutPixel
	pop di

@@IncreaseX:
	inc [X] ; Increase the x axis

;-----	Check if the line is finished
	mov ax, [StartX]
	add ax, 8
	cmp [X], ax

	jb @@BitmapRowPrint

;-----	Reset x
	mov ax, [StartX]
	mov [X], ax

	inc [Y]

	loop @@BitmapRowPrint ; If not finished 2 rows go back again

;-----	Check if finished printing character
	add di, 2
	dec bx
	jnz @@BitmapPrint

@@NextChar:
	inc si ; Move to next char

	add [StartX], 8 ; Adding to the start x the size of each character
	add [X], 8 ; Set x in the next char space

;-----	Reset y axis
	mov ax, [StartY]
	mov [Y], ax

;-----	Check if reached the end of the string
	cmp [byte si], 0
	je @@Return
	jmp @@CharLoop

@@Return:
	ret
ENDP PrintColorfulText

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
