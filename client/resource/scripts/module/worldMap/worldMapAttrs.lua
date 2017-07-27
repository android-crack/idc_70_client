local port_info = require("game_config/port/port_info")
local pve_stronghold_info = require("game_config/portPve/pve_stronghold_info")
local explore_whirlpool = require("game_config/explore/explore_whirlpool")
local area_info = require("game_config/port/area_info")
local relic_info = require("game_config/collect/relic_info")
local goods_info=require("game_config/port/goods_info")
local goods_type_info=require('game_config/port/goods_type_info')
local ui_word = require("game_config/ui_word")
local ClsAlert = require("ui/tools/alert")

local mapW = 113
local mapH = 64

local ClsWorldMapAttrs = class("ClsWorldMapAttrs")

function ClsWorldMapAttrs:ctor()
	self.portTab = {}    --保存已开港口信息{} 索引港口id
	self.allPortHash = {} --所有港口hash表，优化查询速度
	self.portHash = {}    --已开港口
	self.shHash = {}    --已开海上据点
	self.wpHash = {}    --漩涡
	self.wmHash = {}	-- 世界随机任务 哈希表
	self.cmHash = {}	-- 运镖任务 哈希表
	self.hasInitShHash = false
	self.hasInitWpHash = false
	self.hasInitMWHash = false -- 世界随机任务 哈希状态
	self.hasInitCWHash = false -- 运镖任务 哈希状态
	self.seaArea = {}     -- 保存每个海域已开放的港口
	self.relicHash = {}  --保存遗迹，key:id, value:pos
	self.timePirvateHash = {}  --保存时段海盗
	self.mineralPointHash = {}  --保存矿点
	self.relic_rect_infos = {}
	self.hotPortGoods = {}

	self.needToPort = {}       --需求品
	self.portToNeed = {}
	self.needToPortExitDic = {}
	self.portToNeedExitDic = {}
	self.needGoodCallFunc = nil  --探索需求品返回函数

	self.m_is_ask_enter_port = false
	self.m_enter_port_params = {create_ui_callback = nil, item_tab = nil}
end

------------------港口列表-----------------------
--请求单个港口
function ClsWorldMapAttrs:getSinglePortFromSer(port)
	local tab = port_info[port.portId]
	local key = tab.port_pos[1]*mapH + tab.port_pos[2]
	self.portHash[key] = true
	self:setSeaArea(port.portId)
	self.portTab[port.portId] = {invest = port.invest, status = port.status, open = port.open or 0, rewardTime = port.rewardTime}
	local ExploreMap = getUIManager():get("ExploreMap") or getUIManager():get("PortMap")
	if not tolua.isnull(ExploreMap) then
		EventTrigger(EVENT_PORT_LIST_UPDATE)
	end

	local port_main_info_tips = getUIManager():get("ClsPortMainInfoTips")
	if not tolua.isnull(port_main_info_tips) then
		port_main_info_tips:updateShareStatus(port.portId, port.rewardTime)
	end
end

 --请求港口列表
function ClsWorldMapAttrs:getPortListFromSer(portList)
	self.portHash = {}
	self.seaArea = {}
	self.portTab = {}
	if type(portList) == "table" then
		for i,v in ipairs(portList) do
			self:setSeaArea(v.portId)
			local tab = port_info[v.portId]
			local key = tab.port_pos[1]*mapH + tab.port_pos[2]
			self.portHash[key] = true
			self.portTab[v.portId] = {invest = v.invest, status = v.status, open = v.open or 0, rewardTime = v.rewardTime}
		end
	end

	--提示玩家是否可以进行领奖
	--self:setInvestRewardTask()

	local ExploreMap = getUIManager():get("ExploreMap") or getUIManager():get("PortMap")
	if not tolua.isnull(ExploreMap) then
		EventTrigger(EVENT_PORT_LIST_UPDATE)
	end
end

function ClsWorldMapAttrs:clearNeedGood()
	self.needToPort = {}
	self.portToNeed = {}
	self.needToPortExitDic = {}
	self.portToNeedExitDic = {}
end

function ClsWorldMapAttrs:askAllNeedGood()
	GameUtil.callRpc("rpc_server_all_port_goods_type", {},"rpc_client_all_port_goods_type")
end



