return function(EasyAdmin)
	local RunService = game:GetService("RunService")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local PlayersService = game:GetService("Players")

	--//Unpack packages (addons)
	if EasyAdmin.Packages then
		EasyAdmin.Packages.Parent = script.Parent
	end

	--//Shared Env
	for _,Module in script.Parent:WaitForChild("Shared"):GetChildren() do
		if Module:IsA("ModuleScript") then
			EasyAdmin[Module.Name] = require(Module)
		end
	end

	EasyAdmin.Comm = EasyAdmin.Network

	--//Server Env
	local startFuncs = {}
	for _,Module in script.Parent:WaitForChild("Server"):GetChildren() do
		if Module:IsA("ModuleScript") then
			local Mod = require(Module)(EasyAdmin)
			if Mod then
				EasyAdmin[Module.Name] = Mod

				if Mod.Start then
					table.insert(startFuncs,Mod.Start)
				end
			end
		end
	end

	script.Parent:WaitForChild("Server"):Destroy() -- remove so clients dont see

	for _,startMod in startFuncs do
		task.spawn(startMod)
	end

	--//Server Packages
	local Packages = script.Parent:FindFirstChild("Packages")
	if Packages then
		local packsToLoad = Packages:FindFirstChild("Server")
		if packsToLoad then
			EasyAdmin.Packages = {}

			local startFuncs = {}
			for _,Module in packsToLoad:GetChildren() do
				if Module:IsA("ModuleScript") then
					local Mod = require(Module)(EasyAdmin)
					if Mod then
						EasyAdmin[Module.Name] = Mod

						if Mod.Start then
							table.insert(startFuncs,Mod.Start)
						end
					end
				end
			end

			packsToLoad:Destroy() -- remove so clients dont see

			for _,startMod in startFuncs do
				task.spawn(startMod)
			end
		end
	end

	EasyAdmin.Comm:Hook("RunCommand",function(Player,cmdString)
		EasyAdmin.Commands:runCommand(Player,cmdString)
	end)

	EasyAdmin.Comm:Hook("LoadedClient",function(Player)
		local loadedRank = EasyAdmin.Ranks:Get(Player)
		local textRank = EasyAdmin.Options.RankLookup[loadedRank]

		if loadedRank > 0 then
			EasyAdmin.Comm:SendTo(Player,"Hint",{Text = `Permission level: {textRank or loadedRank}`,Time = 6})
		end

		Player.Chatted:Connect(function(Message)
			EasyAdmin.Commands:processCommand(Player,Message)
		end)
	end)

	--// Server Funcs

	function EasyAdmin:ContainerIsOpen(Player,ContainerName)
		return EasyAdmin.Request:Invoke(Player,"CheckContainer",ContainerName)
	end

	--// Connect clients

	local newClient = script:WaitForChild("ClientLoader"):Clone()
	newClient.Parent = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")

	for _,Player in PlayersService:GetPlayers() do
		task.spawn(function()
			local newClient = newClient:Clone()
			newClient.Parent = Player:WaitForChild("PlayerGui",math.huge)
		end)
	end

	--// Finish Up

	EasyAdmin.__initiated = os.clock()

	script.Parent = nil
	return EasyAdmin
end