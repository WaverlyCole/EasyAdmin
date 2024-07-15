local CollectionService = game:GetService("CollectionService")

return function(instanceType,propsTable)
	local new = Instance.new(instanceType)
	
	propsTable.Name = `EAInstance:{propsTable.Name and propsTable.Name or instanceType}`
	
	for i,v in propsTable do
		new[i] = v
	end
	
	CollectionService:AddTag(new,"EasyAdminInstance")
	
	return new
end