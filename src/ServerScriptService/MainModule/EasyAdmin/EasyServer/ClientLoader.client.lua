local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")

local EasyAdmin = require(ReplicatedStorage:WaitForChild("EasyAdmin"))()

EasyAdmin.Comm:Send("LoadedClient")