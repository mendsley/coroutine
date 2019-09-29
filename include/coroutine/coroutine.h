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

#pragma once

#include <stddef.h>

namespace coroutine
{
	/**
	 * Opqaue handle to a coroutine
	 */
	struct H;

	/**
	 * Entry point into a coroutine
	 *
	 * returns a coroutine handle to execute on completion
	 */
	typedef H* Entry(H* coroutine, void* context);

	/**
	 * Convert the current thread into a coroutine
	 */
	H* convertToCoroutine();

	/**
	 * Convert the coroutine back into a standard thread
	 *
	 *   Handle must have been created with convertThreadToCoroutine
	 */
	void convertToThread(H* h);

	/**
	 * Create a new coroutine
	 *
	 *		entry:     Entry point for the coroutine
	 *		arg:       Context data for the coroutine
	 *		stackSize: Size for the coroutine stack (0 = default)
	 */
	H* create(Entry* entry, void* arg, size_t stackSize = 0);

	/**
	 * Destroys a completed coroutine
	 *
	 *   Handle must have been creted with create() and coroutine
	 *   must have terminated
	 */
	void destroy(H* h);

	/**
	 * Susped the current coroutine (from) and resume the target
	 * coroutine (to)
	 */
	void switchTo(H* from, H* to);
}
