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
@ void coroutine_private_switch(coroutine::H* from, coroutine::H* to);
@
.global coroutine_private_switch
coroutine_private_switch:
	@ r0: from, r1: to
	.fnstart

	@ Save volatile registers for current coroutine
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
	.save {r19-r29, lr}
	.vsave {d12-d15}
	.pad #64

	@ from->stack = <stack>
	str sp, [r0]

	@ <stack> = to->stack
	ldr sp, [r1]

	@ Restore volatile registers and return to coroutine
	ldp r19, r20, [sp, #(8 * 0)]
	ldp r21, r22, [sp, #(8 * 2)]
	ldp r23, r24, [sp, #(8 * 4)]
	ldp r25, r26, [sp, #(8 * 6)]
	ldp r27, r28, [sp, #(8 * 8)]
	ldp r29, lr,  [sp, #(8 * 10)]
	ldp d8,  d9,  [sp, #(8 * 12)]
	ldp d10, d11, [sp, #(8 * 14)]
	ldp d12, d13, [sp, #(8 * 16)]
	ldp d14, d15, [sp, #(8 * 18)]
	add sp, sp, #(8 * 20)

	ret
	.fnend
