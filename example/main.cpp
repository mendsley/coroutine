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

#include <stdio.h>
#include <coroutine/coroutine.h>

static coroutine::H* init(coroutine::H* coro, void* context)
{
	coroutine::H* main = static_cast<coroutine::H*>(context);

	printf("In init - switching back\n");
	coroutine::switchTo(coro, main);

	printf("Returning from init\n");

	return main;
}


#include <Windows.h>

static void WINAPI fiberEntry(void* ptr)
{
	SwitchToFiber(ptr);
}

int main()
{
	void* f = ConvertThreadToFiber(0);
	void* f1 = CreateFiber(0, fiberEntry, f);
	SwitchToFiber(f1);
	DeleteFiber(f1);
	f1 = CreateFiber(0, fiberEntry, f);
	SwitchToFiber(f1);
	DeleteFiber(f1);
	ConvertFiberToThread();

	coroutine::H* mainCoro = coroutine::convertToCoroutine();
	coroutine::H* coro = coroutine::create(init, mainCoro);

	printf("Switching to coro #1\n");
	coroutine::switchTo(mainCoro, coro);

	printf("Switching to coro #2\n");
	coroutine::switchTo(mainCoro, coro);

	printf("Destroying coro\n");
	coroutine::destroy(coro);

	printf("Converting back to thread\n");
	coroutine::convertToThread(mainCoro);

	printf("Done\n");
}
