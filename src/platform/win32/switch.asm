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

;
; void coroutine_private_switch(coroutine::H* from, coroutine::H* to);
;
coroutine_private_switch PROC public
	; ecx: from, edx: to

	; Acquire arguments
	mov ecx, dword ptr [esp+4]
	mov edx, dword ptr [esp+8]

	; Save volatile registers
	push ebp
	push ebx
	push edi
	push esi

	; Save current stack
	mov dword ptr [ecx], esp

	; Restore target stack
	mov esp, dword ptr [edx]

	; Restore volatile registers
	pop esi
	pop edi
	pop ebx
	pop ebp

	ret

coroutine_private_switch ENDP

END
