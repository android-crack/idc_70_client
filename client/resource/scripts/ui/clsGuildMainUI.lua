--
-- 公会界面
--

local ClsGuildBaseUI 	= require("gameobj/guild/clsGuildBaseUI")
local on_off_info 		= require("game_config/on_off_info")
local music_info 		= require("scripts/game_config/music_info")
local ClsAlert 			= require("ui/tools/alert")
local ClsUiWord 		= require("game_config/ui_word")
local ClsGuideMgr 		= require("gameobj/guide/clsGuideMgr")
local error_info 		= require("game_config/error_info")

local ClsGuildMainUI 	= class("ClsGuildMainUI", ClsGuildBaseUI)

-- 静态变量，枚举跳转类型
ClsGuildMainUI.OPEN_SKIP = 
{
	HALL 				= "hall", 
	TASK 				= "task", 
	BOSS 				= "boss", 
	BOSS_RANK 			= "boss_rank",
	GIFT 				= "gift",
	SHOP 				= "shop",
	GUILD_FIGHT			= "guild_fight",
	SKILL_STUDY			= "guild_skill_study",
	SKILL_RESEARCH 		= "guild_skill_research",
	TASK_DETAIL_MULTI 	= "task_detail_multi", -- 多人任务详情
	GUILD_MULTI_TASK 	= "guild_multi_task", -- 多人任务
	DONATE 				= "donate"
}

ClsGuildMainUI.getViewConfig = function()
	return {
		["hide_before_view"] = true, 
		["effect"]			 = UI_EFFECT.FADE,
	}
end

ClsGuildMainUI.onEnter = function(self, open_skip)
	self["has_guild"] 		= getGameData():getGuildInfoData():hasGuild()	-- 是否有商会
	self["hall_panel"]		= nil 											-- 没有商会的时候的商会大厅面板
	self["open_skip"] 		= open_skip or self.OPEN_SKIP.HALL

	-- 商会大厅的关于按钮的成员变量
		-- 跟商会群有关的
	self["btn_group"] 		= {
		["btn"] = nil, 					-- 商户群
		["wechat_icon"] = nil,			-- 微信图标
		["qq_icon"] 	= nil, 			-- qq图标
		["state_text"] 	= nil, 			-- 状态文本
	} 
		-- 以下是没有红点的
	self["btn_people_add"] 	= nil 		-- 申请列表
	self["btn_donate"] 		= nil 		-- 商会捐赠
	self["btn_activity"] 	= nil 		-- 商会活动
	self["btn_member"] 		= nil 		-- 成员管理
		-- 以下是有红点的按钮
	self["btn_notice"] 		= nil 		-- 公告修改
	self["btn_star"] 		= nil 		-- 商会之星
	self["btn_institute"] 	= nil 		-- 商会研究所
	self["btn_warehouse"] 	= nil 		-- 商会仓库
	self["btn_wanted"] 		= nil 		-- 商会悬赏

	self["notice_content"] 	= nil 		-- 商会公告
	self["btn_config"] 		= nil 		-- 关于按钮的配置

	self["open_panel"] 		= nil 		-- 打开的面板
	self["open_tip"] 		= false
	-- 父类中声明了很多与基础信息有关的成员变量
	ClsGuildMainUI.super.onEnter(self)
end

ClsGuildMainUI.initUI = function(self)
	local bg_panel = GUIReader:shareReader():widgetFromJsonFile( ClsGuildBaseUI.guild_bg_json )
	self:addWidget(bg_panel)

	if self.has_guild then
		self:initGuildHallView()
		self:updateGuildHallView()
		getGameData():getGuildInfoData():askGuildInfo()
	else
		self:initGuildHallPanel()
	end
end

ClsGuildMainUI.initGuildHallPanel = function(self)
	self.hall_panel = getUIManager():create("gameobj/guild/clsGuildHallPanel", {}, self.open_skip)
end

