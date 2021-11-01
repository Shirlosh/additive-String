; Shirley Alus 207023813
; asm3_q3_data file must contain - num = string of digits
;								 - n = length of num
;								 - result string

; the Program:
; get a string of numbers - if the string is an adittive string, prints the addends else prints false

INCLUDE irvine32.inc
INCLUDE asm3_q3_data.inc

.data
strName BYTE 'Shirley Alus. ID: 207023813', 10, 13, 10, 13, 0
FalseMsg BYTE 'FALSE', 0

.code
myMain proc

	mov edx, OFFSET strName 
	call writeString
	
	mov edx, OFFSET num
	call writeString
	call crlf
	
	push offset num
	push N
	push offset res
	call additiveSequence
	cmp al, 1
	je PrintRes

	mov edx, OFFSET FalseMsg
	call writeString
	call ExitProcess

	PrintRes:
	mov edx, OFFSET res 
	call writeString

	call ExitProcess

myMain endp


IsValid proc
;-----------------------------------
; check if the number is valid
; receives:	- offset of the string (stack 1st push)
;			- the size of the string (stack 2nd push)
; returns: 	- al = 1 if the num is valid
;			- al = 0 if the number is invalid 
;-----------------------------------
strSize = 8
theStr = strSize + 4

push ebp
mov ebp, esp

;chech if the first char is 0
mov eax, [ebp + theStr]
mov eax, [eax]
cmp al, '0'
jne retTRUE

mov eax, [ebp + strSize]
sub eax, 1
jna retFALSE
jmp retTRUE

retFALSE:
	mov al, 0
	jmp DONE

retTRUE:
	mov al, 1
	
DONE:
	mov esp, ebp
	pop ebp
	ret 8

IsValid endp

Val proc USES edx
;-----------------------------------
; convert a numeric string to number
; receives:	- the string (stack 1st push)
;			- the string size(stack 2nd push)
;			- the require position (stack 3rd push)
; returns: 	- if ok - al = numeric value of the string in the required position
;			- else al= 0
;-----------------------------------

strPos = 12
strSize = strPos + 4
theStr = strSize + 4

	push ebp
	mov ebp, esp

	mov eax , [ebp + strSize]
	sub eax, [ebp + strPos]
	jna retFALSE

	mov edx, [ebp + strPos]
	mov eax, [ebp + theStr]
	add eax, edx
	mov eax, [eax]
	sub eax, '0'
	jmp Done

retFALSE:
	mov al, 0

Done:
	mov esp, ebp
	pop ebp
	ret 12

Val endp

AddString proc USES edx esi edi ebx ecx
;-----------------------------------
; convert a numeric string to number
; receives:	- Offset of string A (stack 1st push)
;			- Offset of string B (stack 2nd push)
;			- offset of result string (stack 3rd push)
;			- size of string A (stack 4th push)
;			- size of string B (stack 5th push)
; returns: 	- the addition of the strings a+b in resultString
;			- the size of the string in eax

; registers roles:
; eax - carry						; edx - quotient
; esi - A index						; edi - B index
; ebx - res string					; ecx - divisor
;-----------------------------------

BSize = 8 + 20
ASize = BSize + 4
resString = ASize + 4 
BString = resString + 4
AString = BString + 4

	push ebp
	mov ebp, esp
	mov esi, [ebp + ASize]
	mov edi, [ebp + BSize]
	dec esi
	dec edi
	mov ebx, [ebp + resString] 
	mov ecx, 10d
	mov al, 0

AddLoop:

	mov dl, 0
	mov dl, al

	push [ebp + AString]
	push [ebp + ASize]
	push esi
	call Val
	add edx, eax
	
	push [ebp + BString]
	push [ebp + BSize]
	push edi
	call Val
	add edx, eax
	
	mov eax, 0
	mov al, dl
	mov edx, 0
	div cx
	
	add edx, '0'
	mov [ebx], edx

	inc ebx
	add esi, edi ; to check
	jz EXT
	js EXT
	sub esi, edi
	dec esi
	dec edi


jmp AddLoop

EXT:
cmp eax, 0
je DONE
add eax, '0'
mov [ebx], eax
inc ebx


DONE:
	mov eax, 0
	mov [ebx], eax 
	sub ebx, [ebp + resString]
	push [ebp + resString]
	push ebx ; size
	call ReverseString
	mov eax, ebx
	mov esp, ebp
	pop ebp

ret 20

AddString endp

