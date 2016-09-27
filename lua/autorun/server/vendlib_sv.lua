print("LOADED VENDLIB_SV")
vend = {}

vend.load = function()
	if !file.Exists("vend_data","DATA") then
		file.CreateDir("vend_data")
	end
	local map = game.GetMap()
	if !file.Exists("vend_data/"..map,"DATA") then
		file.CreateDir("vend_data/"..map)
	end
	if !file.Exists("vend_data/"..map.."/config.txt","DATA") then
		file.Write("vend_data/"..map.."/config.txt",util.TableToJSON({}))
		vend.loaded_data = {}
	else
		vend.loaded_data = util.JSONToTable(file.Read("vend_data/"..map.."/config.txt","DATA"))
	end
end

vend.save = function(ent,data)
	if vend.loaded_data == nil then vend.load() end
	vend.loaded_data[data.name]=data
	vend.loaded_data[data.name].pos = ent:GetPos()
	vend.loaded_data[data.name].ang = ent:GetAngles()
	file.Write("vend_data/"..game.GetMap().."/config.txt",util.TableToJSON(vend.loaded_data))
end

vend.forcesave = function()
	file.Write("vend_data/"..game.GetMap().."/config.txt",util.TableToJSON(vend.loaded_data))
end

vend.remove = function(name)
	if vend.loaded_data == nil then vend.load() end
	vend.loaded_data[name]=nil
	vend.forcesave()
end

vend.persist = function(ent,data)
	vend.save(ent,data)
end

vend.nopersist = function(ent,name)
	vend.remove(name)
end

vend.update = function(ent,data)
	vend.save(ent,data)
end
