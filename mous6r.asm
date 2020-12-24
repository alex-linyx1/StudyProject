;mous6r.asm 
; ��������
; ������ � �����
; (com ����)
; 
    .286
    .model tiny
    .code
    org 100h
start:   jmp beg
old_2fh dd ?
old_09h DD ?
;old_1bh DD ?
old_1ch DD ?
my_str db 'K-vo nazh LEVOY mishi =  ; PRAVOY mishi =   '; ��������� �-� �������
my_strlen = $-my_str
priz dw 0	; �������, ��� ���� ������� ���� ����������
kol1 dw 0   ; ���-�� ������� ����� ������ ����
kol2 dw 0	; ���-�� ������� ������ ������ ����
_ms_flag dw 0	; ���� �������� ����
_ms_bx dw 0	; ���������� ��
;
new_1ch proc far	; ���������� ���������� 1C
pusha
push es
push ds
push cs
pop ds
cmp cs:_ms_flag,1		; ���� ������ �� ����?
jne vix_1c		; ��� - �� �����
mov cs:_ms_flag,0	; �� = ����� ����� ����
cmp _ms_bx,1		; ������ ����� ������?
jne wh2
inc cs:kol1		; ��������� �������� ����� ������
jmp vix_1c
wh2:cmp _ms_bx,2	; ������ ������ ������?
jne vix_1c
inc cs:kol2		; ��������� �������� ������ ������
vix_1c: 
pop ds
pop es
popa
iret
new_1ch endp
;
new_09h proc far
;����� ���������� ������� 09h
pusha ;�������� ��� ��������, ������� ���������� ��������,
push es ;�.�. �� ����� �� �������� �� ������ ����������
push ds
push cs
pop ds
mov ax,40h ;�������� �������������� ES �� ������ �������
mov es,ax ;������ BIOS
in al,60h ;����� ����-��� �� ����� ������ ����������� ����������
pro3:
cmp al,63 ;����-��� ������� ������� "F5"?  �������� ������� ����
je pf5
cmp al,87 ;����-��� ������� �������  "F11"?     F11
je pf6   ; ���� �������� � ����� ������� ����
jmp handler09 ;���. ������� � ��������� ���������� 09h
;
pf5:
; =======  ��������� �������� ����
mov cs:kol1,0  ; ����� ��������� ��� � ���� ������ ����
mov cs:kol2,0
;cmp cs:priz,1
;je xx9
mov ax,0	; ������������� ����
int 33h
mov ax,1    ; �������� ������ ����
int 33h
push cs
pop es
mov dx,offset cs:_MS_HANDL   ;========= ����� �������� = ES:DX
mov cx,10
mov ax,0014h
int 33h
;mov cs:priz,1
jmp xx9
pf6:  
; ���������� ��������
push dx
push es
mov ax,001fh
int 33h
pop es
pop dx
; ������� � ���� ��� ���������
mov ax,cs:kol1
aam
add ax, 3030h
lea bx,cs:my_str
add bx,24
mov byte ptr cs:[bx],ah
mov byte ptr cs:[bx+1],al
;
mov ax,cs:kol2
aam
add ax, 3030h
lea bx,cs:my_str
add bx,42
mov byte ptr cs:[bx],ah
mov byte ptr cs:[bx+1],al
;	����� �� �����
push bp
push cx
push bx
push dx
push ax
push cs
pop es
mov bp, offset cs:my_str
mov cx,my_strlen
mov bx,001eh
mov dx,0a00h
mov ax,1300h
int 10h
pop ax
pop dx
pop bx
pop cx
pop bp
;
xx9:
in al,61h ;����� ���������� ����� 61h
or al,80h ;���������� ���� ����, ������� 1 � �������
out 61h,al ;��� ����� 61h
and al,7fh ;����� �������� ������ ����������� ����������,
out 61h,al ;������� ������� ��� ����� 61h
;�������� ������ ���������� ����������� ��������� ���������� ����������
mov al,20h ;20h - ������� EOI
out 20h,al ;20h - ���� �����������
vixint9:
pop ds ;����������� ��������
pop es
popa
iret
;
handler09:
pushf
call dword ptr cs:[old_09h] ;� ��������� ���������� � ���������
pop ds ;����������� ��������
pop es
popa
iret
new_09h endp   ;======================== new_09   END  =================
;			==== ������� ���� ====
_MS_HANDL proc far
mov cs:_ms_bx, bx
; ������������� ���� ������ �������� � 1,
; ������������ ��������� � ���, ���
; ��������� �������.
mov cs:_ms_flag, 1
ret
_MS_HANDL endp

;
; ���������� ����������������� ����������
new_2fh proc far
       cmp ah,0f5h		; �������� ����� ������� ����������������� ����������
       jne out_2fh		; �� ���� � �� �����
       cmp al,00h		; ���������� �������� �� ��������� ���������?
       je inst			; ��, ������� � ������������� ��������� ���������
       cmp al,01h		; ���������� ��������?
       je offprg			; �� � �� ��������
       jmp short out_2fh		; ����������� ����������, �� �����
   inst:  mov al,0ffh		; ��������� ��� �����������
       iret			; ����� �� ����������
out_2fh:
       jmp cs:old_2fh	; ������� �  ��������� �� ������� ���������� ���������� 2Fh
; �������� ��������� �� ������, �������������� ����������� ��� ������������� �� ������� 
offprg:   push ds
       push es
       push dx
