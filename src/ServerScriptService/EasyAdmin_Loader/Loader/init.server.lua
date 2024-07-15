--[[
  ______                            _           _       
 |  ____|                  /\      | |         (_)      
 | |__   __ _ ___ _   _   /  \   __| |_ __ ___  _ _ __  
 |  __| / _` / __| | | | / /\ \ / _` | '_ ` _ \| | '_ \ 
 | |___| (_| \__ \ |_| |/ ____ \ (_| | | | | | | | | | |
 |______\__,_|___/\__, /_/    \_\__,_|_| |_| |_|_|_| |_|
                   __/ |                                
                  |___/  
 Loader.lua
 
--]]

local Loader = {
	DebugMode = true;
	DebugModule = script.Parent.Parent:FindFirstChild("MainModule"),
	Asset = 18459734894;
	Settings = require(script.Parent:WaitForChild("Settings")),
	Packages = script.Parent.Packages
}

if not _G.EasyAdminLoaded then
	local Module
	
	if Loader.DebugMode and Loader.DebugModule then
		warn("[EasyAdmin] Running in Debug mode!")
		Module = require(Loader.DebugModule)
	else
		Module = require(Loader.Asset)
	end
	
	if Module(Loader.Settings, Loader.Packages) then
		_G.EasyAdminLoaded = os.clock()
	else
		warn(`[EasyAdmin]: Error loading`)
	end
else
	warn(`[EasyAdmin]: Admin system already loaded.`)
end