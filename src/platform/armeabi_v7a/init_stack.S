@ Copyright 2016-2019 Matthew Endsley
@ All rights reserved
@
@ Redistribution and use in source and binary forms, with or without
@ modification, are permitted providing that the following conditions
@ are met:
@ 1. Redistributions of source code must retain the above copyright
@    notice, this list of conditions and the following disclaimer.
@ 2. Redistributions in binary form must reproduce the above copyright
@    notice, this list of conditions and the following disclaimer in the
@    documentation and/or other materials provided with the distribution.
@
@ THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
@ IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
@ WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
@ ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
@ DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
@ DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
@ OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
@ HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
@ STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
@ IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
@ POSSIBILITY OF SUCH DAMAGE.

.section .text
.align 4
.arm


@
@ void coroutine_private_init_stack(coroutine::H* coro, coroutine::Entry* entry, void* arg);
@
.global coroutine_private_init_stack
coroutine_private_init_stack:
	@ r0: coro, r1: entry, r2: arg
	@ r3: previous stack pointer
	.fnstart

	push {r4-r6, lr}
	.save {r4-r6, lr}

	@ Switch to coroutine's stack
	mov r3, sp
	ldr sp, [r0]

	@ Store initial context for coroutine
	ldr lr, =coroutine_private_bootstrap
	mov r4, r0
	mov r5, r1
	mov r6, r2
	push {r4-r12, lr}
	vpush {s16-s31}

	@ Save coro->stack and switch back to caller stack
	str sp, [r0]
	mov sp, r3

	pop {r4-r6, pc}
	.fnend

@
@ Entry point for a coroutine. Unpack context and jump into coroutine_private_entry
@
.global coroutine_private_bootstrap
coroutine_private_bootstrap:
	@ r4: coro, r5: entry, r6: arg
	.fnstart

	@ Move coro, entry, arg into position
	mov r0, r4
	mov r1, r5
	mov r2, r6

	b coroutine_private_entry
	.fnend
