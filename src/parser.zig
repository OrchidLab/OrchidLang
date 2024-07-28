const std = @import("std");
const Token = @import("lexer.zig").Token;
const Lexer = @import("lexer.zig").Lexer;
const ast = @import("ast.zig");
const Node = @import("ast.zig").Node;
const Tree = @import("ast.zig").Tree;
const Identifier = @import("ast.zig").Identifier;
const Expression = @import("ast.zig").Expression;

// Stopped at Implementing the Pratt Parser
pub const Parser = struct {
    lexer: *Lexer,
    token: Token,
    prefix: std.AutoHashMap(Token, prefixFn),
    infix: std.AutoHashMap(Token, infixFn),

    pub const prefixFn = *const fn (*Parser) anyerror!?Tree;
    pub const infixFn = *const fn (*Parser) anyerror!?Tree;

    pub fn init(lexer: *Lexer) @This() {
        var parser = Parser{ .lexer = lexer, .token = .illegal };
        parser.next();
        return parser;
    }

    pub fn deinit(self: *@This()) void {
        self.lexer.deinit();
        self.* = undefined;
    }

    pub fn next(self: *@This()) void {
        if (self.lexer.*.next()) |token| self.token = token;
    }

    pub fn parseProgram(self: *@This()) !Tree {
        var tree = Tree.init(self.lexer.allocator);
        errdefer tree.deinit();
        while (self.token != .eof) : (self.next()) {
            const statement = try self.parseStatement() orelse continue;
            try tree.append(statement);
        }

        return tree;
    }

    pub fn parseStatement(self: *@This()) !?Node {
        std.debug.print("{s}\n", .{self.token.to_string()});
        return switch (self.token) {
            .keyword_let => try self.parseLetStatement(),
            .keyword_return => try self.parseReturnStatement(),
            else => return null,
        };
    }

    fn parseLetStatement(self: *@This()) !?Node {
        var node: ast.Let = .{ .token = self.token, .name = undefined, .value = undefined };
        self.next();
        if (self.token != .identifier) return error.UnexpectedToken;
        node.name = Identifier{ .token = self.token };
        self.next();
        if (self.token != .assign) return error.UnexpectedToken;
        self.next();
        if (self.token != .integer) return error.UnexpectedToken;
        node.value = Expression{ .token = self.token };
        self.next();
        if (self.token != .semicolon) return error.UnexpectedToken;
        return Node{ .Let = node };
    }

    fn parseReturnStatement(self: *@This()) !?Node {
        var node: ast.Return = .{ .token = self.token, .value = undefined };
        self.next();
        std.debug.print("{s}\n", .{self.token.to_string()});
        if (self.token != .integer) return error.UnexpectedToken;
        node.value = Expression{ .token = self.token };
        return Node{ .Return = node };
    }
};

test "Parser" {
    const buffer =
        \\ let x = 5;
        \\ let y = 6;
        \\ return 5;
    ;
    std.debug.print("{s}\n", .{buffer});
    const gpa = std.testing.allocator;
    var l = try Lexer.init(gpa, buffer);
    var p = Parser.init(&l);
    var tree = try p.parseProgram();
    defer {
        p.deinit();
        tree.deinit();
    }

    while (tree.popOrNull()) |statement| {
        std.debug.print("{any} \n", .{statement});
    }
}
