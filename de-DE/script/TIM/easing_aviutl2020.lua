local DEBUG = false
local E = require("easing")
-- ft_userは呼び出し元でE.ftとして取得可能にした
-- 受けた変数（現在はE）でftにイージング関数を追加すれば自由にイージングを追加できるはず
-- easing.luaに書かれたような形式で値を返す関数を渡せば自前のイージングも登録可能
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

--ゆうきさんのを改造
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
		-- oovさん
		Extram = require("Extram")
	end
	package.cpath = cpath
	return Extram
end

local function require_prtrdump()
	local Prtrdump
	if( pcall(require, "dump") ) then
		-- Jerome Vuarandさん
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
	--0番のときは常に最終値を返すとする
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
		--時間軸を反転
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
	
	-- 値を反転
	if( reverse_r ) then
		r = b*2 + c - r
	end
	
	-- なんか-1.#INDで返ってくる場合があるようなのでチェック
	-- LuaにおけるNaNのことで、こうやって判定するらしい？
	if( r~=r ) then
		-- NaNなら、とりあえず初期値を返す
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
		-- 6桁以上　合成1 合成2 割合
		_et = string.format("%07d",et_abs)
	elseif( et_abs >= 1000 ) then
		-- 4桁以上　合成1(01固定) 合成2 割合
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
		-- 通常イージング
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
	--get_indexはgetpoint("index")と同じ結果になるようしたつもりだが、
	--そのままだと最終fで次のindexとなって使いづらいので調整する
	if(totalframe == frame) then
		--おそらく最終fにいるので前のindexのratio=1とする
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

