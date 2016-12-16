project "coroutine"
	kind "StaticLib"

	local COROUTINE_PATH = path.getdirectory(_SCRIPT) .. "/"

	includedirs {
		COROUTINE_PATH .. "include/",
	}

	files {
		COROUTINE_PATH .. "include/**",
		COROUTINE_PATH .. "src/*.cpp",
	}

	filter {"system:windows", "architecture:x64"}
		files {
			COROUTINE_PATH .. "src/platform/win64/**",
		}

	filter {"system:windows", "architecture:x32"}
		files {
			COROUTINE_PATH .. "src/platform/win32/**",
		}

	filter {"system:android", "architecture:armeabi_v7a"}
		files {
			COROUTINE_PATH .. "src/platform/armeabi_v7a/**"
		}

	filter {}
