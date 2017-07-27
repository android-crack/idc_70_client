-- 宝物数据

local baowu_info = require("game_config/collect/baozang_info")
local baowu_consume = require("game_config/collect/baowu_consume")

local BaowuData = class("BaowuData")

function BaowuData:ctor()
	self.baowu_list = {}
	self.boat_baowu_list = {}
end 

function BaowuData:askList()
	GameUtil.callRpc("rpc_server_baowu_list", {},"rpc_client_baowu_list")
end 

--请求使用宝物盒子
function BaowuData:askUseBaowuBox(item_id)
	GameUtil.callRpc("rpc_server_use_baowu_box", {item_id}, "rpc_client_use_baowu_box")
end 

function BaowuData:receive(baowu_list, boat_baowu)
	for k, v in pairs(baowu_list) do--水手宝物
		self:addBaowu(v)
	end 	
	for k, v in pairs(boat_baowu) do--船舶宝物
		self:addBoatBaowu(v)
	end 
end 

function BaowuData:addBaowu(info)
	if info then 
		local key = info.baowuKey
		self.baowu_list[key] = info
	end
end 

function BaowuData:addBoatBaowu(info)
	if info then 
		local key = info.baowuId
		self.boat_baowu_list[key] = info
	end
end 

function BaowuData:getInfoById(key)
	if self.baowu_list[key] then
		return self.baowu_list[key] 
	end
	if self.boat_baowu_list[key] then
		return self.boat_baowu_list[key]
	end 
end

function BaowuData:getArrayList(type, _type1, _type2)
	local _list = {}
	local source_list = {}
	if type == BAG_PROP_TYPE_SAILOR_BAOWU then 
		source_list = self.baowu_list
	else
		source_list = self.boat_baowu_list
	end
	for key, v in pairs(source_list) do	
		if (_type1 == nil and _type2 == nil) or (baowu_info[v.baowuId].type == _type1 or baowu_info[v.baowuId].type == _type2) then 
			_list[#_list + 1] = v
		end 
	end
	return _list
end

function BaowuData:getBoatBaoWuList()  --获取所有船舶宝物
	local list = {}
	for k,v in pairs(self.boat_baowu_list) do
		list[#list + 1] = v
	end
	return list
end

function BaowuData:getSailorBaowuList()
	local _list = {}
	for key,v in pairs(self.baowu_list) do
		_list[#_list + 1] = v
	end
	return _list
end

function BaowuData:delBaowu(baowu_key)
	if self.baowu_list[baowu_key] then 
		self.baowu_list[baowu_key] = nil
	end 	
	if self.boat_baowu_list[baowu_key] then 
		self.boat_baowu_list[baowu_key] = nil
	end 	
end

-- 请求洗练查询
function BaowuData:askRefiningCheck(index, pos)
	GameUtil.callRpc("rpc_server_baowu_refining_check", {index - 1, pos},"rpc_client_baowu_refining_check")
end 

-- 请求洗练
function BaowuData:askRefining(index, pos, lock_list)
	GameUtil.callRpc("rpc_server_baowu_refining", {index - 1, pos, lock_list},"rpc_client_baowu_refining")
end 

-- 请求洗练保存
function BaowuData:askRefiningSave(index, pos)
	GameUtil.callRpc("rpc_server_baowu_refining_save", {index - 1, pos},"rpc_client_baowu_refining_save")
end 

-- 请求突破
function BaowuData:askBaowuBreak(index, pos,baowuKey)
	GameUtil.callRpc("rpc_server_baowu_surmount", {index - 1, pos,baowuKey},"rpc_client_baowu_surmount")
end 


-- 请求材料合成
function BaowuData:askMaterialSynthetise(baowu_key)
	GameUtil.callRpc("rpc_server_material_synthetise", {baowu_key},"rpc_client_material_synthetise")
end 

--请求宝物合成
function BaowuData:askBaowuSynthetise(baowu_key)
	GameUtil.callRpc("rpc_server_item_synthetise", {baowu_key}, "rpc_client_item_synthetise")
end 

--请求装备船舶宝物合成
function BaowuData:askBoatEquipCompose(index, baowu_key, pos)
	GameUtil.callRpc("rpc_server_boat_compose_baowu", {index - 1, baowu_key, pos}, "rpc_client_boat_compose_baowu")
end 

--请求宝物拆解
function BaowuData:askBaowuDisassemble(baowu_key)
	GameUtil.callRpc("rpc_server_baowu_disassembly", {baowu_key}, "rpc_client_baowu_disassembly")
end 

--请求船舶宝物合成
function BaowuData:askComposeBoatBaowu(baowu_key)
	GameUtil.callRpc("rpc_server_compose_baowu", {baowu_key}, "rpc_client_compose_baowu")
end 

-- 获取精华
function BaowuData:getEssence()
	local propDataHandle = getGameData():getPropDataHandler()
	if propDataHandle:get_propItem_by_id(3) then 
		return propDataHandle:get_propItem_by_id(3).count
	end 
end

--洗练数据
function BaowuData:getRefiningEssenceById()
	local player_data = getGameData():getPlayerData()
	local level = player_data:getLevel()
	for i,v in ipairs(baowu_consume) do
		if level <= v.level then
			return v
		end
	end
	return baowu_consume[1]
end

return BaowuData




