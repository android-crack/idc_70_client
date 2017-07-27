local composite_effect = require("gameobj/composite_effect")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsChapterMissionUI = class("ClsChapterMissionUI", ClsBaseView)

local SPECIAL_MISSION = 0
local START_CHAPTER = 1

function ClsChapterMissionUI:getViewConfig()
    return {
        name = "ClsChapterMissionUI",
        type = UI_TYPE.DIALOG,
    }
end

function ClsChapterMissionUI:onEnter(missionInfo, call_back)
	self.m_plist_tab = {
        ["ui/material_icon.plist"] = 1,
    }
    LoadPlist(self.m_plist_tab)
	self.data = missionInfo
	self.call_back = call_back

	if self.data.chapter_type == START_CHAPTER then
		self:showStartView()
	else
		self:showSpecialView()
	end
end

function ClsChapterMissionUI:showEffect(panel, is_hide_title)
	local DELAY_TIME = 0.25
	local desc_lab = getConvertChildByName(panel, "title_start")
	local chapter_lab = getConvertChildByName(panel, "title_num")
	local title_lab = getConvertChildByName(panel, "title")
	local new_chapter = getConvertChildByName(panel, "new_chapter")
	local effect_layer = getConvertChildByName(panel, "effect_panel")
	local effect_pos = chapter_lab:convertToWorldSpace(ccp(-2, -25))
	desc_lab:setText(self.data.content)

	if is_hide_title then
		title_lab:setVisible(false)
		chapter_lab:setVisible(false)
	else
		local chapter_title = self.data.chapter_title
		local space_index = string.find(chapter_title, ' ', 0)
		local chapter_str = string.sub(chapter_title, 1, space_index - 1)
		local title_str = string.sub(chapter_title, space_index + 1)
		local effect_id = "tx_new_chapter_water"
		self.title_effect = composite_effect.new(effect_id, effect_pos.x, effect_pos.y, effect_layer, nil, nil, nil, nil, true)
		chapter_lab:setText(chapter_str)
		title_lab:setText(title_str)
	end

	if not new_chapter.is_playing_act then
		new_chapter.is_playing_act = true
		local array = CCArray:create()
		array:addObject(CCDelayTime:create(0.1))	
		new_chapter:setScaleX(0)
		array:addObject(CCScaleTo:create(DELAY_TIME, 1, 1))
		array:addObject(CCCallFunc:create(function()
			new_chapter:stopAllActions()
			new_chapter.is_playing_act = false
			self:performWithDelay(4, function()
				self:closeView()
			end)
		end))
		new_chapter:runAction(CCSequence:create(array))
	end
end

function ClsChapterMissionUI:showStartView()
	local team_port_ui = getUIManager():get("ClsTeamMissionPortUI")
	if not tolua.isnull(team_port_ui) then
		team_port_ui:cleanTitleEffect()
	end

	local panel = GUIReader:shareReader():widgetFromJsonFile("json/tips_chapter.json")
	convertUIType(panel)
	self:addWidget(panel)

	local music_info = require("game_config/music_info")
    audioExt.playEffect(music_info.NEW_CHAPTER.res, false)
	self:showEffect(panel)

	-- self:regTouchEvent(self, function(eventType, x, y)
	-- 	if eventType =="began" then 
	-- 		self:closeView() 
	-- 		return true 
	-- 	end
	-- end)
end

function ClsChapterMissionUI:showSpecialView()
	local layerColor = CCLayerColor:create(ccc4(0,0,0,255), display.width, display.height)
	self:addChild(layerColor, -1)

	local label = createBMFont({ fontFile = FONT_CFG_1, text = self.data.content, color = ccc3(dexToColor3B(COLOR_LOGIN_GLOW)), size = 24, anchor = ccp(0.5,0.5), x = display.cx, y = display.cy, parent = self})
	local arr = CCArray:create()
	arr:addObject(CCFadeIn:create(0.8))
	arr:addObject(CCCallFunc:create(function()
		self:regTouchEvent(self, function(eventType, x, y)
			if eventType =="began" then 
				self:closeView() 
				return true 
			end
		end)
	end))
	arr:addObject(CCDelayTime:create(1.4))
	arr:addObject(CCFadeOut:create(0.8))
	arr:addObject(CCCallFunc:create(function()
		label:stopAllActions()
		self:closeView()
	end))
	label:runAction(CCSequence:create(arr))
end

function ClsChapterMissionUI:performWithDelay(time, func)
	local array = CCArray:create()
    array:addObject(CCDelayTime:create(time))
    array:addObject(CCCallFunc:create(function()
        if type(func) == "function" then
        	func()
        end
    end))
    local action = CCSequence:create(array)
    self:runAction(action)
end

function ClsChapterMissionUI:onExit()
	UnLoadPlist(self.m_plist_tab)
end

function ClsChapterMissionUI:onFinish()
	local mission_data_handler = getGameData():getMissionData()
	mission_data_handler:setEffectSwitch(false)
end

function ClsChapterMissionUI:closeView()
	if type(self.call_back) == "function" then
		self.call_back()
	end
	if not tolua.isnull(self.title_effect) then
		self.title_effect:removeFromParentAndCleanup(true)
		self.title_effect = nil
	end
	if self.data.chapter_type == START_CHAPTER then
		local team_port_ui = getUIManager():get("ClsTeamMissionPortUI")
		if not tolua.isnull(team_port_ui) then
			team_port_ui:showTitleEffect(self.data.id)
		end
	end
	self:close()
end

return ClsChapterMissionUI