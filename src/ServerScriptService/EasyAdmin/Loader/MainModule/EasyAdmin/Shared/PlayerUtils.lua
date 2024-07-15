local Utils = {}

function Utils:UserIdToName(UserId)
	local succ,result = pcall(function()
		return game:GetService("Players"):GetNameFromUserIdAsync(UserId)
	end)
	
	if succ then
		return result
	else
		return "USERNAME_FAILED"
	end
end

function Utils:Teleport(Player,newCF)
	if typeof(newCF) == "Vector3" then
		newCF = CFrame.new(newCF)
	end
	
	local HRP = self:getHRP(Player)
	local Humanoid = self:getHumanoid(Player)
	
	if Humanoid then
		if Humanoid.Sit then
			Humanoid.Sit = false
			task.wait()
		end
	end
	
	HRP.CFrame = newCF
end

function Utils:SetCharacterTransparency(Player, Transparency, DecalTransparency)
	local Character = self:ResolveToPlayer(Player).Character
	for _,v in ipairs(Character:GetDescendants()) do
		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
			v.Transparency = Transparency
		elseif v:IsA("Decal") then
			v.Transparency = DecalTransparency or Transparency
		end
	end
end

function Utils:getHumanoid(Player)
	local Char = self:ResolveToCharacter(Player)
	if Char then
		local Humanoid = Char:FindFirstChildOfClass("Humanoid")
		if Humanoid then
			return Humanoid
		end
	end
end

function Utils:getHRP(Player)
	local Char = self:ResolveToPlayer(Player).Character
	if Char then
		local HRP = Char:FindFirstChild("HumanoidRootPart")
		if HRP then
			return HRP
		end
	end
end

function Utils:ResolveToUserId(providedType: any)
	if type(providedType) == "number" then
		return providedType
	elseif type(providedType) == "string" then
		if game:GetService("Players"):FindFirstChild(providedType) then
			return game:GetService("Players"):FindFirstChild(providedType).UserId
		else
			return tonumber(providedType)
		end
	elseif typeof(providedType) == "Instance" then
		if providedType:IsA("Player") then
			return providedType.UserId
		elseif providedType:IsA("Model") then
			local Player = game:GetService("Players"):GetPlayerFromCharacter(providedType)

			if Player then
				return Player.UserId
			end
		end
	end

	return nil
end

function Utils:ResolveToPlayer(providedType: any)
	local UserId = self:ResolveToUserId(providedType)

	if UserId then
		return game:GetService("Players"):GetPlayerByUserId(UserId)
	end

	return nil
end

function Utils:ResolveToCharacter(providedType: any)
	local Player = self:ResolveToPlayer(providedType)

	if Player then
		return Player.Character
	end

	return nil
end

return Utils