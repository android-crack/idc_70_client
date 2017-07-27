-- @date: 2016年12月19日17:28:30
-- @author: mid
-- @desc: 活动提醒弹框

-- usage

-- package.loaded["gameobj/tips/clsActivityRemindTips"] = nil
-- local id = 22
-- if not getGameData():getActivityData():getRemindRecord(id) then
-- 	getUIManager():create("gameobj/tips/clsActivityRemindTips",nil,id)
-- end


-- include
local scheduler = CCDirector:sharedDirector():getScheduler()
local cfg = require("game_config/activity/new_activity")
local clsActivityRemindTips = class("clsActivityRemindTips", require("ui/view/clsBaseView"))
local ui_word = require("game_config/ui_word")

-- override
function clsActivityRemindTips:onEnter(id)
	self.id = id
	-- self:resetData()
	self:checkOpen()
	self:initUI()
	self:updateUI()
	getGameData():getActivityData():setActivityOpenTipsHasShow(id)
end

function clsActivityRemindTips:checkOpen()
	local prizon_ui = getUIManager():get("ClsPrizonUI")
	local is_lock = false
    if not tolua.isnull(prizon_ui) then
       is_lock = true
    end
	
	if cfg[self.id].is_ckeck == 1 and is_lock then
		self:close()
		return
	end
end

function clsActivityRemindTips:getViewConfig()
	return {is_back_bg = true}
end

-- logic
function clsActivityRemindTips:initUI()
	local main = GUIReader:shareReader():widgetFromJsonFile("json/tips_common.json")
	convertUIType(main)
	main:setPosition(ccp(display.cx - 210,display.cy-132))
	self:addWidget(main)
	local wgts = {
		["act_icon"]   = "activity_icon",
		["act_name"]   = "activity_name",
		["btn_close"]  = "btn_close",
		["btn_left"]   = "btn_confirm",
		["btn_right"]  = "btn_cancel",
		["activity_open"] = "activity_open",
		["ignore_1"]   = "text_1",
		["ignore_2"]   = "text_2",
		["ignore_3"]   = "text_2",
		["panel"]      = "activity_tips",
		["text_left"]  = "btn_text_confirm",
		["text_right"] = "btn_text_cancel",
	}

	for k,v in pairs(wgts) do
		main[k] = getConvertChildByName(main,v)
	end

	main.panel:setVisible(true)

	for i=1,3 do
		main[string.format("ignore_%d",i)]:setVisible(false)
	end
	local function right_callback()
		self:close()
		local prizon_ui = getUIManager():get("ClsPrizonUI")
		local is_lock = false
	    if not tolua.isnull(prizon_ui) then
	       is_lock = true
	    end
		
		if cfg[self.id].is_ckeck == 1 and is_lock then
			local error_info=require("game_config/error_info")
			local Alert = require("ui/tools/alert")
			Alert:warning({msg = error_info[835].message , size = 26})
			return
		end
		local target = getUIManager():create("gameobj/activity/clsActivityMain")
		if not tolua.isnull(target) then
			target:selectTab(2)
		end
	end
	main.btn_right:addEventListener(right_callback,TOUCH_EVENT_ENDED)
	local function close_callback()
		self:close()
	end
	main.btn_left:addEventListener(close_callback,TOUCH_EVENT_ENDED)
	main.btn_close:addEventListener(close_callback,TOUCH_EVENT_ENDED)
	main.text_right:setText(ui_word.ACTIVITY_GO)
	main.text_left:setText(ui_word.ACTIVITY_WAIT)

	self.main_ui = main
end

function clsActivityRemindTips:updateUI()
	local id = self.id
	-- print("--------id",id)
	-- print("--------- name ",cfg[id].name)
	local main_ui = self.main_ui
	main_ui.act_name:setText(cfg[id].name)
	local act_name_width = main_ui.act_name:getContentSize().width
	local pos = main_ui.activity_open:getPosition()
	local offset_x = act_name_width - 63
	main_ui.activity_open:setPosition(ccp(200 + offset_x, pos.y))
	main_ui.act_icon:changeTexture(cfg[id].activity_icon, UI_TEX_TYPE_PLIST)
end

-- function clsActivityRemindTips:resetData()
-- 	self.is_init = false
-- 	self:resetTimer()
-- end

-- function clsActivityRemindTips:resetTimer()
-- 	if self.timer then
-- 		scheduler:unscheduleScriptEntry(self.timer)
-- 	end
-- 	self.timer = nil
-- end



return clsActivityRemindTips
