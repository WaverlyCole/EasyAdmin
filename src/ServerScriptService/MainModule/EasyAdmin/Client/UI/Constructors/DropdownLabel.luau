return function(Context, Props)
    local newLabel = Instance.new("TextButton")
    newLabel.Interactable = false
    newLabel.Size = UDim2.new(1,0,0,30)
    newLabel.BackgroundTransparency = 1
    newLabel.TextTransparency = .1
    newLabel.RichText = true
    newLabel.TextColor3 = Color3.new(1, 1, 1)
    newLabel.Name = Props.Name or "DropdownLabel"

    if Props.Text then
        newLabel.Text = Props.Text
    end

    return newLabel
end