ClsGuildMainUI.initGuildHallView = function(self)
	ClsGuildMainUI.super.initGuildHallView(self)

	self.notice_content = getConvertChildByName(self.mine_panel, "notice_content_1")

	self.mine_panel:setVisible(true)
	self.other_panel:setVisible(false)

	self:initGuildGroupBtn()

	local task_data = getGameData():getTaskData()
	self.btn_config = {
		["btn_notice"] = {
			["click_func"] = self.btnNoticeClick
		},
		["btn_donate"] = {
			["click_func"] = self.btnDonateClick
		},
		["btn_activity"] = {
			["click_func"] = self.btnActivityClick,
			["key"] = on_off_info.GUILD_ACTIVITY.value,
			["task_keys"] = { on_off_info.GRADUATE_BUILD_BUILDBUTTON.value, on_off_info.GUILD_ACTIVITY_PORTFIGHT_ENROLL.value},
			["red_point"] = {x = 25, y = 25},
		},
		["btn_member"] = {
			["click_func"] = self.btnMemberClick
		},
		["btn_people_add"] = {
			["click_func"] = self.btnPeopleAddClick,
			["key"] = on_off_info.MEMBERSHIP.value,
			["task_keys"] = { on_off_info.MEMBERSHIP.value },
			["red_point"] = {x = 15, y = 15}
		},
		["btn_star"] = {
			["click_func"] = self.btnStarClick,
			["key"] = on_off_info.GUILD_STAR.value,
			["task_keys"] = { on_off_info.GUILD_STAR.value, on_off_info.GUILD_SALUTE_REWARD.value },
			["red_point"] = {x = 20, y = 20}
		},
		["btn_institute"] = {
			["click_func"] = self.btnInstituteClick,
			-- ["key"] = on_off_info.GUILD_GRADUATE.value,
			-- ["task_keys"] = { on_off_info.GRADUATE_BUILD_BUILDBUTTON.value },
			-- ["red_point"] = {x = 25, y = 25}
		},
		["btn_warehouse"] = {
			["click_func"] = self.btnWarehouseClick,
			["key"] = on_off_info.GUILD_DEPOT.value,
			["task_keys"] = { on_off_info.GUILD_DEPOT_GIFT.value },
			["red_point"] = {x = 25, y = 25}
		},
		["btn_wanted"] = {
			["click_func"] = self.btnWantedClick,
			["key"] = on_off_info.GUILD_TASK.value,
			["task_keys"] = { on_off_info.GUILD_MULTI_TASK.value, on_off_info.GUILD_TASK.value },
			["red_point"] = {x = 25, y = 25}
		},
	}

	for name, config in pairs(self.btn_config) do
		local btn = getConvertChildByName(self.mine_panel, name)

		btn:setPressedActionEnabled(true)
		btn:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			if name ~= "btn_activity" and not tolua.isnull(self.open_tip) then 
				self.open_tip:close()
			end
			config.click_func(self)
		end, TOUCH_EVENT_ENDED)

		if config.key then
			print(name, config.key)
			task_data:regTask(btn, config.task_keys, KIND_CIRCLE, config.key, config.red_point.x, config.red_point.y, true)
		end

		self[name] = btn
	end

	self:skipToPanel()

	ClsGuideMgr:tryGuide("ClsGuildMainUI")
end

ClsGuildMainUI.getCurGuildId = function(self)
	return getGameData():getGuildInfoData():getGuildId()
end

ClsGuildMainUI.initGuildGroupBtn = function(self)
	self.btn_group = {
		["btn"] 		= getConvertChildByName(self.mine_panel, "group"),
		["wechat_icon"] = getConvertChildByName(self.mine_panel, "btn_wechat_icon"),
		["qq_icon"] 	= getConvertChildByName(self.mine_panel, "btn_qq_icon"),
		["state_text"] 	= getConvertChildByName(self.mine_panel, "group_state_text")
	}