ReverseString proc USES ecx esi edi
;-----------------------------------
; reverse a given string
; receives:	- Offset of the string (stack 1st push)
;			- size of the string (stack 2nd push)
; returns: 	- reverse and saves the string 
;-----------------------------------

; registers roles:
; edi - right index				; esi - left index
; ecx loop counter

strSize = 8 + 12
theStr = strSize + 4

	push ebp
	mov ebp, esp
	mov esi, [ebp + theStr] ; left index
	mov edi, esi ; right index
	mov ecx, [ebp + strSize]
	add edi, ecx
	shr ecx, 1 ; div 2 floor
	dec edi
	cmp ecx, 0
	je ENDF

ReverseLoop:
	
	;swap
	push ecx
	push [esi]
	mov cl, [edi]
	mov [esi], cl

	pop ecx
	mov [edi], cl
	pop ecx
	
loop ReverseLoop

ENDF:
	mov esp, ebp
	pop ebp
	ret 8
ReverseString endp

CmpStr proc USES ecx edi esi 
;-----------------------------------
; reverse a given string
; receives:	- Offset of stringA (stack 1st push)
;			- size of stringA (stack 2nd push)
;			- Offset of stringB (stack 3rd push)
;			- size of stringB (stack 4th push)
; returns: 	- al = 1 if its addition sequence
;			- al = 0 else
;-----------------------------------

; registers roles:
; esi - StrA Offset				; edi - StrB Offset
; ecx - loop counter

BSize = 8 + 12
StrB = BSize + 4
ASize = StrB + 4
StrA = ASize + 4
	
	push ebp
	mov ebp, esp

	mov eax, [ebp + BSize]
	cmp eax, [ebp + ASize]
	jne isFALSE

	mov ecx, [ebp + BSize]
	mov esi, [ebp + StrA]
	mov edi, [ebp + StrB]

cmpLoop:
	
	push ecx
	mov ecx, 0
	mov cl, [edi]
	cmp [esi], cl
	pop ecx
	jne isFALSE
	inc esi
	inc edi

loop cmpLoop

mov al, 1
jmp EndCmp
	
isFALSE:
	mov al, 0

EndCmp:
	mov esp, ebp
	pop ebp
	;pop ecx

	ret ;20

CmpStr endp

LenOf proc USES edx
;-----------------------------------
; push back to an empty string (get an empty string and concate other)
; receives:	- offset of string (stack 1st push)
; returns:  - the len of the string
;-----------------------------------

; registers roles:
; edx - string handle
theStr = 8 + 4

	push ebp
	mov ebp, esp
	mov eax, 0
	mov edx, [ebp + theStr]

	toLOOP:
		push edx
		mov edx, [edx]
		cmp edx, 0
		pop edx
		je endLOOP
		inc edx
		inc eax

	jmp toLOOP

endLOOP:
	mov esp, ebp
	pop ebp
	ret 4

LenOf endp

SubString proc USES edx ebx
;-----------------------------------
; reverse a given string
; receives:	- Offset of the string (stack 1st push)
;			- size of the string (stack 2nd push)
;			- start position (stack 3rd push)
;			- new len (stack 4th push)
;			- offset of result string (stack 5th push)
; returns: 	- al = 1 if its addition sequence
;			- al = 0 else
;-----------------------------------

; registers roles:
; ebx - strRes Offset				; edx - current char to copy and helper

StrRes = 8 + 8
ResLen = StrRes + 4
Pos = ResLen + 4
StrSize = Pos + 4
theStr = StrSize + 4

	push ebp
	mov ebp, esp
	mov al, 1
	mov edx, [ebp + Pos] ; pos validation
	cmp	[ebp + StrSize], edx
	jb retFALSE

	add edx, [ebp + theStr] ; str[pos]
	mov ebx, [ebp + StrRes]
	mov edx, [edx] ; edx = *edx
	mov [ebx], dl
	inc ebx ; next result string cell
	mov dl, 0
	mov [ebx], dl
	inc byte ptr [ebp + pos] ; next position
	mov dl, [ebp + ResLen]
	dec dl
	cmp dl, 0
	jbe SubStringEnd ; reached to the end

	push [ebp + theStr]
	push [ebp + StrSize]
	push [ebp + Pos]
	push edx
	push ebx
	call SubString ; keep copying
	jmp SubStringEnd

retFALSE:
	mov al, 0

