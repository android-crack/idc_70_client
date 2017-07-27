---主角skill
---fmy
local music_info = require("game_config/music_info")
local alert = require("ui/tools/alert")
local ui_word = require("scripts/game_config/ui_word")
local role_info = require("game_config/role/role_info")
local skill_info = require("game_config/skill/skill_info")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local CompositeEffect = require("gameobj/composite_effect")

local ClsBaseView = require("ui/view/clsBaseView")
local ClsRoleSkillView = class("ClsRoleSkillView", ClsBaseView)

local PLATER_LEVEL = 30

local RESUME_DIAMOUND_NUM = 100

local SKILL_FULL_LEVEL = 10 

local ROLE_SKILL_NUM = 12
local SKILL_ARROWS_TAG = 5

local DEFULT_POINT_1 = 1
local DEFULT_POINT_2 = 2
local DEFULT_POINT_3 = 3
local DEFULT_POINT_4 = 4

local widget_name ={
	--"btn_close",
	"surplus_num",
	"btn_refresh",
	"sailor_type_icon",
	"captain_head",
	"sailor_type",
	"skill_bg_13",
}

function ClsRoleSkillView:getViewConfig()

	local effect_type = UI_EFFECT.DOWN
	local clsRoleSkill = getUIManager():get("clsRoleSkill")

	if not tolua.isnull(clsRoleSkill) then
		local effect_status = clsRoleSkill:getDownEffectStatus()
		if effect_status then
			effect_type = 0
		end
	end

	return {
		name = "clsRoleSkillView",
		effect = effect_type, 
		is_swallow = false,
	}
end

function ClsRoleSkillView:onEnter(tab)
	self.tab = tab or 1

	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/skill_job.json")
	self.panel:setPosition(ccp(95, 40))
	self.panel:setVisible(false)
	self:addWidget(self.panel)


	for k,v in pairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	self.skill_bg_13:setVisible(false)
	self:askData()

	-- local voice_info = getLangVoiceInfo()
 --    audioExt.playEffect(voice_info.VOICE_SWITCH_1002.res)

 	local partner_data = getGameData():getPartnerData()
	local data = partner_data:getRoleInfo()

 	--self:mkUI(data)
end


function ClsRoleSkillView:askData()
	local partner_data = getGameData():getPartnerData()
	partner_data:askRoleInfo()
end

function ClsRoleSkillView:mkUI(data)
 	local partner_data = getGameData():getPartnerData()
	local data = partner_data:getRoleInfo()
	-- print("===========ClsRoleSkillView=====data=============")
	-- table.print(data)

	self.panel:setVisible(true)
	self.role_info = data	
	--self:defultView(self.tab)

	self:btnCallBack()
	self:updataView()
	self:updataSkillView()
	self:clearTips()
end

function ClsRoleSkillView:defultView(defult_view)
	-- for k,v in pairs(btn_name) do
	-- 	self[v.res]:setFocused(defult_view == k)
	-- 	self[v.res]:setTouchEnabled(defult_view ~= k)
	-- 	if defult_view == k then
	-- 		setUILabelColor(self[v.lable], ccc3(dexToColor3B(COLOR_TAB_SELECTED)))
	-- 	else
	-- 		setUILabelColor(self[v.lable], ccc3(dexToColor3B(COLOR_TAB_UNSELECTED)))
	-- 	end
	-- end

end

function ClsRoleSkillView:updataView()

	local res = self.role_info.icon 
	local seaman_res = string.format("ui/seaman/seaman_%s.png", res)
	self.captain_head:changeTexture(seaman_res, UI_TEX_TYPE_LOCAL)

	--职业图标
	local role_job_pic = JOB_RES[self.role_info.profession]
	self.sailor_type_icon:changeTexture(role_job_pic, UI_TEX_TYPE_PLIST)

	local def_skill_point = self:getDefSkillPoint()
	local all_level = self:getAllSkillPoint() + self.role_info.skillPoint
	local all_point = all_level - def_skill_point

	local book_point = all_point - self.role_info.allSkillPoint
	self.surplus_num:setText(string.format("%s/%s(+%s)",self.role_info.skillPoint,all_point,book_point))
	self.sailor_type:setText(ROLE_OCCUP_NAME[self.role_info.profession])
end

function ClsRoleSkillView:getAllSkillPoint(  )
	local skill_list_re = self:getSkillList()
	local all_skill_point = 0
	for i,v in ipairs(skill_list_re) do
		if v.level then
			all_skill_point = all_skill_point + v.level
		end
	end
	return all_skill_point
end

