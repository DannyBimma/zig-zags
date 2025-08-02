const std = @import("std");
const printer = std.debug.print; // Cool lil' trick

const TotalValues = struct {
    chars: u32,
    words: u32,
    sentences: u32,
    lines: u32,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}{});
    defer _ = gpa.deinit();
    const allocate = gpa.allocator();

    const args = try std.process.argsAlloc(allocate);
    defer std.process.argsFree(allocate, args);

    if (args.len != 2) {
        printer("Improper Program Operation:\n In order to run program, input: {s} <file_name>", .{args[0]});
        std.process.exit(1);
    }

    const textfile = args[1];

    const file = std.fs.cwd().openFile(textfile, .{}) catch |err| {
        switch (err) {
            error.FileNotFound => {
                printer("Sorry: Ain't no file named '{s}' up in here\n", .{textfile});
                std.process.exit(1);
            },
            error.AccessDenied => {
                printer("Sorry: Your access to the '{s}' file has been denied\n", .{textfile});
                std.process.exit(1);
            },
            else => {
                printer("Sorry: The '{s}' file faled to open succesfully for some reason or another: {}\n", .{ textfile, err });
                std.process.exit(1);
            },
        }
    };
    defer file.close();

    const file_size = try file.getEndPos();
    const content = try allocate.alloc(u8, file_size);
    defer allocate.free(content);

    _ = try file.readAll(content);
}
