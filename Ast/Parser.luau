--!strict
--!optimize 2
--!native

--[[

	TODO LIST
	var ... 만들기 (fn, class 전용)
	a, b, c = 1, 2, 3 만들기
	a.a, b, c.c = 1, 2, 3 만들기
	a += 1 만들기

]]

local Token = require("./Token.luau")
local AstNode = require("./AstNode.luau")

export type ParserImpl = {
	__index: ParserImpl;
	
	simpleTokens: {
		[Token.TokenKind]: AstNode.NodeKind;
	};
	compountOperators: {
		[Token.TokenKind]: AstNode.NodeKind;
	};
	unaryOperators: {
		[Token.TokenKind]: AstNode.NodeKind;
	};
	binaryOperators: {
		[Token.TokenKind]: AstNode.NodeKind;
	};
	selfKeywords: {
		[Token.TokenKind]: AstNode.NodeKind;
	};
	
	new: (
		tokens: { Token.Token },
		names: any?
	) -> Parser;
	is: (
		object: any
	) -> boolean;
	isLastStatements: (
		statement: AstNode.AstNode
	) -> boolean;
	isExpressionLValue: (
		expression: AstNode.AstNode
	) -> boolean;
	isFollowingBlock: (
		token: Token.Token
	) -> boolean;
	
	_peek: (
		self: Parser
	) -> Token.Token;
	_next: (
		self: Parser
	) -> Token.Token?;
	_match: (
		self: Parser,
		tokenKind: Token.TokenKind
	) -> boolean;
	_matchNext: (
		self: Parser,
		tokenKind: Token.TokenKind
	) -> boolean;
	_advance: (
		self: Parser
	) -> Token.Token;
	_accept: (
		self: Parser,
		tokenKind: Token.TokenKind
	) -> Token.Token?;
	_expect: (
		self: Parser,
		tokenKind: Token.TokenKind
	) -> Token.Token;
	_peekAndExpect: (
		self: Parser,
		tokenKind: Token.TokenKind
	) -> ();
	_error: (
		self: Parser,
		formatString: string,
		...any
	) -> ();
	
	_parsePow: (
		self: Parser
	) -> AstNode.AstNode;
	_parseUnary: (
		self: Parser
	) -> AstNode.AstNode;
	_parseFactor: (
		self: Parser
	) -> AstNode.AstNode;
	_parseMultiplyExpression: (
		self: Parser
	) -> AstNode.AstNode;
	_parseSummationExpression: (
		self: Parser
	) -> AstNode.AstNode;
	_parseConcatExpression: (
		self: Parser
	) -> AstNode.AstNode;
	_parseCompareExpression: (
		self: Parser
	) -> AstNode.AstNode;
	_parseAndExpression: (
		self: Parser
	) -> AstNode.AstNode;
	_parseOrExpression: (
		self: Parser
	) -> AstNode.AstNode;
	_parseExpression: (
		self: Parser
	) -> AstNode.AstNode;
	_parseIfStatement: (
		self: Parser
	) -> AstNode.AstNode;
	_parseElseIfStatement: (
		self: Parser
	) -> AstNode.AstNode;
	_parseSwitchStatement: (
		self: Parser
	) -> AstNode.AstNode;
	_parseForStatement: (
		self: Parser
	) -> AstNode.AstNode;
	_parseWhileStatement: (
		self: Parser
	) -> AstNode.AstNode;
	_parseEachStatement: (
		self: Parser
	) -> AstNode.AstNode;
	_parseFnStatement: (
		self: Parser
	) -> AstNode.AstNode;
	_parseClassStatement: (
		self: Parser
	) -> AstNode.AstNode;
	_parseClassInnerBlock: (
		self: Parser
	) -> AstNode.AstNode;
	_parseClassInnerStatement: (
		self: Parser
	) -> AstNode.AstNode;
	_parseArrayConstructor: (
		self: Parser
	) -> AstNode.AstNode;
	_parseDictionaryConstructor: (
		self: Parser
	) -> AstNode.AstNode;
	_parseSimpleExpression: (
		self: Parser
	) -> AstNode.AstNode;
	_parsePrefixExpression: (
		self: Parser
	) -> AstNode.AstNode;
	_parseName: (
		self: Parser
	) -> AstNode.AstNode;
	_parseNameWithKeyword: (
		self: Parser
	) -> AstNode.AstNode;
	_parsePrimaryExpression: (
		self: Parser
	) -> AstNode.AstNode;
	_parseVar: (
		self: Parser
	) -> AstNode.AstNode;
	_parseVarWithoutValues: (
		self: Parser
	) -> AstNode.AstNode;
	_parseParameter: (
		self: Parser
	) -> AstNode.AstNode;
	_parseStatement: (
		self: Parser
	) -> AstNode.AstNode;
	_parseCodeBlock: (
		self: Parser
	) -> AstNode.AstNode;
	_parseBlock: (
		self: Parser
	) -> AstNode.AstNode;
	
	parse: (
		self: Parser
	) -> AstNode.AstNode;
}