end
------------------ SKIP --------------------
ClsGuildMainUI.skipToPanel = function(self, skip_name)
	self.open_skip = skip_name or self.open_skip
	if self.open_skip == nil then return end

	if self.open_skip == self.OPEN_SKIP.HALL then 

	elseif self.open_skip == self.OPEN_SKIP.TASK then 

		self:btnWantedClick()
	elseif self.open_skip == self.OPEN_SKIP.GUILD_MULTI_TASK then 

		self:btnWantedClick()
	elseif self.open_skip == self.OPEN_SKIP.BOSS then 

		if self:canAutoOpenByGuildLevel(GUILD_SYSTEM_TAB.GUILD_BOSS, ClsUiWord.STR_GUILD_BOSS_NAME) then
			self.open_panel = getUIManager():create("gameobj/guild/clsGuildBossUI")
		end
	elseif self.open_skip == self.OPEN_SKIP.BOSS_RANK then 

		if self:canAutoOpenByGuildLevel(GUILD_SYSTEM_TAB.GUILD_BOSS, ClsUiWord.STR_GUILD_BOSS_NAME) then
			self.open_panel = getUIManager():create("gameobj/guild/clsGuildBossUI")
		end
	elseif self.open_skip == self.OPEN_SKIP.GIFT then 

		if self:canAutoOpenByGuildLevel(GUILD_SYSTEM_TAB.GUILD_STORE, ClsUiWord.STR_GUILD_SHOP_NAME) then
			self:btnWarehouseClick(2)
		end
	elseif self.open_skip == self.OPEN_SKIP.SHOP then 
		if self:canAutoOpenByGuildLevel(GUILD_SYSTEM_TAB.GUILD_STORE, ClsUiWord.STR_GUILD_SHOP_NAME)then
			self:btnWarehouseClick()
		end
	elseif self.open_skip == self.OPEN_SKIP.GUILD_FIGHT then 

		local guild_fight_data = getGameData():getGuildFightData()
		guild_fight_data:askEnterGuildFightUI()
	elseif self.open_skip == self.OPEN_SKIP.SKILL_STUDY then 

		if self:canAutoOpenByGuildLevel(GUILD_SYSTEM_TAB.GUILD_RESEARCH, ClsUiWord.STR_GUILD_SKILL_NAME) then
			self.open_panel = getUIManager():create("gameobj/guild/clsGuildSkillResearchMain", nil, GUILD_STUDY)
		end
	elseif self.open_skip == self.OPEN_SKIP.SKILL_RESEARCH then 

		if self:canAutoOpenByGuildLevel(GUILD_SYSTEM_TAB.GUILD_RESEARCH, ClsUiWord.STR_GUILD_SKILL_NAME) then
			self.open_panel = getUIManager():create("gameobj/guild/clsGuildSkillResearchMain")
		end
	elseif self.open_skip == self.OPEN_SKIP.TASK_DETAIL_MULTI then 

		self:btnWantedClick()
	elseif self.open_skip == self.OPEN_SKIP.DONATE then

		self:btnDonateClick()
	end

	self.open_skip = nil 
end

ClsGuildMainUI.canAutoOpenByGuildLevel = function(self, guild_type, open_name)
	local guild_info_data = getGameData():getGuildInfoData()
	local guild_level = guild_info_data:getGuildGrade()
	local open_level = GUILD_SYSTEM_GRADE[guild_type]
	if guild_level < open_level then
		ClsAlert:warning({msg = string.format(ClsUiWord.STR_GUILD_OPEN_LEVEL_TIPS, open_level, open_name)})
		return false
	end
	return true
end
-------------------------------------------

--------------------update-----------------
-- 更新商会信息
ClsGuildMainUI.updateGuildHallView = function(self)
	local info = getGameData():getGuildInfoData():getGuildInfo()
	if not info then return end
	
	-- 如果之前是没有商会，那么这次就是加入商会之后的大动作，要从初始化开始执行
	if not self.has_guild then 
		self.has_guild = true
		if not tolua.isnull(self.hall_panel) then 
			self.hall_panel:close()
		end
		self:initGuildHallView()
	end

	self:updateGuildBaseInfo( info )
	self:updateGuildBtnState()
	self:updateGuildGroupView()
	self:updateGuildNotice()

	local member_panel = getUIManager():get("ClsGuildMemberListPanel")
	if not tolua.isnull(member_panel) then
		member_panel:updateMemberData()
	end
end

