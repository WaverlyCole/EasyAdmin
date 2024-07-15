--[[
  ______                            _           _       
 |  ____|                  /\      | |         (_)      
 | |__   __ _ ___ _   _   /  \   __| |_ __ ___  _ _ __  
 |  __| / _` / __| | | | / /\ \ / _` | '_ ` _ \| | '_ \ 
 | |___| (_| \__ \ |_| |/ ____ \ (_| | | | | | | | | | |
 |______\__,_|___/\__, /_/    \_\__,_|_| |_| |_|_|_| |_|
                   __/ |                                
                  |___/  
 EasyAdmin.lua
 
--]]

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

script.Parent = ReplicatedStorage

local EasyAdmin = {
    __initiated = nil,
    __MainModule = script,
}

setmetatable(EasyAdmin, {
    __call = function(self, Options, PackagesFolder)
        if self.__initiated == nil then
            self.Packages = PackagesFolder or nil
			self.Options = Options or {}

            if RunService:IsServer() then
                print("[EasyAdmin]: Starting server")
                require(script:WaitForChild("EasyServer"))(self)
            elseif RunService:IsClient() then
                print("[EasyAdmin]: Starting client")
                require(script:WaitForChild("EasyClient"))(self)
            end

            self.__initiated = true
            return self
        else
            warn("[EasyAdmin] A module attempted to run setup call on MainModule. Returned already known context instead.")
            return self
        end
    end,
    __metatable = "Locked by EasyAdmin"
})

return EasyAdmin