export type Parser = typeof(setmetatable({} :: {
	_tokens: { Token.Token };
	_names: any;
	_index: number;
}, {} :: ParserImpl))

local ParserImpl = {} :: ParserImpl
ParserImpl.__index = ParserImpl

ParserImpl.simpleTokens = {
	[Token.kind["true"]] = AstNode.kind["true"];
	[Token.kind["false"]] = AstNode.kind["false"];
	[Token.kind.none] = AstNode.kind.none;
	[Token.kind.dot3] = AstNode.kind.dot3;
	[Token.kind.dollar] = AstNode.kind.dollar;
	[Token.kind.at] = AstNode.kind.at;
	[Token.kind.at2] = AstNode.kind.at2;
	[Token.kind.string] = AstNode.kind.string;
	[Token.kind.number] = AstNode.kind.number;
}

ParserImpl.compountOperators = {
	[Token.kind.plusEqual] = AstNode.kind.add;
	[Token.kind.minusEqual] = AstNode.kind.sub;
	[Token.kind.starEqual] = AstNode.kind.mul;
	[Token.kind.slashEqual] = AstNode.kind.div;
	[Token.kind.moduloEqual] = AstNode.kind.mod;
	[Token.kind.caretEqual] = AstNode.kind.pow;
	[Token.kind.dot2Equal] = AstNode.kind.concat;
}

ParserImpl.unaryOperators = {
	[Token.kind.exclamationMark] = AstNode.kind["not"];
	[Token.kind.hashtag] = AstNode.kind.length;
	[Token.kind.minus] = AstNode.kind.negative;
}

ParserImpl.binaryOperators = {
	[Token.kind.plus] = AstNode.kind.add;
	[Token.kind.minus] = AstNode.kind.sub;
	[Token.kind.star] = AstNode.kind.mul;
	[Token.kind.slash] = AstNode.kind.div;
	[Token.kind.modulo] = AstNode.kind.mod;
	[Token.kind.caret] = AstNode.kind.pow;
	[Token.kind.dot2] = AstNode.kind.concat;
	[Token.kind.equalTo] = AstNode.kind.compareEqual;
	[Token.kind.notEqual] = AstNode.kind.compareNotEqual;
	[Token.kind.lessThan] = AstNode.kind.compareLessThan;
	[Token.kind.lessEqual] = AstNode.kind.compareLessEqual;
	[Token.kind.greaterThan] = AstNode.kind.compareGreaterThan;
	[Token.kind.greaterEqual] = AstNode.kind.compareGreaterEqual;
	[Token.kind.ampersand] = AstNode.kind["and"];
	[Token.kind.pipe] = AstNode.kind["or"];
}

ParserImpl.selfKeywords = {
	[Token.kind.at] = AstNode.kind.at;
	[Token.kind.at2] = AstNode.kind.at2;
	[Token.kind.dollar] = AstNode.kind.dollar;
}

function ParserImpl.new(
	tokens: { Token.Token },
	names: any?
): Parser
	local self = {}
	
	self._tokens = tokens
	self._names = names or {}
	self._index = 1
	
	return setmetatable(self, ParserImpl)
end

