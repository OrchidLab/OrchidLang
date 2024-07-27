const std = @import("std");
const Lexer = @import("lexer.zig").Lexer;
const Prompt = ">> ";

pub fn repl(allocator: std.mem.Allocator) !void {
    var buffer: [1024]u8 = undefined;
    var writer = std.io.getStdOut().writer();
    var reader = std.io.getStdOut().reader();
    try writer.print("Welcome to Orchard Lang (.orl for short)\n", .{});
    while (true) {
        _ = try writer.write(Prompt);
        const line = try reader.readUntilDelimiterOrEof(&buffer, '\n') orelse break;
        if (line.len == 0) break;
        var lexer = try Lexer.init(allocator, line);
        while (lexer.next()) |token| {
            if (token == .eof) break;
            _ = try writer.print("{s}  ", .{token.to_string()});
        }
        _ = try writer.print("\r\n", .{});
    }
}
