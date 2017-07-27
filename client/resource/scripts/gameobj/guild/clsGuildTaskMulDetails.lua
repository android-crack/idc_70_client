local Alert = require("ui/tools/alert")
local ClsUiTools = require("gameobj/uiTools")
local ClsDataTools = require("module/dataHandle/dataTools")
local guild_task_info = require("game_config/guild/guild_task_team_info")
local sailor_info = require("game_config/sailor/sailor_info")
local sailor_job = require("game_config/sailor/sailor_job")
local ui_word = require("game_config/ui_word")
local music_info=require("game_config/music_info")
local composite_effect = require("gameobj/composite_effect")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")


local HEAD_SCALE = 0.16
local HEAD_SCALE_2 = 0.3
local ClsSailorCell = class("ClsSailorCell", ClsScrollViewItem)


ClsSailorCell.updateUI = function(self, data, cell_ui)
	self.data = data
	self:mkUi()
end
ClsSailorCell.mkUi = function(self, index)

	local panel = GUIReader:shareReader():widgetFromJsonFile("json/guild_task_multi_assign_bar.json")
	self:addChild(panel)

	local sailor_config = sailor_info[self.data.id]

	--头像
	local list_head = getConvertChildByName(panel, "sailor_head")
	list_head:changeTexture(sailor_config.res, UI_TEX_TYPE_LOCAL)
	list_head:setVisible(true)
	list_head:setScale(1)
	local size = list_head:getContentSize()
	
	list_head:setScale(50/size.width)
   

	--执行力
	local execution = nil
	if self.sailorExecution then
		execution = self.sailorExecution
	else
		execution = ((sailor_config.star - 1) * 5 + self.data.starLevel) * self.data.level
	end

	local power_num_lab = getConvertChildByName(panel, "power_num")
	power_num_lab:setText(execution)

	--名字
	local list_sailor_name = getConvertChildByName(panel, "sailor_name")
	list_sailor_name:setText(self.data.name)

	--职业图
	local job_icon_spr = getConvertChildByName(panel, "job_icon")
	job_icon_spr:changeTexture(JOB_RES[sailor_config.job[1]], UI_TEX_TYPE_PLIST)

	--职业
	local list_sailor_job = getConvertChildByName(panel, "job_name")
	list_sailor_job:setText(ROLE_OCCUP_NAME[self.data.job[1]])

	--工作中
	self.sailor_working = getConvertChildByName(panel, "assign_tick")

	if self.status == TASK_DOING then
		self:setSelectState(true)
	else
		self:setSelectState(false)
	end
	-- for k, v in pairs(self.sailor_type) do
	--     if v == self.data.job[1] then
	--         local fire = CCArmature:create("fire")
	--         fire:getAnimation():playByIndex(0)
	--         fire:setPosition(ccp(160, 45))
	--         fire:setCascadeOpacityEnabled(true)
	--         self.layer:addChild(fire, 0)
	--     end
	-- end
end

ClsSailorCell.setSelectState = function(self, is_select_b)
	if is_select_b then
		self.sailor_working:setVisible(true)
	else
		self.sailor_working:setVisible(false)
	end
end

ClsSailorCell.onTap = function(self)
	if self.tapFunc then
		self:tapFunc()
	end
end

ClsSailorCell.setTapCallFunc = function(self, func)
	self.tapFunc = func
end

------------------------------------------------------
local ClsBaseView = require("ui/view/clsBaseView")
local ClsGuildTaskMulDetails = class("ClsGuildTaskMulDetails", ClsBaseView)

local TASK_BEGIN = 1 --前往任务
local TASK_DOING = 2 --查看
local TASK_COMPLETE = 3 --可领奖
local FLAG_JOIN = 1 --我参与了

local FLAG_START_MYSELF = 1 --我自己开启的

local TASK_CREATE = 5 --任务生成但是并没有发布(自己有任务但是没有开始)

local KIND_OTHER_JOB = 10000000001


ClsGuildTaskMulDetails.getViewConfig = function(self)

	local effect_type = UI_EFFECT.DOWN
	local ClsGuildTaskPanel = getUIManager():get("ClsGuildTaskPanel")

	-- if not tolua.isnull(ClsGuildTaskPanel) then
	--     local effect_status = ClsGuildTaskPanel:getDownEffectStatus()
	--     if effect_status then
	--         effect_type = 0
	--     end
	-- end
	
	return {
		is_swallow = true,
		effect = effect_type,
	}
end

