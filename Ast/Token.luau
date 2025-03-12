--!strict
--!optimize 2
--!native

local Enumerate = require("../Common/Enumerate.luau")
local Location = require("./Location.luau")

export type TokenImpl = {
	__index: TokenImpl;
	
	kind: Enumerate.strict;
	
	new: (
		tokenKind: Enumerate.kind,
		location: Location.Location?,
		value: any?
	) -> Token;
	is: (
		object: any
	) -> boolean;
}

export type Token = typeof(setmetatable({} :: {
	kind: Enumerate.kind;
	location: Location.Location?;
	value: any?;
}, {} :: TokenImpl))

export type TokenKind = Enumerate.kind

local TokenImpl = {} :: TokenImpl
TokenImpl.__index = TokenImpl

TokenImpl.kind = Enumerate("token.kind", {
	"var", "return", "if", "elif", "else", "switch", "case", "default", "for", "while", "each", "continue", "break", "fn", "class", "type",
	
	"true", "false", "none",
	
	"plus", "minus", "star", "slash", "modulo", "caret", "ampersand", "pipe", "dot2", "exclamationMark", "hashtag", "dot", "comma", "dot3", "semiColon", "dollar", "at2", "at",
	
	"equal", "equalTo", "notEqual", "lessThan", "lessEqual", "greaterThan", "greaterEqual",
	
	"leftParen", "rightParen", "leftBrace", "rightBrace", "leftBracket", "rightBracket",
	
	"plusEqual", "minusEqual", "starEqual", "slashEqual", "moduloEqual", "caretEqual", "dot2Equal",
	
	"comment", "multilineComment",
	
	"iden", "builtin", "string", "multilineString", "number",
	
	"unknown", "eof"
})

function TokenImpl.new(
	tokenKind: TokenKind,
	location: Location.Location?,
	value: any?
): Token
	local self = {}

	self.kind = tokenKind
	self.location = location
	self.value = value

	return setmetatable(self, TokenImpl)
end

function TokenImpl.is(object)
	return type(object) == "table" and getmetatable(object) == TokenImpl
end

return TokenImpl