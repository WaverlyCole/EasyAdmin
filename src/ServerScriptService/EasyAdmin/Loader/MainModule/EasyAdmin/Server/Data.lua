return function(Context)
	local Data = {}
	
	Data.__cache = {}
	
	local DataStoreService = game:GetService("DataStoreService")
	
	local defaultDataKey = "EasyAdminDefault"
	local keyUsing = "EasyAdminDefault"
		
	if Context.Options.DataStoreKey then
		keyUsing = Context.Options.DataStoreKey
	end
	
	Data.__dataStore = DataStoreService:GetDataStore(keyUsing)
	
	local ranksKey = "savedRanks"
	
	if keyUsing == defaultDataKey then
		Context.warn("Using default data key. Consider changing this in settings!")
	end
	
	local playerDataTemplate = {
		cmdLogs = {},
	}
	
	function Data:getDataFor(Player)
		if self.__cache[Player] then
			return self.__cache[Player]
			
		else
			local succ,result = pcall(function()
				return self.__dataStore:GetAsync("pData-"..tostring(Player.UserId))
			end)
			if succ then
				self.__cache[Player] = result
				return result
			else
				Context.warn("Failed to get data for " .. Player.Name .. " because " .. result)
				return false
			end
		end
	end
	
	function Data:saveDataFor(Player)
		if self.__cache[Player] then
			local succ,result = pcall(function()
				return self.__dataStore:SetAsync("pData-"..tostring(Player.UserId),self.__cache[Player])
			end)
			if succ then
				self.__cache[Player] = nil
				return true
			else
				Context.warn("Failed to save data for " .. Player.Name .. " because " .. result)
				return false
			end
		end
	end
	
	function Data:saveRank(UserId,rankNum)
		local stringIndex = tostring(UserId)
		
		local succ, returned = pcall(function()
			return self.__dataStore:UpdateAsync(ranksKey,function(current)
				current = current or {}
				current[stringIndex] = rankNum
				
				if rankNum <= 0 then
					current[stringIndex] = nil
				end
				
				self.__savedRanks = current
				
				return current
			end)
		end)
		
		if succ then
			return true
		else
			Context.warn("Failed to save rank for",UserId,rankNum)
			return false
		end
	end
	
	function Data:loadSavedRanks()
		local succ,returned = pcall(function()
			return self.__dataStore:GetAsync(ranksKey)
		end)
		
		if succ then
			self.__savedRanks = returned or {}
			return self.__savedRanks
		else
			Context.warn("Failed to load saved ranks",returned)
			task.wait(1)
			return self:loadSavedRanks()
		end
	end
	
	function Data:getSavedRank(UserId)
		if not self.__savedRanks then
			self:loadSavedRanks()
		end
		
		return self.__savedRanks[tostring(UserId)]
	end
	
	return Data
end