--循環参照は考慮していないので注意
local function has_changed(t1, t2)
	for k, v in pairs(t1) do
		if type(v) == "table" then
			if type(t2[k]) == "table" then
				if( has_changed(v, t2[k]) == true ) then
					-- テーブルの中身で違いがあったので抜ける
					return true
				end
			else
				return true -- 片方テーブルで片方テーブルでなかったので抜ける
			end
		else
			if( number_type(t1[k]) ~= number_type(t2[k]) ) then
				return true	--違うものが見つかった時点で抜ける
			end
		end
	end
	-- どれも違いがなかった
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
	-- 受けた変数(現在はE).easing()でAVIUTLからも、固有処理を飛ばして直接上の関数を呼べるようにする
	easing = easing,
	
	-- ftを返す
	ft = ft_user,
	
	-- イージングの個数を返す
	get_easing_length = function()
		return #ft_original
	end,
	
	-- 有効なイージングタイプかどうか
	is_easing_type = function(et)
		return (et>=1 and et<=#ft_original)
	end,
	
	-- デバッグ表示用
	dump = dump,
	serialize = serialize,
	
	-- トラックバー対応版"ではない"イージング処理
	-- dialog:にグローバル変数使ってるのをやめたいが、そうすると別変数扱いとなり
	-- 過去のプロジェクトでパラメータが消えて設定し直しになるようなので、そのまま
	-- E.LENは流石に使ってる人いない（非公開機能だし）だろうから削除
	easing_aviutl = function()
		local i = (interval == nil) and 0 or (interval * obj.framerate / 1000)
		local d = obj.totalframe - (obj.num-1)*i
		local c = obj.track2-obj.track1
		local t = math.min(math.max(0,obj.frame - obj.index*i),d)
		local s = es
		local a = ea
		local p = ep
		
		if( disable and ((t/d)*100 < disable) ) then
			--無効化
			return 0
		end
		
		if( d <= 0 ) then
			if( obj.index == 0 ) then
				debug_print(string.format("layer%d:%s %dフレーム足りません",obj.layer,obj.getoption("script_name"),-d+1))
			end
			return 0
		end
		
		if( obj.track3>=0 ) then
			-- 進捗%とインターバルの同時利用はよくわからないので諦めた
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
	
	--同じgが与えられたら結果は同じなので毎フレーム（座標等で軌跡表示したら更に）動いてるのが無駄で、どうにかしたい
	--tra内でどのパラメータから呼び出されたかの情報が取れれば、パラメータ毎にグローバル変数に残せておけるのだが
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

		--イージング関数をラップして反発関係をいじった上で返す
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
				
				--前のイージング関数を一旦退避
				local _ft_detarame = {}
				local _ft_original = {}
				for n=1,4 do
					_ft_detarame[n] = ft_detarame[38+n-1]
					_ft_original[n] = ft_original[38+n-1]
				end
				--反発関連情報を更新した関数を渡す
				ft_detarame[38] = inBounce
				ft_detarame[39] = outBounce
				ft_detarame[40] = inOutBounce
				ft_detarame[41] = outInBounce
				ft_original[38] = inBounce
				ft_original[39] = outBounce
				ft_original[40] = inOutBounce
				ft_original[41] = outInBounce
				--イージング実行
				r = easing(et, t, b, c, d)
				--使い終わったのでもとに戻す
				for n=1,4 do
					ft_detarame[38+n-1] = _ft_detarame[n]
					ft_original[38+n-1] = _ft_original[n]
				end
			else
				--反発関係ないイージングなのでそのまま実行
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
					-- 結合区間だった場合、各種処理（ただし、最初の区間は必ず結合しない）
					if( enable_type == "time" ) then
						--時間ならば結合区間の値を最後に有効だった区間に加算
						list[#list] = list[#list] + v
					else
						--それ以外ならば単純に結合区間の値は飛ばす
					end
				else
					-- 通常区間だった場合、前の通常区間として設定
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
					-- 結合区間だった場合、各種処理（ただし、最初の区間は必ず結合しない）
					if( enable_type == "time" ) then
						--時間ならば結合区間の値を最後に有効だった区間に加算
						list[#list] = list[#list] + v
					elseif( enable_type == "v" ) then
						--値ならば、最初の結合区間かどうか調べて
						--最初の結合区間ならばその値を復帰したときの値として使用
						if( first_union_v == nil ) then
							first_union_v = v
						end
					else
						--それ以外ならば単純に結合区間の値は飛ばす
					end
				else
					-- 通常区間だった場合、前の通常区間として設定
					if( first_union_v ~= nil ) then
						-- ただし、結合区間から復帰した場合だったら、結合初めの区間の値を使用する（値の場合のみのはず）
						list[#list+1] = first_union_v
						-- 値の場合、最後の値と1個前の値は必ず同じになるはずなので、
						-- 最後から1個前だった場合は次の区間も結合区間として同じ値を入れさせる
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
			--連結点の座標を取得
			local x = (cp < 0) and cp+1 or cp
			local y = easing(et, x, 0, 1, 1, br, bn)
			return {x=x, y=y}
		end
		
		local calc_scale = function(index, time_list, v_list)
			local scale_y_list = {}
			for i=1,2 do
				--scale_yを計算
				local scale_height = 1
				local scale_y = 1
				
				local v1 = v_list[i] or 0
				local v2 = v_list[i+1] or 0
				local v3 = v_list[i+2] or 0
				if( (v2-v1) == 0 or (v3-v2) == 0 ) then
					--変化がない区間があるならば変形はしない
				else
					scale_height = math.abs((v3-v2)/(v2-v1))
					if( time_list[i+1] == 0 ) then
						--(最終区間が1frameのみの場合にありえる？）
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
			--結合区間を考慮した重みタイムリストからindexとtを取得
			local index, t = get_index(time, data.enable_step_time_list)
			--結合区間を考慮した値リストから開始と終了を取得
			local st, ed = data.enable_v_list[index+1], data.enable_v_list[index+2]
			--結合区間を考慮しない本来のindexとtも返しておく
			local index_raw, t_raw = get_index(time, data.step_time_list)
			--グラフ下段の区間バー表示に使用するので、結合区間を考慮した区間タイムリストや値リストを返す
			return index,t,index_raw,t_raw,st,ed,data.enable_time_list,data.enable_v_list
		end
		
		--区間イージング処理のメイン
		--もうちょっと綺麗に効率よく書きたい
		local main = function(index, t, cp1, cp2, b, c, d)
			local stretch_t = function(t, ts, te, total)
				return math.min((math.max(t/total-ts,0))/(te-ts)*total,total)
			end
			
			b,c,d = b or 0,c or 1,d or 1
			--indexから使用するパラメータを取得
			local param = params[math.max(index+1,1)]
			local scale_t = param.scale_list["t"][2]
			if( t == nil ) then
				-- tがnilならばグラフ描画に使用するparamを返す
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
			--extram_layerが指定され、かつ、paramが空ならばgetvalue等で呼び出されグローバル変数がない状態とみなす
			data = clone(get_extram_data(extram_layer))
			params = data.params
		else
			--g.time_listは前区間の重み（値）が含まれているので、純粋なセクションごとの時間を作る
			data.time_list = calc_section_time_list(g.time_list)
			
			--結合時に使用する値を変える（関数自体を変える）
			local get_union_list = get_union_list_A
			if( g.UNION_FIRST == 1 ) then
				get_union_list = get_union_list_B
			end
			
			--設定の都合上、et_list等は[index][link_index]の形になっているのでpluckで抜き出す
			local un_list = pluck(g.un_list, link_index+1)
			data.step_time_list = g.time_list
			data.enable_et_list = get_union_list(pluck(g.et_list, link_index+1), un_list)
			data.enable_cp_list = get_union_list(pluck(g.cp_list, link_index+1), un_list)
			data.enable_br_list = get_union_list(pluck(g.br_list, link_index+1), un_list)
			data.enable_bn_list = get_union_list(pluck(g.bn_list, link_index+1), un_list)
			data.enable_v_list = get_union_list(g.v_list[link_index+1], un_list, "v")
			data.enable_time_list = get_union_list(data.time_list, un_list, "time")
			data.enable_step_time_list = calc_step_time_list(data.enable_time_list)
			--処理を軽減するため最初に全区画のパラメータを作る
			for index=0, #data.enable_time_list do
				--区画ごとにパラメータを割り振り
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
				--scale_yを計算
				local scale_y_list = calc_scale(index, time_list, v_list)
				local scale_y1, scale_x1 = 1, 1
				local scale_y2, scale_x2 = 1, 1
				--右のグラフを基準とする
				if( scale_y_list[1] > 1 ) then
					--右のグラフが本来縦長になるはずならば左のグラフの縦幅を縮める
					scale_y1 = 1/scale_y_list[1]
				else
					--右のグラフが本来横長になるはずならば左のグラフの縦幅を広げる＝横幅を縮める
					scale_x1 = scale_y_list[1]
				end
				if( scale_y_list[2] > 1 ) then
					--先のグラフが本来縦長になるはずならば先のグラフの横幅を縮める
					scale_x2 = 1/scale_y_list[2]
				else
					--先のグラフが本来横長になるはずならば先のグラフの縦幅を縮める
					scale_y2 = scale_y_list[2]
				end
				
				--左 or 右区画のイージングの最後 or 最初の傾きを計算
				local a1, a2, a1_stretch, a2_stretch, d1, d2
				local pcp1, pcp2 = {x=0, y=0}, {x=1, y=1}
				local cp1,cp2 = cp_list[2]/100, cp_list[3]/100
				--cp1はcp2を超えない
				cp1 = math.min(cp1, 0.99+cp2)
				if( index > 0 ) then
					--1区間目は自身のCPは無視
					if( cp1 < 0 ) then
						-- 連結点がマイナスなので右側のグラフの最初の傾きに繋がる
						-- 連結点があるのは左側のグラフ
						pcp1 = calc_pcp(cp1, et_list[1], br_list[1], bn_list[1])
					else
						-- 連結点がプラスなので左側のグラフの最後の傾きに繋がる
						-- 連結点があるのは右側のグラフ
						pcp1 = calc_pcp(cp1, et_list[2], br_list[2], bn_list[2])
					end
				end
				if( cp2 < 0 ) then
					-- 次の区画の連結点がマイナスなので、次の区画のグラフの最初の傾き
					-- 連結点があるのは右側のグラフ
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
			
			--変化量を計算
			for index=0, #data.enable_time_list do
				local param = params[index+1]
				local cp1,cp2 = param.cp_list[1], param.cp_list[2]
				local d1, d2
				if( index > 0 ) then
					--1区間目は自身のCPは無視
					if( cp1 < 0 ) then
						-- 連結点がマイナスなので右側のグラフの最初の傾きに繋がる
						local result = main(index, "top")
						d1 = result.d1-result.d
					else
						-- 連結点がプラスなので左側のグラフの最後の傾きに繋がる
						local result = main(index-1, "bottom")
						d1 = result.d1-result.d
					end
				end
				if( cp2 < 0 ) then
					-- 次の区画の連結点がマイナスなので、次の区画のグラフの最初の傾き
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


