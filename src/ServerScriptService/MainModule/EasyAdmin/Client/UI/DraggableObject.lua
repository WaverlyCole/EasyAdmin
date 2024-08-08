-- DragModule.lua
-- A module to enable dragging on GUI objects with screen bounds clamping

local DragModule = {}
DragModule.__index = DragModule

local UserInputService = game:GetService("UserInputService")

-- Creates a new draggable object
function DragModule.new(guiObject)
    local self = setmetatable({}, DragModule)
    
    self.GuiObject = guiObject
    self.Dragging = false
    self.DragStart = nil
    self.StartPos = nil
    self.InputChangedConnection = nil
    self.InputEndedConnection = nil
    
    self:Enable()

    return self
end

-- Clamps the GUI object's position to keep it within screen bounds
function DragModule:ClampToScreen()
    local screenSize = workspace.CurrentCamera.ViewportSize
    local guiSize = self.GuiObject.AbsoluteSize
    local anchorPoint = self.GuiObject.AnchorPoint

    -- Calculate the min and max boundaries
    local minX = guiSize.X * anchorPoint.X
    local maxX = screenSize.X - guiSize.X * (1 - anchorPoint.X)
    local minY = (guiSize.Y * anchorPoint.Y)
    local maxY = screenSize.Y - guiSize.Y * (1 - anchorPoint.Y)

    -- Get current position in pixels
    local pos = self.GuiObject.Position
    local posX = pos.X.Scale * screenSize.X + pos.X.Offset
    local posY = pos.Y.Scale * screenSize.Y + pos.Y.Offset

    -- Clamp position
    posX = math.clamp(posX, minX, maxX)
    posY = math.clamp(posY, minY, maxY)

    -- Set the new clamped position
    self.GuiObject.Position = UDim2.new(0, posX, 0, posY)
end

-- Updates the GUI object's position based on input
function DragModule:UpdatePosition(input)
    local delta = input.Position - self.DragStart
    local newPosition = UDim2.new(
        self.StartPos.X.Scale,
        self.StartPos.X.Offset + delta.X,
        self.StartPos.Y.Scale,
        self.StartPos.Y.Offset + delta.Y
    )
    self.GuiObject.Position = newPosition
    self:ClampToScreen()
end

-- Enables dragging
function DragModule:Enable()
    self.GuiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.Dragging = true
            self.DragStart = input.Position
            self.StartPos = self.GuiObject.Position

            self.InputChangedConnection = UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    if self.Dragging then
                        self:UpdatePosition(input)
                    end
                end
            end)

            self.InputEndedConnection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    self.Dragging = false
                    if self.InputChangedConnection then
                        self.InputChangedConnection:Disconnect()
                    end
                    if self.InputEndedConnection then
                        self.InputEndedConnection:Disconnect()
                    end
                end
            end)
        end
    end)
end

-- Disables dragging
function DragModule:Disable()
    if self.InputChangedConnection then
        self.InputChangedConnection:Disconnect()
    end
    if self.InputEndedConnection then
        self.InputEndedConnection:Disconnect()
    end
end

return DragModule
