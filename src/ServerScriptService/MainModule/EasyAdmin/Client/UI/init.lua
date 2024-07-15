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
					v.Top.Refresh.Visible = true
					
					for i = 0,360,10 do
						if not v:IsDescendantOf(game) then return end
						v.Top.Refresh.Rotation = i
						task.wait()
					end
					
					if not RefreshCmd then
						v.Top.Refresh.Visible = false
					end
				end)
				return v
			end
		end
		
		local new = script.Assets.ContentFrame:Clone()
		new.Name = Name
		new.Top.Title.Text = `<b> {Name or " "} </b>`
		
		new.Top.Exit.Button.Activated:Connect(function()
			table.remove(UI.__activeContainers,table.find(UI.__activeContainers,new))
			Context.Comm:Send("ClosedContainer",Name)
			new:Destroy()
		end)
		
		if RefreshCmd then
			new.Top.Refresh.Visible = true
			new.Top.Refresh.Button.Activated:Connect(function()
				Context.Comm:Send("RunCommand",RefreshCmd)
			end)
		end
		
		local drag = UI.Draggable.new(new)
		drag:Enable()
		
		new.Parent = UI.SysUI

		table.insert(UI.__activeContainers,new)
		
		return new
	end
	
	function UI.addDropdownToLabel(textLabel, dropdownContent)
		local existingDropdown = textLabel.DropdownContent:FindFirstChild(dropdownContent)

		if existingDropdown then
			return existingDropdown
		end
		
		local newLabel = Instance.new("TextButton")
		newLabel.Interactable = false
		newLabel.Size = UDim2.new(1,0,0,30)
		newLabel.BackgroundTransparency = 1
		newLabel.TextTransparency = .1
		newLabel.RichText = true
		newLabel.TextColor3 = Color3.new(1, 1, 1)
		newLabel.Name = dropdownContent

		newLabel.Text = dropdownContent
		
		newLabel.Parent = textLabel.DropdownContent
		
		return newLabel
	end
	
	function UI.addTextLabel(contentFrame,labelContent)
		local existingLabel = contentFrame.Content:FindFirstChild(labelContent)
		if existingLabel then
			return existingLabel
		end
		
		local new = script.Assets.ContentFrameLabel:Clone()

		new.Name = labelContent
		new.MainText.Text = labelContent
		new.MainText.DropdownButton.Visible = false
		new.Button.Interactable = false
		
		new.Parent = contentFrame.Content
		
		local opened = false
		new:SetAttribute("Open",opened)
		
		new.Button.Activated:Connect(function()
			if new.MainText.DropdownButton.Visible == true then
				opened = not opened
				
				new:SetAttribute("Open",opened)
				
				if opened then
					local contentSize = new.DropdownContent.UIListLayout.AbsoluteContentSize.Y
					
					local sizeTween = TweenService:Create(new,UITweenInfo,{Size = UDim2.new(1,-6,0,30 + contentSize)}):Play()
					local dropdownTween = TweenService:Create(new.MainText.DropdownButton,UITweenInfo,{Rotation = 180}):Play()
				else
					local sizeTween = TweenService:Create(new,UITweenInfo,{Size = UDim2.new(1,-6,0,30)}):Play()
					local dropdownTween = TweenService:Create(new.MainText.DropdownButton,UITweenInfo,{Rotation = 0}):Play()
				end
			else
				new:SetAttribute("Clicked",true)
			end
		end)
		
		-- Toggle dropdown button visible
		
		local function updateDropdownVisible()
			if new:IsDescendantOf(game) then
				if #new.DropdownContent:GetChildren() > 2 then
					new.MainText.DropdownButton.Visible = true
					new.Button.Interactable = true
				else
					new.MainText.DropdownButton.Visible = false
					new.Button.Interactable = false
				end
			end
		end
		
		new.DropdownContent.ChildAdded:Connect(updateDropdownVisible)
		new.DropdownContent.ChildRemoved:Connect(updateDropdownVisible)
		
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
	
	Context.Comm:Hook("Hint",function(Data)
		local newHint = script.Assets.Hint:Clone()
		newHint.Top.Title.Text = `Notification from <b>{Data.From or "System"}</b>`
		newHint.Content.Content.Text = Data.Text or ""
		newHint.Size = UDim2.new(0,0,0,0)
		
		local dismissed = false
		
		local function dismiss()
			dismissed = true
			newHint:TweenSize(UDim2.new(0,0,0,0),Enum.EasingDirection.In,Enum.EasingStyle.Linear,.1)
			task.wait(.1)
			newHint:Destroy()
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
				
				newHint.Top.Time.Text = math.floor(timeLeft+1).."s"
				newHint.Top.Line.Progress.Size = UDim2.new(percentCompleted,0,1,0)
				
				if timeLeft <= 0 then
					Conn:Disconnect()
					dismiss()
				end
			end)
		else
			newHint.Top.Time.Visible = false
			newHint.Top.Line.Progress.Visible = false
		end
		
		newHint.Button.Activated:Connect(dismiss)
		
		newHint.Parent = UI.SysUI.Hints
		--print(newHint.Content.Content.TextBounds.X,newHint.Top.Title.TextBounds.X)
		newHint:TweenSize(UDim2.new(0,math.max(newHint.Content.Content.TextBounds.X + 20,newHint.Top.Title.TextBounds.X + 50),0,65),Enum.EasingDirection.In,Enum.EasingStyle.Linear,.1)
		newHint.Sound:Play()
		
		return true
	end)
	
	Context.Comm:Hook("Message",function(Data)
		local newHint = script.Assets.Message:Clone()
		newHint.Top.Title.Text = `Message from <b>{Data.From or "System"}</b>`
		newHint.Content.Content.Text = Data.Text or ""
		newHint.Size = UDim2.new(0,0,0,0)

		local dismissed = false

		local function dismiss()
			dismissed = true
			newHint:TweenSize(UDim2.new(0,0,0,0),Enum.EasingDirection.In,Enum.EasingStyle.Linear,.1)
			task.wait(.1)
			newHint:Destroy()
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

				newHint.Top.Time.Text = math.floor(timeLeft+1).."s"
				newHint.Top.Line.Progress.Size = UDim2.new(percentCompleted,0,1,0)

				if timeLeft <= 0 then
					Conn:Disconnect()
					dismiss()
				end
			end)
		else
			newHint.Top.Time.Visible = false
			newHint.Top.Line.Progress.Visible = false
		end

		newHint.Top.Exit.Button.Activated:Connect(dismiss)

		newHint.Parent = UI.SysUI.Messages
		--print(newHint.Content.Content.TextBounds.X,newHint.Top.Title.TextBounds.X)
		newHint:TweenSize(UDim2.new(0,math.max(newHint.Content.Content.TextBounds.X + 45,newHint.Top.Title.TextBounds.X + 85),0,65 + newHint.Content.Content.TextBounds.Y),Enum.EasingDirection.In,Enum.EasingStyle.Linear,.1)
		newHint.Sound:Play()
		
		return true
	end)
		
	Context.Comm:Hook("DisplayTable",function(Data)
		local newContainer = UI.newContentFrame(Data.Name or "Unknown",Data.Refresh)

		local Content = type(Data.Content) == "table" and Data.Content or {}

		for Index, Value in pairs(Content) do
			local newLabel = nil

			if type(Value) == "table" then
				newLabel = UI.addTextLabel(newContainer,tostring(Index))

				for _,DropdownOption in Value do
					if type(DropdownOption) == "table" then
						local newDrop = UI.addDropdownToLabel(newLabel,tostring(DropdownOption.Text))
						
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
						local newDrop = UI.addDropdownToLabel(newLabel,tostring(DropdownOption))
					end
				end
			else
				newLabel = UI.addTextLabel(newContainer,tostring(Value))
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