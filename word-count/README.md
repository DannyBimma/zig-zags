# Word Count - A Zig Adaptation of WC

A text analysis tool written in Zig that counts the characters, words, sentences, and lines in a text file.

## Features

- **Character counting**: Counts all characters including white-spaces
- **Word counting**: Counts words separated by spaces, tabs, or newlines
- **Sentence counting**: Counts sentences ending with `.`, `!`, or `?`
- **Line counting**: Counts all new-lines (\n)'s in the file
- **Error handling**: Comprehensive error messages for common file access issues
- **Memory safety**: Uses Zig's built-in memory management with proper clean-up (I love it)

## Building the Project

### Prerequisites

- Zig 0.14.1 or later

### Build Commands

```bash
# Build the project (creates both library and executable)
zig build

# Build and run with a file argument
zig build run -- <filename>

# Run tests
# (if I didn't write any just read the source-code, it's simple enough, innit?)
zig build test

# Get help with available build options
zig build --help
```

## Usage

### Basic Usage

```bash
# After building, run the executable directly
./zig-out/bin/word_count <filename>

# Or use the build system
zig build run -- <filename>
```

### Example

```bash
# Count statistics for the sample text file
zig build run -- src/witch_hat_and_the_magic_of_cs.txt
```

**Output:**

```
File: src/witch_hat_and_the_magic_of_cs.txt
Characters: 3638
Words: 630
Sentences: 36
Lines: 73
```

### Error Handling

The program provides helpful error messages:

- **File not found**: `Sorry: Ain't no file named 'filename' up in here`
- **Access denied**: `Sorry: Your access to the 'filename' file has been denied`
- **Invalid usage**: `Improper Program Operation: In order to run program, input: word_count <file_name>`

## Project Structure

```
word-count/
├── build.zig          # Build configuration
├── build.zig.zon      # Package metadata
├── src/
│   ├── main.zig       # Main executable entry point
│   ├── root.zig       # Library entry point (placeholder)
│   └── witch_hat_and_the_magic_of_cs.txt  # Sample text file
└── zig-out/
    ├── bin/
    │   └── word_count # Built executable
    └── lib/
        └── libword_count.a  # Built static library
```

## Technical Implementation

### Core Algorithm

The text analysis is performed by the `textCounter69` 😜 function, which:

1. Iterates through each character in the file
2. Maintains state for word boundaries using an `in_word` boolean
3. Counts characters, words, sentences, and lines simultaneously in a single pass
4. Handles edge cases like files not ending with newlines

### Memory Management

- Uses Zig's `GeneralPurposeAllocator` with proper deferred clean-up
- Allocates memory for the entire file content at once for efficient processing
- All allocations are properly freed to prevent memory leaks

### Error Handling

- Comprehensive error handling for file operations using Zig's error union types
- Pattern matching on specific error types for user-friendly messages
- Graceful exit with appropriate status codes

---

## Technical Power-scaling: Zig vs C

### Memory Safety Advantages

**Zig Implementation:**

```zig
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
defer _ = gpa.deinit();
const allocate = gpa.allocator();

const content = try allocate.alloc(u8, file_size);
defer allocate.free(content);
```

**Equivalent C Implementation would be:**

```c
char *content = malloc(file_size);
if (!content) {
    fprintf(stderr, "Memory allocation failed\n");
    exit(1);
}
// Manual free() required - easy to forget!
free(content);
```

**Advantages:**

- **Automatic clean-up**: Zig's `defer` ensures memory is freed even if early returns occur
- **No null pointer dereferences**: Zig's type system prevents accessing null pointers
- **Allocation failure handling**: Zig's error types force explicit handling of allocation failures

### Error Handling Improvements

**Zig Implementation:**

```zig
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
            printer("Sorry: The '{s}' file failed to open successfully: {}\n", .{ textfile, err });
            std.process.exit(1);
        },
    }
};
```

**Equivalent C Implementation:**

```c
FILE *file = fopen(textfile, "r");
if (!file) {
    // errno is global state - thread safety issues
    if (errno == ENOENT) {
        fprintf(stderr, "File not found: %s\n", textfile);
    } else if (errno == EACCES) {
        fprintf(stderr, "Access denied: %s\n", textfile);
    } else {
        perror("Failed to open file");
    }
    exit(1);
}
```

**Advantages:**

- **Explicit error types**: Zig errors are part of the type system, not global state
- **Exhaustive error handling**: Compiler ensures all error cases are handled
- **No errno confusion**: Error types are explicit and type-safe

### Type Safety and Zero-Cost Abstractions

**Zig Implementation:**

```zig
const Tabulator = struct {
    chars: u32,
    words: u32,
    sentences: u32,
    lines: u32,
};

fn textCounter69(content: []const u8) Tabulator {
    var result = Tabulator{
        .chars = 0,
        .words = 0,
        .sentences = 0,
        .lines = 0,
    };
    // ...
}
```

**C Equivalent:**

```c
struct tabulator {
    unsigned int chars;
    unsigned int words;
    unsigned int sentences;
    unsigned int lines;
};

struct tabulator text_counter(const char *content, size_t len) {
    struct tabulator result = {0, 0, 0, 0};
    // Manual bounds checking required for content[i]
    // ...
}
```

**Advantages:**

- **Slice types**: `[]const u8` includes a length property, preventing buffer overflows
- **Struct initialisation**: Guaranteed initialisation of all fields
- **Compile-time checks**: No uninitialised variables or buffer overruns

### Build System Integration

**Zig Implementation:**

- **Single build.zig file**: Declarative build configuration
- **Cross-compilation**: Built-in support for multiple targets
- **Dependency management**: Integrated package manager
- **Test integration**: Built-in test runner

**C Equivalent:**

- **Multiple build files**: Makefile, CMakeLists.txt, or configure scripts
- **Cross-compilation**: Complex tool-chain setup required
- **Dependency management**: External tools like pkg-config or vcpkg
- **Test integration**: Separate test frameworks needed

### Performance Characteristics

Both implementations have a similar algorithmic complexity O(n) for file size, but Zig provides:

1. **Zero-cost abstractions**: High-level constructs compile to efficient machine code
2. **Explicit allocation**: Clear control over memory usage patterns
3. **Bounds checking**: Safety checks can be disabled in release builds for maximum performance
4. **Optimization**: LLVM back-end provides excellent code generation

### Code Readability and Maintenance

**Zig advantages:**

- **Clear intent**: Type system makes assumptions explicit
- **Self-documenting**: Error types and slice bounds are part of the interface
- **Consistent style**: Built-in formatter ensures consistent code style
- **Compile-time guarantees**: Most bugs are caught at compile time rather than runtime

This is an extremely simply program, but my favourite to build when learning a new language.
The Zig implementation demonstrates how modern systems programming languages can provide
C-like performance; while significantly improving safety, maintainability, and developer
experience. The source code was truly a joy to write 🙂

