@ Copyright 2011-2016 Matthew Endsley
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
.align 8
.arm


@
@ void coroutine_private_init_stack(coroutine::H* coro, coroutine::Entry* entry, void* arg);
@
.global coroutine_private_init_stack
coroutine_private_init_stack:
	@ r0: coro, r1: entry, r2: arg
	@ r3: previous stack pointer
	.fnstart

	sub sp, sp, #(8 * 4)]
	stp r19, r20, [sp, #(8 * 0)]
	stp r21, lr, [sp, #(8 * 2)]
	.save {r19-r21, lr}

	@ Switch to coroutine's stack
	mov r3, sp
	ldr sp, [r0]

	@ Store initial context for coroutine
	ldr lr, =coroutine_private_bootstrap
	mov r19, r0
	mov r20, r1
	mov r21, r2

	sub sp, sp, #(8 * 20)
	stp r19, r20, [sp, #(8 * 0)]
	stp r21, r22, [sp, #(8 * 2)]
	stp r23, r24, [sp, #(8 * 4)]
	stp r25, r26, [sp, #(8 * 6)]
	stp r27, r28, [sp, #(8 * 8)]
	stp r29, lr,  [sp, #(8 * 10)]
	stp d8,  d9,  [sp, #(8 * 12)]
	stp d10, d11, [sp, #(8 * 14)]
	stp d12, d13, [sp, #(8 * 16)]
	stp d14, d15, [sp, #(8 * 18)]

	@ Save coro->stack and switch back to caller stack
	str sp, [r0]
	mov sp, r3

	ldp r19, r20, [sp, #(8 * 0)]
	ldp r21, lr, [sp, #(8 * 2)]
	add sp, sp, #(8 * 4)
	ret
	.fnend

@
@ Entry point for a coroutine. Unpack context and jump into coroutine_private_entry
@
.global coroutine_private_bootstrap
coroutine_private_bootstrap:
	@ r19: coro, r20: entry, r21: arg
	.fnstart

	@ Move coro, entry, arg into position
	mov r0, r19
	mov r1, r20
	mov r2, r21

	b coroutine_private_entry
	.fnend

