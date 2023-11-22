;#woderwitch irc channel 
;promotional WonderSwan Color intro
;coded in october 2001
;by Tomasz 'dox' Slanina
;
;use FASM (flatassembler.net) to compile
;

ACT_SEG equ 8000h
XS equ 0
YS equ 2
TR equ 8

  use16
  org 100h

start:     	
  cli
  cld
  mov sp,100h
  mov ax,ACT_SEG
  mov ds,ax

  xor al,al
  out 14h,al ; lcd off

  xor ax,ax
  out 10h,ax
  out 12h,ax

  mov al,1
  out 0,al	;layer 1 on

  in al,60h
  or al,0e0h
  out 60h,al	;gfx mode

  mov al,21h
  out 7,al  ; scrloc 800,1000

  xor di,di
  push di
  pop es
  xor  ax,ax
  mov di,4002h
  mov cx,504*32
  cld
  rep stosw ; clear tiles

  xor ax,ax
  mov [es:TR],ax
  mov [es:XS],ax
  mov [es:YS],ax

  mov si,pals
  mov di,0fe00h
  mov cx,100h
  rep movsw

  mov si,map
  mov di,800h
  mov cx,32*32
  rep movsw

  mov si,text
  mov di,800h+384
  mov cx,12*32

colorSet:
  lodsw
  add ax,256
  or ah,2
  stosw
  loop colorSet

  mov si,pal2
  mov di,0fe00h+32
  mov cx,16
  rep movsw

  mov si,tiles2
  mov di,04000h+256*32
  mov cx,256*32
  rep movsw

  mov al,1
  out 14h,al ; lcd on

  mov ax,ACT_SEG
  mov es,ax
  xor ax,ax
  mov ds,ax
  mov di,startOffsets

mainLoop: 
  mov ax,[es:di]
  or ax,ax
  jne continue
  mov di,startOffsets

continue:
  mov bx,[es:di]
  add di,2
  mov dx,[es:di]
  add di,2
  push di
  call bumpLoop ; 1/4 of the bump
  pop di

  jmp short mainLoop

startOffsets:
  dw 1,1,2,1,1,2,2,2,0,0

bumpLoop:
  mov ax,[ds:TR]
  push ax
  mov di,track
  add di,ax
  mov ax,[es:di]
  mov cl,al
  xor ch,ch
  mov [ds:XS],cx
  mov cl,ah
  mov [ds:YS],cx
  pop ax
  add ax,2
  cmp ax,360*4
  jb oko
  xor ax,ax
oko:
  mov [ds:TR],ax
  push bx
pet1:
  pop bx
  push bx
pet2:
  call bump
  add bx,2
  cmp bx,110
  jb pet2
  add dx,2
  cmp dx,28
  jb pet1
  pop bx
  ret

bump:
  ;bx=x
  ;dx=y
  push es

  mov si,[ds:XS]
  mov di,[ds:YS]
  mov ax,bx
  sub ax,si
  sub ax,64
  mov bp,ax
  mov ax,dx
  sub ax,di
  sub ax,64
  mov si,ax

  mov di,ypos
  mov ax,dx
  inc ax
  shl ax,1
  add di,ax
  mov ax,[es:di] 
  add ax,bx
  add ax,2
  mov di,logo
  add di,ax
  mov cl,[es:di]
  xor ch,ch

  mov di,ypos
  mov ax,dx
  inc ax
  shl ax,1
  add di,ax
  mov ax,[es:di] 
  add ax,bx
  mov di,logo
  add di,ax
  mov al,[es:di]
  xor ah,ah
  sub cx,ax
  sub cx,bp
  cmp cx,127
  jb dal1
  mov cx,127

dal1:
  mov bp,cx
  mov di,ypos
  mov ax,dx
  add ax,2
  shl ax,1
  add di,ax
  mov ax,[es:di] 
  add ax,bx
  inc ax
  mov di,logo
  add di,ax
  mov cl,[es:di]
  xor ch,ch

  mov di,ypos
  mov ax,dx
  shl ax,1
  add di,ax
  mov ax,[es:di] 
  add ax,bx
  inc ax
  mov di,logo
  add di,ax
  mov al,[es:di]
  xor ah,ah
  sub cx,ax
  sub cx,si
  cmp cx,127
  jb dal2
  mov cx,127