ClsGuildTaskMulDetails.onEnter = function(self, missionKey)

	self.missionKey = missionKey
	local guildTaskData = getGameData():getGuildTaskData()
	self.mission_data = guildTaskData:getTaskByKey(missionKey)
	if not self.mission_data and (self.missionKey == guildTaskData:getCurOpenMissonKey()) then
		self.mission_data = guildTaskData:getCurOpenMisson()
	end

	self:initUI()    
	self:askForData()
  
end

ClsGuildTaskMulDetails.initUI = function(self)
	self.plist = {
		["ui/box.plist"] = 1,
	}
	LoadPlist(self.plist)

	self.armatureTab ={
		"effects/fire.ExportJson",
	}
	LoadArmature(self.armatureTab)

	local panel = GUIReader:shareReader():widgetFromJsonFile("json/guild_task_multi_detail.json")
	self:addWidget(panel)
	self.panel = panel

	local bg = getConvertChildByName(panel, "assign_bg")
	self.m_bg_spr = bg

	self.m_multi_pic_spr = getConvertChildByName(self.m_bg_spr, "multi_pic")
	self.m_multi_pic_spr:setVisible(false)
	self.m_my_multi_info_spr = getConvertChildByName(self.m_bg_spr, "my_multi_info")
	self.m_my_multi_info_spr:setVisible(false)

	self.sailors_bg = getConvertChildByName(panel, "right_panel")


	self.select_sailors = {} --当前选中任命的水手
	self.icons = {} --选中的水手头像及航海术
	self.cells = {} --任命时候所有水手cell
	self.rightSailors = nil --开启任务时，所有合适的有序的水手

	local close = getConvertChildByName(panel, "close_btn")
	close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		end,TOUCH_EVENT_BEGAN)
	close:addEventListener(function()

		self:close()
		local guildTaskData = getGameData():getGuildTaskData()
		guildTaskData:askMissionList()
	end, TOUCH_EVENT_ENDED)
end


ClsGuildTaskMulDetails.onExit = function(self)
	self:removeTimeHander()
	UnLoadPlist(self.plist)
	UnLoadArmature(self.armatureTab)    
end

--请求详细信息
ClsGuildTaskMulDetails.askForData = function(self)
	local guildTaskData = getGameData():getGuildTaskData()
	guildTaskData:askGroupMissionDetails(self.missionKey)
end

ClsGuildTaskMulDetails.adaptSpriteTail = function(self, first_spr, second_spr, offset_n)
	offset_n = offset_n or 0
	local pos = first_spr:getPosition()
	second_spr:setPosition(ccp(pos.x + first_spr:getContentSize().width + offset_n, pos.y))
end

ClsGuildTaskMulDetails.updateView = function(self, data)
	local guildTaskData = getGameData():getGuildTaskData()
	self.data = data
	self:getConfig()

	-- print("--------------ClsGuildTaskPerDetails.data---------")
	-- table.print(self.data)
	--任务背景图
	self.m_multi_pic_spr:changeTexture("ui/guild_task_pic/"..self.config.image, UI_TEX_TYPE_LOCAL)
	self.m_multi_pic_spr:setVisible(true)

	--任务名字
	local mission_name_lab = getConvertChildByName(self.m_multi_pic_spr, "multi_name")
	mission_name_lab:setText(self.config.name)

	--效率
	local timeStr = self.config.time
	local str = 100
	if self.data.efficien then
		str = self.data.efficien
		timeStr = self.config.time / self.data.efficien * 100
	end

	self.efficiency_percent_lab = getConvertChildByName(self.m_multi_pic_spr, "efficiency_text")
	self.efficiency_percent_lab:setText(string.format(ui_word.STR_GUILD_TASK_EFF_TIPS, tostring(str)))

	--耗时
	local mission_cost_time = getConvertChildByName(self.m_multi_pic_spr, "time_text")
	local time = ClsDataTools:getMostCnTimeStr(math.floor(timeStr))
	mission_cost_time:setText(string.format(ui_word.STR_GUILD_TASK_TIME_TIPS, time))
	self.mission_cost_time = mission_cost_time

	--奖励值
	local mission_exp = getConvertChildByName(self.m_multi_pic_spr, "exp_num")
	mission_exp:setText(self.config.sailor_exp)

	--团队当前执行力
	local cur_lab = getConvertChildByName(self.m_my_multi_info_spr, "current_power_num_1")
	cur_lab:setText(self.data.allExecution)
	self.execute_team_num = cur_lab

	--我的执行力
	self.execute_my_num = getConvertChildByName(self.m_my_multi_info_spr, "my_power_num")

	--选中的水手
	for i = 1, 3 do
		if not self.icons[i] then
			self.icons[i] = {}
		end

		local icon = getConvertChildByName(self.m_my_multi_info_spr, string.format("sailor_head_%s", i))
		icon:setVisible(true)
		self.icons[i].icon = icon

		local sail = getConvertChildByName(self.m_my_multi_info_spr, string.format("power_num_%s", i))
		self.icons[i].sail = sail
	end

	self.m_my_multi_info_spr:setVisible(true)
	
	--奖励
	self:updateRewards()

	--水手列表
	self:updateSailorList()

	--初始化选中的水手
	self:setSelectSailors()
	self:setSailor()

	--自动分配/任务开始
	self:updateBtns()

