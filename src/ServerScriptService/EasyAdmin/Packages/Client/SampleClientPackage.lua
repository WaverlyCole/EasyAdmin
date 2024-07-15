return function(Context)
	local Package = {}

	-- You can put whatever you want here

	Package.Start = function() -- Anything that relies on other packages being initiated first should be put here
		print("Sample Client Package")
	end

	return Package
end