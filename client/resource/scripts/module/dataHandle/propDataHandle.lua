local treasuremap_info = require("game_config/collect/treasuremap_info")
local ClsAlert = require("ui/tools/alert")
local ClsPropDataHandler = class("propDataHandle")
local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
local ui_word = require("game_config/ui_word")

PROP_BAOWU_ESSENCE = 3
PROP_ITEM_HORN = 5 --喇叭
PROP_ITEM_TREASURE = 80 --藏宝图id
PROP_ITEM_TREASURE_VIP = 164 --高级藏宝图id
PROP_ITEM_JUNIOR_HAMMER = 106 --低级工匠锤
PROP_ITEM_HIGH_HAMMER = 162 --高级工匠锤
PROP_ITEM_MYSTERY_HAMMER = 163 --高级工匠锤

--getGameData():getPropDataHandler()
function ClsPropDataHandler:ctor()
	self.propItems = {}
	self.treasure_item = {}
	self.treasureinfo = nil
	self.treasure_mission_status = false
end

function ClsPropDataHandler:get_propItem_by_id(id)
	return self.propItems[id]
end

function ClsPropDataHandler:get_propItems()
	local tool = require("module/dataHandle/dataTools")

	local propItems = {}
	for k,v in pairs(self.propItems) do
		if v.count > 0 then
			local propItem = table.clone(v)
			propItem.id = k
			propItem.baseData = tool:getItem(ITEM_INDEX_PROP, k)
			if propItem.baseData then
				propItems[#propItems + 1] = propItem
			end
		end
	end
	return propItems
end

function ClsPropDataHandler:getPropItemsByType(prop_type)
	local tool = require("module/dataHandle/dataTools")

	local propItems = {}
	for k,v in pairs(self.propItems) do
		if v.count > 0 then
			local propItem = table.clone(v)
			propItem.id = k
			propItem.baseData = tool:getItem(ITEM_INDEX_PROP, k)--TODO
			if propItem.baseData and propItem.baseData.backpack_type == prop_type then
				propItems[#propItems + 1] = propItem
			end
		end
	end
	return propItems
end

--获取常用道具，主要更具是否消耗判断，暂时是类型为：
--ITEM_USE_TYPE = 1  --图纸类型
--ITEM_USE_BAOWU_BOX = 2  --宝物盒子
function ClsPropDataHandler:getPropItemsCommon()
	local tool = require("module/dataHandle/dataTools")

	local need_use_type = {
		[ITEM_USE_TYPE] = true,
		[ITEM_USE_BAOWU_BOX] = true,
	}
	local propItems = {}
	for k,v in pairs(self.propItems) do
		if v.count > 0 then
			local propItem = table.clone(v)
			propItem.id = k
			propItem.baseData = tool:getItem(ITEM_INDEX_PROP, k)--TODO
			if propItem.baseData then
				if propItem.baseData.backpack_type == PROP_ITEM_BACKPACK_SKIN then
					--print("皮肤道具==================", k)
				elseif need_use_type[propItem.baseData.use_item_type] then
					propItems[#propItems + 1] = propItem
				end
			end
		end
	end
	return propItems
end

function ClsPropDataHandler:get_propItemDic(  )
	return self.propItems
end

function ClsPropDataHandler:set_propItem (id, m_count)
	self.propItems[id] = { count = m_count }
end

function ClsPropDataHandler:add_propItem(id, m_count)
	if not self.propItems[id] then
		self.propItems[id] = { count = m_count }
	else
		self.propItems[id].count = self.propItems[id].count + m_count
	end
end

function ClsPropDataHandler:set_propItem_list(itemList)
	for _, item in pairs(itemList) do
		self:set_propItem(item.id, item.amount)
	end
end

function ClsPropDataHandler:del_propItem_by_id( id, count)
	if self.propItems[id] then
		self.propItems[id].count = self.propItems[id].count - count
		if self.propItems[id].count == 0 then
			self.propItems[id] = nil
		end
	end
end

function ClsPropDataHandler:add_propItem_by_list( list)
	for _, item in pairs(list) do
		self:add_propItem( item.id, item.amount)
	end
end

function ClsPropDataHandler:hasPropItem(id)
	local item = self:get_propItem_by_id(id)
	return item
end

---到据点发送的协议
function ClsPropDataHandler:arriveTreasureItem()
	GameUtil.callRpc("rpc_server_treasure_arrive_destination")
end

function ClsPropDataHandler:setTreasureItem(itemId, count)
	self.treasure_item.treasure_id = itemId
	self.treasure_item.treasure_count = count
end

function ClsPropDataHandler:getTreasureItemCount(item_id)
	if self.propItems[item_id] then
		return self.propItems[item_id].count
	end 
	return 0
end

-----使用道具藏宝图
function ClsPropDataHandler:askTreasureUse(treasure_id)
	--local treasure_id = self.treasure_item.treasure_id
	local on_off_info=require("game_config/on_off_info")

	local status = getGameData():getOnOffData():isOpen(on_off_info.ORGANIZETEAM.value)
	if treasure_id == 164 and not status then
		ClsAlert:warning({msg = ui_word.NO_TEAM_TO_MAP})
		return
	end
	if treasure_id then
		local collectDataHandle = getGameData():getCollectData()
		collectDataHandle:sendUseItemMessage(treasure_id)
	end
end


function ClsPropDataHandler:clearTreasureInfo()
	if self.treasureinfo ~= nil then
		--如果当前场景在探索中，弹出界面提示, “副本已经消失，是否返回出发港口”
		local exploreLayer = getUIManager():get("ExploreLayer")
		if not tolua.isnull(exploreLayer) and IS_AUTO then
			--
			exploreLayer.land:breakAuto()  --取消导航
			EventTrigger(EVENT_EXPLORE_PAUSE)

			--local ui_word = require("game_config/ui_word")
			Alert:showAttention(ui_word.EXPLORE_EVENT_COPY_MISSING, function()
				local portData = getGameData():getPortData()
				EventTrigger(EVENT_EXPLORE_QUICK_ENTER_PORT, portData:getPortId())
			end, function()
				local exploreLayer = getUIManager():get("ExploreLayer")
				exploreLayer:releaseTreasureAuto()
				if not tolua.isnull(self.treasure_layer) then
					self.treasure_layer.closeBtn:touchEndEvent()
				end
			end, nil, {hide_cancel_btn = true})
		end
	end
	
	self.treasureinfo = nil
	local scheduler = CCDirector:sharedDirector():getScheduler()
	if self.hasTreasureInfoHandle then
		scheduler:unscheduleScriptEntry(self.hasTreasureInfoHandle)
		self.hasTreasureInfoHandle = nil
	end
end

function ClsPropDataHandler:getTreasureInfo()
	return self.treasureinfo
end

function ClsPropDataHandler:isUseTreasureMap()
	if self.treasureinfo and self.treasureinfo.treasure_id ~= 0 then
		return true
	end
	return false
end

function ClsPropDataHandler:setTreasureInfo(info)
	self.treasureinfo = info
	self.treasureinfo.end_time = info.time
	self.treasure_mission_status = false
	if info.treasure_id ~= 0 then
		self.use_item_id = info.treasure_id	
		self.treasure_mission_status = true 
	end
end

function ClsPropDataHandler:getTreasureMissionStatus()
	return self.treasure_mission_status 
end

----请求藏宝图信息
function ClsPropDataHandler:askTreasureInfo()
	GameUtil.callRpc("rpc_server_treasure_info", {}, "rpc_client_treasure_info")
end

function ClsPropDataHandler:treasureUI(btn, time)
	local isVisible = false
	if type(btn.label.setString) ~= "function" then
		function btn.label:setString(str)
			btn.label:setText(str)
		end
	end

	if self.treasureinfo then
		time = time or 0
		local dataTools = require("module/dataHandle/dataTools")
		local timeStr = dataTools:getCnTimeStr(time)
		btn.label:setString(timeStr)
		
		btn:setVisible(true)
		isVisible = true
	else
		--local ui_word = require("game_config/ui_word")
		btn.label:setString(ui_word.TREASUREMAP_TIPS)
		
		local treasure_num = self:getTreasureItemCount()
		if treasure_num > 0 then
			btn:setVisible(true)
			isVisible = true
		else
			btn:setVisible(false)
		end
	end
	if isVisible then
		local on_off_info=require("game_config/on_off_info")
		local onOffData = getGameData():getOnOffData()
		onOffData:pushOpenBtn(on_off_info.PORT_TRSASURE_MAP.value, {openBtn = btn})
	end
end


function ClsPropDataHandler:useItemId(item_id)
	self.use_item_id = item_id
end
function ClsPropDataHandler:getUseItemId()
	return self.use_item_id
end

--弹出藏宝图界面
function ClsPropDataHandler:alertTreasureView()	

	local ClsBackpackMainUI = getUIManager():get("ClsBackpackMainUI")     
	if not tolua.isnull(ClsBackpackMainUI) then
		missionSkipLayer:skipLayerByName("treasure_map")  
	end

	local clsActivityMain =  getUIManager():get("ClsActivityMain")
	if not tolua.isnull(clsActivityMain) then
		if self.treasureinfo and self.treasureinfo.treasure_id ~= 0 then
			missionSkipLayer:skipLayerByName("treasure_map")   
		else
			local  function ok_call_back_func()
				if self:getTreasureItemCount(self.use_item_id) > 0 then
					self:askTreasureUse(self.use_item_id)
				else
					ClsAlert:warning({msg = ui_word.TREASUREMAP_ITEM_NO, size = 26})
					if not tolua.isnull(clsActivityMain) then
						clsActivityMain:setTouch(true)
					end
				end         
			end
			local function close_call_back_func()
				if not tolua.isnull(clsActivityMain) then
					clsActivityMain:setTouch(true)
				end
			end
			ClsAlert:showAttention(ui_word.TREASUREMAP_ITEM_TIPS, ok_call_back_func, close_call_back_func)    
		end
	end
	
end


function ClsPropDataHandler:getMapCoord(key)
	local t = treasuremap_info
	local coordnum = self.treasureinfo.positionId or 1
	key = key .. coordnum
	if t[self.treasureinfo.mapId] then 
		return t[self.treasureinfo.mapId][key]
	else
		print("--------服务端发错mapId的时候---对报错的处理")
		return t[1][key]
	end
end

-- 获取藏宝图在藏宝图界面的坐标
function ClsPropDataHandler:getTreasureCoordSmall() --返回像素上的位置
	local key = "small_cd"
	return self:getMapCoord(key)
end

function ClsPropDataHandler:getTreasureCoordBig() -- 返回TileMap上的位置
	local key = "big_cd"
	return self:getMapCoord(key)
end

-- 获取舰队改造物品数量
function ClsPropDataHandler:getFleetReformNum()
	if self:get_propItem_by_id(106) then 
		return self:get_propItem_by_id(106).count
	end 
	return 0
end

-- 获取工匠锤数量
function ClsPropDataHandler:getHammerNum(id)
	if self:get_propItem_by_id(id) then 
		return self:get_propItem_by_id(id).count
	end 
	return 0
end

function ClsPropDataHandler:getCrystalNum(id)
	if self:get_propItem_by_id(id) then
		return self:get_propItem_by_id(id).count
	end
	return 0
end

function ClsPropDataHandler:getPropNumByID(id)
	if self:get_propItem_by_id(id) then
		return self:get_propItem_by_id(id).count
	end
	return 0
end



return ClsPropDataHandler
