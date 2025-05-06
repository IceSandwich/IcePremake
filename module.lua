local exports = {
    -- LinkType
    PUBLIC = "PUBLIC",
    PRIVATE = "PRIVATE",
    INTERFACE = "INTERFACE"
}

local ModuleClass = {}
ModuleClass.__index = ModuleClass

function exports.New(packageName)
    local mc = {
        PackageName = packageName or "",
        IncludeDirectories = {},
        LinkDirectories = {},
        LinkLibraries = {}
    }
    setmetatable(mc, ModuleClass)
    -- print("New package:", packageName, "===>", mc.PackageName)
    return mc
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