const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const lib = b.addLibrary(.{
        .name = "libjpeg_turbo",
        .linkage = .static,
        .root_module = b.createModule(.{
          .target = target,
          .optimize = optimize,
        })
    });
    
    lib.root_module.link_libc = true;
    
    lib.root_module.addIncludePath(b.path("src"));
    lib.installHeadersDirectory(b.path("src"), "", .{});
    
    const jversion_h = b.addConfigHeader(.{
        .style = .{
            .cmake = b.path("src/jversion.h.in"),
        },
        .include_path = "jversion.h"
    }, .{
        .JPEG_LIB_VERSION = "80",
        .COPYRIGHT_YEAR = "2025",
        .WITH_SIMD = 1,
    });
    
    lib.root_module.addConfigHeader(jversion_h);
    lib.installConfigHeader(jversion_h);
    
    const libjpeg_map = b.addConfigHeader(.{
        .style = .{
            .cmake = b.path("src/libjpeg.map.in"),
        },
        .include_path = "libjpeg.map"
    }, .{
        .JPEG_LIB_VERSION_DECIMAL = "8.0",
        .MEM_SRCDST_FUNCTIONS =  "global:  jpeg_mem_dest;  jpeg_mem_src;",
        .WITH_SIMD = 1,
    });
    
    lib.root_module.addConfigHeader(libjpeg_map);
    lib.installConfigHeader(libjpeg_map);
    
    const jconfig_h = b.addConfigHeader(.{
        .style = .{
            .cmake = b.path("src/jconfig.h.in"),
        },
        .include_path = "jconfig.h"
    }, .{
        .JPEG_LIB_VERSION = "80",
        .VERSION = "3.1.80",
        .LIBJPEG_TURBO_VERSION_NUMBER = "3001002",
        .WITH_SIMD = 1,
    });
    
    lib.root_module.addConfigHeader(jconfig_h);
    lib.installConfigHeader(jconfig_h);
    
    const jconfigint = b.addConfigHeader(.{
        .style = .{
            .cmake = b.path("src/jconfigint.h.in"),
        },
        .include_path = "jconfigint.h"
    }, .{
        .BUILD = "20250628",
        .HIDDEN = "__attribute__((visibility(\"hidden\")))",
        .INLINE = "__inline__ __attribute__((always_inline))",
        .THREAD_LOCAL = "__thread",
        .CMAKE_PROJECT_NAME = "libjpeg-turbo",
        .VERSION = "3.1.2",
        .SIZE_T = switch (target.result.ptrBitWidth()) {
            16 => "2",
            32 => "4",
            64 => "8",
            else => "8",
        },
        .WITH_SIMD = 1,
        .SIMD_ARCHITECTURE = switch (target.result.cpu.arch) {
            .arm, .armeb => "ARM",
            .aarch64, .aarch64_be => "ARM64",
            .x86_64 => "X86_64",
            .x86 => "I386",
            else => "NONE",
        },
    });
    
    lib.root_module.addConfigHeader(jconfigint);
    lib.installConfigHeader(jconfigint);
    
    switch (target.result.cpu.arch) {
        .arm, .armeb => {
            if (std.Target.arm.featureSetHas(target.result.cpu.features, .neon)) {
                addArmFiles(b, lib, false);
            }
        },
        .aarch64, .aarch64_be => {
            if (std.Target.aarch64.featureSetHas(target.result.cpu.features, .neon)) {
                addArmFiles(b, lib, true);
            }
        },
        .x86 => {
            addX86Files(b, lib, target);
        },
        .x86_64 => {
            addX86Files(b, lib, target);
        },
        else => {},
    }
    
    lib.root_module.addCSourceFiles(.{
        .files = &.{
            "src/jcapimin.c",
            "src/wrapper/jcapistd-8.c",
            "src/wrapper/jcapistd-12.c",
            "src/wrapper/jcapistd-16.c",
            "src/wrapper/jccoefct-8.c",
            "src/wrapper/jccoefct-12.c",
            "src/wrapper/jccolor-8.c",
            "src/wrapper/jccolor-12.c",
            "src/wrapper/jccolor-16.c",
            "src/wrapper/jcdctmgr-8.c",
            "src/wrapper/jcdctmgr-12.c",
            "src/wrapper/jcdiffct-8.c",
            "src/wrapper/jcdiffct-12.c",
            "src/wrapper/jcdiffct-16.c",
            "src/jchuff.c",
            "src/jcicc.c",
            "src/jcinit.c",
            "src/jclhuff.c",
            "src/wrapper/jclossls-8.c",
            "src/wrapper/jclossls-12.c",
            "src/wrapper/jclossls-16.c",
            "src/wrapper/jcmainct-8.c",
            "src/wrapper/jcmainct-12.c",
            "src/wrapper/jcmainct-16.c",
            "src/jcmarker.c",
            "src/jcmaster.c",
            "src/jcomapi.c",
            "src/jcparam.c",
            "src/jcphuff.c",
            "src/wrapper/jcprepct-8.c",
            "src/wrapper/jcprepct-12.c",
            "src/wrapper/jcprepct-16.c",
            "src/wrapper/jcsample-8.c",
            "src/wrapper/jcsample-12.c",
            "src/wrapper/jcsample-16.c",
            "src/jctrans.c",
            "src/jdapimin.c",
            "src/wrapper/jdapistd-8.c",
            "src/wrapper/jdapistd-12.c",
            "src/wrapper/jdapistd-16.c",
            "src/jdatadst.c",
            "src/jdatasrc.c",
            "src/wrapper/jdcoefct-8.c",
            "src/wrapper/jdcoefct-12.c",
            "src/wrapper/jdcolor-8.c",
            "src/wrapper/jdcolor-12.c",
            "src/wrapper/jdcolor-16.c",
            "src/wrapper/jddctmgr-8.c",
            "src/wrapper/jddctmgr-12.c",
            "src/wrapper/jddiffct-8.c",
            "src/wrapper/jddiffct-12.c",
            "src/wrapper/jddiffct-16.c",
            "src/jdhuff.c",
            "src/jdicc.c",
            "src/jdinput.c",
            "src/jdlhuff.c",
            "src/wrapper/jdlossls-8.c",
            "src/wrapper/jdlossls-12.c",
            "src/wrapper/jdlossls-16.c",
            "src/wrapper/jdmainct-8.c",
            "src/wrapper/jdmainct-12.c",
            "src/wrapper/jdmainct-16.c",
            "src/jdmarker.c",
            "src/jdmaster.c",
            "src/wrapper/jdmerge-8.c",
            "src/wrapper/jdmerge-12.c",
            "src/jdphuff.c",
            "src/wrapper/jdpostct-8.c",
            "src/wrapper/jdpostct-12.c",
            "src/wrapper/jdpostct-16.c",
            "src/wrapper/jdsample-8.c",
            "src/wrapper/jdsample-12.c",
            "src/wrapper/jdsample-16.c",
            "src/jdtrans.c",
            "src/jerror.c",
            "src/jfdctflt.c",
            "src/wrapper/jfdctfst-8.c",
            "src/wrapper/jfdctfst-12.c",
            "src/wrapper/jfdctint-8.c",
            "src/wrapper/jfdctint-12.c",
            "src/wrapper/jidctflt-8.c",
            "src/wrapper/jidctflt-12.c",
            "src/wrapper/jidctfst-8.c",
            "src/wrapper/jidctfst-12.c",
            "src/wrapper/jidctint-8.c",
            "src/wrapper/jidctint-12.c",
            "src/wrapper/jidctred-8.c",
            "src/wrapper/jidctred-12.c",
            "src/jmemmgr.c",
            "src/jmemnobs.c",
            "src/jpeg_nbits.c",
            "src/wrapper/jquant1-8.c",
            "src/wrapper/jquant1-12.c",
            "src/wrapper/jquant2-8.c",
            "src/wrapper/jquant2-12.c",
            "src/wrapper/jutils-8.c",
            "src/wrapper/jutils-12.c",
            "src/wrapper/jutils-16.c",
        },
        .flags = &.{
            "-DWITH_SIMD"
        }
    });

    b.installArtifact(lib);
}

