--!strict
--!optimize 2
--!native

local Position = require("./Position.luau")
local Location = require("./Location.luau")
local Token = require("./Token.luau")

export type LexerImpl = {
	__index: LexerImpl;
	
	eof: string;
	eol: string;
	whitespace: string;
	digit: string;
	alphabet: string;
	hexadecimal: string;
	
	escapeSequences: {
		[string]: string;
	};
	keywords: {
		[string]: Token.TokenKind;
	};
	builtins: {
		--// TODO: do this
	};
	operators: {
		[string]: Token.TokenKind;
	};
	
	sortedOperators: {
		{
			[string]: Token.TokenKind;
		}
	};
	
	new: (
		source: string
	) -> Lexer;
	is: (
		object: any
	) -> boolean;
	sortOperators: (
		operators: {
			[string]: Token.TokenKind;
		}
	) -> {
		{
			[string]: Token.TokenKind;
		}
	};
	
	_position: (
		self: Lexer
	) -> Position.Position;
	_pervPosition: (
		self: Lexer
	) -> Position.Position;
	_nextPosition: (
		self: Lexer
	) -> Position.Position;
	_move: (
		self: Lexer
	) -> ();
	_moveBy: (
		self: Lexer,
		count: number
	) -> ();
	_back: (
		self: Lexer
	) -> ();
	_backBy: (
		self: Lexer,
		count: number
	) -> ();
	_peek: (
		self: Lexer,
		count: number?
	) -> string;
	_perv: (
		self: Lexer
	) -> string;
	_next: (
		self: Lexer
	) -> string;
	_consume: (
		self: Lexer,
		character: string
	) -> ();
	_concat: (
		self: Lexer,
		clear: boolean?
	) -> string;
	_clear: (
		self: Lexer
	) -> ();
	_match: (
		self: Lexer,
		toMatch: string
	) -> boolean;
	_advance: (
		self: Lexer
	) -> string;
	_accept: (
		self: Lexer,
		toMatch: string
	) -> string?;
	_addStack: (
		self: Lexer,
		toStack: string
	) -> ();
	_removeStack: (
		self: Lexer
	) -> ();
	_getStack: (
		self: Lexer,
		index: number?
	) -> string;
	_peekToken: (
		self: Lexer
	) -> Token.Token;
	_pervToken: (
		self: Lexer
	) -> Token.Token;
	_isEOF: (
		self: Lexer,
		character: string
	) -> boolean;
	_isEOL: (
		self: Lexer,
		character: string
	) -> boolean;
	_isWhitespace: (
		self: Lexer,
		character: string
	) -> boolean;
	_isDigit: (
		self: Lexer,
		character: string
	) -> boolean;
	_isAlpha: (
		self: Lexer,
		character: string
	) -> boolean;
	_isBinary: (
		self: Lexer,
		character: string
	) -> boolean;
	_isHex: (
		self: Lexer,
		character: string
	) -> boolean;
	_isOperator: (
		self: Lexer,
		character: string
	) -> boolean;
	
	_readString: (
		self: Lexer
	) -> Token.Token;
	_readMultilineString: (
		self: Lexer
	) -> Token.Token;
	_readComment: (
		self: Lexer
	) -> Token.Token;
	_readMultilineComment: (
		self: Lexer
	) -> Token.Token;
	_readIden: (
		self: Lexer
	) -> Token.Token;
	_readNumber: (
		self: Lexer
	) -> Token.Token;
	_readBinaryNumber: (
		self: Lexer
	) -> Token.Token;
	_readHexadecimalNumber: (
		self: Lexer
	) -> Token.Token;
	_readDot: (
		self: Lexer
	) -> Token.Token;
	_readUnknown: (
		self: Lexer
	) -> Token.Token;
	
	_read: (
		self: Lexer
	) -> Token.Token | boolean;
	scan: (
		self: Lexer
	) -> { Token.Token };
};

export type Lexer = typeof(setmetatable({} :: {
	source: string;
	tokens: { Token.Token };
	
	_offset: number;
	_line: number;
	_lineOffset: number;
	_lastLineOffset: number;
	_charArray: { string };
	_stack: { string };
}, {} :: LexerImpl))

local LexerImpl = {} :: LexerImpl
LexerImpl.__index = LexerImpl

LexerImpl.eof = ""
LexerImpl.eol = "\n\r"
LexerImpl.whitespace = "\32\t\n\r\f"
LexerImpl.digit = "0123456789"
LexerImpl.alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
LexerImpl.hexadecimal = "abcdefABCDEF" .. LexerImpl.digit