; ����������� ������ 9h
       mov ax,2509h		; ������� ��������� �������
       lds dx,cs:old_09h		; �������� DS:DX
       int 21h
; ����������� ������ 1ch
       mov ax,251ch		; ������� ��������� �������
       lds dx,cs:old_1ch		; �������� DS:DX
       int 21h
; ����������� ������ 2fh 
       mov ax,252fh		; ������� ��������� ������� 2Fh
       lds dx,cs:old_2fh		; �������� DS:DX
       int 21h
; ������� �� PSP ����� ������������ ��������� � �������� ���
       mov es,cs:2ch		; ES = ���������
       mov ah,49h		; ������� ������������ ����� ������
       int 21h
; �������� ������ ���� ���������
       push cs			; �������� � ES ���������� CS, �.�. ���������� ����� PSP
       pop es
       mov ah,49h		; ������� ������������ ����� ������
       int 21h
; ����������� ���������������� ��������
       pop dx
       pop es
       pop ds
       iret			; ������� � ��������� ���������
new_2fh endp			; ����� ��������� ��������� ���������� 2Fh    
rsize   db 0     ;   ===== ����� ����������� �����   ======
;  
tail db 'off'			; ��������� ����� �������
flag db 0			; ���� ���������� �������� 
beg: 
init2: 
       mov cl,es:80h		; ������� ����� ������ PSP
       cmp cl,0			; ����� ������ = 0 ?
       jne go923		; ���	
	jmp other6			; � �����
go923:  xor ch,ch			; ������ CX=CL=����� ������
       mov di,81h		; DS:SI = ����� � PSP
       lea si,tail			; DS:SI = ���� tail	
       mov al,' '			; ����� ������� �� ������ ������
repe   scasb			; ��������� �����, ���� �������
       dec di			; DI = ������ ������ ����� �������� 
	mov dx,di
       mov cx,3			; ��������� ����� ���������
repe   cmpsb			; ���������� �������� ����� � ���������
       jne other6			; ������� �������� �� off 
       inc flag		; ������� (off), ��������� ���� ������� �� ��������
other6:	
	mov ah,0f5h	; ��������� ��� ��� �������
      	mov al,0 ; � ���������� �� ������� ����� ��������� � ����������� ������ 
       int 2fh
       cmp al,0ffh	; ��������� �����������?
       je installed	; ��, ��� ������� ������� �� �������� � ����� ���������	
	push cs
        pop  ds
; ==== take int 9 orig directly from vector's table
	push es
	xor ax,ax
	mov es,ax
	mov di,24h
	mov ax,es:[di]  ; offset orig int 9h
	mov word ptr old_09h,ax
	mov ax,es:[di+2] ; segment orig int 9h
	mov word ptr old_09h+2,ax
	pop es
;
       ;���������� ����� ������ ���������� int 9
       mov      ax,2509h
       mov      dx,offset ds:new_09h
       int      21h
       ;��������� ������ ������ ���������� int 1c
       mov      ax,351ch
       int      21h
    mov word ptr cs:old_1ch,bx ; �������� �������� ���������� ����������� int 1c
    mov word ptr cs:old_1ch+2,es; �������� ������� ���������� ����������� int 1c
       ;���������� ����� ������ ���������� int 1c
       mov      ax,251ch
       mov      dx,offset ds:new_1ch
       int      21h
; �������� ������ 2fh 
       mov ax,352fh		; ������� ��������� ������� 2fh
       int 21h
       mov word ptr cs:old_2fh,bx 	; �������� �������� ���������� �����������
       mov word ptr cs:old_2fh+2,es 	; �������� ������� ���������� �����������
; �������� ������ 2fh
       mov ax,252fh		; ������� ������������ ������� ���������� 2fh
       mov dx,offset ds:new_2fh	; �������� ������ �����������
       int 21h

;
; ������� �� ����� �������������� ���������
by:    mov ah,9h		; ������� ������ �� �����
       lea dx,mes		; DS:DX = ����� ������
       int 21h
       mov ax,3100h		; ������� = ����������� � �������� ����������� =
       mov dx,(init2-start+10fh)/16	; ������ � ����������
       int 21h
installed:
       cmp flag,1		; ������ �� �������� ����������?
       je unins			; ��, �� ��������
; ������� �� ����� �������������� ���������
       mov ah,09h		; ������� ������ �� �����
       lea dx,mes1		; DS:DX = ����� ������
       int 21h
; ������� ��������������� �������� ������       
zumm:   mov cx,5			; ���������� ������
       mov ah,02h		; ������� ������ �� �����
l8:     mov dl,07h		; ASCII ��� �������
       int 21h
       loop l8			; �������� CX ���
exi:   mov ax,4c01h		; ������� ���������� � ����� ��������
       int 21h
unins:
; ������� � ������ (�����������) ����� ��������� ������ �� ��������   
       mov ax,0f501h		; ���� ������� � ����������� ��������
       int 2fh			; �������������� ����������
; ������� �� ����� �������������� ��������� 
       mov ah,09h		; ������� ������ �� �����
       lea dx,mes2		; DS:DX = ����� ������
       int 21h
       mov ax,4c00h		; ������� ���������� ���������
       int 21h
       mes  db 'Resident Program installed$'
       mes1 db 'Program already installed$'
       mes2 db 'Program UNLOADED from memory$'
; =====
end start