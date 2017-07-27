-- ui显示队列
-- Author: Ltian
-- Date: 2016-11-11 14:22:20
--
local dialogQuene = {}
local un_exc_dialog_quene = {}

local dialog_type = {
	mission = 1,
	funcOpen = 2,
	upgrade = 3,
	daily 	= 4,	---悬赏任务
	skillDialog = 5, --航海士战斗外技能触发提示框
	exploreRewardEffect = 6, --探索奖励图标特效
	explorePlot = 7, --探索大副对白
	commonReward = 8, --探索奖励图标特效
	loginAward = 9, --登陆奖励类型
	loginAwardUI = 10, --登陆奖励ui界面
	loginAwardClose = 11, --登陆奖励ui关闭界面函数

	copySceneRewardEffect = 13, --探索副本奖励
	sailor_mission_reward = 14, -- 传记奖励
	shopping_guild_alert = 15,  --特殊商品通知弹框
	auto_pop_welfare = 17, --福利界面自动弹框
	mission_battle = 18, --任务战斗
	un_appiont_alert = 19, --市政厅接在弹框
	ship_reward = 20, --船舶奖励弹框
	battle_power = 21,--战斗力提升弹框
	world_mission_dialog = 22, --世界任务剧情
	chapter_mission_plot = 23, --任务开始/结束章节弹框
	explore_find_new_port = 24, --发现新港口队列
	explore_enter_port = 25, --进入港口
	auto_trade_reward = 26,
	auto_trade_reward_pop = 27,
	obtain_ui = 28, -- 投资界面获得物品弹窗
	port_market_reward = 29,---交易所结算界面
	wine_recruit_reward = 30, ---朗姆酒招募
	time_priate_finish_pop = 31, --时段海盗结束后的奖励弹框
	new_bie_mission_effect = 32,-- 演示战斗后绑定前的新手特效
	explore_sailor_up_level = 33, ---探索界面航海士升级
	nobility_up_effect = 34, ---爵位升级特效
	obtain_new_title_effect = 35, --获得新称号特效
	port_power_change_effect = 36, -- 港口势力变化
	mission_pirate_plot = 37, --任务海盗剧情播放
	sailor_up_level_effect = 38, ---探索界面航海士升级
	team_world_mission_pop = 39, -- 刷世界组队随机任务弹框
	unlock_activity_pop = 40, -- 新活动解锁通知弹框
	ship_effect_ui  = 41,
	addict_tips_pop  = 42,--防沉迷提示框
	city_challenge_pop = 43, --市政厅活动任务
	mission_battle_pop = 44, --主线战斗弹框
	boat_skin_alert = 45, --船舶皮肤过期弹框

}

local dialog_type_proitity = {
	[dialog_type.mission_battle] = 0, --任务战斗
	[dialog_type.un_appiont_alert] = 0, --市政厅水手卸任弹窗
	[dialog_type.chapter_mission_plot] = 2, -- 开始/结束章节弹框
	[dialog_type.mission] = 1,
	[dialog_type.funcOpen] = 1,
	[dialog_type.daily] 	= 1,	---悬赏任务
	[dialog_type.skillDialog] = 111, --航海士战斗外技能触发提示框
	[dialog_type.exploreRewardEffect] = 1, --探索奖励图标特效
	[dialog_type.copySceneRewardEffect] = 1, --探索副本奖励
	[dialog_type.sailor_mission_reward] = 1, -- 传记奖励
	[dialog_type.explorePlot] = 1, --探索大副对白
	[dialog_type.commonReward] = 1, --探索奖励图标特效
	[dialog_type.world_mission_dialog] = 2, --
	[dialog_type.shopping_guild_alert] = 30, -- 特殊商品通知弹框
	[dialog_type.upgrade] = 50,
	[dialog_type.wine_recruit_reward] = 90,---朗姆酒招募
	[dialog_type.loginAwardClose] = 99, --登陆奖励ui界面
	[dialog_type.loginAward] = 100, --登陆奖励类型
	[dialog_type.loginAwardUI] = 101, --登陆奖励ui界面
	[dialog_type.auto_pop_welfare] = 104, -- 福利界面弹框
	[dialog_type.ship_reward] = 106,
	[dialog_type.port_market_reward] = 110,---交易所结算界面
	[dialog_type.battle_power] = 138,
	[dialog_type.explore_find_new_port] = 139, --发现新港口
	[dialog_type.explore_enter_port] = 0, --进入港口
	[dialog_type.auto_trade_reward] = 106,
	[dialog_type.auto_trade_reward_pop] = 105,
	[dialog_type.obtain_ui] = 200, -- 投资界面获得物品弹窗
	[dialog_type.time_priate_finish_pop] = 107, --时段海盗结束后的奖励弹框
	[dialog_type.new_bie_mission_effect] = 2, -- 演示战斗后绑定前的新手特效
	[dialog_type.explore_sailor_up_level] = 150, -- 探索界面航海士升级
	[dialog_type.nobility_up_effect] = 151, -- 爵位升级特效
	[dialog_type.obtain_new_title_effect] = 152, --获得新称号特效
	[dialog_type.port_power_change_effect] = 3, ---- 港口势力变化
	[dialog_type.mission_pirate_plot] = 4, ---- 任务海盗剧情播放
	[dialog_type.sailor_up_level_effect] = 153, --航海士升级特效
	[dialog_type.team_world_mission_pop] = 0, --刷世界组队随机任务弹框
	[dialog_type.unlock_activity_pop] = 0, -- 新活动解锁通知弹框
	[dialog_type.ship_effect_ui] = 2,   --幻彩效果ui
	[dialog_type.addict_tips_pop] = 300,   --防沉迷提示框
	[dialog_type.city_challenge_pop] = 0, --市政厅活动任务
	[dialog_type.mission_battle_pop] = 0, -- 主线战斗失败弹求助框
	[dialog_type.boat_skin_alert] = 2,
}

