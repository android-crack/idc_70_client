-- @author: mid
-- @date: 2016年11月15日21:08:17
-- @desc: 市政厅 投资界面

-- include 引用
local alert = require("ui/tools/alert")
local base_info = require("game_config/base_info")
local boat_attribute = require("game_config/boat/boat_attr")
local boat_info = require("game_config/boat/boat_info")
local build_info = require("game_config/port/build_info")
local ClsDataTools = require("module/dataHandle/dataTools")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local composite_effect=require("gameobj/composite_effect")
local equip_material_info = require("game_config/boat/equip_material_info")
local goods_info = require("game_config/port/goods_info")
local goods_type_info=require("game_config/port/goods_type_info")
local invest_cell = require("gameobj/port/clsInvestCell")
local item_info = require("game_config/propItem/item_info")
local jump_info = require("game_config/jump/jump_info")
local music_info = require("game_config/music_info")
local news = require("game_config/news")
local on_off_info = require("game_config/on_off_info")
local port_info = require("game_config/port/port_info") -- 港口信息表
local port_lock = require("game_config/port/port_lock") -- 港口投资解锁信息表
local port_reward_info = require("game_config/port/port_reward_info")
local sailor_info = require("game_config/sailor/sailor_info")
local scheduler = CCDirector:sharedDirector():getScheduler()
local Tips = require("ui/tools/Tips")
local ui_word = require("game_config/ui_word")
local uiTools = require("gameobj/uiTools")
local news_info = require("game_config/news")

-- const define 常量
local STAR = {"e", "d", "c", "b", "a", "s"}
local PORT_TYPE_ICON = {
	["market"] = "cityhall_business_icon.png",
	["pub"] = "cityhall_culture_icon.png",
	["ship"] = "cityhall_industry_icon.png",
}
local LINE_WIDTH = 40
local FRAME_WIDTH = 60
local armatureTab = {
}

-- main logic 主逻辑
local clsPortInvestTabUI = class("clsPortInvestTabUI", function () return UIWidget:create() end)

-- 数据重置
function clsPortInvestTabUI:resetData()
	self.is_init = false -- UI的初始化状态
	self.is_can_send_rpc = true -- 是否能发送升级协议
	self.invest_lv = 0 -- 当前投资等级
	self.is_doing_update = false -- 是否在播放特效
	self.touch_control_list = {} -- 触摸控制数组
	self.item_list = {} -- 列表子项触摸控制数组
	-- 定时器相关
	self:resetTimer()
end

-- 定时器重置
function clsPortInvestTabUI:resetTimer()
	if self.timer then
		scheduler:unscheduleScriptEntry(self.timer)
		self.timer = nil
	end
end

-- 重置协议发送状态
function clsPortInvestTabUI:resetSendState()
	self.is_can_send_rpc = true
end

function clsPortInvestTabUI:ctor()
	self:resetData()
	self:initBaseData()
	self:initUI()
	self:updateUI()
end

function clsPortInvestTabUI:preClose()
	self:resetData()
end

-- 退出时释放资源
function clsPortInvestTabUI:onExit()
	self:resetData()
	UnLoadPlist(self.plistTab)
	ReleaseTexture(self)
	UnRegTrigger(CASH_UPDATE_EVENT)
end

-- 初始化常量数据(只需要初始化一次的数据)
function clsPortInvestTabUI:initBaseData()
	-- ui
	self.plistTab = {
		["ui/cityhall_ui.plist"] = 1,
		["ui/material_icon.plist"] = 1,
	}
	LoadPlist(self.plistTab)
	self.bind_wgts = {

		["btn_close"] = "close_btn", -- 关闭按钮
		["btn_level_up"] = "btn_appoint", -- 提升
		["btn_text"] = "btn_text_upgrade", -- 按钮文字

		["text_port_name_info"] = "port_name_info",-- 港口名+等级
		["text_port_type"] = "port_tpye_info",-- 港口类型
		["text_level_up_comsume_money"] = "btn_appoint_text", -- 升级消耗金钱数
		["text_level_up_comsume_letter"] = "btn_appoint_letter_num",-- 升级消耗信封数
		["text_level_up_reward_honor_num"] = "all_invest_num_2", -- 下阶段奖励的声望数
		["btn_reward_honor"] = "all_invest_icon_2",-- 下阶段奖励的声望图标

		-- ["img_level_up_reward_item_icon"] = "next_icon_level_info", -- 下阶段奖励的图标
		["progress"] = "unlock_progress", -- 总体进度条
		["panel_letter"] = "letter_panel", -- 介绍信界面
		["text_letter_num"] = "btn_appoint_letter_num", -- 介绍信数量说明

		["panel_level_up_reward_item"] = "next_award_panel", -- 下阶段奖励
		["text_level_up_reward"] = "all_invest_text", -- 下阶段经验奖励 文字

		["coin_panel"] = "coin_panel", -- 金币面板
		["letter_panel"] = "letter_panel", -- 推荐信面板
		["text_unmeet_lv"] = "level_limit", -- 等级不满足条件的 提醒文本
	}
	-- modol
	self.port_id = getGameData():getPortData():getPortId()
