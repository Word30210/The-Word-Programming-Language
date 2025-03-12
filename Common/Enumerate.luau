--!strict
--!optimize 2
--!native

export type kind = { string }
export type strict = typeof(setmetatable({} :: { [string]: kind }, {} :: {
	__index: <S, K>(S, K) -> ();
	__newindex: <S, K>(S, K) -> ();
}))

local function strict(
	name: string,
	table: { [string]: kind }
): strict
	return setmetatable(table, {
		__index = function(_, key)
			error(("%q is not a valid member of %q"):format(tostring(key), name))
		end;

		__newindex = function(_, key)
			error(("%q of %q is not assignable"):format(tostring(key), name))
		end;
	})
end

local function enumerate(enumName: string, enumItems: { string })
	local items = {}

	for _, name in enumItems do
		items[name] = { name }
	end

	return strict(enumName, items)
end

return enumerate