dal2:
  shl cx, 7
  or cx,bp
  mov di,light
  add di,cx
  mov cl,[es:di]
  add cl,cl
  xor ch,ch

  ;plot
  ;bx - x
  ;dx - y
  ;cx - color
  mov di,y_4
  mov ax,dx
  shr ax,1
  and ax,0fffeh
  add di,ax
  mov di,[es:di]
  mov ax,bx
  and ax,0fch
  shl ax,3
  add di,ax

  mov bp,bx
  and bp,3
  add di,bp
  mov bp,dx
  and bp,3
  shl bp,3
  add bp,di

  mov di,bumpcol
  add di,cx
  mov cl,[es:di]
  xor ax,ax
  mov es,ax
  mov [es:bp],cl
  mov ch,cl
  shr cl,4
  shl ch,4
  or cl,ch
  mov [es:bp+4],cl

  pop es
  ret

y_4:
  dw 16384, 17280, 18176, 19072, 19968, 20864, 21760, 22656, 23552
  dw 24448, 25344, 26240, 27136, 28032, 28928, 29824, 30720, 31616

map:
  include 'map.inc'

bumpcol:
  db $11, $12, $22, $23, $33, $34, $44, $45, $55, $56, $66, $67, $77
  db $78, $88, $89, $99, $9a, $aa, $ab, $bb, $bc, $cc, $cd, $dd, $de
  db $ee, $ef, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
  db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
  db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
  db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

text:
  dw 40,40,40,40,40,40,40,40,40,40,40,40
  dw 40,40,40,40,40,40,40,40,40,40,40,40
  dw 40,40,40,40,0,0,0,0,37,37,5,14
  dw 17,37,0,11,11,37,24,14,20,17,37,22
  dw 14,13,3,4,17,18,22,0,13,37,37,37
  dw 0,0,0,0,37,37,37,37,37,37,37,37
  dw 37,37,37,37,37,37,37,37,37,37,37,37
  dw 37,37,37,37,37,37,37,37,0,0,0,0
  dw 37,37,37,13,4,4,3,18,37,37,37,15
  dw 11,4,0,18,4,37,37,21,8,18,8,19
  dw 37,37,37,37,0,0,0,0,37,37,37,37
  dw 37,37,37,37,37,37,37,37,37,37,37,37
  dw 37,37,37,37,37,37,37,37,37,37,37,37
  dw 0,0,0,0,37,37,37,37,37,37,37,39
  dw 37,22,14,13,3,4,17,22,8,19,2,7
  dw 37,37,37,37,37,37,37,37,0,0,0,0
  dw 37,37,37,37,37,37,37,37,37,37,37,37
  dw 37,37,37,37,37,37,37,37,37,37,37,37
  dw 37,37,37,37,0,0,0,0,37,37,37,37
  dw 37,14,13,37,8,17,2,36,13,4,22,13
  dw 4,19,36,13,4,19,37,37,37,37,37,37
  dw 0,0,0,0,37,37,37,37,37,37,37,37
  dw 37,37,37,37,37,37,37,37,37,37,37,37
  dw 37,37,37,37,37,37,37,37,0,0,0,0
  dw 37,37,37,37,37,37,37,37,37,37,37,37
  dw 37,37,37,37,37,37,37,37,37,37,37,37
  dw 37,37,37,37,0,0,0,0,37,37,37,2
  dw 14,3,4,37,1,24,37,37,3,14,23,38
  dw 18,15,0,2,4,36,15,11,37,37,37,37
  dw 0,0,0,0,41,41,41,41,41,41,41,41
  dw 41,41,41,41,41,41,41,41,41,41,41,41
  dw 41,41,41,41,41,41,41,41,0,0,0,0

pal2:
  db 41,10,80,0,5,0,6,0,22,1,39,2
  db 40,2,57,3,74,4,106,6,123,7,143,8
  db 173,10,255,15,1,0,255,15,255,15,0,15
  db 0,13,0,11,0,8,0,6,153,9,136,8
  db 119,7,119,7,102,6,85,5,68,4,51,3
  db 34,2,34,2,240,15,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,255,15

tiles2:
 include 'tiles2.inc'

pals:
 include 'pals.inc'

logo:
 include 'ws.inc'

ypos:
 include 'ypos.inc'

light:
 include 'light.inc'

track:
 include 'track.inc'