end

--创建已任命的水手
ClsGuildTaskMulDetails.updateApponitedSailors = function(self)
	local guild_task_multi_check_ui = GUIReader:shareReader():widgetFromJsonFile("json/guild_task_multi_check.json")
	convertUIType(guild_task_multi_check_ui)
	self.m_had_appointed_sailors_ui = guild_task_multi_check_ui
	self.sailors_bg:addChild(guild_task_multi_check_ui)
	
	local right_panel = getConvertChildByName(self.m_had_appointed_sailors_ui, "right_panel")
	for i = 1, 3 do
		local person_data = self.data.persons[i]
		local participant_title_bg_str = getConvertChildByName(right_panel, "participant_"..i)
		if person_data then
			participant_title_bg_str:setVisible(true)
			
			local name_lab = getConvertChildByName(participant_title_bg_str, "participant_name_"..i)
			local title_lab = getConvertChildByName(participant_title_bg_str, "participant_job_"..i)
			local num_lab = getConvertChildByName(participant_title_bg_str, "participant_power_num_"..i)
			name_lab:setText(person_data.name)
			title_lab:setText(returnProfessionStr(person_data.job))
			num_lab:setText(person_data.execution)
			
			for j = 1, 3 do
				local icon_str = getConvertChildByName(participant_title_bg_str, "sailor_icon_"..i.."_"..j)
				if person_data.sailors[j] then
					icon_str:setVisible(true)
					local sailor_item = sailor_info[person_data.sailors[j]]
					icon_str:changeTexture(sailor_item.res, UI_TEX_TYPE_LOCAL)
					icon_str:setScale(1)
					local size = icon_str:getContentSize()
					icon_str:setScale(50/size.width)
				else
					icon_str:setVisible(false)
				end
			end
		else
			participant_title_bg_str:setVisible(false)
		end
	end
end

--创建右侧水手
ClsGuildTaskMulDetails.updateSailorList = function(self)
	--可查看
	if self.data.status == TASK_DOING then
		self:updateApponitedSailors()
		return
	end

	if self.data.status == TASK_BEGIN then
		if self.mission_data.isJoin == FLAG_JOIN then
			self:updateApponitedSailors()
		else
			self:updateCanApponitSailors()
		end
	end

	if self.data.status == TASK_CREATE then
		self:updateCanApponitSailors()
	end
end

ClsGuildTaskMulDetails.tryToCloseView = function(self, mission_infos)
	for k, v in pairs(mission_infos) do
		if self.missionKey == v.missionKey then
			if v.status ~= TASK_DOING then
				return false
			end
		end
	end
	self:closeView()
	return true
end

