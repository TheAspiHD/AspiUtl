local DEBUG = false
local E = require("easing")
-- ft_user�͌Ăяo������E.ft�Ƃ��Ď擾�\�ɂ���
-- �󂯂��ϐ��i���݂�E�j��ft�ɃC�[�W���O�֐���ǉ�����Ύ��R�ɃC�[�W���O��ǉ��ł���͂�
-- easing.lua�ɏ����ꂽ�悤�Ȍ`���Œl��Ԃ��֐���n���Ύ��O�̃C�[�W���O���o�^�\
local ft_user = {}
local ft_detarame = {
	E.linear				,--  1
	E.inQuad				,--  2
	E.outQuad				,--  3
	E.inOutQuad				,--  4
	E.outInQuad				,--  5
	E.inCubic 				,--  6
	E.outCubic				,--  7
	E.inOutCubic			,--  8
	E.outInCubic			,--  9
	E.inQuart				,-- 10
	E.outQuart				,-- 11
	E.inOutQuart			,-- 12
	E.outInQuart			,-- 13
	E.inQuint				,-- 14
	E.outQuint				,-- 15
	E.inOutQuint			,-- 16
	E.outInQuint			,-- 17
	E.inSine				,-- 18
	E.outSine				,-- 19
	E.inOutSine				,-- 20
	E.outInSine				,-- 21
	E.inExpo				,-- 22
	E.outExpo				,-- 23
	E.inOutExpo				,-- 24
	E.outInExpo				,-- 25
	E.inCirc				,-- 26
	E.outCirc				,-- 27
	E.inOutCirc				,-- 28
	E.outInCirc				,-- 29
	E.inElastic				,-- 30
	E.outElastic			,-- 31
	E.inOutElastic			,-- 32
	E.outInElastic			,-- 33
	E.inBack				,-- 34
	E.outBack				,-- 35
	E.inOutBack				,-- 36
	E.outInBack				,-- 37
	E.inBounce				,-- 38
	E.outBounce				,-- 39
	E.inOutBounce			,-- 40
	E.outInBounce			,-- 41
}
local ft_original = {
	E.linear				,--  1
	E.inSine				,--  2
	E.outSine				,--  3
	E.inOutSine				,--  4
	E.outInSine				,--  5
	E.inQuad				,--  6
	E.outQuad				,--  7
	E.inOutQuad				,--  8
	E.outInQuad				,--  9
	E.inCubic 				,-- 10
	E.outCubic				,-- 11
	E.inOutCubic			,-- 12
	E.outInCubic			,-- 13
	E.inQuart				,-- 14
	E.outQuart				,-- 15
	E.inOutQuart			,-- 16
	E.outInQuart			,-- 17
	E.inQuint				,-- 18
	E.outQuint				,-- 19
	E.inOutQuint			,-- 20
	E.outInQuint			,-- 21
	E.inExpo				,-- 22
	E.outExpo				,-- 23
	E.inOutExpo				,-- 24
	E.outInExpo				,-- 25
	E.inCirc				,-- 26
	E.outCirc				,-- 27
	E.inOutCirc				,-- 28
	E.outInCirc				,-- 29
	E.inElastic				,-- 30
	E.outElastic			,-- 31
	E.inOutElastic			,-- 32
	E.outInElastic			,-- 33
	E.inBack				,-- 34
	E.outBack				,-- 35
	E.inOutBack				,-- 36
	E.outInBack				,-- 37
	E.inBounce				,-- 38
	E.outBounce				,-- 39
	E.inOutBounce			,-- 40
	E.outInBounce			,-- 41
}

--�䂤������̂�����
local type = function(v)
	local v = v
	local s = tostring(v)
	if(s == v)then return "string" end
	if(s == "nil")then return "nil" end
	if(s == "true" or s == "false")then return "boolean" end
	if(string.find(s, "table:"))then return "table" end
	if(string.find(s, "function:"))then return "function" end
	if(string.find(s, "userdata:"))then return "userdata" end
	--add
	if(string.find(s, "file %("))then return "function" end	--io.stderr
	return "number"
end

local number_type = function(v)
	local val
	if( v ~= v ) then
		val = "0/0"
	elseif( v == 1/0 ) then
		val = "1/0"
	elseif( v == -1/0 ) then
		val = "-1/0"
	elseif( v == math.floor(v) ) then
		val = tostring(v)
	elseif( type(v) == "number" ) then
		val = string.format("%.14f",v)
	else
		val = v
	end
	return val
end

local function require_extram()
	local cpath = package.cpath
	local Extram
	package.cpath = package.cpath..";"..obj.getinfo"script_path":gsub("[^\\]+\\$","?.dll")
	if( pcall(require, "Extram") ) then
		-- oov����
		Extram = require("Extram")
	end
	package.cpath = cpath
	return Extram
end

local function require_prtrdump()
	local Prtrdump
	if( pcall(require, "dump") ) then
		-- Jerome Vuarand����
		Prtrdump = require("dump")
	end
	return Prtrdump
end

local function extram_get(key)
	local data
	if( pcall(Extram.get, key) ) then
		data = Extram.get(key)
	end
	return data
end

local function dump(...)
	if(DEBUG) then
		local Prtrdump = require_prtrdump()
		if( Prtrdump ) then
			local str, error = Prtrdump.tostring(...)
			if( error ) then
				debug_print(error)
			else
				debug_print(str or "nil")
			end
		end
	end
end

local function easing_core(et, t, b, c, d, s, a, p)
	--0�Ԃ̂Ƃ��͏�ɍŏI�l��Ԃ��Ƃ���
	if( et == 0 ) then
		return c
	end
	
	local ft = ft_detarame
	local r
	local reverse_t = false
	local reverse_r = false
	
	if( et < 0 ) then
		et = -et
		ft = ft_original
		--reverse_t = true
		--reverse_r = true
	end
	if( ft_user[et] ~= nil ) then
		ft = ft_user
	end
	
	if( reverse_t ) then
		--���Ԏ��𔽓]
		t = d-t
	end
	
	if( et >= 30 and et <= 33 ) then
		if( a ~= nil ) then
			a = a + c
		end
		r = ft[et](t,b,c,d,a,p)
	else
		r = ft[et](t,b,c,d,s)
	end
	
	-- �l�𔽓]
	if( reverse_r ) then
		r = b*2 + c - r
	end
	
	-- �Ȃ�-1.#IND�ŕԂ��Ă���ꍇ������悤�Ȃ̂Ń`�F�b�N
	-- Lua�ɂ�����NaN�̂��ƂŁA��������Ĕ��肷��炵���H
	if( r~=r ) then
		-- NaN�Ȃ�A�Ƃ肠���������l��Ԃ�
		return b
	else
		return r
	end
end

local function analyze_fusion(et)
	local _et,et1,et2,ratio_f
	local et_abs = math.abs(et)
	if( et_abs <= 99 ) then
		return et, nil, nil
	elseif( et_abs >= 100000 ) then
		-- 6���ȏ�@����1 ����2 ����
		_et = string.format("%07d",et_abs)
	elseif( et_abs >= 1000 ) then
		-- 4���ȏ�@����1(01�Œ�) ����2 ����
		_et = string.format("01%05d",et_abs)
	end
	et1 = tonumber(string.sub(_et,1,2))
	et2 = tonumber(string.sub(_et,3,4))
	if( et < 0 ) then
		et1 = -et1
		et2 = -et2
	end
	ratio_f = tonumber(string.sub(_et,5))
	
	return et1, et2, ratio_f
end

local function easing(et, t, b, c, d, s, a, p)
	if( math.abs(et) <= 99 ) then
		-- �ʏ�C�[�W���O
		return easing_core(et, t, b, c, d, s, a, p)
	else
		local et1,et2,ratio_f = analyze_fusion(et)
--dump({str=_et,et1=et1,et2=et2,ratio=ratio_f})
		local r1 = easing_core(et1, t, b, c, d, s, a, p)
		local r2 = easing_core(et2, t, b, c, d, s, a, p)
		local r = r1+(r2-r1)/100*ratio_f
		return r
	end
end

local get_section = function(g, target_list)
	if( g == nil ) then
		g = {}
	end
	
	local num = obj.getoption("section_num")+1
	
	g.time_list = {}
	for i=1,num-1 do
		g.time_list[i] = obj.getvalue("time",0,i)
	end
	g.time_list[#g.time_list+1] = g.time_list[#g.time_list]
	
	g.v_list = {}
	for n,v in pairs(target_list) do
		g.v_list[v] = {}
		for i=1,num do
			g.v_list[v][i] = obj.getvalue(v, 0, i-1)
		end
		g.v_list[v][#g.v_list[v]+1] = g.v_list[v][#g.v_list[v]]
	end
	
	return g
end

local get_trackbar_section = function(g)
	if( g == nil ) then
		g = {
			param_list = {},
			v_list = {},
		}
	end
	
	local link_index,link_num = obj.getpoint("link")
	local num = obj.getpoint("num")
	
	g.param_list[link_index+1] = obj.getpoint("param")
	
	g.time_list = {}
	for i=1,num-1 do
		g.time_list[i] = obj.getpoint("time",i)
	end
	g.time_list[#g.time_list+1] = g.time_list[#g.time_list]
	
	g.v_list[link_index+1] = {}
	for i=1,num do
		g.v_list[link_index+1][i] = obj.getpoint(i-1)
	end
	local n = #g.v_list[link_index+1]
	g.v_list[link_index+1][n+1] = g.v_list[link_index+1][n]
	
	return g
end

local get_index = function(time, time_list)
	local _time = 0
	for i=1,#time_list do
		if( time_list[i] > time ) then
			return i-1, (time-_time)/(time_list[i]-_time)
		end
		_time = time_list[i]
	end
	if( time_list[#time_list] == time_list[#time_list-1] ) then
		return #time_list-1, 0
	else
		return #time_list, 0
	end
end

local adjust_index_last_frame = function(index, ratio, frame, totalframe)
	--get_index��getpoint("index")�Ɠ������ʂɂȂ�悤�������肾���A
	--���̂܂܂��ƍŏIf�Ŏ���index�ƂȂ��Ďg���Â炢�̂Œ�������
	if(totalframe == frame) then
		--�����炭�ŏIf�ɂ���̂őO��index��ratio=1�Ƃ���
		index = index - 1
		ratio = 1
	end
	
	return index, ratio
end

local to_frame = function(time, fps)
	return math.floor(time*fps+0.5)
end

local calc_section_time_list = function(time_list)
	local section_time_list = {}
	for n=1, #time_list do
		local time0 = time_list[n-1] or 0
		local time1 = time_list[n]
		section_time_list[n] = time1-time0
	end
	return section_time_list
end

local calc_step_time_list = function(time_list)
	local total_time_list = {}
	for n=1, #time_list do
		local time0 = total_time_list[n-1] or 0
		total_time_list[n] = time_list[n]+time0
	end
	return total_time_list
end

local function clone(t)
	if( t == nil ) then
		return nil
	end
	
	local _t = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			_t[k] = clone(v)
		else
			_t[k] = v
		end
	end
	return _t
end

--�z�Q�Ƃ͍l�����Ă��Ȃ��̂Œ���
local function has_changed(t1, t2)
	for k, v in pairs(t1) do
		if type(v) == "table" then
			if type(t2[k]) == "table" then
				if( has_changed(v, t2[k]) == true ) then
					-- �e�[�u���̒��g�ňႢ���������̂Ŕ�����
					return true
				end
			else
				return true -- �Е��e�[�u���ŕЕ��e�[�u���łȂ������̂Ŕ�����
			end
		else
			if( number_type(t1[k]) ~= number_type(t2[k]) ) then
				return true	--�Ⴄ���̂������������_�Ŕ�����
			end
		end
	end
	-- �ǂ���Ⴂ���Ȃ�����
	return false
end

local function serialize(t, indent_num, refs)
	if( t == nil ) then
		return "nil"
	end
	indent_num = indent_num or 1
	refs = refs or {}
	
	local s = ""
	local indent = string.rep(" ",indent_num)
	for k, v in pairs(t) do
		local key = (type(k) == "number") and "["..k.."]" or k
		if( type(v) == "table" ) then
			if( refs[ tostring(v) ] ) then
			else
				refs[ tostring(v) ] = tostring(t)
				s = s .. indent .. key .. " = {\n"
				s = s .. serialize(v, indent_num+1, refs)
				s = s .. indent .. "},\n"
			end
		elseif( type(v) == "number" ) then
			local val = number_type(v)
			s = s .. indent .. key .. " = " .. val ..",\n"
		elseif( type(v) == "function" or type(v) == "userdata" ) then
			s = s .. indent .. key .. " = " .. type(v) ..",\n"
		else
			s = s .. indent .. key .. " = " .. tostring(v) .. ",\n"
		end
	end
	return s
end

local function get_extram_data(layer)
	local data = {
		params = {}
	}
	local Extram = require_extram()
	if( Extram ) then
		local str = extram_get('g_uf_easing')
		
		if( str ~= nil ) then
--debug_print(str)
			data = loadstring("return "..str)()
			data = data[layer]
		end
dump("extram read num:"..#data.params)
	end
	return data
end

local function set_extram_data(layer, d)
	local Extram = require_extram()
	if( Extram ) then
		local data = extram_get('g_uf_easing')
		if( data == nil ) then
			data = {}
		else
			data = loadstring("return "..data)()
		end
		data[layer] = clone(d)
		local str = "{\n"..serialize(data).."}"
--debug_print(str)
		--local data2 = loadstring("return "..str)()
dump("extram write num:"..#d.params)
		Extram.put("g_uf_easing", str)
	end
end

return {
	-- �󂯂��ϐ�(���݂�E).easing()��AVIUTL������A�ŗL�������΂��Ē��ڏ�̊֐����Ăׂ�悤�ɂ���
	easing = easing,
	
	-- ft��Ԃ�
	ft = ft_user,
	
	-- �C�[�W���O�̌���Ԃ�
	get_easing_length = function()
		return #ft_original
	end,
	
	-- �L���ȃC�[�W���O�^�C�v���ǂ���
	is_easing_type = function(et)
		return (et>=1 and et<=#ft_original)
	end,
	
	-- �f�o�b�O�\���p
	dump = dump,
	serialize = serialize,
	
	-- �g���b�N�o�[�Ή���"�ł͂Ȃ�"�C�[�W���O����
	-- dialog:�ɃO���[�o���ϐ��g���Ă�̂���߂������A��������ƕʕϐ������ƂȂ�
	-- �ߋ��̃v���W�F�N�g�Ńp�����[�^�������Đݒ肵�����ɂȂ�悤�Ȃ̂ŁA���̂܂�
	-- E.LEN�͗��΂Ɏg���Ă�l���Ȃ��i����J�@�\�����j���낤����폜
	easing_aviutl = function()
		local i = (interval == nil) and 0 or (interval * obj.framerate / 1000)
		local d = obj.totalframe - (obj.num-1)*i
		local c = obj.track2-obj.track1
		local t = math.min(math.max(0,obj.frame - obj.index*i),d)
		local s = es
		local a = ea
		local p = ep
		
		if( disable and ((t/d)*100 < disable) ) then
			--������
			return 0
		end
		
		if( d <= 0 ) then
			if( obj.index == 0 ) then
				debug_print(string.format("layer%d:%s %d�t���[������܂���",obj.layer,obj.getoption("script_name"),-d+1))
			end
			return 0
		end
		
		if( obj.track3>=0 ) then
			-- �i��%�ƃC���^�[�o���̓������p�͂悭�킩��Ȃ��̂Œ��߂�
			t = d * obj.track3 / 100
		end
		
		return easing(obj.track0,t,obj.track1,c,d,s,a,p)
	end,
	
	analyze_fusion = analyze_fusion,
	
	get_section = get_section,
	
	get_trackbar_section = get_trackbar_section,
	
	get_index = get_index,

	adjust_index_last_frame = adjust_index_last_frame,
	
	to_frame = to_frame,
	
	calc_section_time_list = calc_section_time_list,
	
	clone = clone,
	
	has_changed = has_changed,
	
	--����g���^����ꂽ�猋�ʂ͓����Ȃ̂Ŗ��t���[���i���W���ŋO�Օ\��������X�Ɂj�����Ă�̂����ʂŁA�ǂ��ɂ�������
	--tra���łǂ̃p�����[�^����Ăяo���ꂽ���̏�񂪎���΁A�p�����[�^���ɃO���[�o���ϐ��Ɏc���Ă�����̂���
	easing_concat = function(link_index, g, extram_layer)
		local data = {
			params = {},
			enable_et_list = {},
			enable_cp_list = {},
			enable_br_list = {},
			enable_bn_list = {},
			enable_v_list = {},
			enable_time_list = {},
			enable_step_time_list = {},
			time_list = {},
			step_time_list = {},
		}
		local params = {}

		--�C�[�W���O�֐������b�v���Ĕ����֌W������������ŕԂ�
		local easing = function(et, t, b, c, d, br, bn)
			br = br or 0
			bn = bn or 3
			
			local r
			if( math.abs(et) >= 38 and math.abs(et) <= 41 ) then
				local l = {}
				local bs,be = 1, bn+1
				for n=bs,be+1 do
					l[n] = 3-(1/2)^(n-2)
				end
				l[0] = -1
				local bound_coef = math.pow(l[be], 2)
				local outBounce = function(t, b, c, d)
					t = t / d
					for n=bs,be do
						if ( n==be ) or (t < l[n] / l[be]) then
							local h = (l[n-1] + l[n])/2
							local u = 1 - math.pow(1/2,n-1)^(2)
							t = t - ( h / l[be])
							if( n > 1 ) then
								local y = (bound_coef * t * t + u)
								return c * math.min(1, y - (1-y)*(br/100*(n-1))) + b
							else
								return c * (bound_coef * t * t + u) + b
							end
						end
					end
				end
				
				local inBounce = function(t, b, c, d)
					return c - outBounce(d - t, 0, c, d) + b
				end
				
				local function inOutBounce(t, b, c, d)
					if t < d / 2 then
						return inBounce(t * 2, 0, c, d) * 0.5 + b
					else
						return outBounce(t * 2 - d, 0, c, d) * 0.5 + c * .5 + b
					end
				end

				local function outInBounce(t, b, c, d)
					if t < d / 2 then
						return outBounce(t * 2, b, c / 2, d)
				 	else
						return inBounce((t * 2) - d, b + c / 2, c / 2, d)
					end
				end
				
				--�O�̃C�[�W���O�֐�����U�ޔ�
				local _ft_detarame = {}
				local _ft_original = {}
				for n=1,4 do
					_ft_detarame[n] = ft_detarame[38+n-1]
					_ft_original[n] = ft_original[38+n-1]
				end
				--�����֘A�����X�V�����֐���n��
				ft_detarame[38] = inBounce
				ft_detarame[39] = outBounce
				ft_detarame[40] = inOutBounce
				ft_detarame[41] = outInBounce
				ft_original[38] = inBounce
				ft_original[39] = outBounce
				ft_original[40] = inOutBounce
				ft_original[41] = outInBounce
				--�C�[�W���O���s
				r = easing(et, t, b, c, d)
				--�g���I������̂ł��Ƃɖ߂�
				for n=1,4 do
					ft_detarame[38+n-1] = _ft_detarame[n]
					ft_original[38+n-1] = _ft_original[n]
				end
			else
				--�����֌W�Ȃ��C�[�W���O�Ȃ̂ł��̂܂܎��s
				r = easing(et, t, b, c, d)
			end
			return r
		end

		local list_slice = function(index, all_list, num, default)
			local list = {}
			for i=1,num do
				local value = (all_list[index+i-1] == nil) and default or all_list[index+i-1]
				list[i] = ( index == 0 and i==1 ) and (0/0) or (value)
			end
			return list
		end
		
		local get_union_list_A = function(all_list, un_list, enable_type)
			local list = {}
			for i,v in ipairs(all_list) do
				if( i>1 and un_list[i] == 1 ) then
					-- ������Ԃ������ꍇ�A�e�폈���i�������A�ŏ��̋�Ԃ͕K���������Ȃ��j
					if( enable_type == "time" ) then
						--���ԂȂ�Ό�����Ԃ̒l���Ō�ɗL����������Ԃɉ��Z
						list[#list] = list[#list] + v
					else
						--����ȊO�Ȃ�ΒP���Ɍ�����Ԃ̒l�͔�΂�
					end
				else
					-- �ʏ��Ԃ������ꍇ�A�O�̒ʏ��ԂƂ��Đݒ�
					list[#list+1] = v
				end
			end
			return list
		end
				
		local get_union_list_B = function(all_list, un_list, enable_type)
			local list = {}
			local first_union_v = nil
			for i,v in ipairs(all_list) do
				if( i>1 and un_list[i] == 1 ) then
					-- ������Ԃ������ꍇ�A�e�폈���i�������A�ŏ��̋�Ԃ͕K���������Ȃ��j
					if( enable_type == "time" ) then
						--���ԂȂ�Ό�����Ԃ̒l���Ō�ɗL����������Ԃɉ��Z
						list[#list] = list[#list] + v
					elseif( enable_type == "v" ) then
						--�l�Ȃ�΁A�ŏ��̌�����Ԃ��ǂ������ׂ�
						--�ŏ��̌�����ԂȂ�΂��̒l�𕜋A�����Ƃ��̒l�Ƃ��Ďg�p
						if( first_union_v == nil ) then
							first_union_v = v
						end
					else
						--����ȊO�Ȃ�ΒP���Ɍ�����Ԃ̒l�͔�΂�
					end
				else
					-- �ʏ��Ԃ������ꍇ�A�O�̒ʏ��ԂƂ��Đݒ�
					if( first_union_v ~= nil ) then
						-- �������A������Ԃ��畜�A�����ꍇ��������A�������߂̋�Ԃ̒l���g�p����i�l�̏ꍇ�݂̂̂͂��j
						list[#list+1] = first_union_v
						-- �l�̏ꍇ�A�Ō�̒l��1�O�̒l�͕K�������ɂȂ�͂��Ȃ̂ŁA
						-- �Ōォ��1�O�������ꍇ�͎��̋�Ԃ�������ԂƂ��ē����l����ꂳ����
						if( i ~= (#all_list-1) ) then
							first_union_v = nil
						end
					else
						list[#list+1] = v
					end
				end
			end
			return list
		end
		
		local pluck = function(t, column_key, index_key)
			local _t = {}
			for i,v in ipairs(t) do
				local _i = v[index_key] or i
				_t[_i] = v[column_key]
			end
			return _t
		end
		
		local calc_pcp = function(cp, et, br, bn)
			--�A���_�̍��W���擾
			local x = (cp < 0) and cp+1 or cp
			local y = easing(et, x, 0, 1, 1, br, bn)
			return {x=x, y=y}
		end
		
		local calc_scale = function(index, time_list, v_list)
			local scale_y_list = {}
			for i=1,2 do
				--scale_y���v�Z
				local scale_height = 1
				local scale_y = 1
				
				local v1 = v_list[i] or 0
				local v2 = v_list[i+1] or 0
				local v3 = v_list[i+2] or 0
				if( (v2-v1) == 0 or (v3-v2) == 0 ) then
					--�ω����Ȃ���Ԃ�����Ȃ�Εό`�͂��Ȃ�
				else
					scale_height = math.abs((v3-v2)/(v2-v1))
					if( time_list[i+1] == 0 ) then
						--(�ŏI��Ԃ�1frame�݂̂̏ꍇ�ɂ��肦��H�j
						scale_y = 1
					else
						scale_y = scale_height * time_list[i] / time_list[i+1]
					end
				end
				scale_y_list[i] = scale_y
			end
			return scale_y_list
		end
		
		local get_union_values = function(time)
			--������Ԃ��l�������d�݃^�C�����X�g����index��t���擾
			local index, t = get_index(time, data.enable_step_time_list)
			--������Ԃ��l�������l���X�g����J�n�ƏI�����擾
			local st, ed = data.enable_v_list[index+1], data.enable_v_list[index+2]
			--������Ԃ��l�����Ȃ��{����index��t���Ԃ��Ă���
			local index_raw, t_raw = get_index(time, data.step_time_list)
			--�O���t���i�̋�ԃo�[�\���Ɏg�p����̂ŁA������Ԃ��l��������ԃ^�C�����X�g��l���X�g��Ԃ�
			return index,t,index_raw,t_raw,st,ed,data.enable_time_list,data.enable_v_list
		end
		
		--��ԃC�[�W���O�����̃��C��
		--������������Y��Ɍ����悭��������
		local main = function(index, t, cp1, cp2, b, c, d)
			local stretch_t = function(t, ts, te, total)
				return math.min((math.max(t/total-ts,0))/(te-ts)*total,total)
			end
			
			b,c,d = b or 0,c or 1,d or 1
			--index����g�p����p�����[�^���擾
			local param = params[math.max(index+1,1)]
			local scale_t = param.scale_list["t"][2]
			if( t == nil ) then
				-- t��nil�Ȃ�΃O���t�`��Ɏg�p����param��Ԃ�
				return param
			elseif( t == "top" ) then
				t = 0
			elseif( t == "bottom" ) then
				t = 1-scale_t
			end
			
			local time_list = param.time_list
			local v_list = param.v_list
			
			local et = param.et_list[2]
			local br = param.br_list[2]
			local bn = param.bn_list[2]
			
			local pcp1 = {0, 0}
			local pcp2 = {1, 1}
			if( cp1~= nil ) then
				pcp1 = calc_pcp(cp1, et, br, bn)
			else
				cp1 = param.cp_list[1]
				pcp1 = param.pcp_list[1]
			end
			if( cp2 ~= nil ) then
				pcp2 = calc_pcp(cp2, et, br, bn)
			else
				cp2 = param.cp_list[2]
				pcp2 = param.pcp_list[2]
			end
			
			local pcp1x = pcp1.x
			local pcp1y = pcp1.y
			local pcp2x = pcp2.x
			local pcp2y = pcp2.y
			if( cp1 < 0 ) then
				pcp1x = 0
				pcp1y = 0
			end
			if( cp2 >= 0 ) then
				pcp2x = 1
				pcp2y = 1
			end
			
			local _x = 1-pcp1x - (1-pcp2x)
			local _y = 1-pcp1y - (1-pcp2y)
			local _t = t * _x + pcp1x
			local _d = easing(et, _t, b, c, d, br, bn)
			local y = (_d-pcp1y)/_y
			local _t1 = math.min(_t+scale_t*_x,1)
			local _d1 = easing(et, _t1, b, c, d, br, bn)
			local y1 = (_d1-pcp1y)/_y
			local st, ed = v_list[2], v_list[3]
			
			return {
				param = param,
				p = {x=t, y=y},
				p_origin = {x=_t, y=_d},
				p1 = {x=t+scale_t, y=y1},
				p1_origin = {x=_t+scale_t*_x, y=_d1},
				d = st + (ed-st) * y,
				d1 = st + (ed-st) * y1,
			}
		end
		
		if( extram_layer and g==nil ) then
			--extram_layer���w�肳��A���Aparam����Ȃ��getvalue���ŌĂяo����O���[�o���ϐ����Ȃ���ԂƂ݂Ȃ�
			data = clone(get_extram_data(extram_layer))
			params = data.params
		else
			--g.time_list�͑O��Ԃ̏d�݁i�l�j���܂܂�Ă���̂ŁA�����ȃZ�N�V�������Ƃ̎��Ԃ����
			data.time_list = calc_section_time_list(g.time_list)
			
			--�������Ɏg�p����l��ς���i�֐����̂�ς���j
			local get_union_list = get_union_list_A
			if( g.UNION_FIRST == 1 ) then
				get_union_list = get_union_list_B
			end
			
			--�ݒ�̓s����Aet_list����[index][link_index]�̌`�ɂȂ��Ă���̂�pluck�Ŕ����o��
			local un_list = pluck(g.un_list, link_index+1)
			data.step_time_list = g.time_list
			data.enable_et_list = get_union_list(pluck(g.et_list, link_index+1), un_list)
			data.enable_cp_list = get_union_list(pluck(g.cp_list, link_index+1), un_list)
			data.enable_br_list = get_union_list(pluck(g.br_list, link_index+1), un_list)
			data.enable_bn_list = get_union_list(pluck(g.bn_list, link_index+1), un_list)
			data.enable_v_list = get_union_list(g.v_list[link_index+1], un_list, "v")
			data.enable_time_list = get_union_list(data.time_list, un_list, "time")
			data.enable_step_time_list = calc_step_time_list(data.enable_time_list)
			--�������y�����邽�ߍŏ��ɑS���̃p�����[�^�����
			for index=0, #data.enable_time_list do
				--��悲�ƂɃp�����[�^������U��
				local param = {}
				
				local et_list = list_slice(index, data.enable_et_list, 3, 1)
				local cp_list = list_slice(index, data.enable_cp_list, 3, 0)
				local br_list = list_slice(index, data.enable_br_list, 3, 0)
				local bn_list = list_slice(index, data.enable_bn_list, 3, 3)
								
				local time_list = list_slice(index, data.enable_time_list, 3)
				local v_list = list_slice(index, data.enable_v_list, 4)
				
				local scale_t1 = 1/(to_frame(time_list[1] or 0 ,g.fps))
				local scale_t2 = 1/(to_frame(time_list[2] or 0, g.fps))
				local scale_t3 = 1/(to_frame(time_list[3] or 0, g.fps))
				--scale_y���v�Z
				local scale_y_list = calc_scale(index, time_list, v_list)
				local scale_y1, scale_x1 = 1, 1
				local scale_y2, scale_x2 = 1, 1
				--�E�̃O���t����Ƃ���
				if( scale_y_list[1] > 1 ) then
					--�E�̃O���t���{���c���ɂȂ�͂��Ȃ�΍��̃O���t�̏c�����k�߂�
					scale_y1 = 1/scale_y_list[1]
				else
					--�E�̃O���t���{�������ɂȂ�͂��Ȃ�΍��̃O���t�̏c�����L���遁�������k�߂�
					scale_x1 = scale_y_list[1]
				end
				if( scale_y_list[2] > 1 ) then
					--��̃O���t���{���c���ɂȂ�͂��Ȃ�ΐ�̃O���t�̉������k�߂�
					scale_x2 = 1/scale_y_list[2]
				else
					--��̃O���t���{�������ɂȂ�͂��Ȃ�ΐ�̃O���t�̏c�����k�߂�
					scale_y2 = scale_y_list[2]
				end
				
				--�� or �E���̃C�[�W���O�̍Ō� or �ŏ��̌X�����v�Z
				local a1, a2, a1_stretch, a2_stretch, d1, d2
				local pcp1, pcp2 = {x=0, y=0}, {x=1, y=1}
				local cp1,cp2 = cp_list[2]/100, cp_list[3]/100
				--cp1��cp2�𒴂��Ȃ�
				cp1 = math.min(cp1, 0.99+cp2)
				if( index > 0 ) then
					--1��Ԗڂ͎��g��CP�͖���
					if( cp1 < 0 ) then
						-- �A���_���}�C�i�X�Ȃ̂ŉE���̃O���t�̍ŏ��̌X���Ɍq����
						-- �A���_������͍̂����̃O���t
						pcp1 = calc_pcp(cp1, et_list[1], br_list[1], bn_list[1])
					else
						-- �A���_���v���X�Ȃ̂ō����̃O���t�̍Ō�̌X���Ɍq����
						-- �A���_������͉̂E���̃O���t
						pcp1 = calc_pcp(cp1, et_list[2], br_list[2], bn_list[2])
					end
				end
				if( cp2 < 0 ) then
					-- ���̋��̘A���_���}�C�i�X�Ȃ̂ŁA���̋��̃O���t�̍ŏ��̌X��
					-- �A���_������͉̂E���̃O���t
					pcp2 = calc_pcp(cp2, et_list[2], br_list[2], bn_list[2])
				end
				
				
				param.time_list = time_list
				param.v_list = v_list
				param.et_list = et_list
				param.cp_list = {cp1, cp2}
				param.br_list = br_list
				param.bn_list = bn_list
				param.scale_y_list = scale_y_list
				param.scale_list = {
					x = { scale_x1, scale_x2 },
					y = { scale_y1, scale_y2 },
					t = { scale_t1, scale_t2 },
				}
				param.pcp_list = {pcp1, pcp2}
				params[index+1] = param
			end
			
			--�ω��ʂ��v�Z
			for index=0, #data.enable_time_list do
				local param = params[index+1]
				local cp1,cp2 = param.cp_list[1], param.cp_list[2]
				local d1, d2
				if( index > 0 ) then
					--1��Ԗڂ͎��g��CP�͖���
					if( cp1 < 0 ) then
						-- �A���_���}�C�i�X�Ȃ̂ŉE���̃O���t�̍ŏ��̌X���Ɍq����
						local result = main(index, "top")
						d1 = result.d1-result.d
					else
						-- �A���_���v���X�Ȃ̂ō����̃O���t�̍Ō�̌X���Ɍq����
						local result = main(index-1, "bottom")
						d1 = result.d1-result.d
					end
				end
				if( cp2 < 0 ) then
					-- ���̋��̘A���_���}�C�i�X�Ȃ̂ŁA���̋��̃O���t�̍ŏ��̌X��
					local result = main(index+1, "top")
					d2 = result.d1-result.d
				end
				param.diff_list = {d1, d2}
			end
			
			if( g.EXTRAM_USE == 1 ) then
				data.params = params
				set_extram_data(g.layer, data)
			end
		end
		
		return main,get_union_values
	end,

}


