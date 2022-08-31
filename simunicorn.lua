

(function()
    --- clone angr_native
    local native = "https://github.com/angr/angr/blob/master/native/"
    local angr_native = { 
        native .. "log.h", native .. "log.c", 
        native .. "angr_native.def", 
        native .. "sim_unicorn.hpp", 
        native .. "sim_unicorn.cpp" }
    
        for idx, url in ipairs(angr_native) do
            http.download(url .. "?raw=true", path.getname(url))
        end

    --- clone pyvex
    if (not os.isdir("pyvex")) then
        os.execute("git clone --recursive https://github.com/angr/pyvex")
    end
end)()



solution "simunicorn"
    location( _ACTION )

    configurations { "Release", "Debug" }

    platforms { "x86", "x64" }

    filter "configurations:Debug"
        symbols     "On"
        defines     { "_DEBUG" }

    filter "configurations:Release"
        optimize    "Full"
        flags       { "LinkTimeOptimization" }
        defines     { "NDEBUG" }



project "libsimunicorn"
    language    "C++"
    kind        "SharedLib"

    links { "pyvex", "unicorn" }

    targetname ("angr_native")

    includedirs { "pyvex/vex/pub", "pyvex/pyvex_c", "unicorn/include" }

    files { 
        "%{prj.basedir}/sim_unicorn.cpp", 
        "%{prj.basedir}/sim_unicorn.hpp", 
        "%{prj.basedir}/angr_native.def"
    }




project "pyvex"
    language    "C"
    kind        "SharedLib"

    links { "libvex" }

    basedir("pyvex/pyvex_c")

    includedirs { "%{prj.basedir}", "pyvex/vex/pub" }

    files { 
        "%{prj.basedir}/pyvex.c",
        "%{prj.basedir}/postprocess.c",
        "%{prj.basedir}/analysis.c",
        "%{prj.basedir}/logging.c",
        "%{prj.basedir}/pyvex.h",

        "%{prj.basedir}/pyvex.def"
    }


project "libvex"
    language    "C"
    kind        "StaticLib"

    basedir("pyvex/vex")

    includedirs { "%{prj.basedir}/pub", "%{prj.basedir}/priv" }

    files { "%{prj.basedir}/priv/*.c" }

    buildoptions { "/wd4715", "/DPYVEX" }

    --- libvex_guest_offsets.h
    prebuildcommands { 
        "cd " .. "$(ProjectDir)%{prj.basedir}",
        "cl /Ipub /Ipriv /O2 /wd4715 /DPYVEX auxprogs\\genoffsets.c /Fo:auxprogs\\genoffsets.o /Fe:auxprogs\\genoffsets.exe",
        "auxprogs\\genoffsets.exe > pub\\libvex_guest_offsets.h"
    }