function ClsWorldMapAttrs:receiveNeedGoodType(portId,ids,needCallBackFunc)
	if not ids then return end
	-- if self.portTab[portId] then
		for k,v in ipairs(ids) do
			if not self.needToPortExitDic[v.."_"..portId] then
				self.needToPortExitDic[v.."_"..portId] = true
				self.needToPort[v] = self.needToPort[v] or {}
				table.insert(self.needToPort[v],portId)
			end
			if not self.portToNeedExitDic[portId.."_"..v] then
				self.portToNeedExitDic[portId.."_"..v] = true
				self.portToNeed[portId] = self.portToNeed[portId] or {}
				table.insert(self.portToNeed[portId],v)
			end
		end
	-- end
	if needCallBackFunc and type(self.needGoodCallFunc) == "function" then
		self.needGoodCallFunc(ids)
		self.needGoodCallFunc = nil
	end
end

function ClsWorldMapAttrs:getNeedPort(needId)   --class
	if needId then
		return self.needToPort[needId]
	else
		return self.needToPort
	end
end

function ClsWorldMapAttrs:getPortNeed(portId,callBack)
	if portId then
		if type(callBack) == "function" then
			if self.portToNeed[portId] then
				callBack(self.portToNeed[portId])
			else
				self.needGoodCallFunc = callBack
				GameUtil.callRpc("rpc_server_port_goods_type", {portId},"rpc_client_port_goods_type")
			end
		else
			return self.portToNeed[portId]
		end
	else
		return self.portToNeed
	end
end

-- ui请求
function ClsWorldMapAttrs:getPortList()
	if self.isAskPost then
		return self.portTab
	end
	self.isAskPost = true
	self:askPortList()
end

function ClsWorldMapAttrs:askPortList()
	GameUtil.callRpc("rpc_server_port_list", {}, "rpc_client_port_list")
	self:askAllNeedGood()
end

function ClsWorldMapAttrs:setPortStatus(portId, status)
	if self.portTab[portId] ~= nil then
		self.portTab[portId].status = status
	end
end

function ClsWorldMapAttrs:getPortStatus(portId)
	local portInfo = self.portTab[portId]
	if portInfo ~= nil then
		return portInfo.status
	end

	return PORT_STATUS_HIDE
end

function ClsWorldMapAttrs:isOpen(portId)
	local status = self:getPortStatus(portId)
	if status == PORT_STATUS_ZHONGLI or status == PORT_STATUS_ZHANLING then
		return true
	end
end

function ClsWorldMapAttrs:initHash()
	self.allPortHash.init = true
	for i,v in pairs(port_info) do
		local key = v.port_pos[1]*mapH + v.port_pos[2]
		self.allPortHash[key] = i
	end
end