function ParserImpl.is(
	object: any
): boolean
	return type(object) == "table" and getmetatable(object) == ParserImpl
end

function ParserImpl.isLastStatements(
	statement: AstNode.AstNode
): boolean
	return statement.kind == AstNode.kind["continue"]
		or statement.kind == AstNode.kind["break"]
		or statement.kind == AstNode.kind["return"]
end

function ParserImpl.isExpressionLValue(
	expression: AstNode.AstNode
): boolean
	return expression.kind == AstNode.kind.variable
end

function ParserImpl.isFollowingBlock(
	token: Token.Token
): boolean
	return token.kind == Token.kind.rightBrace
		or token.kind == Token.kind.eof
end

function ParserImpl:_peek(): Token.Token
	return self._tokens[self._index]
end

function ParserImpl:_next(): Token.Token?
	return self._tokens[self._index + 1]
end

function ParserImpl:_match(
	tokenKind: Token.TokenKind
): boolean
	return self:_peek().kind == tokenKind
end

function ParserImpl:_matchNext(
	tokenKind: Token.TokenKind
): boolean
	local nextToken = self:_next()
	
	if nextToken then
		return nextToken.kind == tokenKind
	else
		return false
	end
end

function ParserImpl:_advance(): Token.Token
	local token = self:_peek()
	
	self._index += 1
	
	return token
end

function ParserImpl:_accept(
	tokenKind: Token.TokenKind
): Token.Token?
	local token = self:_peek()
	
	if token.kind == tokenKind then
		self:_advance()
		
		return token
	end
	
	return nil
end

function ParserImpl:_expect(
	tokenKind: Token.TokenKind
): Token.Token
	local token = self:_peek()
	
	if not token or token.kind ~= tokenKind then
		if token then
			if token.location then
				error(("[WZ_PARSER] :%d:%d: Expected %s, got %s; %d"):format(token.location.begin.line, token.location.begin.column, tokenKind[1], token.kind[1], self._index))
			else
				error(("[WZ_PARSER] Expected %s, got %s; %d"):format(tokenKind[1], token.kind[1], self._index))
			end
		else
			error(("[WZ_PARSER] Expected %s, got <unknown>"):format(tokenKind[1]))
		end
	else
		self:_advance()

		return token
	end
end

function ParserImpl:_peekAndExpect(
	tokenKind: Token.TokenKind
)
	local token = self:_peek()

	if not token or token.kind ~= tokenKind then
		if token then
			if token.location then
				error(("[WZ_PARSER] :%d:%d: Expected %s, got %s"):format(token.location.begin.line, token.location.begin.column, tokenKind[1], token.kind[1]))
			else
				error(("[WZ_PARSER] Expected %s, got %s"):format(tokenKind[1], token.kind[1]))
			end
		else
			error(("[WZ_PARSER] Expected %s, got <unknown>"):format(tokenKind[1]))
		end
	end
end

function ParserImpl:_error(
	formatString: string,
	...: any
)
	local token = self:_peek()
	
	if token then
		if token.location then
			error(("[WZ_PARSER] :%d:%d: %s"):format(token.location.begin.line, token.location.begin.column, formatString:format(...)))
		else
			error("[WZ_PARSER]" .. formatString:format(...))
		end
	end
end

function ParserImpl:_parsePow(): AstNode.AstNode
	local left = self:_parseSimpleExpression()
	
	if not self:_peek() then
		return left
	end
	
	while true do
		local token = self:_accept(Token.kind.caret)
		
		if not token then
			break
		end
		
		local right = self:_parseSimpleExpression()
		local nodeKind = ParserImpl.binaryOperators[token.kind]
		
		left = AstNode.new(nodeKind, left, right)
	end
	
	return left
end

function ParserImpl:_parseUnary(): AstNode.AstNode
	local stack = {}
	
	while true do
		local token = self:_accept(Token.kind.exclamationMark)
			or self:_accept(Token.kind.hashtag)
			or self:_accept(Token.kind.minus)
		
		if not token then
			break
		end
		
		table.insert(stack, token)
	end
	
	local expression = self:_parsePow()
	
	for i = #stack, 1, -1 do
		local nodeKind = ParserImpl.unaryOperators[stack[i].kind]
		
		expression = AstNode.new(nodeKind, expression)
	end
	
	return expression
