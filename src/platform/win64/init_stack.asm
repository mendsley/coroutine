; Copyright 2011-2016 Matthew Endsley
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
	mov r9, rsp
	mov rsp, qword ptr [rcx]

	; Win64 ABI unwind boundary
	push 0

	; Additional Shadow space for Win64 ABI (32 + locals) + alignment
	sub rsp, 24

	; Local variables to coroutine_private_entry
	push rdx
	push r8

	; Return address
	lea rax, coroutine_private_entry
	push rax

	; Seed the volatile register set
	sub rsp, 64

	; Save new stack pointer and restore callers stack
	mov qword ptr [rcx], rsp
	mov rsp, r9
	ret

coroutine_private_init_stack ENDP


;
; Entry point for a coroutine
;
coroutine_private_entry PROC FRAME
	; rdx: arg, r8: entry, rcx: coro
	; rbx: coro
	.allocstack 40
	.endprolog

	; Restore local arguments (Keep shadow space)
	mov rdx, qword ptr [rsp]
	mov r8, qword ptr [rsp + 8]

	; coro->ctx_status = CORO_RUNNING
	mov qword ptr [rax+8], 1

	; Save coro across call boundary
	mov rbx, rcx

	; call into user entry point
	call r8

	; coroutine has terminated. return to coroutine at <rax>

	; Remove space for locals
	add rsp, 40

	; coro->ctx_status = CORO_FINISHED
	mov qword ptr [rbx+8], 2

	; coroutine_private_switch(coro, return)
	mov rcx, rbx
	mov rdx, rax
	jmp coroutine_private_switch

coroutine_private_entry ENDP

END
