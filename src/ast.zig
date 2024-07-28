const std = @import("std");
const Token = @import("lexer.zig").Token;
const Lexer = @import("lexer.zig").Lexer;

pub const Node = union(enum) {
    Let: Let,
    Return: Return,
    Identifier: Identifier,
    Expression: Expression,
};

pub const Identifier = struct {
    token: Token,
};

pub const Let = struct {
    token: Token,
    name: Identifier,
    value: ?Expression,
};

pub const Return = struct {
    token: Token,
    value: ?Expression,
};

pub const Expression = struct {
    token: Token,
};
pub const Tree = std.ArrayList(Node);
