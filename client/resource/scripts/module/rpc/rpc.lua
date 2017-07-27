
local ENDIAN = "little"
local HEAD_LENGTH = 4

local MAX_DATA_LENGHT = 1024*1024

local INT = 0
local STRING = 1
local STRUCT = 2
local DOUBLE = 3
local BUFFER = 5
local BYTE = 6
local SHORT = 7

local ARRAY_VAR = 0x00010000
local UNARRAY_VAR = 0x000000FF

-- 一帧之内最大的协议解析数量，以防止卡死
local MAX_PARSE_COUNT_PER_FRAME = 100


local rpc = { _input = "", _output, _luaSocket = nil, _pkgLen = nil }

SERVER_FUNC = {}

---------------------------------------------------------------------
-- 以下部分为静态协议中必须先与rpc.cfg存在的协议
---------------------------------------------------------------------
local RPC_CLIENT_UPDATE_PTO     = "1"
local RPC_SERVER_VERSION        = "2"
local RPC_CLIENT_VERSION_RETUEN = "3"
-- TODO:RPC_CLIENT_UPDATE_PTO_STR 应该取名 RPC_CLIENT_UPDATE_PTO_JSON 或者 RPC_CLIENT_UPDATE_PTO_LUASTRING
local RPC_CLIENT_UPDATE_PTO_STR = "4"
-- TODO:还应该再实现一个服务器下行lua字符串执行的协议
local RPC_SERVER_AUTH			= "5"
local RPC_SERVER_UID_RELINK			= "11"

local FUNCTION_CFG = {}

local CLASS_CFG = {
	{class_name= "loginInfo", field= { {field_name= "uid", class_index= -1, type= INT}, {field_name= "school", class_index= -1, type= INT} } }
}
---------------------------------------------------------------------
local regFun = {}

--load协议之前，预先生成的函数
local function cleanServerFuncCfg()
	FUNCTION_CFG = {}
	-- 上行客户端版本信息
	FUNCTION_CFG[RPC_SERVER_VERSION] = {args = { {class_index = -1, type = STRING}, {class_index = -1, type = STRING}, {class_index = -1, type = STRING}, {class_index = -1, type = STRING} }, function_name = "rpc_server_version"}
	-- 版本信息结果返回
	FUNCTION_CFG[RPC_CLIENT_VERSION_RETUEN] = {args = { {class_index = -1, type = INT},{class_index = -1, type = STRING} }, function_name = "rpc_client_version_return"}
	-- 更新协议
	FUNCTION_CFG[RPC_CLIENT_UPDATE_PTO_STR] = {args = { {class_index = -1, type = BUFFER} }, function_name = "rpc_client_update_pto_str"}
	--
	FUNCTION_CFG[RPC_SERVER_AUTH] = { args = { { class_index = -1, type = STRING}, { class_index = -1, type = STRING}, {class_index = -1,  type = STRING}, { class_index = -1,  type = STRING}, {class_index = -1, type = STRING}}, function_name = "rpc_server_auth"}

	FUNCTION_CFG[RPC_SERVER_UID_RELINK] = { args = { {class_index = -1, type = INT}, { class_index = -1, type = STRING}}, function_name = "rpc_server_uid_relink"}
end

function rpc:regRpc(prot_name, func)
	regFun[prot_name] = func
end

function rpc:unregRpc(prot_name)
	regFun[prot_name] = nil
end

local unprint_rpc_t = {
	["rpc_server_user_heartbeat"]	= true,
	["rpc_server_fight_view"]	= true,
	["rpc_client_fight_view"]	= true,
	["rpc_server_fight_move_to_points"]	= true,
	["rpc_client_fight_move_to_points"]	= true,
	["rpc_server_fight_view_move_to"]	= true,
	["rpc_client_fight_view_move_to"]	= true,
	["rpc_server_fight_view_add_status"]	= true,
	["rpc_client_fight_view_add_status"]	= true,
	["rpc_client_fight_view_del_status"]	= true,
	["rpc_server_fight_view_del_status"]	= true,
	["rpc_server_fight_view_add_ai"]	= true,
	["rpc_client_fight_view_add_ai"]	= true,
	["rpc_server_fight_view_del_ai"]	= true,
	["rpc_client_fight_view_del_ai"]	= true,
	["rpc_server_ai_status"]	= true,
	["rpc_client_to_perform_skill"] = true,
	["rpc_client_user_add_pve_ship"] = true,
}

