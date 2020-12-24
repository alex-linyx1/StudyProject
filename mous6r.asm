;mous6r.asm 
; резидент
; работа с мышью
; (com файл)
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
my_str db 'K-vo nazh LEVOY mishi =  ; PRAVOY mishi =   '; сообщение к-в нажатий
my_strlen = $-my_str
priz dw 0	; признак, что файл драйвер мыши установлен
kol1 dw 0   ; кол-во нажатий левой кнопки мыши
kol2 dw 0	; кол-во нажатий правой кнопки мыши
_ms_flag dw 0	; флаг драйвера мыши
_ms_bx dw 0	; содержимое ВХ
;
new_1ch proc far	; обработчик прерывания 1C
pusha
push es
push ds
push cs
pop ds
cmp cs:_ms_flag,1		; есть сигнал от мыши?
jne vix_1c		; нет - на выход
mov cs:_ms_flag,0	; да = сброс флага мыши
cmp _ms_bx,1		; нажата левая кнопка?
jne wh2
inc cs:kol1		; инкремент счетчика левой кнопки
jmp vix_1c
wh2:cmp _ms_bx,2	; нажата правая кнопка?
jne vix_1c
inc cs:kol2		; инкремент счетчика правой кнопки
vix_1c: 
pop ds
pop es
popa
iret
new_1ch endp
;
new_09h proc far
;Новый обработчик вектора 09h
pusha ;Сохраним все регистры, включая сегментные регистры,
push es ;т.к. не знаем их значения на момент прерывания
push ds
push cs
pop ds
mov ax,40h ;настроим предварительно ES на начало области
mov es,ax ;данных BIOS
in al,60h ;Введём скан-код из порта данных контроллера клавиатуры
pro3:
cmp al,63 ;Скан-код нажатия клавиши "F5"?  включить драйвер мыши
je pf5
cmp al,87 ;Скан-код нажатия клавиши  "F11"?     F11
je pf6   ; откл драйвера и вывод нажатий мыши
jmp handler09 ;Нет. Перейдём в системный обработчик 09h
;
pf5:
; =======  включение драйвера мыши
mov cs:kol1,0  ; сброс счетчиков лев и прав кнопок мыши
mov cs:kol2,0
;cmp cs:priz,1
;je xx9
mov ax,0	; инициализация мыши
int 33h
mov ax,1    ; включить курсор мыши
int 33h
push cs
pop es
mov dx,offset cs:_MS_HANDL   ;========= адрес драйвера = ES:DX
mov cx,10
mov ax,0014h
int 33h
;mov cs:priz,1
jmp xx9
pf6:  
; отключение драйвера
push dx
push es
mov ax,001fh
int 33h
pop es
pop dx
; перевод в симв вид счетчиков
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
;	вывод на экран
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
in al,61h ;Введём содержимое порта 61h
or al,80h ;Подтвердим приём кода, записав 1 в старший
out 61h,al ;бит порта 61h
and al,7fh ;Снова разрешим работу контроллера клавиатуры,
out 61h,al ;сбросив старший бит порта 61h
;Завершим работу системного контроллера обработки аппаратных прерываний
mov al,20h ;20h - команда EOI
out 20h,al ;20h - порт контроллера
vixint9:
pop ds ;Восстановим регистры
pop es
popa
iret
;
handler09:
pushf
call dword ptr cs:[old_09h] ;В системный обработчик с возвратом
pop ds ;Восстановим регистры
pop es
popa
iret
new_09h endp   ;======================== new_09   END  =================
;			==== драйвер мыши ====
_MS_HANDL proc far
mov cs:_ms_bx, bx
; Устанавливаем флаг вызова драйвера в 1,
; сигнализируя программе о том, что
; произошло событие.
mov cs:_ms_flag, 1
ret
_MS_HANDL endp

;
; Обработчик мультиплексорного прерывания
new_2fh proc far
       cmp ah,0f5h		; Проверим номер функции мультиплексорного прерывания
       jne out_2fh		; Не наша – на выход
       cmp al,00h		; Подфункция проверки на повторную установку?
       je inst			; Да, сообщим о невозможности повторной установки
       cmp al,01h		; Подфункция выгрузки?
       je offprg			; Да – на выгрузку
       jmp short out_2fh		; Неизвестная подфункция, на выход
   inst:  mov al,0ffh		; Программа уже установлена
       iret			; Выход из прерывания
out_2fh:
       jmp cs:old_2fh	; Переход в  следующий по цепочке обработчик прерывания 2Fh
; Выгрузим программу из памяти, предварительно восстановив все перехваченные ею векторы 
offprg:   push ds
       push es
       push dx
; Восстановим вектор 9h
       mov ax,2509h		; Функция установки вектора
       lds dx,cs:old_09h		; Заполним DS:DX
       int 21h
