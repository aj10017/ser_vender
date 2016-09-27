
local Pressed = false
local Dragging = false
local scrolltxt = {}
print("LOADED 3D2D GUI LIBRARY")
print("Version 1.3.3-4.25.16")

sgui = {}
sgui.version = "1.3.3-4.25.16"
sgui.CursorWithinBounds = function (vec,x1,y1,x2,y2)
	if vec.x > x1 and vec.x < x2 and vec.y > y1 and vec.y < y2 then
		return true
	else
		return false
	end
end

sgui.AddButton = function (txt,font,tbl,x,y,w,h,pc,cmin,cmax,callback,tooltip,clk,rolcall)
	local btn = {}
	btn.text = txt or "nil"
	btn.font = font or "DermaDefault"
	btn.x = x or 0
	btn.y = y or 0
	btn.w = w or 0
	btn.h = h or 0
	btn.pc = pc
	btn.cmin = cmin or Color(0,0,0,0)
	btn.cmax = cmax or Color(255,255,255,255)
	btn.c = cmin
	btn.callback = callback
	btn.pressed = false
	btn.key = IN_USE
	btn.reclick = clk or 1
	btn.rolcall = rolcall or function() end
	btn.hover = false
	if tooltip~=nil then btn.tooltip = tooltip end
	table.insert(tbl,#tbl+1,btn)
	return tbl
end

sgui.HandleButtons = function (vec,table,altinput)
	Dragging = input.IsMouseDown(107)
	for k, v in pairs(table) do
		if v ~= nil then
			--if isfunction(v.think) then v.think() end
			if v.hold == nil then v.hold = CurTime()+5 end
			if v.rolcall == nil then v.rolcall = function() end end
			if v.hover == nil then v.hover = false end

			if sgui.CursorWithinBounds(vec,v.x,v.y,v.x+v.w,v.y+v.h) then
				v.c = v.cmax
				sgui.DrawToolTip(vec,v)
				if !v.hover then
					v.hover = true
					v.rolcall(v)
				end
			else
				v.c = v.cmin
				v.hover = false
			end
			sgui.DrawButtons(v)
			if altinput==nil then
				if v.c == v.cmax and Pressed == false and Dragging == true then
					Pressed = true
					v.hold = CurTime()+v.reclick
					v.callback(v)
				end
				if v.c == v.cmax and Dragging and Pressed and v.hold < CurTime() then
					v.callback(v)
					v.hold = CurTime()+0.1
				end
				if Pressed == true and Dragging == false then
					Pressed = false
					v.hold = CurTime()+1
				end
			elseif altinput==true then
				if v.c == v.cmax and !Pressed and LocalPlayer():KeyDown(v.key) then
					Pressed = true
					v.callback(v)
				end
				if Pressed == true and !LocalPlayer():KeyDown(v.key) then
					Pressed = false
				end
			end
		end
	end
	for k, v in pairs(table) do
		if v~=nil then
			if sgui.CursorWithinBounds(vec,v.x,v.y,v.x+v.w,v.y+v.h) then
				--v.c = v.cmax
				sgui.DrawToolTip(vec,v)
			end
		end
	end
end
sgui.DrawButtons = function (tbl)
	draw.RoundedBox(0,tbl.x,tbl.y,tbl.w,tbl.h,tbl.c)
	draw.DrawText(tbl.text,tbl.font,tbl.x+(tbl.w/2),tbl.y+(tbl.h/(4))-tbl.pc,Color(255,255,255,255),TEXT_ALIGN_CENTER)
end

sgui.DrawToolTip = function (vec,v)
	local txt = v.tooltip
	if txt~=nil then
		draw.RoundedBox(0,vec.x+20,vec.y,string.len(txt)*8,20,Color(25,25,25,230))
		draw.DrawText(txt,"ButtonFontMedium",vec.x+22,vec.y+2,Color(255,255,255,255))
	end
end



//blurred rects
local function definecanvas(ref)
	render.ClearStencil()
	render.SetStencilEnable(true)
	render.SetStencilCompareFunction(STENCIL_ALWAYS)
	render.SetStencilPassOperation(STENCIL_REPLACE)
	render.SetStencilFailOperation(STENCIL_KEEP)
	render.SetStencilZFailOperation(STENCIL_KEEP)
	render.SetStencilWriteMask(253)
	render.SetStencilTestMask(253)
	render.SetStencilReferenceValue(ref or 43)
end

local function drawon()
	render.SetStencilCompareFunction(STENCIL_EQUAL)
end

local function stopcanvas()
	render.SetStencilEnable(false)
end

local blur = Material("pp/blurscreen")



draw.BlurredRect = function(r,x,y,w,h,c,p,a)
	definecanvas(322)
	draw.RoundedBox(r,x,y,w,h,c)
	drawon()
	--drawBlurredRectangle(-400,0,800,80,5,5)
	render.SetMaterial(blur)

	for i = p, 1, a do
		blur:SetFloat("$blur", i * 5)
		blur:Recompute()
		render.UpdateScreenEffectTexture()
		render.DrawScreenQuad()
	end
	stopcanvas()
end