local lock_quene_table = {}

function dialogQuene:getDialogType()
	return dialog_type
end

--不要调用！上一个队列执行完执行下一个队列的
function dialogQuene:excNextTask()
	self.doing_task = nil
	self.quene_doing = false
	self:excQueneTask()
end

--插入队列
function dialogQuene:insertTaskToQuene(task)
	print("insertTaskToQuene", task:getQueneType())
	local task_type = task:getQueneType()
	task.priority = dialog_type_proitity[task_type] or 0
	local count = #un_exc_dialog_quene
	if count > 0 then
		local priority =  task.priority
		local sequence = #un_exc_dialog_quene
		local index = sequence
		for i=sequence, 1, -1 do
			local target_proity = un_exc_dialog_quene[i].priority
			if target_proity >= task.priority then
			else
				index = index - 1
			end
		end
		table.insert(un_exc_dialog_quene, index + 1, task)
	else
		un_exc_dialog_quene[1] = task
	end
	self:excQueneTask()
end

--暂停队列
function dialogQuene:pauseQuene(cause)
	if cause then
		for i,v in ipairs(lock_quene_table) do
			if cause == v then return end
		end
		lock_quene_table[#lock_quene_table + 1] = cause
	end
end

--激活队列
function dialogQuene:resumeQuene(cause)
	for i,v in ipairs(lock_quene_table) do
		if v == cause then
			table.remove(lock_quene_table, i)
			break
		end
	end
	self:excQueneTask()
end

--真正队列执行的调用
function dialogQuene:excTask()
	local task = table.remove(un_exc_dialog_quene, 1)
	if task and type(task.excTask) == "function" then
		self.quene_doing = true
		self.doing_task = task
		task:excTask()
	else
		task = nil
	end
end

function dialogQuene:excQueneTask()
	if not self.quene_doing and #lock_quene_table < 1 then
		self:excTask()
	else
		--打印暂停表
		if self.quene_doing then
			print("上个队列在还没播完=======================", self.doing_task:getQueneType())
		end
		if #lock_quene_table > 0 then
			print("被外部暂停===============================")
		end
	end
end

function dialogQuene:resetQuene()
	--un_exc_dialog_quene = {}
	self.quene_doing = false
end

--添加获取是否在播放队列的接口
function dialogQuene:isShowing()
	return self.quene_doing
end

---重置队列数据
function dialogQuene:resetSaveDialogTable()
	local removeKeys = {}
	for k,v in ipairs(un_exc_dialog_quene) do
		if v:getQueneType() ~= dialog_type.mission and
		v:getQueneType() ~= dialog_type.upgrade and
		(v:getQueneType() ~= dialog_type.daily) and
		(v:getQueneType() ~= dialog_type.sailor_mission_reward) and
		(v:getQueneType() ~= dialog_type.loginAwardUI)  and
		(v:getQueneType() ~= dialog_type.auto_pop_welfare) and
		(v:getQueneType() ~= dialog_type.far_arena_win_call_back) and
		(v:getQueneType() ~= dialog_type.un_appiont_alert) and
		(v:getQueneType() ~= dialog_type.ship_reward) and
		-- (v:getQueneType() ~= dialog_type.explore_find_new_port) and
		(v:getQueneType() ~= dialog_type.battle_power) and
		(v:getQueneType() ~= dialog_type.auto_trade_reward) and
		(v:getQueneType() ~= dialog_type.auto_trade_reward_pop) and
		(v:getQueneType() ~= dialog_type.time_priate_finish_pop) and
		(v:getQueneType() ~= dialog_type.new_bie_mission_effect) and
		(v:getQueneType() ~= dialog_type.chapter_mission_plot) and
		(v:getQueneType() ~= dialog_type.obtain_new_title_effect ) and
		(v:getQueneType() ~= dialog_type.mission_battle_pop ) and 
		(v:getQueneType() ~= dialog_type.boat_skin_alert ) 

		then
			removeKeys[#removeKeys + 1] = k
		end
	end

	for i = #removeKeys, 1, -1 do
	    table.remove(un_exc_dialog_quene, removeKeys[i])
	end
	self:resetQuene()
end

return dialogQuene
