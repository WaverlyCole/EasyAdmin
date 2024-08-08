local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EasyAdmin = require(ReplicatedStorage:WaitForChild("EasyAdmin"))()

EasyAdmin.Comm:Send("LoadedClient")