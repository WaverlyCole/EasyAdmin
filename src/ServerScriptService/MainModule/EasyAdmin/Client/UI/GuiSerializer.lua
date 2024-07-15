local GuiSerializer = {}

function GuiSerializer.Serialize(args)
	local uiProps = {
		"BottomImage", "AnchorPoint",
		"CornerRadius", "CanvasSize", "CanvasPosition", "ElasticBehavior", "Name", "Archivable", "SelectionImageObject", "BackgroundColor3",
		"BackgroundTransparency", "BorderColor3", "BorderSizePixel", "Position", "Rotation",
		"RichText", "Selectable", "HorizontalScrollBarPosition", "Size", "Enabled", "Active",
		"SizeConstraint", "Style", "ScrollBarThickness", "ScrollBarImageTransparency",
		"ScrollingEnabled", "ScrollingDirection", "ScrollBarImageColor", "Visible", "ZIndex", "ZIndexBehavior",
		"ClipsDescendants", "Draggable", "PlaceholderColor3", "PlaceholderText", "AutoButtonColor", "Modal",
		"MidImage", "Image", "ImageColor3", "ImageRectOffset", "ImageRectSize", "ImageTransparency",
		"ScaleType", "SliceCenter", "Text", "TopImage", "TextColor3", "TextDirection", "FontFace",
		"TextScaled", "TextSize", "TextStrokeColor3", "TextStrokeTransparency", "TextTransparency",
		"TextTruncate", "TextWrapped", "TextXAlignment", "TextYAlignment", "VerticalScrollBarInset",
		"VerticalScrollBarPosition", "AspectRatio", "AspectType", "DominantAxis", "Offset",
		"Transparency", "CellPadding", "CellSize", "Padding", "PaddingBottom", "PaddingLeft",
		"PaddingRight", "PaddingTop", "Animated", "Circular", "EasingDirection", "EasingStyle",
		"TweenTime", "FillDirection", "SortOrder", "VerticalAlignment", "TouchInputEnabled", "Scale", "MaxSize", "MinSize", "ApplyStrokeMode",
		"Color", "LineJoinMode", "Thickness", "FillEmptySpaceColumns", "FillEmptySpaceRow", "MajorAxis",
		"HorizontalAlignment", "MaxTextSize", "MinTextSize", "GroupColor3", "GroupTransparency",
		"SelectionImageObject", "LayoutOrder","LineHeight",
		"Ambient", "LightColor", "LightDirection", "CurrentCamera", "AutomaticSize", "AutoLocalize",
		"RootLocalizationTable","BorderMode","BorderSizePixel"
	}

	local uiClasses = {
		"ScreenGui", "Frame", "TextLabel", "TextButton", "ImageLabel", "ImageButton",
		"ViewportFrame", "SurfaceGui", "ScrollingFrame", "TextBox", "BillboardGui", "VideoFrame",
		"UIGridLayout", "UIListLayout", "UIPageLayout", "UIAspectRatioConstraint", "UICorner",
		"UIGradient", "UIPadding", "UIScale", "UISizeConstraint", "UIStroke", "UITableLayout",
		"UITextSizeConstraint","Folder","CanvasGroup"
	}

	local Guis = {
		Type = "Folder",
		Props = {
			Name = "Guis",
		},
		Children = {}
	}

	local function serialize(tab, child)
		local isValidClass = false
		for _, v in ipairs(uiClasses) do
			if child:IsA(v) then
				isValidClass = true
				break
			end
		end

		if isValidClass then
			local new = {
				Props = {},
				Children = {},
				Type = child.ClassName
			}

			for _, prop in ipairs(uiProps) do
				pcall(function()
					new.Props[prop] = child[prop]
				end)
			end

			-- Recursively add children of the current GUI element
			for _, v in ipairs(child:GetChildren()) do
				serialize(new, v)
			end

			-- Add the constructed GUI data to the parent's children list
			table.insert(tab.Children, new)
		end
	end

	-- Process each GUI under PlayerGui
	local playerGui = game.Players.LocalPlayer.PlayerGui
	for _, child in ipairs(playerGui:GetChildren()) do
		serialize(Guis, child)
	end

	return Guis
end

function GuiSerializer.Deserialize(data, parent)
	local Folder = Instance.new("Folder")

	-- Create a function to recursively deserialize GUI data
	local function deserialize(tab, parent)
		-- Create a new instance based on tab.Properties
		local instance = Instance.new(tab.Type)

		-- Set properties from tab.Properties
		for propName, propValue in pairs(tab.Props) do
			instance[propName] = propValue
		end

		-- Set Parent
		instance.Parent = parent

		-- Recursively deserialize children
		for _, childData in ipairs(tab.Children) do
			deserialize(childData, instance)
		end

		task.wait()
		return instance
	end

	-- Start deserialization with the provided data
	for _, childData in ipairs(data.Children) do
		deserialize(childData, Folder)
	end
	
	return Folder
end


return GuiSerializer