const neon_sources = [_][]const u8 {
    "simd/arm/jccolor-neon.c",
    "simd/arm/jcgray-neon.c",
    "simd/arm/aarch32/jchuff-neon.c",
    "simd/arm/aarch64/jchuff-neon.c",
    "simd/arm/jcphuff-neon.c",
    "simd/arm/jcsample-neon.c",
    "simd/arm/jdcolor-neon.c",
    "simd/arm/jdmerge-neon.c",
    "simd/arm/jdsample-neon.c",
    "simd/arm/jfdctfst-neon.c",
    "simd/arm/jfdctint-neon.c",
    "simd/arm/jidctfst-neon.c",
    "simd/arm/jidctint-neon.c",
    "simd/arm/jidctred-neon.c",
    "simd/arm/jquanti-neon.c",
    "simd/arm/aarch32/jsimdcpu.c",
    "simd/arm/aarch64/jsimdcpu.c",
    "simd/jsimd.c"
};

fn addArmFiles(b: *std.Build, library: *std.Build.Step.Compile, is64: bool) void {
    const neon_compat = b.addConfigHeader(.{
        .style = .{
            .cmake = b.path("simd/arm/neon-compat.h.in"),
        },
        .include_path = "neon-compat.h"
    }, .{});

    library.addConfigHeader(neon_compat);
    library.addIncludePath(b.path("simd/arm"));

    const arch_sources = if (is64) blk: {
        var sources = std.array_list.Managed([]const u8).init(std.heap.page_allocator);
        defer sources.deinit();

        for (neon_sources) |source| {
            if (std.mem.indexOf(u8, source, "aarch32") == null) {
                sources.append(source) catch unreachable;
            }
        }
        break :blk sources.toOwnedSlice() catch unreachable;
    } else blk: {
        var sources = std.array_list.Managed([]const u8).init(std.heap.page_allocator);
        defer sources.deinit();

        for (neon_sources) |source| {
            if (std.mem.indexOf(u8, source, "aarch64") == null) {
                sources.append(source) catch unreachable;
            }
        }
        break :blk sources.toOwnedSlice() catch unreachable;
    };

    const flags = if (is64) &[_][]const u8 {
        "-DWITH_SIMD",
    } else &[_][]const u8 {
        "-DWITH_SIMD",
        "-mfpu=neon",
        "-mfloat-abi=softfp"
    };

    library.addCSourceFiles(.{
        .flags = flags,
        .files = arch_sources,
    });
}

