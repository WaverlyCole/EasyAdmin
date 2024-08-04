return function(Context, Props)
    local newConfirmation = Instance.new("Frame")
    newConfirmation.BackgroundTransparency = 1
    newConfirmation.AnchorPoint = Vector2.new(.5,.5)
    newConfirmation.Position = UDim2.fromScale(.5,.5)
    newConfirmation.Size = UDim2.fromScale(.3,.2)

    local Base = require(script.Parent.Base)(Context,Props)
    Base.Name = "Main"
    Base.Top.Buttons.Close.Visible = false
    Base.Size = UDim2.fromScale(1,1)
    Base.Parent = newConfirmation

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Content"
    textLabel.TextWrapped = true
    textLabel.Size = UDim2.new(1,0,1,0)
    textLabel.TextColor3 = Color3.new(1,1,1)
    textLabel.AnchorPoint = Vector2.new(.5,1)
    textLabel.Position = UDim2.new(.5,0,1,0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextTransparency = .1
    textLabel.Parent = Base.Content

    if Props.Text then
        textLabel.Text = Props.Text
    else
        textLabel.Text = "Blank"
    end

    local Options = Instance.new("Frame")
    Options.Name = "Options"
    Options.BackgroundTransparency = 1
    Options.Position = UDim2.fromScale(0,1.1)
    Options.Size = UDim2.new(1,0,0,30)
    Options.Parent = newConfirmation

    local confirmFrame = Instance.new("Frame")
    confirmFrame.BackgroundTransparency = .5
    confirmFrame.BackgroundColor3 = Color3.new(0,0,0)
    confirmFrame.Name = "Confirm"
    confirmFrame.Size = UDim2.fromScale(.49,1)
    confirmFrame.Parent = Options

    local confirmButton = Instance.new("TextButton")
    confirmButton.Text = ""
    confirmButton.Name = "Button"
    confirmButton.BackgroundTransparency = 1
    confirmButton.Size = UDim2.fromScale(1,1)
    confirmButton.Parent = confirmFrame

    local confirmText = Instance.new("TextLabel")
    confirmText.TextColor3 = Color3.new(1,1,1)
    confirmText.RichText = true
    confirmText.Name = "Content"
    confirmText.Text = "<b>Yes</b>"
    confirmText.BackgroundTransparency = 1
    confirmText.Size = UDim2.fromScale(1,1)
    confirmText.Parent = confirmFrame

    local confirmCorner = Instance.new("UICorner")
    confirmCorner.CornerRadius = UDim.new(0,8)
    confirmCorner.Parent = confirmFrame

    local denyButtonFrame = confirmFrame:Clone()
    denyButtonFrame.Name = "Deny"
    denyButtonFrame.Position = UDim2.fromScale(1,0)
    denyButtonFrame.AnchorPoint = Vector2.new(1,0)
    denyButtonFrame.Content.Text = "<b>No</b>"
    denyButtonFrame.Parent = Options

    return newConfirmation
end