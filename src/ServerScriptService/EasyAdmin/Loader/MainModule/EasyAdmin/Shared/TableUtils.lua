local TableUtils = {}

function TableUtils.shallowCopy(original)
	local copy = {}
	for key, value in pairs(original) do
		copy[key] = value
	end
	return copy
end

function TableUtils.deepCopy(original)
	local function innerDeepCopy(originalTable, copies)
		local copy = {}
		copies = copies or {}

		if copies[originalTable] then
			return copies[originalTable]
		end

		copies[originalTable] = copy

		for key, value in pairs(originalTable) do
			if type(value) == "table" then
				copy[key] = innerDeepCopy(value, copies)
			else
				copy[key] = value
			end
		end

		return setmetatable(copy, getmetatable(originalTable))
	end

	return innerDeepCopy(original)
end

function TableUtils.mergeTables(...)
	local merged = {}
	for _, tbl in ipairs({...}) do
		for key, value in pairs(tbl) do
			merged[key] = value
		end
	end
	return merged
end

function TableUtils.contains(table, value)
	for _, v in pairs(table) do
		if v == value then
			return true
		end
	end
	return false
end

function TableUtils.flatten(nestedTable)
	local flat = {}

	local function innerFlatten(tbl)
		for _, v in pairs(tbl) do
			if type(v) == "table" then
				innerFlatten(v)
			else
				table.insert(flat, v)
			end
		end
	end

	innerFlatten(nestedTable)
	return flat
end

return TableUtils
