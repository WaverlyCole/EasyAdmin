return function(...)
	local args = {...}
	local messages = {}

	for i, v in ipairs(args) do
		messages[i] = tostring(v)
	end

	local message = table.concat(messages, " ")

	print("[EasyAdmin]:",message)
end