function ExecuteProgram(cmd)
    local handle = io.popen(cmd)
    local result = handle:read("*a")
    handle:close()
    return result
end

local CMakeExecutable = ExecuteProgram("where cmake")
if CMakeExecutable == nil then
    error("CMake executable not found, please install it and try again.")
end
CMakeExecutable = CMakeExecutable:gsub("\r\n", ""):gsub("\n", ""):gsub("\r", "")
CMakeExecutable = "\"" .. CMakeExecutable.. "\""
print("Detected CMake executable program: " .. CMakeExecutable)

local exports = {}

function exports.GetCMakeExecutable()
    return CMakeExecutable
end

function exports.ConfigureCMD(cmakelistPath, buildpath, installpath, args)
    command = CMakeExecutable .. " -S \"".. cmakelistPath.. "\" -B \"".. buildpath .. "\" -DCMAKE_INSTALL_PREFIX=\"" .. installpath .. "\""
    for i,v in pairs(args or {}) do
        command = command .. " -D".. i.. "=".. v
    end
    print("Running command: " .. command)
    return command
end

return exports