function ClsWorldMapAttrs:initShHash()
	if self.hasInitShHash then
		return
	end

	self.hasInitShHash = true

	for i,v in ipairs(pve_stronghold_info) do
		local key = v.point_pos[1]*mapH + v.point_pos[2]
		if not self.shHash[key] then
			self.shHash[key] = {}
		end
		self.shHash[key][#self.shHash[key] + 1] = i
	end
end

function ClsWorldMapAttrs:initWpHash()
	if self.hasInitWpHash then
		return
	end

	self.hasInitWpHash = true

	for i,v in ipairs(explore_whirlpool) do
		local key = v.map_pos[1]*mapH + v.map_pos[2]
		self.wpHash[key] = i
	end
end

-- 构建 运镖任务 哈希表
function ClsWorldMapAttrs:resetCMHash()
	-- print(' ---------------- ClsWorldMapAttrs resetCMHash --------')
	self.cmHash = {} --reset
	local data = getGameData():getConvoyMissionData()
	local list = data:getShowList()
	-- print(' ------------ list --------------- ')
	-- table.print(list)
	for k,v in pairs( list ) do
		if v.cfg then
			local key = v.cfg.position_map[1]*mapH + v.cfg.position_map[2]
			self.cmHash[key] = v.id
		end
	end
end

-- 运镖任务 位置 哈希查找接口
function ClsWorldMapAttrs:getCMIdByPos(pos)
	local key = pos.x*mapH + pos.y
	return self.cmHash[key]
end

-- 构建 世界随机任务 哈希表
function ClsWorldMapAttrs:resetWmHash()
	self.wmHash = {} --reset
	local data = getGameData():getWorldMissionData()
	local list = data:getShowInMapAndSeaList()
	for k,v in pairs( list ) do
		if v.cfg then
			local key = v.cfg.position_map[1]*mapH + v.cfg.position_map[2]
			self.wmHash[key] = v.id
		else
			local id = "unknow"
			if v.id then
				id = v.id
			end
			print('error ClsWorldMapAttrs resetWmHash')
		end
	end
end

-- 世界随机任务 位置 哈希查找接口
function ClsWorldMapAttrs:getWmIdByPos(pos)
	local key = pos.x*mapH + pos.y
	return self.wmHash[key]
end

--已开海上据点位置
function ClsWorldMapAttrs:getShIdsByPos(pos)
	local key = pos.x*mapH + pos.y
	return self.shHash[key]
end

-- 漩涡位置
function ClsWorldMapAttrs:getWpIdByPos(pos)
	local key = pos.x*mapH + pos.y
	return self.wpHash[key]
end

function ClsWorldMapAttrs:getIDByPos(pos)  --
	if not self.allPortHash.init then
		self:initHash()
	end
	local key = pos.x*mapH + pos.y
	return self.allPortHash[key]
end

--是否已开港口位置
function ClsWorldMapAttrs:isPortPos(pos)
	local key = pos.x*mapH + pos.y
	return self.portHash[key]
end

function ClsWorldMapAttrs:tryToEnterDefaultPort()
	do return end

	local port_id = getGameData():getPortData():getPortId()
	self:tryToEnterPort(port_id, 1)
end

function ClsWorldMapAttrs:tryToEnterPort(port_id, is_login)
	local is_login = is_login or 0
	if self.m_is_ask_enter_port then
		ClsAlert:warning({msg = ui_word.PORT_WAITING_PORT_INFO})
		return
	end
	self.m_is_ask_enter_port = true

	GameUtil.callRpc("rpc_server_port_enter", {port_id, is_login})
end

function ClsWorldMapAttrs:setIsAskEnterPort(is_ask_enter_port)
	self.m_is_ask_enter_port = is_ask_enter_port
	if false == self.m_is_ask_enter_port then
		self.m_enter_port_params = {}
	end
end

--告知ui，更新
function ClsWorldMapAttrs:enterPort(portId)
	if portId then
		if self:isNewPort(portId) then
			self:portActive(portId)
		end
	end
end

function ClsWorldMapAttrs:isNewPortPos(pos)  --是否新港口位置
	local key = pos.x*mapH + pos.y
	if self:getIDByPos(pos) and not self:isPortPos(pos) then
		return true
	end
	return false
end

function ClsWorldMapAttrs:isNewPort(portId)
	if portId and port_info[portId] and not self.portTab[portId] then
		return true
	end
	return false
end

function ClsWorldMapAttrs:isMapOpenPort(port_id)
	local net_port_info = self.portTab[port_id]
	if port_id and port_info[port_id] and net_port_info then
		local has_enter = getNumBitValue(net_port_info.open, PORT_MAP_STATE.HAS_ENTER)
		local task_open = getNumBitValue(net_port_info.open, PORT_MAP_STATE.TASK_OPEN)
		local find_open = getNumBitValue(net_port_info.open, PORT_MAP_STATE.NEAR)
		return (has_enter > 0 or task_open > 0 or find_open > 0)
	end
end

--是否有任务港口前置
function ClsWorldMapAttrs:isPreTaskOpenPort(port_id)
	local net_port_info = self.portTab[port_id]
	if port_id and port_info[port_id] and net_port_info then
		if getNumBitValue(net_port_info.open, PORT_MAP_STATE.PRE_TASK) > 0 then
			return true
		end
	end
	return false
end

function ClsWorldMapAttrs:isPortShareReward(port_id)
	local net_port_info = self.portTab[port_id]
	if port_id and port_info[port_id] and net_port_info then
		return net_port_info.rewardTime == 0
	end
	return true
end

--通知客户端，探索到新港口
function ClsWorldMapAttrs:portActive(portId)
	if port_info[portId] then
		self.portTab[portId] = {invest = 0, status = PORT_STATUS_ZHONGLI, open = 0, rewardTime = 0}
		self:setSeaArea(portId)
		local key = port_info[portId].port_pos[1]*mapH + port_info[portId].port_pos[2]
		self.portHash[key] = true
	end
end

--EXPLORE_NAV_TYPE_POS navId:没用， params = {pos = {1,2}, name = "前往个啥"}，params其他类型可以不传，但是EXPLORE_NAV_TYPE_POS一定要，pos是必须的， name是可选的，不写这个 1:2 这样的显示
function ClsWorldMapAttrs:goOutPort(navId, navType, okCallBack, cancalCallBack, params)
	if not getGameData():getBuffStateData():IsCanGoExplore(true) then
		if type(cancalCallBack) == "function" then
			cancalCallBack()
		end
		return
	end

	if not navType then return end

	local exploreMapData = getGameData():getExploreMapData()
	local exploreData = getGameData():getExploreData()
	local supplyData = getGameData():getSupplyData()
	
	local go_out_callback = function(id, type_n, is_ignore_distance)
		local goalInfo = {id = id,navType = type_n}
		if params and type(params) == "table" then
			for k, v in pairs(params) do
				goalInfo[k] = v
			end
		end
		exploreData:setGoalInfo(goalInfo)

		if getGameData():getSceneDataHandler():isInExplore() then
	        EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, table.clone(goalInfo))
	        return
	    end

		local exploreMapData = getGameData():getExploreMapData()
		local cur_click_area_id = exploreMapData:getCurClickAreaId()
		exploreMapData:init() --初始化pve，数据
		exploreMapData:setCurClickAreaId(cur_click_area_id)
		exploreMapData:calcExploreExpectFood(id, type_n)

		if type_n == EXPLORE_NAV_TYPE_NONE then
			exploreData:setTargetPort(id)
			supplyData:startExplore(okCallBack, SUPPLY_GO_SAILING, cancalCallBack, is_ignore_distance)
		elseif type_n == EXPLORE_NAV_TYPE_PORT then
			exploreData:setGoalInfo(goalInfo)
			exploreData:setTargetPort(id)
			supplyData:startExplore(okCallBack, SUPPLY_GO_NOW, cancalCallBack, is_ignore_distance)
		elseif type_n == EXPLORE_NAV_TYPE_SH then
			exploreData:setGoalInfo(goalInfo)
			goalInfo.isSh = true
			supplyData:startExplore(okCallBack, SUPPLY_GO_NOW, cancalCallBack, is_ignore_distance)
		elseif type_n == EXPLORE_NAV_TYPE_POS or type_n == EXPLORE_NAV_TYPE_REWARD_PIRATE or type_n == EXPLORE_NAV_TYPE_SALVE_SHIP then
			supplyData:startExplore(okCallBack, SUPPLY_GO_NOW, cancalCallBack, is_ignore_distance)
		else
			exploreData:setGoalInfo(goalInfo)
			supplyData:startExplore(okCallBack, SUPPLY_GO_NOW, cancalCallBack, is_ignore_distance)
		end
	end
	
	local is_auto_port_reward_status = getGameData():getMissionData():getAutoPortRewardStatus() ---自动悬赏
	if not is_auto_port_reward_status then
		exploreMapData:goMayChangeWhirlHandler(navId, navType, params, function(whirl_id) --go_callback
			go_out_callback(whirl_id, EXPLORE_NAV_TYPE_WHIRLPOOL, true)
		end, function(is_pop_go_whirlpool) --no_change_callback
			-- 缓存传入的坐标信息
			go_out_callback(navId, navType, is_pop_go_whirlpool)
		end, cancalCallBack)
	else
		go_out_callback(navId, navType, true)		
	end

