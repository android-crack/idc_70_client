local ClsUiWord = require("game_config/ui_word")
local ClsDataTools = require("module/dataHandle/dataTools")
local ClsMissionGuide = require("gameobj/mission/missionGuide")
local music_info=require("game_config/music_info")
local on_off_info = require("game_config/on_off_info")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local ClsScrollView = require("ui/view/clsScrollView")

local TODAY = 0
local YESTERDAY = 1

--公会之星
local ClsGuildStarItem = class("ClsGuildStarItem", ClsScrollViewItem)
function ClsGuildStarItem:updateUI(data, cell)
    local rank_icon = getConvertChildByName(cell, "rank_icon")
    local rank_num = getConvertChildByName(cell, "rank_num")
    if data.rank <= 3 then
    	rank_icon:setVisible(true)
    	rank_icon:changeTexture("common_top_" .. data.rank .. ".png" , UI_TEX_TYPE_PLIST)
    	rank_num:setVisible(false)
    else
    	rank_num:setVisible(true)
    	rank_icon:setVisible(false)
    	rank_num:setText(data.rank)
    end

    local name = getConvertChildByName(cell, "name")
    name:setText(data.name)

    local num = getConvertChildByName(cell, "num")
    num:setText(data.invest)

    local playerData = getGameData():getPlayerData()
    if playerData:getUid() == data.uid then
    	setUILabelColor(name, ccc3(dexToColor3B(COLOR_GREEN)))
    	setUILabelColor(rank_num, ccc3(dexToColor3B(COLOR_GREEN)))
    	setUILabelColor(num, ccc3(dexToColor3B(COLOR_GREEN)))
    end
end

--公会荣誉
-----------------------------------------------------------------------------------
local ClsGuildPrestigePanel = class("ClsGuildPrestigePanel", ClsBaseView)

function ClsGuildPrestigePanel:getViewConfig()
	return {
		is_back_bg = true,
		effect = UI_EFFECT.DOWN,
	}
end

function ClsGuildPrestigePanel:onEnter()
	self.plist = {
		["ui/guild_ui.plist"] = 1,
		["ui/box.plist"] = 1,
	}
	LoadPlist(self.plist)
	self.is_guild_b = true

	self.guildPrestigeData = getGameData():getGuildPrestigeData()
	self.guildPrestigeData:askGuildPrestigeInfo()
	self.guildPrestigeData:askGuildCurStartList()

	self.list_status = TODAY

	self:mkUi()
	self:initEvent()

	self.lbl_today_explain:setVisible(true)
	self.lbl_yesterday_explain:setVisible(false)
	self.btn_rank:setVisible(true)
	self.lbl_not_rank_tips:setVisible(false)
end

function ClsGuildPrestigePanel:mkUi()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/guild_honour.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)

	local needWidgetName = {
		["star_level"] = "star_level", --等级
		["star_info"] = "star_info", --头像
		["star_name"] = "star_name", --名字
		["btn_salute"] = "btn_salute", --致敬按钮
		["btn_close"] = "btn_close",
		["lbl_salute"] = "btn_salute_text", --致敬文字
		["lbl_star_info"] = "star_info_text",
		["spr_level_bg"] = "level_bg",
		["btn_rank"] = "btn_rank",
		["lbl_yesterday_explain"] = "rank_explain_1",
		["lbl_today_explain"] = "rank_explain_2",
		["lbl_rank_txt"] = "btn_rank_text",
		["lbl_not_rank_tips"] = "tips_info",
		["spr_bar_times"] = "bg_bar",
		["bar_time"] = "bar",
		["lbl_time"] = "num_text",
		["btn_reward_box"] = "box_bar",
		["lbl_tips"] = "star_info_text_1",
		["spr_tips_line"] = "line",
 	}

 	for k, v in pairs(needWidgetName) do
 		self[k] = getConvertChildByName(self.panel, v)
 	end	

 	self.star_info:setVisible(false)
 	self.star_name:setVisible(false)
 	self.spr_level_bg:setVisible(false)
 	self.lbl_tips:setVisible(false)
 	self.spr_tips_line:setVisible(false)

 	self.lbl_star_info.pos = self.lbl_star_info:getPosition()

 	local task_data = getGameData():getTaskData()
 	local task_keys = {
        on_off_info.GUILD_SALUTE_REWARD.value,
    }
 	task_data:regTask(self.btn_salute, task_keys, KIND_CIRCLE, on_off_info.GUILD_SALUTE_REWARD.value, 70, 16, true)
