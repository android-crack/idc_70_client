local sailor_info = require("game_config/sailor/sailor_info")
local ui_word = require("game_config/ui_word")
local skill_map = require("game_config/battleSkill/skill_map")
local Alert =  require("ui/tools/alert")
local tool = require("module/dataHandle/dataTools")
local composite_effect = require("gameobj/composite_effect")
local on_off_info = require("game_config/on_off_info")
local skill_info = require("game_config/skill/skill_info")
local music_info = require("scripts/game_config/music_info")
local role_info = require("game_config/role/role_info")
local battleRecording = require("gameobj/battle/battleRecording")
local clsVirtualJoystick = require("gameobj/battle/clsVirtualJoystick")
local ClsLitenerAutoLayer = require("gameobj/battle/clsLitenerAutoLayer")
local battle_slogan = require("game_config/battle/battle_slogan")

local voice_info = getLangVoiceInfo()

local HEAD_SIZE_WIDTH, HEAD_SIZE_WIDTH_PARTNER = 36.7, 27.2

local VOICE_NUM = 3 -- 语音的线条数量

local HEAD_POS, HEAD_OFFSET, HEAD_FLAGSHIP_HEIGHT, HEAD_PARTNER_HEIGHT = 490, 5, 50, 40
local HEAD_WIDGET_NAME = 
{
	"dialog",
	"dialog_text",
	"hp",
	"head",
	"head_bg",
	"title",
	"name",
	"select",
}
local JSON_FLAGSHIP, JSON_PARTNER = "json/battle_field_myself.json", "json/battle_field_partner.json"

local ClsBaseView = require("ui/view/clsBaseView")
local FightUI = class("FightUI", ClsBaseView)

local ARROW_UP = 1
local ARROW_DOWN = 2 
local TEST_SPEED_ADD = 50
local TEST_SPEED_SUB = -50
local SPEED_BTN_STATUS = 1
local ROCKER_BTN_STATUS = 1

local GATHER_CD = 10

local run_skill_id = 9001 -- 疾跑技能id

FightUI.getViewConfig = function(self)
	return {
		type = UI_TYPE.VIEW,
		is_swallow = false,
	}
end

FightUI.onEnter = function(self)
	self.dialog_tab = {}

	self.skill_bg = {}
	self.skill_param = {}
	self.skill_progress = {}

	self.sub_enter = {}
	self.show_death = {}

	self.fleet_head = {}
	self.head_action = {}

	self.lock_camera = false		-- 锁定视角
	self.isRunning = true			-- 战斗是否进行中
	self.no_sailor_fight = true		--
	self.lock_update_radar = true 	--
	self.NPC = {}					-- 保存雷达中npc
	self.showParnerTips = {}
	self.rich_labels = {}
	self.skill_effect = {}
	self.voice_list = {}			--正真玩家的list索引是玩家uid
	self.new_skill_effects = {}
	self.layer_prompt = nil
	
	self:initUI()
	self:initJsonUI()
	self:initEvent()
	local battle_data = getGameData():getBattleDataMt()
	local attr = battle_data:GetData("ui_attr")
	if attr and attr.hidden_ui == 1 then
		self:setVisible(false)
		self.uiLayer:setEnabled(false)
	end
	
	self:mkSeaGodUI()

	local auto_trade_data = getGameData():getAutoTradeAIHandler()
	local is_auto_trade = auto_trade_data:inAutoTradeAIRun()

	local missionDataHandler = getGameData():getMissionData()
	local is_auto_status = missionDataHandler:getAutoPortRewardStatus()

	if is_auto_trade or is_auto_status then
		getUIManager():close("ClsChatComponent")
	end
end

FightUI.setShowDeath = function(self, uid, value)
	self.show_death[uid] = value
end

FightUI.isShowDeath = function(self, uid)
	return self.show_death[uid]
end

FightUI.setSubEnter = function(self, uid, value)
	self.sub_enter[uid] = value
end

FightUI.isSubEnter = function(self, uid)
	return self.sub_enter[uid]
end

--海神挑战特殊ui
FightUI.mkSeaGodUI = function(self)
	local battle_data = getGameData():getBattleDataMt()
	local ui_attr = battle_data:GetData("ui_attr")
	self.text_panel = getConvertChildByName(self.uiLayer, "text_panel")
	self.tips_text_1 = getConvertChildByName(self.uiLayer, "tips_text_1")
	self.tips_text_2 = getConvertChildByName(self.uiLayer, "tips_text_2")

	self.text_panel:setVisible(false)
	
	if type(ui_attr.seagod_lv) == "number" then
		self.text_panel:setVisible(true)
		self.sea_god_end_time = ui_attr.seagod_start + ui_attr.seagod_duration
		self.tips_text_2:setText(ui_word.SEA_GOD_TIME..ui_attr.seagod_lv)
		self:refreshSeaGodUI()
	end
end

FightUI.refreshSeaGodUI = function(self)
	local battle_data = getGameData():getBattleDataMt()
	local ui_attr = battle_data:GetData("ui_attr")
	if type(ui_attr.seagod_lv) ~= "number" then return end

	local time = self.sea_god_end_time - (os.time() + getGameData():getPlayerData():getTimeDelta())
	if time <= 0 then
		time = 0
	end
	local str_time = tool:getTimeStrNormal(time, true)
	if tolua.isnull(self.tips_text_1) then return end
	self.tips_text_1:setText(ui_word.SEA_GOD_END_TIME..str_time)
end

FightUI.pauseBattle = function(self)
	self.isRunning = false
	-- self:setTouchEnabled(false)
end

FightUI.resumeBattle = function(self)
	self.isRunning = true
	-- self:setTouchEnabled(true)
end

-- 触摸开关
FightUI.setTouch = function(self, is_touch)
	self.menu:setEnabled(is_touch)
	local battle_data = getGameData():getBattleDataMt()
	local battle_layer = battle_data:GetLayer("battle_scene_layer")
	battle_layer:setTouchEnabled(is_touch)
end

