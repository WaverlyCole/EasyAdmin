return function(Context, Props)
    local newContainer = require(script.Parent.Base)(Context, Props)
    newContainer.Name = Props.Name or "Container"
    newContainer.Size = UDim2.new(0,250,0,300)

    newContainer.Content:Destroy()
    local content = Instance.new("ScrollingFrame")
    content.Name = "Content"
    content.BackgroundTransparency = 1
    content.AnchorPoint = Vector2.new(.5,1)
    content.Position = UDim2.new(.5,0,1,-4)
    content.Size = UDim2.new(1,-8,1,-39)
    content.AutomaticCanvasSize = Enum.AutomaticSize.XY
    content.ScrollBarImageTransparency = .5
    content.ScrollBarThickness = 2
    content.Parent = newContainer

    return newContainer
end