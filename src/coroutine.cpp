/**
* Copyright 2016-2019 Matthew Endsley
* All rights reserved
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted providing that the following conditions
* are met:
* 1. Redistributions of source code must retain the above copyright
*    notice, this list of conditions and the following disclaimer.
* 2. Redistributions in binary form must reproduce the above copyright
*    notice, this list of conditions and the following disclaimer in the
*    documentation and/or other materials provided with the distribution.
*
* THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
* IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
* ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
* DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
* OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
* HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
* STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
* IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
* POSSIBILITY OF SUCH DAMAGE.
*/

#include "coroutine/coroutine.h"
#include <stdlib.h>

#if !defined(COROUTINE_DEFAULT_STACK_SIZE)
#	define COROUTINE_DEFAULT_STACK_SIZE (1<<20)
#endif

#if !defined(COROUTINE_ABORT)
#	include <assert.h>
#	define COROUTINE_ABORT(msg) do { assert(false && msg); abort(); } while(0)
#endif

namespace { struct Context; }

// implemented in assembly per platform. See src/<platform>/
extern "C"
{
	// Initialize the stack for a newly created coroutine
	void coroutine_private_init_stack(coroutine::H* coro, coroutine::Entry* entry, void* arg);

	// Handle the switching of coroutines
	void coroutine_private_switch(coroutine::H* from, coroutine::H* to);
}

using namespace coroutine;

namespace
{
	// Status flags for coroutine
	enum CoroutineStatus : uintptr_t
	{
		CORO_RUNNING = 1,
		CORO_FINISHED = 2,
	};
}

struct coroutine::H
{
	void* stack;
	uintptr_t status;

	void* raw_stack;
};

#if defined(_WIN32) || defined(_WIN64)
#	define aligned_malloc(alignment, size) _aligned_malloc((size), (alignment))
#	define aligned_free(alignment, ptr) _aligned_free(ptr)
#else
#	define aligned_malloc(alignment, size) memalign((alignment), (size))
#	define aligned_free(alignment, ptr) free(ptr)
#endif


extern "C" void coroutine_private_entry(coroutine::H* coro, coroutine::Entry* entry, void* arg)
{
	coro->status = CORO_RUNNING;
	auto* next = (*entry)(coro, arg);
	coro->status = CORO_FINISHED;
	switchTo(coro, next);
}


H* coroutine::convertToCoroutine()
{
	H* coro = static_cast<H*>(aligned_malloc(16, sizeof(H)));
	coro->status = CORO_RUNNING;
	return coro;
}


void coroutine::convertToThread(H* h)
{
	if (nullptr != h->raw_stack)
	{
		COROUTINE_ABORT("Current coroutine is not main coroutine. cannot convert back to thread");
	}

	aligned_free(16, h);
}

H* coroutine::create(Entry* entry, void* arg, size_t stackSize)
{
	if (stackSize == 0)
	{
		stackSize = COROUTINE_DEFAULT_STACK_SIZE;
	}

	H* coro = static_cast<H*>(aligned_malloc(16, sizeof(H)));
	coro->status = 0;
	coro->raw_stack = aligned_malloc(16, stackSize);
	// stack grows downward
	coro->stack = static_cast<char*>(coro->raw_stack) + stackSize;

	coroutine_private_init_stack(coro, entry, arg);
	return coro;
}

void coroutine::destroy(H* h)
{
	if (CORO_FINISHED != h->status)
	{
		COROUTINE_ABORT("Attempt to destroy a running coroutine");
	}

	aligned_free(16, h->raw_stack);
	aligned_free(16, h);
}

void coroutine::switchTo(H* from, H* to)
{
	if (to != from)
	{
		coroutine_private_switch(from, to);
	}
}
