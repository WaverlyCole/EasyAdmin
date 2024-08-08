return function(Context, Props)
    local newCategory = Instance.new("Frame")
    newCategory.Name = Props.Name or "Category"
    newCategory.Size = UDim2.new(1,-6,0,30) 
    newCategory.BackgroundColor3 = Color3.new(0,0,0)
    newCategory.BackgroundTransparency = .5

    local categoryCorner = Instance.new("UICorner")
    categoryCorner.CornerRadius = UDim.new(0,4)
    categoryCorner.Parent = newCategory

    local categoryButton = Instance.new("TextButton")
    categoryButton.Name = "Button"
    categoryButton.Text = ""
    categoryButton.BackgroundTransparency = 1
    categoryButton.Size = UDim2.new(1,0,1,0)
    categoryButton.Parent = newCategory

    local categoryPadding = Instance.new("UIPadding")
    categoryPadding.PaddingBottom = UDim.new(0,2)
    categoryPadding.PaddingLeft = UDim.new(0,2)
    categoryPadding.PaddingRight = UDim.new(0,2)
    categoryPadding.PaddingTop = UDim.new(0,2)
    categoryPadding.Parent = newCategory

    local textLabel = Instance.new("TextLabel")
    textLabel.TextColor3 = Color3.new(1,1,1)
    textLabel.BackgroundColor3 = Color3.new(0,0,0)
    textLabel.Position = UDim2.new(.5,0,0,0)
    textLabel.BackgroundTransparency = .8
    textLabel.AnchorPoint = Vector2.new(.5,0)
    textLabel.Size = UDim2.new(1,0,0,26)
    textLabel.TextTransparency = .1
    categoryCorner:Clone().Parent = textLabel
    textLabel.Parent = newCategory

    local dropdownButton = Instance.new("ImageButton")
    dropdownButton.BackgroundTransparency = 1
    dropdownButton.ImageTransparency = .1
    dropdownButton.Image = "rbxassetid://5279719038"
    dropdownButton.AnchorPoint = Vector2.new(1,.5)
    dropdownButton.Size = UDim2.new(.5,0,.5,0)
    dropdownButton.Position = UDim2.new(.99,0,.5,0)
    dropdownButton.ZIndex = 3
    dropdownButton.Visible = false
    dropdownButton.Parent = textLabel
    Instance.new("UIAspectRatioConstraint",dropdownButton)

    local dropdownContent = Instance.new("Frame")
    dropdownContent.BackgroundTransparency = 1
    dropdownContent.ClipsDescendants = true
    dropdownContent.Name = "DropdownContent"
    dropdownContent.AnchorPoint = Vector2.new(.5,0)
    dropdownContent.Position = UDim2.new(.5,0,0,32)
    dropdownContent.Size = UDim2.new(1,0,1,-32)
    dropdownContent.ZIndex = 2
    categoryCorner:Clone().Parent = dropdownContent
    dropdownContent.Parent = newCategory

    local dropDownLayout = Instance.new("UIListLayout")
    dropDownLayout.FillDirection = Enum.FillDirection.Vertical
    dropDownLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    dropDownLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    dropDownLayout.Padding = UDim.new(0,4)
    dropDownLayout.SortOrder = Enum.SortOrder.LayoutOrder
    dropDownLayout.Parent = dropdownContent

    if Props.Text then
        textLabel.Text = Props.Text
    end

    local TweenService = game:GetService("TweenService")
    local UITweenInfo = TweenInfo.new(.25)
    local opened = false
    newCategory:SetAttribute("Open",opened)
    
    categoryButton.Activated:Connect(function()
        if dropdownButton.Visible == true then
            opened = not opened
            newCategory:SetAttribute("Open",opened)
            
            if opened then
                local contentSize = dropDownLayout.AbsoluteContentSize.Y
                
                local sizeTween = TweenService:Create(newCategory,UITweenInfo,{Size = UDim2.new(1,-6,0,30 + contentSize)}):Play()
                local dropdownTween = TweenService:Create(dropdownButton,UITweenInfo,{Rotation = 180}):Play()
            else
                local sizeTween = TweenService:Create(newCategory,UITweenInfo,{Size = UDim2.new(1,-6,0,30)}):Play()
                local dropdownTween = TweenService:Create(dropdownButton,UITweenInfo,{Rotation = 0}):Play()
            end
        else
            newCategory:SetAttribute("Clicked",true)
        end
    end)
    
    -- Toggle dropdown button visible
    
    local function updateDropdown()
        if newCategory:IsDescendantOf(game) then
            --Dropdown button visible?
            if #dropdownContent:GetChildren() > 2 then
                dropdownButton.Visible = true
                categoryButton.Interactable = true
            else
                dropdownButton.Visible = false
                categoryButton.Interactable = false
            end

            --Need to update size?
            if opened then
                local contentSize = dropDownLayout.AbsoluteContentSize.Y
                local sizeTween = TweenService:Create(newCategory,UITweenInfo,{Size = UDim2.new(1,-6,0,30 + contentSize)}):Play()
            end
        end
    end
    
    dropdownContent.ChildAdded:Connect(function(a)
        a.Changed:Connect(updateDropdown)

        updateDropdown()
    end)
    dropdownContent.ChildRemoved:Connect(updateDropdown)
	
    return newCategory
end