FightUI.initUI = function(self)
	local battle_data = getGameData():getBattleDataMt()
	local ship = battle_data:getCurClientControlShip()
	if ship then
		CameraFollow:LockTarget(ship.body.node)
	end

	if device.platform == "windows" then
		self.btn_scale_big = MyMenuItem.new({image = "#common_btn_blue1.png", imageSelected = "#common_btn_blue2.png", x = 900, y = 310, scale=SMALL_BUTTON_SCALE,
			text = ui_word.BOAT_BIGGER, fsize = 18, fontFile = FONT_BUTTON})
				
		self.btn_scale_big:regCallBack(function()
			local battle_layer = battle_data:GetLayer("battle_scene_layer")
			local curPos = {
					x = display.cx, 
					y = display.cy,
					dis = 105,
				}
			
			local lastPos = {
					x = display.cx,
					y = display.cy,
					dis = 100,
				}
			battle_layer.onMutilTouchMoved( curPos, lastPos)
		end)
		
		
		self.btn_scale_small = MyMenuItem.new({image = "#common_btn_blue1.png", imageSelected = "#common_btn_blue2.png", x = 900, y = 270, scale=SMALL_BUTTON_SCALE,
			text = ui_word.BOAT_SMALLER, fsize = 18, fontFile = FONT_BUTTON})
		
		self.btn_scale_small:regCallBack(function()
			local battle_layer = battle_data:GetLayer("battle_scene_layer")
			local curPos = {
					x = display.cx, 
					y = display.cy,
					dis = 100,
				}
			
			local lastPos = {
					x = display.cx,
					y = display.cy,
					dis = 105,
				}
			battle_layer.onMutilTouchMoved( curPos, lastPos)
		end)
	end

	local menu_t = {}

	if device.platform == "windows" then
		-- menu_t[#menu_t + 1] = self.btn_scale_big
		-- menu_t[#menu_t + 1] = self.btn_scale_small
		self.menu = MyMenu.new(menu_t)
	else
		self.menu = MyMenu.new(menu_t)
	end
	self:addChild(self.menu, 1)

	local achieveData = getGameData():getAchieveData()
	local rewardLayer = achieveData:getRewardLayer()
	rewardLayer:stop()
end

----------------------------------------------------------新UI----------------------------------------------------------

FightUI.initSingleHeadUI = function(self, ship, pos_x, pos_y, index)
	local id = ship:getId()
	local uid = ship:getUid()
	local role = ship:getRole()
	local is_leader = ship:is_leader()
	local sailor_id = ship:getSailorID()

	self.fleet_head[id] = {}

	local panel = GUIReader:shareReader():widgetFromJsonFile(is_leader and JSON_FLAGSHIP or JSON_PARTNER)
	convertUIType(panel)
	self.uiLayer:addChild(panel)

	panel:setPosition(ccp(pos_x, pos_y))

	for _, child_name in ipairs(HEAD_WIDGET_NAME) do
		self.fleet_head[id][child_name] = getConvertChildByName(panel, child_name)
	end

	local battle_data = getGameData():getBattleDataMt()
	local owner_leader_ship = battle_data:getCurClientControlShip()
	if owner_leader_ship == ship then
		local flagship_icon = getConvertChildByName(panel, "flagship_icon")
		flagship_icon:setVisible(true)
	end

	local ship_name = ""
	local sailor_job = 1
	local sailor_res
	if role then
		sailor_job = role_info[role].job_id
		sailor_res = role_info[role].res
	else
		sailor_job = sailor_info[sailor_id].job[1]
		sailor_res = sailor_info[sailor_id].res

		ship_name = sailor_info[sailor_id].name
	end

	local job_bg = SAILOR_JOB_BG[sailor_job].battle
	local scale = 40
	
	if is_leader then
		local voice_item = getConvertChildByName(panel, "voice")
		local volume_list = {}
		for k = VOICE_NUM, 1, -1 do
			local name = string.format("volume_%d", k)
			local volume_item = getConvertChildByName(voice_item, name)
			volume_item:setVisible(false)
			volume_list[k] = volume_item
		end
		voice_item.volume_list = volume_list
		voice_item.action_node = CCNode:create()
		voice_item:addCCNode(voice_item.action_node)
		self:setVoiceAction(voice_item)
		self.voice_list[uid] = voice_item

		ship_name = ship:getFighterName()
		if ship_name == "" then
			ship_name = ship:getName()
		end
		job_bg = SAILOR_JOB_BG[sailor_job].normal
		scale = 60
	else 
		local dialog = getConvertChildByName(panel, "dialog")
		dialog:setVisible(false)
		local dialog_text = getConvertChildByName(panel, "dialog_text")
		self.dialog_tab[id] = {}
		self.dialog_tab[id].dialog = dialog
		self.dialog_tab[id].dialog_text = dialog_text
	end

	self.fleet_head[ship:getId()].name:setText(ship_name)

	self.fleet_head[id].title:setVisible(is_leader)
	if role then
		local nobility_data = getGameData():getNobilityData()
		local nobility_info = nobility_data:getNobilityDataByID(ship:getNobility())
		if nobility_info then
			self.fleet_head[id].title:setVisible(true)
			local title_pic = nobility_info.peerage_before
			self.fleet_head[id].title:changeTexture(convertResources(title_pic), UI_TEX_TYPE_PLIST)
		end
	end
	
	-- 头像背景
	self.fleet_head[id].head_bg:changeTexture(job_bg, UI_TEX_TYPE_PLIST)

	local size = self.fleet_head[id].head_bg:getContentSize()
	self.fleet_head[id].head_bg:setScale(scale/size.width)

	-- 头像
	self.fleet_head[id].head:changeTexture(sailor_res, UI_TEX_TYPE_LOCAL)

	local texture = CCTextureCache:sharedTextureCache():textureForKey(sailor_res)
	size = texture:getContentSize()
	self.fleet_head[id].head:setScale((is_leader and HEAD_SIZE_WIDTH or HEAD_SIZE_WIDTH_PARTNER) / size.width)

	if owner_leader_ship:getUid() ~= uid then
		local hp_res = is_leader and "battle_left_role2.png" or "battle_left_partner2.png"
		self.fleet_head[id].hp:loadTexture(hp_res, UI_TEX_TYPE_PLIST)
	end
	self.fleet_head[id].hp:setPercent(math.floor(ship:getHpRate()*100))

	self.fleet_head[id].select:setVisible(false)

	panel:disable()
	-- if owner_leader_ship:getUid() == uid then
	-- 	if is_leader then
	-- 		self.fleet_head[id].select:setVisible(true)
	-- 	end
	-- 	panel:active()
	-- 	local battle_data = getGameData():getBattleDataMt()
	-- 	local change_ship_key = battle_data:GetData("change_ship_key") or {}
	-- 	change_ship_key["change_ship_" .. index] = id
	-- 	battle_data:SetData("change_ship_key", change_ship_key)

	-- 	panel:addEventListener(function()
 --   			local battle_data = getGameData():getBattleDataMt()
 --   			local ship_id = battle_data:GetData("change_ship_key")["change_ship_" .. index]
 --   			local ship = battle_data:getShipByGenID(ship_id)
 --   			if not ship or ship:is_deaded() then
 --   				Alert:battleWarning({msg = ui_word.BATTLE_SHIP_DEAD})
 --   				return
 --   			end
 --   			if battle_data:isCurClientControlShip(ship_id) then return end
 --   			self:clearSkillEffect()
 --   			battle_data:changeControlShip(ship_id)
 --   		end, TOUCH_EVENT_ENDED)
	-- end
end

FightUI.assembleShips = function(self)
	local battle_data = getGameData():getBattleDataMt()

	if battle_data:isSimilarityBoss() then
		return self:assembleDemoGuildShips()
	end

	local cur_uid = battle_data:getCurClientUid()

	local team_ships = battle_data:GetTeamShips(battle_config.default_team_id, true)

	local tmp_ships = {}
	for k, v in ipairs(team_ships) do
		if not v:isPVEShip() then
			if not tmp_ships[v:getUid()] then
				tmp_ships[v:getUid()] = {}
			end
			if v:is_leader() then
				table.insert(tmp_ships[v:getUid()], 1, v)
			else
				table.insert(tmp_ships[v:getUid()], v)
			end
		end
	end

	local summon_value = battle_data:GetData("battle_field_data").summon_btn

	local addVirtualShip
	addVirtualShip = function(ships, return_ships, cur_client)
		if summon_value ~= BATTLE_ONE_PLAYER then
			local ship_num = summon_value == BATTLE_TWO_PLAYERS and 3 or 2
			for i = #ships + 1, ship_num do
				table.insert(ships, 0)
			end
		end

		if cur_client then
			local count = 1
			for k, ship in ipairs(ships) do
				table.insert(return_ships, count, ship)
				count = count + 1
			end
		else
			for k, ship in ipairs(ships) do
				table.insert(return_ships, ship)
			end
		end
	end

	local return_ships = {}
	for uid, ships in pairs(tmp_ships) do
		addVirtualShip(ships, return_ships, cur_uid == uid)
	end

	return return_ships
end

FightUI.assembleDemoGuildShips = function(self)
	local battle_data = getGameData():getBattleDataMt()

	local ships = {}

	local cur_ship = battle_data:getCurClientControlShip()
	table.insert(ships ,cur_ship)

	local team_ships = battle_data:GetTeamShips(battle_config.default_team_id, true)

	for k, v in ipairs(team_ships) do
		if cur_ship:getUid() == v:getUid() and not v:is_leader() then
			table.insert(ships, v)
			break
		end
	end

	if #ships < 2 then
		table.insert(ships, 0)
	end

	local uid_ships = {
		[1] = {},
		[2] = {}
	}
	for k, v in ipairs(battle_data:GetShips()) do
		local index
		if v:getBaseId() > 7 and v:getBaseId() < 10 then
			index = 1
		elseif v:getBaseId() > 9 and v:getBaseId() < 12 then
			index = 2
		end

		if index then
			if v:is_leader() then
				table.insert(uid_ships[index], 1, v)
			else
				table.insert(uid_ships[index], v)
			end
		end
	end

	for k, v in pairs(uid_ships) do
		for _, ship in ipairs(v) do
			table.insert(ships, ship)
		end
	end

	return ships
end

FightUI.initHeadUi = function(self, battle_type)
	local pos_x, pos_y = 0, HEAD_POS

	local ships = self:assembleShips()
	for k, ship in ipairs(ships) do
		if type(ship) == "table" then
			local offset_y = ship:is_leader() and HEAD_FLAGSHIP_HEIGHT or HEAD_PARTNER_HEIGHT

			pos_y = pos_y - HEAD_OFFSET - offset_y

			self:initSingleHeadUI(ship, pos_x, pos_y, k)
		else
			pos_y = pos_y - HEAD_OFFSET - HEAD_PARTNER_HEIGHT
		end
	end
end

FightUI.setHeadAction = function(self, id, value)
	self.head_action[id] = value
end

FightUI.getHeadAction = function(self, id)
	return self.head_action[id]
end

FightUI.setShipDead = function(self, uid, id)
	local battle_data = getGameData():getBattleDataMt()

	local ship = battle_data:getShipByGenID(id)

	local is_leader = ship:is_leader()

	local onClear
	onClear = function()
		if not is_leader then
			self:setHeadAction(id, false)
		end

		if self.fleet_head and self.fleet_head[id] and self.fleet_head[id].head then 
			self.fleet_head[id].head:setGray(true)
			self.fleet_head[id].hp:setPercent(0)

			local parent = self.fleet_head[id].head:getParent()
			if not tolua.isnull(parent) then
				parent:setOpacity(255/2)
			end
		end

		local battle_data = getGameData():getBattleDataMt()
		local sub_queue = battle_data:GetData("sub_queue")
		if not sub_queue or not sub_queue[id] then return end

		local replace_id = sub_queue[id]

		if is_leader then return end

		self:setSubShipInfo(uid, replace_id, id)
	end
		
	if self.fleet_head and self.fleet_head[id] then 
		local parent = self.fleet_head[id].name:getParent()
		if not tolua.isnull(parent) then
			if not is_leader then
				self:setHeadAction(id, true)
			end

			local size = parent:getContentSize()
			composite_effect.new("tx_death_line", size.width/2, size.height/2, parent, 2, onClear, nil, nil, true)
		end
	end 
end

FightUI.setSubShipInfo = function(self, uid, sub_id, id)
	if not self.fleet_head then return end

	local battle_data = getGameData():getBattleDataMt()

	local sub_boat = battle_data:getShipByGenID(sub_id)

	if not sub_boat then return end

	if not self.fleet_head[id] or tolua.isnull(self.fleet_head[id].name) then 
		local sub_queue = battle_data:GetData("sub_queue") or {}
		sub_queue[id] = sub_id

		battle_data:SetData("sub_queue", sub_queue)
		return 
	end

	-- local change_ship_key = battle_data:GetData("change_ship_key") or {}
	-- for k, v in pairs(change_ship_key) do
	-- 	if v == id then
	-- 		change_ship_key[k] = sub_id
	-- 		break
	-- 	end
	-- end

	self.fleet_head[sub_id] = self.fleet_head[id]
	self.fleet_head[id] = nil

	local root = self.fleet_head[sub_id].name:getParent()
	local size = root:getContentSize()

	local actions = {}
	actions[#actions + 1] = CCMoveBy:create(0.5, ccp(-size.width, 0))
	actions[#actions + 1] = CCCallFunc:create(function()
		if not self.fleet_head or not self.fleet_head[sub_id] then return end

		local parent = self.fleet_head[sub_id].head:getParent()
		if not tolua.isnull(parent) then
			parent:setOpacity(255)
		end

		self.fleet_head[sub_id].head:setGray(false)
		self.fleet_head[sub_id].head:changeTexture(sailor_info[sub_boat.sailor_id].res, UI_TEX_TYPE_LOCAL)

		local texture = CCTextureCache:sharedTextureCache():textureForKey(sailor_info[sub_boat.sailor_id].res)
		self.fleet_head[sub_id].head:setScale(HEAD_SIZE_WIDTH_PARTNER/texture:getContentSize().width)

		self.fleet_head[sub_id].hp:setPercent(math.floor(sub_boat:getHpRate()*100))

		self.fleet_head[sub_id].name:setText(sailor_info[sub_boat.sailor_id].name)
	end)
	actions[#actions + 1] = CCMoveBy:create(0.5, ccp(size.width, 0))
	actions[#actions + 1] = CCCallFunc:create(function()
		self:setHeadAction(id, false)

		local battle_data = getGameData():getBattleDataMt()
		local ship = battle_data:getShipByGenID(id)
		if ship and ship:is_deaded() then
			self:setShipDead(uid, id)
		end
	end)

	self:setHeadAction(id, true)

	root:runAction(transition.sequence(actions))
end

FightUI.judgeEdge = function(self, pos)
	local radar_size = self.radar:getSize()
	local radar_pos = self.radar:getPosition()
	local frame_size = self.select_frame:getContentSize()

	local width_min = radar_pos.x - radar_size.width/2 + frame_size.width/2
	local width_max = radar_pos.x + radar_size.width/2 - frame_size.width/2
	local height_min = radar_pos.y - radar_size.height/2 + frame_size.height/2
	local height_max = radar_pos.y + radar_size.height/2 - frame_size.height/2

	local result = ccp(Math.clamp(width_min, width_max, pos.x), Math.clamp(height_min, height_max, pos.y))

	result.x = result.x - radar_size.width/2
	result.y = result.y - radar_size.height/2

	local node_pos = self.radar:getVirtualRenderer():convertToNodeSpace(result)

	return ccp(math.floor(node_pos.x + 0.5), math.floor(node_pos.y + 0.5))
end

FightUI.initRadar = function(self)
	self.radar = getConvertChildByName(self.uiLayer, "fleet_bg")
	self.radar:setVisible(true)
	self.radar:active()

	self.timeLabel = getConvertChildByName(self.radar, "last_time_num")
	self.timeLabel:setVisible(true)

	local battle_data = getGameData():getBattleDataMt()

	self:Timer(battle_data:GetData("battle_time_from_server"))
	
	local sx, sy = battle_data:GetTable("battle_layer").getSceneSize()
	-- 雷达 和 实际地图的比例
	local radar_pos = self.radar:getPosition()
	local radar_size = self.radar:getSize()
	-- self.radar_width_rate = (radar_size.width - 8)/ sx
	-- self.radar_height_rate = (radar_size.height - 10)/ sy

	-- self.radar_offX = - radar_size.width/2 + 3
	-- self.radar_offY = - radar_size.height/2 + 4

	self.radar_width_rate = radar_size.width/sx
	self.radar_height_rate = radar_size.height/sy
	
	self.radar_offX = - radar_size.width/2
	self.radar_offY = - radar_size.height/2

	local frame = display.newSpriteFrame("battle_radar_frame.png")
	self.select_frame = CCScale9Sprite:createWithSpriteFrame(frame)
	self:setRadarFrameContentSize(sx*BATTLE_SCALE_RATE, sy*BATTLE_SCALE_RATE)
	self.radar:addRenderer(self.select_frame, 2)

	local convertToWorld
	convertToWorld = function(pos)
		local world_pos = cocosToGameplayWorld(ccp((pos.x + radar_size.width/2)/self.radar_width_rate, 
			(pos.y + radar_size.height/2)/self.radar_height_rate))
		CameraFollow:StopShake()
		CameraFollow:SetFreeMove(world_pos)
		self:showBtnViewUnlock()
	end

	if not self.lock_camera then
		self.radar:addEventListener(function()
			local pos = self.radar:getTouchStartPos()
			local node_pos = self:judgeEdge(pos)
			self.select_frame:setPosition(node_pos)

			convertToWorld(node_pos)

			self.lock_update_radar = false
		end, TOUCH_EVENT_BEGAN)

		self.radar:addEventListener(function()
			local pos = self.radar:getTouchMovePos()
			local node_pos = self:judgeEdge(pos)
			self.select_frame:setPosition(node_pos)

			convertToWorld(node_pos)

			self.lock_update_radar = false
		end, TOUCH_EVENT_MOVED)

		self.radar:addEventListener(function()
			self:lockPlayerShip()
			self:updateRadarFrame()
		end, TOUCH_EVENT_ENDED)

		self.radar:addEventListener(function()
			self:lockPlayerShip()
			self:updateRadarFrame()
		end, TOUCH_EVENT_CANCELED)
	end

	self:updataRadar(battle_data:GetShips())
end

FightUI.initBtns = function(self)
	local battle_data = getGameData():getBattleDataMt()

	-- 退出战斗
	self.btn_quit = getConvertChildByName(self.uiLayer, "btn_quit")
	self.btn_quit:setPressedActionEnabled(true)

	self.btn_quit:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)

		local okClickCallBack
		okClickCallBack = function()
			if not battle_data:GetBattleSwitch() then return end
			battleRecording:recordVarArgs("battle_escape")
		end

		Alert:showAttention(ui_word.BATTLE_BREAK, okClickCallBack, nil, nil, {hide_cancel_btn = true})
	end, TOUCH_EVENT_ENDED)

	-- 锁定视角
	self.btn_view_unlock = getConvertChildByName(self.uiLayer, "btn_view_unlock")
	self.btn_view_unlock:setVisible(false)
	-- self.btn_view_unlock:addEventListener(function()
	-- 	self.btn_view_unlock:setOpacity(255)
	-- end, TOUCH_EVENT_BEGAN)
	-- self.btn_view_unlock:addEventListener(function()
	-- 	local pos = self.btn_view_unlock:getTouchMovePos()
	-- 	local b_pos, b_size = self.btn_view_unlock:getPosition(), self.btn_view_unlock:getContentSize()
	-- 	local rect = CCRect(b_pos.x - b_size.width/2, b_pos.y - b_size.height/2, b_size.width, b_size.height)
	-- 	if rect:containsPoint(ccp(pos.x, pos.y)) then
	-- 		self.btn_view_unlock:stopAllActions()
	-- 		self.btn_view_unlock:setOpacity(255)
	-- 	else
	-- 		self:btnViewUnlockAction()
	-- 	end
	-- end, TOUCH_EVENT_MOVED)
	-- self.btn_view_unlock:addEventListener(function()
	-- 	self:lockPlayerShip()
	-- end, TOUCH_EVENT_ENDED)
	
	--自动战斗按钮
	self.btn_auto_fight = getConvertChildByName(self.uiLayer, "btn_auto")
	self.btn_auto_text = getConvertChildByName(self.btn_auto_fight, "auto_text")
	self.btn_auto_fight:setPressedActionEnabled(true)

	local onOffData = getGameData():getOnOffData()

	if onOffData:isOpen(on_off_info.BATTLE_AUTO.value) then 
		self.btn_auto_fight:setVisible(true)
		self.btn_auto_fight:setTouchEnabled(true)
	else
		self.btn_auto_fight:setVisible(false)
		self.btn_auto_fight:setTouchEnabled(false)
	end
	self.btn_auto_fight:addEventListener(function ()
		local ship = battle_data:getCurClientControlShip()
		if not ship or ship:is_deaded() then return end
		ship.body:setPathNode(false)
		if not ship:isAutoFighting() then
			self:setAutoFight()
		else
			self:setHand()
			ship:setAutoFight(false)
		end
	end, TOUCH_EVENT_ENDED)
	local last_fight_type = battle_data:getLastSelectFightType()
	if last_fight_type then
		self:setAutoFight()
	end

	local btn_chat = getConvertChildByName(self.uiLayer, "btn_chat")
	local chat_data = getGameData():getChatData()
	--组队状态下可以语音
	btn_chat:setPressedActionEnabled(true)
	btn_chat:addEventListener(function()
		chat_data:stopRecord()
	end, TOUCH_EVENT_ENDED) --结束录音
	btn_chat:addEventListener(function()
		chat_data:recordMessage(KIND_TEAM)
	end, TOUCH_EVENT_BEGAN)--开始录音

	btn_chat:addEventListener(function()
		chat_data:cancelRecord()
	end, TOUCH_EVENT_CANCELED)--取消录音

	local team_data = getGameData():getTeamData()
	if team_data:isInTeam() then
		btn_chat:setVisible(true)
		btn_chat:setTouchEnabled(true)
	else
		btn_chat:setVisible(false)
	end
	self.btn_chat = btn_chat

	-- 集合按钮
	self.btn_gather = getConvertChildByName(self.uiLayer, "btn_gather")

	local ship = battle_data:getCurClientControlShip()
	local ships = battle_data:GetTeamMemberShip(ship:getUid(), true)
	if #ships < 1 then
		self.btn_gather:setVisible(false)
		return
	end

	self.btn_gather_progress = self:createProgress(self.btn_gather, ccp(-1, -2), "#battle_gather.png", 0.8)

	self.btn_gather_enable = true
	
	self.btn_gather:addEventListener(function()
		if not self.btn_gather_enable then return end

		local ship = battle_data:getCurClientControlShip()

		if not ship or ship:is_deaded() then return end

		local ships = battle_data:GetTeamMemberShip(ship:getUid(), true)

		if #ships < 1 then return end

		audioExt.playEffect(music_info.BT_HAOJIAO.res)

		for k, v in ipairs(ships) do
			v:getBody():resetPath()
			v:tryRunAI("sys_gather")
		end

		self.btn_gather_enable = false

		local action_1 = CCProgressFromTo:create(GATHER_CD, 100, 0)
		local action_2 = CCCallFunc:create(function()
			self.btn_gather_enable = true

			if tolua.isnull(self.btn_gather_progress) then return end

			self.btn_gather_progress:stopAllActions()

			self.btn_gather_progress.label:setString("")
		end)

		self.btn_gather_progress:runAction(CCSequence:createWithTwoActions(action_1, action_2))

		self.btn_gather_cd = GATHER_CD
		self.btn_gather_progress.label:setString(self.btn_gather_cd)

		local action_3 = CCDelayTime:create(1)
		local action_4 = CCCallFunc:create(function()
			if tolua.isnull(self.btn_gather_progress) then return end

			self.btn_gather_cd = self.btn_gather_cd - 1
			self.btn_gather_cd = self.btn_gather_cd < 0 and 0 or self.btn_gather_cd

			self.btn_gather_progress.label:setString(self.btn_gather_cd)
		end)

		self.btn_gather_progress:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(action_3, action_4)))
	end, TOUCH_EVENT_ENDED)
