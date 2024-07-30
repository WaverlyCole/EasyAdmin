return function(Context, Props)
    local Base = require(script.Parent.Base)(Context,Props)

    Base.Size = UDim2.new(0,0,0,0)

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Content"
    textLabel.TextWrapped = true
    textLabel.Size = UDim2.new(1,0,1,0)
    textLabel.TextColor3 = Color3.new(1,1,1)
    textLabel.AnchorPoint = Vector2.new(.5,1)
    textLabel.Position = UDim2.new(.5,0,1,0)
    textLabel.BackgroundTransparency = 1
    textLabel.Parent = Base.Content

    if Props.Text then
        textLabel.Text = Props.Text
    else
        textLabel.Text = "Blank"
    end

    return Base
end