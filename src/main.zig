const std = @import("std");
const repl = @import("repl.zig");

pub fn main() !void {
    var heap = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = heap.allocator();
    try repl.repl(gpa);
}