end

function ParserImpl:_parseFactor(): AstNode.AstNode
	local left = self:_parseUnary()
	
	if not self:_peek() then
		return left
	end
	
	while true do
		local token = self:_accept(Token.kind.modulo)
		
		if not token then
			break
		end
		
		local right = self:_parseUnary()
		local nodeKind = ParserImpl.binaryOperators[token.kind]
		
		left = AstNode.new(nodeKind, left, right)
	end
	
	return left
end

function ParserImpl:_parseMultiplyExpression(): AstNode.AstNode
	local left = self:_parseFactor()
	
	if not self:_peek() then
		return left
	end
	
	while true do
		local token = self:_accept(Token.kind.star)
			or self:_accept(Token.kind.slash)
			or self:_accept(Token.kind.modulo)
		
		if not token then
			break
		end
		
		local right = self:_parseFactor()
		local nodeKind = ParserImpl.binaryOperators[token.kind]
		
		left = AstNode.new(nodeKind, left, right)
	end
	
	return left
end

function ParserImpl:_parseSummationExpression(): AstNode.AstNode
	local left = self:_parseMultiplyExpression()

	if not self:_peek() then
		return left
	end

	while true do
		local token = self:_accept(Token.kind.plus)
			or self:_accept(Token.kind.minus)

		if not token then
			break
		end

		local right = self:_parseMultiplyExpression()
		local nodeKind = ParserImpl.binaryOperators[token.kind]

		left = AstNode.new(nodeKind, left, right)
	end

	return left
end

function ParserImpl:_parseConcatExpression(): AstNode.AstNode
	local left = self:_parseSummationExpression()
	
	if not self:_peek() then
		return left
	end
	
	while true do
		local token = self:_accept(Token.kind.dot2)
		
		if not token then
			break
		end
		
		local right = self:_parseSummationExpression()
		local nodeKind = ParserImpl.binaryOperators[token.kind]
		
		left = AstNode.new(nodeKind, left, right)
	end
	
	return left
end

function ParserImpl:_parseCompareExpression(): AstNode.AstNode
	local left = self:_parseConcatExpression()
	
	if not self:_peek() then
		return left
	end
	
	while true do
		local token = self:_accept(Token.kind.equalTo)
			or self:_accept(Token.kind.notEqual)
			or self:_accept(Token.kind.lessThan)
			or self:_accept(Token.kind.lessEqual)
			or self:_accept(Token.kind.greaterThan)
			or self:_accept(Token.kind.greaterEqual)
		
		if not token then
			break
		end
		
		local right = self:_parseConcatExpression()
		local nodeKind = ParserImpl.binaryOperators[token.kind]
		
		left = AstNode.new(nodeKind, left, right)
	end
	
	return left
end

function ParserImpl:_parseAndExpression(): AstNode.AstNode
	local left = self:_parseCompareExpression()

	if not self:_peek() then
		return left
	end

	while true do
		local token = self:_accept(Token.kind["ampersand"])

		if not token then
			break
		end

		local right = self:_parseCompareExpression()
		local nodeKind = ParserImpl.binaryOperators[token.kind]

		left = AstNode.new(nodeKind, left, right)
	end

	return left
end

function ParserImpl:_parseOrExpression(): AstNode.AstNode
	local left = self:_parseAndExpression()

	if not self:_peek() then
		return left
	end

	while true do
		local token = self:_accept(Token.kind["pipe"])

		if not token then
			break
		end

		local right = self:_parseAndExpression()
		local nodeKind = ParserImpl.binaryOperators[token.kind]

		left = AstNode.new(nodeKind, left, right)
	end

	return left
end

function ParserImpl:_parseExpression(): AstNode.AstNode
	return self:_parseOrExpression()
end

