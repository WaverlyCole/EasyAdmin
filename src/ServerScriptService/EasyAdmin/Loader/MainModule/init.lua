--[[
  ______                            _           _       
 |  ____|                  /\      | |         (_)      
 | |__   __ _ ___ _   _   /  \   __| |_ __ ___  _ _ __  
 |  __| / _` / __| | | | / /\ \ / _` | '_ ` _ \| | '_ \ 
 | |___| (_| \__ \ |_| |/ ____ \ (_| | | | | | | | | | |
 |______\__,_|___/\__, /_/    \_\__,_|_| |_| |_|_|_| |_|
                   __/ |                                
                  |___/  
 MainModule.lua
 
--]]

return function(Settings, Packages)
	return require(script.EasyAdmin)(Settings,Packages)
end