end

-- 初始化UI
function clsPortInvestTabUI:initUI()
	-- 加载主界面
	local main_ui = GUIReader:shareReader():widgetFromJsonFile("json/cityhall_invest.json")
	self.main_ui = main_ui
	convertUIType(main_ui)
	self:addChild(main_ui)

	-- 绑定控件
	for k, v in pairs(self.bind_wgts) do
		self[k] = getConvertChildByName(main_ui, v)
	end

	self:initBtns() -- 按钮事件
	self:regEvent() -- 监听事件 -- 刷新金币数

	self.node = display.newNode()
	self:addCCNode(self.node)
	self.node:registerScriptHandler(function(event)
		if event == "exit" then
			self:onExit()
		end
	end)
	self:oldOtherLogic() -- 其他逻辑
	self.is_init = true
end

-- 按钮初始化 事件 状态
function clsPortInvestTabUI:initBtns()
	-- 关闭按钮
	local function close_btn_callback()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:resetData()
		getUIManager():get("clsPortTownUI"):showEffectClose()
	end
	local btn_close = self.btn_close
	btn_close:setPressedActionEnabled(true)
	btn_close:addEventListener(close_btn_callback,TOUCH_EVENT_ENDED)

	-- 提升按钮
	local function level_up_btn_callback()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		-- 前端判断是否可升级 可以再发协议
		if self:isCanSendLevelUp() then
			-- 修改是否能发送协议的状态
			self.is_can_send_rpc = false
			-- 直接上行协议 请求提升投资级别协议
			self.pre_value_of_power = getGameData():getPlayerData():getBattlePower()
			getGameData():getInvestData():requestLevelUpInvest(self.port_id)
		end

		-- 测试代码
		-- 测试刷新进度条
		-- self:updateUI(true)

		-- 测试弹出获得的物品信息界面
		-- package.loaded["gameobj/port/clsObtainTipUI"] = nil

		-- local data = {}
		-- data.port_id = self.port_id
		-- data.pre_power = self.pre_value_of_power
		-- getUIManager():create("gameobj/port/clsObtainTipUI", nil, data)
	end
	local btn_level_up = self.btn_level_up
	btn_level_up:setPressedActionEnabled(true)
	btn_level_up:addEventListener(level_up_btn_callback,TOUCH_EVENT_ENDED)
	btn_level_up.msg = "btn_level_up"


	local function diamond_btn_callback()
		local data = {}
		data.id = 222
		getUIManager():create("gameobj/tips/clsCommonItemTips",nil,data)
	end
	self.btn_reward_honor:addEventListener(diamond_btn_callback,TOUCH_EVENT_ENDED)
end

-- 监听事件
function clsPortInvestTabUI:regEvent()
	RegTrigger(CASH_UPDATE_EVENT, function()
		local target_ui = nil
		local is_exist = false
		target_ui = getUIManager():get("clsPortTownUI")
		is_exist = not tolua.isnull(target_ui)
		if is_exist then
			target_ui:getTab(1):updateCashAndLetter()
		end
	end)
end

-- 引导部分逻辑
function clsPortInvestTabUI:oldOtherLogic()
	-- 引导部分
	ClsGuideMgr:tryGuide("clsPortTownUI")
	-- 任务开关部分
	local onOffData = getGameData():getOnOffData()
	onOffData:pushOpenBtn(on_off_info.PORT_TOWN_APPOINT.value, {openBtn = self.btn_level_up, openEnable = true, btn_scale = 0.7,
		addLock = true, tipRes = "#common_lock.png",labelOpacity = 255*0.5, btnRes = "#common_btn_blue1.png", btnShow = true, isUIWidget = true})
	local task_data = getGameData():getTaskData()
	local task_keys = {
		on_off_info.PORT_TOWN.value
	}
	task_data:regTask(self.btn_level_up, task_keys, KIND_RECTANGLE, on_off_info.PORT_TOWN_APPOINT.value, 64, 17, true)