function ParserImpl:_parseIfStatement(): AstNode.AstNode
	self:_expect(Token.kind["if"])
	self:_expect(Token.kind.leftParen)
	
	local condition = self:_parseExpression()
	
	self:_expect(Token.kind.rightParen)
	
	local ifBlock = self:_parseCodeBlock()
	local elseBlock = nil
	
	if self:_match(Token.kind["elif"]) then
		elseBlock = self:_parseElseIfStatement()
	elseif self:_accept(Token.kind["else"]) then
		elseBlock = self:_parseCodeBlock()
	end
	
	return AstNode.fromValue(AstNode.kind.ifStatement, condition, ifBlock, elseBlock)
end

function ParserImpl:_parseElseIfStatement(): AstNode.AstNode
	self:_expect(Token.kind["elif"])
	self:_expect(Token.kind.leftParen)
	
	local condition = self:_parseExpression()
	
	self:_expect(Token.kind.rightParen)
	
	
	local ifBlock = self:_parseCodeBlock()
	local elseBlock = nil
	
	if self:_match(Token.kind["elif"]) then
		elseBlock = self:_parseElseIfStatement()
	elseif self:_accept(Token.kind["else"]) then
		elseBlock = self:_parseCodeBlock()
	end
	
	return AstNode.fromValue(AstNode.kind.ifStatement, condition, ifBlock, elseBlock)
end

function ParserImpl:_parseSwitchStatement(): AstNode.AstNode
	self:_expect(Token.kind.switch)
	self:_expect(Token.kind.leftParen)
	
	local expression = self:_parseExpression()
	
	self:_expect(Token.kind.rightParen)
	self:_expect(Token.kind.leftBrace)
	
	local cases = {}
	
	repeat
		if self:_accept(Token.kind.case) then
			self:_expect(Token.kind.leftParen)
			
			local caseLabel = self:_parseExpression()
			
			self:_expect(Token.kind.rightParen)
			
			local caseBlock = self:_parseCodeBlock()
			
			table.insert(cases, AstNode.fromValue(AstNode.kind.caseStatement, caseLabel, caseBlock))
		elseif self:_accept(Token.kind.default) then
			local caseBlock = self:_parseCodeBlock()
			
			table.insert(cases, AstNode.fromArray(AstNode.kind.defaultCaseStatement, { caseBlock }))
		end
	until
	
	self:_expect(Token.kind.rightBrace)
	
	return AstNode.fromValue(AstNode.kind.switchStatement, expression, table.unpack(cases))
end

function ParserImpl:_parseForStatement(): AstNode.AstNode
	self:_expect(Token.kind["for"])
	self:_expect(Token.kind.leftParen)
	
	local loopBegin = self:_parseExpression()
	
	self:_expect(Token.kind.semiColon)
	
	local loopFinish = self:_parseExpression()
	
	self:_expect(Token.kind.rightParen)
	
	local loopBlock = self:_parseCodeBlock()
	
	return AstNode.fromValue(AstNode.kind.forLoop, { loopBegin, loopFinish }, loopBlock)
end

function ParserImpl:_parseWhileStatement(): AstNode.AstNode
	self:_expect(Token.kind["while"])
	self:_expect(Token.kind.leftParen)
	
	local condition = self:_parseExpression()
	
	self:_expect(Token.kind.rightParen)
	
	local loopBlock = self:_parseCodeBlock()
	
	return AstNode.fromValue(AstNode.kind.whileLoop, condition, loopBlock)
end

function ParserImpl:_parseEachStatement(): AstNode.AstNode
	self:_expect(Token.kind.each)
	self:_expect(Token.kind.leftParen)
	
	local loopVariableList = self:_parseVarWithoutValues()
	
	self:_expect(Token.kind.semiColon)
	
	local expression = self:_parseExpression()
	
	self:_expect(Token.kind.rightParen)
	
	local loopBlock = self:_parseCodeBlock()
	
	return AstNode.fromValue(AstNode.kind.eachLoop, { loopVariableList, expression }, loopBlock)
end

function ParserImpl:_parseFnStatement(): AstNode.AstNode
	self:_expect(Token.kind.fn)
	self:_expect(Token.kind.leftParen)
	
	local fnArguments = self:_parseParameter()
	
	self:_expect(Token.kind.rightParen)
	
	local fnBlock = self:_parseCodeBlock()
	
	return AstNode.fromArray(
		AstNode.kind.fnStatement,
		{ fnBlock },
		fnArguments
	)