const nasm_x86_64_sources: []const []const u8 = &.{
    "simd/x86_64/jsimdcpu.asm",
    "simd/x86_64/jfdctflt-sse.asm",
    "simd/x86_64/jccolor-sse2.asm",
    "simd/x86_64/jcgray-sse2.asm",
    "simd/x86_64/jchuff-sse2.asm",
    "simd/x86_64/jcphuff-sse2.asm",
    "simd/x86_64/jcsample-sse2.asm",
    "simd/x86_64/jdcolor-sse2.asm",
    "simd/x86_64/jdmerge-sse2.asm",
    "simd/x86_64/jdsample-sse2.asm",
    "simd/x86_64/jfdctfst-sse2.asm",
    "simd/x86_64/jfdctint-sse2.asm",
    "simd/x86_64/jidctflt-sse2.asm",
    "simd/x86_64/jidctfst-sse2.asm",
    "simd/x86_64/jidctint-sse2.asm",
    "simd/x86_64/jidctred-sse2.asm",
    "simd/x86_64/jquantf-sse2.asm",
    "simd/x86_64/jquanti-sse2.asm",
    "simd/x86_64/jccolor-avx2.asm",
    "simd/x86_64/jcgray-avx2.asm",
    "simd/x86_64/jcsample-avx2.asm",
    "simd/x86_64/jdcolor-avx2.asm",
    "simd/x86_64/jdmerge-avx2.asm",
    "simd/x86_64/jdsample-avx2.asm",
    "simd/x86_64/jfdctint-avx2.asm",
    "simd/x86_64/jidctint-avx2.asm",
    "simd/x86_64/jquanti-avx2.asm",
};

