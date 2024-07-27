const std = @import("std");

pub const Token = union(enum) {
    eof,
    illegal,
    assign,
    plus,
    minus,
    bang,
    asterisk,
    fslash,
    lt,
    gt,
    eq,
    not_eq,
    comma,
    semicolon,
    lparen,
    rparen,
    lbrace,
    rbrace,

    identifier: []const u8,
    integer: []const u8,

    keyword_fn,
    keyword_let,
    keyword_return,
    keyword_true,
    keyword_false,
    keyword_if,
    keyword_else,

    pub fn to_string(token: Token) []const u8 {
        return switch (token) {
            .identifier => token.identifier,
            .keyword_let => "\n(STMT) let",
            .keyword_return => "\n(STMT) return",
            .keyword_fn => "\n(STMT) fn",
            else => @tagName(token),
        };
    }
};

pub const Lexer = struct {
    buffer: []const u8,
    cursor: usize = 0,
    char: u8 = undefined,
    map: std.StringHashMap(Token),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, buffer: []const u8) !@This() {
        var map = std.StringHashMap(Token).init(allocator);
        {
            _ = try map.put("fn", .keyword_fn);
            _ = try map.put("let", .keyword_let);
            _ = try map.put("return", .keyword_return);
            _ = try map.put("true", .keyword_true);
            _ = try map.put("false", .keyword_false);
            _ = try map.put("if", .keyword_if);
            _ = try map.put("else", .keyword_else);
        }
        var l: Lexer = .{ .buffer = buffer, .allocator = allocator, .map = map };
        l.advance();
        return l;
    }

    pub fn deinit(self: *@This()) void {
        self.map.deinit();
        self.* = undefined;
    }

    /// Read char under cursor and set it to self.char
    /// If buffer permits, advance cursor
    pub fn advance(self: *@This()) void {
        if (self.cursor >= self.buffer.len) {
            self.char = 0;
        } else {
            self.char = self.buffer[self.cursor];
        }
        self.cursor += 1;
    }

    pub fn next(self: *@This()) ?Token {
        while (std.ascii.isWhitespace(self.char)) self.advance();
        var token: ?Token = null;
        switch (self.char) {
            ';' => token = .semicolon,
            '(' => token = .lparen,
            ')' => token = .rparen,
            '{' => token = .lbrace,
            '}' => token = .rbrace,
            ',' => token = .comma,
            '+' => token = .plus,
            '-' => token = .minus,
            '*' => token = .asterisk,
            '/' => token = .fslash,
            '<' => token = .lt,
            '>' => token = .gt,
            '=' => {
                if (self.peek() == '=') {
                    self.advance();
                    token = .eq;
                } else {
                    token = .assign;
                }
            },
            '!' => {
                if (self.peek() == '=') {
                    self.advance();
                    token = .not_eq;
                } else {
                    token = .bang;
                }
            },

            'a'...'z', 'A'...'Z', '_' => return self.lookup(),
            '0'...'9' => return .{ .integer = self.read_integer() },
            0 => token = .eof,
            else => token = .illegal,
        }

        self.advance();
        return token;
    }

    fn read(self: *@This()) []const u8 {
        const position = self.cursor - 1;
        while (std.ascii.isAlphanumeric(self.char)) self.advance();
        return self.buffer[position .. self.cursor - 1];
    }

    fn read_integer(self: *@This()) []const u8 {
        const position = self.cursor - 1;
        while (std.ascii.isDigit(self.char)) self.advance();
        return self.buffer[position .. self.cursor - 1];
    }

    fn peek(self: *@This()) u8 {
        if (self.cursor >= self.buffer.len) {
            return 0;
        } else {
            return self.buffer[self.cursor];
        }
    }

    fn lookup(self: *@This()) Token {
        const identifier = self.read();
        if (self.map.get(identifier)) |token| {
            return token;
        } else {
            return .{ .identifier = identifier };
        }
    }
};

test "Lexer ops" {
    const buffer = @embedFile("./basic-program.ol");
    std.debug.print("{s}\n", .{buffer});
    const a = std.testing.allocator;
    var lexer = try Lexer.init(a, buffer);
    defer lexer.deinit();
    while (lexer.next()) |token| {
        if (token == .eof) break;
        std.debug.print("{s} ", .{token.to_string()});
    }
}
