.model tiny
.code
org 100h

BEGIN: jmp start
;TSR O6PA6OT4UK KJlABUW
new_9h proc
pushf
push ax
in al, 60h
cmp AL, 4Dh ; <-
je activityRacketRight  
cmp AL, 4Bh ; ->
je activityRacketLeft
pop ax
popf
jmp dword ptr cs:[old_9h]

ActivityRacketLeft:  ;O6PA6OTKA KJlABUWU <-
sti
in AL,61h
or AL,80h
out 61h,AL
and AL,7Fh
out 61h,AL  
mov dl, positionRacket
add dl, weightRacket
dec dl
mov dh, 23 
mov ah, 02h
int 10h
mov ah, 2h
mov dl, 032;76
int 21h
cmp positionRacket, 0
je toPrint
dec positionRacket
jmp toPrint

ActivityRacketRight:  ;O6PA6OTKA KJlABUWU ->
sti
in AL,61h
or AL,80h
out 61h,AL
and AL,7Fh
out 61h,AL
mov dl, positionRacket
mov dh, 23 
mov ah, 02h
int 10h
mov ah, 2h
mov dl, 032
int 21h
mov cl, positionRacket
add cl, weightRacket
dec cl
cmp cl, 79
je toPrint 
inc positionRacket
jmp toPrint

toPrint:                           
call printRacket

cli
mov AL,20h      
out 20h,AL 
pop ax
popf
iret  
new_9h endp


;<HOBblU O6PA6OT4UK 1Ch
new_1Ch proc
mov al, activeDelay
cmp al, 4
jne counterPlus
mov delay, 1
mov activeDelay, 0 
jmp exit1Ch
counterPlus:
add al, 1
mov activeDelay, al
exit1Ch:
iret    
new_1Ch endp


;3AHOCUM HOBbIE O6PA6OT4UKU B TA6JlUVY
setup proc
mov ax, 3509h
int 21h
mov word ptr old_9h, bx
mov word ptr old_9h+2, es
mov dx, offset new_9h
mov ax, 2509h
int 21h
mov ax, 351Ch
int 21h
mov word ptr old_1Ch, bx
mov word ptr old_1Ch+2, es
mov dx, offset new_1Ch
mov ax, 251Ch
int 21h
ret
setup endp 


;BblBECTU PAKETKY
printRacket proc
push ax
push dx
mov cl, 0
mov dl, positionRacket
mov bl, weightRacket
inc bl
dec bl
mov ch, dl
printLoop:
inc cl
mov dl, ch
mov dh, 23 
mov ah, 02h
int 10h
mov ah, 2h
mov dl, 061
int 21h
inc ch
cmp bl, cl
jg printLoop
pop dx
pop ax
ret
printRacket endp
 
 
  
start:
;BBEDUTE DJlUHY
mov ah, 9h
mov dx, offset mess
int 21h      
;C4UTATb CTPOKY
mov dx, offset weight
mov ah, 0Ah
int 21h  
;llPEO6PA3OBATb B 4UCJlO
xor bx, bx
mov al, weight[2]
sub al, 48
cmp weight[1], 2
jne next
mov cl, 10
mul cl
add al, weight[3]
sub al, 48
next:
mov weightRacket, al ; 3AHOCUM PE3YJlbTAT 
;O4UCTUTb 3KPAH
mov ax, 03h
int 10h
;YCTAHABJlUBAEM WAP B UEHTP
mov ah, 2Ch
int 21h
xor ax, ax
mov al, dh
mov cl, 3
div cl
mov dh, 12 
mov dl, 40
add dh, ah
add dh, ah
push dx
;CJlY4AUHOE HAllPABJlEHUE WAPA by system time 2Ch
mov ah, 2Ch
int 21h
xor ax, ax
mov al, dh
mov cl, 4
div cl
mov directionOfMove, ah
call printRacket
call setup ; YCTAHOBUM HOBblE O6PA6OT4UKU llPEPblBAHUU

;llEPEMEWEHUE WAPA
movementBall:
mov ah, 0fh
int 10h  
mov ah, 02h
pop dx
int 10h
mov ah, 2h
push dx  
mov dl, 079
int 21h
jmp positionBall

