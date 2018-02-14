;------------------------------------------
; PURPOSE : Project Menu 
; SYSTEM  : Turbo Assembler Ideal Mode  
; AUTHOR  : Almog Hamdani
;------------------------------------------

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

MACRO DrawRect X, Y, Width, Height, Clr
        mov [Color], Clr
        mov [StartX], X
        mov [StartY], Y
        mov [SizeWidth], Width
        mov [SizeHeight], Height

        call DrawRectangle
ENDM DrawRect

;----Constants-----

GameBackgroundColor     equ 53
FloorY                  equ 150

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

upArrowScanCode   equ 72
downArrowScanCode equ 80
enterScanCode     equ 28

gameText          db "This is the game", 13, 10, '$'
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

        DrawRect 0, FloorY, 320, 10, 15

        ; Wait for keyboard tap
        xor ah, ah
        int 16h

        jmp PrintMenu ; Return to menu

        ret
ENDP Game

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