LexerImpl.escapeSequences = {
	["a"] = "\a";
	["b"] = "\b";
	["f"] = "\f";
	["n"] = "\n";
	["r"] = "\r";
	["t"] = "\t";
	["v"] = "\v";
	["\\"] = "\\";
	["'"] = "'";
	['"'] = '"';
}

LexerImpl.keywords = {
	["var"] = Token.kind["var"];
	["return"] = Token.kind["return"];
	["if"] = Token.kind["if"];
	["elif"] = Token.kind["elif"];
	["else"] = Token.kind["else"];
	["switch"] = Token.kind["switch"];
	["case"] = Token.kind["case"];
	["default"] = Token.kind["default"];
	["for"] = Token.kind["for"];
	["while"] = Token.kind["while"];
	["each"] = Token.kind["each"];
	["continue"] = Token.kind["continue"];
	["break"] = Token.kind["break"];
	["fn"] = Token.kind["fn"];
	["class"] = Token.kind["class"];
	["type"] = Token.kind["type"];
	["true"] = Token.kind["true"];
	["false"] = Token.kind["false"];
	["none"] = Token.kind["none"];
}

LexerImpl.builtins = {}

LexerImpl.operators = {
	["+"] = Token.kind.plus;
	["-"] = Token.kind.minus;
	["*"] = Token.kind.star;
	["/"] = Token.kind.slash;
	["%"] = Token.kind.modulo;
	["^"] = Token.kind.caret;
	["&"] = Token.kind.ampersand;
	["|"] = Token.kind.pipe;
	[".."] = Token.kind.dot2;
	["!"] = Token.kind.exclamationMark;
	["#"] = Token.kind.hashtag;
	["."] = Token.kind.dot;
	[","] = Token.kind.comma;
	["..."] = Token.kind.dot3;
	[";"] = Token.kind.semiColon;
	["$"] = Token.kind.dollar;
	["@"] = Token.kind.at;
	["@@"] = Token.kind.at2;
	
	["="] = Token.kind.equal;
	["!="] = Token.kind.notEqual;
	["=="] = Token.kind.equalTo;
	["<"] = Token.kind.lessThan;
	["<="] = Token.kind.lessEqual;
	[">"] = Token.kind.greaterThan;
	[">="] = Token.kind.greaterEqual;
	
	["("] = Token.kind.leftParen;
	[")"] = Token.kind.rightParen;
	["{"] = Token.kind.leftBrace;
	["}"] = Token.kind.rightBrace;
	["["] = Token.kind.leftBracket;
	["]"] = Token.kind.rightBracket;
	
	["+="] = Token.kind.plusEqual;
	["-="] = Token.kind.minusEqual;
	["*="] = Token.kind.starEqual;
	["/="] = Token.kind.slashEqual;
	["%="] = Token.kind.moduloEqual;
	["^="] = Token.kind.caretEqual;
	["..="] = Token.kind.dot2Equal;
}

function LexerImpl.new(
	source: string
): Lexer
	local self = {}
	
	self.source = source
	self.tokens = {}
	
	self._offset = 1
	self._line = 1
	self._lineOffset = 0
	self._lastLineOffset = 0
	self._charArray = {}
	self._stack = {}
	
	return setmetatable(self, LexerImpl)
end

function LexerImpl.is(
	object: any
): boolean
	return type(object) == "table" and getmetatable(object) == LexerImpl
end

function LexerImpl.sortOperators(
	operators: {
		[string]: Token.TokenKind;
	}
): {
	{
		[string]: Token.TokenKind;
	}
}
	local tables = {}

	for operator, token in operators do
		local length = operator:len()

		if not tables[length] then
			for i = 1, length do
				tables[i] = tables[i] or {}
			end
		end

		tables[length][operator] = token
	end

	return tables
end

function LexerImpl:_position(): Position.Position
	return Position.new(self._line, self._offset - self._lineOffset)
end

function LexerImpl:_pervPosition(): Position.Position
	self:_back()
	local pervPosition = Position.new(self._line, self._offset - self._lineOffset)
	self:_move()
	
	return pervPosition
end

function LexerImpl:_nextPosition(): Position.Position
	self:_move()
	local pervPosition = Position.new(self._line, self._offset - self._lineOffset)
	self:_back()

	return pervPosition