end

FightUI.setAutoFight = function(self)
	local onOffData = getGameData():getOnOffData()

	if not  onOffData:isOpen(on_off_info.BATTLE_AUTO.value) then  return end
	local battle_data = getGameData():getBattleDataMt()
	local ship = battle_data:getCurClientControlShip()
	if not tolua.isnull(self.auto_fight_effect)  then
		self.auto_fight_effect:setVisible(true)
	else
		self.auto_fight_effect = composite_effect.new("tx_0198", 0,0, self.btn_auto_fight, 999, nil, nil,nil, true)
	end
	
	ship:setAutoFight(true)
	self:lockPlayerShip()
	if not tolua.isnull(self.btn_auto_text) then
		self.btn_auto_text:setFocused(true)
		self.btn_auto_text:setText(ui_word.MAIN_CANCEL)
	end

	if self.virtula_joystick and not tolua.isnull(self.virtula_joystick) then
		self.virtula_joystick:giveUp()
	end
end

FightUI.addNewSkillEffect = function(self, skill_id, pos, btn_panel)
	if not self[skill_id.."muisc"] then
		audioExt.playEffect(music_info.NEW_SKILL_UNLOCK.res)
		self[skill_id.."muisc"] = true
	end

	btn_panel.new_skill_effect = composite_effect.new("tx_new_skill", pos.x - 40, pos.y - 40, self)

	local tx_1042_5 = composite_effect.new("tx_1042_5", 0, 0, btn_panel.new_skill_effect)

	local skill_res = skill_info[skill_id].res
	local skill_bg = display.newSprite(skill_res)

	btn_panel.new_skill_effect:addChild(skill_bg, 999)

	local titile = getChangeFormatSprite("ui/txt/txt_new_skill.png")
	titile:setPosition(display.cx, display.cy - 50)
	self:addChild(titile)

	local array = CCArray:create()
	array:addObject(CCDelayTime:create(2))
	array:addObject(CCCallFunc:create(function()
		titile:removeFromParentAndCleanup(true)
	end))

	titile:runAction(CCSequence:create(array))
end

FightUI.createProgress = function(self, parent, pos, res, scale)
	local shadow = display.newSprite("#battle_skill_shadow.png")
	local skill_progress = CCProgressTimer:create(shadow)
	skill_progress:setType(kCCProgressTimerTypeRadial)
	skill_progress:setReverseProgress(true)
	skill_progress:setPercentage(0)
	parent:addRenderer(skill_progress, 2)

	skill_progress:setScale(scale or 1)

	pos = pos or ccp(0, 0)
	skill_progress:setPosition(pos.x, pos.y)

	local sprite = display.newSprite(res)
	sprite:setPosition(pos.x, pos.y)
	parent:addRenderer(sprite, 1)

	skill_progress.sprite = sprite

	local label = createBMFont({text = "", size = 20})
	label:setPosition(pos.x, pos.y)
	parent:addRenderer(label, 3)

	skill_progress.label = label

	return skill_progress
end