function ClsRoleSkillView:getDefSkillPoint(  )
	local player_level = getGameData():getPlayerData():getLevel()
	if player_level < 2 then
		return DEFULT_POINT_1
	elseif player_level < 10 and player_level >= 2 then
		return DEFULT_POINT_2
	elseif player_level < 20 and player_level >= 10 then
		return DEFULT_POINT_3
	else
		return DEFULT_POINT_4
	end
end

---未开放skill
function ClsRoleSkillView:getNoOpenSkill(skill_id)
	for k,v in pairs(self.role_info.skills) do
		if v.skillId == skill_id then
			return true, v
		end
	end
	return false, skill_id
end

function ClsRoleSkillView:getSkillList(  )
	local skill_list = {}
	local role_skill_list = role_info[self.role_info.roleId]["Skills"]
	for k,v in pairs(role_skill_list) do
		local is_open ,skill_data = self:getNoOpenSkill(v)
		if not is_open then
			skill_list[#skill_list + 1] = {["skillId"] = v}
		else
			skill_list[#skill_list + 1] = skill_data
		end
	end

	local skill_list_re = {}
	local skill_light = {}
	for k,v in pairs(skill_list) do
		local skill_is_string = tostring(v.skillId)
		if string.sub(skill_is_string,2) ~= "401" then
			skill_list_re[#skill_list_re + 1] = v
		else
			skill_light[#skill_light + 1] = v
		end
	end

	for k,v in pairs(skill_light) do
		skill_list_re[#skill_list_re + 1] = v
	end	
	return skill_list_re
end

function ClsRoleSkillView:getSkillLevelById(skill_id)

	for k,v in pairs(self.role_info.skills) do
		if v.skillId == skill_id then
			return v.level
		end
	end
end

function ClsRoleSkillView:updataSkillView()

	local skill_list_re = self:getSkillList()
	self.skill_bg_list = {}
	
	for i= SKILL_ARROWS_TAG, ROLE_SKILL_NUM do
		self["line_"..i] = getConvertChildByName(self.panel, "line_"..i)
		self["line_"..i]:setGray(true)
	end

	for i=1,ROLE_SKILL_NUM do
		local data = skill_list_re[i]

		local skill_level = getConvertChildByName(self.panel, "skill_level_"..i)
		local skill_name = getConvertChildByName(self.panel, "skill_name_"..i)
		local skill_icon = getConvertChildByName(self.panel, "skill_icon_"..i)

		local skill_bg = getConvertChildByName(self.panel, "skill_bg_"..i)
		self.skill_bg_list[#self.skill_bg_list + 1] = skill_bg

		local btn_add = getConvertChildByName(self.panel, "btn_add_"..i)
		--local btn_add_panel = getConvertChildByName(self.panel, "btn_panel_"..i)
		local skill_lock_bg = getConvertChildByName(self.panel, "skill_lock_bg_"..i)
		skill_lock_bg:setVisible(false)

		local skill_data = skill_info[data.skillId]
		--btn_add:changeTexture("common_mark_add3.png", "common_mark_add3.png", "common_mark_add3.png", UI_TEX_TYPE_PLIST)
		skill_icon:changeTexture(convertResources(skill_data.res), UI_TEX_TYPE_PLIST)--UI_TEX_TYPE_PLIST
		skill_icon:setTouchEnabled(true)
		skill_icon:addEventListener(function ()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)

			local pos = skill_icon:convertToWorldSpace(ccp(-300, -100))
			local temp = {}
			temp.pos = pos
			temp.skill = data.skillId
			temp.skill_level = data.level or 1

			if not tolua.isnull(self.tips) then
		        self.tips:close()
		        self.tips = nil 
		    end	

			self.tips = getUIManager():create("gameobj/playerRole/clsRoleSkillTips", {}, self, temp)
		end, TOUCH_EVENT_ENDED)

		--技能名称
		skill_name:setText(skill_data.name)

		---加号
		--btn_add_panel:setTouchEnabled(true)
		-- btn_add_panel:addEventListener(function()
		-- 	btn_add:executeEvent(TOUCH_EVENT_ENDED)
		-- end, TOUCH_EVENT_ENDED)

		btn_add:setPressedActionEnabled(true)

		btn_add:addEventListener(function ()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)

			if skill_data.need_unlock ~= 0 and self:getSkillLevelById(skill_data.need_unlock) ~= SKILL_FULL_LEVEL then
				local last_skill_name = skill_info[skill_data.need_unlock].name 
				local text_name = string.format(ui_word.SKILL_NOT_ADD_POINT_LBL,last_skill_name)
				alert:warning({msg = text_name, size = 26}) 
				return 
			end

			local partner_data = getGameData():getPartnerData()
			partner_data:upgradeRoleSkill(data.skillId)

		end, TOUCH_EVENT_ENDED)

		if data.level then  ---已经解锁

			local level = data.level 
			local max_level = skill_data.max_lv	

			local btn_is_visible  = false
			if skill_data.initiative == 0 and skill_data.need_unlock > 0 and self:getSkillLevelById(skill_data.need_unlock) == SKILL_FULL_LEVEL  then 
				if data.level == 0 then
					skill_icon:setGray(true)					
				else
					skill_icon:setGray(false)
				end
				self["line_"..i]:setGray(false)
				btn_is_visible = true
			elseif skill_data.initiative == 0 and skill_data.need_unlock > 0 and self:getSkillLevelById(skill_data.need_unlock) ~= SKILL_FULL_LEVEL then
				self["line_"..i]:setGray(true)
				skill_icon:setGray(true)
				btn_is_visible = false
			else
				skill_icon:setGray(false)
				if level < max_level then
					btn_is_visible = true
				else
					btn_is_visible = false
				end	
			end

			local str = tonumber(level) >= tonumber(max_level) and "Lv.MAX" or string.format("Lv.%s/%s", level, max_level)
			skill_level:setText(str)  
			setUILabelColor(skill_name, ccc3(dexToColor3B(COLOR_YELLOW_STROKE)))

			btn_add:setVisible(btn_is_visible and (level < max_level) )
			btn_add:setTouchEnabled(btn_is_visible and (level < max_level) )			
			--btn_add_panel:setTouchEnabled(btn_is_visible and (level < max_level))
		else

			local open_level = skill_data.open_level
			skill_level:setText(string.format(ui_word.ROLE_SKILL_OPRN_LEVEL, open_level))
			setUILabelColor(skill_name, ccc3(dexToColor3B(COLOR_CAMEL)))
			btn_add:setVisible(false)
			--btn_add_panel:setVisible(false)
			skill_icon:setGray(true)
			if i >= SKILL_ARROWS_TAG and i <= ROLE_SKILL_NUM then
				self["line_"..i]:setGray(true)
			end
		end


		if self.role_info.skillPoint < 1 then
			btn_add:setVisible(false)
			--btn_add_panel:setVisible(false)
		end
		
	end
	ClsGuideMgr:tryGuide("clsRoleSkillView")
end

function ClsRoleSkillView:playSkillUpLevelEffect(skill_id)

	local next_skill_id = skill_info[skill_id].next_skill_id
	local skill_list = self:getSkillList()
	local skill_index = 1
	local skill_is_open = false	
	for k,v in pairs(skill_list) do
		if tonumber(v.skillId) == tonumber(next_skill_id) then
			skill_index =  k
			if v.level then
				skill_is_open = true
			end
			break
		end
	end

	if skill_is_open then
		local effect_tx = "tx_skill_unlock"
		CompositeEffect.new(effect_tx, 0, 10, self.skill_bg_list[skill_index], nil, nil, nil, nil, true)
	end
end

function ClsRoleSkillView:btnCallBack()
	self.btn_refresh:setPressedActionEnabled(true)
    self.btn_refresh:addEventListener(function ()
    	audioExt.playEffect(music_info.COMMON_BUTTON.res)

		local playerLevel = getGameData():getPlayerData():getLevel()
		local str ,str_other = "",""
		local is_other_str = false
		local is_btn_pic = false
		if playerLevel > PLATER_LEVEL then
			str = ui_word.SKILL_IS_RESET_DIAMOUNT
		else
			str = ui_word.SKILL_IS_RESET
			is_other_str = true
			str_other = ui_word.SKILL_RESET_FREE
			is_btn_pic = true
		end

		alert:showBuyAttention(str, RESUME_DIAMOUND_NUM, nil, function ()

			if not is_other_str then
				local gold_num = getGameData():getPlayerData():getGold()
				if gold_num < RESUME_DIAMOUND_NUM then
					alert:showJumpWindow(DIAMOND_NOT_ENOUGH,self)
					return 		
				end
			end
			local partner_data = getGameData():getPartnerData()	
			partner_data:resetSkillPoint()	
		end, nil, str_other, is_btn_pic)

    end, TOUCH_EVENT_ENDED)
end

function ClsRoleSkillView:clearTips()
	if not tolua.isnull(self.tips) then
        self.tips:close()
        self.tips = nil 
    end	
end

function ClsRoleSkillView:close()
	self:clearTips()

	self.super.close(self)
end

return ClsRoleSkillView