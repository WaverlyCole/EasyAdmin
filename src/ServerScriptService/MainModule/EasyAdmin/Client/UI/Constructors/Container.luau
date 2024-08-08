return function(Context, Props)
    local newContainer = require(script.Parent.Base)(Context, Props)
    newContainer.Position = UDim2.new(.01,0,.4,0)
    newContainer.Name = Props.Name or "Container"
    newContainer.Size = UDim2.new(0,250,0,300)

    newContainer.Top.Title.TextXAlignment = Enum.TextXAlignment.Left

    newContainer.Top.Buttons.Search.Visible = true

    newContainer.Content:Destroy()
    local content = Instance.new("ScrollingFrame")
    content.Name = "Content"
    content.BorderSizePixel = 0
    content.BackgroundTransparency = 1
    content.AnchorPoint = Vector2.new(.5,1)
    content.Position = UDim2.new(.5,0,1,-4)
    content.Size = UDim2.new(1,-8,1,-39)
    content.AutomaticCanvasSize = Enum.AutomaticSize.XY
    content.ScrollBarImageTransparency = .5
    content.ScrollBarThickness = 2
    content.Parent = newContainer

    local listLayout = Instance.new("UIListLayout")
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    listLayout.Padding = UDim.new(0,4)
    listLayout.Parent = content

    return newContainer
end