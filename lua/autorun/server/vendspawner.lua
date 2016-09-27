hook.Add("InitPostEntity","vend_spawner",function()
	if vend~=nil then
		vend.load()
		print("spawning..")
		for k, v in pairs(vend.loaded_data) do
			local tmp = ents.Create("ser_vender")
			tmp:SetPos(v.pos-Vector(0,0,98))
			tmp:SetAngles(v.ang)
			tmp:Spawn()
			tmp.name = v.name
			tmp.header = v.header
			tmp.ccolor = v.ccolor
			tmp.itemList = v.itemList
			tmp.Categories = v.Categories
			tmp:UpdateClientData()

		end
	end
end)