SubStringEnd:
	and al, 1
	mov esp, ebp
	pop ebp
	ret 20

SubString endp

checkAddition proc USES ebx edx ecx
;-----------------------------------
; get 2 Consecutive numbers (A and B) and a string C and return if the summary of A and B is a sequence of C or its SubStrings
; receives:	- Offset of stringA (stack 1st push)
;			- size of stringA (stack 2nd push)
;			- Offset of stringB (stack 3rd push)
;			- size of stringB (stack 4th push)
;			- Offset of stringC (stack 5rd push)
;			- size of stringC (stack 6th push)
;			- Offset of Res (stack 5rd push)
; returns: 	- al = 1 if its addition sequence
;			- al = 0 else
;-----------------------------------
; registers roles:
; ebx - sum size				; edx - current char to copy and helper
; ecx - sum offset				; 

OfRes = 8 + 12
CSize = ofRes + 4
StrC = CSize + 4
BSize = StrC + 4
StrB = BSize + 4
ASize = StrB + 4
StrA = ASize + 4
Sum = -N
CSub = -2*N

	push ebp
	mov ebp, esp
	sub esp, 2*N

	;are a str and b str valid
	push [ebp + StrA]
	push [ebp + ASize]
	call IsValid
	cmp al, 0
	je EndCheckAddition

	push [ebp + StrB]
	push [ebp + BSize]
	call IsValid
	cmp al, 0
	je EndCheckAddition
	
	lea ecx, [ebp + Sum] ; init ecx with sum offset
	;init sum
	push [ebp + StrA]
	push [ebp + StrB]
	push ecx
	push [ebp + ASize]
	push [ebp + BSize]
	call AddString 
	mov ebx, eax

	; if sum == c
	push [ebp + StrC]
	push [ebp + CSize]
	push ecx
	push eax ; sum size
	call CmpStr 
	cmp al, 1
	je PushAndEnd ; return al = 1

	;if sum.size >= c.size
	cmp ebx, [ebp + CSize]
	mov al, 0
	jae EndCheckAddition

	;if sum != csubstr 
	lea edx, [ebp + CSub] 
	push [ebp + StrC]
	push [ebp + CSize]
	push 0
	push ebx
	push edx
	call SubString

	push edx
	push ebx
	push ecx
	push ebx
	call CmpStr
	cmp al, 0
	je EndCheckAddition ; return al = 0

	;** ELSE RECURSIVE CALL**
	push [ebp + ofRes]
	push ecx
	push ebx
	call PushBack ;push sum
	add [ebp + ofRes], al
	
	push [ebp + StrC]
	push [ebp + CSize]
	push ebx
	sub [ebp + CSize], ebx ; about to delete |ebx| chars
	push [ebp + CSize]
	push edx
	call SubString ; create new c substring
	
	push [ebp + StrB]
	push [ebp + BSize]
	push ecx
	push ebx
	push edx
	push [ebp + CSize]
	push [ebp + ofRes]
	call checkAddition ;recursive call


	EndCheckAddition:
	mov esp, ebp
	pop ebp
	ret 28

PushAndEnd:
	push [ebp + ofRes]
	push ecx
	push ebx
	call PushBack ;push sum
	mov al, 1
	jmp EndCheckAddition

checkAddition endp

additiveSequence proc USES ebx edx ecx
;-----------------------------------
; get 2 Consecutive numbers (A and B) and a string C and return if the summary of A and B is a sequence of C or its SubStrings
; receives:	- Offset of a string (stack 1st push)
;			- size of string (stack 2nd push)
;			- Offset of ResultString (stack 3rd push)
; returns: 	- al = 1 if its addition sequence
;			- al = 0 else

; registers roles:
; ecx - loops counter				; edx - data helper
; ebx - offset of the current substring
;-----------------------------------
theRes = 8 + 12
StrSize = theRes + 4
theStr = StrSize + 4
i = -4
j = -8
subStringStart = -12

	push ebp
	mov ebp, esp
	sub esp, [ebp + strSize]
	sub esp, 16d

	mov ecx, 1 ; init counters
	mov [ebp + i], ecx
	mov [ebp + j], ecx

	dec byte ptr [ebp + strSize]
	mov ecx, [ebp + strSize] 
	shr ecx, 1
	lea ebx, [ebp + subStringStart]
	sub ebx, [ebp + strSize]

