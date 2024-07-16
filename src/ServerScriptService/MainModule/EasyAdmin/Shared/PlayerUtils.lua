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

function Utils:ScaleCharacter(Char,scale,scaleProperties)
	local Humanoid = Char:FindFirstChildOfClass("Humanoid")
	local HRP = Char:FindFirstChild("HumanoidRootPart")

	if Humanoid and HRP then
		if Humanoid.RigType == Enum.HumanoidRigType.R15 then -- R15
			if Humanoid:FindFirstChild("HeadScale") then
				local HS = Humanoid.HeadScale
				local BDS = Humanoid.BodyDepthScale
				local BWS = Humanoid.BodyWidthScale
				local BHS = Humanoid.BodyHeightScale

				HS.Value = HS.Value * scale
				BDS.Value = BDS.Value * scale
				BWS.Value = BWS.Value * scale
				BHS.Value = BHS.Value * scale
			end
		else -- R6
			local halfHMRSize = (HRP.Size.Y / 2)
			for _, i in pairs(Char:GetDescendants()) do
				if i:IsA("BasePart") and i.Name ~= "HumanoidRootPart" then
					local wasCanCollide = i.CanCollide
					i.CanCollide = false
					i.Size = i.Size * scale
					i.CanCollide = wasCanCollide
				elseif i:IsA("FileMesh") and (not i:IsA("SpecialMesh") or i.MeshType == Enum.MeshType.FileMesh) then
					i.Scale = i.Scale * scale
				elseif i:IsA("JointInstance") then
					local wasAnchored = i.Part1.Anchored
					i.Part1.Anchored = false
					i.C0 = i.C0 - (i.C0.p * (1 - scale))
					i.C1 = i.C1 - (i.C1.p * (1 - scale))
					i.Part1.Anchored = wasAnchored
				elseif i:IsA("Attachment") then
					i.Position = i.Position * scale
				elseif i:IsA("Pose") then
					i.CFrame = i.CFrame - (i.CFrame.p * (1 - scale))
				elseif i:IsA("Humanoid") then
					i.HipHeight = (i.HipHeight + halfHMRSize) * scale - halfHMRSize
				end
			end
		end

		if scaleProperties then
			Humanoid.WalkSpeed = Humanoid.WalkSpeed * scale
			Humanoid.JumpPower = Humanoid.JumpPower * scale
			Humanoid.JumpHeight = Humanoid.JumpHeight * scale
		end
	end

	return Char
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