end

---------------------流行商品--------------------
--function ClsWorldMapAttrs:getHotsell()  --流行商品港口请求
	--GameUtil.callRpc("rpc_server_map_hotsell_port", {}, "rpc_client_map_hotsell_port")
--end

function ClsWorldMapAttrs:receiveHotsellFromSer(portList)  --服务器返回
	if portList and #portList then
		self.hotPortGoods = {}
		-- hotGoodToPort = {} --搜索不到这个参数哪里创建哪里调用了
		for i, item in pairs(portList) do --此数值是包括未开放的港口，需过滤
			local id = item.portId
			local pos = ccp(port_info[id].port_pos[1], port_info[id].port_pos[2])
			if self:isPortPos(pos) then
				self.hotPortGoods[id] = {
					goodId = item.goodsId, --保存流行商品id
					amount = nil,
				}
			end
		end
	end
end

function ClsWorldMapAttrs:receiveHotPortGoodsList(portId,goodsList)  --流行商品的的港口的所有商店的所有货物
	local hotPortGood = self.hotPortGoods[portId]
	if hotPortGood then
		for k ,good in pairs(goodsList) do
			if hotPortGood.goodId == good.goodsId then
				hotPortGood.amount = good.amount
				break
			end
		end
	end
end

--是否流行商品的港口
function ClsWorldMapAttrs:getHotPortGood(id)
	return self.hotPortGoods[id]
end

function ClsWorldMapAttrs:getAllHotGoods()
	return self.hotPortGoods
end


