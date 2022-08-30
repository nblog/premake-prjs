---
---
-- author: 
---
---



    function prj_tests(prjs)
        for idx, prj_name in ipairs(prjs) do
            project(prj_name)

            language    "C++"
            kind        "ConsoleApp"

            basedir( "re2/testing" )
            includedirs { ".", "%{prj.basedir}" }

            links       { "re2", "testing" }

            files { "util/test.cc", "%{prj.basedir}/%{prj.name}.cc" }
        end
    end






    solution "re2"
        location( _ACTION )

        startproject "re2_test"

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
            defines {
                "UNICODE", "_UNICODE", "STRICT", "NOMINMAX",
                "_CRT_SECURE_NO_WARNINGS", "_SCL_SECURE_NO_WARNINGS",
            }

            buildoptions { "/wd4100", "/wd4201", "/wd4456", "/wd4457", "/wd4702", "/wd4815" }

            buildoptions { "/utf-8" }


    project "re2"
        language    "C++"
        kind        "StaticLib"

        includedirs { "." }

        files {
            "re2/bitstate.cc",
            "re2/compile.cc",
            "re2/dfa.cc",
            "re2/filtered_re2.cc",
            "re2/mimics_pcre.cc",
            "re2/nfa.cc",
            "re2/onepass.cc",
            "re2/parse.cc",
            "re2/perl_groups.cc",
            "re2/prefilter.cc",
            "re2/prefilter_tree.cc",
            "re2/prog.cc",
            "re2/re2.cc",
            "re2/regexp.cc",
            "re2/set.cc",
            "re2/simplify.cc",
            "re2/stringpiece.cc",
            "re2/tostring.cc",
            "re2/unicode_casefold.cc",
            "re2/unicode_groups.cc",
            "util/rune.cc",
            "util/strutil.cc",
        }



    project("testing")
        language    "C++"
        kind        "StaticLib"

        links { "re2" }

        includedirs { "." }

        files {
            "re2/testing/backtrack.cc",
            "re2/testing/dump.cc",
            "re2/testing/exhaustive_tester.cc",
            "re2/testing/null_walker.cc",
            "re2/testing/regexp_generator.cc",
            "re2/testing/string_generator.cc",
            "re2/testing/tester.cc",
            "util/pcre.cc",
        }

    prj_tests { 
        "charclass_test",
        "compile_test",
        "filtered_re2_test",
        "mimics_pcre_test",
        "parse_test",
        "possible_match_test",
        "re2_test",
        "re2_arg_test",
        "regexp_test",
        "required_prefix_test",
        "search_test",
        "set_test",
        "simplify_test",
        "string_generator_test",

        "dfa_test",
        "exhaustive1_test",
        "exhaustive2_test",
        "exhaustive3_test",
        "exhaustive_test",
        "random_test",
    }