local function initServerFunc()
	for i, cfg in pairs(FUNCTION_CFG) do
		local pid = tonumber(i)
		SERVER_FUNC[cfg["function_name"]] = function(...)
			local function_name = cfg["function_name"]
			if (not unprint_rpc_t[function_name]) then
				rpc_print("[C->S]["..cfg["function_name"].."]"..dump({...}, "args", 1))
			end
			
			rpc:rpc_call(pid, ...)
		end
	end
end

local function get_field_info(field)
	field.__type__ = field.__type__ or Math.bit_and(field["type"], UNARRAY_VAR)
	field.__isarray__ = field.__isarray__ or Math.bit_and(field["type"], ARRAY_VAR)
	
	return field.__type__, field.__isarray__
end

function rpc:loadConfig(config)
	cleanServerFuncCfg()
	local rpccfg = LoadJsonFromFile(config)

	for k, v in pairs(rpccfg.function_cfg) do
		FUNCTION_CFG[k] = v
	end

	CLASS_CFG = rpccfg.class_cfg
	initServerFunc()
end


function rpc_client_update_pto(bytes)
	cleanServerFuncCfg()
	local rpccfg = json.decode(bytes)

	for k, v in pairs(rpccfg.function_cfg) do
		FUNCTION_CFG[k] = v
	end

	CLASS_CFG = rpccfg.class_cfg
	initServerFunc()
end

