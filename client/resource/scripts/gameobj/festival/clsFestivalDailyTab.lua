--
-- 日常活动
--

local ClsScrollView 		= require("ui/view/clsScrollView")
local ClsScrollViewItem 	= require("ui/view/clsScrollViewItem")
local daily_config			= require("game_config/duanwu_activity_daily")
local music_info 			= require("game_config/music_info")
local ui_word 				= require("game_config/ui_word")
local ClsAlert   			= require("ui/tools/alert")

------------------------  ClsFestivalDailyCell ------------------------------
local ClsFestivalDailyCell	= class("ClsFestivalDailyCell", ClsScrollViewItem)

function ClsFestivalDailyCell:updateUI(cell_index, cell_panel) 		-- cell_data: { ["step"] = 1, ["schedule"] = 0, ["target"] = 0, "type" = 1 }
	local cell_data  		= getGameData():getFestivalActivityData():getDailyActivityInfo()[cell_index]
	-- 获取控件
	self["task_text"]			 = getConvertChildByName(cell_panel, "task_text") 				-- 任务名字
	self["task_level_info"] 	 = getConvertChildByName(cell_panel, "task_level_info") 		-- 任务等级（一星..）
	self["task_conditions_info"] = getConvertChildByName(cell_panel, "task_conditions_info") 	-- 完成条件
	self["task_award_info_num"]  = getConvertChildByName(cell_panel, "task_award_info_num") 	-- 女神积分奖励
	self["status_pic"]			 = getConvertChildByName(cell_panel, "status_pic") 				-- 全部完成的文本提示
	self["task_icon"]			 = getConvertChildByName(cell_panel, "task_icon") 				-- 任务图标
	self["task_stars"]			 = {}
	for k = 1, 3 do
		table.insert(self.task_stars, getConvertChildByName(cell_panel, "star_"..k))
	end

	-- 得到值
	local task_name 			 = daily_config[cell_data.type].name
	local task_level_txt 		 = ui_word["TASK_STAR_INFO_"..cell_data.step]
	local task_conditions_txt 	 = string.format( daily_config[cell_data.type]["mission_step_"..cell_data.step], cell_data.schedule.."/"..cell_data.target)
	local task_award_num 		 = "+"..daily_config[cell_data.type].mission_score[cell_data.step]
	local task_icon_res			 = daily_config[cell_data.type].mission_icon

	-- 设置
	self.task_icon:changeTexture(task_icon_res, UI_TEX_TYPE_PLIST)
	self.task_text:setText(task_name)
	self.task_level_info:setText(task_level_txt)
	self.task_conditions_info:setText(task_conditions_txt)
	self.task_award_info_num:setText(task_award_num)
	if cell_data.step == 3 and cell_data.schedule >= cell_data.target then
		self.status_pic:setVisible(true)
	else
		self.status_pic:setVisible(false)
	end
	for k = 1, 3 do
		if k <= cell_data.step then
			self.task_stars[k]:setVisible(true)
		else
			self.task_stars[k]:setVisible(false)
		end
	end
end
------------------------------------------------------------------------------

------------------------- ClsFestivalDailyTab --------------------------------
local ClsFestivalDailyTab 	= class("ClsFestivalDailyTab", function() return UIWidget:create() end)

-- json地址
local TAB_JSON_URL 			= "json/activity_dw_daily.json"			-- 界面JSON
local DIALY_LIST_JSON_URL 	= "json/activity_dw_daily_list.json"	-- 日常活动List的JSON
-- 兑换积分
local EXCHANGE_GRADE		= 100
-- 活动列表的一些参数
local ListParams 			=
{
	list_height 			= 250,
	list_width 				= 550,
	list_pos 				= CCPoint(31, 72),
	cell_size 				= CCSize(550, 90)
}

local widget_names			=
{
	"btn_exchange", "grade_num", "have_grade_num", "activity_panel"
}

local LabelColor 			=
{
	Red = ccc3(dexToColor3B(COLOR_RED)),
	Green = ccc3(dexToColor3B(COLOR_GREEN)),
}

function ClsFestivalDailyTab:ctor()
	self["panel"]			= nil 		-- panel
	self["btn_exchange"]	= nil 		-- 兑换按钮
	self["grade_num"] 		= nil 		-- 兑换积分
	self["have_grade_num"] 	= nil 		-- 拥有积分
	self["activity_list"]	= nil 		-- 活动列表
	self["activity_panel"]	= nil 		-- 要加列表的panel

	self:mkUI()
	-- 刷新日常数据
	getGameData():getFestivalActivityData():askDailyActivityInfo()
end

function ClsFestivalDailyTab:mkUI()
	self.panel = GUIReader:shareReader():widgetFromJsonFile(TAB_JSON_URL)
	self:addChild(self.panel)

	for k, name in ipairs(widget_names) do 
		self[name] = getConvertChildByName(self.panel, name)
	end

	self.grade_num:setText(EXCHANGE_GRADE)
	self.grade_num:setColor(LabelColor.Green)

	self:initExchangeBtn()
	self:initDailyActivityList()
	self:updateDailyActivity()
end

function ClsFestivalDailyTab:initExchangeBtn()
	self.btn_exchange:setTouchEnabled(true)
	self.btn_exchange:setPressedActionEnabled(true)
	self.btn_exchange:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local grade = getGameData():getFestivalActivityData():getDialyActivityGrade()
		if grade >= EXCHANGE_GRADE then 
			getGameData():getFestivalActivityData():askExchangeDailyActivityGrade()
		else
			ClsAlert:warning({msg = ui_word.NO_DAILY_GRADE_ALERT_TIP_51})
		end
	end, TOUCH_EVENT_ENDED)
end

function ClsFestivalDailyTab:initDailyActivityList()
	self.activity_list = ClsScrollView.new(ListParams.list_width, ListParams.list_height, true, function()
		return GUIReader:shareReader():widgetFromJsonFile(DIALY_LIST_JSON_URL)
	end, {is_fit_bottom = true})
	self.activity_list:setPosition(ListParams.list_pos)
	self.activity_panel:addChild(self.activity_list)

	local activity_data = getGameData():getFestivalActivityData():getDailyActivityInfo()
	local activity_cells = {}
	for k, data in ipairs(activity_data) do
		table.insert(activity_cells, ClsFestivalDailyCell.new(ListParams.cell_size, k))
	end

	self.activity_list:addCells(activity_cells)
end

-- update
function ClsFestivalDailyTab:updateDailyActivity()
	local grade = getGameData():getFestivalActivityData():getDialyActivityGrade()
	self.have_grade_num:setText(grade)

	if grade >= EXCHANGE_GRADE then 
		self.have_grade_num:setColor(LabelColor.Green)
	else
		self.have_grade_num:setColor(LabelColor.Red)
	end

	local activity_data = getGameData():getFestivalActivityData():getDailyActivityInfo()
	for k, data in ipairs(activity_data) do
		self.activity_list:updateCellIndex(k)
	end
end

return ClsFestivalDailyTab