end

function ClsGuildPrestigePanel:initEvent()
	--界面关闭按钮
	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function() 
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:close()
	end, TOUCH_EVENT_ENDED)

	--致敬按钮
	self.btn_salute:setPressedActionEnabled(true)
	self.btn_salute:addEventListener(function() 
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self.btn_salute:disable(false)
		self.guildPrestigeData:askSalute() 
	end, TOUCH_EVENT_ENDED)

	self.guildPrestigeData:regSaluteUiFunc(function(saluteTime, guildStar)
		self.saluteTime = saluteTime
		self.guildStar = guildStar
		if tolua.isnull(self) then return end
		local playerData = getGameData():getPlayerData()
		local uid = playerData:getUid()
	
		self.star_level:setVisible(guildStar ~= 0 )
		self.btn_salute:setVisible(guildStar ~= 0)
		self.lbl_star_info:setVisible(guildStar ~= 0)
		self.lbl_tips:setVisible(guildStar == 0)		

		local need_guild_b = false
		if guildStar == uid then
			self.btn_salute:setVisible(false)
		else
			if self.saluteTime == 0 then
				self.btn_salute:active()
				self.lbl_salute:setText(ClsUiWord.STR_GUILD_HORNOR_SALUTE)
				need_guild_b = true
			else
				self.btn_salute:disable()
				self.lbl_salute:setText(ClsUiWord.STR_GUILD_HORNOR_SALUTE_DONE)
			end
		end
		self:updateStar()
		if (true == self.is_guild_b) and (true == need_guild_b) and (guildStar ~= 0) then
			self.is_guild_b = false

		end
	end)

	self.btn_rank:addEventListener(function() 
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		if self.list_status == YESTERDAY then
			self.guildPrestigeData:askGuildCurStartList()
			self.list_status = TODAY
			self.lbl_rank_txt:setText(ClsUiWord.STR_GUILD_HORNOR_BTN_TIPS_TODAY)
		else
			self.guildPrestigeData:askGuildStartList()
			self.list_status = YESTERDAY
			self.lbl_rank_txt:setText(ClsUiWord.STR_GUILD_HORNOR_BTN_TIPS_YESTERDAY)
		end
	end, TOUCH_EVENT_ENDED)

	self.btn_reward_box:addEventListener(function() 
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:showReward()
	end, TOUCH_EVENT_BEGAN)
	self.btn_reward_box:addEventListener(function() 
		if not tolua.isnull(self.reward_ui) then
			self.reward_ui:removeFromParent()
		end
	end, TOUCH_EVENT_ENDED)
	self.btn_reward_box:addEventListener(function() 
		if not tolua.isnull(self.reward_ui) then
			self.reward_ui:removeFromParent()
		end
	end, TOUCH_EVENT_CANCELED)
end