; Восстановим вектор 1ch
       mov ax,251ch		; Функция установки вектора
       lds dx,cs:old_1ch		; Заполним DS:DX
       int 21h
; Восстановим вектор 2fh 
       mov ax,252fh		; Функция установки вектора 2Fh
       lds dx,cs:old_2fh		; Заполним DS:DX
       int 21h
; Получим из PSP адрес собственного окружения и выгрузим его
       mov es,cs:2ch		; ES = окружение
       mov ah,49h		; Функция освобождения блока памяти
       int 21h
; Выгрузим теперь саму программу
       push cs			; Загрузим в ES содержимое CS, т.е. сегментный адрес PSP
       pop es
       mov ah,49h		; Функция освобождения блока памяти
       int 21h
; Восстановим использовавшиеся регистры
       pop dx
       pop es
       pop ds
       iret			; Возврат в вызвавшую программу
new_2fh endp			; Конец процедуры обработки прерывания 2Fh    
rsize   db 0     ;   ===== конец резидентной части   ======
;  
tail db 'off'			; Ожидаемый хвост команды
flag db 0			; Флаг требования выгрузки 
beg: 
init2: 
       mov cl,es:80h		; Получим длину хвоста PSP
       cmp cl,0			; Длина хвоста = 0 ?
       jne go923		; нет	
	jmp other6			; и выход
go923:  xor ch,ch			; Теперь CX=CL=длина хвоста
       mov di,81h		; DS:SI = хвост в PSP
       lea si,tail			; DS:SI = поле tail	
       mov al,' '			; Уберём пробелы из начала хвоста
repe   scasb			; Сканируем хвост, пока пробелы
       dec di			; DI = первый символ после пробелов 
	mov dx,di
       mov cx,3			; Ожидаемая длина параметра
repe   cmpsb			; Сравниваем введённый хвост с ожидаемым
       jne other6			; Введено отличное от off 
       inc flag		; Введено (off), установим флаг запроса на выгрузку
other6:	
	mov ah,0f5h	; Установим наш код функции
      	mov al,0 ; и подфункцию на наличие нашей программы в оперативной памяти 
       int 2fh
       cmp al,0ffh	; Программа установлена?
       je installed	; Да, при наличии запроса на выгрузку её можно выгрузить	
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
       ;установить новый вектор прерывания int 9
       mov      ax,2509h
       mov      dx,offset ds:new_09h
       int      21h
       ;сохранить старый вектор прерывания int 1c
       mov      ax,351ch
       int      21h
    mov word ptr cs:old_1ch,bx ; Сохраним смещение системного обработчика int 1c
    mov word ptr cs:old_1ch+2,es; Сохраним сегмент системного обработчика int 1c
       ;установить новый вектор прерывания int 1c
       mov      ax,251ch
       mov      dx,offset ds:new_1ch
       int      21h
; Сохраним вектор 2fh 
       mov ax,352fh		; Функция получения вектора 2fh
       int 21h
       mov word ptr cs:old_2fh,bx 	; Сохраним смещение системного обработчика
       mov word ptr cs:old_2fh+2,es 	; Сохраним сегмент системного обработчика
; Заполним вектор 2fh
       mov ax,252fh		; Функция установления вектора прерывания 2fh
       mov dx,offset ds:new_2fh	; Смещение нашего обработчика
       int 21h

;
; Выведем на экран информационное сообщение
by:    mov ah,9h		; Функция вывода на экран
       lea dx,mes		; DS:DX = адрес строки
       int 21h
       mov ax,3100h		; Функция = завершиться и остаться резидентным =
       mov dx,(init2-start+10fh)/16	; Размер в параграфах
       int 21h
installed:
       cmp flag,1		; Запрос на выгрузку установлен?
       je unins			; Да, на выгрузку
; Выведем на экран информационное сообщение
       mov ah,09h		; Функция вывода на экран
       lea dx,mes1		; DS:DX = адрес строки
       int 21h
; Выведем предупреждающий звуковой сигнал       
zumm:   mov cx,5			; Количество гудков
       mov ah,02h		; Функция вывода на экран
l8:     mov dl,07h		; ASCII код зуммера
       int 21h
       loop l8			; Повторим CX раз
exi:   mov ax,4c01h		; Функция завершения с кодом возврата
       int 21h
unins:
; Перешлём в первую (резидентную) копию программы запрос на выгрузку   
       mov ax,0f501h		; Наша функция с подфункцией выгрузки
       int 2fh			; Мультиплексное прерывание
; Выведем на экран информационное сообщение 
       mov ah,09h		; Функция вывода на экран
       lea dx,mes2		; DS:DX = адрес строки
       int 21h
       mov ax,4c00h		; Функция завершения программы
       int 21h
       mes  db 'Resident Program installed$'
       mes1 db 'Program already installed$'
       mes2 db 'Program UNLOADED from memory$'
; =====
end start