const nasm_i386_sources: []const []const u8 = &.{
    "simd/i386/jsimdcpu.asm",
    "simd/i386/jfdctflt-3dn.asm",
    "simd/i386/jidctflt-3dn.asm",
    "simd/i386/jquant-3dn.asm",
    "simd/i386/jccolor-mmx.asm",
    "simd/i386/jcgray-mmx.asm",
    "simd/i386/jcsample-mmx.asm",
    "simd/i386/jdcolor-mmx.asm",
    "simd/i386/jdmerge-mmx.asm",
    "simd/i386/jdsample-mmx.asm",
    "simd/i386/jfdctfst-mmx.asm",
    "simd/i386/jfdctint-mmx.asm",
    "simd/i386/jidctfst-mmx.asm",
    "simd/i386/jidctint-mmx.asm",
    "simd/i386/jidctred-mmx.asm",
    "simd/i386/jquant-mmx.asm",
    "simd/i386/jfdctflt-sse.asm",
    "simd/i386/jidctflt-sse.asm",
    "simd/i386/jquant-sse.asm",
    "simd/i386/jccolor-sse2.asm",
    "simd/i386/jcgray-sse2.asm",
    "simd/i386/jchuff-sse2.asm",
    "simd/i386/jcphuff-sse2.asm",
    "simd/i386/jcsample-sse2.asm",
    "simd/i386/jdcolor-sse2.asm",
    "simd/i386/jdmerge-sse2.asm",
    "simd/i386/jdsample-sse2.asm",
    "simd/i386/jfdctfst-sse2.asm",
    "simd/i386/jfdctint-sse2.asm",
    "simd/i386/jidctflt-sse2.asm",
    "simd/i386/jidctfst-sse2.asm",
    "simd/i386/jidctint-sse2.asm",
    "simd/i386/jidctred-sse2.asm",
    "simd/i386/jquantf-sse2.asm",
    "simd/i386/jquanti-sse2.asm",
    "simd/i386/jccolor-avx2.asm",
    "simd/i386/jcgray-avx2.asm",
    "simd/i386/jcsample-avx2.asm",
    "simd/i386/jdcolor-avx2.asm",
    "simd/i386/jdmerge-avx2.asm",
    "simd/i386/jdsample-avx2.asm",
    "simd/i386/jfdctint-avx2.asm",
    "simd/i386/jidctint-avx2.asm",
    "simd/i386/jquanti-avx2.asm",
};

fn addX86Files(b: *std.Build, lib: *std.Build.Step.Compile, target: std.Build.ResolvedTarget) void {
    const is64 = target.result.cpu.arch == .x86_64;
    const sources = if (is64) nasm_x86_64_sources else nasm_i386_sources;
    const nasm_dep = b.dependency("nasm", .{.optimize = .ReleaseFast});
    const nasm_exe = nasm_dep.artifact("nasm");
    
    var dargs = std.array_list.Managed([]const u8).init(std.heap.page_allocator);
    defer dargs.deinit();

    switch (target.result.ofmt) {
        .macho => {
            dargs.append("-f") catch unreachable;
            dargs.append(if (is64) "macho64" else "macho32") catch unreachable;
            dargs.append("-DMACHO") catch unreachable;
        },
        .elf => {
            dargs.append("-f") catch unreachable;
            dargs.append(if (is64) "elf64" else "elfx32") catch unreachable;
            dargs.append("-DELF") catch unreachable;
        },
        .coff => {
            dargs.append("-f") catch unreachable;
            dargs.append(if (is64) "win64" else "win32") catch unreachable;
            dargs.append("-DCOFF") catch unreachable;
        },
        else => {},
    }
    
    if (is64) {
        if (target.result.os.tag == .windows) {
            dargs.append("-DWIN64") catch unreachable;
        }
        dargs.append("-D__x86_64__") catch unreachable;
    } else {
        if (target.result.os.tag == .windows) {
            dargs.append("-DWIN32") catch unreachable;
        }
    }
    
    for (sources) |input_file| {
        const output_basename = basenameNewExtension(b, input_file, ".o");
        const nasm_run = b.addRunArtifact(nasm_exe);

        nasm_run.addArgs(dargs.items);

        // nasm requires a trailing slash on include directories
        const root = b.path(".").getPath3(b, &lib.step);
        nasm_run.addArg(b.fmt("-I{f}/", .{root}));
        nasm_run.addArg(b.fmt("-I{f}/simd/nasm/", .{root}));
        nasm_run.addArg(b.fmt("-I{f}/{s}/", .{root, std.fs.path.dirname(input_file).?}));

        // TODO: Zig 0.15:
        //nasm_run.addDecoratedDirectoryArg("-I", b.path("."), "/");
        //nasm_run.addDecoratedDirectoryArg("-I", b.path("."), "/nasm/");
        //nasm_run.addDecoratedDirectoryArg("-I", b.path(std.fs.path.dirname(input_file).?), "/");

        nasm_run.addArgs(&.{"-o"});
        lib.root_module.addObjectFile(nasm_run.addOutputFileArg(output_basename));

        nasm_run.addFileArg(b.path(input_file));
    }

    lib.root_module.addCSourceFiles(.{
        .files = &.{"simd/jsimd.c"}
    });
}

fn basenameNewExtension(b: *std.Build, path: []const u8, new_extension: []const u8) []const u8 {
    const basename = std.fs.path.basename(path);
    const ext = std.fs.path.extension(basename);
    return b.fmt("{s}{s}", .{ basename[0 .. basename.len - ext.len], new_extension });
}
