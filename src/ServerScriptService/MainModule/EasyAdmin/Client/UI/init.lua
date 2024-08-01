return function(Context)
	local UI = {}
	
	UI.PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui",math.huge)
	UI.SysUI = script:WaitForChild("EasyAdminGui"):Clone()
	UI.SysUI.Parent = UI.PlayerGui
	
	UI.__activeContainers = {}
	
	UI.GuiSerializer = require(script:WaitForChild("GuiSerializer"))
	UI.Draggable = require(script:WaitForChild("DraggableObject"))
		
	local TweenService = game:GetService("TweenService")
	local UITweenInfo = TweenInfo.new(.25)
	
	function UI.newContentFrame(Name,RefreshCmd)
		for _,v in UI.__activeContainers do
			if v.Name == Name then
				task.spawn(function()
					v.Top.Buttons.Refresh.Visible = true
					
					for i = 0,360,10 do
						if not v:IsDescendantOf(game) then return end
						v.Top.Buttons.Refresh.Button.Rotation = i
						task.wait()
					end
					
					if not RefreshCmd then
						v.Top.Buttons.Refresh.Visible = false
					end
				end)
				return v
			end
		end
		
		local new = UI.new("Container",{Name = Name, Title = `<b> {Name} </b>`})
		
		new.Top.Buttons.Close.Button.Activated:Connect(function()
			table.remove(UI.__activeContainers,table.find(UI.__activeContainers,new))
			Context.Comm:Send("ClosedContainer",Name)
			new:Destroy()
		end)
		
		if RefreshCmd then
			new.Top.Buttons.Refresh.Visible = true
			new.Top.Buttons.Refresh.Button.Activated:Connect(function()
				Context.Comm:Send("RunCommand",RefreshCmd)
			end)
		end
		
		local drag = UI.Draggable.new(new)
		drag:Enable()
		
		new.Parent = UI.SysUI

		table.insert(UI.__activeContainers,new)
		
		return new
	end
	
	function UI.addLabelToCategory(textLabel, dropdownContent)
		local existingDropdown = textLabel.DropdownContent:FindFirstChild(dropdownContent)

		if existingDropdown then
			return existingDropdown
		end
		
		local newLabel = UI.new("DropdownLabel",{Name = dropdownContent,Text = dropdownContent})
		
		newLabel.Parent = textLabel.DropdownContent
		
		return newLabel
	end
	
	function UI.addCategory(contentFrame,labelContent)
		local existingLabel = contentFrame.Content:FindFirstChild(labelContent)
		if existingLabel then
			return existingLabel
		end
		
		local new = UI.new("ContainerCategory",{Name = labelContent,Text = labelContent})
	
		new.Parent = contentFrame.Content
		
		return new
	end
	
	Context.Comm:Hook("Confirmation",function(Data)
		local newHint = script.Assets.Confirmation:Clone()
		newHint.Main.Top.Title.Text = `Confirmation from <b>{Data.From or "System"}</b>`
		newHint.Main.Content.Content.Text = Data.Text or ""
		newHint.Size = UDim2.new(0,0,0,0)

		local dismissed = false
		local response = nil

		local function dismiss()
			dismissed = true
			newHint:TweenSize(UDim2.new(0,0,0,0),Enum.EasingDirection.In,Enum.EasingStyle.Linear,.1)
			task.wait(.1)
			newHint:Destroy()
			return nil
		end
		
		if not Data.Time then
			Data.Time = 15
		end

		if Data.Time then
			local endTime = time() + Data.Time

			local Conn;Conn = game:GetService("RunService").Stepped:Connect(function()
				if dismissed then
					Conn:Disconnect()
				end
				local currTime = time()
				local timeLeft = endTime - currTime
				local percentCompleted = 1 - (currTime/endTime)

				newHint.Main.Top.Time.Text = math.floor(timeLeft+1).."s"
				newHint.Main.Top.Line.Progress.Size = UDim2.new(percentCompleted,0,1,0)

				if timeLeft <= 0 then
					Conn:Disconnect()
					dismiss()
				end
			end)
		else
			newHint.Main.Top.Time.Visible = false
			newHint.Main.Top.Line.Progress.Visible = false
		end

		newHint.Parent = UI.SysUI.Prompts
		--print(newHint.Content.Content.TextBounds.X,newHint.Top.Title.TextBounds.X)
		
		newHint:TweenSize(UDim2.new(0,math.max(newHint.Main.Content.Content.TextBounds.X + 35,newHint.Main.Top.Title.TextBounds.X + 60),0,newHint.Main.Content.Content.TextBounds.Y + 80),Enum.EasingDirection.In,Enum.EasingStyle.Linear,.1)
		--newHint.Sound:Play()

		newHint.Options.Confirm.Button.Activated:Connect(function()
			response = true
			dismiss()
		end)
		
		newHint.Options.Deny.Button.Activated:Connect(function()
			response = false
			dismiss()
		end)
		
		repeat task.wait() until dismissed
		
		return response
	end)

	function UI.new(UIType,Props)
		local Constructor = script.Constructors:FindFirstChild(UIType)

		if Constructor then
			local obj = require(Constructor)(Context,Props)
			obj:SetAttribute("UIType",UIType)
			return obj
		else
			Context.warn("Could not find constructor for UI Type:", UIType)
		end
	end

	function UI:Notify(Props)
		local newNotificaiton = self.new("Notification",Props)
		local dismissed = false
		
		local function dismiss()
			dismissed = true
			newNotificaiton:TweenSize(UDim2.new(0,0,0,0),Enum.EasingDirection.In,Enum.EasingStyle.Linear,.1)
			task.wait(.1)
			newNotificaiton:Destroy()
		end
		
		if Props.Time then
			local endTime = time() + Props.Time
			
			local Conn;Conn = game:GetService("RunService").Stepped:Connect(function()
				if dismissed then
					Conn:Disconnect()
				end
				local currTime = time()
				local timeLeft = endTime - currTime
				local percentCompleted = 1 - (currTime/endTime)
				
				newNotificaiton.Top.Time.Text = math.floor(timeLeft+1).."s"
				newNotificaiton.Top.Line.Progress.Size = UDim2.new(percentCompleted,0,1,0)
				
				if timeLeft <= 0 then
					Conn:Disconnect()
					dismiss()
				end
			end)
		else
			newNotificaiton.Top.Time.Visible = false
			newNotificaiton.Top.Line.Progress.Visible = false
		end
		
		newNotificaiton.Button.Activated:Connect(dismiss)
		
		newNotificaiton.Parent = UI.SysUI.Hints
		--print(newHint.Content.Content.TextBounds.X,newHint.Top.Title.TextBounds.X)
		newNotificaiton:TweenSize(UDim2.new(0,math.max(newNotificaiton.Content.Content.TextBounds.X + 20,newNotificaiton.Top.Title.TextBounds.X + 60),0,65),Enum.EasingDirection.In,Enum.EasingStyle.Linear,.1)
	end

	function UI:Message(Props)
		local newNotificaiton = self.new("Message",Props)
		local dismissed = false
		
		local function dismiss()
			dismissed = true
			newNotificaiton:TweenSize(UDim2.new(0,0,0,0),Enum.EasingDirection.In,Enum.EasingStyle.Linear,.1)
			task.wait(.1)
			newNotificaiton:Destroy()
		end
		
		if Props.Time then
			local endTime = time() + Props.Time
			
			local Conn;Conn = game:GetService("RunService").Stepped:Connect(function()
				if dismissed then
					Conn:Disconnect()
				end
				local currTime = time()
				local timeLeft = endTime - currTime
				local percentCompleted = 1 - (currTime/endTime)
				
				newNotificaiton.Top.Time.Text = math.floor(timeLeft+1).."s"
				newNotificaiton.Top.Line.Progress.Size = UDim2.new(percentCompleted,0,1,0)
				
				if timeLeft <= 0 then
					Conn:Disconnect()
					dismiss()
				end
			end)
		else
			newNotificaiton.Top.Time.Visible = false
			newNotificaiton.Top.Line.Progress.Visible = false
		end
		
		newNotificaiton.Top.Buttons.Close.Button.Activated:Connect(dismiss)
		
		newNotificaiton.Parent = UI.SysUI.Messages
		--print(newHint.Content.Content.TextBounds.X,newHint.Top.Title.TextBounds.X)
		newNotificaiton:TweenSize(UDim2.new(0,math.max(newNotificaiton.Content.Content.TextBounds.X + 45,newNotificaiton.Top.Title.TextBounds.X + 85),0,65 + newNotificaiton.Content.Content.TextBounds.Y),Enum.EasingDirection.In,Enum.EasingStyle.Linear,.1)
	end
	
	Context.Comm:Hook("Notify",function(Data)
		Data.Title = `<b>{Data.From or "System"}</b>`
		Data.From = nil

		UI:Notify(Data)

		return true
	end)
	
	Context.Comm:Hook("Message",function(Data)
		Data.Title = `<b>{Data.From or "System"}</b>`
		Data.From = nil

		UI:Message(Data)

		return true
	end)
		
	Context.Comm:Hook("DisplayTable",function(Data)
		local newContainer = UI.newContentFrame(Data.Name or "Unknown",Data.Refresh)

		local Content = type(Data.Content) == "table" and Data.Content or {}

		for Index, Value in pairs(Content) do
			local newLabel = nil

			if type(Value) == "table" then
				newLabel = UI.addCategory(newContainer,tostring(Index))

				for _,DropdownOption in Value do
					if type(DropdownOption) == "table" then
						local newDrop = UI.addLabelToCategory(newLabel,tostring(DropdownOption.Text))
						
						newDrop.Interactable = true
						
						newDrop.MouseEnter:Connect(function()
							newDrop.Text = `[ {DropdownOption.Text} ]`
						end)
						newDrop.MouseLeave:Connect(function()
							newDrop.Text = DropdownOption.Text
						end)
						newDrop.Activated:Connect(function()
							if DropdownOption.Command then
								Context.Comm:Send("RunCommand",DropdownOption.Command)
							end
						end)
					else
						local newDrop = UI.addLabelToCategory(newLabel,tostring(DropdownOption))
					end
				end
			else
				newLabel = UI.addCategory(newContainer,tostring(Value))
			end
		end
		
		--remove
		
		for _, v in ipairs(newContainer.Content:GetChildren()) do
			if v:IsA("UIComponent") then
				continue
			end

			local found = false

			for Index, Value in pairs(Content) do
				local search = Value

				if type(Value) == "table" then
					search = Index
				end

				if v.Name == tostring(search) then
					found = true
					break
				end
			end

			if not found then
				v:Destroy()
			end
		end
		
		return true
	end)
	
	Context.Comm:Hook("ViewAvatar",function(UserId)
		game:GetService("GuiService"):InspectPlayerFromUserId(UserId)
	end)
	
	Context.Comm:Hook("CheckContainer",function(containerName)
		for _,v in UI.__activeContainers do
			if v.Name == containerName then
				return true
			end
		end
		
		return false
	end)
	
	Context.Comm:Hook("SerializeGuis",function()
		local serial = UI.GuiSerializer.Serialize()
		
		return serial
	end)
	
	Context.Comm:Hook("DeserializeGuis",function(Data)
		local main = UI.GuiSerializer.Deserialize(Data)
		
		main.Parent = UI.SysUI
		task.wait(5)
		main:Destroy()
		
		return true
	end)
	
	
	return UI
end