end

function ParserImpl:_parseClassStatement(): AstNode.AstNode
	self:_expect(Token.kind.class)
	self:_expect(Token.kind.leftParen)
	
	local classArguments = self:_parseParameter()
	
	self:_expect(Token.kind.rightParen)
	
	local classBlock = self:_parseClassInnerBlock()
	
	return AstNode.fromArray(
		AstNode.kind.classStatement,
		{ classBlock },
		classArguments
	)
end

function ParserImpl:_parseClassInnerBlock(): AstNode.AstNode
	self:_expect(Token.kind.leftBrace)

	local statements = {}
	local statement

	while not ParserImpl.isFollowingBlock(self:_peek()) do
		statement = self:_parseClassInnerStatement()

		if not statement then
			break
		end

		table.insert(statements, statement)

		warn(statement)

		if ParserImpl.isLastStatements(statement) then
			break
		end
	end

	self:_expect(Token.kind.rightBrace)

	return AstNode.fromArray(AstNode.kind.codeBlock, statements)
end

function ParserImpl:_parseClassInnerStatement(): AstNode.AstNode
	if not self:_match(Token.kind.var) then
		self:_error("Expected var, got %s", self:_peek().kind[1])
	end
	
	return self:_parseVar()
end

function ParserImpl:_parseArrayConstructor(): AstNode.AstNode
	self:_expect(Token.kind.leftBracket)
	
	if not self:_accept(Token.kind.rightBracket) then
		local fields = {}

		repeat
			table.insert(fields, self:_parseExpression())
		until not self:_accept(Token.kind.comma)

		self:_expect(Token.kind.rightBracket)
		
		return AstNode.fromArray(AstNode.kind.arrayConstructor, fields)
	else
		return AstNode.fromArray(AstNode.kind.arrayConstructor)
	end
end

function ParserImpl:_parseDictionaryConstructor(): AstNode.AstNode
	self:_expect(Token.kind.leftBrace)
	
	local fields = {}
	
	repeat
		self:_expect(Token.kind.leftBracket)
		
		local key = self:_parseExpression()
		
		self:_expect(Token.kind.rightBracket)
		self:_expect(Token.kind.equal)
		
		local value = self:_parseExpression()
		
		table.insert(fields, AstNode.fromArray(AstNode.kind.dictionaryKeyAssign, { key, value }))
	until not self:_accept(Token.kind.comma)
	
	self:_expect(Token.kind.rightBrace)
	
	return AstNode.fromArray(AstNode.kind.dictionaryConstructor, fields)
end

function ParserImpl:_parseSimpleExpression(): AstNode.AstNode
	if self:_match(Token.kind["if"]) then
		return self:_parseIfStatement()
	end

	if self:_match(Token.kind.switch) then
		return self:_parseSwitchStatement()
	end
	
	if self:_match(Token.kind["for"]) then
		return self:_parseForStatement()
	end
	
	if self:_match(Token.kind["while"]) then
		return self:_parseWhileStatement()
	end
	
	if self:_match(Token.kind.each) then
		return self:_parseEachStatement()
	end
	
	if self:_match(Token.kind.fn) then
		return self:_parseFnStatement()
	end
	
	if self:_match(Token.kind.class) then
		return self:_parseClassStatement()
	end
	
	if self:_match(Token.kind.leftBracket) then
		return self:_parseArrayConstructor()
	end
	
	if self:_match(Token.kind.leftBrace) then
		return self:_parseDictionaryConstructor()
	end
	
	local stringToken = self:_accept(Token.kind.string) or self:_accept(Token.kind.multilineString)
	
	if stringToken then
		return AstNode.fromValue(AstNode.kind.string, stringToken.value)
	end
	
	local numberToken = self:_accept(Token.kind.number)
	
	if numberToken then
		return AstNode.fromValue(AstNode.kind.number, numberToken.value)
	end
	
	local dot3Token = self:_accept(Token.kind.dot3)

	if dot3Token then
		return AstNode.new(AstNode.kind.dot3)
	end
	
	local trueToken = self:_accept(Token.kind["true"])

	if trueToken then
		return AstNode.new(AstNode.kind["true"])
	end
	
	local falseToken = self:_accept(Token.kind["false"])

	if falseToken then
		return AstNode.new(AstNode.kind["false"])
	end
	
	local noneToken = self:_accept(Token.kind.none)
	
	if noneToken then
		return AstNode.new(AstNode.kind.none)
	end
	
	return self:_parsePrimaryExpression()
