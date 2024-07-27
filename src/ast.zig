const std = @import("std");
const Token = @import("lexer.zig").Token;
const Lexer = @import("lexer.zig").Lexer;

pub const Node = union(enum) {};
