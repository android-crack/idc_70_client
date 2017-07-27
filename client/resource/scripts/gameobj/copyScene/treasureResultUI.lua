--
-- Author: 0496
-- Date: 2016-05-31 16:12:45
-- Function: 寻宝副本的结算界面

local music_info = require("game_config/music_info")
local ui_word = require("game_config/ui_word")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsSceneManage = require("gameobj/copyScene/copySceneManage")

local treasureResultUI = class("treasureResultUI", ClsBaseView)
local scheduler = CCDirector:sharedDirector():getScheduler()

function treasureResultUI:onEnter(result_info, callback)
	local sea_layer = createExploreSea()
	self:addChild(sea_layer, -1)
	self.plist_tab = {
		["ui/box.plist"] = 1,
	}
	LoadPlist(self.plist_tab)
	self.m_result_info = result_info
	self.m_callback = callback
	self:initUI()
	self:configEvent()

	local copy_scene_data = getGameData():getCopySceneData()
	local missions = copy_scene_data:getTreasureMissions()
	local win_uid = copy_scene_data:getWinUid()
	local win_reward = copy_scene_data:getWinReward()
	local win_name = nil
	for _, mission in pairs(missions) do
		if mission.uid == win_uid then
			win_name = mission.name
			break
		end
	end
	self:configUI(missions, win_name, win_reward)
end

function treasureResultUI:initUI()
	--创建自己的结算界面
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/explore_copy_complete.json")
	self:addWidget(self.panel)
	local copy_treasure = getConvertChildByName(self.panel, "copy_treasure")
	local copy_speed = getConvertChildByName(self.panel, "copy_speed")
	copy_speed:setEnabled(false)
	copy_speed:setVisible(false)
	copy_treasure:setEnabled(true)
	copy_treasure:setVisible(true)
	local need_widget_name = {
		lbl_win_player_name = "win_player_name",
		btn_exit = "btn_exit",
	}

	for k, v in pairs(need_widget_name) do
		self[k] = getConvertChildByName(copy_treasure, v)
	end

	for i = 1, 3 do
		local child_name = string.format("lbl_player_name_%d", i)
		self[child_name] = getConvertChildByName(copy_treasure, string.format("player_name_info_%d", i))
		self[child_name]:setText("")
		child_name = string.format("lbl_player_mission_%d", i)
		self[child_name] = getConvertChildByName(copy_treasure, string.format("player_grade_info_%d", i))
		self[child_name]:setText("")
	end

	for i = 1, 4 do
		local child_name = string.format("spr_award_item_%d", i)
		self[child_name] = getConvertChildByName(copy_treasure, string.format("award_item_%d", i))
		child_name = string.format("lbl_award_num_%d", i)
		self[child_name] = getConvertChildByName(copy_treasure, string.format("baowu_num_%d", i))
		self[child_name]:setText("")
		child_name = string.format("lbl_award_name_%d", i)
		self[child_name] = getConvertChildByName(copy_treasure, string.format("baowu_text_%d", i))
		self[child_name]:setText("")
	end
end

function treasureResultUI:configUI(missions, win_player_name, rewards)
	for i = 1, 3 do
		local player_name = string.format("lbl_player_name_%d", i)
		local mission_name = string.format("lbl_player_mission_%d", i)
		if missions[i] then
			local name_str = missions[i].name
			self[player_name]:setText(name_str)
			local copy_scene_data = getGameData():getCopySceneData()
			local mission_info = copy_scene_data:getMissionInfo(missions[i].type)
			local str_mission = string.format(ui_word.STR_COPY_SCENE_MISSION_NAME, mission_info.name,
				missions[i].progress, missions[i].times)
			self[mission_name]:setText(str_mission)
		else
			self[player_name]:setVisible(false)
			self[mission_name]:setVisible(false)
		end
	end

	for i = 1, 4 do
		local child_name = string.format("spr_award_item_%d", i)
		local child_name_num = string.format("lbl_award_num_%d", i)
		local child_rward_name = string.format("lbl_award_name_%d", i)
		if not rewards[i] then
			self[child_name]:setVisible(false)
			self[child_name_num]:setVisible(false)
			self[child_rward_name]:setVisible(false)
		else
			local icon, cont, _, name = getCommonRewardIcon(rewards[i])
			self[child_name]:setVisible(true)
			self[child_name_num]:setVisible(true)
			self[child_rward_name]:setVisible(true)
			self[child_rward_name]:setText(name)
			icon = convertResources(icon)
			self[child_name]:changeTexture(icon, UI_TEX_TYPE_PLIST)
			self[child_name_num]:setText("x" .. cont)
			local pos_y = self[child_name_num]:getPosition().y
			local pos_x = self[child_rward_name]:getPosition().x + self[child_rward_name]:getContentSize().width + 5
			self[child_name_num]:setPosition(ccp(pos_x, pos_y))
		end
	end

	if not win_player_name then
		self.lbl_win_player_name:setText(ui_word.STR_COPY_SCENE_NOT_WIN_PLAYER_TIPS)
	else
		self.lbl_win_player_name:setText(win_player_name)
	end
	self.lbl_win_player_name:setVisible(true)
end

function treasureResultUI:configEvent()
	self.btn_exit:setPressedActionEnabled(true)
	self.btn_exit:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:closeView()
	end, TOUCH_EVENT_ENDED)
	if self.timer == nil then
		local function callback()
			self:closeView()
		end
		self.timer = scheduler:scheduleScriptFunc(callback,3,false)
	end
end

function treasureResultUI:closeView()
	--以防多次退出
	if self._exit then
		return
	end
	self._exit = true
	local copy_scene_data = getGameData():getCopySceneData()
	copy_scene_data:clearTreasureMission()
	copy_scene_data:setWinUid(nil)
	copy_scene_data:setWinReward(nil)
	if self.m_callback then
		self.m_callback()
	end
	self:removeFromParentAndCleanup(true)
end

function treasureResultUI:onExit()
	UnLoadPlist(self.plist_tab)
	if self.timer then
		scheduler:unscheduleScriptEntry(self.timer)
		self.timer = nil
	end
end

return treasureResultUI
