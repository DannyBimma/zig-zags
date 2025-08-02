const std = @import("std");
const printer = std.debug.print; // Cool lil' trick

const Tabulator = struct {
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

    const stats = textCounter69(content);

    printer("File: {s}\n", .{textfile});
    printer("Characters: {}\n", .{stats.characters});
    printer("Words: {}\n", .{stats.words});
    printer("Sentences: {}\n", .{stats.sentences});
    printer("Lines: {}\n", .{stats.lines});
}

fn isWord(c: u8) bool {
    return c == ' ' or c == '\t' or c == '\n' or c == '\r';
}

fn isSentence(c: u8) bool {
    return c == '.' or c == '!' or c == '?';
}

fn textCounter69(content: []const u8) Tabulator {
    var result = Tabulator{
        .chars = 0,
        .words = 0,
        .sentences = 0,
        .lines = 0,
    };

    var in_word = false;
    var i: usize = 0;

    while (i < content.len) {
        const c = content[i];

        result.characters += 1;

        if (c == '\n') {
            result.lines += 1;
        }

        if (isWord(c)) {
            if (in_word) {
                result.words += 1;
                in_word = false;
            }
        } else {
            in_word = true;
        }

        if (isSentence(c)) {
            result.sentences += 1;
        }

        i += 1;
    }

    if (in_word) {
        result.words += 1;
    }

    if (content.len > 0 and content[content.len - 1] != '\n') {
        result.lines += 1;
    }

    return result;
}
