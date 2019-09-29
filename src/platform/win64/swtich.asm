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

;
; void coroutine_private_switch(coroutine::H* from, coroutine::H* to);
;
coroutine_private_switch PROC public FRAME
	; rcx: from, rdx: to
	.endprolog

	; Save volatile registers
	push rbx
	push rbp
	push rdi
	push rsi
	push r12
	push r13
	push r14
	push r15

	; from->stack <stack>
	mov qword ptr [rcx], rsp

	; <stack> = coro->stack
	mov rsp, qword ptr [rdx]

	; Restore volatile registers
	pop r15
	pop r14
	pop r13
	pop r12
	pop rsi
	pop rdi
	pop rbp
	pop rbx

	ret

coroutine_private_switch ENDP

END
