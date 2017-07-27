--
-- Author: Ltian
-- Date: 2017-02-03 10:12:21
--
local sailor_op_config = require("game_config/sailor/sailor_op_config")
local music_info = require("game_config/music_info")
local ui_word = require("game_config/ui_word")
local ClsBaseView = require("ui/view/clsBaseView")
local sailor_info = require("game_config/sailor/sailor_info")
local voice_info = getLangVoiceInfo()
local awake_huodong_config = require("game_config/activity/awake_huodong_config")

local ClsSailorAwakeView = class("ClsSailorAwakeView", ClsBaseView)
local item_awaken = 0
local diamoud_awaken = 1
function ClsSailorAwakeView:getViewConfig()
    return { 
        is_back_bg = true, 
         effect = UI_EFFECT.DOWN,
    }
end

function ClsSailorAwakeView:onEnter(sailor)
	self.sailor = sailor
	self.awake_type = item_awaken
	-- local activity_info = getGameData():getActivityData():getSailorAwakeActivityInfo()
	-- if not activity_info then 
	-- 	return 
	-- end
	self:initUI()
	self:regFunc()
	self:askData()

end

local widget_name = {
	"btn_close",
	"btn_wake",
	"star_cost_num",
	"seaman_name_1",
	"seaman_name_2",
	"bar_boat",
	"job_icon_1",
	"job_icon_2",
	"captain_head_1",
	"captain_head_2",
	"sailor_level_1",
	"sailor_level_2",
	"star_panel_1",
	"star_panel_2",
	"bar_num",
	"bar",
	"btn_wake_text",
	"star_icon",
	"star_cost_num",
}
local awake_star = {
	"star_1_1",
	"star_2_1",
	"star_3_1",
	"star_4_1",
	"star_5_1",
	"star_6_1",
	"star_7_1",
}

local target_star = {
	"star_2_2",
	"star_3_2",
	"star_4_2",
	"star_5_2",
	"star_6_2",
	"star_7_2",
}
local awake_target_star = {
	"star_1_2",
	"star_2_2",
	"star_3_2",
	"star_4_2",
	"star_5_2",
	"star_6_2",
	"star_7_2",
}
function ClsSailorAwakeView:initUI()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/partner_wake.json")
	self:addWidget(self.panel)
	for i,v in ipairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	local activity_info = getGameData():getActivityData():getSailorAwakeActivityInfo()
	if activity_info then
		self:updateUI()
	end
end

function ClsSailorAwakeView:askData()
	getGameData():getActivityData():askSailorAwakeActivityInfo()
end


function ClsSailorAwakeView:regFunc()
	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:close()
	end, TOUCH_EVENT_ENDED)

	self.btn_wake:setPressedActionEnabled(true)
	self.btn_wake:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		if self:isHasSailor() then
			local Alert = require("ui/tools/alert")
			Alert:warning({msg = ui_word.SAILOR_AWAKEN_HAS_SAILOR_TIPS , size = 26})
			return
		end
		local sailor_data = getGameData():getSailorData()
		sailor_data:askSailorAwaken(self.sailor.id, self.awake_type)

	end, TOUCH_EVENT_ENDED)
end

function ClsSailorAwakeView:updateUI()
	self:updateAwakeSailor()
	self:updataTargetSailor()
	self:updataStauts()
	self:updateConsume()
end

--更新要觉醒的航海士
function ClsSailorAwakeView:updateAwakeSailor()

	self.captain_head_1:changeTexture(self.sailor.res, UI_TEX_TYPE_LOCAL)
	self.captain_head_1:setScale(1)
	local size = self.captain_head_1:getContentSize()
	self.captain_head_1:setScale(100/size.width)
	self.seaman_name_1:setText(self.sailor.name)

	self.sailor_level_1:changeTexture(STAR_SPRITE_RES[self.sailor.star].big, UI_TEX_TYPE_PLIST)
	local is_scale = sailor_info[self.sailor.id].big_or_small
	-- if is_scale == 1 then
	-- 	self.sailor_level_1:setScale(0.45)
	-- end
	self.job_icon_1:changeTexture(JOB_RES[self.sailor.job[1]], UI_TEX_TYPE_PLIST)
	
	if self.sailor.starLevel%2 == 0 then
		self.star_panel_1:setPosition(ccp(-34, -62))
	end
	for i,v in ipairs(awake_star) do
		if i <= self.sailor.starLevel then
			getConvertChildByName(self.panel, v):setVisible(true)
		else
			getConvertChildByName(self.panel, v):setVisible(false)
		end
		
	end
