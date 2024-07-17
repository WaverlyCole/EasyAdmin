return function(Context)
    local TextFilter = {}

    local TextService = game:GetService("TextService")

    function TextFilter:FilterBroadcast(Text,fromPlayerId)
		fromPlayerId = Context.PlayerUtils:ResolveToUserId(fromPlayerId)

		local success, returned = pcall(function()
			return TextService:FilterStringAsync(Text, fromPlayerId)
		end)

		if not success then
			Context.warn("Error filtering text:", Text, ":", returned)
		else
			return returned:GetNonChatStringForBroadcastAsync()
		end
	end

	function TextFilter:FilterFor(Text,fromPlayerId,toPlayerId)
		fromPlayerId = Context.PlayerUtils:ResolveToUserId(fromPlayerId)
        toPlayerId = Context.PlayerUtils:ResolveToUserId(toPlayerId)

		local success, returned = pcall(function()
			return TextService:FilterStringAsync(Text, fromPlayerId)
		end)

		if not success then
			Context.warn("Error filtering text:", Text, ":", returned)
		else
			return returned:GetNonChatStringForUserAsync(toPlayerId)
		end
	end


    return TextFilter
end