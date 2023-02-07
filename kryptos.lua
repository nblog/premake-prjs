/*
    project: https://github.com/rafael-santiago/kryptos

*/


function prj_sample(prjs)
    for idx, prj_name in ipairs(prjs) do
        project(prj_name)
            language    "C"
            kind        "ConsoleApp"
            basedir     ( "src" )

            includedirs { "%{prj.basedir}" }
            files { "%{prj.basedir}/samples/%{prj.name}.c" }

            links { "libkryptos" }
    end
end



solution "kryptos"
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

    filter { "action:vs*" }
        buildoptions { "/wd4005" }


project "libkryptos"
    language    "C"
    kind        "StaticLib"

    defines { "KRYPTOS_DATA_WIPING_WHEN_FREEING_MEMORY" }

    basedir( "src" )

    includedirs { "%{prj.basedir}" }

    files { "%{prj.basedir}/*.c" }

    links { "bcrypt" }


prj_sample {
    "aes-ctr-c99-sample",
    "aes-gcm-c99-sample",
    "base64-sample",
}