end


-- 在播放特效时 屏蔽所有可触摸的控件
function clsPortInvestTabUI:setTouch(is_touch)
	target_ui = getUIManager():get("clsPortTownUI")
	is_exist = not tolua.isnull(target_ui)
	if is_exist then
		target_ui:setViewTouchEnabled(is_touch)
	end
end

-- 解析界面数据
function clsPortInvestTabUI:parseUIData()

	local data = getGameData():getInvestData():getInvestDataByPortId(self.port_id)

	-- 掉线重连保护
	if not data then
		return false
	end

	local port_id = self.port_id
	self.invest_lv = data.investStep -- 投资等级
	self.total_num = #port_lock[port_id] -- 奖励总数
	self.is_max = (self.invest_lv == self.total_num) -- 是否是最大投资级别
	self.port_data = ClsDataTools:getPort(port_id) -- 港口信息
	return true
end

function clsPortInvestTabUI:setIsGoLvUpEffect(status_b)
	self.is_go_lv_eff = status_b
end

function clsPortInvestTabUI:tryToUpdateUI()
	if self.is_go_lv_eff then
		local dialog_quene = require("gameobj/quene/clsDialogQuene")
		local clsObtainUIQueue = require("gameobj/quene/clsObtainUIQueue")
		local invest_step = getGameData():getInvestData():getStep() - 1
		dialog_quene:insertTaskToQuene(clsObtainUIQueue.new({invest_step = invest_step}))
	else
		self:updateUI()
	end
	self.is_go_lv_eff = false
end

-- 播放升级特效
function clsPortInvestTabUI:showLevelUpEffect(callback, invest_lv)
	invest_lv = invest_lv or self.invest_lv
	-- 屏蔽控件触摸
	self:setTouch(false)

	-- 修改是否正在播放特效的标志
	-- self.is_doing_update = true

	audioExt.playEffect(music_info.TOWN_INVEST.res)

	self:resetTimer()

	local new_percent = (invest_lv+1)/self.total_num*100
	local old_percent = (invest_lv)/self.total_num*100
	local total_time = 0.5 -- 秒
	local time_interval = 0.02 -- 时间间隔
	local times = total_time/time_interval -- 次数
	local add_value_per_time = (new_percent - old_percent)/times -- 每次要更新的数值

	local function progress_callback()
		if times > 0 then
			self.progress:setPercent( math.ceil(new_percent - add_value_per_time*times ) ) -- 进位取整
			times = times - 1
		else
			self:resetTimer()
			self.is_doing_update = false
			-- 重置升级按钮是否发送协议的状态
			self:resetSendState()
			-- 刷新UI
			self:updateUI()
			-- 弹出获得的物品信息界面
			local data = {}
			data.port_id = self.port_id
			data.pre_power = self.pre_value_of_power
			data.callback = callback
			data.callback1 = function () -- 改变播放状态
				local target_ui = getUIManager():get("clsPortTownUI")
				if tolua.isnull(target_ui) then return end
				self.is_doing_update = false
				self:setTouch(true)
				self:updateUI()
				alert:warning({msg = news_info.PORT_TOWN_GOODS.msg}) 
				-- print(" ---------------------- setTouch false")
			end
			getUIManager():create("gameobj/port/clsObtainTipUI", nil, data)
		end
	end
	self.timer = scheduler:scheduleScriptFunc(progress_callback,time_interval,false)
end

