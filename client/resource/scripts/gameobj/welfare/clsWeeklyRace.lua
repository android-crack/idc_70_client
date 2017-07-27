----每日竞赛
local clsDailyActivityTeamRank = require("gameobj/dailyActivity/clsDailyActivityTeamRank")
local ui_word = require("game_config/ui_word")
local music_info=require("game_config/music_info")
local ClsDataTools = require("module/dataHandle/dataTools")

local ClsWeeklyRace = class("ClsWeeklyRace",require("ui/view/clsBaseView"))
local dailyrace_data = require("game_config/daily_activity/dailyrace_data")
local ACTIVITY_STATUS = 1   ---活动状态

local widget_type = {
	[1] = "json/award_race_1.json",
	[2] = "json/award_race_2.json",
}

local ACTIVITY_XUANSHANG_TYPE = 2
local PERSONAL_BTN = 1
local TEAM_BTN = 2
local CLOSE_BTN = 3

local widget_btn = {
	{btn = "personal_bg_btn",txt = "personal_bg_btn_txt",panel = "activity_personal_bg"},
	{btn = "team_bg_btn",txt = "team_bg_btn_txt",panel = "activity_team_bg"},
}

function ClsWeeklyRace:getViewConfig()
	return {
		is_swallow = false,
	}
end


function ClsWeeklyRace:regChild(name,child)
	if not self.child_list then
		self.child_list = {}
	end
	self.child_list[name] = child
end

function ClsWeeklyRace:getRegChild(name)
	if self.child_list then
		return self.child_list[name]
	end
end

function ClsWeeklyRace:unRegChild(name)
	if self.child_list then
		self.child_list[name] = nil
	end
end


function ClsWeeklyRace:onEnter()
	self.plist = {
		["ui/box.plist"] = 1
	}

	self.btn_tag = 1
	LoadPlist(self.plist)
	self:initData()
	self.tab_view = {}
end

function ClsWeeklyRace:initData()
	local daily_activity_data = getGameData():getDailyActivityData()
	daily_activity_data:askWeeklyRaceInfo()  ----下发活动状态

end

function ClsWeeklyRace:handleData()
	local daily_activity_data = getGameData():getDailyActivityData()

	self.weekly_data = daily_activity_data:getWeeklyData()
	self.activity_type = self.weekly_data.type   ----活动类型
	self.left_time = self.weekly_data.remain_time--剩余时间

	local default_tab = self.default_tab or 1
	self:initView()
	self:defultView(default_tab)
end

--初始化界面
function ClsWeeklyRace:initView()
	if not tolua.isnull(self.panel) then
		self.panel:removeFromParentAndCleanup(true)
	end
	if self.activity_type <= 0 then
		self.activity_type = 1
	end
	self.panel = GUIReader:shareReader():widgetFromJsonFile(widget_type[self.activity_type])
	convertUIType(self.panel)
	self:addWidget(self.panel)
	for k,v in pairs(widget_btn) do
		self[v.panel] = getConvertChildByName(self.panel, v.panel)
	end

	self.tab_view[1] = self.activity_personal_bg
	self.tab_view[2] = self.activity_team_bg
	self:updataBtn()
	self:updataPersonView()
	self:updataTeamView()

	self.activity_time_num = getConvertChildByName(self.panel, "activity_time_num")
	self.my_ranking_txt = getConvertChildByName(self.panel, "my_ranking_txt")    
	local time_str = ClsDataTools:getTimeStr1(self.left_time)
	self.activity_time_num:setText(time_str)
	-- 优化 #53998
	-- 每周竞赛排名奖励的钻石数修改为可配置表
	for i=1,3 do
		local str = string.format("reward_num%d",i)
		self.panel[str] = getConvertChildByName(self.panel,str)
		self.panel[str]:setText(dailyrace_data[self.activity_type].step_diamond_reward[i])
	end
end

function ClsWeeklyRace:updataMyRank()
	local rank = getGameData():getDailyActivityData():getMyRank()
	local str = string.format(ui_word.WEEKLY_RACE_RANK, rank)
	self.my_ranking_txt:setText(str)		
end
function ClsWeeklyRace:updataBtn()

	for k,v in pairs(widget_btn) do
		self[v.btn] = getConvertChildByName(self.panel, v.btn)
		self[v.txt] = getConvertChildByName(self.panel, v.txt)

		if k == PERSONAL_BTN then
			setUILabelColor(self[v.txt], ccc3(dexToColor3B(COLOR_TAB_SELECTED)))
		else
			setUILabelColor(self[v.txt], ccc3(dexToColor3B(COLOR_TAB_UNSELECTED)))
		end

		self[v.btn]:addEventListener(function ()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self:defultView(k)
		end,TOUCH_EVENT_ENDED)  
	end
end

function ClsWeeklyRace:hideTips()
	self.reward_tips:setVisible(false)
end