FightUI.initSkillUi = function(self, new_skill_id)
	-- 技能
	local battle_data = getGameData():getBattleDataMt()
	local ship = battle_data:getCurClientControlShip()

	if not ship or ship:is_deaded() then return end

	local sort_skills = battle_data:GetData(ship.baseData.boat_key)

	if not sort_skills then return end

	if self.skill_progress then
		for k, v in pairs(self.skill_progress) do
			if v.sprite then
				v.sprite:removeFromParentAndCleanup(true)
				v.label:removeFromParentAndCleanup(true)
			end
			v:removeFromParentAndCleanup(true)
			v = nil
		end
	end
	if self.skill_param then
		for k, v in pairs(self.skill_param) do
			v.skill_text:setVisible(false)
			v.skill_icon_bg:setVisible(false)
			v.skill_passivity_bg:setVisible(true)
		end
	end

	self.skill_progress = {}
	self.skill_param = {}

	local setSkill
	setSkill = function(parent, index, skill_id, skillData)
		if index > 4 then return end

		if skill_id then
			local skill_ex_id = skill_info[skill_id].skill_ex_id

			local skill_bg = self.skill_bg[index]

			local initiative = skillData.baseData.initiative
			local btn_skill = getConvertChildByName(skill_bg, "btn_skill_" .. index)

			local skill_pos = btn_skill:getPosition()

			local pos = btn_skill:convertToWorldSpace(skill_pos)
			local size = btn_skill:getContentSize()
			btn_skill:setEnabled(true)
			btn_skill:addEventListener(function()
				self:doShowSkillTip(pos.x - size.width - 20, pos.y - size.height, skill_id)
				local ship = battle_data:getCurClientControlShip() --在这里获取船，防止使用upvalue引用住船导致没释放
				if not ship or ship:is_deaded() then return end
				if initiative == SKILL_INITIATIVE and not ship:isAutoFighting() then
					skill_bg:setScale(0.98)
				end

				local cls_skill = skill_map[skill_ex_id]
				local skill_level = cls_skill:get_skill_lv(ship)
				local range = cls_skill:get_limit_distance_max(ship, skill_level)

				local skill_series = cls_skill:get_skill_series()
				if skill_series > 0 and skill_series < 100 then
					local common_cd = ship:get_common_skill_cd()
					if common_cd and common_cd > 0 then 
						return
					end

					local cur_cd = ship:get_skill_cd(skill_ex_id)
					if cur_cd and cur_cd > 0 then 
						return
					end

					cls_skill:ShowUnSelectSkillPerfrom(ship)
					-- self:updateDir(ship, cls_skill)
				end

				if range < 2000 then 
					ship.body:showSkillRange(range, skill_series)
				end
			end, TOUCH_EVENT_BEGAN)

			btn_skill:addEventListener(function()
				local move_pos = btn_skill:getTouchMovePos()
				local rect = CCRect(pos.x - size.width, pos.y - size.height, size.width, size.height)
				local ship = battle_data:getCurClientControlShip() --在这里获取船，防止使用upvalue引用住船导致没释放
				if not ship or ship:is_deaded() then return end
				if initiative == SKILL_INITIATIVE and not ship:isAutoFighting() then
					if rect:containsPoint(ccp(move_pos.x, move_pos.y)) then
						skill_bg:setScale(0.98)
					else
						skill_bg:setScale(1.0)
					end
				end
			end, TOUCH_EVENT_MOVED)

			btn_skill:addEventListener(function()
				local cls_skill = skill_map[skill_ex_id]
				local skill_series = cls_skill:get_skill_series()
				local ship = battle_data:getCurClientControlShip() --在这里获取船，防止使用upvalue引用住船导致没释放
				if not ship or ship:is_deaded() then return end
				if skill_series > 0 and skill_series < 100 then
					cls_skill:removeUnSelectSkillPerfrom(ship)
				end
				if initiative == SKILL_INITIATIVE and not ship:isAutoFighting() then
					skill_bg:setScale(1.0)
					ship:UseSkill(skill_id)
				end
				self:dismissSkillTip()
				ship.body:dismissSkillRange()
				if btn_skill.new_skill_effect then
					btn_skill.new_skill_effect:removeFromParentAndCleanup(true)
					btn_skill.new_skill_effect = nil
				end
			end, TOUCH_EVENT_ENDED)
			
			btn_skill:addEventListener(function ( )
				self:dismissSkillTip()
				local ship = battle_data:getCurClientControlShip() --在这里获取船，防止使用upvalue引用住船导致没释放
				if not ship or ship:is_deaded() then return end
				ship.body:dismissSkillRange()
				local cls_skill = skill_map[skill_ex_id]
				local skill_series = cls_skill:get_skill_series()
				if skill_series > 0 and skill_series < 100 then
					cls_skill:removeUnSelectSkillPerfrom(ship)
				end
			end, TOUCH_EVENT_CANCELED)

			self.skill_progress[skill_ex_id] = self:createProgress(skill_bg, skill_pos, skill_info[skill_id].res)

			if skill_id == new_skill_id then
				self:addNewSkillEffect(skill_id, pos, btn_skill) --新技能特效
			end

			local passive = false

			local skill_passivity_bg = getConvertChildByName(skill_bg, "skill_passivity_bg_" .. index)
			local skill_icon_bg = getConvertChildByName(skill_bg, "skill_icon_bg_" .. index)
			local skill_text = getConvertChildByName(skill_bg, "skill_text_" .. index)

			if initiative == SKILL_AURA or initiative == SKILL_AURA_JUST_DISPLAY then
				skill_text:setVisible(true)
				passive = true
			elseif initiative == SKILL_INITIATIVE then
				skill_icon_bg:setVisible(true)
				skill_passivity_bg:setVisible(false)
			end
			
			self.skill_param[skill_ex_id] = {sp = btn_skill, passive = passive, skill_bg = skill_bg,
				skill_text = skill_text, skill_icon_bg = skill_icon_bg, skill_passivity_bg = skill_passivity_bg, sprite = sprite}
		end
	end

	if #self.skill_bg == 0 then
		for i = 1, 4 do
			self.skill_bg[#self.skill_bg + 1] = getConvertChildByName(self.uiLayer, "skill_bg_" .. i)
		end
		self.skill_bg[#self.skill_bg + 1] = getConvertChildByName(self.uiLayer, "btn_fire")
	end

	for i, skill_id in pairs(sort_skills) do
		if skill_id == run_skill_id then
			local skill_bg = self.skill_bg[#self.skill_bg]
			skill_bg:setVisible(true)

			self.skill_progress["sk4001"] = self:createProgress(skill_bg, ccp(-2, 0), skill_info[skill_id].res, 1.2)

			if skill_id == new_skill_id then
				local pos = skill_bg:getPosition()
				pos = ccp(pos.x + 40, pos.y + 40)
				self:addNewSkillEffect(skill_id, pos, skill_bg)
			end

			skill_bg:setPressedActionEnabled(true)
			skill_bg:addEventListener(function()
				if not skill_bg:isVisible() then return end

				local ship = battle_data:getCurClientControlShip()

				if not ship or ship:is_deaded() then return end

				ship:UseSkill(run_skill_id)
				
				if skill_bg.new_skill_effect then
					skill_bg.new_skill_effect:removeFromParentAndCleanup(true)
					skill_bg.new_skill_effect = nil
				end
			end, TOUCH_EVENT_ENDED)
		else
			setSkill(self.uiLayer, i, skill_id, ship.skills[skill_id])
		end
	end

	self:setCommonSkillCD()
end

FightUI.updateDir = function(self, ship, skill)
	local lv = skill:get_skill_lv(ship)
	local targets = skill:selectTargetEnemy(ship, ship:getTarget(), lv, 1, "DISTANCE")
	local dir
	if #targets == 0 then
		print("走到了这里说明是没有目标的---")
		dir = ship:getBody().node:getForwardVectorWorld():normalize()
	else
		local target = targets[1]
		local v1 = ship:getBody().node:getTranslationWorld()
		local v2 = target:getBody().node:getTranslationWorld()
		local forward = Vector3.new()
		Vector3.subtract(v2, v1, forward)
		dir = forward:normalize()
	end
	
	ship.body:updateSkillRankDirection(dir)
end

FightUI.initKillUi = function(self)
	--剩余血条
	-- local hp_panel = GUIReader:shareReader():widgetFromJsonFile("json/battle_hp.json")
	-- convertUIType(hp_panel)
	
	-- local bar_residue = getConvertChildByName(hp_panel, "battle_hp_progress")
	-- local residue_num = getConvertChildByName(hp_panel, "residue_num")
	local GuildBossData = getGameData():getGuildBossData()
	local group_boss_info =  GuildBossData:getGroupBossInfo()
	local cur_amount = GuildBossData:getRemianPirateAmount()
	local max_amount = GuildBossData:getBossMaxAmount()
	-- residue_num:setText(cur_amount)
	-- bar_residue:setPercent(100 * (cur_amount / max_amount))
	-- hp_panel:setPosition(ccp(270 , 485))

	--积分排行榜
	local rank_panel = GUIReader:shareReader():widgetFromJsonFile("json/battle_info.json")
	convertUIType(rank_panel)
	self.rank_panel = rank_panel
	self:addWidget(rank_panel)

	rank_panel.name = "battle_info"
	local sailor_1 = getConvertChildByName(rank_panel, "head_icon_1")
	local sailor_2 = getConvertChildByName(rank_panel, "head_icon_2")
	sailor_1:changeTexture(sailor_info[6].res)
	sailor_2:changeTexture(sailor_info[28].res)
	local bg = getConvertChildByName(rank_panel, "backgroud")
	bg:setPosition(ccp(display.cx + 181, 139))
	local btn_touch_switch = getConvertChildByName(rank_panel, "btn_arrow")
	local btn_switch = MyMenuItem.new({image = "#battle_rank_btn.png", x = btn_touch_switch:getPosition().x, y = btn_touch_switch:getPosition().y})
	btn_switch:setNodeSize(CCSize(50, 50))
	local menu = MyMenu.new({btn_switch})
	btn_touch_switch:getParent():addCCNode(menu)
	btn_touch_switch:setVisible(false)
	local guild_boss_data = getGameData():getGuildBossData()
	local switch = guild_boss_data:getBossTipsStatus()
	if switch then
		guild_boss_data:setBossTipsStatus(not switch)
	end
	switch = guild_boss_data:getBossTipsStatus()
	btn_switch:setFlipY(false)
	bg:setPosition(ccp(display.cx + 181,  -114))
	rank_panel.backgroud = bg
	
	btn_switch:regCallBack(function() 
		btn_switch:setEnabled(false)
		local actions = CCArray:create()
		if switch then
			actions:addObject(CCEaseBackOut:create(CCMoveTo:create(0.5, ccp(display.cx + 181,  -114))))
		else
			actions:addObject(CCEaseBackIn:create(CCMoveTo:create(0.5, ccp(display.cx + 181,  139))))
		end
		actions:addObject(CCCallFunc:create(function() 
			btn_switch:setFlipY(switch)
			btn_switch:setEnabled(true)
		end))
		switch = not switch
		guild_boss_data:setBossTipsStatus(switch)
		bg:runAction(CCSequence:create(actions))
	end)

	local general_pirate_kill_num = GuildBossData:getGeneralPirateKillNum()
	local advanced_pirate_kill_num = GuildBossData:getAdvancePirateKillNum()
	local myself_kill_num_1 = getConvertChildByName(rank_panel, "kill_num_1")
	local myself_kill_num_2 = getConvertChildByName(rank_panel, "kill_num_2")
	myself_kill_num_1:setText(general_pirate_kill_num or 0)
	myself_kill_num_2:setText(advanced_pirate_kill_num or 0)
	
	local myself_rank = getConvertChildByName(rank_panel, "my_rank_num")
	local my_rank_info = GuildBossData:getMyRank()
	local base_point = 0
	if my_rank_info then
		base_point = my_rank_info.point
		myself_rank:setText(my_rank_info.rank)
	else
		myself_rank:setText(0)
	end

	local kill_node = {}
	local kill_name_1 = getConvertChildByName(rank_panel, "rank_name_1")
	local kill_name_2 = getConvertChildByName(rank_panel, "rank_name_2")
	local kill_name_3 = getConvertChildByName(rank_panel, "rank_name_3")
	local kill_point_1 = getConvertChildByName(rank_panel, "point_1")
	local kill_point_2 = getConvertChildByName(rank_panel, "point_2")
	local kill_point_3 = getConvertChildByName(rank_panel, "point_3")
	local kill_rank_1 = getConvertChildByName(rank_panel, "rank_num_1")
	local kill_rank_2 = getConvertChildByName(rank_panel, "rank_num_2")
	local kill_rank_3 = getConvertChildByName(rank_panel, "rank_num_3")

	kill_node[#kill_node + 1] = {name = kill_name_1, point = kill_point_1, rank = kill_rank_1}
	kill_node[#kill_node + 1] = {name = kill_name_2, point = kill_point_2, rank = kill_rank_2}
	kill_node[#kill_node + 1] = {name = kill_name_3, point = kill_point_3, rank = kill_rank_3}

	local rankData = GuildBossData:getFightingRanks()
	for i = 1, #kill_node do
		local name = ""
		local point = ""
		if rankData[i] then
			name = rankData[i].name
			point = rankData[i].point
			kill_node[i].name:setVisible(true)
			kill_node[i].point:setVisible(true)
		else
			kill_node[i].name:setVisible(false)
			kill_node[i].point:setVisible(false)
		end
		kill_node[i].name:setText(name)
		kill_node[i].point:setText(point)
	end

	local lbl_my_point = getConvertChildByName(rank_panel, "point_me")
	lbl_my_point:setVisible(true)
	lbl_my_point:setText(base_point)
	RegTrigger(EVENT_BATTLE_SET_DATA, function(name, data) 
		if tolua.isnull(self) then return end

		local battle_data = getGameData():getBattleDataMt()
		local GuildBossData = getGameData():getGuildBossData()
		local general_pirate_kill_num = GuildBossData:getGeneralPirateKillNum()
		local advanced_pirate_kill_num = GuildBossData:getAdvancePirateKillNum()
		local pirate_cnt = battle_data:GetData("__pirate_cnt") or 0
		local sup_pirate_cnt = battle_data:GetData("__sup_pirate_cnt") or 0
		local difficulty = GuildBossData:getCurDifficulty()
		local guild_boss_battle = require("game_config/guild/guild_boss_battle")
		local bossConfig = guild_boss_battle[GuildBossData:getGroupBossInfo().bossId]
		if name and name == "__pirate_cnt" then
			local group_boss_info =  GuildBossData:getGroupBossInfo()
			local curAmount = cur_amount - pirate_cnt * bossConfig["pirate_num_" .. difficulty] - sup_pirate_cnt * bossConfig["pirate_num_" .. difficulty]
			if curAmount < 0 then
				curAmount = 0
			end
			-- bar_residue:setPercent(100 * (curAmount / max_amount))
			local bass_pirate = bossConfig["pirate_num_" .. difficulty]
			lbl_my_point:setText(base_point + pirate_cnt * bossConfig["pirate_" .. difficulty] * bass_pirate + sup_pirate_cnt * bossConfig["high_pirate_" .. difficulty] * bass_pirate)
			myself_kill_num_1:setText(myself_kill_num_1:getStringValue() + bass_pirate)
			-- residue_num:setText(curAmount)
		end
		if name and name == "__sup_pirate_cnt" then
			local group_boss_info =  GuildBossData:getGroupBossInfo()
			local curAmount = cur_amount - pirate_cnt * bossConfig["pirate_num_" .. difficulty] - sup_pirate_cnt * bossConfig["pirate_num_" .. difficulty]
			if curAmount < 0 then
				curAmount = 0
			end
			-- bar_residue:setPercent(100 * (curAmount / max_amount))
			local bass_pirate = bossConfig["pirate_num_" .. difficulty]
			lbl_my_point:setText(base_point + pirate_cnt * bossConfig["pirate_" .. difficulty] * bass_pirate + sup_pirate_cnt * bossConfig["high_pirate_" .. difficulty] * bass_pirate)
			myself_kill_num_2:setText(myself_kill_num_2:getStringValue() + bass_pirate)
			-- residue_num:setText(curAmount)
		end
	end, "battle_ui")

	RegTrigger(EVENT_BATTLE_GUILD_BOSS_PIRATE_KILL_UPDATE, function(general_pirate_kill_num, advanced_pirate_kill_num) 
		if tolua.isnull(self) then return end
		myself_kill_num_1:setText(general_pirate_kill_num)
		myself_kill_num_2:setText(advanced_pirate_kill_num)
	end, "battle_ui")

	RegTrigger(EVENT_BATTLE_GUILD_BOSS_FLUSH_CURAMOUNT, function(rank)
		if tolua.isnull(self) then return end
		local GuildBossData = getGameData():getGuildBossData()
		local group_boss_info =  GuildBossData:getGroupBossInfo()
		local battle_data = getGameData():getBattleDataMt()
		local pirate_cnt = battle_data:GetData("__pirate_cnt") or 0
		local sup_pirate_cnt = battle_data:GetData("__sup_pirate_cnt") or 0
		local curAmount = cur_amount - pirate_cnt - sup_pirate_cnt
		if curAmount < 0 then
			curAmount = 0
		end
		-- bar_residue:setPercent(100 * (curAmount / max_amount))
		-- residue_num:setText(curAmount)
	end)
end

FightUI.initDemoGuildBossFightUI = function(self)
	local battle_data = getGameData():getBattleDataMt()
	local guild_boss_data = getGameData():getGuildBossData()
	guild_boss_data:initTempData()
	battle_data:SetData("sup_killer_tbl", {})
	battle_data:SetData("killer_tbl", {})
	
	local hp_panel = GUIReader:shareReader():widgetFromJsonFile("json/battle_hp.json")
	convertUIType(hp_panel)
	local bar_residue = getConvertChildByName(hp_panel, "battle_hp_progress")
	local residue_num = getConvertChildByName(hp_panel, "residue_num")
	local max_hp = guild_boss_data:getTempBossMaxHP()
	local cur_hp = guild_boss_data:getTempBossCurHP()
	bar_residue:setPercent(100 * (cur_hp / max_hp))
	residue_num:setText(cur_hp)
	hp_panel:setPosition(ccp(270 , 485))
	self:addWidget(hp_panel)
		
	--演示商会boss战斗UI
	local panel = GUIReader:shareReader():widgetFromJsonFile("json/battle_info_boss.json")
	convertUIType(panel)
	self.rank_panel = panel
	self:addWidget(panel)

	panel.name = "battle_info_boss"

	local widget_info = {
		[1] = {name = "btn_arrow"},
		[2] = {name = "btn_close"},
		[3] = {name = "my_rank_num"},
		[4] = {name = "my_grade_num"},
		[5] = {name = "backgroud"},
	}

	for k, v in ipairs(widget_info) do
		local item = getConvertChildByName(panel, v.name)
		panel[v.name] = item
	end
	panel.my_grade_num:setText(0)
	panel.my_rank_num:setText(0)

	--重新定义关闭按钮的setVisible方法
	local temp_func = panel.btn_close.setVisible
	panel.btn_close.setVisible = function(self, enable)
		temp_func(self, enable)
		self:setTouchEnabled(enable)
	end

	panel.btn_arrow.status = ARROW_UP
	panel.backgroud:setPosition(ccp(display.cx + 181,  -114))
	panel.btn_arrow:addEventListener(function()
		local btn_arrow = panel.btn_arrow
		btn_arrow:setTouchEnabled(false)
		panel.btn_close:setVisible(false)
		local status = btn_arrow.status
		local actions = CCArray:create()
		if status == ARROW_DOWN then
			actions:addObject(CCEaseBackOut:create(CCMoveTo:create(0.5, ccp(display.cx + 181,  -114))))
		else
			actions:addObject(CCEaseBackIn:create(CCMoveTo:create(0.5, ccp(display.cx + 181,  139))))
		end
		actions:addObject(CCCallFunc:create(function()
			btn_arrow.status = (status == ARROW_DOWN) and ARROW_UP or ARROW_DOWN
			btn_arrow:setFlipY(not btn_arrow:isFlipY())
			btn_arrow:setTouchEnabled(true)
			panel.btn_close:setVisible(btn_arrow.status == ARROW_DOWN)
		end))
		panel.backgroud:runAction(CCSequence:create(actions))
	end, TOUCH_EVENT_ENDED)

	panel.btn_close:setPressedActionEnabled(true)
	panel.btn_close:setVisible(false)
	panel.btn_close:addEventListener(function() 
		local btn_close = panel.btn_close
		btn_close:setVisible(false)
		panel.btn_arrow:executeEvent(TOUCH_EVENT_ENDED)
	end, TOUCH_EVENT_ENDED)

	local INFO_NUM = 3
	local rank_nodes = {}
	for k = 1, 3, 1 do
		local node = {}
		local rank_name = string.format("rank_num_%s", k)
		local rank_player_name = string.format("rank_name_%s", k)
		local point_name = string.format("point_%s", k)
		local rank_item = getConvertChildByName(panel, rank_name)
		local point_item = getConvertChildByName(panel, point_name)
		local name_item = getConvertChildByName(panel, rank_player_name)
		point_item:setVisible(false)
		name_item:setVisible(false)
		node = {name = name_item, point = point_item, rank = rank_item}
		rank_nodes[#rank_nodes + 1] = node
	end

	RegTrigger(EVENT_BATTLE_SET_DATA, function(name, data) 
		if tolua.isnull(self) then return end
		local battle_data = getGameData():getBattleDataMt()
		local guild_boss_data = getGameData():getGuildBossData()
		
		local self_uid = getGameData():getPlayerData():getUid()
		local killer_list = battle_data:GetData("killer_tab") or {}
		local sup_killer_tbl = battle_data:GetData("sup_killer_tbl") or {}
		local max_hp = guild_boss_data:getTempBossMaxHP()
		local cur_hp = guild_boss_data:getTempBossCurHP()
		if cur_hp < 0 then
			cur_hp = 0
		end
		bar_residue:setPercent(100 * (cur_hp / max_hp))
		residue_num:setText(cur_hp)

		--排名tempSortRank
		local rank_data = guild_boss_data:getTempRank()
		for k = 1, #rank_nodes do
			local node = rank_nodes[k]
			local name = ""
			local point = ""
			if rank_data[k] then
				name = rank_data[k].name
				point = rank_data[k].rank
				node.name:setVisible(true)
				node.point:setVisible(true)
			else
				node.name:setVisible(false)
				node.point:setVisible(false)
			end
			node.name:setText(name)
			node.point:setText(point)
		end
		local my_rank = guild_boss_data:getMyTempRank()
		local my_temp_info = guild_boss_data:getMyTeampInfo()
		panel.my_grade_num:setText(my_temp_info.rank)
		panel.my_rank_num:setText(my_rank)
	end, "battle_ui")
end

--提供外部ai调用
FightUI.showKillRankUI = function(self)
	local panel = self.rank_panel

	if not panel or tolua.isnull(panel) then return end

	if panel.name == "battle_info" then
		local guild_boss_data = getGameData():getGuildBossData()
		local switch = guild_boss_data:getBossTipsStatus()	
		local actions = CCArray:create()
		if not switch then
			actions:addObject(CCEaseBackIn:create(CCMoveTo:create(0.5, ccp(display.cx + 181,  139))))
			switch = not switch
			panel.backgroud:runAction(CCSequence:create(actions))
		end
		guild_boss_data:setBossTipsStatus(switch)
	else
		if panel.btn_arrow.status == ARROW_DOWN then return end
		panel.btn_arrow:executeEvent(TOUCH_EVENT_ENDED)
	end
end

FightUI.initPlunderSilver = function(self)
	self.cion_bar_bg = getConvertChildByName(self.uiLayer, "cion_bar_bg")
	self.cion_bar_bg:setVisible(true)
	self.explore_plunder_silver = {}
	self.explore_plunder_silver.progress = getConvertChildByName(self.cion_bar_bg, "cion_bar")
	self.explore_plunder_silver.num_label = getConvertChildByName(self.cion_bar_bg, "cion_num")
	self.explore_plunder_silver.num_label:setText("0")
	self.explore_plunder_silver.progress:setPercent(0)
end

FightUI.initJsonUI = function(self)
	self.uiLayer = GUIReader:shareReader():widgetFromJsonFile("json/battle_field.json")
	convertUIType(self.uiLayer)
	self:addWidget(self.uiLayer)

	local win_tips_panel = getConvertChildByName(self.uiLayer, "win_tips_panel")
	win_tips_panel:setVisible(false)

	self.combo_light = getConvertChildByName(self.uiLayer, "combo_light")
	self.combo_num = getConvertChildByName(self.combo_light, "combo_num")
	self.combo_num:setText(0)

	local battle_data = getGameData():getBattleDataMt()
	local battle_field_data = battle_data:GetData("battle_field_data")
	local battle_type = battle_field_data.fight_type    

	self.virtula_joystick = clsVirtualJoystick.new()
	self:addChild(self.virtula_joystick)
	-- self:regTouchEvent(self.virtula_joystick, function(event, x, y)
	-- 	if tolua.isnull(self.virtula_joystick) then return end
	-- 	return self.virtula_joystick:onTouch(event, x, y)
	-- end)

	self.litener_auto_layer = ClsLitenerAutoLayer.new()
	self:addChild(self.litener_auto_layer)
	self:regGuildPassTouchEvent(self.litener_auto_layer, function(event, x, y)
		if tolua.isnull(self.litener_auto_layer) then return end
		return self.litener_auto_layer:onTouch(event, x, y)
	end, 1)

	---用于ce测试
	--======================================================
	local battle_ui_attr_data = battle_data:GetData("ui_attr")
	local rocker_ui_data = battle_ui_attr_data.ce_test_rocker
	local speed_ui_data = battle_ui_attr_data.ce_test_speed

	----速度按钮
	if speed_ui_data  == SPEED_BTN_STATUS then
		--self:initBoatSpeedBtn()
		getGameData():getBattleDataMt():setSpeedForTest(TEST_SPEED_ADD)
	end

	----摇杆按钮
	if rocker_ui_data == ROCKER_BTN_STATUS then
		--self:initRockerBtn()
		self.virtula_joystick:setVisible(false)
	end
	--======================================================

	if not battle_data:isDemo() then
		-- 左侧舰队头像
		self:initHeadUi(battle_type)
		-- 按钮
		self:initBtns()
		-- 右下技能
		self:initSkillUi()

		if battle_type == battle_config.fight_type_guild_boss then
			self:initKillUi()
		elseif battle_data:isSimilarityBoss() then
			self:initDemoGuildBossFightUI()
		end
	else
		getConvertChildByName(self.uiLayer, "btn_quit"):setVisible(false)

  --  		local btn_back = MyMenuItem.new({image = "#battle_btn_quit.png", x = 73, y = 512, text = ui_word.TASK_SKIP, 
  --  			fsize = 16, fontFile = FONT_BUTTON})
  --  		local skip_menu = MyMenu.new({btn_back}, TOUCH_PRIORITY_MORE_HIGHT)
		-- self:addChild(skip_menu, 10)
		-- btn_back:regCallBack(function()
		-- 	btn_back:setEnabled(false)
		-- 	battleRecording:recordVarArgs("battle_escape")
		-- 	battle_data:GetTable("battle_layer").setBattlePaused(true)
		-- end)
	end

	if battle_type == battle_config.fight_type_plunder and battle_tag == 1 then
		self:initPlunderSilver()
	end
	-- 战场小地图
	self:initRadar()
	self:initZoomUI(self.uiLayer)
end

---控制摇杆按钮
FightUI.initRockerBtn = function(self)
	local rocker_btn = MyMenuItem.new({text = ui_word.BATTLE_ROCKER, image = "#common_btn_circle.png", imageSelected = "#common_btn_circle.png",
				x = display.cx - 130, y = display.top - 30})
	rocker_btn:regCallBack( function()
		self.virtula_joystick:setTouchEnabled( not self.virtula_joystick:isVisible())		
		self.virtula_joystick:setVisible( not self.virtula_joystick:isVisible())
	end)

	local menu=MyMenu.new({rocker_btn}, TOUCH_PRIORITY_MORE_HIGHT)
	self:addChild(menu,1)
end

---船速按钮
FightUI.initBoatSpeedBtn = function(self)

	local btn_add = MyMenuItem.new({image = "#common_mark_add2.png", imageSelected = "#common_mark_add2.png",
				x = display.cx + 30, y = display.top - 30})
	local btn_sub = MyMenuItem.new({image = "#common_mark_reduce2.png", imageSelected = "#common_mark_reduce2.png",
				x = display.cx - 30, y = display.top - 30})

	btn_add:regCallBack( function()
		getGameData():getBattleDataMt():setSpeedForTest(TEST_SPEED_ADD)
	end)
	btn_sub:regCallBack( function()
		getGameData():getBattleDataMt():setSpeedForTest(TEST_SPEED_SUB)
	end)
	local menu=MyMenu.new({btn_add,btn_sub}, TOUCH_PRIORITY_MORE_HIGHT)
	self:addChild(menu,1)
end

--视角缩放按钮
FightUI.initZoomUI = function(self, panel)
	local battle_data = getGameData():getBattleDataMt()
	
	self.btn_zoom = getConvertChildByName(panel, "btn_zoom")
	self.zoom_out = getConvertChildByName(panel, "zoom_out")
	self.zoom_in = getConvertChildByName(panel, "zoom_in")
	self.btn_zoom:setTouchEnabled(true)
	self.btn_zoom:setPressedActionEnabled(true)
	local old_zoom = battle_data:getBattleLayerScale() or 0.95
	local max_zoom = false	
	local zoom_status = false
	if old_zoom > 0.9 then
		max_zoom = true
		
	end

	local setZoomStatus
	setZoomStatus = function(max_zoom, new_zoom)
		self.zoom_out:setVisible(max_zoom)
		self.zoom_in:setVisible(not max_zoom)
	end
	setZoomStatus(max_zoom)
	local setZoom
	setZoom = function()
		local old_zoom = battle_data:getBattleLayerScale()		
		local new_zoom
		
		if old_zoom > 0.9 then
			max_zoom = true
			new_zoom = 0.85			
		elseif old_zoom < 0.8 then
			max_zoom = false
			new_zoom = 0.85		
		else
			if max_zoom then
				new_zoom = old_zoom - 0.1			
			else
				new_zoom = old_zoom + 0.1
			end
		end
		if new_zoom >0.9 then
			zoom_status = true
		elseif new_zoom < 0.8 then
			zoom_status = false
		end
		setZoomStatus(zoom_status, new_zoom)
		BATTLE_SCALE_RATE = new_zoom
		battle_data:setBattleLayerScale(new_zoom)
		CameraFollow:ScaleByScreenPos(new_zoom, ccp(display.cx, display.cy))
		self:lockPlayerShip()
	end

	
	self.btn_zoom:addEventListener(function()
		setZoom()
	end, TOUCH_EVENT_ENDED)
end

----------------------------------------------------------新UI----------------------------------------------------------
---------------------------------------------------------UI刷新---------------------------------------------------------

FightUI.setProgressBarPercent = function(self, enemy_dead_ship_num)
	enemy_dead_ship_num = enemy_dead_ship_num or 0

	if tolua.isnull(self.cion_bar_bg) then return end
	if not self.cion_bar_bg:isVisible() then
		self.cion_bar_bg:setVisible(true)
	end

	local battleData = getGameData():getBattleDataMt()
	if not battleData:IsInBattle() then return end

	local battle_field_data = battleData:GetData("battle_field_data")
	if battle_field_data.fight_type == battle_config.fight_type_plunder then
		local progress_bar_node = self.explore_plunder_silver
		local lootDataHandle = getGameData():getLootData()
		local process_max_value = lootDataHandle:getProcessMaxValue()
		local cash = math.ceil((enemy_dead_ship_num * 0.2) * process_max_value)
		progress_bar_node.num_label:setText(cash)
		progress_bar_node.progress:setPercent((cash / process_max_value) * 100)
	end
end

FightUI.showTipsUI = function(self, str_tips, time)
	local pan_tips = getConvertChildByName(self.uiLayer, "top_tips")
	local lbl_tips = getConvertChildByName(pan_tips, "top_tips_txt")
	lbl_tips:setText(str_tips)
	pan_tips:setVisible(true)
	lbl_tips:stopAllActions()
	local arr_action = CCArray:create()
	arr_action:addObject(CCDelayTime:create(time))
	arr_action:addObject(CCCallFunc:create(function()
		lbl_tips:stopAllActions()
		pan_tips:setVisible(false)
	end))
	lbl_tips:runAction(CCSequence:create(arr_action))
end

FightUI.setHp = function(self, rate, ship_data)
	if self.fleet_head and self.fleet_head[ship_data.id] then
		self.fleet_head[ship_data.id].hp:setPercent(rate)
	end 
end

FightUI.updataRadar = function(self, shipTab)
	if tolua.isnull(self) then return end

	if self.lock_update_radar then
		self:updateRadarFrame()
	end

	local getSpriteName
	getSpriteName = function(ship_obj)
		local png = "battle_radar_enemy"

		local team_id = ship_obj.teamId

		if team_id == battle_config.default_team_id or team_id == battle_config.neutral_team_id then
			png = "battle_radar_friend"

			if ship_obj:getUid() == getGameData():getBattleDataMt():getCurClientUid() then
				png = "battle_radar_mine"
			end
		end

		if ship_obj:is_leader() then
			png = string.format("%s%s", png, 2)
		end

		return string.format("%s%s", png, ".png")
	end
	
	for k, ship_data in pairs(shipTab) do
		local id = ship_data:getId()

		if not ship_data.isDeaded and ship_data.baseData.radar_show then 
			local posX, posY = ship_data:getPosition()
				
			local x = posX * self.radar_width_rate + self.radar_offX
			local y = posY * self.radar_height_rate + self.radar_offY

			local radar_obj = self.NPC[id]

			local sprite_name = getSpriteName(ship_data)
			local current_team_id = ship_data.teamId
			
			if not tolua.isnull(radar_obj) then 
				-- 校验敌友是否更改
				if current_team_id ~= radar_obj.team_id then
					radar_obj.teamId = current_team_id
					local tmp_frame = display.newSpriteFrame(sprite_name)
					if tmp_frame then
						radar_obj:setDisplayFrame(tmp_frame)
					end
				end
			else
				self.NPC[id] = display.newSprite( "#" .. sprite_name )	
				radar_obj = self.NPC[id]
				self.radar:addRenderer(self.NPC[id], 1)
			end

			radar_obj:setPosition(ccp(x, y))
		else
			self:removeNPC(id)
		end
	end
end

FightUI.removeNPC = function(self, id)
	if not id or not self.NPC then return end

	if not self.NPC[id] then return end

	self.NPC[id]:removeFromParentAndCleanup(true)
	self.NPC[id] = nil
end

FightUI.Timer = function(self, tick)
	if tick < 0 then tick = 0 end
	
	if not tolua.isnull(self.timeLabel) then
		local str = string.format("%02d:%02d", math.floor(tick/60), tick - (math.floor(tick/60)*60))
		self.timeLabel:setText(str)
		if tick <= 20 then 
			self.timeLabel:setColor(ccc3(dexToColor3B(COLOR_RED)))
		end 
	end
end

FightUI.subStar = function(self, mask)
	local battle_data = getGameData():getBattleDataMt()
	if not battle_data:IsBattleStart() or not self.starText or not self.starText[mask] then return end

	self.starText[mask]:setColor(ccc3(dexToColor3B(COLOR_GREY_STROKE)))
	self.starArray[mask]:changeTexture("battle_star_2.png", UI_TEX_TYPE_PLIST)
end

FightUI.lockPlayerShip = function(self)
	CameraFollow:StopShake()
	self.lock_update_radar = true

	if not self.isRunning then return end

	local battle_data = getGameData():getBattleDataMt()
	local ship = battle_data:getCurClientControlShip()
	if ship and not ship:is_deaded() then
		CameraFollow:LockTarget(ship.body.node)
	end
	
	if not tolua.isnull(self.btn_view_unlock) then
		self.btn_view_unlock:setVisible(false)
	end
end

FightUI.showBtnViewUnlock = function(self)
	if self.lock_camera or getGameData():getBattleDataMt():GetShipsDead() then return end
	-- if self.btn_view_unlock and not self.btn_view_unlock:isVisible() then
	-- 	self.btn_view_unlock:setVisible(true)
	-- 	self:btnViewUnlockAction()
	-- end
	self.lock_update_radar = true
end

FightUI.btnViewUnlockAction = function(self)
	if self.btn_view_unlock then
		self.btn_view_unlock:stopAllActions()
		actions_1 = CCFadeOut:create(6.1)
		actions_2 = CCSequence:createWithTwoActions(CCDelayTime:create(3), CCCallFunc:create(function()
				self.btn_view_unlock:setOpacity(255/2)
				self.btn_view_unlock:stopAllActions()
			end))
		local actions = CCSpawn:createWithTwoActions(actions_1, actions_2)
		self.btn_view_unlock:runAction(actions)
	end
end

FightUI.setHand = function(self)
	if self.btn_auto_fight then
		self.btn_auto_fight:setFocused(false)
		if not tolua.isnull(self.btn_auto_text) then
			self.btn_auto_text:setText(ui_word.BATTLE_AUTO)
		end
		if not tolua.isnull(self.auto_fight_effect) then
			self.auto_fight_effect:setVisible(false)
		end
		
	end
end

FightUI.changeSkillSpriteOpacity = function(self, obj, value)
	if not obj or not obj.sprite then return end

	obj.sprite:setOpacity(value)
end

-- 公共cd
FightUI.setCommonSkillCD = function(self)
	local battle_data = getGameData():getBattleDataMt()
	local ship = battle_data:getCurClientControlShip()
	if type(self.skill_progress) == "table" then
		for k,v in pairs(self.skill_progress) do
			self:updateSkillUI(k, true)
		end
	end
end

FightUI.stopProgressActions = function(self, skill_progress)
	skill_progress:stopAllActions()
	skill_progress.label:setString("")
end

FightUI.createNumAction = function(self, skill_id)
	local action_1 = CCCallFunc:create(function()
		local battle_data = getGameData():getBattleDataMt()
		local ship = battle_data:getCurClientControlShip()

		if not self.skill_progress or not ship then return end

		local skill_progress = self.skill_progress[skill_id]
		if tolua.isnull(skill_progress) then return end

		local remain_cd = ship:get_remain_cd(skill_id)

		skill_progress.label:setString(math.floor(remain_cd))
	end)

	local action_2 = CCDelayTime:create(0.2)

	return CCRepeatForever:create(CCSequence:createWithTwoActions(action_1, action_2))
end

--技能cd
FightUI.showSkillCD = function(self, skillId)
	if not self.skill_progress then return end
	local skill_progress = self.skill_progress[skillId]
	if tolua.isnull(skill_progress) then return end

	local battle_data = getGameData():getBattleDataMt()
	local ship = battle_data:getCurClientControlShip()

	if not ship or ship:is_deaded() then return end

	self:stopProgressActions(skill_progress)

	local remain_cd = ship:get_remain_cd(skillId)

	if remain_cd == 0 then 
		skill_progress:setPercentage(0)
		self:changeSkillSpriteOpacity(skill_progress, TOATL_OPACITY)
		return 
	end

	self:changeSkillSpriteOpacity(skill_progress, HALF_OPACITY)

	local cd = skill_map[skillId]:get_skill_cd(ship)

	local to = CCProgressFromTo:create(remain_cd, remain_cd/cd*100, 0)
	local ac_1 = CCSequence:createWithTwoActions(to, CCCallFunc:create(function()
		self:stopProgressActions(skill_progress)

		if skillId ~= "sk4001" and not ship:is_deaded() and battle_data:IsBattleStart() and self.uiLayer:isVisible() then
			local skill_param = self.skill_param[skillId]
			local pos = skill_param.sp:convertToWorldSpace(skill_param.sp:getPosition())
			pos.x = pos.x - skill_param.sp:getContentSize().width/2 - 9
			pos.y = pos.y - skill_param.sp:getContentSize().height/2 - 9
			self.skill_effect[skillId] = composite_effect.new("tx_0088", pos.x, pos.y, self, 1, function()
				self.skill_effect[skillId] = nil
			end)
		end
		self:changeSkillSpriteOpacity(skill_progress, TOATL_OPACITY)
	end))

	local ac_2 = self:createNumAction(skillId)

	skill_progress:runAction(ac_1)
	skill_progress:runAction(ac_2)
end

FightUI.updateSkillUI = function(self, skillId, not_use)
	if not self.skill_progress then return end
	local skill_progress = self.skill_progress[skillId]
	if tolua.isnull(skill_progress) then return end

	local battle_data = getGameData():getBattleDataMt()
	local ship = battle_data:getCurClientControlShip()

	self:stopProgressActions(skill_progress)

	if not not_use and skillId ~= "sk4001" and self.uiLayer:isVisible() then ---加速技能去掉特效
		composite_effect.bollow("tx_0072", skill_progress:getContentSize().width/2, 
		skill_progress:getContentSize().height/2, skill_progress)
	end

	local now = getCurrentLogicTime()
	local common_cd = ship:get_common_skill_cd() - now
	--先判断有没有公共cd，有的话先播公共cd再技能cd，没有公共cd直接播技能cd
	if common_cd > 0 then
		self:changeSkillSpriteOpacity(skill_progress, HALF_OPACITY)
		local to = CCProgressFromTo:create(common_cd, 100, 0)
		skill_progress.cdActionHandler = to
		skill_progress:runAction(CCSequence:createWithTwoActions(skill_progress.cdActionHandler, CCCallFunc:create(function ()
			self:changeSkillSpriteOpacity(skill_progress, TOATL_OPACITY)
			self:showSkillCD(skillId)
		end)))
	else
		self:showSkillCD(skillId)
	end
end

FightUI.showSkillDamage = function(self, str)
	local num = #self.rich_labels
	for i = num, 1, -1 do
		if i == 3 then
			self.rich_labels[i]:stopAllActions()
			self.rich_labels[i]:removeFromParentAndCleanup(true)
			self.rich_labels[i] = nil
		else
			self.rich_labels[i + 1] = self.rich_labels[i]
			self.rich_labels[i + 1]:setPosition(ccp(480, 450 + 23*i))
		end
	end

	local rich_label = createRichLabel(str, 1, 14, 14, nil, true)
	rich_label:setAnchorPoint(ccp(0.5, 0.5))
	rich_label:setPosition(ccp(480, 450))
	self:addChild(rich_label, 9)

	local actions = {}
	actions[1] = CCDelayTime:create(3)
	actions[2] = CCFadeOut:create(0.5)
	actions[3] = CCCallFunc:create(function()
		self.rich_labels[#self.rich_labels]:removeFromParentAndCleanup(true)
		self.rich_labels[#self.rich_labels] = nil
	end)
	rich_label:runAction(transition.sequence(actions))

	self.rich_labels[1] = rich_label
end

FightUI.updateRadarFrame = function(self)
	local battle_data = getGameData():getBattleDataMt()
	if not battle_data:IsBattleStart() then return end

	local camera_node = BattleInit3D:getScene():getActiveCamera():getNode()
	if not tolua.isnull(camera_node) and not tolua.isnull(self.select_frame) then
		local camera_pos = gameplayToCocosWorld(camera_node:getTranslationWorld())
		local x = math.floor(camera_pos.x * self.radar_width_rate + self.radar_offX + 0.5)
		local y = math.floor(camera_pos.y * self.radar_height_rate + self.radar_offY + 0.5)

		local judgeEdge
		judgeEdge = function(pos)
			local radar_size = self.radar:getSize()
			local frame_size = self.select_frame:getContentSize()

			local x = math.floor(Math.clamp(- radar_size.width/2 + frame_size.width/2, 
				radar_size.width/2 - frame_size.width/2, pos.x) + 0.5)
			local y = math.floor(Math.clamp(- radar_size.height/2 + frame_size.height/2, 
				radar_size.height/2 - frame_size.height/2, pos.y) + 0.5)
			return ccp(x, y)
		end

		self.select_frame:setPosition(judgeEdge(ccp(x, y)))
	end
end

FightUI.setRadarFrameContentSize = function(self, width, height)
	local radar_size = self.radar:getSize()
	local size_w = math.floor(radar_size.width/width*960 + 0.5)
	local size_h = math.floor(radar_size.height/height*540 + 0.5)
	size_w = size_w%2 == 0 and size_w or size_w - 1
	size_h = size_h%2 == 0 and size_h or size_h - 1
	self.select_frame:setContentSize(CCSize(size_w, size_h))

	local judgeEdge
	judgeEdge = function(pos)
		local radar_size = self.radar:getSize()
		local frame_size = self.select_frame:getContentSize()

		local x = Math.clamp(- radar_size.width/2 + frame_size.width/2, 
			radar_size.width/2 - frame_size.width/2, pos.x)
		local y = Math.clamp(- radar_size.height/2 + frame_size.height/2, 
			radar_size.height/2 - frame_size.height/2, pos.y)

		return ccp(x, y)
	end

	self.select_frame:setPosition(judgeEdge(ccp(self.select_frame:getPositionX(), self.select_frame:getPositionY())))
end

FightUI.getLockCamera = function(self)
	return self.lock_camera
end

FightUI.clearSkillEffect = function(self)
	for k, v in pairs(self.skill_effect) do
		if v then
			v:stopEffect()
		end
	end

	self.skill_effect = {}
end

FightUI.hideGatherButton = function(self)
	local battle_data = getGameData():getBattleDataMt()
	local ship = battle_data:getCurClientControlShip()
	if not ship:is_leader() then 
		self.btn_gather:setVisible(false)
		return
	end

	self.btn_gather:setVisible(true)
end

FightUI.allShipsDead = function(self)
	local battle_data = getGameData():getBattleDataMt()
	if battle_data:isDemo() then return end

	if battle_data:isSummon() then
		local die_tips = getConvertChildByName(self.uiLayer, "die_tips")
		die_tips:setVisible(true)

		local layer = CCLayerColor:create(ccc4(0, 0, 0, 80))
		self:addChild(layer)
	else
		self.btn_chat:setVisible(false)
	end

	if not tolua.isnull(self.litener_auto_layer) then
		self.litener_auto_layer:removeFromParentAndCleanup(true)
		self.litener_auto_layer = nil
	end

	self.lock_camera = false

	self.btn_gather:setVisible(false)
	self.btn_auto_fight:setVisible(false)
	self.btn_view_unlock:setVisible(false)
	self.virtula_joystick:setVisible(false)

	self:clearSkillEffect()
	for k, v in ipairs(self.skill_bg) do
		v:setVisible(false)
	end
end

FightUI.isCanTouch = function(self)
	if self.virtula_joystick and not tolua.isnull(self.virtula_joystick) then
		return self.virtula_joystick:getUserTouchScene()
	end

	return true
end
 
-- 设置战斗口号
FightUI.setSlogan = function(self, ship_id, skill_id)
	local battle_data = getGameData():getBattleDataMt()
	
	local ship = battle_data:getShipByGenID(ship_id)

	if not ship or ship:is_deaded() then return end

	if ship:getTeamId() ~= battle_config.default_team_id then return end

	local slogan = battle_slogan[skill_id]
	local sailor_id = ship:getSailorID()

	if not sailor_id or not sailor_info[sailor_id] then return end

	local sex = sailor_info[sailor_id].sex
	local sailor_sex = sex == SEX_M and "male" or "female"

	local key = slogan.voice[sailor_sex]
	local text = slogan.slogan_info[sailor_sex]

	ship:say(nil, text, true)
	
	if self.dialog_tab[ship_id] and not tolua.isnull(self.dialog_tab[ship_id].dialog) then
		local dialog = self.dialog_tab[ship_id].dialog
		dialog:stopAllActions()

		local dialog_text = self.dialog_tab[ship_id].dialog_text
		dialog_text:setText(text)
		dialog:setVisible(true)

		local array = CCArray:create()
		array:addObject(CCFadeIn:create(0.5))
		array:addObject(CCDelayTime:create(2))
		array:addObject(CCFadeOut:create(0.5))
		array:addObject(CCCallFunc:create(function ()
			dialog:setVisible(false)
		end))
		dialog:runAction(CCSequence:create(array))
		
		if voice_info[key] then 
			sound = voice_info[key].res
			audioExt.playEffect(sound, false, true)
		end
		self.is_slogan = true
		self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(10), CCCallFunc:create(function ( )
			self.is_slogan = false
		end))) 
	end
end 

FightUI.isSlogan = function(self)
	return self.is_slogan
end

FightUI.showPrompt = function(self, txt)
	local layerAction
	layerAction = function()
		local bg_size = self.layer_prompt:getContentSize()

		self.layer_prompt.label = createBMFont({text = txt, size = 14,fontFile = FONT_COMMON, 
			color = ccc3(dexToColor3B(COLOR_BROWN)), x = bg_size.width/2, y = bg_size.height/2})

		self.layer_prompt:addChild(self.layer_prompt.label)

		self.layer_prompt:setPosition(display.cx, 5/6*display.height)

		local ac_1 = CCSequence:createWithTwoActions(CCFadeIn:create(1), CCDelayTime:create(1))
		local ac_2 = CCMoveTo:create(0.5, ccp(display.cx, display.height))

		self.layer_prompt:runAction(CCSequence:createWithTwoActions(ac_1, ac_2))
	end

	if tolua.isnull(self.layer_prompt) then
		self.layer_prompt = display.newSprite( "#battle_goal_bg.png" )
		self.layer_prompt:setCascadeOpacityEnabled(true)

		self.layer_prompt:setAnchorPoint(ccp(0.5, 1))

		self:addChild(self.layer_prompt)

		layerAction()
		return
	end

	self:hidePrompt(layerAction)
end

FightUI.hidePrompt = function(self, call_back)
	if tolua.isnull(self.layer_prompt) then return end 

	local ani_tick = 1
	local size = self.layer_prompt:getContentSize()
	local line =  display.newSprite("#battle_point.png", 10, size.height/2)
	line:setAnchorPoint(ccp(0,0.5))
	line:setScale(2)
	self.layer_prompt:addChild(line)

	line:runAction(CCSequence:createWithTwoActions(CCScaleTo:create(ani_tick, size.width - 20, 2), 
		CCCallFunc:create(function()
			line:removeFromParentAndCleanup(true)
		end)))

	local actions = {}
	actions[1] = CCDelayTime:create(ani_tick)
	actions[2] = CCMoveBy:create(1, ccp(0, self.layer_prompt:getContentSize().height))
	actions[3] = CCCallFunc:create(function() 
		self.layer_prompt.label:removeFromParentAndCleanup(true)
		self.layer_prompt.label = nil

		if type(call_back) == "function" then
			call_back()
		end
	end)
	action = transition.sequence(actions)
	self.layer_prompt:runAction(action)
end

FightUI.showCombo = function(self, value)
	self.combo_light:stopAllActions()
	self.combo_light:setVisible(value)

	if not value then
		self.combo_num:setText(0)
		return
	end

	self.combo_light:setScale(1)

	local num = tonumber(self.combo_num:getStringValue())
	self.combo_num:setText(num + 1)

	local actions = {}
	actions[#actions + 1] = CCScaleTo:create(0.1, 1.3)
	actions[#actions + 1] = CCScaleTo:create(0.1, 1)
	actions[#actions + 1] = CCDelayTime:create(2)
	actions[#actions + 1] = CCCallFunc:create(function()
		self:showCombo(false)
	end)

	self.combo_light:runAction(transition.sequence(actions))

	if not tolua.isnull(self.combo_effect) then 
		self.combo_effect:removeFromParentAndCleanup(true)
		self.combo_effect = nil
	end

	local time = 1

	self.combo_effect = composite_effect.new("tx_combo", 0, 0, self.combo_num, time)
	self.combo_effect:setZOrder(-1)

	local actions_1 = {}
	actions_1[#actions_1 + 1] = CCDelayTime:create(time)
	actions_1[#actions_1 + 1] = CCCallFunc:create(function()
		if not tolua.isnull(self.combo_effect) then
			self.combo_effect:removeFromParentAndCleanup(true)
			self.combo_effect = nil
		end
	end)
	local running_scene = GameUtil.getRunningScene()
	running_scene:runAction(transition.sequence(actions_1))
end

FightUI.storyMode = function(self)
	local frame = display.newSpriteFrame("common_9_black.png")

	local down_sprite = CCScale9Sprite:createWithSpriteFrame(frame)
	down_sprite:setContentSize(CCSize(display.width, 50))
	down_sprite:setAnchorPoint(ccp(0, 0))
	down_sprite:setPosition(ccp(0, 0))
	self:addChild(down_sprite, 999)

	local up_sprite = CCScale9Sprite:createWithSpriteFrame(frame)
	up_sprite:setContentSize(CCSize(display.width, 50))
	up_sprite:setAnchorPoint(ccp(0, 1))
	up_sprite:setPosition(ccp(0, display.height))
	self:addChild(up_sprite, 999)

	local label = createBMFont({text = ui_word.STORY_MODE, size = 16, fontFile = FONT_COMMON, 
		color = ccc3(dexToColor3B(COLOR_GREEN_STROKE)), x = display.width/2, y = 0})
	label:setAnchorPoint(ccp(0.5, 0))
	up_sprite:addChild(label)

	if self.skill_param then
		for k, v in pairs(self.skill_param) do
			if not tolua.isnull(v.sp) and not tolua.isnull(v.sp.new_skill_effect) then
				v.sp.new_skill_effect:setVisible(false)
			end
		end
	end

	local btn_fire = getConvertChildByName(self.uiLayer, "btn_fire")
	if not tolua.isnull(btn_fire) and not tolua.isnull(btn_fire.new_skill_effect) then
		btn_fire.new_skill_effect:setVisible(false)
	end

	self.down_sprite = down_sprite
	self.up_sprite = up_sprite

	self.uiLayer:setVisible(false)

	self.virtula_joystick:giveUp()
	self.virtula_joystick:setVisible(false)
	self.virtula_joystick:setTouchEnabled(false)

	local battle_layer = getUIManager():get("battle_layer")
	if not tolua.isnull(battle_layer) then
		battle_layer:setViewTouchEnabled(false)
	end

	local battle_data = getGameData():getBattleDataMt()
	local ship = battle_data:getCurClientControlShip()
	if ship then
		ship:setLockMove(true)
		ship:getBody():resetPath()
	end
end

FightUI.normalMode = function(self)
	if not tolua.isnull(self.down_sprite) then
		self.down_sprite:removeFromParentAndCleanup(true)
		self.down_sprite = nil
	end

	if not tolua.isnull(self.up_sprite) then
		self.up_sprite:removeFromParentAndCleanup(true)
		self.up_sprite = nil
	end

	if self.skill_param then
		for k, v in pairs(self.skill_param) do
			if not tolua.isnull(v.sp) and not tolua.isnull(v.sp.new_skill_effect) then
				v.sp.new_skill_effect:setVisible(true)
			end
		end
	end

	local btn_fire = getConvertChildByName(self.uiLayer, "btn_fire")
	if not tolua.isnull(btn_fire) and not tolua.isnull(btn_fire.new_skill_effect) then
		btn_fire.new_skill_effect:setVisible(true)
	end

	self.uiLayer:setVisible(true)
	self.virtula_joystick:setVisible(true)
	self.virtula_joystick:setTouchEnabled(true)

	local battle_layer = getUIManager():get("battle_layer")
	if not tolua.isnull(battle_layer) then
		battle_layer:setViewTouchEnabled(true)
	end

	local battle_data = getGameData():getBattleDataMt()
	local ship = battle_data:getCurClientControlShip()
	if ship then
		ship:setLockMove(false)
	end
end

---------------------------------------------------------UI刷新---------------------------------------------------------

FightUI.doShowSkillTip = function(self, x, y, id)
	self:stopSkillTipAction()

	local action_1 = CCDelayTime:create(0.5)
	local action_2 = CCCallFunc:create(function()
		self:showSkillTip(x, y, id)
		self.skill_action = nil
	end)

	local running_scene = GameUtil.getRunningScene()
	self.skill_action = running_scene:runAction(CCSequence:createWithTwoActions(action_1, action_2))
end

local widget_pvp_kill = {
	"pvp_kill",
	"pvp_me",
	"pvp_my_name",
	"pvp_my_head",
	"pvp_enemy",
	"pvp_enemy_name",
	"pvp_enemy_head",
}

FightUI.showPvPKillTip = function(self, attacker, be_attacker)
	if not tolua.isnull(self.pvp_kill_tip_ui) then
		self.pvp_kill_tip_ui:stopAllActions()
		self.pvp_kill_tip_ui:removeFromParentAndCleanup(true)
	end
	self.pvp_kill_tip_ui = GUIReader:shareReader():widgetFromJsonFile("json/battle_pvp_kill.json")
	convertUIType(self.pvp_kill_tip_ui)
	self.pvp_kill_tip_ui:setPosition(ccp(390, 400))
	self:addWidget(self.pvp_kill_tip_ui)
	for i,v in ipairs(widget_pvp_kill) do
		self.pvp_kill_tip_ui[v] = getConvertChildByName(self.pvp_kill_tip_ui, v)
	end
	----------------------左边ui---------------------------
	if not attacker.is_enemy then --自己
		self.pvp_kill_tip_ui.pvp_me:changeTexture("battle_pvp_me.png", UI_TEX_TYPE_PLIST)
		self.pvp_kill_tip_ui.pvp_my_name:setColor(ccc3(dexToColor3B(COLOR_GREEN)))
	else
		self.pvp_kill_tip_ui.pvp_me:changeTexture("battle_pvp_enemy.png", UI_TEX_TYPE_PLIST)
		self.pvp_kill_tip_ui.pvp_my_name:setColor(ccc3(dexToColor3B(COLOR_RED)))
	end
	self.pvp_kill_tip_ui.pvp_my_name:setText(attacker.name)

	sailor_res = sailor_info[attacker.sailor_id].res
	self.pvp_kill_tip_ui.pvp_my_head:changeTexture(sailor_res)
	local size = self.pvp_kill_tip_ui.pvp_my_head:getContentSize()
	local scale = 20/size.width
	self.pvp_kill_tip_ui.pvp_my_head:setScale(scale)

	----------------------右边ui---------------------------
	if not be_attacker.is_enemy then --自己
		self.pvp_kill_tip_ui.pvp_enemy:changeTexture("battle_pvp_me.png", UI_TEX_TYPE_PLIST)
		self.pvp_kill_tip_ui.pvp_enemy_name:setColor(ccc3(dexToColor3B(COLOR_GREEN)))
	else
		self.pvp_kill_tip_ui.pvp_enemy:changeTexture("battle_pvp_enemy.png", UI_TEX_TYPE_PLIST)
		self.pvp_kill_tip_ui.pvp_enemy_name:setColor(ccc3(dexToColor3B(COLOR_RED)))
	end
	self.pvp_kill_tip_ui.pvp_enemy_name:setText(be_attacker.name)
	self.pvp_kill_tip_ui.pvp_kill_icon = getConvertChildByName(self.pvp_kill_tip_ui.pvp_enemy, "pvp_kill_icon")
	self.pvp_kill_tip_ui.pvp_kill_icon:setVisible(false)
	self.pvp_kill_tip_ui.pvp_kill_icon:setZOrder(100)
	getConvertChildByName(self.pvp_kill_tip_ui.pvp_me, "pvp_kill_icon"):setVisible(false)

  
	sailor_res = sailor_info[be_attacker.sailor_id].res
	self.pvp_kill_tip_ui.pvp_enemy_head:changeTexture(sailor_res)
	local size = self.pvp_kill_tip_ui.pvp_enemy_head:getContentSize()
	local scale = 20/size.width
	self.pvp_kill_tip_ui.pvp_enemy_head:setScale(scale)

	local array = CCArray:create()
	   
	array:addObject(CCCallFunc:create(function()
		self.pvp_kill_tip_ui.pvp_me:setPosition(ccp(-140, -5))
		self.pvp_kill_tip_ui.pvp_enemy:setPosition(ccp(140, -5))
		--move_arr:addObject(CCEaseSineInOut:create(CCMoveTo:create(word_eff_time_n/2, ccp(x, 12))))
		self.pvp_kill_tip_ui.pvp_me:runAction(CCEaseSineInOut:create(CCMoveTo:create(0.45, ccp(-70, -5))))
		self.pvp_kill_tip_ui.pvp_enemy:runAction(CCEaseSineInOut:create(CCMoveTo:create(0.45, ccp(70, -5))))
	end))
	array:addObject(CCDelayTime:create(0.5))
	array:addObject(CCCallFunc:create(function ()
		self.pvp_kill_tip_ui.pvp_kill_icon:setVisible(true)
		self.pvp_kill_tip_ui.pvp_kill_icon:runAction(CCFadeIn:create(0.2))
	end))
	array:addObject(CCDelayTime:create(2))
	
	array:addObject(CCCallFunc:create(function ()
		self.pvp_kill_tip_ui.pvp_kill:runAction(CCFadeOut:create(0.5))
	end))
	array:addObject(CCDelayTime:create(0.5))
	array:addObject(CCCallFunc:create(function ()
		self.pvp_kill_tip_ui:removeFromParentAndCleanup(true)
	end))
	self.pvp_kill_tip_ui:runAction(CCSequence:create(array))
end

FightUI.stopSkillTipAction = function(self)
	if not tolua.isnull(self.skill_action) then
		local running_scene = GameUtil.getRunningScene()
		running_scene:stopAction(self.skill_action)
		self.skill_action = nil
	end
end

FightUI.showSkillTip = function(self, x, y, id)
	local battle_data = getGameData():getBattleDataMt()
	local ship = battle_data:getCurClientControlShip()

	if not ship then return end

	local level = ship:get_skill_lv(id)
	local skill = tool:getSkill(id)
	local site = skill.site
	local subSite = string.sub(site, 3)

	if self.skillTipLayer then
		self.skillTipLayer:removeFromParentAndCleanup(true)
		self.skillTipLayer = nil
	end
	local frame = display.newSpriteFrame("common_9_tips2.png")
	self.skillTipLayer = CCScale9Sprite:createWithSpriteFrame(frame)
	self.skillTipLayer:setAnchorPoint(ccp(0, 0.5))
	local offset = 11
	local dx = 28
	local desc_tab = getGameData():getSailorData():getSkillDescWithLv(id, level)
	--基础技能
	self.baseExpDesc = createBMFont({text = desc_tab.base_desc, width = 232, fontFile = FONT_COMMON, size = 14, 
		color = ccc3(dexToColor3B(COLOR_CAMEL))})
	self.baseExpDesc:setAnchorPoint(ccp(0, 0))
	self.baseExpDesc:setPosition(ccp(dx / 2, offset))
	offset = self.baseExpDesc:getContentSize().height + offset + 4
	self.skillTipLayer:addChild(self.baseExpDesc)
	
	--技能名称
	self.skillName = createBMFont({text = skill.name, fontFile = FONT_COMMON, size = 14, 
		color = ccc3(dexToColor3B(COLOR_COFFEE))})
	local height = self.skillName:getContentSize().height
	local width = self.skillName:getContentSize().width
	self.skillName:setAnchorPoint(ccp(0, 0))
	self.skillName:setPosition(ccp(dx / 2, offset))
	self.skillTipLayer:addChild(self.skillName)
	--等级
	self.skillLevel = createBMFont({text = "Lv."..level, fontFile = FONT_CFG_1, size = 14,color = ccc3(dexToColor3B(COLOR_COFFEE))})
	self.skillLevel:setAnchorPoint(ccp(0, 0))
	self.skillLevel:setPosition(ccp(dx + width, offset + 2))
	self.skillTipLayer:addChild(self.skillLevel)
	
	self.skillTipLayer:setContentSize(CCSize(260, offset + 35))
	self:addChild(self.skillTipLayer, 10)
	self.skillTipLayer:setAnchorPoint(ccp(1, 0))
	self.skillTipLayer:setPosition(ccp(x,y))
end

FightUI.dismissSkillTip = function(self)
	self:stopSkillTipAction()
	if self.skillTipLayer then
		self.skillTipLayer:removeFromParentAndCleanup(true)
		self.skillTipLayer = nil
	end
end

-------------------------伙伴位置提示----------------------------
local parner_widget_name = {
	"arrow_up",
	"arrow_down",
	"arrow_left",
	"arrow_right",
}

FightUI.showPartnerTips = function(self)
	local battle_data = getGameData():getBattleDataMt()
	local partner_ships = battle_data:GetTeamMemberShip(getGameData():getPlayerData():getUid())

	for i,v in ipairs(partner_ships) do
		local ship_id = v:getId()
		if not v.isDeaded and 
			v.baseData.tag ~= battle_config.FEN_SHEN_TAG and
			v.sailor_id
		then
			local pos_3d = v:getPosition3D()
			local pos_2d = Vector3ToScreen(pos_3d, BattleInit3D:getScene():getActiveCamera())
			local x, y = pos_2d:x(), pos_2d:y()
			if math.abs(x- 480) > 520 or math.abs(y - 270) > 310 then
				if self.showParnerTips[ship_id] and not tolua.isnull(self.showParnerTips[ship_id]) then
					self.showParnerTips[ship_id]:setVisible(true)
				else
					local panel = GUIReader:shareReader():widgetFromJsonFile("json/battle_field_outside.json")
					convertUIType(panel)
					self.showParnerTips[ship_id] = panel
					self:addWidget(panel)

					local head_pic = getConvertChildByName(panel, "head_pic")
					head_pic:changeTexture(sailor_info[v.sailor_id].res)
					local size = head_pic:getContentSize()
					local scale = 25/size.width
					head_pic:setScale(scale)
					self.showParnerTips[ship_id].sits = {}
					for i,v in ipairs(parner_widget_name) do
						self.showParnerTips[ship_id].sits[i] = getConvertChildByName(panel, v)
						self.showParnerTips[ship_id].sits[i]:setVisible(false)
					end
				end
				local pos = {x = 0, y = 0}
				local sit = 1
				if math.abs(x- 480) > 520 then
					if y < 30 then
						y = 30
					elseif y > 480 then
						y = 480
					end
					if x < 0 then
						pos = {x = 0, y = y}
						sit = 3
					else
						pos = {x = 890, y = y}
						sit = 4
					end
					
				else 
					if x > 950 then
						x = 950
					elseif x < 40 then
						x = 40
					end
					if y < 0 then
						pos = {x = x - 50, y = 0}
						sit = 2
					else
						pos = {x = x - 50, y = 480}
						sit = 1
					end
					
				end
				local old_sit = self.showParnerTips[ship_id].old_sit
				if sit ~= self.showParnerTips[ship_id].old_sit then
					self.showParnerTips[ship_id].sits[sit]:setVisible(true)
					if old_sit then
						self.showParnerTips[ship_id].sits[old_sit]:setVisible(false)
					end
					
				end
				self.showParnerTips[ship_id].old_sit = sit
				self.showParnerTips[ship_id]:setPosition(ccp(pos.x, pos.y))
			else

				if self.showParnerTips[ship_id] and not tolua.isnull(self.showParnerTips[ship_id]) then
					self.showParnerTips[ship_id]:setVisible(false)
				end
			end
		else
			if self.showParnerTips[ship_id] and not tolua.isnull(self.showParnerTips[ship_id]) then
				self.showParnerTips[ship_id]:setVisible(false)
			end
		end
	end
end

--语音播放效果代码
FightUI.initEvent = function(self)
	RegTrigger(AUDIO_PLAY_EVENT, function(chat)
		if tolua.isnull(self) then return end
		self:audioPlayEvent(chat)
	end)
	RegTrigger(AUDIO_STOP_EVENT, function(chat)
		if tolua.isnull(self) then return end
		self:audioStopEvent(chat)
	end)
end

FightUI.setVoiceAction = function(self, voice)
	voice.runAction = function(self)
		self:setVisible(true)
		local volume_list = self.volume_list
		local array = CCArray:create()
		for k = #volume_list, 1, -1 do
			local item = volume_list[k]
			array:addObject(CCCallFunc:create(function()
				item:setVisible(true)
			end))
			array:addObject(CCDelayTime:create(0.5))
		end
		array:addObject(CCCallFunc:create(function()
			for k = 1, #volume_list do
				local item = volume_list[k]
				item:setVisible(false)
			end
		end))
		array:addObject(CCDelayTime:create(0.5))
		self.action_node:runAction(CCRepeatForever:create(CCSequence:create(array)))
	end

	voice.stopAction = function(self)
		self.action_node:stopAllActions()
		local volume_list = self.volume_list
		self:setVisible(false)
		for k = 1, #volume_list do
			local item = volume_list[k]
			item:setVisible(false)
		end
	end
end

FightUI.audioPlayEvent = function(self, chat)
	local voice = self:audioStopEvent(chat)--增加一个保证
	if tolua.isnull(voice) then return end
	voice:runAction()
end

FightUI.audioStopEvent = function(self, chat)
	local chat_data = getGameData():getChatData()
	local voice = self.voice_list[chat.sender]
	if tolua.isnull(voice) then return end
	voice:stopAction()
	return voice
end

FightUI.onExit = function(self)
	if not tolua.isnull(self.layer_prompt) then 
		self.layer_prompt:removeFromParentAndCleanup(true)
		self.layer_prompt = nil
	end

	self:clearSkillEffect()
	--self:dismissSkillTip()
	UnRegTrigger(AUDIO_PLAY_EVENT)
	UnRegTrigger(AUDIO_STOP_EVENT)
	UnRegTrigger(EVENT_BATTLE_SET_DATA, "battle_ui")
	UnRegTrigger(EVENT_BATTLE_GUILD_BOSS_PIRATE_KILL_UPDATE, "battle_ui")
	UnRegTrigger(EVENT_BATTLE_GUILD_BOSS_FLUSH_CURAMOUNT)
end

return FightUI
