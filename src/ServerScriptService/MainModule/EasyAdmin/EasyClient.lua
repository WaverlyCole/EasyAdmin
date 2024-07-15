return function(EasyAdmin)
	--//Shared Env
	for _,Module in script.Parent:WaitForChild("Shared"):GetChildren() do
		if Module:IsA("ModuleScript") then
			EasyAdmin[Module.Name] = require(Module)
		end
	end
	
	EasyAdmin.Comm = EasyAdmin.Network
		
	--//Client Env
	local startFuncs = {}
	for _,Module in script.Parent:WaitForChild("Client"):GetChildren() do
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

	for _,startMod in startFuncs do
		task.spawn(startMod)
	end
	
	--//Client Packages
	local Packages = script.Parent:FindFirstChild("Packages")
	if Packages then
		local packsToLoad = Packages:FindFirstChild("Client")
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

			for _,startMod in startFuncs do
				task.spawn(startMod)
			end
		end
	end
		
	--//Client Funcs
	
	
	EasyAdmin.__initiated = os.clock()
	
	return EasyAdmin
end