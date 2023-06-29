
--- APIs are different
--- 16.x  script debugger
--- 15.x  session debugger
--- output：Ghidra\patch\win32-x86-64\frida-core.dll (Please be the same as the jdk bit version)
local FRIDA_VERSION = "15.2.2"
local FRIDA_CORE_DEVKIT_X86 = "frida-core-devkit-" .. FRIDA_VERSION .. "-windows-x86"
local FRIDA_CORE_DEVKIT_X86_64 = "frida-core-devkit-" .. FRIDA_VERSION .. "-windows-x86_64"

(function()
    --- clone frida
    local frida = "https://github.com/frida/frida/releases/download/" .. FRIDA_VERSION .. "/"
    local frida_core_devkit = { 
        FRIDA_CORE_DEVKIT_X86 .. ".tar.xz", FRIDA_CORE_DEVKIT_X86_64 .. ".tar.xz" }

    for idx, url in ipairs(frida_core_devkit) do
        local target = path.getname(url)
        if (not os.isfile(target)) then
            http.download(url, target)
        end
    end

    --- clone ghidra_wrapper
    local ghidra = "https://github.com/NationalSecurityAgency/ghidra/blob/master/Ghidra/Debug/Debugger-agent-frida/src/main/cpp/"
    local ghidra_wrapper = {
        ghidra .. "ghidra_wrapper.c"
    }

    for idx, url in ipairs(ghidra_wrapper) do
        http.download(url .. "?raw=true", path.getname(url))
    end

    --- generate export
    output_content = "LIBRARY\r\nEXPORTS\r\n"

    wrapper_content = io.readfile("ghidra_wrapper.c")

    for fn in string.gmatch(wrapper_content, " (GH_[%w_]+) %(") do
        output_content = output_content .. "\t" .. fn .. "\r\n"
    end

    io.writefile("ghidra_wrapper.def", output_content)
    io.writefile("ghidra_wrapper.cc", wrapper_content)
end)()



solution "ghidra_wrapper"
    location( _ACTION )

    configurations { "Release", "Debug" }

    platforms { "x86", "x64" }

    staticruntime   "On"

    filter "configurations:Debug"
        symbols     "On"
        defines     { "_DEBUG" }

    filter "configurations:Release"
        optimize    "Full"
        flags       { "LinkTimeOptimization" }
        defines     { "NDEBUG" }


project "libfrida-core"
    language    "C++"
    kind        "SharedLib"

    linkoptions ("/DEF:\"%{prj.basedir}/ghidra_wrapper.def\"")

    links { "frida-core" }

    targetname ("frida-core")

    files { 
        "%{prj.basedir}/ghidra_wrapper.cc", 
    }

    filter { "system:windows", "platforms:x64" }
        includedirs {
            "%{prj.basedir}/" .. FRIDA_CORE_DEVKIT_X86_64,
        }
        libdirs { "%{prj.basedir}/" .. FRIDA_CORE_DEVKIT_X86_64, }
    filter { "system:windows", "platforms:x86" }
        includedirs {
            "%{prj.basedir}/" .. FRIDA_CORE_DEVKIT_X86,
        }
        libdirs { "%{prj.basedir}/" .. FRIDA_CORE_DEVKIT_X86, }
