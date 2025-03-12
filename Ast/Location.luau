--!strict
--!optimize 2
--!native

local Position = require("./Position.luau")

export type LocationImpl = {
	__index: LocationImpl;
	__eq: (
		self: Location,
		rhs: Location
	) -> boolean;
	
	new: (
		begin: Position.Position?,
		finish: Position.Position?
	) -> Location;
	newWithLength: (
		begin: Position.Position,
		length: number
	) -> Location;
	newFromLocations: (
		begin: Location,
		finish: Location
	) -> Location;
	
	encloses: (
		self: Location,
		l: Location
	) -> boolean;
	overlaps: (
		self: Location,
		l: Location
	) -> boolean;
	contains: (
		self: Location,
		p: Position.Position
	) -> boolean;
	containsClosed: (
		self: Location,
		p: Position.Position
	) -> boolean;
	extend: (
		self: Location,
		other: Location
	) -> ();
	shift: (
		self: Location,
		start: Position.Position,
		oldFinish: Position.Position,
		newFinish: Position.Position
	) -> ();
}

export type Location = typeof(setmetatable({} :: {
	begin: Position.Position;
	finish: Position.Position
}, {} :: LocationImpl))

local LocationImpl = {} :: LocationImpl
LocationImpl.__index = LocationImpl

function LocationImpl.new(
	begin: Position.Position?,
	finish: Position.Position?
): Location
	local self = {}
	
	self.begin = begin or Position.new()
	self.finish = finish or Position.new()
	
	return setmetatable(self, LocationImpl)
end

function LocationImpl.newWithLength(
	begin: Position.Position,
	length: number
): Location
	local self = {}
	
	self.begin = begin
	self.finish = Position.new(begin.line, begin.column + length)
	
	return setmetatable(self, LocationImpl)
end

function LocationImpl.newFromLocations(
	begin: Location,
	finish: Location
): Location
	local self = {}
	
	self.begin = begin.begin
	self.finish = finish.finish
	
	return setmetatable(self, LocationImpl)
end

function LocationImpl.__eq(
	self: Location,
	rhs: Location
): boolean
	return self.begin == rhs.begin and self.finish == rhs.finish
end

function LocationImpl:encloses(
	l: Location
): boolean
	return self.begin <= l.begin and self.finish >= l.finish
end

function LocationImpl:overlaps(
	l: Location
): boolean
	return (self.begin <= l.begin and self.finish >= l.begin) or (self.begin <= l.finish and self.finish >= l.finish) or (self.begin >= l.begin and self.finish <= l.finish)
end

function LocationImpl:contains(
	p: Position.Position
): boolean
	return self.begin <= p and p < self.finish
end

function LocationImpl:containsClosed(
	p: Position.Position
): boolean
	return self.begin <= p and p <= self.finish
end

function LocationImpl:extend(
	other: Location
)
	if other.begin < self.begin then
		self.begin = other.begin
	end
	
	if other.finish > self.finish then
		self.finish = other.finish
	end
end

function LocationImpl:shift(
	start: Position.Position,
	oldFinish: Position.Position,
	newFinish: Position.Position
)
	self.begin:shift(start, oldFinish, newFinish)
	self.finish:shift(start, oldFinish, newFinish)
end

return LocationImpl