;OllPEDEJlREM CTOJlKHYJlCR JlU WAR?
positionBall:
jmp mainLoop
continueGame:
pop dx
cmp dh, 22    ; DOCTU7 DHA?
je compareDown
cmp dh, 0     ; DOCTU7 BEPWUHbl?
je compareUp
cmp dl, 0     ; DOCTU7 JlEBO7O KPAR?
je compareLeft 
cmp dl, 78    ; DOCTU7 llPABO7O KPAR?
je compareRight
push dx
jmp compareEnd
;CPABHUTb HAllPABJlEHUE CHU3Y
compareDown:
cmp dl, positionRacket
jb toEnd
mov al, positionRacket
add al, weightRacket
cmp dl, al
ja toEnd
jmp continueCompareDown
continueCompareDown:
push dx
cmp directionOfMove, 1
je toLeftUp
jne toRightUp
;CPABHUTb HAllPABJlEHUE CBEPXY 

compareUp:
push dx
cmp directionOfMove, 0
je toLeftDown
jne toRightDown
;CPABHUTb HAllPABJlEHUE CJlEBA
compareLeft:
push dx
cmp directionOfMove, 0
je toRightUp
jne toRightDown
;CPABHUTb HAllPABJlEHUE CllPABA
compareRight:
push dx
cmp directionOfMove, 2
je toLeftUp
jne toLeftDown 
;CMEHUTb HAllPABJlEHUE BJlEBO BBEPX
toLeftUp:
mov directionOfMove, 0
jmp compareEnd
;CMEHUTb HAllPABJlEHUE BJlEBO BHU3
toLeftDown:
mov directionOfMove, 1 
jmp compareEnd
;CMEHUTb HAllPABJlEHUE BllPABO BBEPX
toRightUp:
mov directionOfMove, 2 
jmp compareEnd
;CMEHUTb HAllPABJlEHUE BllPABO BHU3
toRightDown:
mov directionOfMove, 3 
jmp compareEnd
;OllPEDEJlUTb, KAKOE HAllPABJlEHUE
compareEnd:
cmp directionOfMove, 0
je leftUp
cmp directionOfMove, 1
je leftDown
cmp directionOfMove, 2
je rightUp
jne rightDown

toEnd:      ; 3A7JlYWKA, 4TO6bl llPEODOJlETb O7PAHU4EHUE JMP
jmp gameOver
;CMEHA KOOPDUHAT HA..
rightDown:
pop dx
mov ah, 02h
int 10h
mov ah, 2h
mov cl, dl  
mov dl, 032
int 21h
mov dl, cl
inc dl
inc dl
inc dh
push dx
jmp movementBall 
;CMEHA KOOPDUHAT HA..
rightUp:
pop dx
mov ah, 02h
int 10h
mov ah, 2h
mov cl, dl  
mov dl, 032
int 21h
mov dl, cl
inc dl
inc dl
dec dh
push dx
jmp movementBall
;CMEHA KOOPDUHAT HA..
leftUp:
pop dx 
mov ah, 02h
int 10h
mov ah, 2h
mov cl, dl  
mov dl, 032
int 21h
mov dl, cl
dec dl
dec dl
dec dh
push dx
jmp movementBall
;CMEHA KOOPDUHAT HA..
leftDown:
pop dx
mov ah, 02h
int 10h
mov ah, 2h
mov cl, dl  
mov dl, 032
int 21h
mov dl, cl
dec dl
dec dl
inc dh
push dx
jmp movementBall

;3AMEDJlREM DBU)l(EHUE WAPUKA
mainLoop:
cmp delay, 1
jne mainLoop
mov delay, 0
jmp continueGame     
;3ABEPWAEM
gameOver:
mov dl, 36
mov dh, 12 
mov ah, 02h
int 10h
mov ah, 9h
mov dx, offset messGameOver
int 21h
mov dl, 0
mov dh, 0 
mov ah, 02h
int 10h
lds dx, cs:old_9h
mov ax,2509h
int 21h 
lds dx, cs:old_1Ch
mov ax,251Ch
int 21h           
int 20h

mess db 'Enter racket width (min 1, max 80): $'
delay db 2
activeDelay db 0
messGameOver db 'Game over$'       
weight db 3,?, 3 dup(' ')
weightRacket db 0
positionRacket db 0
old_9h DD ?
old_1Ch DD ?
directionOfMove db 0; 0 LeftUp, 1 LeftDown, 2 RightUp, 3 RightDown  
end BEGIN