-- 更新商会群状态
ClsGuildMainUI.updateGuildGroupView = function(self)
	local group = self.btn_group

	if GTab.IS_VERIFY then
		group.btn:setVisible(false)
		return
	end
	group.btn:setVisible(true)
	-- 判断平台
	local game_sdk = require("module/sdk/gameSdk")
	local platform = game_sdk.getPlatform()
	local task_keys = { on_off_info.GUILD_ADD.value, }
	if platform == PLATFORM_QQ then
		group.wechat_icon:setVisible(false)
		group.qq_icon:setVisible(true)
		getGameData():getTaskData():regTask(group.qq_icon, task_keys, KIND_CIRCLE, task_keys[1], 15, 12, true)
	elseif PLATFORM_WEIXIN == platform then
		group.wechat_icon:setVisible(true)
		group.qq_icon:setVisible(false)
		getGameData():getTaskData():regTask(group.wechat_icon, task_keys, KIND_CIRCLE, task_keys[1], 15, 12, true)
	else
		group.btn:setVisible(false)
		return
	end
	-- 判断是否建群
	local guild_data = getGameData():getGuildInfoData()
	local guild_group_open_id = guild_data:getGuildGroupOpenID()
	if guild_group_open_id and guild_group_open_id ~= "" then --建群了
		if guild_data:isCaptain() then
			group.state_text:setText(ClsUiWord.STR_GROUP_BIND)
		else
			if guild_data:getIsJionGroup() == 1 then --加入
				group.state_text:setText(ClsUiWord.STR_GROUP_BIND)
			else
				group.state_text:setText(ClsUiWord.STR_CREATED)
			end
		end
	else
		group.state_text:setText(ClsUiWord.STR_GROUP_NO_CREATE)
	end

	group.qq_icon:setPressedActionEnabled(true)
	group.wechat_icon:setPressedActionEnabled(true)

	group.qq_icon:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:touchGroupEvent()
	end, TOUCH_EVENT_ENDED)

	group.wechat_icon:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:touchGroupEvent()
	end, TOUCH_EVENT_ENDED)
end

-- 更新按钮状态
ClsGuildMainUI.updateGuildBtnState = function(self)
	self:updateNoticeBtn()
	self:updatePeopleAddBtn()
end

-- 编辑公告的权利
ClsGuildMainUI.updateNoticeBtn = function(self)
	local can_edit = getGameData():getGuildInfoData():isEidtNotice()

	self.btn_notice:setTouchEnabled(can_edit)
	if can_edit then 
		self.btn_notice:active()
	else
		self.btn_notice:disable()
	end
end

-- 申请列表的权利
ClsGuildMainUI.updatePeopleAddBtn = function(self)
	local is_normal = getGameData():getGuildInfoData():isNormalMember()

	self.btn_people_add:setTouchEnabled(is_normal)
	if is_normal then 
		self.btn_people_add:disable()
	else
		self.btn_people_add:active()
	end
end

-- 这个函数之前的操作是更新研究所按钮上的等级，现在按钮上没有等级
ClsGuildMainUI.updateGuildSkill = function(self)

end

-- 之前的操作是增加倒计时，并且增加按钮上的效果
ClsGuildMainUI.updateBossState = function(self)

end

-- 更新商会之星按钮上的文本
ClsGuildMainUI.updateGuildStar = function(self)
end

-- 更新商会公告
ClsGuildMainUI.updateGuildNotice = function(self)
	self.notice_content:setText(getGameData():getGuildInfoData():getGuildNotice())
end

-- 更新等级、经验
ClsGuildMainUI.updateGuildLevel = function(self)
	local donate_panel = getUIManager():get("ClsGuildDonatePanel")
	if not tolua.isnull(donate_panel) then
		donate_panel:updateGuildLevel()
	end

	local data_handler = getGameData():getGuildInfoData()
	local grade, cur, max = data_handler:getGuildGrade(), data_handler:getCurExp(), data_handler:getMaxExp()
	ClsGuildMainUI.super.updateGuildLevel(self, grade, cur, max)
end
---------------------------------------

