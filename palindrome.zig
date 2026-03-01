const std = @import("std");

fn isPalindrome(s: []const u8) bool {
    var i: usize = 0;
    var j: usize = s.len;

    if (j == 0) return false;
    j -= 1;

    while (i < j) {
        if (s[i] != s[j]) return false;
        i += 1;
        j -= 1;
    }
    return true;
}

pub fn main() !void {
    const stdio = std.io.getStdOut().writer();
    const allocator = std.heap.page_allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        try stdio.print("Usage: palindromes <text>\n", .{});
        return;
    }

    const text = args[1];
    const len = text.len;

    try stdio.print("Palindromes found:\n", .{});

    for (0..len) |start| {
        for (start + 1..len + 1) |end| {
            const substr = text[start..end];
            if (isPalindrome(substr)) {
                try stdio.print("{s}\n", .{substr});
            }
        }
    }
}