iLOOP:
	
	push ecx
	mov ecx, [ebp + strSize] 
	sub ecx, [ebp + i]
	shr ecx , 1

	jLOOP:

		lea ebx, [ebp + subStringStart]
		sub ebx, [ebp + strSize]

		push [ebp + theStr]
		push [ebp + StrSize]
		push 0
		push [ebp + i]
		push ebx
		call SubString
		push ebx ; push a string params
		push [ebp + i]

		add ebx, [ebp + i]
		inc ebx
		push [ebp + theStr]
		push [ebp + StrSize]
		push [ebp + i]
		push [ebp + j]
		push ebx
		call SubString
		push ebx ; push b string params plus i
		push [ebp + j]

		add ebx, [ebp + j]
		inc ebx
		push [ebp + theStr]
		push [ebp + StrSize]
		mov edx, [ebp + i]
		add edx, [ebp + j]
		push edx ; pos
		mov edx, [ebp + strSize]
		sub edx, [esp] ; len (till end minus pos)
		push edx
		push ebx
		call SubString
		push ebx ; push c string params + j
		push edx
		push [ebp + theRes]
		call checkAddition
		cmp al, 0
		je continue
		jmp FOUND

		continue:	
		inc byte ptr [ebp + j]

	loop jLOOP

	mov [ebp + j], al
	inc byte ptr [ebp + j]
	inc dword ptr [ebp + i]
	pop ecx
	
loop iLOOP

mov al, 0
jmp EndAdditive

FOUND:

	push [ebp + theRes]
	call LenOf
	push [ebp + theRes]
	push eax
	lea ebx, [ebp + subStringStart] 
	sub ebx, [ebp + strSize]
	mov ecx, [ebp + i]
	shl ecx, 1
	add ebx, ecx
	push ebx
	push [ebp + j]
	call PushFront ; bug

	push [ebp + theRes]
	call LenOf
	push [ebp + theRes]
	push eax
	sub ebx, ecx
	push ebx
	shr ecx, 1
	push [ebp + i]
	call PushFront
	mov al, 1

EndAdditive:

	mov esp, ebp
	pop ebp
	ret 12

additiveSequence endp

PushBack proc USES ecx edx edi
;-----------------------------------
; push back to an empty string (get an empty string and concate other)
; receives:	- offset of res string (stack 1st push)
;			- offset of string to push (stack 2nd push)
;			- size of string to push (stack 3rd push)
;
; returns:  - the new size of the string
; registers roles:
; esi - Offset of the str to push				; edi - offset of the res str
; ecx - loop counter
;-----------------------------------
PSize = 8 + 12
PushStr = PSize + 4
resStr = PushStr + 4

	push ebp
	mov ebp, esp
	mov ecx, [ebp + PSize]
	mov edx, [ebp + PushStr]
	mov edi, [ebp + resStr]
	mov eax, 0
	;insert the new data
	cLOOP:
		push edx
		mov edx, [edx]
		mov [edi], edx 
		pop edx
		inc edi
		inc edx
		inc eax

	loop cLOOP
	inc eax
	mov edx, ' '
	mov [edi], edx
	inc edi
	mov edx, 0
	mov [edi], edx ; put ' ', 0 in the end
	mov esp, ebp
	pop ebp
	ret 12

PushBack endp

PushFront proc USES ecx edx
;-----------------------------------
; push back to an empty string (get an empty string and concate other)
; receives:	- offset of res string (stack 1st push)
;			- size of res string (stack 2st push)
;			- offset of string to push (stack 3rd push)
;			- size of string to push (stack 4th push)
; registers roles:
; ecx - offset of res				;edx - sizeof res
;-----------------------------------
PSize = 8 + 8
PushStr = PSize + 4
RSize =  PushStr + 4
resStr = RSize + 4
TempStr = 4

	push ebp
	mov ebp, esp
	mov ecx, [ebp + RSize]
	shl ecx, 1
	sub esp, ecx ; esp - 2*size of result
	mov edx, esp
	
	push [ebp + resStr]
	push [ebp + RSize]
	push 0
	push [ebp + RSize]
	push edx
	call SubString

	;override and push back the new string
	push [ebp + resStr]
	push [ebp + PushStr]
	push [ebp + PSize]
	call PushBack

	;push back the rest of the string
	mov ecx, [ebp + resStr]
	add ecx, eax ; eax contains size from pushBackreturn
	push ecx
	push edx
	push [ebp + RSize]
	call PushBack

	mov esp, ebp
	pop ebp
	ret 12

PushFront endp

end myMain



