workspace "coroutine"
	platforms {
		"x32",
		"x64",
	}

	configurations {
		"Debug",
	}

	symbols "on"

	dofile "coroutine.lua"

	project "example"
		kind "ConsoleApp"

		links {
			"coroutine",
		}

		includedirs {
			"include/",
		}

		files {
			"example/**",
		}

workspace "coroutine"
	startproject "example"
