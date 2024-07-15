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

function Util:formatTime(seconds)
	if seconds == nil then
		seconds = 0
	end
	
	local days = math.floor(seconds / 86400)
	seconds = seconds % 86400

	local hours = math.floor(seconds / 3600)
	seconds = seconds % 3600

	local minutes = math.floor(seconds / 60)
	seconds = seconds % 60

	local timeString = ""
	if days > 0 then
		timeString = timeString .. days .. "d"
	end
	if hours > 0 then
		timeString = timeString .. hours .. "h"
	end
	if minutes > 0 then
		timeString = timeString .. minutes .. "m"
	end
	if seconds > 0 then
		timeString = timeString .. seconds .. "s"
	end

	return timeString
end


return Util