ClsGuildTaskMulDetails.updateCanApponitSailors = function(self)
	local sailor_panel = GUIReader:shareReader():widgetFromJsonFile("json/guild_task_multi_assign.json")
	convertUIType(sailor_panel)
	self.sailor_panel = sailor_panel
	self.sailors_bg:addChild(sailor_panel)

	self.no_sailor = getConvertChildByName(sailor_panel, "no_sailor")
	self.no_sailor:setVisible(false)

	local list_panel = getConvertChildByName(self.sailor_panel, "assign_list_panel")

	self.list_view= ClsScrollView.new(list_panel:getSize().width, list_panel:getSize().height, true, nil, {is_fit_bottom = true})
	self.list_view:setPosition(ccp(485,102))
	self:addWidget(self.list_view)
  
	local sailor_data = getGameData():getSailorData()
	local needSailorType = self.config.sailor_type

	--职业排序，需求的在前面
	local sortJobs = {}
	for k, v in pairs(needSailorType) do
		sortJobs[k] = v
	end
	sortJobs[#sortJobs + 1] = KIND_OTHER_JOB

	--根据职业找水手，再根据航海术排序
	local sailors = {} 
	for k, v in pairs(sortJobs) do
		if v == KIND_OTHER_JOB then
			sailors[k] = sailor_data:getSailorNotJob(needSailorType)
		else
			sailors[k] = sailor_data:getSailorsByJob(v, needSailorType)
		end


		table.sort(sailors[k], function(sailor1, sailor2)
			local sailor_config1 = sailor_info[sailor1.id]
			local execution1 = ((sailor_config1.star - 1) * 5 + sailor1.starLevel) * sailor1.level

			local sailor_config2 = sailor_info[sailor2.id]
			local execution2 = ((sailor_config2.star - 1) * 5 + sailor2.starLevel) * sailor2.level

			return execution1 > execution2
		end)
	end



	local rightSailors = {}
	local index = 1
	local list_item_panel = getConvertChildByName(self.sailor_panel, "assign_list_item")
	local list_item_size =  list_item_panel:getSize()
	for k , v in pairs(sailors) do
		for key, val in pairs(v) do
			rightSailors[#rightSailors + 1] = val
			local curCell = ClsSailorCell.new(CCSize(list_item_size.width, list_item_size.height), val)
			self.list_view:addCell(curCell)
			curCell.status = TASK_BEGIN
			curCell.index = index
			curCell.data = val
			curCell.sailor_type = self.config.sailor_type

			self.cells[val.id] = curCell
			curCell:setTapCallFunc(function()
				self:onCellTap(curCell)
			end)
			index = index + 1
		end
	end

	--self.list_view:addCells(self.cells)
   -- self.list_view:setCurrentIndex(1)
	self.rightSailors = rightSailors

	if #self.rightSailors < 1 then
		self.no_sailor:setVisible(true)
	end
end

ClsGuildTaskMulDetails.onCellTap = function(self, cell)
	audioExt.playEffect(music_info.COMMON_BUTTON.res)
	if self.data.status == TASK_DOING then
		return
	end

	if not tolua.isnull(self.list_view) then
		if cell.data then
			local hasKey = nil 
			local hasValue = nil

			for key, value in pairs(self.select_sailors) do
				if value == cell.data.id then
					hasKey = key
					hasValue = value
					break
				end
			end
			if hasKey and hasValue then --再点击已经选中的数据，进行取消的处理
				table.remove(self.select_sailors, hasKey)
				cell:setSelectState(false)
				self:setSailor()
			else
				self:selectOneSailor(cell)
			end
		end
	end
end

--新选中一个，界面显示头像处理
ClsGuildTaskMulDetails.selectOneSailor = function(self, cell)
	local count = 0
	local has = false
	for key, value in pairs(self.select_sailors) do
		count = count + 1
		if value == cell.data.id then
			has = true
		end
	end
	if has then
		return
	else
		if count >= 3 then
			local tempSailorId = self.select_sailors[1]
			if tempSailorId then
				self.cells[tempSailorId]:setSelectState(false)
				table.remove(self.select_sailors, 1)                
			end
		end

		self.select_sailors[#self.select_sailors + 1] = cell.data.id
		cell:setSelectState(true)
	end
	self:setSailor()
end

ClsGuildTaskMulDetails.setSailor = function(self)
	for i = 1, 3 do
		self.icons[i].icon:setVisible(false)
		self.icons[i].sail:setVisible(false)
	end

	local sailorData = getGameData():getSailorData()
	local allOwnSailors = sailorData:getOwnSailors()

	local corrSailorCount = 0  --选中的航海士数量
	local execute_power = 0  --水手的总执行力

	for k, v in pairs(self.select_sailors) do

		local sailorInfo = allOwnSailors[v]
		if sailorInfo then
			-- local find = false
			-- for key, val in pairs(self.config.sailor_type) do
			--     if sailorInfo.job[1] == val then
			--         find = true
			--         break
			--     end
			-- end

			-- if find then
			--     corrSailorCount = corrSailorCount + 1
			-- end

			self.icons[k].icon:setVisible(true)
			self.icons[k].icon:changeTexture(sailorInfo.res, UI_TEX_TYPE_LOCAL)

			self.icons[k].icon:setScale(1)
			local size = self.icons[k].icon:getContentSize()
			self.icons[k].icon:setScale(50/size.width)

			--总执行力
			local cur_execution = self:getCurExecute(k, sailorInfo)
			execute_power = execute_power + cur_execution

			self.icons[k].sail:setVisible(true)
			self.icons[k].sail:setText(cur_execution)
		end

	end

	self:updateContent(corrSailorCount, math.floor(execute_power))
end

--获取水手当前的执行力（因为有升级升阶，水手执行力不能有变）
ClsGuildTaskMulDetails.getCurExecute = function(self, k, sailorInfo)
	local sailor_config = sailor_info[sailorInfo.id]

	local cur_execution = nil

	local person = self.data.persons[self.select_sailors_person]
	if person and person.sailorExecution and person.sailorExecution[k] then
		cur_execution = person.sailorExecution[k]
	else
		-- 航海士执行力=（航海士阶级*5+航海士星级）*航海士等级
		cur_execution = ((sailor_config.star - 1) * 5 + sailorInfo.starLevel ) * sailorInfo.level
	end
	return cur_execution
end

--更新公会效率、耗时、执行力
ClsGuildTaskMulDetails.updateContent = function(self, corrSailorCount, execute_power)

	if self.data.status == TASK_CREATE or (self.data.status == TASK_BEGIN and self.mission_data.isJoin ~= 1) then

		--我的执行力
		self.execute_my_num:setText(execute_power)

		local temp = self.data.allExecution + execute_power

		--团队执行力
		self.execute_team_num:setText(temp)

		--时间/效率
		self:updateEffiView(corrSailorCount)

		--领奖进度
		if temp > self.config.execution3 then
			self.rewardPro:setPercent(100)
		else
			self.rewardPro:setPercent(temp / self.config.execution3 * 100)
		end
		self:updateRewardsLabelColor(temp)
	end
end

--更新时间 和效率
ClsGuildTaskMulDetails.updateEffiView = function(self, corrSailorCount)
	local total_effi = self.data.efficien + corrSailorCount * 50
	local str = self.config.time / total_effi * 100

	--效率
	self.efficiency_percent_lab:setText(string.format(ui_word.STR_GUILD_TASK_EFF_TIPS, tostring(total_effi)))
	local time = ClsDataTools:getMostCnTimeStr(math.floor(str))
	--耗时
	self.mission_cost_time:setText((string.format(ui_word.STR_GUILD_TASK_TIME_TIPS, time)))
end

ClsGuildTaskMulDetails.getConfig = function(self)
	self.config = guild_task_info[self.data.missionId] 
end


--进度条上的数字颜色显示
ClsGuildTaskMulDetails.updateRewardsLabelColor = function(self, temp)


	setUILabelColor(self.pro1, ccc3(dexToColor3B(COLOR_BROWN)))
	setUILabelColor(self.pro2, ccc3(dexToColor3B(COLOR_BROWN)))
	setUILabelColor(self.pro3, ccc3(dexToColor3B(COLOR_BROWN)))

	self.box_1:changeTexture("box_closed2.png", UI_TEX_TYPE_PLIST)
	self.box_2:changeTexture("box_closed3.png", UI_TEX_TYPE_PLIST)
	self.box_3:changeTexture("box_closed4.png", UI_TEX_TYPE_PLIST)

	if temp < self.config.execution1 then return end

	local dx = 2

	if temp < self.config.execution2 then
		setUILabelColor(self.pro1, ccc3(dexToColor3B(COLOR_YELLOW_STROKE)))

		self.box_1:changeTexture("box_full2.png", UI_TEX_TYPE_PLIST)
		return
	end

	if temp < self.config.execution3 then
		setUILabelColor(self.pro1, ccc3(dexToColor3B(COLOR_YELLOW_STROKE)))
		setUILabelColor(self.pro2, ccc3(dexToColor3B(COLOR_YELLOW_STROKE)))

		-- self.box_1:changeTexture("box_full2.png", UI_TEX_TYPE_PLIST)
		self.box_2:changeTexture("box_full3.png", UI_TEX_TYPE_PLIST)
		return
	end

	setUILabelColor(self.pro1, ccc3(dexToColor3B(COLOR_YELLOW_STROKE)))
	setUILabelColor(self.pro2, ccc3(dexToColor3B(COLOR_YELLOW_STROKE)))
	setUILabelColor(self.pro3, ccc3(dexToColor3B(COLOR_YELLOW_STROKE)))

	-- self.box_1:changeTexture("box_full2.png", UI_TEX_TYPE_PLIST)
	-- self.box_2:changeTexture("box_full3.png", UI_TEX_TYPE_PLIST)
	self.box_3:changeTexture("box_full4.png", UI_TEX_TYPE_PLIST)
end

--奖励显示
ClsGuildTaskMulDetails.updateRewards = function(self)
	--进度条
	local progressbar = getConvertChildByName(self.m_my_multi_info_spr, "bar_content")
	self.rewardPro = progressbar

	local percent = 0
	if self.data.allExecution >= self.config.execution3 then
		percent = 100
	else
		percent = self.data.allExecution / self.config.execution3 * 100
	end
	self.rewardPro:setPercent(percent)


	--参与
	local member_num = getConvertChildByName(self.m_my_multi_info_spr, "participate_rate")
	member_num:setText(#self.data.persons .. "/3")
	self.member_num = member_num

	--进度1
	local pro1 = getConvertChildByName(self.m_my_multi_info_spr, "box_power_num_1")
	local pro2 = getConvertChildByName(self.m_my_multi_info_spr, "box_power_num_2")
	local pro3 = getConvertChildByName(self.m_my_multi_info_spr, "box_power_num_3")
	self.pro1 = pro1
	self.pro2 = pro2
	self.pro3 = pro3

	pro1:setText(self.config.execution1)
	pro2:setText(self.config.execution2)
	pro3:setText(self.config.execution3)


	local reward = self.m_my_multi_info_spr
	--宝箱1
	local box_1 = getConvertChildByName(reward, "power_box_1")
	box_1:setTouchEnabled(true)
	self.box_1 = box_1
	--宝箱2
	local box_2 = getConvertChildByName(reward, "power_box_2")
	box_2:setTouchEnabled(true)
	self.box_2 = box_2
	--宝箱3
	local box_3 = getConvertChildByName(reward, "power_box_3")
	box_3:setTouchEnabled(true)
	self.box_3 = box_3

	self:updateRewardsLabelColor(self.data.allExecution)

	--宝物tips
	local treasureTips = GUIReader:shareReader():widgetFromJsonFile("json/guild_task_tips.json")
	convertUIType(treasureTips)
	reward:addChild(treasureTips)
	treasureTips:setZOrder(10)
	
	treasureTips:setVisible(false)

	--商会贡献
	local contri_icon = getConvertChildByName(treasureTips, "silver_icon")
	contri_icon:changeTexture("txt_common_icon_guild_contribution.png", UI_TEX_TYPE_PLIST)

	--商会贡献值
	local contri_number = getConvertChildByName(treasureTips, "silver_number")
	contri_number:setText(self.config.contribution)
	self.contri_number = contri_number

	--商会经验
	local exp_icon = getConvertChildByName(treasureTips, "honour_icon")
	exp_icon:changeTexture("common_guild_exp.png", UI_TEX_TYPE_PLIST)

	--商会经验值
	local exp_number = getConvertChildByName(treasureTips, "honour_number")
	exp_number:setText(self.config.guild_exp)
	self.exp_number = exp_number

	--物品
	local treasure_icon = getConvertChildByName(treasureTips, "treasure_icon")
	self.treasure_icon = treasure_icon

	--我的执行力
	local execute_my_num = getConvertChildByName(self.m_my_multi_info_spr, "my_power_num")
	execute_my_num:setText(self.data.myExecution)
	self.execute_my_num  = execute_my_num

	local treasure = getConvertChildByName(treasureTips, "treasure_name")
	treasure:setVisible(false)

	local treasure_name = getConvertChildByName(treasureTips, "treasure_name_0")
	treasure_name:setVisible(true)
	self.treasure_name = treasure_name

	-- for key, val in pairs(self.config.rewards) do

	--     local temp = {}
	--     for k, v in pairs(val) do
	--         if k == "type" then
	--             temp["key"] = v
	--         end
	--         if k == "amount" then
	--             temp["value"] = v
	--         end
	--         if k == "id" then
	--             temp["id"] = v
	--         end
	--     end

	--     local icoStr, amount, scale =  getCommonRewardIcon(temp)

	--     icoStr = string.sub(icoStr, 2, #icoStr)
	--     treasure_icon:changeTexture(icoStr, UI_TEX_TYPE_PLIST)
	--     treasure_icon:setScale(scale)
	-- end

	-- local multiple = 0.5
	box_1:addEventListener(function()

		local reward = require("game_config/guild/" .. self.config.rewards1[1])
		self:setReward(reward)

		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local pos = box_1:getPosition()
		treasureTips:setPosition(ccp(pos.x, pos.y))
		treasureTips:setVisible(true)

		local Tips = require("ui/tools/Tips")
		Tips:runAction(treasureTips)
	end, TOUCH_EVENT_BEGAN)
	box_1:addEventListener(function()
		treasureTips:setVisible(false)
	end, TOUCH_EVENT_CANCELED)

	box_1:addEventListener(function()
		treasureTips:setVisible(false)

	end, TOUCH_EVENT_ENDED)


	box_2:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local pos = box_2:getPosition()
		treasureTips:setPosition(ccp(pos.x, pos.y))
		treasureTips:setVisible(true)

		local reward = require("game_config/guild/" .. self.config.rewards2[1])
		self:setReward(reward)

		local Tips = require("ui/tools/Tips")
		Tips:runAction(treasureTips)
	end, TOUCH_EVENT_BEGAN)

	box_2:addEventListener(function()
		treasureTips:setVisible(false)
	end, TOUCH_EVENT_CANCELED)

	box_2:addEventListener(function()
		treasureTips:setVisible(false)
	end, TOUCH_EVENT_ENDED)

	box_3:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local pos = box_3:getPosition()
		treasureTips:setPosition(ccp(pos.x - 40, pos.y))
		treasureTips:setVisible(true)

		local reward = require("game_config/guild/" .. self.config.rewards3[1])
		self:setReward(reward)
		
		local Tips = require("ui/tools/Tips")
		Tips:runAction(treasureTips)
	end, TOUCH_EVENT_BEGAN)

	box_3:addEventListener(function()
		treasureTips:setVisible(false)
	end, TOUCH_EVENT_CANCELED)

	box_3:addEventListener(function()
		treasureTips:setVisible(false)
	end, TOUCH_EVENT_ENDED)

end

ClsGuildTaskMulDetails.setReward = function(self, reward)
	local rewards = {}
	for k, v in pairs(reward) do
		if v.type == ITEM_TYPE_CONTRIBUTE then
			self.contri_number:setText(v.cnt)
		elseif v.type == ITEM_TYPE_GUILD_EXP then
			self.exp_number:setText(v.cnt)
		else

			local temp = {}
			for key, val in pairs(v) do
				if key == "type" then
					temp["key"] = ITEM_TYPE_MAP[val]
				end
				if key == "cnt" then
					temp["value"] = val
				end
				if key == "id" then
					temp["id"] = val
				end
			end

			local icoStr, amount, scale =  getCommonRewardIcon(temp)
			self.treasure_icon:changeTexture(convertResources(icoStr), UI_TEX_TYPE_PLIST)
			--self.treasure_icon:setScale(scale)

			self.treasure_name:setText(amount)
		end
	end
end

ClsGuildTaskMulDetails.askForStart = function(self)

	if self.data.status == TASK_CREATE then
		local guildTaskData = getGameData():getGuildTaskData()
		guildTaskData:askGroupMissionJoin(self.missionKey, self.select_sailors)
	else
		local guildTaskData = getGameData():getGuildTaskData()
		guildTaskData:askGroupMissionJoin(self.missionKey, self.select_sailors)
	end
end

ClsGuildTaskMulDetails.updateBtnsDoing = function(self)
	if tolua.isnull(self.m_had_appointed_sailors_ui) then
		return
	end
	local btn_quit = getConvertChildByName(self.m_had_appointed_sailors_ui, "quit_task")
	btn_quit:disable()

	self.btn_start = getConvertChildByName(self.m_had_appointed_sailors_ui, "start_task")
	self.btn_start:disable()
end

--[[
--创建倒计时定时器
]]
ClsGuildTaskMulDetails.createCDTimer = function(self, callBack, time)
	local scheduler = CCDirector:sharedDirector():getScheduler()
	self:removeTimeHander()
	self.hander_time = scheduler:scheduleScriptFunc(callBack, time, false)
end

ClsGuildTaskMulDetails.removeTimeHander = function(self)
	local scheduler = CCDirector:sharedDirector():getScheduler()
	if self.hander_time then
		scheduler:unscheduleScriptEntry(self.hander_time) 
		self.hander_time = nil 
	end
end

ClsGuildTaskMulDetails.updateBtnStart = function(self)
	if self.data.status == TASK_BEGIN and self.mission_data.isJoin == FLAG_JOIN and self.mission_data.missionFlag == FLAG_START_MYSELF then
		self.btn_start:active()
		self:removeTimeHander()
	end
end

ClsGuildTaskMulDetails.updateBtnsQuit = function(self)
	--开始任务
	if self.mission_data.missionFlag == FLAG_START_MYSELF then
		local data = getGameData():getGuildTaskData()
		self.btn_start_text = getConvertChildByName(self.m_had_appointed_sailors_ui, "start_text")
		self.btn_start_text:setText(ui_word.GUILD_TASK_SEND_MSG)

		self.btn_start = getConvertChildByName(self.m_had_appointed_sailors_ui, "start_task")
		self.btn_start:setPressedActionEnabled(true)
		if self.data.remainTime > 0 then
			self.btn_start:disable()
		else
			self.btn_start:active()
		end

		self:createCDTimer(function()
			local ui = getUIManager():get("ClsGuildTaskMulDetails")
			if not tolua.isnull(ui) then
				ui:updateBtnStart()
			end
			
		end, self.data.remainTime)

		self.btn_start:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self.btn_start:disable()
			data:askRefreshMsg(self.data.missionKey)
		end, TOUCH_EVENT_ENDED)
	else
		self.btn_start = getConvertChildByName(self.m_had_appointed_sailors_ui, "start_task")
		self.btn_start:setVisible(true)
		self.btn_start:disable()
		self.btn_start:setPressedActionEnabled(true)
		self.btn_start:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
		end, TOUCH_EVENT_ENDED)
	end

	--退出
	local btn_quit = getConvertChildByName(self.panel, "quit_task")
	btn_quit:setVisible(true)
	btn_quit:setPressedActionEnabled(true)
	btn_quit:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local guildTaskData = getGameData():getGuildTaskData()
		local call
		call = function(  )
			guildTaskData:askGroupMissionQuit(self.data.missionKey)
		end
		local alertLayer = guildTaskData:alertGiveUpView(call)
		self.alertLayer = alertLayer

	end, TOUCH_EVENT_ENDED)
