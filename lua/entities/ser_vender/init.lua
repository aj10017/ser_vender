AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )
ENT.aHealth = 150
ENT.dieTime = 0
ENT.StoredMoney = 0
ENT.Spawning = false
util.AddNetworkString("vend.buy")
util.AddNetworkString("vend.sync")
util.AddNetworkString("vend.fullsync")
util.AddNetworkString("vend.update")
util.AddNetworkString("vend.persist")
util.AddNetworkString("vend.nopersist")

VS = VS or {}
VS.Clear = function()
	VSHARE.time = CurTime()+0.01
	VSHARE.ply = nil
	VSHARE.self = nil
	VSHARE.ent = nil
end

VSHARE = VSHARE or {time=0,ply=nil,self=nil}

hook.Add("Tick","vshare",function()
	if VSHARE.time < CurTime()+0.01 then
		VS.Clear()
	end
end)

net.Receive("vend.persist",function(len,ply)
	if !ply:IsSuperAdmin() then return end
	local ent = net.ReadEntity()
	local data = net.ReadTable()
	ent.name = data.name
	ent.header = data.header
	ent.itemList = data.itemList
	ent.Categories = data.Categories
	vend.persist(ent,data)
	ent:UpdateClientData()
end)

net.Receive("vend.nopersist",function(len,ply)
	if !ply:IsSuperAdmin() then return end
	local ent = net.ReadEntity()
	local name = net.ReadString()
	vend.nopersist(ent,name)
	ent:UpdateClientData()
end)

net.Receive("vend.update",function(len,ply)
	if !ply:IsSuperAdmin() then return end
	local ent = net.ReadEntity()
	local data = net.ReadTable()
	ent.name = data.name
	ent.header = data.header
	ent.itemList = data.itemList
	ent.Categories = data.Categories
	vend.persist(ent,data)
	ent:UpdateClientData()
end)

net.Receive("vend.fullsync",function(len,ply)
	local ent = net.ReadEntity()
	if ent:IsValid() then ent:UpdateClientData() end
end)



function ENT:Initialize()

	self:SetModel( "models/props_interiors/VendingMachineSoda01a.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
	local min, max = self:GetModelBounds()
	self:SetPos(self:GetPos()+(Vector(0,0,max.z-min.z)))
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion( false )
		phys:Wake()
	end
	self.Select = 0
	self.name = "default"
	self.header = "WELCOME HUMAN."
	self.ccolor = Color(50,50,50,170)
	self.SelectedCategory = 0
end

function ENT:UpdateClientData()
	vend.load()
	net.Start("vend.fullsync")
	local persistant = false
	if vend.loaded_data[self.name]~=nil then persistant = true end
	net.WriteEntity(self)
	if vend.loaded_data[self.name]~=nil then
		net.WriteTable({name=vend.loaded_data[self.name].name or self.name,header=vend.loaded_data[self.name].header or self.header,persist = persistant,itemList=vend.loaded_data[self.name].itemList or self.itemList,Categories=vend.loaded_data[self.name].Categories or self.Categories,ccolor=vend.loaded_data[self.name].ccolor or self.ccolor})
	else
		net.WriteTable({name=self.name,header=self.header,persist = persistant,itemList=self.itemList,Categories=self.Categories,ccolor=self.ccolor})
	end
	net.Broadcast()
end



function ENT:GetCenterPos()
	return self:GetPos()
end



net.Receive("vend.buy",function(len,ply)
	local id = net.ReadEntity()
	local sel = net.ReadInt(8)
	local selcat = net.ReadInt(8)
	if IsValid(id) then if ply:GetPos():Distance(id:GetPos()) > 100 then return end end
	id.Select = sel
	id.SelectedCategory = selcat
	id:CreateWeapon(sel,ply)
end)

net.Receive("vend.sync",function(len,ply)
	local ent = net.ReadEntity()
	local cat = net.ReadTable()
	local items = net.ReadTable()
	if ent:CPPIGetOwner() == ply then
		ent.Categories = cat
		ent.itemList = items
		net.Start("vend.sync")
		net.WriteEntity(ent)
		net.WriteTable(cat)
		net.WriteTable(items)
		net.Broadcast()
	end
end)

ENT.Once = false
function ENT:Use( ply, activator )
	self.Once = true


end

function ENT:CreateWeapon(select,ply)
	if self.Spawning == true then return end
	self.Once = false
	local ic = 0
	local item = nil
	local CanAfford = true
	local snd_override = false
	local pos, ang = LocalToWorld( Vector( 100, 100, 100 ), Angle( -120, -130, 0 ), self:GetPos(), self:GetAngles() )

	item = self.itemList[self.SelectedCategory][self.Select]
	if ply.canAfford ~= nil then
		CanAfford = ply:canAfford(item.Price)
	end
	if CanAfford then
		if ply.addMoney ~= nil then
			ply:addMoney(-item.Price)
		end
		item.c_check = CompileString(item.CLua,"vend.check",false)
		local class = item.ClassID
		local it = item
		item = nil
		item = ents.Create(class)
		VSHARE.ply = ply
		VSHARE.self = self
		VSHARE.time = CurTime()+0.01
		VSHARE.ent = item or nil
		VSHARE.item = it
		VSHARE.nosound = false
		local run = it.c_check()
		snd_override = VSHARE.nosound or false
		VS.Clear()
		if run == nil then run = true end
		if !run then
			if IsValid(item) then item:Remove() end
		end
	else
		item = nil
	end
	if !IsValid(item) then if !snd_override then self:EmitSound("buttons/combine_button_locked.wav",75,100) end return false end
	if snd_override == false then self:EmitSound("buttons/button3.wav",75,100) end
	self.Spawning = true
	local spawnPos = self:GetPos()+(self:GetAngles():Forward()*20)+(self:GetAngles():Up()*-20)

	item:SetPos(spawnPos)
	item:SetAngles(self:GetAngles())
	timer.Simple(2.35,function()
		if IsValid(item) then
			item:Spawn()
			itemPhysObj = item:GetPhysicsObject()
			itemPhysObj:ApplyForceCenter( Vector(math.random(0, 10), math.random(0, 10), math.random(0, 10)))
			item:Activate()
			self:EmitSound("doors/door1_stop.wav",75,100)
		end
		self.Spawning = false
	end)

	return true
end



function ENT:OnRemove()
	if not IsValid(self) then return end
end
