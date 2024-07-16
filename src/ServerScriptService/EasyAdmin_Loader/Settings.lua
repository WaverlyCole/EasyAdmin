--[[
  ______                            _           _       
 |  ____|                  /\      | |         (_)      
 | |__   __ _ ___ _   _   /  \   __| |_ __ ___  _ _ __  
 |  __| / _` / __| | | | / /\ \ / _` | '_ ` _ \| | '_ \ 
 | |___| (_| \__ \ |_| |/ ____ \ (_| | | | | | | | | | |
 |______\__,_|___/\__, /_/    \_\__,_|_| |_| |_|_|_| |_|
                   __/ |                                
                  |___/  
 Settings.lua
 
--]]

return {
	Prefix = ";", -- The prefix used in commands. The ";" in ";kill bob".
	DataStoreKey = "EasyAdminTesting", -- Key to used admin data. Changing this will reset all data
	
	Ranks = {
		--["Username"] = 2,
		--["UserId"] = 2,
		--["GroupId:GroupRank"] = 2,
	},
	
	RankLookup = {
		[0] = "Player",
		[1] = "Temp-Mod",
		[2] = "Mod",
		[3] = "Admin",
		[4] = "Owner"
	},
	
	DisableFunCommands = false,
}
