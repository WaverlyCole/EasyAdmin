return function(Context, Props)
    local uiGroup = Instance.new("CanvasGroup")
    uiGroup.Name = "Base"
    uiGroup.Size = UDim2.new(0,250,0,250)
    uiGroup.BackgroundTransparency = .5
    uiGroup.BackgroundColor3 = Color3.new(0,0,0)

    local groupCorner = Instance.new("UICorner")
    groupCorner.CornerRadius = UDim.new(0,8)
    groupCorner.Parent = uiGroup

    local topBar = Instance.new("Frame")
    topBar.Name = "Top"
    topBar.Size = UDim2.new(1,0,0,30)
    topBar.BackgroundColor3 = Color3.new(0,0,0)
    topBar.BackgroundTransparency = .5
    topBar.Parent = uiGroup

    local topBarTitle = Instance.new("TextLabel")
    topBarTitle.Name = "Title"
    topBarTitle.TextColor3 = Color3.new(1,1,1)
    topBarTitle.AnchorPoint = Vector2.new(.5,.5)
    topBarTitle.Position = UDim2.new(.5,0,.5,0)
    topBarTitle.Size = UDim2.new(.8,0,1,0)
    topBarTitle.FontFace.Weight = Enum.FontWeight.Bold
    topBarTitle.BackgroundTransparency = 1
    topBarTitle.TextTransparency = .1
    topBarTitle.RichText = true
    topBarTitle.Parent = topBar

    local timeDisplay = topBarTitle:Clone()
    timeDisplay.Name = "Time"
    timeDisplay.Text = ""
    timeDisplay.TextColor3 = Color3.new(1,1,1)
    timeDisplay.AnchorPoint = Vector2.new(0,.5)
    timeDisplay.Position = UDim2.new(0,8,.5,0)
    timeDisplay.Size = UDim2.new(.05,0,1,0)
    timeDisplay.TextTransparency = .1
    timeDisplay.TextXAlignment = Enum.TextXAlignment.Left
    topBarTitle.FontFace.Weight = Enum.FontWeight.Medium
    timeDisplay.Parent = topBar

    local topBarButtons = Instance.new("Frame")
    topBarButtons.Name = "Buttons"
    topBarButtons.AnchorPoint = Vector2.new(1,.5)
    topBarButtons.Position = UDim2.new(1,0,.5,0)
    topBarButtons.Size = UDim2.new(.5,0,.8,0)
    topBarButtons.BackgroundTransparency = 1
    topBarButtons.Parent = topBar

    local buttonsLayout = Instance.new("UIListLayout")
    buttonsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    buttonsLayout.FillDirection = Enum.FillDirection.Horizontal
    buttonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    buttonsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    buttonsLayout.Parent = topBarButtons

    local closeButtonFrame = Instance.new("Frame")
    closeButtonFrame.Name = "Close"
    closeButtonFrame.BackgroundTransparency = 1
    closeButtonFrame.Size = UDim2.new(1,0,1,0)
    closeButtonFrame.LayoutOrder = 999
    closeButtonFrame.Parent = topBarButtons

    local buttonRatio = Instance.new("UIAspectRatioConstraint")
    buttonRatio.Parent = closeButtonFrame

    local closeButton = Instance.new("ImageButton")
    closeButton.Name = "Button"
    closeButton.AnchorPoint = Vector2.new(.5,.5)
    closeButton.Position = UDim2.new(.5,0,.5,0)
    closeButton.Size = UDim2.new(.95,0,.95,0)
    closeButton.BackgroundTransparency = 1
    closeButton.Image = "http://www.roblox.com/asset/?id=6415685859"
    closeButton.ImageTransparency = .1
    closeButton.Parent = closeButtonFrame

    local refreshButton = closeButtonFrame:Clone()
    refreshButton.Name = "Refresh"
    refreshButton.Button.Image = "rbxassetid://18459550449"
    refreshButton.Visible = false
    refreshButton.LayoutOrder = 1
    refreshButton.Parent = topBarButtons

    local topLine = Instance.new("Frame")
    topLine.Name = "Line"
    topLine.BackgroundTransparency = .5
    topLine.Position = UDim2.new(0,0,1,0)
    topLine.Size = UDim2.new(1,0,0,1)
    topLine.BorderSizePixel = 0
    topLine.Parent = topBar

    local progressBar = Instance.new("Frame")
    progressBar.Name = "Progress"
    progressBar.BorderSizePixel = 0
    progressBar.Size = UDim2.new(0,0,1,0)
    progressBar.Parent = topLine

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.BackgroundTransparency = 1
    content.AnchorPoint = Vector2.new(.5,1)
    content.Position = UDim2.new(.5,0,1,-4)
    content.Size = UDim2.new(1,-8,1,-39)
    content.Parent = uiGroup

    warn(Props)

    if Props.Title then
        topBarTitle.Text = Props.Title
    end

    return uiGroup
end