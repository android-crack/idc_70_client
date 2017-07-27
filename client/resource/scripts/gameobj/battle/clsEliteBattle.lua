
---fmy0570
---精英战役

local clsUiTools = require("gameobj/uiTools")
local item_info = require("game_config/propItem/item_info")
local clsUiWord = require("game_config/ui_word")
local music_info = require("game_config/music_info")
local battle_jy_info = require("game_config/battle/battle_jy_info")
local sailor_info = require("game_config/sailor/sailor_info")
local battle_type_info = require("game_config/battle/battle_type_info")
local alert = require("ui/tools/alert")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local on_off_info = require("game_config/on_off_info")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsDataTools = require("module/dataHandle/dataTools")
local boat_info = require("game_config/boat/boat_info")
local scheduler = CCDirector:sharedDirector():getScheduler()
local armature_manager = CCArmatureDataManager:sharedArmatureDataManager()

local Main3d = require("gameobj/mainInit3d")
local Game3d = require("game3d")


local ClsEliteBattleUI = class("ClsEliteBattleUI", ClsBaseView)

local NO_TEAM = {
    1100031,
    1100032,
}

local BTN_NUM = 4
local REWARD_NUM = 3
local SAILOR_S_LEVEL = 6

local btn_pic_gray = "elite_bottle_grey.png"
local btn_pic_select = "elite_bottle_selected.png"
local btn_pic_select_2 = "elite_bottle_selected2.png"
local btn_pic_normal = "elite_bottle.png"

local need_widget_name = {
	"btn_bottle_1",
	"btn_bottle_2",
	"btn_bottle_3",
	"btn_bottle_4",
	"seamen_head",
	"seamen_name",
	"mid_text_1",
	"mid_text_2",
	"chapter_info",
	"chapter",
}

local battle_info_name = {
	"award_bg_1",
	"award_bg_2",
	"award_bg_3",
	"award_bg_4",
	"btn_fight",
	"open_num",
	"open_text",
	"prestige_num",
	"boat_base",
}


function ClsEliteBattleUI:getViewConfig()
    return {
		effect = UI_EFFECT.DOWN,
		is_back_bg = true 
    }
end

function ClsEliteBattleUI:onEnter(close_callback)
    self.plistTab = {
        ["ui/material_icon.plist"] = 1,
        ["ui/baowu.plist"] = 1,
        ["ui/equip_icon.plist"] = 1,
        ["ui/elite_battle.plist"] = 1,
        ["ui/ship_icon.plist"] = 1,
    }
    LoadPlist(self.plistTab)

	local battle_info_config_data = getGameData():getBattleInfoConfigData()
	battle_info_config_data:setConfigFileFlag(battle_info_config_data.ELITE_CONFIG)
	
	self.close_callback = close_callback

	self:askData()
end

function ClsEliteBattleUI:askData()
	local battleData = getGameData():getBattleData()
	battleData:askEliteBattleInfo()
end

function ClsEliteBattleUI:mkUI()

    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/battle_elite.json")
    self:addWidget(self.panel)

	self.btn_close = getConvertChildByName(self.panel, "btn_close")

    for k, v in pairs(need_widget_name) do
        self[v] = getConvertChildByName(self.panel, v)
    end	

    for k, v in pairs(battle_info_name) do
        self[v] = getConvertChildByName(self.panel, v)
    end	
    ClsGuideMgr:tryGuide("ClsEliteBattleUI")

    self:init3D()	
    self:initUI()
    self:configEvent()

end

