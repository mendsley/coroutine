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

.code

EXTERN coroutine_private_switch : PROC

;
; void coroutine_private_init_stack(coroutine::H* coro, coroutine::Entry* entry, void* arg);
;
coroutine_private_init_stack PROC public FRAME
	; rcx: coro, rdx: arg, r8: entry
	; r9: original rsp
	.endprolog

	; Save stack pointer and switch to the new coroutine's stack
	push rbx
	push rdi
	push rsi
	mov r9, rsp

	mov rsp, qword ptr [rcx]

	; Win64 ABI unwind boundary
	push 0

	; ABI boundary address
	lea rax, coroutine_private_bootstrap
	push rax

	; Seed volatile registers
	mov rbx, rcx
	mov rdi, rdx
	mov rsi, r8
	push rbx
	push 0		; ebp
	push rdi
	push rsi
	push 0		; r12
	push 0		; r13W
	push 0		; r14
	push 0		; r15

	; Save new stack pointer
	mov qword ptr [rcx], rsp

	; Restore caller stack
	mov rsp, r9
	pop rsi
	pop rdi
	pop rbx
	ret

coroutine_private_init_stack ENDP


EXTERN coroutine_private_entry : PROC

;
; Entry point for a coroutine
;
coroutine_private_bootstrap PROC public FRAME
	; rbx: coro, rdi: arg, rsi: entry

	; Shadow space + alignment: Win64 ABI
	sub rsp, 40
	.allocstack 40
	.endprolog

	; Setup argumetns to entry point
	mov rcx, rbx
	mov rdx, rdi
	mov r8, rsi

	call coroutine_private_entry
	; does not retrun

coroutine_private_bootstrap ENDP

END
