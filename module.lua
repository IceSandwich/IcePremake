local exports = {
    -- LinkType
    PUBLIC = "PUBLIC",
    PRIVATE = "PRIVATE",
    INTERFACE = "INTERFACE"
}

local ModuleClass = {}
ModuleClass.__index = ModuleClass

local Network = require("Network")

function exports.New(packageName)
    local mc = {
        PackageName = packageName or "",
        IncludeDirectories = {},
        LinkDirectories = {},
        LinkLibraries = {}
    }
    setmetatable(mc, ModuleClass)
    -- print("New package:", packageName, "===>", mc.PackageName)
	print("[IcePremake] Package " .. packageName)
    return mc
end

function solveURL(dependency)
	local url = dependency.Url
	local filename = dependency.Filename
	local hash = dependency.Hash

	if type(url) == "nil" then
		return
	end

	if type(filename) == "nil" then
		error("[IcePremake] Dependency " .. dependency.PackageName .. " has no `Filename` property. When you use `Url`, you must specify `Filename` and `Hash`(optional) at the same time.")
	end

	if os.isfile(filename) then
		if type(hash) ~= "nil" then
			-- TODO: hash validation
			print("[IcePremake] Dependency file " .. filename .. " already exists. But IcePremake doesn't support hash validation yet. Skip validation.")
		else
			print("[IcePremake] Dependency file " .. filename .. " already exists. Skip download.")
		end
	else
		local basedir = path.getdirectory(filename)
		if os.mkdir(basedir) == false then
			error("[IcePremake] Failed to make directories: " .. basedir)
		end
		Network.Download(url, filename)
	end

	local extractDir = dependency.ExtractDir
	if type(extractDir) ~= "nil" then
		print("[IcePremake] \tExtract zip to " .. extractDir)
		zip.extract(filename, extractDir)
		local keepFile = dependency.KeepFile or false
		if keepFile == false then
			print("[IcePremake] \tDelete cache file " .. filename)
			os.remove(filename)
		end
	end
end

-- deps(LinkType, ...)
-- LinkType: PUBLIC/PRIVATE/INTERFACE
-- ...: modules
-- Example:
-- deps {
--     PUBLIC
--     Hickory
-- }
function ModuleClass:Dependencies(args)
    local linktype = args[1]
    if linktype ~= exports.PUBLIC and linktype ~= exports.PRIVATE and linktype ~= exports.INTERFACE then
        error("The first argument of deps is LinkType which is one of PUBLIC, PRIVATE, INTERFACE. Currently got " .. linktype .. ".")
    end

    for i = 2, #args do
        local dependency = args[i]

		local name = dependency.PackageName
		if type(name) == "nil" then
			error("[IcePremake] All Dependencies must have `PackageName` property. Please check your dependencies table.")
		end

		print("[IcePremake] Use package " .. name)

		solveURL(dependency)

		-- print("Using thirdparty libraray: " .. dependencyName)
        local includeDirectories = dependency.IncludeDirectories
		if type(includeDirectories) ~= "nil" then
            if linktype == exports.PRIVATE or linktype == exports.PUBLIC then
                for _, includeDirectory in ipairs(includeDirectories) do
                    includedirs(includeDirectory)
                    -- print("\t- include dir: " .. includeDirectory)
                end
            end
            if linktype == exports.INTERFACE or linktype == exports.PUBLIC then
                for _, includeDirectory in ipairs(includeDirectories) do
                    table.insert(self.IncludeDirectories, includeDirectory)
                end
            end
		end

        local linkDirectories = dependency["LinkDirectories"]
		if type(linkDirectories) ~= "nil" then
            if linktype == exports.PRIVATE or linktype == exports.PUBLIC then
                for _, linkDirectory in ipairs(linkDirectories) do
                    libdirs(linkDirectory)
                    -- print("\t- lib dir: " .. linkDirectory)
                end
            end
            if linktype == exports.INTERFACE or linktype == exports.PUBLIC then
                for _, linkDirectory in ipairs(linkDirectories) do
                    table.insert(self.LinkDirectories, linkDirectory)
                end
            end
		end

        local linkLibraries = dependency["LinkLibraries"]
		if type(linkLibraries) ~= "nil" then
            if linktype == exports.PRIVATE or linktype == exports.PUBLIC then
                for _, linkLibrary in ipairs(linkLibraries) do 
                    links(linkLibrary)
                    -- print("\t- libs: " .. linkLibrary)
                end
            end
            if linktype == exports.INTERFACE or linktype == exports.PUBLIC then
                for _, linkLibrary in ipairs(linkLibraries) do
                    table.insert(self.LinkLibraries, linkLibrary)
                end
            end
		end

	end
end

return exports