function ClsEliteBattleUI:initUI()
	local battleData = getGameData():getBattleData()
	local battleInfo = battleData:getBattleInfo()

	local all_complated_status = getGameData():getBattleData():getAllComplated()
	local cur_max_fight_id = getGameData():getBattleData():getMaxBattleId()
	---获取当前的章节id  和战役id
    local battleData = getGameData():getBattleData()
	self.fight_id = battleData:getFightId()
	local fight_id = self.fight_id
	if self.fight_id == cur_max_fight_id and all_complated_status ~= ELITE_BATTLE_ALL_COMPLATED_STATUS then
		fight_id = battle_jy_info[self.fight_id].next_battle
	end
	self.chapter_id = battle_jy_info[fight_id].parent

    self.battle_list = battleInfo[self.chapter_id].eliteBattle
	for i=1,BTN_NUM do
		self["btn_bottle_"..i]:setVisible(i <= #self.battle_list)
	end

	self.chapter_info:setText(battle_type_info[self.chapter_id].name)
	self.chapter:setText(battle_jy_info[self.fight_id].chapter)

	local tab = 1
	for k,v in pairs(self.battle_list) do
		local datas = {}
		datas.chapter_id = self.chapter_id
		datas.fight_id = v.fight_id
		datas.grade = battle_jy_info[v.fight_id].grade
		datas.status = v.status

		self["battle_text_"..k] = getConvertChildByName(self["btn_bottle_"..k], "battle_text_"..k)
		self["bottle_lock_"..k] = getConvertChildByName(self["btn_bottle_"..k], "bottle_lock_"..k)
		self["complete_pic_"..k] = getConvertChildByName(self["btn_bottle_"..k], "complete_pic_"..k)

		self["battle_text_"..k]:setText(battle_jy_info[datas.fight_id].name)

		--local playerData = getGameData():getPlayerData()
		--local cur_fight_id = getGameData():getBattleData():getMaxBattleId()

		---完成的
		if datas.fight_id < self.fight_id or cur_max_fight_id == datas.fight_id then
			self["complete_pic_"..k]:setVisible(true)
		else
			self["complete_pic_"..k]:setVisible(false)
		end

		---未开启的
		if datas.fight_id > self.fight_id then
			self["bottle_lock_"..k]:setVisible(true)		
		end


		
		local is_opacity = true
		if v.fight_id == self.fight_id then
			is_opacity = false
		end
		self:showArmatureBoat(battle_jy_info[datas.fight_id].show_ship, self["btn_bottle_"..k], is_opacity)
		local res = btn_pic_gray
		if v.fight_id == self.fight_id and self.fight_id ~= cur_max_fight_id then
			self.battle_key = k 
			res = btn_pic_select
		end
		self["btn_bottle_"..k]:changeTexture(res, res, res, UI_TEX_TYPE_PLIST)

		self["btn_bottle_"..k]:setPressedActionEnabled(true)
		self["btn_bottle_"..k]:addEventListener(function ()
			self:updateUI(datas,k)
		end,TOUCH_EVENT_ENDED)

		if self.fight_id == cur_max_fight_id and k == 1 then
			self.datas = datas
			tab = k
		end 

		if v.fight_id == self.fight_id  then
			self.datas = datas
			tab = k
		end
	end

	self:defaultView(self.datas, tab)
end

function ClsEliteBattleUI:defaultView(data, tab)
	self:updateUI(data,tab)
end

function ClsEliteBattleUI:updateUI(data,num)

	local res = btn_pic_select
	for i=1,BTN_NUM do
		if num == i then
			if self.battle_key then
				if self.battle_key == i then
					res = btn_pic_select
				else
					res = btn_pic_select_2
				end			
			else
				res = btn_pic_select_2

			end

		else
			if self.battle_key == i then
				res = btn_pic_normal
			else
				res = btn_pic_gray
			end
		end
		self["btn_bottle_"..i]:changeTexture(res, res, res, UI_TEX_TYPE_PLIST)
	end

	local rewards = battle_jy_info[data.fight_id].reward_material
	local role_id = getGameData():getPlayerData():getRoleId()	
	local battle_rewards = {}
	local boat_reward = {}
	local item_id_list = {}
	for k,v in pairs(rewards) do
		if v.type ~= "boat" then
			battle_rewards[#battle_rewards + 1 ] = v
			local item_id = v.id
			if(v.type == "exp")then
				item_id = 221
			elseif(v.type == "prosper")then
				item_id = 222
			elseif(v.type == "reward")then
				item_id = 224
			end
			table.insert(item_id_list,item_id)
		end
		if v.role == role_id then
			boat_reward[#boat_reward + 1] = v 
		end
	end

	for i=1,REWARD_NUM do
		self["award_bg_"..i]:setVisible( i <= #battle_rewards)
		self["award_bg_"..i]:setTouchEnabled(i <= #battle_rewards)
	end

	for k,v in pairs(battle_rewards) do
		self["award_icon_"..k] = getConvertChildByName(self["award_bg_"..k], "award_icon_"..k)
		self["award_num_"..k] = getConvertChildByName(self["award_bg_"..k], "award_num_"..k)

		local icon, amount = nil,nil 
		if v.type == "reward" then
			icon = "common_random_equip.png"
			amount = v.amount
		else
			icon, amount = getCommonRewardIcon(getCommonRewardData(v))
		end 
		
		self["award_num_"..k]:setText(amount)
		self["award_icon_"..k]:changeTexture(convertResources(icon), UI_TEX_TYPE_PLIST)
	end


	self.boat_base:setVisible(#boat_reward > 0)
	self.boat_base:setTouchEnabled(#boat_reward > 0)
	if #boat_reward > 0 then
		--print("==========boat_reward[1].id===========",boat_reward[1].id)
		self:showShip3D(boat_reward[1].id)
	end

	self.seamen_name:setText(battle_jy_info[data.fight_id].head_name)
    local sailor = sailor_info[battle_jy_info[data.fight_id].head_img]
    self.seamen_head:changeTexture(sailor.res)
    self.seamen_head:setScale(1)
    if sailor.star >= SAILOR_S_LEVEL then
        self.seamen_head:setScale(0.5)
    end

	self.mid_text_1:setText(battle_jy_info[data.fight_id].explain)

	self.mid_text_2:setText(battle_jy_info[data.fight_id].strategy)

	self.grade = battle_jy_info[data.fight_id].grade
	self.open_num:setText(self.grade)
	local player_level =  getGameData():getPlayerData():getLevel()

	if player_level < self.grade then
		setUILabelColor(self.open_num, ccc3(dexToColor3B(COLOR_RED)))
	else
		setUILabelColor(self.open_num, ccc3(dexToColor3B(COLOR_COFFEE)))
	end
	self.open_text:setVisible(false)
	self.open_num:setVisible(false)

	---总声望
	local total_prestige = getGameData():getPlayerData():getBattlePower()
	local target_prestige = battle_jy_info[data.fight_id].difficulty
	self.prestige_num:setText(target_prestige)
	if total_prestige < target_prestige then
		setUILabelColor(self.prestige_num, ccc3(dexToColor3B(COLOR_RED)))
	else
		setUILabelColor(self.prestige_num, ccc3(dexToColor3B(COLOR_COFFEE)))
	end

	local playerData = getGameData():getPlayerData()
	local cur_fight_id = getGameData():getBattleData():getMaxBattleId()
    if data.fight_id == self.fight_id and cur_fight_id ~= self.fight_id then -- self.grade and self.grade <= playerData:getLevel()and data.eliteOpen
        self.btn_fight:active()
    else
        self.btn_fight:disable()
    end

	self.btn_fight:setPressedActionEnabled(true)
	self.btn_fight:addEventListener(function ()
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
        local battle_info_config_data = getGameData():getBattleInfoConfigData()
        battle_info_config_data:setConfigFileFlag(battle_info_config_data.ELITE_CONFIG)
        --local cur_fight_id = getGameData():getBattleData():getMaxBattleId()
        local data_id = toint(battle_jy_info[data.fight_id].data)

        self:close()
        GameUtil.callRpc("rpc_server_elite_battle_start", {data_id})

	end,TOUCH_EVENT_ENDED)	

	local all_complated_status = getGameData():getBattleData():getAllComplated()
	if all_complated_status == ELITE_BATTLE_ALL_COMPLATED_STATUS then
		alert:warning({msg = clsUiWord.ELITE_BATTLE_ALL_COMPLATED, size = 26})
	end

	self.boat_base:addEventListener(function()
    	local tip = self:showItemTip(223)
    	if(not tip)then return end
		getUIManager():create("ui/view/clsBaseTipsView", nil, "EliteBattleTip", {is_back_bg = true},tip, true)
    end, TOUCH_EVENT_ENDED)

	for i=1,REWARD_NUM do
		self["award_bg_"..i]:addEventListener(function()
    		local tip = self:showItemTip(item_id_list[i])
    		if(not tip)then return end
			getUIManager():create("ui/view/clsBaseTipsView", nil, "EliteBattleTip", {is_back_bg = true},tip, true)
    	end, TOUCH_EVENT_ENDED)
	end
end

function ClsEliteBattleUI:configEvent()
    self.btn_close:setPressedActionEnabled(true)
    self.btn_close:addEventListener(function()
    	audioExt.playEffect(music_info.COMMON_CLOSE.res)
		local battle_info_config_data = getGameData():getBattleInfoConfigData()
		battle_info_config_data:setConfigFileFlag(battle_info_config_data.GENERAL_CONFIG)
		if self.close_callback then
			self.close_callback()			
		end

        self:close()
    end, TOUCH_EVENT_ENDED)

end

function ClsEliteBattleUI:init3D()
	
	self.layer_id = 1
	self.scene_id = SCENE_ID.ELITE
	local parent = CCNode:create()
	self.boat_base:addCCNode(parent)
	
	Main3d:createScene(self.scene_id) 
	
	-- layer
	Game3d:createLayer(self.scene_id, self.layer_id, parent)
    self.layer3d = Game3d:getLayer3d(self.scene_id, self.layer_id)

	
	self.layer3d:setTranslation(CameraFollow:cocosToGameplayWorld(ccp(240,-80)))
	self:rotation3D()
end 

-- -- 3d旋转
function ClsEliteBattleUI:rotation3D()
	if self.hander_time then return end 
	
	local angle_speed = 25
	local function step(dt)
		self.layer3d:rotateY(math.rad(angle_speed*dt))
	end 
	--local scheduler = CCDirector:sharedDirector():getScheduler()
	self.hander_time = scheduler:scheduleScriptFunc(step, 0, false)
end 

local ship_scale = {
	["smallShip"] = 0.72,
	["middleShip"] = 0.68,
	["bigShip"] = 0.7,
}

-- 显示3D船
function ClsEliteBattleUI:showShip3D(boat_id)	
	if boat_info[boat_id] == nil then return end 
	
	if tolua.isnull(self.layer3d) then
		return 
	end
	
	self.layer3d:removeAllChildren()
	local path = SHIP_3D_PATH
	local node_name = string.format("boat%.2d", boat_info[boat_id].res_3d_id)
	local Sprite3D = require("gameobj/sprite3d")
	boat_id = 1
	local item = {
		id = boat_id,
		key = boat_key,
		path = path,
		is_ship = true,
		node_name = node_name,
		ani_name = node_name,
		parent = self.layer3d,
		pos = {x = 0, y = 0, angle = -120}
	}
	local ship_model = Sprite3D.new(item)
	if boat_info[boat_id].kind and ship_scale[boat_info[boat_id].kind] then
		ship_model.node:setScale(ship_scale[boat_info[boat_id].kind])
	end
end 

--骨骼动画
function ClsEliteBattleUI:showArmatureBoat(boat_id, node, is_opacity)

	local boat_config = ClsDataTools:getBoat(boat_id)

	local res_armature = string.format("armature/ship/%s/%s.ExportJson", boat_config.effect, boat_config.effect)
	armature_manager:addArmatureFileInfo(res_armature)	
	self.ship_show_sprite = CCArmature:create(boat_config.effect)
	self.ship_show_sprite:getAnimation():playByIndex(0)
	node:addCCNode(self.ship_show_sprite)


	local seaman_width = self.ship_show_sprite:getContentSize().width
	self.ship_show_sprite:setScale(90 / seaman_width)
	--autoScaleWithLength(self.ship_show_sprite, 80)
	local set_opacity = 255
	if is_opacity then
		set_opacity = 255*0.5
	end
	self.ship_show_sprite:setOpacity(set_opacity)
	-- self.ship_show_sprite:setRotation(345)
	self.ship_show_sprite:setPosition(boat_config.boatPos[1] - 15, boat_config.boatPos[2] + 9)
end

function ClsEliteBattleUI:showItemTip( itemId )
	local item_config = item_info[itemId]
	if(not item_config)then return end
	local panel = GUIReader:shareReader():widgetFromJsonFile("json/backpack_tips.json")
	panel:setPosition(ccp(260, 70))
	local item_icon = getConvertChildByName(panel, "box_icon")
	local item_bg = getConvertChildByName(panel, "box_bg")
	local item_name = getConvertChildByName(panel, "box_name")
	local item_num = getConvertChildByName(panel, "box_tips_num")
	local item_intro = getConvertChildByName(panel, "box_introduce")

	local btn_use = getConvertChildByName(panel, "btn_use")
	btn_use:setVisible(false)
	local consume_panel = getConvertChildByName(panel, "consume_panel")
	consume_panel:setVisible(false)
	local box_tips = getConvertChildByName(panel,"box_tips")
	box_tips:setVisible(false)
	
	local quality = item_config.quality or item_config.level
	setUILabelColor(item_name, ccc3(dexToColor3B(QUALITY_COLOR_NORMAL[quality])))
	local item_bg_res = string.format("item_box_%s.png", quality)
	item_bg:changeTexture(item_bg_res, UI_TEX_TYPE_PLIST)

	item_icon:changeTexture(convertResources(item_config.res), UI_TEX_TYPE_PLIST)
	item_name:setText(item_config.name)
	item_num:setText("")
	item_intro:setText(item_config.desc)

	return panel
end


function ClsEliteBattleUI:onExit()
	if self.hander_time then 
		scheduler:unscheduleScriptEntry(self.hander_time) 
		self.hander_time = nil
	end

	local battle_info_config_data = getGameData():getBattleInfoConfigData()
	battle_info_config_data:setConfigFileFlag(battle_info_config_data.GENERAL_CONFIG)

	UnLoadPlist(self.plistTab)
	self.layer3d = nil
    Main3d:removeScene(self.scene_id)
end

return ClsEliteBattleUI
