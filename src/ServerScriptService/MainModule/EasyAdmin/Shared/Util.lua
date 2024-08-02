local Util = {}

function Util:interpretTimeString(timeString)
	if timeString == nil then
		timeString = "0s"
	end
	
	local timeUnits = {
		s = 1,
		sec = 1,
		secs = 1,
		seconds = 1,
		m = 60,
		min = 60,
		mins = 60,
		minutes = 60,
		h = 3600,
		hr = 3600,
		hrs = 3600,
		hour = 3600,
		hours = 3600,
		d = 86400,
		day = 86400,
		days = 86400
	}

	local totalSeconds = 0
	for value, unit in timeString:gmatch("(%d+)(%a+)") do
		local unitMultiplier = timeUnits[unit:lower()]
		if unitMultiplier then
			totalSeconds = totalSeconds + tonumber(value) * unitMultiplier
		else
			return nil, "Invalid time unit: " .. unit
		end
	end

	if totalSeconds > 0 then
		return totalSeconds
	else
		return nil, "Invalid time format"
	end
end

function Util:formatTime(seconds, units, expanded)
	if seconds == nil then
		seconds = 0
	end

	local timeUnits = {
		years = math.floor(seconds / 31536000),
		days = math.floor((seconds % 31536000) / 86400),
		hours = math.floor((seconds % 86400) / 3600),
		minutes = math.floor((seconds % 3600) / 60),
		seconds = seconds % 60,
	}

	local timeStrings = {
		years = expanded and "y " or "y",
		days = expanded and "d " or "d",
		hours = expanded and "h " or "h",
		minutes = expanded and "m " or "m",
		seconds = expanded and "s " or "s",
	}

	-- If units is nil, default to all non-zero units
	if units == nil then
		units = {}
		for unit, value in pairs(timeUnits) do
			if value > 0 then
				table.insert(units, unit)
			end
		end
	end

	local timeString = ""

	for _, unit in ipairs(units) do
		if timeUnits[unit] > 0 then
			timeString = timeString .. timeUnits[unit] .. timeStrings[unit]
		end
	end

	-- Trim any trailing space if expanded
	if expanded then
		timeString = timeString:match("^%s*(.-)%s*$")
	end

	return timeString
end





return Util