function ClsWorldMapAttrs:setSeaArea(portId)  --海域相关
	if port_info[portId] then
		local areaId = port_info[portId].areaId
		if not self.seaArea[areaId] then
			self.seaArea[areaId] = {}
		end
		self.seaArea[areaId][#self.seaArea[areaId] + 1] = portId
	end

	--测试用
	-- self.seaArea[2] = {18}
	-- self.seaArea[3] = {29}
	-- self.seaArea[4] = {41}
	-- self.seaArea[5] = {51}
	-- self.seaArea[6] = {59}
	-- self.seaArea[7] = {67}
end

function ClsWorldMapAttrs:getSeaArea()
	return table.clone(self.seaArea)
end

function ClsWorldMapAttrs:getSeaAreaById(area_id)
	if not self.seaArea or not self.seaArea[area_id] then return end
	return table.clone(self.seaArea[area_id])
end

---------------------------------遗迹数据处理-----------------
function ClsWorldMapAttrs:initRelicHash()
	local explore_map = getUIManager():get("ExploreMap") or getUIManager():get("PortMap")
	local map_height = 0
	local map_tile_size = 0
	local worldmap_relic_sp_scale = 0
	if not tolua.isnull(explore_map) then
		map_height = explore_map.map_height
		map_tile_size = explore_map.map_tile_size
		worldmap_relic_sp_scale = explore_map.worldmap_relic_sp_scale
	end

	local size = map_tile_size * worldmap_relic_sp_scale

	local pos_offset = (map_tile_size - size) / 2
	local rect_info = nil
	local relic_area_info = nil

	self.relicHash["init"] = true
	for i,v in ipairs(relic_info) do
		local key = v.coord[1]*mapH + v.coord[2]
		self.relicHash[key] = i

		rect_info = {id = i}
		
		local x = v.coord[1] * map_tile_size + pos_offset - size/2
		local y = map_height - (v.coord[2]+1) * map_tile_size + pos_offset - size/2

		rect_info.rect = CCRect(x, y, size*2, size*2)
		rect_info.center_x = rect_info.rect.origin.x + rect_info.rect.size.width / 2
		rect_info.center_y = rect_info.rect.origin.y + rect_info.rect.size.height / 2

		relic_area_info = area_info[v.areaId]
		if relic_area_info and
			rect_info.rect.origin.x >= relic_area_info.lbPos[1] and
			(rect_info.rect.origin.x + rect_info.rect.size.width) <= (relic_area_info.lbPos[1] + relic_area_info.width) and
			rect_info.rect.origin.y >= relic_area_info.lbPos[2] and
			(rect_info.rect.origin.y + rect_info.rect.size.height) <= (relic_area_info.lbPos[2] + relic_area_info.height) then
			rect_info.area_id = v.areaId
		end

		self.relic_rect_infos[#self.relic_rect_infos + 1] = rect_info
	end
end

function ClsWorldMapAttrs:getRelicIdByPos(pos)  --从格子位置获取遗迹id
	if not self.relicHash.init then
		self:initRelicHash()
	end
	local key = pos.x*mapH + pos.y
	return self.relicHash[key]
end

function ClsWorldMapAttrs:getRelicRectInfoByPixPos(pos)  --从像素位置获取遗迹区域信息
	if not self.relicHash.init then
		self:initRelicHash()
	end
	local rect_info = nil
	for k,v in ipairs(self.relic_rect_infos) do
		if v.rect:containsPoint(pos) then
			rect_info = v
			break
		end
	end
	return rect_info
end

function ClsWorldMapAttrs:initTimePirvateHash()
	if self.timePirvateHash.init then
		return
	end
	self.timePirvateHash.init = true
	local hash = {}
	for i, v in pairs(getGameData():getExplorePirateEventData():getTimePirateConfig()) do
		local key = v.map_pos[1]*mapH + v.map_pos[2]
		hash[key] = i
	end
	self.timePirvateHash.hash = hash
end

function ClsWorldMapAttrs:getTimePirvateByPos(pos)
	if not self.timePirvateHash.init then
		self:initTimePirvateHash()
	end
	local key = pos.x * mapH + pos.y
	return self.timePirvateHash.hash[key]
end

function ClsWorldMapAttrs:initMineralPointHash()
	if self.mineralPointHash.init then
		return
	end
	self.mineralPointHash.init = true
	local hash = {}
	for i, v in pairs(getGameData():getAreaCompetitionData():getMineralPointConfig()) do
		local key = v.map_pos[1]*mapH + v.map_pos[2]
		hash[key] = i
	end
	self.mineralPointHash.hash = hash
end

function ClsWorldMapAttrs:getMineralPointByPos(pos)
	if not self.mineralPointHash.init then
		self:initMineralPointHash()
	end
	local key = pos.x * mapH + pos.y
	return self.mineralPointHash.hash[key]
end

return ClsWorldMapAttrs