end

function LexerImpl:_move()
	if self:_isEOL(self.source:sub(self._offset, self._offset)) then
		self._line += 1
		self._lastLineOffset = self._lineOffset
		self._lineOffset = self._offset + 1
	end

	self._offset += 1
end

function LexerImpl:_moveBy(
	count: number
)
	for i = 1, count do
		self:_move()
	end
end

function LexerImpl:_back()
	self._offset -= 1
	
	if self:_isEOL(self.source:sub(self._offset, self._offset)) then
		self._line -= 1
		self._lineOffset = self._lastLineOffset
	end
end

function LexerImpl:_backBy(
	count: number
)
	for i = 1, count do
		self:_back()
	end
end

function LexerImpl:_peek(
	count: number?
): string
	local count = count or 0
	
	local endPosition = count + self._offset
	
	return self.source:sub(self._offset, endPosition)
end

function LexerImpl:_perv(): string
	return self.source:sub(self._offset - 1, self._offset - 1)
end

function LexerImpl:_next(): string
	return self.source:sub(self._offset + 1, self._offset + 1)
end

function LexerImpl:_consume(
	character: string
)
	table.insert(self._charArray, character)
end

function LexerImpl:_concat(
	clear: boolean?
): string
	local asString = table.concat(self._charArray)
	
	if clear then
		self:_clear()
	end
	
	return asString
end

function LexerImpl:_clear()
	table.clear(self._charArray)
end

