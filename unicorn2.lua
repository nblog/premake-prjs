    ---
    ---
    -- author: 
    ---
    ---


    function prj_softmmu(target_arch, autogen_header)
        language    "C"
        kind        "StaticLib"

        basedir( "msvc/%{prj.name}" )
        includedirs { "%{prj.basedir}", path.join("qemu/target", target_arch)}

        defines     { "NEED_CPU_H" }
        links       { "unicorn-common" }

        forceincludes(autogen_header)

        files {
            "qemu/exec.c",
            "qemu/exec-vary.c",
    
            "qemu/softmmu/cpus.c",
            "qemu/softmmu/ioport.c",
            "qemu/softmmu/memory.c",
            "qemu/softmmu/memory_mapping.c",
    
            "qemu/fpu/softfloat.c",
    
            "qemu/tcg/optimize.c",
            "qemu/tcg/tcg.c",
            "qemu/tcg/tcg-op.c",
            "qemu/tcg/tcg-op-gvec.c",
            "qemu/tcg/tcg-op-vec.c",
    
            "qemu/accel/tcg/cpu-exec.c",
            "qemu/accel/tcg/cpu-exec-common.c",
            "qemu/accel/tcg/cputlb.c",
            "qemu/accel/tcg/tcg-all.c",
            "qemu/accel/tcg/tcg-runtime.c",
            "qemu/accel/tcg/tcg-runtime-gvec.c",
            "qemu/accel/tcg/translate-all.c",
            "qemu/accel/tcg/translator.c",
        }
    end


    function prj_tests(prjs)
        for idx, prj_name in ipairs(prjs) do
            project(prj_name)

            language    "C"
            kind        "ConsoleApp"
    
            basedir( "tests/unit" )
            includedirs { "%{prj.basedir}" }
    
            links       { "unicorn" }
    
            files { "%{prj.basedir}/%{prj.name}.c" }
        end
    end




    solution "unicorn"
        location( path.join("msvc", _ACTION) )

        startproject "test_x86"

        configurations { "Release", "Debug" }
        platforms { "x86", "x64" }

        filter "configurations:Debug"
            defines     { "_DEBUG" }

        filter "configurations:Release"
            optimize    "Full"
            flags       { "LinkTimeOptimization" }
            defines     { "NDEBUG" }

        filter "architecture:x86_64"
            defines { "__x86_64__" }

        filter "architecture:i386"
            defines { "__i386__" }

        filter { "action:vs*", "language:C" }
            defines { 
                "inline=__inline", "__func__=__FUNCTION__", 
                "_CRT_SECURE_NO_WARNINGS", "WIN32_LEAN_AND_MEAN",
            }

            includedirs { "glib_compat", "qemu", "qemu/include", "include", "qemu/tcg" }
            includedirs { "qemu/tcg/i386", "msvc" }

            buildoptions { "/wd4018", "/wd4098", "/wd4244", "/wd4267" }

        filter "kind:SharedLib or StaticLib"
            defines { "UNICORN_SHARED" }


    project "unicorn"
        language    "C"
        kind        "SharedLib"

        links       { 
            "unicorn-common",
            "x86_64-softmmu",
            "arm-softmmu", 
            "aarch64-softmmu", 
            "m68k-softmmu", 
            "mips-softmmu", "mipsel-softmmu", "mips64-softmmu", "mips64el-softmmu",
            "sparc-softmmu", "sparc64-softmmu",
            "ppc-softmmu", "ppc64-softmmu",
            "riscv32-softmmu", "riscv64-softmmu",
            "s390x-softmmu",
            "tricore-softmmu",
        }

        files {
            "uc.c",
            "qemu/softmmu/vl.c", "qemu/hw/core/cpu.c", 
        }

        defines { 
            "UNICORN_HAS_X86",
            "UNICORN_HAS_ARM",
            "UNICORN_HAS_AARCH64", "UNICORN_HAS_ARM64",
            "UNICORN_HAS_M68K",
            "UNICORN_HAS_MIPS", "UNICORN_HAS_MIPSEL", "UNICORN_HAS_MIPS64", "UNICORN_HAS_MIPS64EL",
            "UNICORN_HAS_SPARC",
            "UNICORN_HAS_PPC",
            "UNICORN_HAS_RISCV",
            "UNICORN_HAS_S390X",
            "UNICORN_HAS_TRICORE",
        }


    project "unicorn-common"
        language    "C"
        kind        "StaticLib"

        files {
            "list.c", 
            "glib_compat/*.c", 
            "qemu/util/**", "qemu/crypto/aes.c", 
        }

        filter "system:not windows"
            excludes {
                "qemu/util/oslib-win32.c",
                "qemu/util/qemu-thread-win32.c",
            }

        filter "system:windows"
            excludes {
                "qemu/util/oslib-posix.c",
                "qemu/util/qemu-thread-posix.c",
            }

        filter { "system:windows", "platforms:x86" }
            excludes {
                "qemu/util/setjmp-wrapper-win32.asm",
            }


    project "aarch64-softmmu"
        prj_softmmu("arm", "aarch64.h")

        files {
            "qemu/target/arm/cpu64.c",
            "qemu/target/arm/cpu.c",
            "qemu/target/arm/crypto_helper.c",
            "qemu/target/arm/debug_helper.c",
            "qemu/target/arm/helper-a64.c",
            "qemu/target/arm/helper.c",
            "qemu/target/arm/iwmmxt_helper.c",
            "qemu/target/arm/m_helper.c",
            "qemu/target/arm/neon_helper.c",
            "qemu/target/arm/op_helper.c",
            "qemu/target/arm/pauth_helper.c",
            "qemu/target/arm/psci.c",
            "qemu/target/arm/sve_helper.c",
            "qemu/target/arm/tlb_helper.c",
            "qemu/target/arm/translate-a64.c",
            "qemu/target/arm/translate.c",
            "qemu/target/arm/translate-sve.c",
            "qemu/target/arm/vec_helper.c",
            "qemu/target/arm/vfp_helper.c",
            "qemu/target/arm/unicorn_aarch64.c",
        }

    project "arm-softmmu"
        prj_softmmu("arm", "arm.h")

        files { 
            "qemu/target/arm/cpu.c",
            "qemu/target/arm/crypto_helper.c",
            "qemu/target/arm/debug_helper.c",
            "qemu/target/arm/helper.c",
            "qemu/target/arm/iwmmxt_helper.c",
            "qemu/target/arm/m_helper.c",
            "qemu/target/arm/neon_helper.c",
            "qemu/target/arm/op_helper.c",
            "qemu/target/arm/psci.c",
            "qemu/target/arm/tlb_helper.c",
            "qemu/target/arm/translate.c",
            "qemu/target/arm/vec_helper.c",
            "qemu/target/arm/vfp_helper.c",
            "qemu/target/arm/unicorn_arm.c",
        }

    project "m68k-softmmu"
        prj_softmmu("m68k", "m68k.h")

        files { 
            "qemu/target/m68k/cpu.c",
            "qemu/target/m68k/fpu_helper.c",
            "qemu/target/m68k/helper.c",
            "qemu/target/m68k/op_helper.c",
            "qemu/target/m68k/softfloat.c",
            "qemu/target/m68k/translate.c",
            "qemu/target/m68k/unicorn.c",
        }

    project "mips64el-softmmu"
        prj_softmmu("mips", "mips64el.h")

        files { 
            "qemu/target/mips/cp0_helper.c",
            "qemu/target/mips/cp0_timer.c",
            "qemu/target/mips/cpu.c",
            "qemu/target/mips/dsp_helper.c",
            "qemu/target/mips/fpu_helper.c",
            "qemu/target/mips/helper.c",
            "qemu/target/mips/lmi_helper.c",
            "qemu/target/mips/msa_helper.c",
            "qemu/target/mips/op_helper.c",
            "qemu/target/mips/translate.c",
            "qemu/target/mips/unicorn.c",
        }

    project "mips64-softmmu"
        prj_softmmu("mips", "mips64.h")

        files { 
            "qemu/target/mips/cp0_helper.c",
            "qemu/target/mips/cp0_timer.c",
            "qemu/target/mips/cpu.c",
            "qemu/target/mips/dsp_helper.c",
            "qemu/target/mips/fpu_helper.c",
            "qemu/target/mips/helper.c",
            "qemu/target/mips/lmi_helper.c",
            "qemu/target/mips/msa_helper.c",
            "qemu/target/mips/op_helper.c",
            "qemu/target/mips/translate.c",
            "qemu/target/mips/unicorn.c",
        }

    project "mipsel-softmmu"
        prj_softmmu("mips", "mipsel.h")

        files { 
            "qemu/target/mips/cp0_helper.c",
            "qemu/target/mips/cp0_timer.c",
            "qemu/target/mips/cpu.c",
            "qemu/target/mips/dsp_helper.c",
            "qemu/target/mips/fpu_helper.c",
            "qemu/target/mips/helper.c",
            "qemu/target/mips/lmi_helper.c",
            "qemu/target/mips/msa_helper.c",
            "qemu/target/mips/op_helper.c",
            "qemu/target/mips/translate.c",
            "qemu/target/mips/unicorn.c",
        }

    project "mips-softmmu"
        prj_softmmu("mips", "mips.h")

        files { 
            "qemu/target/mips/cp0_helper.c",
            "qemu/target/mips/cp0_timer.c",
            "qemu/target/mips/cpu.c",
            "qemu/target/mips/dsp_helper.c",
            "qemu/target/mips/fpu_helper.c",
            "qemu/target/mips/helper.c",
            "qemu/target/mips/lmi_helper.c",
            "qemu/target/mips/msa_helper.c",
            "qemu/target/mips/op_helper.c",
            "qemu/target/mips/translate.c",
            "qemu/target/mips/unicorn.c",
        }

    project "ppc64-softmmu"
        prj_softmmu("ppc", "ppc64.h")

        files { 
            "qemu/hw/ppc/ppc.c",
            "qemu/hw/ppc/ppc_booke.c",
        
            "qemu/libdecnumber/decContext.c",
            "qemu/libdecnumber/decNumber.c",
            "qemu/libdecnumber/dpd/decimal128.c",
            "qemu/libdecnumber/dpd/decimal32.c",
            "qemu/libdecnumber/dpd/decimal64.c",
        
            "qemu/target/ppc/compat.c",
            "qemu/target/ppc/cpu.c",
            "qemu/target/ppc/cpu-models.c",
            "qemu/target/ppc/dfp_helper.c",
            "qemu/target/ppc/excp_helper.c",
            "qemu/target/ppc/fpu_helper.c",
            "qemu/target/ppc/int_helper.c",
            "qemu/target/ppc/machine.c",
            "qemu/target/ppc/mem_helper.c",
            "qemu/target/ppc/misc_helper.c",
            "qemu/target/ppc/mmu-book3s-v3.c",
            "qemu/target/ppc/mmu-hash32.c",
            "qemu/target/ppc/mmu-hash64.c",
            "qemu/target/ppc/mmu_helper.c",
            "qemu/target/ppc/mmu-radix64.c",
            "qemu/target/ppc/timebase_helper.c",
            "qemu/target/ppc/translate.c",
            "qemu/target/ppc/unicorn.c",
        }

    project "ppc-softmmu"
        prj_softmmu("ppc", "ppc.h")

        files { 
            "qemu/hw/ppc/ppc.c",
            "qemu/hw/ppc/ppc_booke.c",
        
            "qemu/libdecnumber/decContext.c",
            "qemu/libdecnumber/decNumber.c",
            "qemu/libdecnumber/dpd/decimal128.c",
            "qemu/libdecnumber/dpd/decimal32.c",
            "qemu/libdecnumber/dpd/decimal64.c",
        
            "qemu/target/ppc/cpu.c",
            "qemu/target/ppc/cpu-models.c",
            "qemu/target/ppc/dfp_helper.c",
            "qemu/target/ppc/excp_helper.c",
            "qemu/target/ppc/fpu_helper.c",
            "qemu/target/ppc/int_helper.c",
            "qemu/target/ppc/machine.c",
            "qemu/target/ppc/mem_helper.c",
            "qemu/target/ppc/misc_helper.c",
            "qemu/target/ppc/mmu-hash32.c",
            "qemu/target/ppc/mmu_helper.c",
            "qemu/target/ppc/timebase_helper.c",
            "qemu/target/ppc/translate.c",
            "qemu/target/ppc/unicorn.c",
        }

    project "riscv32-softmmu"
        prj_softmmu("riscv", "riscv32.h")

        files { 
            "qemu/target/riscv/cpu.c",
            "qemu/target/riscv/cpu_helper.c",
            "qemu/target/riscv/csr.c",
            "qemu/target/riscv/fpu_helper.c",
            "qemu/target/riscv/op_helper.c",
            "qemu/target/riscv/pmp.c",
            "qemu/target/riscv/translate.c",
            "qemu/target/riscv/unicorn.c",
        }

    project "riscv64-softmmu"
        prj_softmmu("riscv", "riscv64.h")

        files { 
            "qemu/target/riscv/cpu.c",
            "qemu/target/riscv/cpu_helper.c",
            "qemu/target/riscv/csr.c",
            "qemu/target/riscv/fpu_helper.c",
            "qemu/target/riscv/op_helper.c",
            "qemu/target/riscv/pmp.c",
            "qemu/target/riscv/translate.c",
            "qemu/target/riscv/unicorn.c",
        }

    project "s390x-softmmu"
        prj_softmmu("s390x", "s390x.h")

        files { 
            "qemu/hw/s390x/s390-skeys.c",

            "qemu/target/s390x/cc_helper.c",
            "qemu/target/s390x/cpu.c",
            "qemu/target/s390x/cpu_features.c",
            "qemu/target/s390x/cpu_models.c",
            "qemu/target/s390x/crypto_helper.c",
            "qemu/target/s390x/excp_helper.c",
            "qemu/target/s390x/fpu_helper.c",
            "qemu/target/s390x/helper.c",
            "qemu/target/s390x/interrupt.c",
            "qemu/target/s390x/int_helper.c",
            "qemu/target/s390x/ioinst.c",
            "qemu/target/s390x/mem_helper.c",
            "qemu/target/s390x/misc_helper.c",
            "qemu/target/s390x/mmu_helper.c",
            "qemu/target/s390x/sigp.c",
            "qemu/target/s390x/tcg-stub.c",
            "qemu/target/s390x/translate.c",
            "qemu/target/s390x/vec_fpu_helper.c",
            "qemu/target/s390x/vec_helper.c",
            "qemu/target/s390x/vec_int_helper.c",
            "qemu/target/s390x/vec_string_helper.c",
            "qemu/target/s390x/unicorn.c",
        }

    project "sparc64-softmmu"
        prj_softmmu("sparc", "sparc64.h")

        files { 
            "qemu/target/sparc/cc_helper.c",
            "qemu/target/sparc/cpu.c",
            "qemu/target/sparc/fop_helper.c",
            "qemu/target/sparc/helper.c",
            "qemu/target/sparc/int64_helper.c",
            "qemu/target/sparc/ldst_helper.c",
            "qemu/target/sparc/mmu_helper.c",
            "qemu/target/sparc/translate.c",
            "qemu/target/sparc/vis_helper.c",
            "qemu/target/sparc/win_helper.c",
            "qemu/target/sparc/unicorn64.c",
        }

    project "sparc-softmmu"
        prj_softmmu("sparc", "sparc.h")

        files { 
            "qemu/target/sparc/cc_helper.c",
            "qemu/target/sparc/cpu.c",
            "qemu/target/sparc/fop_helper.c",
            "qemu/target/sparc/helper.c",
            "qemu/target/sparc/int32_helper.c",
            "qemu/target/sparc/ldst_helper.c",
            "qemu/target/sparc/mmu_helper.c",
            "qemu/target/sparc/translate.c",
            "qemu/target/sparc/win_helper.c",
            "qemu/target/sparc/unicorn.c",
        }

    project "tricore-softmmu"
        prj_softmmu("tricore", "tricore.h")

        files { 
            "qemu/target/tricore/cpu.c",
            "qemu/target/tricore/fpu_helper.c",
            "qemu/target/tricore/helper.c",
            "qemu/target/tricore/op_helper.c",
            "qemu/target/tricore/translate.c",
            "qemu/target/tricore/unicorn.c",
        }

    project "x86_64-softmmu"
        prj_softmmu("i386", "x86_64.h")

        files { 
            "qemu/hw/i386/x86.c", 

            "qemu/target/i386/arch_memory_mapping.c",
            "qemu/target/i386/bpt_helper.c",
            "qemu/target/i386/cc_helper.c",
            "qemu/target/i386/cpu.c",
            "qemu/target/i386/excp_helper.c",
            "qemu/target/i386/fpu_helper.c",
            "qemu/target/i386/helper.c",
            "qemu/target/i386/int_helper.c",
            "qemu/target/i386/machine.c",
            "qemu/target/i386/mem_helper.c",
            "qemu/target/i386/misc_helper.c",
            "qemu/target/i386/mpx_helper.c",
            "qemu/target/i386/seg_helper.c",
            "qemu/target/i386/smm_helper.c",
            "qemu/target/i386/svm_helper.c",
            "qemu/target/i386/translate.c",
            "qemu/target/i386/xsave_helper.c",
            "qemu/target/i386/unicorn.c",
        }


    prj_tests { 
        "test_x86", 
        "test_tricore", "test_sparc", "test_s390x", 
        "test_riscv", "test_ppc", "test_mips", 
        "test_m68k", "test_arm64", "test_arm" 
    }