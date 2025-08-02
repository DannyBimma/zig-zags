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
    const alloc = gpa.allocator();

    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);
}
