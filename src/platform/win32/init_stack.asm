; Copyright 2016-2019 Matthew Endsley
; All rights reserved
;
; Redistribution and use in source and binary forms, with or without
; modification, are permitted providing that the following conditions
; are met:
; 1. Redistributions of source code must retain the above copyright
;    notice, this list of conditions and the following disclaimer.
; 2. Redistributions in binary form must reproduce the above copyright
;    notice, this list of conditions and the following disclaimer in the
;    documentation and/or other materials provided with the distribution.
;
; THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
; IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
; WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
; ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
; DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
; OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
; HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
; STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
; IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
; POSSIBILITY OF SUCH DAMAGE.

.model flat, C
.686p
.code

EXTERN coroutine_private_switch : PROC

;
; void coroutine_private_init_stack(coroutine::H* coro, coroutine::Entry* entry, void* arg);
;
coroutine_private_init_stack PROC public
	; eax: coro, ecx: entry, edx: arg

	; Save registers and stack
	push ebp
	mov ebp, esp
	push ebx
	push edi
	push esi
	mov ecx, esp

	; Acquire arguments
	mov ebx, dword ptr [ebp+8]
	mov edi, dword ptr [ebp+12]
	mov esi, dword ptr [ebp+16]

	; Switch to the new coroutine's stack
	mov esp, dword ptr [ebx]

	; Return address
	push 0
	lea eax, coroutine_private_bootstrap
	push eax

	; Seed volatile registers
	push 0 ; ebp
	push ebx
	push edi
	push esi

	; Save the new stack pointer
	mov dword ptr [ebx], esp

	; Restore registers and stack
	mov esp, ecx
	pop esi
	pop edi
	pop ebx
	pop ebp

	ret

coroutine_private_init_stack ENDP


EXTERN coroutine_private_entry : PROC
;
; Entry point for a coroutine
;
coroutine_private_bootstrap PROC public
	; push arguments to private_entry
	push esi
	push edi
	push ebx

	call coroutine_private_entry
	; does not return

coroutine_private_bootstrap ENDP

END
