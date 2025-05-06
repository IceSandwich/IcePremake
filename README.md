# IcePremake

This repository contains the premake scripts that i frequently used in other projects.

In short, it provides a package management system like CMake.

# Usage

1. Clone this repository.

``` bash
cd path-to-your-project
git clone https://github.com/IceSandwich/IcePremake.git premake
```

2. Download premake prebuilt binaray.

Go to the [premake release](https://github.com/premake/premake-core/releases) and download the prebuilt binary for your platform.

Extract the `premake5.exe` file into the `path-to-your-project/premake/bin` folder.

3. Write your module.

``` lua
-- Include IceModule
local Pkg = require("premake/module")

-- Create a new module
ProjectAModule = Pkg.New("ProjectA")

-- Store all your dependencies in a table.
Dependencies = {}

-- Here use vulkan and spdlog as an example.
VULKAN_SDK = os.getenv("VULKAN_SDK")
print("Detected Vulkan SDK: " .. VULKAN_SDK)
Dependencies["Vulkan"] = {
	-- IncludeDirectories, LinkDirectories, LinkLibraries are optional.
	-- You can use one of them or two of them.
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
	IncludeDirectories = {
		"%{wks.location}/vendor/spdlog/include",
	},
}

-- Your library project configuration
project(ProjectAModule.PackageName)
	kind "StaticLib"
	language "C++"
	cppdialect "c++17"
	staticruntime "on"

	-- Define dependencies in module
	ProjectAModule:Dependencies {
		Pkg.PUBLIC, -- Could be [PREIVATE, PUBLIC, INTERFACE]
		Dependencies["Vulkan"], -- ProjectA's dependencies.
	}

	files {
		"src/**.h",
		"src/**.cpp"
	}

	includedirs {
		"src",
	}

	-- If your project is a library, you should add the following code to tell other projects use the library this project generated.
	table.insert(ProjectAModule.IncludeDirectories, "%{wks.location}/src")
	table.insert(ProjectAModule.LinkLibraries, ProjectAModule.PackageName)

	filter "configurations:Debug"
		symbols "on"

	filter "configurations:Release"
		optimize "on"


-- Create a new module
ProjectBModule = Pkg.New("ProjectB")

-- Your executable project configuration
project(ProjectBModule.PackageName)
	kind "ConsoleApp"
	language "C++"
	cppdialect "C++17"
	staticruntime "on"

	ProjectBModule:Dependencies {
		Pkg.PRIVATE,
		Dependencies["Spdlog"], -- ProjectB's dependencies.
		ProjectAModule,	-- Include ProjectA as library, also it will include vulkan as well because we use PUBLIC previously.
	}

	files {
		"test/test.cpp"
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