function ClsGuildPrestigePanel:updateStarList(ranks)
	local cells = {}
	for k, rank in ipairs(ranks) do
		local data = rank
		data.rank = k

		local cell = ClsGuildStarItem.new(CCSize(360, 40), data)
		cells[#cells + 1] = cell
	end

	if not tolua.isnull(self.story_des_view) then
		self.story_des_view:removeFromParent()
	end

	self.story_des_view = ClsScrollView.new(380, 240, true, function()
		local cell = GUIReader:shareReader():widgetFromJsonFile("json/guild_honour_rank.json")
		return cell
	end, {is_fit_bottom = true})
	self.story_des_view:addCells(cells)
	self.story_des_view:setPosition(ccp(460, 85))
	self:addWidget(self.story_des_view)

	if #ranks == 0 then
		self.lbl_today_explain:setVisible(false)
		self.lbl_yesterday_explain:setVisible(false)
	else
		if self.list_status == TODAY then
		self.lbl_today_explain:setVisible(false)
		self.lbl_yesterday_explain:setVisible(true)
		else
			self.lbl_today_explain:setVisible(true)
			self.lbl_yesterday_explain:setVisible(false)
		end
	end

	
	self.lbl_not_rank_tips:setVisible(#ranks == 0)
end

function ClsGuildPrestigePanel:showReward()
	if not tolua.isnull(self.reward_ui) then
		self.reward_ui:removeFromParent()
	end
	self.reward_ui = createPanelByJson("json/new_star_box_info.json")
	self:addWidget(self.reward_ui)
	self.reward_ui:setPosition(ccp(340, 170))
	local icon = getConvertChildByName(self.reward_ui, "award_icon_1")
	icon:changeTexture("box_full4.png", UI_TEX_TYPE_PLIST)
	icon:setScale(0.2)
	local name = getConvertChildByName(self.reward_ui, "award_text")
	name:setText(ClsUiWord.STR_GUILD_GIFT)
	local num = getConvertChildByName(self.reward_ui, "award_num_1")
	num:setText("1")
end

function ClsGuildPrestigePanel:updateStar()
	local starData = self.guildPrestigeData:getStarData()
	local prestigeName = ClsUiWord.STR_GUILD_HORNOR_HAVE_NO_STAR
	if starData["name"] ~= nil and starData["name"] ~= "" then prestigeName = starData["name"] end

	self.star_name:setVisible(true)
	self.star_name:setText(prestigeName)

	local prestigeLevel = 0
	if starData["level"] ~= nil and starData["level"] ~= 0 then prestigeLevel = starData["level"] end
	self.star_level:setText(string.format("Lv.%d", prestigeLevel))
	if prestigeLevel == 0 then
		self.spr_level_bg:setVisible(false)
		self.spr_bar_times:setVisible(false)
		self.btn_reward_box:setVisible(false)
		self.btn_reward_box:setEnabled(false)
	else
		self.spr_level_bg:setVisible(true)
		self.spr_bar_times:setVisible(true)
		self.btn_reward_box:setVisible(true)
		self.btn_reward_box:setEnabled(true)
		table.print(starData)
		local salute_times = starData["saluteTimes"]
		local salute_limit = starData["saluteLimit"]
		self.lbl_time:setText(salute_times .. "/" .. salute_limit)
		self.bar_time:setPercent(salute_times / salute_limit * 100)
		self.btn_reward_box:changeTexture("box_closed4.png", UI_TEX_TYPE_PLIST)
		if salute_times >= salute_limit then
			self.bar_time:setPercent(100)
			self.btn_reward_box:changeTexture("box_full4.png", UI_TEX_TYPE_PLIST)
		end
	end

	self.star_info:setVisible(true)
	local prestigeIcon = 1
	local iconData = ClsDataTools:getSailorIcon(prestigeIcon)
	if starData["icon"] ~= nil and starData["icon"] ~= "" then
		prestigeIcon = tonumber(starData["icon"])
		iconData = ClsDataTools:getSailorIcon(prestigeIcon)
		self.star_info:changeTexture(iconData)
	else
		self.star_info:loadTexture("guild_no_star.png", UI_TEX_TYPE_PLIST)
	end
	self.star_info:setScale(1)

end

function ClsGuildPrestigePanel:onExit()  -- 退出处理
	ReleaseTexture()
	UnLoadPlist(self.plist)
end

return ClsGuildPrestigePanel
