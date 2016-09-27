
ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Vending Machine"
ENT.Author = "Seris"
ENT.Category = "Seris"

ENT.Spawnable			= true
ENT.AdminOnly			= true
ENT.HOffset = 24.7
ENT.HMult = -2
ENT.Select = 0
ENT.CatSelect = 0
ENT.SelectedCategory = 1


ENT.Categories = {

}

ENT.itemList = {

}


function ENT:OnReloaded()
	print("vending machine reloaded")
end





if CLIENT then
	net.Receive("vend.sync",function(len)
		local ent = net.ReadEntity()
		local cat = net.ReadTable()
		local items = net.ReadTable()
		local persistant = net.ReadBool()
		ent.Categories = cat
		ent.itemList = items
		ent.perma = persistant or false
	end)
	net.Receive("vend.fullsync",function(len)
		local ent = net.ReadEntity()
		local data = net.ReadTable()
		ent.name = data.name
		ent.header = data.header
		ent.ccolor = data.ccolor
		ent.perma = data.persist
		ent.itemList = data.itemList
		ent.Categories = data.Categories
	end)
	surface.CreateFont( "vf_large", {
		font = "roboto",
		size = 128,
		weight = 1000,
		antialias = true,
		additive = false
	})
	surface.CreateFont( "vf_medium", {
		font = "roboto",
		size = 72,
		weight = 1000,
		antialias = true,
		additive = false
	})
	surface.CreateFont( "vf_small", {
		font = "roboto",
		size = 36,
		weight = 1000,
		antialias = true,
		additive = false
	})
	function ENT:Initialize()
		self.menu = 0
		self.catsel = 0
		self.header = "WELCOME HUMAN."
		self.conf = {}
		self.name = "no name"
		self.ccolor = Color(50,50,50,170)
		self.synced = false
	end
	function ENT:Draw()
		self:DrawModel()
		if LocalPlayer():GetPos():Distance(self:GetPos())>500 or sgui==nil then return end
		local buttons = {}
		local cp = Vector(0,0,0)
		local ang = self:GetAngles()
		local pos = self:GetPos() + self:GetForward()*22 + self:GetRight()*20 + self:GetUp()*25

		ang:RotateAroundAxis(ang:Right(),-90)
		ang:RotateAroundAxis(ang:Up(),90)
		cp = util.IntersectRayWithPlane(EyePos(),EyeAngles():Forward(),pos,ang:Up())
		if cp~=nil then
			cp = WorldToLocal(cp,EyeAngles(),pos,ang)
			cp = cp * 50
			cp.y = cp.y * - 1
		end
		//button generation
		if self.menu == 0 then
			if LocalPlayer():IsSuperAdmin() then
				sgui.AddButton("-Configure-","vf_medium",buttons,100,300,400,70,15,Color(255,0,0,200),Color(100,100,100,200),function(v) self:OpenConfiguration() end)
			end
			for k, v in pairs(self.Categories) do
				sgui.AddButton(v.CatName.." ("..#self.itemList[k]..")","vf_large",buttons,100,300+(k*130),1200,120,40,v.CatColor,Color(100,100,100,200),function(v) self.menu = 1 self.catsel = k end)
			end
		elseif self.menu == 1 then
			sgui.AddButton("Back","vf_medium",buttons,100,300,190,70,15,Color(0,0,0,200),Color(100,255,100,200),function(v) self.menu = 0 end)
			for k, v in pairs(self.itemList[self.catsel]) do
				sgui.AddButton("Buy","vf_medium",buttons,1110,300+(k*120),190,70,15,Color(0,0,0,200),Color(100,255,100,200),function(v) self:BuyItem(k,self.catsel) print("buying item "..k.." in category "..self.catsel) end)
			end
		elseif self.menu == 2 then
			sgui.AddButton("Back","vf_medium",buttons,100,300,190,70,15,Color(0,0,0,200),Color(100,255,100,200),function(v) self.menu = 0 end)
		end

		cam.Start3D2D(pos,ang,0.02)
			if !self.synced then
				net.Start("vend.fullsync")
				net.WriteEntity(self)
				net.SendToServer()
				self.synced = true
			end
			draw.RoundedBox(0,0,0,1600,2000,self.ccolor)
			surface.SetDrawColor(0,0,0,255)
			for i=1,5 do
				if self.ccolor.a == 0 then break end
				surface.DrawOutlinedRect(0-i,0-i,1600+(i*2),2000+(i*2))
			end
			--draw.BlurredRect(0,0,0,1600,2000,Color(0,0,0,200),0.2,0.2)
			draw.DrawText(self.header or "","vf_large",50,50,Color(255,255,255,255))
			if self.menu == 0 then
				draw.DrawText("Select A Category Below:","vf_medium",50,140,Color(255,255,255,255))
				for i=1,#self.Categories do
					--draw.RoundedBox(0,510,300+i*80,200,70,Color(0,0,0,200))
					--draw.DrawText(#self.itemList[i].." items","vf_small",515,305+i*80,Color(255,255,255,255))
				end
			elseif self.menu == 1 then
				draw.DrawText("Press 'Buy' on the item you would like to purchase","vf_medium",50,140,Color(255,255,255,255))
				for k, v in pairs(self.itemList[self.catsel]) do
					local c = Color(0,0,0,0)
					c.r = self.Categories[self.catsel].CatColor.r
					c.g = self.Categories[self.catsel].CatColor.g
					c.b = self.Categories[self.catsel].CatColor.b
					c.a = self.Categories[self.catsel].CatColor.a
					c.a = c.a/2
					draw.RoundedBox(0,100,300+(k*120),1000,70,v.col or c)
					c.a = c.a/2
					draw.RoundedBox(0,100,375+(k*120),1200,35,v.col or c)
					draw.DrawText(v.Name,"vf_medium",105,295+k*120,Color(255,255,255,255))
					draw.DrawText("$"..v.Price,"vf_medium",1090,305+k*120,Color(255,255,255,255),TEXT_ALIGN_RIGHT)
					draw.DrawText(v.Desc,"vf_small",105,375+k*120,Color(255,255,255,255))
					--draw.BlurredRect(0,100,300+(k*80),800,70,v.col or (self.Categories[self.catsel].CatColor),0.01,0.1)
				end
			elseif self.menu == 2 then
				for i=1,5 do
					draw.RoundedBox(0,100,300+(i*80),1000,70,Color(50,50,50,255))
				end
			end
			if cp~=nil then
				sgui.HandleButtons(cp,buttons,true)
			end
		cam.End3D2D()
	end



	function ENT:BuyItem(selection,category)
		net.Start("vend.buy")
		net.WriteEntity(self)
		net.WriteInt(selection,8)
		net.WriteInt(category,8)
		net.SendToServer()
	end

	function ENT:OpenConfiguration()
		net.Start("vend.fullsync")
		net.WriteEntity(self)
		net.SendToServer()
		local frame = vgui.Create("DFrame")
		local w = ScrW()
		local h = ScrH()
		local ent = self
		frame:SetTitle("Vending Machine Configuration Editor")
		frame:SetSize(ScrW()/2,ScrH()/2)
		frame:Center()
		frame:SetDraggable(true)
		frame:MakePopup()
		function frame:OnClose()
			net.Start("vend.sync")
			net.WriteEntity(ent)
			if ent.Categories ~= nil then
				net.WriteTable(ent.Categories)
			end
			if ent.itemList ~= nil then
				net.WriteTable(ent.itemList)
			end
			net.SendToServer()
		end
		function frame:Paint(x,y)
			--draw.RoundedBox(16,0,0,w,h,Color(0,75,75,200))
			draw.BlurredRect(0,0,0,w,h,Color(30,30,30,200),0.2,0.2)
		end
		local fw = frame:GetWide()
		local fh = frame:GetTall()
		local hint = vgui.Create("DLabel",frame)
			hint:SetPos(fw/2.5,fh/12)
			hint:SetText("To edit a value, click on the text to open an input box")
			hint:SizeToContents()
		local scr = vgui.Create("DScrollPanel",frame)
			scr:SetPos(fw/2.5,fh/9)
			scr:SetSize(fw/2,fh/1.3)
			function scr:Paint(w,h)
				draw.BlurredRect(0,0,0,w,h,Color(0,0,0,200),0.2,0.2)
				if self.settings then
					draw.RoundedBox(0,w*0.02,h*0.02,w*0.4,h*0.05,Color(25,25,25,200))
					draw.DrawText("Settings","DermaDefault",w*0.02,h*0.02,Color(255,255,255,255))
				end
			end
			function scr:LoadItems(i)
				self:Clear()
				self.settings = false
				local tmp = vgui.Create("DPanel",scr)
					local sw = scr:GetWide()
					local sh = scr:GetTall()
					tmp:Dock(TOP)
					tmp:SetSize(sw,sh/5)
					function tmp:Paint(w,h)
						draw.BlurredRect(0,0,0,w,h,Color(155,155,155,200),0.4,0.4)
					end
					tmp.tw = tmp:GetWide()
					tmp.th = tmp:GetTall()
					self:CreateValueEditor(tmp,0.025,0.1,i,ent.Categories[i],"CatName")
					tmp.add = vgui.Create("DButton",tmp)
						tmp.add:SetText("Create New Item")
						tmp.add:SetSize(tmp.tw/4,tmp.th/4)
						tmp.add:SetPos(tmp.tw*0.025,tmp.th*0.3)
						tmp.add.DoClick = function()
							table.insert(ent.itemList[i],1,{ClassID="classid",Name="name",Desc="description",Price=0,CLua="return"})
							self:LoadItems(i)
						end
					tmp.clear = vgui.Create("DButton",tmp)
						tmp.clear:SetText("Clear Items")
						tmp.clear:SetSize(tmp.tw/4,tmp.th/4)
						tmp.clear:SetPos(tmp.tw*0.025,tmp.th*0.6)
						tmp.clear.DoClick = function()
							ent.itemList[i]={}
							self:LoadItems(i)
						end
					tmp.color = vgui.Create("DButton",tmp)
						tmp.color:SetText("Change Color")
						tmp.color:SetSize(tmp.tw/4,tmp.th/4)
						tmp.color:SetPos(tmp.tw*0.285,tmp.th*0.3)
						tmp.color.DoClick = function()
							self:OpenColorPicker(tmp,i)
						end
				for k, v in pairs(ent.itemList[i]) do
					local tmp = vgui.Create("DPanel",scr)
					local sw = scr:GetWide()
					local sh = scr:GetTall()
					tmp:Dock(TOP)
					tmp:SetSize(sw,sh/5)
					function tmp:Paint(w,h)
						draw.BlurredRect(0,0,0,w,h,Color(105,105,105,200),0.7,0.7)
					end
					tmp.tw = tmp:GetWide()
					tmp.th = tmp:GetTall()
					/*
					tmp.isel = vgui.Create("DComboBox",tmp)
					tmp.isel:SetPos(tmp.tw*0.025,tmp.th*0.1)
					tmp.isel:SetSize(tmp.tw*0.4,tmp.th*0.25)
					tmp.isel:SetValue(ent.itemList[i][k].Name or "select an item")
					for k, v in pairs(CustomShipments) do
						tmp.isel:AddChoice(v.name)
					end
					tmp.isel.OnSelect = function(pan,index,value)
						ent.itemList[i][k].Name = CustomShipments[index].name
						ent.itemList[i][k].Price = CustomShipments[index].price / CustomShipments[index].amount
						ent.itemList[i][k].ClassID = CustomShipments[index].entity
						self:LoadItems(i)
					end
					*/
					self:CreateValueEditor(tmp,0.025,0.1,i,v,"Name")
					self:CreateValueEditor(tmp,0.025,0.25,i,v,"ClassID")
					self:CreateValueEditor(tmp,0.025,0.4,i,v,"Desc")
					self:CreateValueEditor(tmp,0.025,0.55,i,v,"Price",true)
					self:CreateValueEditor(tmp,0.025,0.7,i,v,"CLua",false)
					tmp.up = vgui.Create("DButton",tmp)
						tmp.up:SetPos(tmp.tw*0.85,tmp.tw*0.01)
						tmp.up:SetSize(tmp.tw*0.05,tmp.th*0.2)
						tmp.up:SetText("▲")
						tmp.up.DoClick = function()
							table.remove(ent.itemList[i],k)
							table.insert(ent.itemList[i],math.Clamp(k-1,1,999),v)
							self:LoadItems(i)
						end
					tmp.dw = vgui.Create("DButton",tmp)
						tmp.dw:SetPos(tmp.tw*0.8,tmp.tw*0.01)
						tmp.dw:SetSize(tmp.tw*0.05,tmp.th*0.2)
						tmp.dw:SetText("▼")
						tmp.dw.DoClick = function()
							table.remove(ent.itemList[i],k)
							table.insert(ent.itemList[i],math.Clamp(k+1,1,#ent.itemList[i]+1),v)
							self:LoadItems(i)
						end
					tmp.re = vgui.Create("DButton",tmp)
						tmp.re:SetPos(tmp.tw*0.9,tmp.tw*0.01)
						tmp.re:SetSize(tmp.tw*0.05,tmp.th*0.2)
						tmp.re:SetText("X")
						tmp.re.DoClick = function()
							table.remove(ent.itemList[i],k)
							self:LoadItems(i)
						end
				end
			end
			function scr:OpenColorPicker(panel,i)
				local tmp = vgui.Create("DFrame")
				tmp:SetTitle("Color Picker")
				tmp:SetSize(w/6,h/6)
				tmp:Center()
				tmp:SetDraggable(true)
				tmp:SetDeleteOnClose(true)
				tmp:MakePopup()
				tmp.c = vgui.Create("DColorMixer",tmp)
				tmp.c:Dock(FILL)
				tmp.c:SetPalette(false)
				tmp.c:SetAlphaBar(true)
				tmp.c:SetWangs(true)
				tmp.c:SetColor(ent.Categories[i].CatColor)
				function tmp:OnClose()
					ent.Categories[i].CatColor = tmp.c:GetColor()
				end
			end
			function scr:OpenModColorPicker(tbl,i)
				local tmp = vgui.Create("DFrame")
				tmp:SetTitle("Color Picker")
				tmp:SetSize(w/6,h/6)
				tmp:Center()
				tmp:SetDraggable(true)
				tmp:SetDeleteOnClose(true)
				tmp:MakePopup()
				tmp.c = vgui.Create("DColorMixer",tmp)
				tmp.c:Dock(FILL)
				tmp.c:SetPalette(false)
				tmp.c:SetAlphaBar(true)
				tmp.c:SetWangs(true)
				tmp.c:SetColor(tbl[i])
				function tmp:OnClose()
					tbl[i]=tmp.c:GetColor()
				end
			end
			function scr:CreateValueEditor(pan,x,y,i,v,vn,n)
				local tmp = pan
				tmp.n = vgui.Create("DLabel",tmp)
					if n ~= nil and n == false then
						tmp.n:SetText(vn..": (...)")
					else
						tmp.n:SetText(vn..": "..v[vn])
					end
					tmp.n:SetPos(tmp.tw*x,tmp.th*y)
					tmp.n:SizeToContents()
					tmp.n:SetMouseInputEnabled(true)
					tmp.n.DoClick = function()
						local inp = vgui.Create("DFrame")
						inp:SetTitle("Set "..vn..":")
						if n ~= nil and n == false then
							inp:SetSize(w/2,h/2)
						else
							inp:SetSize(w/3,h/14)
						end
						inp:Center()
						inp:SetDraggable(false)
						inp:SetDeleteOnClose(true)
						inp:MakePopup()
						local ib = vgui.Create("DTextEntry",inp)
						ib:Dock(FILL)
						ib:SetText(v[vn])
						if n ~= nil and n == false then
							ib:SetMultiline(true)
							ib:SetTabbingDisabled(true)
							inp.OnClose = function()
								if ib:GetText()~=nil then
									if n then
										v[vn] = tonumber(ib:GetText())
									else
										v[vn] = ib:GetText()
									end
								end
								if i ~= -1 then
									self:LoadItems(i)
								else
									self:Clear()
									self:LoadSettings()
								end
							end
						else
							ib.OnEnter = function()
								if ib:GetText()~=nil then
									if n then
										v[vn] = tonumber(ib:GetText())
									else
										v[vn] = ib:GetText()
									end
								end
								if i ~= -1 then
									self:LoadItems(i)
								else
									self:Clear()
									self:LoadSettings()
								end
								inp:Close()
							end
						end
					end
			end

			function scr:LoadSettings()
				scr.tw = scr:GetWide()
				scr.th = scr:GetTall()
				scr.settings = true
				self:CreateValueEditor(scr,0.025,0.1,-1,ent,"name")
				self:CreateValueEditor(scr,0.025,0.15,-1,ent,"header")
				local tmp = {}
				tmp.color = vgui.Create("DButton",self)
					tmp.color:SetText("Screen Color")
					tmp.color:SetPos(scr.tw*0.025,scr.th*0.2)
					tmp.color:SetSize(scr.tw*0.25,scr.th*0.05)
					tmp.color.DoClick = function()
						self:OpenModColorPicker(ent,"ccolor")
					end
				if !ent.perma then
					local makeperma = vgui.Create("DButton",self)
					makeperma:SetText("Persist on Reboot")
					makeperma:SetPos(scr.tw*0.025,scr.th*0.25)
					makeperma:SetSize(scr.tw*0.25,scr.th*0.05)
					makeperma.DoClick = function()
						net.Start("vend.persist")
						net.WriteEntity(ent)
						net.WriteTable({name=ent.name,header=ent.header,itemList=ent.itemList,Categories=ent.Categories,ccolor=ent.ccolor})
						net.SendToServer()
					end
				else
					local makeperma = vgui.Create("DButton",self)
					makeperma:SetText("Disable Persistance")
					makeperma:SetPos(scr.tw*0.025,scr.th*0.25)
					makeperma:SetSize(scr.tw*0.25,scr.th*0.05)
					makeperma.DoClick = function()
						net.Start("vend.nopersist")
						net.WriteEntity(ent)
						net.WriteString(ent.name)
						net.SendToServer()
					end
					local sync = vgui.Create("DButton",self)
					sync:SetText("Sync Changes To Server")
					sync:SetPos(scr.tw*0.025,scr.th*0.3)
					sync:SetSize(scr.tw*0.33,scr.th*0.05)
					sync.DoClick = function()
						net.Start("vend.update")
						net.WriteEntity(ent)
						net.WriteTable({name=ent.name,header=ent.header,itemList=ent.itemList,Categories=ent.Categories,ccolor=ent.ccolor})
						net.SendToServer()
					end
				end
			end
		local catlist = vgui.Create("DListView",frame)
			catlist:SetMultiSelect(false)
			catlist:SetPos(fw/20,fh/9)
			catlist:SetSize(fw/3,fh/1.3)
			catlist:AddColumn("Categories")
			catlist:AddColumn("Items")
			catlist:SetSortable(false)
			for k, v in pairs(self.Categories) do
				catlist:AddLine(v.CatName,#self.itemList[k])
			end
			function catlist:OnRowSelected(i,row)
				scr:LoadItems(i)
			end

		local add = vgui.Create("DButton",frame)
			add:SetSize(fw/10,fh/20)
			add:SetPos(fw/20,fh/16)
			add:SetText("new")
			add.DoClick = function()
				local inp = vgui.Create("DFrame")
				inp:SetTitle("Enter category name:")
				inp:SetSize(w/4,h/18)
				inp:Center()
				inp:SetDraggable(false)
				inp:SetDeleteOnClose(true)
				inp:MakePopup()
				local ib = vgui.Create("DTextEntry",inp)
				ib:Dock(FILL)
				ib:SetText("Category")
				ib.OnEnter = function()
					if ib:GetText()~=nil then
						table.insert(self.Categories,#self.Categories+1,{CatName=ib:GetText(),CatColor=Color(50,50,50,200)})
						table.insert(self.itemList,#self.itemList+1,{})
						catlist:AddLine(ib:GetText(),0)
					end
					inp:Close()
				end
			end
		local rem = vgui.Create("DButton",frame)
			rem:SetSize(fw/10,fh/20)
			rem:SetPos(fw/6.5,fh/16)
			rem:SetText("delete")
			rem.DoClick = function()
				local i = catlist:GetSelectedLine() or 0
				if i == 0 then return end
				catlist:RemoveLine(i)
				table.remove(self.Categories,i)
				table.remove(self.itemList,i)
				catlist:Clear()
				scr:Clear()
				for k, v in pairs(self.Categories) do
					catlist:AddLine(v.CatName,#self.itemList[k])
				end
			end
		local makeperma = vgui.Create("DButton",frame)
			makeperma:SetSize(fw/10,fh/20)
			makeperma:SetPos(fw/3.9,fh/16)
			makeperma:SetText("Settings")
			makeperma.DoClick = function()
				scr:Clear()
				scr:LoadSettings()
			end
	end
end