end

ClsGuildTaskMulDetails.updateBtns = function(self)

	if self.data.status == TASK_CREATE then
		self:updateBtnsBegin()
	end

	if self.data.status == TASK_BEGIN then

		if self.mission_data.isJoin == FLAG_JOIN then
			self:updateBtnsQuit()
		else
			self:updateBtnsBegin()
		end
	end


	if self.data.status == TASK_DOING then
		self:updateBtnsDoing()
	end
end

ClsGuildTaskMulDetails.updateBtnsBegin = function(self)
	self.btn_start = getConvertChildByName(self.sailor_panel, "join_task")
	self.btn_start:setPressedActionEnabled(true)

	self.btn_start:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		if #self.select_sailors == 0 then
			Alert:warning({msg = ui_word.GUILD_TASK_NOT_APPONIT, size = 26})
			return
		end

		self:askForStart()
	end, TOUCH_EVENT_ENDED)

	local btn_auto = getConvertChildByName(self.panel, "quick_assign")
	btn_auto:setVisible(true)
	btn_auto:setPressedActionEnabled(true)
	btn_auto:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		if self.rightSailors then
			local count = #self.rightSailors

			if count > 3 then
				count = 3
			end

			local tempAllSailors = self.rightSailors

			for i = 1, count do
				local sailordata = tempAllSailors[i]
				self:selectOneSailor(self.cells[sailordata.id])
				
				if i == 1 then
					self.list_view:scrollToCellIndex(self.cells[sailordata.id].index)--, true
				end

			end
		end
	end, TOUCH_EVENT_ENDED)
end

ClsGuildTaskMulDetails.setSelectSailors = function(self)
	self.select_sailors = {}
	self.select_sailors_person = nil --玩家自己在persons的index
	if self.data.persons then
		local playerData = getGameData():getPlayerData()
		for k, v in pairs(self.data.persons) do
			
			if playerData:getUid() == v.uid then
				self.select_sailors = v.sailors
				self.select_sailors_person = k
				break;
			end
		end

	end
end

ClsGuildTaskMulDetails.closeView = function(self, missionKey)
	if not missionKey then
		getGameData():getGuildTaskData():askMissionList()
		self:close()
		return
	end
	if self.missionKey == missionKey then
		if not tolua.isnull(self.alertLayer) then
			self.alertLayer.nTouchCallBack()
		end

		self:close()
		local guildTaskData = getGameData():getGuildTaskData()
		guildTaskData:askMissionList()      

	end
end

return ClsGuildTaskMulDetails
