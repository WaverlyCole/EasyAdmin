return function(Context)
	local Ranks = {__rankCache = {}}
	
	function Ranks:Set(Player,Rank,Permanent)
		local UserId = Context.PlayerUtils:ResolveToUserId(Player)
		
		if Permanent ~= true then
			self.__rankCache[UserId] = Rank
		end
	end
	
	function Ranks:Get(Player)
		local UserId = Context.PlayerUtils:ResolveToUserId(Player)
		
		if not self.__rankCache[UserId] then
			self:calculateRank(UserId)
		end

		return self.__rankCache[UserId]
	end
	
	function Ranks:GetPlayersByRank(minRank,exact)
		local returnPlrs = {}
		
		for _,Player in game:GetService("Players"):GetPlayers() do
			local pRank = self:Get(Player)
			
			if exact then
				if pRank == minRank then
					table.insert(returnPlrs,Player)
				end
			else
				if pRank >= minRank then
					table.insert(returnPlrs,Player)
				end
			end
		end
		
		return returnPlrs
	end
	
	function Ranks:calculateRank(Player)
		local UserId = Context.PlayerUtils:ResolveToUserId(Player)
		
		local foundRanks = {0}

		if Context.Options.Ranks[tostring(UserId)] then -- UserId as string
			table.insert(foundRanks,Context.Options.Ranks[tostring(UserId)])
		end

		if Context.Options.Ranks[UserId] then -- UserId as number
			table.insert(foundRanks,Context.Options.Ranks[UserId])
		end

		local usernameSucc, usernameErr = pcall(function() -- Username as string
			local Username = game.Players:GetNameFromUserIdAsync(UserId)
			if Username then
				if Context.Options.Ranks[Username] then
					table.insert(foundRanks,Context.Options.Ranks[Username])
				end
			end
		end)
		
		if not usernameSucc then
			Context.warn("Problem loading username for UserId:",UserId)
			Context.warn(usernameErr)
		end
		
		local groupChecksucc, groupcheckErr = pcall(function() -- GroupId:GroupRank
			local playerGroups = game:GetService("GroupService"):GetGroupsAsync(UserId)
			local groupRanks = {}
			
			for Data,Rank in Context.Options.Ranks do
				if string.find(Data,":") then
					local args = string.split(Data,":")
					local groupID = tonumber(args[1])
					local groupRank = tonumber(args[2])
					
					if groupID == nil or groupRank == nil then
						Context.warn("Improper group rank setting format:",'"'..Data..'"')
						continue
					end

					groupRanks[groupID] = {groupRank =  groupRank,Rank = Rank}
				end
			end
			
			for _,groupInfo in pairs(playerGroups) do
				if groupRanks[groupInfo.Id] then
					if groupInfo.Rank >= groupRanks[groupInfo.Id].groupRank then
						table.insert(foundRanks,groupRanks[groupInfo.Id].Rank)
					end
				end
			end
		end)
		
		if not groupChecksucc then
			Context.warn("Problem checking groups for ranks for UserId:",UserId)
			Context.warn(groupcheckErr)
		end
		
		table.insert(foundRanks,Context.Data:getSavedRank(UserId))

		--Check owner
		local function isOwner()
			local succ, res = pcall(function()
				if game.CreatorType == Enum.CreatorType.User then
					return UserId == game.CreatorId
				elseif game.CreatorType == Enum.CreatorType.Group then
					local groupId = game.CreatorId
					local playerGroups = game:GetService("GroupService"):GetGroupsAsync(UserId)
					
					for _, groupInfo in ipairs(playerGroups) do
						if groupInfo.Id == groupId then
							if groupInfo.Rank == 255 then
								return true
							end
						end
					end
				end
				return false
			end)

			if succ then
				return res
			else
				Context.warn("Problem checking groups for Owner rank for UserId",UserId)
			end
		end

		if isOwner() then
			table.insert(foundRanks,4)
		end
		
		local determinedRank = math.max(table.unpack(foundRanks))
				
		self.__rankCache[UserId] = determinedRank

		local Player = Context.PlayerUtils:ResolveToPlayer(Player)
		if Player then
			Context.Comm:SendTo(Player,"RankUpdated",determinedRank)
		end
		
		return determinedRank
	end
	
	return Ranks
end