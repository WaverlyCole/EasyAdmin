local Network = {_hooks = {}}

local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local IsServer = RunService:IsServer()
local IsClient = RunService:IsClient()

local Debug = false

if IsServer then
	Network._remote = Instance.new("RemoteFunction")
	Network._remote.Name = "Main"
	Network._remote.Parent = script

	Network._remote.OnServerInvoke = function(Player, hookName, ...)
		local payload = {...}

		local succ,res = pcall(function()
			if Network._hooks[hookName] then
				local results = {}
				for _, hook in pairs(Network._hooks[hookName]) do
					local success, result = pcall(hook, Player, unpack(payload))
					if success then
						table.insert(results, result)
					else
						warn("Error in hook " .. hookName .. ": " .. result)
					end
				end
				return unpack(results)
			end
		end)

		if succ then return res else return nil end
	end
elseif IsClient then
	Network._remote = script:WaitForChild("Main",math.huge)

	Network._remote.OnClientInvoke = function(hookName, ...)
		local payload = {...}

		local succ,res = pcall(function()
			if Network._hooks[hookName] then
				local results = {}
				for _, hook in pairs(Network._hooks[hookName]) do
					local success, result = pcall(hook, unpack(payload))
					if success then
						table.insert(results, result)
					else
						warn("Error in hook " .. hookName .. ": " .. result)
					end
				end
				return unpack(results)
			end
		end)

		if succ then return res else return nil end
	end
end

function Network:generateHook()
	local newHook = HttpService:GenerateGUID(false)
	return newHook
end

function Network:Unhook(hookName, hookID)
	if self._hooks[hookName] and hookID then
		self._hooks[hookName][hookID] = nil
		if Debug then print(`"Network {IsServer and "Server" or "Client"} unregistered {hookName}({hookID})`) end
		if next(self._hooks[hookName]) == nil then
			self._hooks[hookName] = nil
		end
	end
end

function Network:Hook(hookName, hookRun)
	local hookID = self:generateHook()
	if not self._hooks[hookName] then
		self._hooks[hookName] = {}
	end
	self._hooks[hookName][hookID] = hookRun

	if Debug then print(`"Network {IsServer and "Server" or "Client"} registered {hookName}({hookID})`) end
	
	local newHook = {}
	newHook.Name = hookName
	newHook.Id = hookID
	newHook._run = hookRun
	
	function newHook:Disconnect()
		Network:Unhook(hookName, hookID)
		table.clear(newHook)
	end

	return newHook
end

function Network:isHooked(hookName)
	return self._hooks[hookName] ~= nil
end

function Network:Get()
	return self
end

--//Yielding

function Network:SendAwait(...)
	local Args = {...}

	if IsClient then
		return self._remote:InvokeServer(unpack(Args))
	else
		local succ,res = pcall(function()
			return self._remote:InvokeClient(table.remove(Args, 1), unpack(Args))
		end)

		if succ then return res else return nil end
	end
end

function Network:Invoke(...)
	return Network:SendAwait(...)
end

--//Non-Yielding

function Network:Send(hookName, ...)
	assert(IsClient, "Send is not usable on server")
	local Args = {hookName, ...}

	task.spawn(function()
		self._remote:InvokeServer(unpack(Args))
	end)

	return true
end

function Network:SendTo(plrsTbl, ...)
	assert(IsServer, "SendTo is not usable on clients")
	local Args = {...}

	if typeof(plrsTbl) == "Instance" then
		plrsTbl = {plrsTbl}
	end

	for _, Plr in ipairs(plrsTbl) do
		task.spawn(function()
			local succ,res = pcall(function()
				return self._remote:InvokeClient(Plr, unpack(Args))
			end)

			if succ then return res else return nil end
		end)
	end

	return true
end

return Network