-- 刷新界面
function clsPortInvestTabUI:updateUI(data)
	data = data or {}
	local is_show_effect,callback = data.is_show_effect,data.callback
	-- print(" clsPortInvestTabUI updateUI ")
	-- print(" is_show_effect ",is_show_effect)
	-- print(debug.traceback())

	-- 界面数据
	if not self:parseUIData() then return end

	-- 如果还没初始化, 如果还没播放完特效
	if not self.is_init or self.is_doing_update == true then
		return
	end
	self.is_doing_update = true
	-- 点击触摸属性复位
	self:setTouch(true)

	-- 播放升级特效
	if is_show_effect then
		self:showLevelUpEffect(callback, data.invest_step)
		return --不刷新UI(等播放完再刷新)
	end

	local str = ""

	-- 港口名称
	str = self.port_data.name
	str = string.format("%s(" .. ui_word.STR_FRIEND_LV .. "%d)",str,self.invest_lv)
	self.text_port_name_info:setText(str)
	-- 港口类型
	str = ClsDataTools:getPortTypeConfig(self.port_data.type).name
	self.text_port_type:setText(str)

	-- 下一阶段奖励信息 如果最大级别 则隐藏,如果不是 显示对应奖励
	if not self.is_max then
		-- 声望
		local honor_data = port_info[self.port_id].invest_prestige
		self.text_level_up_reward_honor_num:setText(honor_data[self.invest_lv+1])
		-- 奖励信息
		local lock_item_data = port_lock[self.port_id][self.invest_lv+1]
		self.panel_level_up_reward_item:removeAllChildren()

		local item = invest_cell.new(lock_item_data,self.port_id)
		item.lbl_step:setVisible(false)
		item.lbl_goods_type:setVisible(false)
		item.spr_goods_type_bg:setVisible(false)
		item.spr_item_icon:setScale(item.spr_item_icon:getScale()*1.4)
		-- item.btn_item:setTouchEnabled(false)-- 按钮 传递三个状态的图片 设置不可点击
		item.btn_item:changeTexture("common_icon_bg2.png","common_icon_bg2.png","common_icon_bg2.png",UI_TEX_TYPE_PLIST)
		item:setScale(0.56)
		item:setPosition(ccp(2,-14))

		self.panel_level_up_reward_item:addChild(item)
	else
		self.text_level_up_reward_honor_num:setVisible(false)
		self.btn_reward_honor:setVisible(false)
		self.panel_level_up_reward_item:setVisible(false)
		self.text_level_up_reward:setVisible(false)
	end

	-- 进度条相关
	-- 分割图标
	self.progress:removeAllChildren()
	self.progress:setPercent(math.floor(self.invest_lv/self.total_num*100)) -- 进位取整
	local split_sprites_table = {}
	-- local length = self.progress:getContentSize().width -- 691 不准..
	local length = 660
	local spacing = length/self.total_num

	for i=1,self.total_num-1 do
		split_sprites_table[i] = display.newSprite("#cityhall_invest_mark.png")
		split_sprites_table[i]:setPositionX(i*spacing - 0.5*length)
		self.progress:addCCNode(split_sprites_table[i])
	end

	-- 奖励列表
	local port_lock_item_data = port_lock[self.port_id]
	-- 清空数组
	self.item_list = {}
	for k,v in pairs(port_lock_item_data) do
		local item = invest_cell.new(v,self.port_id)
		item:setScale(1)
		item.spr_item_icon:setGray(k > self.invest_lv)
		if k <= self.invest_lv then
			item.btn_item:changeTexture("cityhall_item2.png","cityhall_item2.png","cityhall_item2.png",UI_TEX_TYPE_PLIST)
		end
		item:setPosition(ccp(k*spacing-0.5*length - 0.5*item.width,-item.height))
		-- 存入数组
		self.item_list[#self.item_list+1] = item.btn_item
		self.progress:addChild(item)

		if not self:isVisible() then
			item.btn_item:setTouchEnabled(false)
		end
	end

	-- 更新金币 信封数据 修改按钮 状态
	self:updateCashAndLetter()

	self.is_doing_update = false
end

function clsPortInvestTabUI:updateCashAndLetter()
	-- print(" updateCashAndLetter ")

	if not self.is_init then
		return
	end

	local cur -- 当前数量
	local need -- 需要数量
	local color

	-- 等级不足提醒文本 初始化为不可见
	self.text_unmeet_lv:setVisible(false)
	-- 还没最大
	if not self.is_max then
		-- 按钮文本
		self.btn_text:setText(ui_word.PORT_INVEST_BTN_TEXT)

		-- 不满足等级条件
		if self:isMeetLvCondition().is_ok == false then
			-- 隐藏金币和信封数量面板
			self.coin_panel:setVisible(false)
			self.letter_panel:setVisible(false)
			-- 灰化按钮
			self.btn_level_up:disable()
			-- 等级不足提醒文本
			self.text_unmeet_lv:setVisible(true)
			self.text_unmeet_lv:setText(string.format(ui_word.PORT_INVEST_LEVEL_UP_TIPS_3,self:isMeetLvCondition().next_min_player_lv_for_invest))
		else
			-- 满足等级条件 再判断金钱和推荐信
			-- 金钱
			cur,need = getGameData():getPlayerData():getCash(), port_info[self.port_id].invest_cost[self.invest_lv+1].cash
			cur,need = tonumber(cur),tonumber(need)
			self.text_level_up_comsume_money:setText(need)
			color = cur < need and COLOR_RED or COLOR_YELLOW
			self.text_level_up_comsume_money:setColor(ccc3(dexToColor3B(color)))

			-- 推荐信
			need = port_info[self.port_id].invest_cost[self.invest_lv+1].letter
			self.panel_letter:setVisible(not (tonumber(need)==0)) -- 不需要时隐藏
			if need > 0 then
				cur = getGameData():getPropDataHandler():getTreasureItemCount(63)
				-- print("现在身上推荐信的数量为",cur)
				self.text_letter_num:setText(string.format("%d/%d",cur,need))
				color = cur < need and COLOR_RED or COLOR_YELLOW
				self.text_letter_num:setColor(ccc3(dexToColor3B(color)))
			end
		end
	else
		-- 不需要则都隐藏
		self.coin_panel:setVisible(false)
		self.letter_panel:setVisible(false)
		self.btn_text:setText(ui_word.PORT_INVEST_MAX_TEXT)
		self.btn_level_up:disable() -- 按钮设置为不可点击
	end
end

-- 解析物品数据结构
function clsPortInvestTabUI:parseItemData(lock_data)
	local res = ""
	local isboat = false
	local name = ""
	local title = ""
	local unlock = false
	local desc = ""
	local goods_type = nil
	local goods_decs = nil
	local star_lv = nil
	if lock_data.lock then
		if lock_data.lock.type == "goods" then
			local goods_tab = goods_info[lock_data.lock.id]
			goods_decs = string.format(ui_word.PORT_GOOD_LEVEL, goods_tab.level, goods_type_info[goods_tab.class].name)
			goods_type = ui_word.PORT_NORMAL_GOOD
			if goods_tab.breed == GOOD_TYPE_AREA then
				goods_type = ui_word.PORT_AREA_GOOD
			elseif goods_tab.breed == GOOD_TYPE_PORT then
				goods_type = ui_word.PORT_PORT_GOOD
			end
			res = goods_tab.res
			name = goods_tab.name
			title = ui_word.PORT_INVEST_TYPE_GOODS
			desc = goods_tab.explain
		elseif lock_data.lock.type == "build" then
			res = "#cityhall_item_building.png"
			title = ui_word.PORT_INVEST_TYPE_BUILD
			name = ui_word.PORT_BUILD
			desc = ui_word.PORT_PORT_INVEST_TYPE_BUILD_DESC
		end
	else
		local portData = getGameData():getPortData()
		local curPortId = portData:getPortId()
		local key = string.format(" %d_%d", curPortId, lock_data.step)
		local port_reward_data = port_reward_info[key]
		local r_type = port_reward_data.type
		if r_type == "item" then
			res = item_info[port_reward_data.id].res
			name = item_info[port_reward_data.id].name
			title = ui_word.PORT_INVEST_TYPE_ITEM
			desc = item_info[port_reward_data.id].desc
		elseif r_type == "boat" then
			res = port_reward_data.id
			isboat = true
			name = boat_info[port_reward_data.id].name
			title = ui_word.PORT_INVEST_TYPE_BOAT
			desc = boat_info[port_reward_data.id].explain
			star_lv = boat_attribute[port_reward_data.id].boat_level
		elseif r_type == "sailor" then
			res = sailor_info[port_reward_data.id].res
			name = sailor_info[port_reward_data.id].name
			title = ui_word.PORT_INVEST_TYPE_SAILOR
			desc = sailor_info[port_reward_data.id].explain
			star_lv = sailor_info[port_reward_data.id].star
		elseif r_type == "material" then
			res = equip_material_info[port_reward_data.id].res
			name = equip_material_info[port_reward_data.id].name
			title = ui_word.PORT_INVEST_TYPE_MATERIAL
			desc = equip_material_info[port_reward_data.id].desc
		elseif r_type == "honour" then
			res = "#common_icon_honour.png"
			name = ui_word.PORT_HONOR
			title = ui_word.PORT_HONOR
			desc = ui_word.PORT_HONOR_DESC
		end
		if port_reward_data.cnt >= 1 then
			name = string.format("%s x %d", name, port_reward_data.cnt)
		end
	end
	return title, res, name, desc, isboat, goods_type, goods_decs, star_lv
end

-- 是否满足投资条件
function clsPortInvestTabUI:isMeetLvCondition()
	local t = {}
	-- 判断依据
	local data = getGameData():getInvestData():getInvestDataByPortId(self.port_id)
	local cur_invest_lv = data.investStep -- 当前投资等级
	local cur_player_lv = getGameData():getPlayerData():getLevel() -- 当前玩家等级
	local cur_invest_lv_max = base_info[cur_player_lv].invest_level -- 当前玩家等级对应的最大投资等级
	-- print("当前投资等级",cur_invest_lv)
	-- print("当前玩家等级",cur_player_lv)
	-- print("当前玩家等级对应的最大投资等级",cur_invest_lv_max)
	-- 如果小于 可以投资 大于等于 则不能投资
	if cur_invest_lv >= cur_invest_lv_max then
		-- 需要显示的数据有(当前最大投资等级, 下一阶段的玩家等级)
		local function getNextPlayerLevelMin(i_lv)
			i_lv = tonumber(i_lv)
			-- print("i_lv",i_lv)
			local p_lv = nil
			for i,v in ipairs(base_info) do
				-- print("v.invest_level",v.invest_level)
				-- print("传入的等级:",i_lv)
				if v.invest_level >= i_lv then
					p_lv = i
					break
				end
			end
			-- print("p_lv :", p_lv)
			if p_lv == nil then
				return getNextPlayerLevelMin(i_lv+1)
			else
				return p_lv
			end
		end
		local p_lv = getNextPlayerLevelMin(cur_invest_lv+1)
		t.is_ok = false
		t.cur_max_invest_lv = cur_invest_lv_max
		t.next_min_player_lv_for_invest = p_lv
	else
		t.is_ok = true
	end

	return t
end

-- 升级按钮的判断条件
function clsPortInvestTabUI:isCanSendLevelUp( )
	-- 按照顺序判断,不符合条件就直接返回false,都符合则走到逻辑结束 返回 true

	-- 判断
	local data = getGameData():getInvestData():getInvestDataByPortId(self.port_id)
	local cur_invest_lv = data.investStep -- 当前投资等级

	-- print("1 是否是最大的投资级别")
	if self.is_max then
		return false
	end

	--正在升级不给提升
	if self.timer then
		return false
	end

	-- print("2 是否连续发送协议")
	if self.is_can_send_rpc then
		-- print("设置为不可以发协议")
		-- self.is_can_send_rpc = false
	else
		-- print("设置为可以发协议")
		return false
	end

	-- print( "3 是否满足投资条件限制")
	local result_judge_lv = self:isMeetLvCondition()
	if result_judge_lv.is_ok == false then
		alert:warning({msg = string.format(ui_word.PORT_INVEST_LEVEL_UP_TIPS_1, result_judge_lv.cur_max_invest_lv ,result_judge_lv.next_min_player_lv_for_invest), size = 26})
		return false
	end

	-- print( "4 消耗品是否足够")
	-- 金币
	local cur,need = getGameData():getPlayerData():getCash(), port_info[self.port_id].invest_cost[cur_invest_lv+1].cash
	need = tonumber(need)
	cur = tonumber(cur)
	local is_money_enough = cur >= need
	local money_diff = tonumber(need) - tonumber(cur)
	-- 推荐信
	cur,need = getGameData():getPropDataHandler():getTreasureItemCount(63), port_info[self.port_id].invest_cost[cur_invest_lv+1].letter
	local is_letter_enough = cur >= need
	need = tonumber(need)
	cur = tonumber(cur)
	local letter_diff = tonumber(need) - tonumber(cur)

	-- 如果信封不够
	if (not is_letter_enough) then
		alert:showJumpWindow(LETTER_NOT_ENOUGH, self,{need_cash = money_diff}) -- 快速获取信封
		return false
	else
		-- 如果金钱不够
		if (not is_money_enough) then
			alert:showJumpWindow(CASH_NOT_ENOUGH, self,{need_cash = money_diff}) -- 快速获取钱
			return false
		end
	end

	return true
end

return clsPortInvestTabUI