local function bytes_to_int(str,endian,signed) -- use length of string to determine 8,16,32,64 bits
    local t = {str:byte(1,-1)}
    if endian == "big" then --reverse bytes
        local tt={}
        for k=1,#t do
            tt[#t-k+1]=t[k]
        end
        t=tt
    end
    local n=0
    for k=1,#t do
        n=n+t[k]*2^((k-1)*8)
    end
    if signed then
        --n = (n > 2^(#t-1) -1) and (n - 2^#t) or n -- if last bit set, negative.
		n = (t[4] > 2^7 -1) and (n - 2^((#t*8))) or n -- if last bit set, negative.
    end
    return n
end

local function int_to_bytes(num,endian,signed)
    if num < 0 and not signed then
    	num =- num
    	print"warning, dropping sign from number converting to unsigned"
    end
    
    local res={}
    --local n = math.ceil(select(2,math.frexp(num))/8) -- number of bytes to be used.
    local n = 4
    if signed and num < 0 then
        num = num + 2^(n*8)
    end
    for k=n,1,-1 do -- 256 = 2^8 bits per char.
        local mul=2^(8*(k-1))
        res[k]=math.floor(num/mul)
        num=num-res[k]*mul
    end
    assert(num==0)

    if endian == "big" then
        local t={}
        for k=1,n do
            t[k]=res[n-k+1]
        end
        res=t
    end

    return string.char(unpack(res))
end

local function table_slice(values,i1,i2)
	local res = {}
	local n = #values

	-- default values for range
	i1 = i1 or 1
	i2 = i2 or n
	if i2 < 0 then
		i2 = n + i2 + 1
	elseif i2 > n then
		i2 = n
	end

	if i1 < 1 or i1 > n then
		return {}
	end

	local k = 1

	for i = i1,i2 do
		res[k] = values[i]
		k = k + 1
	end
	return res
end

function rpc:pack_int(data)
	assert(self._luaSocket)

	self._luaSocket:pushInt(data)
end

function rpc:unpack_int()
	assert(self._luaSocket)
	return self._luaSocket:readInt()
end

function rpc:pack_string(str)
	assert(self._luaSocket)

	self._luaSocket:pushString(str)
end

function rpc:unpack_string()
	assert(self._luaSocket)
	return self._luaSocket:readString()
end

function rpc:unpack_buffer()
	return self:unpack_string()
end

function rpc:pack_byte(data)
	assert(self._luaSocket)

	self._luaSocket:pushByte(data)
end

function rpc:unpack_byte()
	assert(self._luaSocket)
	return self._luaSocket:readByte()
end

function rpc:pack_short(data)
	assert(self._luaSocket)

	self._luaSocket:pushShort(data)
end

function rpc:unpack_short()
	assert(self._luaSocket)
	return self._luaSocket:readShort()
end

function rpc:pack_struct(data, class_index)
	class_index = class_index + 1
	local classInfo = CLASS_CFG[class_index]
	local fieldInfo = classInfo.field

	for i = 1, #fieldInfo do
		local field = fieldInfo[i]

		local _type, isarray = get_field_info(field)

		local field_name = field["field_name"]

		if isarray ~= 0 then
			if _type == STRUCT then
				self:pack_array(_type, data[field_name], field["class_index"])
			else
				self:pack_array(_type, data[field_name])
			end
		else
			if _type == INT then
				self:pack_int(data[field_name])
			elseif _type == STRING then
				self:pack_string(data[field_name])
			elseif _type == BYTE then
				self:pack_byte(data[field_name])
			elseif _type == SHORT then
				self:pack_short(data[field_name])
			elseif _type == STRUCT then
				self:pack_struct(data[field_name], field["class_index"])
			else
				assert(0)
			end
		end
	end
end

function rpc:unpack_struct(class_index)
	class_index = class_index + 1
	local classInfo = CLASS_CFG[class_index]
	local fieldInfo = classInfo["field"]
	local struct = {}

	for i = 1, #fieldInfo do
		local field = fieldInfo[i]
		
		local _type, isarray = get_field_info(field)

		local field_name = field["field_name"]

		if isarray ~= 0 then
			if _type == STRUCT then
				struct[field_name] = self:unpack_array(_type, field["class_index"])
			else
				struct[field_name] = self:unpack_array(_type)
			end
		else
			if _type == INT then
				struct[field_name] = self:unpack_int()
			elseif _type == BYTE then
				struct[field_name] = self:unpack_byte()
			elseif _type == SHORT then
				struct[field_name] = self:unpack_short()
			elseif _type == STRING then
				struct[field_name] = self:unpack_string()
			elseif _type == STRUCT then
				struct[field_name] = self:unpack_struct(field["class_index"])
			else
				assert(0)
			end
		end
	end

	return struct
end

function rpc:pack_array(_type, data, class_index)
	local len = #data
	self:pack_int(len)

	for i = 1, len do
		if _type == INT then
			self:pack_int(data[i])
		elseif _type == BYTE then
			self:pack_byte(data[i])
		elseif _type == SHORT then
			self:pack_short(data[i])
		elseif _type == STRING then
			self:pack_string(data[i])
		elseif _type == STRUCT then
			self:pack_struct(data[i], class_index)
		else
			assert(0)
		end
	end
end

function rpc:unpack_array(_type, class_index)
	local len = self:unpack_int()
	local args = {}

	for i = 1, len do
		if _type == INT then
			args[i] = self:unpack_int()
		elseif _type == BYTE then
			args[i] = self:unpack_byte()
		elseif _type == SHORT then
			args[i] = self:unpack_short()
		elseif _type == STRING then
			args[i] = self:unpack_string()
		elseif _type == STRUCT then
			args[i] = self:unpack_struct(class_index)
		else
			assert(0)
		end
	end

	return args
end

function rpc:pack(pid, ...)
	local rpcInfo = FUNCTION_CFG[tostring(pid)]
	self:pack_int(pid)

	--for i, v in ipairs{...} do
	for i, v in ipairs(arg) do
		local typeInfo = rpcInfo["args"][i]
		
		local _type, isarray = get_field_info(typeInfo)

		if isarray ~= 0 then
			if _type == STRUCT then
				self:pack_array(_type, v, typeInfo["class_index"])
			else
				self:pack_array(_type, v)
			end
		else
			if _type == INT then
				self:pack_int(v)
			elseif _type == BYTE then
				self:pack_byte(v)
			elseif _type == SHORT then
				self:pack_short(v)
			elseif _type == STRING then
				self:pack_string(v)
			elseif _type == STRUCT then
				self:pack_struct(v, typeInfo["class_index"])
			end
		end
	end
end

function rpc:unpack()
	local pid = self:unpack_int()
	local rpcInfo = FUNCTION_CFG[tostring(pid)]
	local argsInfo = rpcInfo["args"]
	local args = {}

	args[1] = pid

	for i = 1, #argsInfo do
		local typeInfo = argsInfo[i]
		
		local _type, isarray = get_field_info(typeInfo)

		if isarray ~= 0 then
			if _type == STRUCT then
				args[i + 1] = self:unpack_array(_type, typeInfo["class_index"])
			else
				args[i + 1] = self:unpack_array(_type)
			end
		else
			if _type == INT then
				args[i + 1] = self:unpack_int()
			elseif _type == BYTE then
				args[i + 1] = self:unpack_byte()
			elseif _type == SHORT then
				args[i + 1] = self:unpack_short()
			elseif _type == STRING then
				args[i + 1] = self:unpack_string()
			elseif _type == BUFFER then
				args[i + 1] = self:unpack_buffer()
			elseif _type == STRUCT then
				args[i + 1] = self:unpack_struct(typeInfo["class_index"])
			else
				assert(0)
			end
		end
	end
	return args
end

local function GetFun(pid)
	local funcInfo = FUNCTION_CFG[tostring(pid)]
	local funcName = funcInfo["function_name"]
	local func = _G[funcName]

	if not func then
		func = regFun[funcName]
	end

	return funcName, func
end


function setNetPause( is_pause )
	print("set net pause....", is_pause)
	net_pause = is_pause
end

--[[
function rpc:rpc_parse()
	--assert(self._luaSocket)
	if not self._luaSocket then return end
	--卡协议,一帧中的协议全不解析
	if net_pause then return end

	--正在解析中
	--if is_rpc_parsing then return end

	--is_rpc_parsing = true
	--每次最多只处理100条协议
	local parse_count_this_frame = 0
	local package_length = self._luaSocket:getNextPackage() or 0
	while (package_length > 0) do

		local args = self:unpack()
		local pid = args[1]
		local args = table_slice(args, 2, -1)

		local funcName, func = GetFun(pid)

		if type(func) == "function" then
	 		if funcName ~= "rpc_client_user_heartbeat" then
				print("[S->C]".."["..funcName..dump(args).."]")  --发布时候删除
			end

			require("module/rpc/rpcWait").emit(funcName)
			if func then func(unpack(args)) end



		else
			cclog("rpc_parse error. function not exist: pid"..pid.."func:"..funcName)
		end

		parse_count_this_frame = parse_count_this_frame + 1
		if parse_count_this_frame >= MAX_PARSE_COUNT_PER_FRAME then
			break
		end

		if not self._luaSocket then break end
		--卡协议，可以精确到从某个协议开始卡
		if net_pause then break end

	 	package_length = self._luaSocket:getNextPackage() or 0
	end

	--is_rpc_parsing = false
end
--]]

function rpc:dispatch()
	if self.dispatching then return end
	self.dispatching = true

	self:rpc_parse()
	self:call_rpc_functions()

	self.dispatching = false
end

function rpc:rpc_parse()
	if not self._luaSocket then return end

	perftime.gperf_begin("rpc_parse")
	
	--解析出来的协议的缓存
	self.ready_rpc_queue = self.ready_rpc_queue or {}


	local package_length = self._luaSocket:getNextPackage() or 0
	while (package_length > 0) do

		local args = self:unpack()
		local pid = args[1]
		local args = table_slice(args, 2, -1)
		local funcName, func = GetFun(pid)

		if type(func) == "function" then
			--卡协议时打印一下，协议来到的顺序, 以便协议通了之后对比顺序
			if net_pause then
				rpc_print("parse rpc:[S->C]".."["..funcName..dump(args).."]")
			end

			table.insert( self.ready_rpc_queue, { funcName = funcName, func = func, args = args})
			require("module/rpc/rpcWait").emit(funcName)
		else
			cclog("rpc_parse error. function not exist: pid"..pid.."func:"..funcName)
		end

	 	package_length = self._luaSocket:getNextPackage() or 0
	end

	perftime.gperf_end("rpc_parse")
end


function rpc:call_rpc_functions()
	if not self._luaSocket then return end
	--卡协议,一帧中的协议全不解析
	if net_pause then return end

	if not self.ready_rpc_queue then
		print("call rpc func error:ready rpc func queue is nil")
	end

	--[[
	--每次最多执行100条
	for i = 1, MAX_PARSE_COUNT_PER_FRAME, 1 do
		if not self._luaSocket then
			print( "lua socket is nil when call rpc funcs...")
			return
		end

		--卡协议，可以精确到从某个协议开始卡
		if net_pause then return end

		local ready_rpc = table.remove(self.ready_rpc_queue, 1)
		if not ready_rpc then
			--print( "ready rpc queue is empty....")
			return
		end

		if (not unprint_rpc_t[ready_rpc.funcName]) then
			rpc_print("[S->C]".."["..ready_rpc.funcName..dump(ready_rpc.args).."]")  --发布时候删除
		end

		if ready_rpc.func then
			ready_rpc.func(unpack(ready_rpc.args))
		else
			print("call rpc error:[S->C]["..ready_rpc.funcName.."] function is nil")
		end
	end
	--]]

	perftime.gperf_begin("call_rpc_functions")
	
	local called_idx = 0
	--每次最多执行100条,只执行，不摘除
	for i = 1, MAX_PARSE_COUNT_PER_FRAME, 1 do
		if not self._luaSocket then
			print( "lua socket is nil when call rpc funcs...")
			break
		end

		--卡协议，可以精确到从某个协议开始卡
		if net_pause then break end

		local ready_rpc = self.ready_rpc_queue[i]
		if not ready_rpc then
			--print( "ready rpc queue is empty....")
			break
		end

		if (not unprint_rpc_t[ready_rpc.funcName]) then
			rpc_print("[S->C]".."["..ready_rpc.funcName..dump(ready_rpc.args).."]")  --发布时候删除
		end

		called_idx = i
		if ready_rpc.func then
			perftime.gperf_begin("call_rpc_function:"..ready_rpc.funcName)
			
			xpcall(function()
				ready_rpc.func(unpack(ready_rpc.args))
			end, __G__TRACKBACK__)
			
			perftime.gperf_end("call_rpc_function:"..ready_rpc.funcName)
		else
			print("call rpc error:[S->C]["..ready_rpc.funcName.."] function is nil")
		end
	end

	--一次把执行过的，都摘除掉
	local new_ready_queue = {}
	for i = called_idx+1, #self.ready_rpc_queue, 1 do
		table.insert( new_ready_queue, self.ready_rpc_queue[i])
	end
	self.ready_rpc_queue = new_ready_queue
	
	perftime.gperf_end("call_rpc_functions")
end

function rpc:rpc_call(pid, ...)
	if self._luaSocket == nil then return end

	self._luaSocket:beginSendPackage()
	self:pack(pid, ...)
	self._luaSocket:endSendPackage()
end

function rpc:set_lua_socket( socket )
	self._luaSocket = socket
end

function rpc:get_lua_socket( socket )
	return self._luaSocket
end

function rpc:clear()
	self._luaSocket = nil
	self.ready_rpc_queue = {}
end

return rpc