--------- 按钮的点击方法 --------------
-- 商会群
ClsGuildMainUI.touchGroupEvent = function(self)
	local task_keys = {on_off_info.GUILD_ADD.value}
	getGameData():getTaskData():setTask(task_keys[1], false)

	local guild_data = getGameData():getGuildInfoData()
	local guild_group_open_id = guild_data:getGuildGroupOpenID()
	if guild_group_open_id and guild_group_open_id ~= "" then --建群了
		if guild_data:isCaptain() then --是会长大大--弹出管理群
			self.open_panel = getUIManager():create("gameobj/guild/clsGuildGroupManageView")
		else
			--加入群聊
			ClsAlert:showAttention(ClsUiWord.STR_GROUP_JOIN, function()
				--加入工会群
				getGameData():getGuildInfoData():askJoinGroup()
			end, nil, nil, {ok_text = ClsUiWord.STR_GOTO_GROUP, cancel_text = ClsUiWord.STR_GROUP_NOT_CREAT})
		end
	else --未建群
		if guild_data:isCaptain() then --是会长大大
			local tips = ClsUiWord.STR_GROUP_TIPS_LEARD_CREATE
			local module_game_sdk = require("module/sdk/gameSdk")
			local platform = module_game_sdk.getPlatform()
			if platform == PLATFORM_WEIXIN then
				tips = ClsUiWord.STR_GROUP_TIPS_LEARD_CREATE_WX
			end
			ClsAlert:showAttention(tips, function()
				--创建工会群
				getGameData():getGuildInfoData():askCreateGroup()
			end, nil, nil, {ok_text = ClsUiWord.STR_GROUP_CREAT, cancel_text = ClsUiWord.STR_GROUP_NOT_CREAT})
		else
			ClsAlert:warning({msg = ClsUiWord.STR_GROUP_TIPS_NOT_CREATE, size = 26}) 
		end
	end
end

-- 公告修改
ClsGuildMainUI.btnNoticeClick = function(self)
	self.open_panel = getUIManager():create("gameobj/guild/clsGuildNoTicePanel", nil)
end

-- 商会捐献
ClsGuildMainUI.btnDonateClick = function(self)
	self.open_panel = getUIManager():create("gameobj/guild/clsGuildDonatePanel", nil)
end

-- 商会活动（10级解锁）
ClsGuildMainUI.btnActivityClick = function(self)
	if not tolua.isnull(self.open_tip) then
		self.open_tip:close()
	else
		self.open_tip = getUIManager():create("gameobj/guild/clsGuildActivityOptionsPanel")
	end
end

-- 成员管理
ClsGuildMainUI.btnMemberClick = function(self)
	self.open_panel = getUIManager():create("gameobj/guild/clsGuildMemberListPanel")
end

-- 成员申请管理
ClsGuildMainUI.btnPeopleAddClick = function(self)
	local task_data = getGameData():getTaskData()
	for k, v in pairs(self.btn_config["btn_people_add"].task_keys) do
		if task_data:getTaskState(v) then
			task_data:setTask(v, false)
		end
	end

	self.open_panel = getUIManager():create("gameobj/guild/clsGuildApplyManagerUI")
end

-- 商会之星(5级解锁)
ClsGuildMainUI.btnStarClick = function(self)
	if getGameData():getGuildInfoData():getGuildGrade() < 5 then
		ClsAlert:warning({msg = error_info[874].message})
		self.open_panel = getUIManager():create("ui/clsGuildWillOpenTips", nil, 1)
	else
		self.open_panel = getUIManager():create("gameobj/guild/clsGuildPrestigePanel")
	end
end

-- 商会研究所（25级解锁）
ClsGuildMainUI.btnInstituteClick = function(self)
	if getGameData():getGuildInfoData():getGuildGrade() < 25 then
		ClsAlert:warning({msg = error_info[872].message})
		self.open_panel = getUIManager():create("ui/clsGuildWillOpenTips", nil, 3)
	else
		self.open_panel = getUIManager():create("gameobj/guild/clsGuildSkillResearchMain")
	end
end

-- 商会仓库
ClsGuildMainUI.btnWarehouseClick = function(self, index)
	self.open_panel = getUIManager():create("gameobj/guild/clsGuildShopUI", nil, index)
end

-- 商会悬赏（任务）
ClsGuildMainUI.btnWantedClick = function(self)
	local open_skip = self.open_skip or "task"
	self.open_panel = getUIManager():create("gameobj/guild/clsGuildTaskPanel", nil, open_skip)
end

---------------------------------------


ClsGuildMainUI.setBtnClose = function(self, btn_close)
	if btn_close then self.btn_close = btn_close end
end

ClsGuildMainUI.preClose = function(self)
	getUIManager():close("clsGuildHallPanel")
	if not tolua.isnull(self.open_panel) then
		self.open_panel:close()
	end

	-- 商会活动那三个，用self.open_panel，不太好记，直接删除
	getUIManager():close("ClsGuildWillOpenTips")
	getUIManager():close("ClsGuildBossUI")
	getUIManager():close("ClsGuildFightUI")
	getUIManager():close("ClsGuildActivityOptionsPanel")
end

return ClsGuildMainUI
