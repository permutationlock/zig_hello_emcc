const std = @import("std");
const builtin = @import("builtin");
const Builder = std.build.Builder;

const emccOutputDir = "zig-out"
    ++ std.fs.path.sep_str
    ++ "htmlout"
    ++ std.fs.path.sep_str;
const emccOutputFile = "index.html";

pub fn build(b: *Builder) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    if (target.os_tag == .emscripten) {
        const lib = b.addStaticLibrary(.{
            .name = "hello_emcc",
            .root_source_file = .{ .path = "main.zig" },
            .link_libc = true,
            .target = target,
            .optimize = optimize,
        });

        const emcc_exe = switch (builtin.os.tag) {
            .windows => "emcc.bat",
            else => "emcc",
        };

        const mkdir_command = b.addSystemCommand(
            &[_][]const u8{ "mkdir", "-p", emccOutputDir }
        );
        const emcc_command = b.addSystemCommand(&[_][]const u8{emcc_exe});
        emcc_command.addFileArg(lib.getEmittedBin());
        emcc_command.step.dependOn(&lib.step);
        emcc_command.step.dependOn(&mkdir_command.step);
        emcc_command.addArgs(&[_][]const u8{
            "-o",
            emccOutputDir ++ emccOutputFile,
            "-Oz",
            "-sASYNCIFY",
        });

        // emcc flag necessary for debug builds
        if (optimize == .Debug or optimize == .ReleaseSafe) {
            emcc_command.addArgs(&[_][]const u8{
                "-sUSE_OFFSET_CONVERTER",
            });
        }
        b.getInstallStep().dependOn(&emcc_command.step);
    } else {
        const exe = b.addExecutable(.{
            .name = "hello_emcc",
            .root_source_file = .{ .path = "main.zig" },
            .target = target,
            .optimize = optimize,
        });

        b.installArtifact(exe);
    }
}
