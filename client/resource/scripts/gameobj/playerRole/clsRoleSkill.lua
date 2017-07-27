-- 主角技能 主界面
local music_info = require("game_config/music_info")
local on_off_info = require("game_config/on_off_info")
local clsDialogQuene = require("gameobj/quene/clsDialogQuene")

local ClsBaseView = require("ui/view/clsBaseView")
local ClsRoleSkill = class("ClsRoleSkill", ClsBaseView)

local FILE_DIR = "gameobj/playerRole/"

local btn_name = {
	{res = "btn_job", lable = "btn_job_text", index = INITIATIVE_SKILL,
		on_off_key = on_off_info.SKILL_PAGE.value, task_keys = {on_off_info.SKILL_PAGE.value},
		file_name = "clsRoleSkillView",
	},
	{res = "btn_talent", lable = "btn_talent_text", index = ATTRIBUTE_SKILL, 
		file_name = "clsRoleAttrSkillView", on_off = on_off_info.BASIC_SKILL.value,
	},
}

function ClsRoleSkill:getViewConfig()
	return {
		name = "clsRoleSkill",
		effect = UI_EFFECT.DOWN, 
		is_back_bg = true, 
	}
end


function ClsRoleSkill:onCreateFinish(  )
    self.is_finish_effect = true
end

function ClsRoleSkill:getDownEffectStatus(  )
	return self.is_finish_effect
end

function ClsRoleSkill:onEnter(tab)
	tab = tab or INITIATIVE_SKILL
	self.is_finish_effect = false
	self.m_zhandouli  = getGameData():getPlayerData():getBattlePower()

	self.plist = {
		["ui/partner.plist"] = 1,
		["ui/skill_icon.plist"] = 1,
	}
	LoadPlist(self.plist)

	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/skill_bg.json")
	self:addWidget(self.panel)

	local task_data = getGameData():getTaskData()
	for k, v in pairs(btn_name) do
		self[v.res] = getConvertChildByName(self.panel, v.res)
		self[v.res]["index"] = v.index
		self[v.res]["file_name"] = v.file_name
		if v.task_keys and v.on_off_key then
			task_data:regTask(self[v.res], v.task_keys, KIND_CIRCLE, v.on_off_key, 42, 14, true)
		end

		if v.on_off and not getGameData():getOnOffData():isOpen(v.on_off) then
			self[v.res]:setVisible(false)
		end

		self[v.lable] = getConvertChildByName(self.panel, v.lable)
		
		self:regEvent(self[v.res], self[v.lable], self[v.res]["index"])
	end

	self.btn_close = getConvertChildByName(self.panel, "btn_close")
	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		for k, v in pairs(btn_name) do
			local file_name = self[v.res]["file_name"]
			if file_name and file_name ~= "" then 
				local ui = getUIManager():get(file_name)
				if not tolua.isnull(ui) then
					ui:close()
				end
			end
		end

		self:close()
	end, TOUCH_EVENT_ENDED)

	local voice_info = getLangVoiceInfo()
	audioExt.playEffect(voice_info.VOICE_SWITCH_1002.res)

	-- clsDialogQuene:pauseQuene("ClsRoleSkill")

	local partner_data = getGameData():getPartnerData()
	local data = partner_data:getRoleInfo()
	--partner_data:askRoleInfo()

	--getGameData():getBaseSkillData():askBaseInfo()

	self.last_tab = tab
	self:changePanel(self.last_tab)
end

function ClsRoleSkill:regEvent(obj, obj_label, index)
	obj:addEventListener(function()
		setUILabelColor(obj_label, ccc3(dexToColor3B(COLOR_TAB_SELECTED)))
	end, TOUCH_EVENT_BEGAN)

	obj:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:changePanel(index)
	end, TOUCH_EVENT_ENDED)

	obj:addEventListener(function()
		setUILabelColor(obj_label, ccc3(dexToColor3B(COLOR_TAB_UNSELECTED)))
	end, TOUCH_EVENT_CANCELED)
end

function ClsRoleSkill:changePanel(index)
	if self.last_tab then
		index = self.last_tab
		self.last_tab = nil
	end

	index = index or INITIATIVE_SKILL

	for k, v in pairs(btn_name) do
		if self[v.res]:isVisible() then
			local btn_bool = self[v.res]["index"] == index

			self[v.res]:setFocused(btn_bool)
			self[v.res]:setTouchEnabled(not btn_bool)
			if btn_bool then
				setUILabelColor(self[v.lable], ccc3(dexToColor3B(COLOR_TAB_SELECTED)))
			else
				setUILabelColor(self[v.lable], ccc3(dexToColor3B(COLOR_TAB_UNSELECTED)))
			end

			local file_name = self[v.res]["file_name"]
			if file_name and file_name ~= "" then 
				local ui = getUIManager():get(file_name)
				if not tolua.isnull(ui) then
					ui:close()
				end
				if btn_bool then
					getUIManager():create(FILE_DIR .. file_name)
				end
			end
		end
	end
end

function ClsRoleSkill:onFinish()
	-- clsDialogQuene:resumeQuene("ClsRoleSkill")
	local curZhandouli  = getGameData():getPlayerData():getBattlePower()
	if curZhandouli > self.m_zhandouli then
		local clsBattlePower = require("gameobj/quene/clsBattlePower")
		clsDialogQuene:insertTaskToQuene(clsBattlePower.new({newPower = curZhandouli,oldPower = self.m_zhandouli}))
	end

	UnLoadPlist(self.plist)
end


return ClsRoleSkill