end

function ParserImpl:_parsePrefixExpression(): AstNode.AstNode
	if self:_accept(Token.kind.leftParen) then
		local expression = self:_parseExpression()
		
		self:_expect(Token.kind.rightParen)
		
		return expression
	else
		return self:_parseNameWithKeyword()
	end
end

function ParserImpl:_parseName(): AstNode.AstNode
	local name = self:_expect(Token.kind.iden)
	
	return AstNode.fromValue(AstNode.kind.name, name.value)
end

function ParserImpl:_parseNameWithKeyword(): AstNode.AstNode
	local keyword = self:_accept(Token.kind.at)
		or self:_accept(Token.kind.at2)
		or self:_accept(Token.kind.dollar)

	if keyword then
		local nodeKind = ParserImpl.selfKeywords[keyword.kind]

		return AstNode.new(nodeKind)
	end

	local name = self:_expect(Token.kind.iden)

	return AstNode.fromValue(AstNode.kind.name, name.value)
end

function ParserImpl:_parsePrimaryExpression(): AstNode.AstNode
	local expression = self:_parsePrefixExpression()
	
	while true do
		if self:_accept(Token.kind.dot) then
			expression = AstNode.new(AstNode.kind.indexName, expression, self:_parseName())
		elseif self:_accept(Token.kind.leftBracket) then
			expression = AstNode.new(AstNode.kind.indexExpression, expression, self:_parseExpression())
			
			self:_expect(Token.kind.rightBracket)
		elseif self:_match(Token.kind.leftParen) then
			local arguments = {}

			self:_expect(Token.kind.leftParen)

			if not self:_accept(Token.kind.rightParen) then
				repeat
					table.insert(arguments, self:_parseExpression())
				until not self:_accept(Token.kind.comma)

				self:_expect(Token.kind.rightParen)
			end
			
			expression = AstNode.new(AstNode.kind.functionCall, expression, arguments)
		else
			break
		end
	end
	
	return expression
end

function ParserImpl:_parseVar(): AstNode.AstNode
	self:_expect(Token.kind.var)
	
	local names = {}

	repeat
		table.insert(names, self:_parseName())
	until not self:_accept(Token.kind.comma)
	
	if self:_accept(Token.kind.equal) then
		local expressions = {}

		repeat
			table.insert(expressions, self:_parseExpression())
		until not self:_accept(Token.kind.comma)

		return AstNode.new(AstNode.kind.variable, names, expressions)
	else
		return AstNode.new(AstNode.kind.variable, names)
	end
end

function ParserImpl:_parseVarWithoutValues(): AstNode.AstNode
	self:_expect(Token.kind.var)
	
	local names = {}
	
	repeat
		table.insert(names, self:_parseName())
	until not self:_accept(Token.kind.comma)
	
	return AstNode.new(AstNode.kind.variable, names)
end

function ParserImpl:_parseParameter(): AstNode.AstNode
	local parameters = {}

	while not self:_match(Token.kind.rightParen) do
		if self:_accept(Token.kind.var) then
			while true do
				local dot3 = self:_accept(Token.kind.dot3)

				if dot3 then
					table.insert(parameters, AstNode.new(Token.kind.dot3))

					self:_peekAndExpect(Token.kind.rightParen)
				else
					table.insert(parameters, self:_parseName())
				end

				if not self:_accept(Token.kind.comma) or dot3 then
					break
				end
			end
		end
	end
	
	return AstNode.new(AstNode.kind.parameter, parameters)
end

