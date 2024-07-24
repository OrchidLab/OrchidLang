const std = @import("std");

const Token = union(enum) {
    eof,
    illegal,
    assign,
    plus,
    comma,
    semicolon,
    lparen,
    rparen,
    lbrace,
    rbrace,

    identifier: []const u8,
    int: []const u8,

    keyword_fn,
    keyword_let,
};

pub const Lexer = struct {
    buffer: []const u8,
    cursor: usize = 0,
    char: u8 = undefined,

    pub fn init(buffer: []const u8) @This() {
        var l: Lexer = .{ .buffer = buffer };
        l.advance();
        return l;
    }

    /// Read char under cursor and set it to self.char
    /// If buffer permits, advance cursor
    pub fn advance(self: *@This()) void {
        if (self.cursor + 1>= self.buffer.len) {
            self.char = 0;
        } else {
            self.char = self.buffer[self.cursor];
        }
        self.cursor += 1;
    }

    fn read(self: *@This()) []const u8 {
        const position = self.cursor;
        while (std.ascii.isAlphanumeric(self.char)) self.advance();
        return self.buffer[position..self.cursor];
    }

    pub fn next(self: *@This()) ?Token {
        var token: ?Token = null;
        switch (self.char) {
            '=' => token = .assign,
            ';' => token = .semicolon,
            '(' => token = .lparen,
            ')' => token = .rparen,
            '{' => token = .lbrace,
            '}' => token = .rbrace,
            ',' => token = .comma,
            '+' => token = .plus,
            'a'...'z', 'A'...'Z', '_' => {
                return .{ .identifier = self.read() };
            },
            0 => token = .eof,
            else => token = .illegal,
        }

        self.advance();
        return token;
    }
};

test "Lexer ops" {
    const buffer = "=;()+zb";
    var lexer = Lexer.init(buffer);
    while (lexer.next()) |token| {
        if (token == .eof) break;
        std.debug.print("{any}\n", .{token});
    }
}
