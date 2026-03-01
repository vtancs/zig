const std = @import("std");
pub fn main(init: std.process.Init) !void {
    _ = init;
    const info = @typeInfo(std.process.Init);
    _ = info;
}