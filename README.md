# IcePremake

This repository contains the premake scripts that i frequently used in other projects.

In short, it provides a package management system like CMake.

# Usage

1. Use this repository as submodule.

``` bash
cd path-to-your-project
git submodule add https://github.com/IceSandwich/IcePremake.git premake
```

2. Download premake prebuilt binaray.

Go to the [premake release](https://github.com/premake/premake-core/releases) and download the prebuilt binary for your platform.

Extract the `premake5.exe` file into the `path-to-your-project/premake/bin` folder.

3. Write your modules.

We organize the struture as follows(Just a suggestion, not mandatory).

``` txt
├─ProjectLib
│  ├─src
│  │   └─**.cpp
│  └─premake5.lua
├─ProjectExe
│  ├─src
│  │   └─test.cpp
│  └─premake5.lua
├─vendor
│  ├─spdlog
│  │  └─...
│  └─dependencies.lua
├─premake
│  ├─bin
│  │  └─premake5.exe
│  └─**.lua
└─premake5.lua
```

In the `premake5.lua` file under the project root folder.

``` lua
workspace "MyProject"
    architecture "x64"
    startproject "ProjectExe"

    configurations { "Debug", "Release" }

include "ProjectLib"
include "ProjectExe"
```

In the `vendor/dependencies.lua` file, you should write the dependencies that your project needs.

``` lua
DependenciesDir = "%{wks.location}/vendor"

-- Store all your dependencies in a table.
Dependencies = {}

-- Here use vulkan and spdlog as an example.
VULKAN_SDK = os.getenv("VULKAN_SDK")
print("Detected Vulkan SDK: " .. VULKAN_SDK)
Dependencies["Vulkan"] = {
	-- IncludeDirectories, LinkDirectories, LinkLibraries are optional.
	-- You can use one of them or two of them.
	PackageName = "Vulkan",
	IncludeDirectories = {
		VULKAN_SDK .. "/Include",
	},
	LinkDirectories = {
		VULKAN_SDK  .. "/Lib",
	},
	LinkLibraries  = {
		"vulkan-1",
	}
}
Dependencies["Spdlog"] = { -- spdlog is a header only library, so you don't need to link.
	PackageName = "Spdlog",
	IncludeDirectories = {
		"%{DependenciesDir}/spdlog/include",
	},
}
-- Or use prebuilt library from interneet
if os.target() == "windows" then
	local glfwDir = "thirdparties/glfw-3.4.bin.WIN64"

	GLFWLibDir = {}
	GLFWLibDir["vs2022"] = "lib-vc2022"

	local libPath = GLFWLibDir[_ACTION]
	if type(libPath) == "nil" then
		error("GLFW cannot find the suitable prebuilt library for " .. _ACTION)
	end

	Dependencies["GLFW"] = {
		PackageName = "GLFW",
		Url = "https://github.com/glfw/glfw/releases/download/3.4/glfw-3.4.bin.WIN64.zip",
		Filename = "thirdparties/glfw.zip",
		ExtractDir = "thirdparties",
		KeepFile = true,

		IncludeDirectories = {
			glfwDir .. "/include",
		},
		LinkDirectories = {
			glfwDir .. "/" .. libPath,
		},
		LinkLibraries = {
			"glfw3"
		}
	}
else
	error("not support os: ".. os.target())
end
```

In `ProjectLib/premake5.lua` file.

``` lua
-- Include IceModule and dependencies table.
local Pkg = require("premake/module")
include "../vendor/dependencies.lua"

-- Create a new module.
LibModule = Pkg.New("ProjectLib")

-- Your library project configuration
project(LibModule.PackageName)
	kind "StaticLib"
	language "C++"
	cppdialect "c++17"
	staticruntime "on"

	targetdir ("%{wks.location}/build/%{prj.name}")
    objdir ("%{wks.location}/build/%{prj.name}")

	-- Define dependencies in module
	LibModule:Dependencies {
		Pkg.PUBLIC, -- Could be [PREIVATE, PUBLIC, INTERFACE]
		Dependencies["Vulkan"], -- ProjectLib's dependencies.
	}

	files {
		"src/**.h",
		"src/**.cpp"
	}

	includedirs {
		"src",
	}

	-- If your project is a library, you should add the following code to tell other projects use the library this project generated.
	table.insert(LibModule.IncludeDirectories, "%{wks.location}/" .. LibModule.PackageName .. "/src")
	table.insert(LibModule.LinkLibraries, LibModule.PackageName)

	filter "configurations:Debug"
		symbols "on"

	filter "configurations:Release"
		optimize "on"
```

In `ProjectExe/premake5.lua` file.

``` lua
-- Include IceModule and dependencies table.
local Pkg = require("premake/module")
include "../vendor/dependencies.lua"

-- Create a new module
ExeModule = Pkg.New("ProjectExe")

-- Your executable project configuration
project(ExeModule.PackageName)
	kind "ConsoleApp"
	language "C++"
	cppdialect "C++17"
	staticruntime "on"

	targetdir ("%{wks.location}/build/%{prj.name}")
    objdir ("%{wks.location}/build/%{prj.name}")

	ExeModule:Dependencies {
		Pkg.PRIVATE,
		Dependencies["Spdlog"], -- ProjectB's dependencies.
		LibModule,	-- Include ProjectLib as library, also it will include vulkan as well because we use PUBLIC previously.
	}

	files {
		"src/test.cpp"
	}

	filter "configurations:Debug"
		symbols "on"

	filter "configurations:Release"
		optimize "on"
```

4. Make a build script(Optional).

If you are using windows, create a .bat file in the root directory of your project.

``` bat
call premake\bin\premake5.exe vs2022
PAUSE
```