function ClsWeeklyRace:updataPersonView()
	local daily_activity_data = getGameData():getDailyActivityData()
	local have_point = self.weekly_data.point   ----拥有的分数
	self.reward_info = self.weekly_data.step_data   ---领奖信息

	self.personal_bg = getConvertChildByName(self["activity_personal_bg"], "personal_bg")
	self.reward_tips = getConvertChildByName(self["activity_personal_bg"], "reward_tips")
	self.reward_tips_txt = getConvertChildByName(self["activity_personal_bg"], "reward_tips_txt")
	self.reward_tips:setVisible(false)
	self.reward_tips:setZOrder(10)
	self.finished_text_1 = getConvertChildByName(self["activity_team_bg"], "finished_text_1")
	self.finished_text_2 = getConvertChildByName(self["activity_team_bg"], "finished_text_2")
	self.finished_text_1:setVisible(false)
	self.finished_text_2:setVisible(false)

	if not self.reward_info then return  end
	for k,v in ipairs(self.reward_info) do
		local step_status = v
		local step_cost = dailyrace_data[self.activity_type].step[k]
		local max_point = self:getCoinNumber(step_cost)
		if self.activity_type == ACTIVITY_XUANSHANG_TYPE then
			max_point = step_cost
		end

		self["reward_btn"..k] = getConvertChildByName(self.personal_bg,"reward_btn"..k)
		self["reward_ok_txt"..k] = getConvertChildByName(self.personal_bg,"reward_ok_txt"..k)
		----分数
		self["personal_conditions_num"..k] = getConvertChildByName(self.personal_bg,"personal_conditions_num"..k)
		local need_point = max_point

		if have_point >= need_point then
			self["personal_conditions_num"..k]:setText(need_point.."/"..need_point)
		else
			self["personal_conditions_num"..k]:setText(have_point.."/"..need_point)
			self["personal_conditions_num"..k]:setColor(ccc3(dexToColor3B(COLOR_RED)))	
		end

		self["reward_btn"..k]:setPressedActionEnabled(true)
		self["reward_btn"..k]:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self.btn_tag = k
			local step = k
			daily_activity_data:askWeeklyRaceStepReward(step)
		end, TOUCH_EVENT_ENDED)
		local no_reward = 0
		local get_reward = 1
		if step_status == no_reward then
			self["reward_btn"..k]:disable()
			self["reward_ok_txt"..k]:setText(ui_word.DAILY_ACTIVITY_NO_REWARD)  ----未达到
		elseif step_status == get_reward then
			self["reward_btn"..k]:active()
			self["reward_ok_txt"..k]:setText(ui_word.REWARD_GET_2)--可以领取
		else
			self["reward_btn"..k]:disable()
			self["reward_ok_txt"..k]:setText(ui_word.REWARD_HAD_GET)		----已经领取
		end
		self:updataReward(k)
	end
end

function ClsWeeklyRace:updateBtn(  )
	self["reward_btn"..self.btn_tag]:disable()
	self["reward_ok_txt"..self.btn_tag]:setText(ui_word.REWARD_HAD_GET)  ---已领取	
end

function ClsWeeklyRace:updataReward(num)

	local reward_list_info = dailyrace_data[self.activity_type].step_reward[num]
	local reward_name = dailyrace_data[self.activity_type].step_reward_name[num]

	local reward_num = nil
	local reward_icon = nil
	for i=1,3 do
		reward_num = "reward_num"..num.."_"..i
		reward_icon = "reward_icon"..num.."_"..i
		self[reward_num] = getConvertChildByName(self.personal_bg,reward_num)
		self[reward_icon] = getConvertChildByName(self.personal_bg,reward_icon)
		self[reward_num]:setVisible(false)
		self[reward_icon]:setVisible(false)
		self[reward_icon]:removeEventListener(TOUCH_EVENT_ENDED)
	end

	local step_reward_num = "reward_num"..num.."_"..1
	local step_reward_icon = "reward_icon"..num.."_"..1

	self[step_reward_num]:setText("1")
	self[step_reward_icon]:setVisible(true)
	self[step_reward_icon]:changeTexture(convertResources(reward_list_info), UI_TEX_TYPE_PLIST)
	self[step_reward_icon]:setTouchEnabled(true)
	self[step_reward_icon]:addEventListener(function()
		self.reward_tips_txt:setText(reward_name)
		self.reward_tips:setVisible(true)

		local reward_tips_parent = self.reward_tips:getParent()
		local contentSize = reward_tips_parent:getContentSize()
		local temp_point = reward_tips_parent:getVirtualRenderer():convertToWorldSpace(ccp(contentSize.width/2,contentSize.height/2))

		local target_point = self[step_reward_icon]:getVirtualRenderer():convertToWorldSpace(ccp(0,60))

		self.reward_tips:setPosition(ccp(target_point.x - temp_point.x - 66,target_point.y - temp_point.y + 10))
	end,TOUCH_EVENT_ENDED)

end

function ClsWeeklyRace:updataTeamView()
	self["activity_team_bg"]:setVisible(true)
end

function ClsWeeklyRace:defultView(index)
	self.default_tab = index

	if not tolua.isnull(self.rank_view) then
		self.rank_view:removeFromParentAndCleanup(true)
		self.rank_view = nil 
	end

	self.tab_view[1]:setVisible(index == 1)
	self.tab_view[2]:setVisible(index ~= 1)

	if index ~= 1 then
		self:hideTips()
		self.rank_view = clsDailyActivityTeamRank.new()
		self:addWidget(self.rank_view)		
	end

	for k,v in pairs(widget_btn) do
		self[v.btn]:setFocused(index == k)
		self[v.btn]:setTouchEnabled(index ~= k)
		local color = COLOR_TAB_SELECTED
		if index ~= k then
			color = COLOR_TAB_UNSELECTED
		end
		setUILabelColor(self[v.txt], ccc3(dexToColor3B(color)))
	end
end

function ClsWeeklyRace:getCoinNumber(diamound_num)
	local level = self.weekly_data.level
	local num = diamound_num*Math.round(1.5^(math.floor(level/10))*660/100)*100 * 2
	return num 		
end

function ClsWeeklyRace:onExit()
	UnLoadPlist(self.plist)
end

return ClsWeeklyRace
