--!strict
--!optimize 2
--!native

local Enumerate = require("../Common/Enumerate.luau")

export type AstNodeImpl = {
	__index: AstNodeImpl;
	
	kind: Enumerate.strict;
	
	fromArray: (
		nodeKind: Enumerate.kind,
		children: { AstNode }?,
		value: any?
	) -> AstNode;
	new: (
		nodeKind: Enumerate.kind,
		...any
	) -> AstNode;
	fromValue: (
		nodeKind: Enumerate.kind,
		value: any,
		...any
	) -> AstNode;
	is: (
		object: any
	) -> boolean;
}

export type AstNode = typeof(setmetatable({} :: {
	kind: Enumerate.kind;
	children: { AstNode }?;
	value: any?;
}, {} :: AstNodeImpl))

export type NodeKind = Enumerate.kind

local AstNodeImpl = {} :: AstNodeImpl
AstNodeImpl.__index = AstNodeImpl

AstNodeImpl.kind = Enumerate("astNode.kind", {
	"true", "false", "none", "dot3", "string", "number", "name", "at", "at2", "dollar",
	
	"length", "negative", "not",
	
	"add", "sub", "mul", "div", "mod", "pow", "concat",
	
	"compareEqual", "compareNotEqual", "compareLessThan", "compareLessEqual", "compareGreaterThan", "compareGreaterEqual", "and", "or",
	
	"continue", "break", "return",
	
	"ifStatement", "switchStatement", "caseStatement", "defaultCaseStatement", "fnStatement", "classStatement", "compoundAssign", "assign", "variable", "parameter", "functionCall",
	
	"arrayConstructor", "dictionaryConstructor", "dictionaryKeyAssign", "keyAssign", "indexName", "indexExpression",
	
	"block", "codeBlock", "forLoop", "whileLoop", "eachLoop"
})

function AstNodeImpl.fromArray(
	nodeKind: Enumerate.kind,
	children: { AstNode }?,
	value: any?
): AstNode
	local self = {}
	
	self.kind = nodeKind
	self.children = children
	self.value = value
	
	return setmetatable(self, AstNodeImpl)
end

function AstNodeImpl.new(
	nodeKind: Enumerate.kind,
	...: any
): AstNode
	return AstNodeImpl.fromArray(nodeKind, nil, select("#", ...) > 0 and { ... } or nil)
end

function AstNodeImpl.fromValue(
	nodeKind: Enumerate.kind,
	value: any,
	...: any
): AstNode
	return AstNodeImpl.fromArray(nodeKind, select("#", ...) > 0 and { ... } or nil, value)
end

function AstNodeImpl.is(
	object: any
): boolean
	return type(object) == "table" and getmetatable(object) == AstNodeImpl
end

return AstNodeImpl