end


--更新觉醒目标航海士
function ClsSailorAwakeView:updataTargetSailor()
	
	local activity_info = getGameData():getActivityData():getSailorAwakeActivityInfo()
	
	local awake_data = awake_huodong_config[activity_info.id]
	local sailor_id = awake_data.sailor

	local sailor_data = sailor_info[sailor_id]

	self.captain_head_2:changeTexture(sailor_data.res, UI_TEX_TYPE_LOCAL)
	self.captain_head_2:setScale(0.35)
	self.seaman_name_2:setText(sailor_data.name)

	self.sailor_level_2:changeTexture(STAR_SPRITE_RES[sailor_data.star].big, UI_TEX_TYPE_PLIST)
	-- local is_scale = sailor_data.big_or_small
	-- if is_scale == 1 then
	-- 	self.sailor_level_2:setScale(0.45)
	-- end
	self.job_icon_2:changeTexture(JOB_RES[sailor_data.job[1]], UI_TEX_TYPE_PLIST)
	
	
	for i,v in ipairs(target_star) do	
		getConvertChildByName(self.panel, v):setVisible(false)		
	end
end

function ClsSailorAwakeView:updataStauts()
	local sailor_data = getGameData():getSailorData()
	local times = sailor_data:getAwakenTimes()
	self.bar_num:setText(times.."/30")
	local percent = times / 0.3
	-- local pos = self.bar_boat:getPosition()
	-- print(pos.x, pos.y)
	local all_length = 180
	local length = all_length * (times / 30)
	self.bar_boat:setPosition(ccp(-90 + length, 64))
	self.bar:setPercent(percent)
	if self:isHasSailor() then
		self.btn_wake_text:setText(ui_word.HAS_IT)
	end
end

function ClsSailorAwakeView:updateConsume()
	local activity_info = getGameData():getActivityData():getSailorAwakeActivityInfo()
	local awake_data = awake_huodong_config[activity_info.id]
	local sailor_id = awake_data.sailor

	local consume_item_id = sailor_op_config[self.sailor.star].awake_consume
	local consume_item_num =  sailor_op_config[self.sailor.star].awake_consume_count

	local prop_data = getGameData():getPropDataHandler()
	local item = prop_data:hasPropItem(consume_item_id)
    local have_num = 0
    if item then
        have_num = item.count
    end

    if have_num >= consume_item_num then --有足够的道具
    	self.star_icon:changeTexture("common_item_medal.png", UI_TEX_TYPE_PLIST)
    	self.awake_type = item_awaken
    	self.star_cost_num:setText(have_num.."/1")
    else
    	self.awake_type = diamoud_awaken
    	self.star_icon:changeTexture("common_icon_diamond.png", UI_TEX_TYPE_PLIST)
    	local awake_consume_gold = sailor_op_config[self.sailor.star].awake_consume_gold
    	local have_gold_num = getGameData():getPlayerData():getGold()
    	setUILabelColor(self.star_cost_num, ccc3(dexToColor3B(COLOR_COFFEE)))
    	if have_gold_num < awake_consume_gold then 
    		setUILabelColor(self.star_cost_num, ccc3(dexToColor3B(COLOR_RED)))
    	end
    	self.star_cost_num:setText(awake_consume_gold)
    end
end

function ClsSailorAwakeView:updateStarNum()
	local propDataHandle = getGameData():getPropDataHandler()
	local item_info = propDataHandle:hasPropItem(self._up_star_item_id)
	local has_item_num = 0
    if item_info then
        has_item_num = item_info.count or 0
    end
	self.star_num:setText(has_item_num)
end


function ClsSailorAwakeView:isHasSailor()
	local sailor_list = getGameData():getSailorData():getOwnSailors()
	local activity_info = getGameData():getActivityData():getSailorAwakeActivityInfo()	
	local awake_data = awake_huodong_config[activity_info.id]
	local sailor_id = awake_data.sailor
	if sailor_list and sailor_list[sailor_id] then
		return true
	else
		return false
	end
end
function ClsSailorAwakeView:onExit()
end

return ClsSailorAwakeView