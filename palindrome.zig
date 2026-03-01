const std = @import("std");

fn isPalindrome(s: []const u8) bool {
    if (s.len == 0) return false;

    var i: usize = 0;
    var j: usize = s.len - 1;

    while (i < j) {
        if (s[i] != s[j]) return false;
        i += 1;
        j -= 1;
    }
    return true;
}

pub fn main(init: std.process.Init) !void {
    var iter = try std.process.Args.Iterator.initAllocator(init.minimal.args, init.gpa);
    defer iter.deinit();

    _ = iter.next(); // skip executable name

    const text = iter.next() orelse {
        std.debug.print("Usage: palindrome <text>\n", .{});
        return;
    };

    std.debug.print("Palindromes found:\n", .{});

    for (0..text.len) |start| {
        for (start + 1..text.len + 1) |end| {
            const substr = text[start..end];
            if (isPalindrome(substr)) {
                std.debug.print("{s}\n", .{substr});
            }
        }
    }
}