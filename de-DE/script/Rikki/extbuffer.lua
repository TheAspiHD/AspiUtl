extbuffer = extbuffer or {}


require("extbuffer_core")
local floor = math.floor
local extbuffer_core_type = extbuffer.core.type
local extbuffer_core_freeid = extbuffer.core.freeid
local extbuffer_core_write = extbuffer.core.write
local extbuffer_core_size = extbuffer.core.size
local extbuffer_core_read = extbuffer.core.read
local extbuffer_core_read2 = extbuffer.core.read2
local extbuffer_core_clear = extbuffer.core.clear
local extbuffer_core_mix = extbuffer.core.mix
local extbuffer_core_getpixel = extbuffer.core.getpixel
local extbuffer_core_fwrite = extbuffer.core.fwrite


local function normalize_id(id)
	local id = id or ""
	if(extbuffer_core_type(id) == "number")then
		return floor(id)
	else
		return id
	end
end

local function is_userdata(userdata)
	local good = (extbuffer_core_type(userdata) == "userdata")
	if(not good)then
		debug_print("invalid userdata")
	end
	return good
end


extbuffer.freeid = function()
	return extbuffer_core_freeid()
end

extbuffer.write = function(id)
	local id = normalize_id(id)
	extbuffer_core_write(id, obj.getpixeldata())
end

extbuffer.write2 = function(id, userdata, w, h)
	if(not is_userdata(userdata))then
		return
	end

	local id = normalize_id(id)
	extbuffer_core_write(id, userdata, w, h)
end

extbuffer.size = function(id)
	local id = normalize_id(id)
	return extbuffer_core_size(id)
end

extbuffer.read = function(id)
	local id = normalize_id(id)

	local w1, h1 = extbuffer_core_size(id)
	local w2, h2 = obj.getpixel()
	
	--resize
	--avoid overflowing virtual buffer
	if(h1 > h2 or w1 > w2)then
		if(h1 == obj.screen_h and w1 == obj.screen_w)then
			obj.load("framebuffer")
		else
			obj.load("figure", "Square", 0, math.max(w1, h1))
			w2, h2 = obj.getpixel()
			local ue = floor((h2 - h1) * 0.5)
			local shita = (h2 - h1) - ue
			local hidari = floor((w2 - w1) * 0.5)
			local migi = (w2 - w1) - hidari
			obj.effect("Clipping", "Top", ue, "Bottom", shita, "Left", hidari, "Right", migi)
		end
	elseif(h1 < h2 or w1 < w2)then
		local ue = floor((h2 - h1) * 0.5)
		local shita = (h2 - h1) - ue
		local hidari = floor((w2 - w1) * 0.5)
		local migi = (w2 - w1) - hidari
		obj.effect("Clipping", "Top", ue, "Bottom", shita, "Left", hidari, "Right", migi)
	end

	local userdata = obj.getpixeldata()
	extbuffer_core_read(id, userdata)
	obj.putpixeldata(userdata)
end

extbuffer.read2 = function(id)
	local id = normalize_id(id)

	
	--return userdata, w, h
	return extbuffer_core_read2(id)
end

extbuffer.clear = function(id)
	local id = normalize_id(id)
	extbuffer_core_clear(id)
end

extbuffer.swap = function(userdata, w, h)
	if(not is_userdata(userdata))then
		return
	end

	local id1 = extbuffer.freeid()
	extbuffer.write(id1)
	local id2 = extbuffer.freeid()
	extbuffer.write2(id2, userdata, w, h)

	extbuffer.read(id2)
	userdata, w, h = extbuffer.read2(id1)

	extbuffer.clear(id1)
	extbuffer.clear(id2)
end

extbuffer.mix = function(id, userdata, w, h, command)
	if(not is_userdata(userdata))then
		return
	end

	local id = normalize_id(id)
	extbuffer_core_mix(id, userdata, w, h, command)
end

extbuffer.getpixel = function(id, x, y)
	local id = normalize_id(id)
	return extbuffer_core_getpixel(id, x, y)
end

extbuffer.fwrite = function(filename, userdata, w, h)
	if(not is_userdata(userdata))then
		return
	end

	return extbuffer_core_fwrite(filename, userdata, w, h)
end


