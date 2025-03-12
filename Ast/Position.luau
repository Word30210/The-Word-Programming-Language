--!strict
--!optimize 2
--!native

export type PositionImpl = {
	__index: PositionImpl;
	__add: (
		self: Position,
		rhs: Position
	) -> Position;
	__sub: (
		self: Position,
		rhs: Position
	) -> Position;
	__eq: (
		self: Position,
		rhs: Position
	) -> boolean;
	__lt: (
		self: Position,
		rhs: Position
	) -> boolean;
	__le: (
		self: Position,
		rhs: Position
	) -> boolean;

	new: (
		line: number?,
		column: number?
	) -> Position;

	shift: (
		self: Position,
		start: Position,
		oldFinish: Position,
		newFinish: Position
	) -> ();
	clone: (
		self: Position
	) -> Position;
}

export type Position = typeof(setmetatable({} :: {
	line: number;
	column: number;
}, {} :: PositionImpl))

local PositionImpl = {} :: PositionImpl
PositionImpl.__index = PositionImpl

function PositionImpl.new(
	line: number?,
	column: number?
): Position
	local self = {}

	self.line = line or 1
	self.column = column or 1

	return setmetatable(self, PositionImpl)
end

function PositionImpl.__add(
	self: Position,
	rhs: Position
): Position
	return PositionImpl.new(self.line + rhs.line, self.column + rhs.column)
end

function PositionImpl.__sub(
	self: Position,
	rhs: Position
): Position
	return PositionImpl.new(self.line - rhs.line, self.column - rhs.column)
end

function PositionImpl.__eq(
	self: Position,
	rhs: Position
):  boolean
	return self.column == rhs.column and self.line == rhs.line
end

function PositionImpl.__lt(
	self: Position,
	rhs: Position
): boolean
	if self.line == rhs.line then
		return self.column < rhs.column
	else
		return self.line < rhs.line
	end
end

function PositionImpl.__le(
	self: Position,
	rhs: Position
): boolean
	return self == rhs or self < rhs
end

function PositionImpl:shift(
	start: Position,
	oldFinish: Position,
	newFinish: Position
)
	if self >= start then
		if self.line > oldFinish.line then
			self.line += (newFinish.line - oldFinish.line)
		else
			self.line = newFinish.line
			self.column += (newFinish.column - oldFinish.column)
		end
	end
end

function PositionImpl:clone(): Position
	return PositionImpl.new(self.line, self.column)
end

return PositionImpl