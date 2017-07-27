-- 航海士觉醒
-- Author: Ltian
-- Date: 2017-02-02 15:00:34
--
local sailor_info = require("game_config/sailor/sailor_info")
local CompositeEffect = require("gameobj/composite_effect")
local on_off_info = require("game_config/on_off_info")
local music_info = require("scripts/game_config/music_info")
local ui_word = require("game_config/ui_word")
local alert = require("ui/tools/alert")
local awake_huodong_config = require("game_config/activity/awake_huodong_config")
local ClsDataTools = require("module/dataHandle/dataTools")
local skill_info = require("game_config/skill/skill_info")

local ClsSailorAwake = class("ClsSailorAwake", function() return UIWidget:create() end)

function ClsSailorAwake:ctor()
	self:mkUI()
	self:regFunc()
	getUIManager():get("ClsActivityMain"):regChild("ClsSailorAwake",self)
	-- 查看之后移除新一轮传奇航海士页签的红点
	self:removeSailorTabRedPoint()
end

local widget_name = {
	"btn_accpet",
	"type_icon",
	"sailor_name",
	"tips_text",
	"navy_txt",
	"sailor_head",
	"time_remaining_num",
	"btn_skill_1",
	"btn_skill_2",
	"btn_skill_select_1",
	"btn_skill_select_2",
	"btn_skill_icon_1",
	"btn_skill_icon_2",
	"skill_name_info",
	"skill_level_info",
	"skill_introduce_info",

}

function ClsSailorAwake:askData()
	getGameData():getActivityData():askSailorAwakeActivityInfo()
end


function ClsSailorAwake:mkUI()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/activity_sailor.json")
	convertUIType(self.panel)
	self:addChild(self.panel)
	for i,v in ipairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	self:updateView()
end

function ClsSailorAwake:regFunc()
	self.btn_accpet:setPressedActionEnabled(true)
	self.btn_accpet:addEventListener(function  ()
		local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
		local layer = missionSkipLayer:skipLayerByName("sailor_awake")
	end, TOUCH_EVENT_ENDED)
end

function ClsSailorAwake:updateView()
	local activity_info = getGameData():getActivityData():getSailorAwakeActivityInfo()
	if not activity_info then 
		self:setVisible(false)
		return 
	end
	self:setVisible(true)
	
	local awake_data = awake_huodong_config[activity_info.id]
	local sailor_id = awake_data.sailor
	print("·sailor_id··", sailor_id)
	local sailor_data = sailor_info[sailor_id]
	self.sailor_name:setText(sailor_data.name)
	self.tips_text:setText(awake_data.sailor_info)
	self.sailor_head:changeTexture(sailor_data.res)
	self.navy_txt:changeTexture("ui/txt/"..awake_data.sailor_type)
	self.type_icon:changeTexture(JOB_RES[sailor_data.job[1]], UI_TEX_TYPE_PLIST)
	local this_time = os.time()
	print("this_time - activity_info.time", this_time, activity_info.time)
	local r_time = this_time - activity_info.time
	local remain_time = activity_info.remainTime - r_time
	print("remain_time", remain_time)
	if remain_time <= 0 then
		self.time_remaining_num:setText(ui_word.GUILD_FIGHT_END_TIP)
		self:askData()
	else
		local time_str = ClsDataTools:getTimeStr1(remain_time)
		self.time_remaining_num:setText(time_str)
	end
	self:updateSkill(sailor_data)
end

function ClsSailorAwake:updateSkill(sailor_data)
	local skills = sailor_data.skills

	for i=1,2 do
		if skills[i] then
			local skill_data = skill_info[skills[i].id]
			self["btn_skill_icon_"..i]:changeTexture(convertResources(skill_data.res), UI_TEX_TYPE_PLIST)
			self["btn_skill_"..i]:changeTexture(SAILOR_SKILL_BG[skill_data.quality], UI_TEX_TYPE_PLIST)
			--skill_bg:changeTexture(SAILOR_SKILL_BG[skill.quality], UI_TEX_TYPE_PLIST)
			self["btn_skill_icon_"..i]:setTouchEnabled(true)
			self["btn_skill_icon_"..i]:addEventListener(function( )
				self:selectSkill(i, sailor_data)
			end, TOUCH_EVENT_ENDED)
		else
			self["btn_skill_"..i]:setVisible(false)
		end
		
	end
	self:selectSkill(1, sailor_data)
end

function ClsSailorAwake:selectSkill(index, sailor_data)
	for i=1,2 do
		self["btn_skill_select_"..i]:setVisible(false)
	end
	self["btn_skill_select_"..index]:setVisible(true)
	local skills = sailor_data.skills
	local skill_level = 5
	local sailor_data_handle = getGameData():getSailorData()
	local skill_data = skill_info[skills[index].id]
	local skill_des = sailor_data_handle:getColorSkillDescWithLv(skills[index].id, skill_level, sailor_data.id)
	--print(skill_des.base_desc)
	self.skill_name_info:setText(skill_data.name)
	self.skill_level_info:setText("Lv."..skill_level)
	self.skill_introduce_info:setText("")
	if self.rich_label then
		self.rich_label:removeFromParentAndCleanup(true)
		self.rich_label= nil  
	end
	self.rich_label = createRichLabel(skill_des.base_desc, 180, 100, 14)
	self.rich_label:setAnchorPoint(ccp(0,1))
	self.rich_label:setPosition(ccp(0,0))
	self.skill_introduce_info:addCCNode(self.rich_label)
   


end

function ClsSailorAwake:removeSailorTabRedPoint()
	local taskData = getGameData():getTaskData()
	local taskKeys = {
		on_off_info.LEGEND_SAILOR_ACTIVITY.value,
	}
	if taskData:getTaskState(on_off_info.LEGEND_SAILOR_ACTIVITY.value) then -- 如果红点有值
		for i,v in ipairs(taskKeys) do
			taskData:setTask(v, false)
		end
		getGameData():getActivityData():askSailorAwakeActivityInfo()
	end
end

function ClsSailorAwake:onExit()
	getUIManager():get("ClsActivityMain"):unRegChild("ClsSailorAwake",self)
end
function ClsSailorAwake:preClose()

end


return ClsSailorAwake