function ParserImpl:_parseStatement(): AstNode.AstNode
	if self:_match(Token.kind["if"]) then
		return self:_parseIfStatement()
	end
	
	if self:_match(Token.kind.switch) then
		return self:_parseSwitchStatement()
	end
	
	if self:_match(Token.kind["for"]) then
		return self:_parseForStatement()
	end

	if self:_match(Token.kind["while"]) then
		return self:_parseWhileStatement()
	end

	if self:_match(Token.kind.each) then
		return self:_parseEachStatement()
	end

	if self:_match(Token.kind.fn) then
		return self:_parseFnStatement()
	end
	
	if self:_match(Token.kind.class) then
		return self:_parseClassStatement()
	end
	
	if self:_match(Token.kind.var) then
		return self:_parseVar()
	end
	
	if self:_match(Token.kind.leftBrace) then
		return self:_parseCodeBlock()
	end
	
	if self:_accept(Token.kind["return"]) then
		local expressionList = {}
		
		if not ParserImpl.isFollowingBlock(self:_peek()) then
			repeat
				table.insert(expressionList, self:_parseExpression())
			until not self:_accept(Token.kind.comma)
		end
		
		return AstNode.new(AstNode.kind["return"], expressionList)
	end
	
	if self:_accept(Token.kind["break"]) then
		return AstNode.new(AstNode.kind["break"])
	end
	
	if self:_accept(Token.kind["continue"]) then
		return AstNode.new(AstNode.kind["continue"])
	end
	
	local expression = self:_parsePrefixExpression()
	local isIncompleteStatement = true

	while true do
		if self:_accept(Token.kind.dot) then
			isIncompleteStatement = true
			expression = AstNode.new(AstNode.kind.indexName, expression, self:_parseName())
		elseif self:_accept(Token.kind.leftBracket) then
			isIncompleteStatement = true
			expression = AstNode.new(AstNode.kind.indexExpression, expression, self:_parseExpression())

			self:_expect(Token.kind.rightBracket)
		elseif self:_match(Token.kind.leftParen) then
			local arguments = {}

			self:_expect(Token.kind.leftParen)

			if not self:_accept(Token.kind.rightParen) then
				repeat
					table.insert(arguments, self:_parseExpression())
				until not self:_accept(Token.kind.comma)

				self:_expect(Token.kind.rightParen)
			end
			
			isIncompleteStatement = false
			expression = AstNode.new(AstNode.kind.functionCall, expression, arguments)
		elseif self:_accept(Token.kind.equal) then
			local expressions = {}
			
			repeat
				table.insert(expressions, self:_parseExpression())
			until not self:_accept(Token.kind.comma)
			
			isIncompleteStatement = false
			expression = AstNode.new(AstNode.kind.assign, expression, expressions)
		else
			break
		end
	end
	
	if not isIncompleteStatement then
		return expression
	end
	
	self:_error("Incomplete statement: expected assignment or a function call; " .. self._index)
	
	return ({} :: any) :: AstNode.AstNode
end

function ParserImpl:_parseCodeBlock(): AstNode.AstNode
	self:_expect(Token.kind.leftBrace)
	
	local statements = {}
	local statement
	
	while not ParserImpl.isFollowingBlock(self:_peek()) do
		statement = self:_parseStatement()

		if not statement then
			break
		end

		table.insert(statements, statement)

		if ParserImpl.isLastStatements(statement) then
			break
		end
	end
	
	self:_expect(Token.kind.rightBrace)

	return AstNode.fromArray(AstNode.kind.codeBlock, statements)
end

function ParserImpl:_parseBlock(): AstNode.AstNode
	local statements = {}
	local statement
	
	while not ParserImpl.isFollowingBlock(self:_peek()) do
		statement = self:_parseStatement()
		
		if not statement then
			break
		end
		
		table.insert(statements, statement)
		
		if ParserImpl.isLastStatements(statement) then
			break
		end
	end
	
	return AstNode.fromArray(AstNode.kind.block, statements)
end

function ParserImpl:parse(): AstNode.AstNode
	local root = self:_parseBlock()
	
	self:_accept(Token.kind.eof)
	
	return root
end

return ParserImpl