function LexerImpl:_match(
	toMatch: string
): boolean
	return self:_peek(#toMatch - 1) == toMatch
end

function LexerImpl:_advance()
	local character = self:_peek()
	
	self:_move()
	
	return character
end

function LexerImpl:_accept(
	toMatch: string
): string?
	if self:_match(toMatch) then
		self:_moveBy(#toMatch)
		
		return toMatch
	end
	
	return nil
end

function LexerImpl:_addStack(
	toStack: string
)
	table.insert(self._stack, toStack)
end

function LexerImpl:_removeStack()
	self._stack[#self._stack] = nil
end

function LexerImpl:_getStack(
	index: number?
): string
	local index = index or #self._stack
	
	return self._stack[index]
end

function LexerImpl:_peekToken(): Token.Token
	return self.tokens[#self.tokens]
end

function LexerImpl:_pervToken(): Token.Token
	return self.tokens[#self.tokens - 1]
end

function LexerImpl:_isEOF(
	character: string
): boolean
	return character == LexerImpl.eof
end

function LexerImpl:_isEOL(
	character: string
): boolean
	if self:_isEOF(character) then
		return false
	else
		return not not LexerImpl.eol:find(character, 1, true)
	end
end

function LexerImpl:_isWhitespace(
	character: string
): boolean
	if self:_isEOF(character) then
		return false
	else
		return not not LexerImpl.whitespace:find(character, 1, true)
	end
end

function LexerImpl:_isDigit(
	character: string
): boolean
	if self:_isEOF(character) then
		return false
	else
		return not not LexerImpl.digit:find(character, 1, true)
	end
end

function LexerImpl:_isAlpha(
	character: string
): boolean
	if self:_isEOF(character) then
		return false
	else
		return not not LexerImpl.alphabet:find(character, 1, true)
	end
end

function LexerImpl:_isBinary(
	character: string
): boolean
	return character == "0" or character == "1"
end

function LexerImpl:_isHex(
	character: string
): boolean
	if self:_isEOF(character) then
		return false
	else
		return not not LexerImpl.hexadecimal:find(character, 1, true)
	end
end

function LexerImpl:_isOperator(
	character: string
): boolean
	if LexerImpl.operators[character] then
		return true
	else
		return false
	end
end

function LexerImpl:_readString(): Token.Token
	local startPosition = self:_position()
	
	local quote = (self:_accept("'") or self:_accept('"')) :: string
	
	while not self:_accept(quote) do
		local character = self:_advance()
		
		if character == "\\" then
			local escapeCharacter = self:_advance()
			local escapeCharacterSequence = LexerImpl.escapeSequences[escapeCharacter] or escapeCharacter
			
			character = escapeCharacterSequence
		elseif self:_isEOF(character) or self:_isEOL(character) then
			error("Malformed string; did you forget to finish it?")
		end
		
		self:_consume(character)
	end
	
	return Token.new(
		Token.kind.string,
		Location.new(
			startPosition,
			self:_pervPosition()
		),
		self:_concat(true)
	)
end

function LexerImpl:_readMultilineString(): Token.Token
	local startPosition = self:_position()
	
	local tokenKind = "multilineString"
	
	self:_accept("[")
	
	local level = 0 while self:_accept("=") do
		level += 1
	end
	
	if not self:_accept("[") then
		error("Malformed string; did you forget to finish it?")
	end
	
	local suffix = "]" .. ("="):rep(level) .. "]"
	
	while not self:_accept(suffix) do
		local character = self:_advance()
		
		if character == LexerImpl.eof then
			error("Malformed string; did you forget to finish it?")
		else
			self:_consume(character)
		end
	end
	
	return Token.new(
		Token.kind[tokenKind],
		Location.new(
			startPosition,
			self:_pervPosition()
		),
		self:_concat(true)
	)
end

function LexerImpl:_readComment(): Token.Token
	local startPosition = self:_position()

	self:_accept("--")

	while not(self:_isEOL(self:_peek()) or self:_isEOF(self:_peek())) do
		self:_consume(self:_advance())
	end

	return Token.new(
		Token.kind.comment,
		Location.new(
			startPosition,
			self:_pervPosition()
		),
		self:_concat(true)
	)
end

function LexerImpl:_readMultilineComment(): Token.Token
	local startPosition = self:_position()

	local tokenKind = "multilineComment"

	self:_accept("--")
	self:_accept("[")

	local level = 0 while self:_accept("=") do
		level += 1
	end

	if not self:_accept("[") then
		self:_backBy(-level)
		self:_backBy(-3)
		
		return self:_readComment()
	end
	
	local suffix = "]" .. ("="):rep(level) .. "]"
	
	while not self:_accept(suffix) do
		local character = self:_advance()
		
		if character == LexerImpl.eof then
			error("Expected identifier when parsing expression, got unfinished comment")
		else
			self:_consume(character)
		end
	end
	
	return Token.new(
		Token.kind[tokenKind],
		Location.new(
			startPosition,
			self:_pervPosition()
		),
		self:_concat(true)
	)
end

function LexerImpl:_readIden(): Token.Token
	local startPosition = self:_position()
	
	while self:_isAlpha(self:_peek()) or self:_isDigit(self:_peek()) or self:_match("_") do
		if self:_isEOF(self:_peek()) or self:_isEOL(self:_peek()) then
			break
		end
		
		self:_consume(self:_advance())
	end
	
	local asString = self:_concat(true)
	
	if LexerImpl.builtins[asString] then
		return Token.new(
			Token.kind.builtin,
			Location.new(
				startPosition,
				self:_pervPosition()
			),
			asString
		)
	else
		return Token.new(
			Token.kind.iden,
			Location.new(
				startPosition,
				self:_pervPosition()
			),
			asString
		)
	end
end

function LexerImpl:_readNumber(): Token.Token
	local startPosition = self:_position()

	local afterE = false
	local afterDot = false

	if self:_match("0") then
		print(self:_next())
		if self:_next() == "b" or self:_next() == "B" then
			return self:_readBinaryNumber()
		elseif self:_next() == "x" or self:_next() == "X" then
			return self:_readHexadecimalNumber()
		end
	end

	if self:_match(".") then
		if self:_isDigit(self:_next()) then
			self:_consume(self:_advance())
			afterDot = true
		end
	end

	while self:_isDigit(self:_peek()) or self:_match(".") or self:_match("_") do
		if self:_match(".") then
			if not afterDot then
				afterDot = true
			else
				error("Malformed number")
			end
		end

		self:_consume(self:_advance())
	end

	if self:_match("e") or self:_match("E") then
		self:_consume(self:_advance())

		afterE = true

		if self:_match("+") or self:_match("-") then
			self:_consume(self:_advance())
		end
	elseif self:_isAlpha(self:_peek()) then
		error("Malformed number")
	end

	while self:_isAlpha(self:_peek()) or self:_isDigit(self:_peek()) or self:_match("_") do
		if self:_match("e") or self:_match("E") then
			if not afterE then
				afterE = true
			else
				error("Malformed number")
			end
		end

		if self:_match(".") then
			if not afterDot then
				afterDot = true
			else
				error("Malformed number")
			end
		end

		self:_consume(self:_advance())
	end

	if self:_isAlpha(self:_perv()) then
		error("Malformed number")
	end

	return Token.new(
		Token.kind.number,
		Location.new(
			startPosition,
			self:_pervPosition()
		),
		self:_concat(true)
	)
end

function LexerImpl:_readBinaryNumber(): Token.Token
	local startPosition = self:_position()

	self:_consume(self:_advance())
	self:_consume(self:_advance())

	while self:_isAlpha(self:_peek()) or self:_isDigit(self:_peek()) or self:_match("_") do
		if not self:_isBinary(self:_peek()) then
			error("Malformed number")
		end

		self:_consume(self:_advance())
	end

	return Token.new(
		Token.kind.number,
		Location.new(
			startPosition,
			self:_pervPosition()
		),
		self:_concat(true)
	)
end

function LexerImpl:_readHexadecimalNumber(): Token.Token
	local startPosition = self:_position()

	local tokenKind = "number"

	self:_consume(self:_advance())
	self:_consume(self:_advance())

	while self:_isAlpha(self:_peek()) or self:_isDigit(self:_peek()) or self:_match("_") do
		if not self:_isHex(self:_peek()) then
			error("Malformed number")
		end

		self:_consume(self:_advance())
	end

	return Token.new(
		Token.kind.number,
		Location.new(
			startPosition,
			self:_pervPosition()
		),
		self:_concat(true)
	)
end

function LexerImpl:_readDot(): Token.Token
	local startPosition = self:_position()

	local tokenKind = "dot"

	if self:_isDigit(self:_next()) then
		return self:_readNumber()
	end

	if self:_accept("...") then
		tokenKind = "dot3"
	elseif self:_accept("..") then
		tokenKind = "dot2"
	else
		self:_move()
	end

	return Token.new(
		Token.kind[tokenKind],
		Location.new(
			startPosition,
			self:_pervPosition()
		)
	)
end

function LexerImpl:_readUnknown(): Token.Token
	local startPosition = self:_position()
	
	while true do
		local character = self:_peek()
		
		if self:_isEOF(character)
			or self:_isEOL(character)
			or self:_isWhitespace(character)
			or self:_isDigit(character)
			or self:_isAlpha(character)
			or self:_isHex(character)
			or self:_isOperator(character)
		then
			break
		else
			self:_consume(self:_advance())
		end
	end
	
	return Token.new(
		Token.kind.unknown,
		Location.new(
			startPosition,
			self:_pervPosition()
		),
		self:_concat(true)
	)
end

function LexerImpl:_read(): Token.Token | boolean
	if self:_match("'") or self:_match('"') then
		return self:_readString()
	end
	
	if self:_match("[[") or self:_match("[=") then
		return self:_readMultilineString()
	end
	
	if self:_match("--") then
		if self:_match("--[[") or self:_match("--[=") then
			self:_readMultilineComment()
			
			return true
			--return self:_readMultilineComment()
		else
			self:_readComment()
			
			return true
			--return self:_readComment()
		end
	end
	
	for keyword, token in LexerImpl.keywords do
		local startPosition = self:_position()
		
		if self:_accept(keyword) then
			return Token.new(
				token,
				Location.new(
					startPosition,
					self:_pervPosition()
				)
			)
		end
	end
	
	for operatorLength = #LexerImpl.sortedOperators, 1, -1 do
		local startPosition = self:_position()
		
		local operatorGroup = LexerImpl.sortedOperators[operatorLength]
		
		for operator, token in operatorGroup do
			if self:_match(operator) then
				if operator:find(".", 1, true) then
					return self:_readDot()
				else
					self:_moveBy(#operator)
					
					return Token.new(
						token,
						Location.new(
							startPosition,
							self:_pervPosition()
						)
					)
				end
			end
		end
	end
	
	if self:_isWhitespace(self:_peek()) then
		self:_move()
		
		return true
	end
	
	if self:_isDigit(self:_peek()) then
		return self:_readNumber()
	end
	
	if self:_isAlpha(self:_peek()) or self:_match("_") then
		return self:_readIden()
	end
	
	return self:_readUnknown()
end

function LexerImpl:scan(): { Token.Token }
	while self._offset <= #self.source do
		local token = self:_read()
		
		if not token then
			break
		end
		
		if Token.is(token) then
			table.insert(self.tokens, token :: Token.Token)
		end
	end
	
	table.insert(self.tokens, Token.new(Token.kind.eof))
	return self.tokens
end

LexerImpl.sortedOperators = LexerImpl.sortOperators(LexerImpl.operators)

return LexerImpl