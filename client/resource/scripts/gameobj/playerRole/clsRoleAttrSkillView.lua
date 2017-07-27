-- 主角技能 属性技能界面
local alert = require("ui/tools/alert")
local ui_word = require("game_config/ui_word")
local music_info = require("game_config/music_info")
local on_off_info = require("game_config/on_off_info")
local nobility_data = require("game_config/nobility_data")
local composite_effect = require("gameobj/composite_effect")
local base_skill_gen = require("game_config/role/base_skill_gen")
local base_skill_attr = require("game_config/role/base_skill_attr")

local ClsBaseView = require("ui/view/clsBaseView")
local ClsRoleAttrSkillView = class("ClsRoleAttrSkillView", ClsBaseView)

local CONSUME_EXP_LIMIT = 40

local attr_widget_name = 
{
	"captain_head",
	"job_icon",
	"job_type",
	"title_txt",
	"name_txt",
	"prestige_num",
	"cost_num",
	"btn_upgrade",
	"exp_num",
	"cost_icon",
	"consume_exp_icon",
	"consume_exp_check",

	"skill_circle",
	"property_info",
	"coin_panel",


	-- "crit_tips_bg",
	-- "crit_icon",
	-- "crit_text",
	-- "crit_tips",
}

local skill_name = 
{
	"skill",
	"effect",
	"property_num",
	"property_plus",
	"skill_level",
}

function ClsRoleAttrSkillView:getViewConfig()

	local effect_type = UI_EFFECT.DOWN
	local clsRoleSkill = getUIManager():get("clsRoleSkill")

	if not tolua.isnull(clsRoleSkill) then
		local effect_status = clsRoleSkill:getDownEffectStatus()
		if effect_status then
			effect_type = 0
		end
	end

	return {
		name = "clsRoleAttrSkillView",
		effect = effect_type, 
		is_swallow = false,
	}
end

function ClsRoleAttrSkillView:onEnter()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/skill_upgrade.json")
	self.panel:setPosition(ccp(95, 40))
	self.panel:setVisible(false)
	self:addWidget(self.panel)

	for k, v in ipairs(attr_widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end

	self.skills = {}
	for i = 1, 4 do
		self.skills[i] = {}

		for k, v in pairs(skill_name) do
			local name = v .. "_" .. i
			self.skills[i][v] = getConvertChildByName(self.panel, name)
		end

		--self.skills[i].light = display.newSprite("#partner_skill_light.png")
		--self.skills[i].light:setVisible(false)
		--self.skills[i].skill:addCCNode(self.skills[i].light)

		local pos = self.skill_circle:convertToWorldSpace(self.skills[i].skill:getPosition())

		self.skills[i].skill:addEventListener(function()
			getUIManager():create("gameobj/playerRole/clsRoleAttrSkillTip", nil, i, pos)
		end, TOUCH_EVENT_ENDED)

		local exp_progress = CCProgressTimer:create(display.newSprite("#partner_skill_bar.png"))
	    exp_progress:setType(kCCProgressTimerTypeRadial)
	    exp_progress:setReverseProgress(true)
	    self.skills[i].skill:addRenderer(exp_progress, 1)

	    self.skills[i].exp_progress = exp_progress
	end

	-- self:mkUI()
	-- self:initBtns()

	-- self:hideAddAttr()
	self:askData()
	RegTrigger(CASH_UPDATE_EVENT, function()
		if tolua.isnull(self) then return end
		self:updateCoin()
	end, "clsRoleAttrSkillView")

	-- local data = getGameData():getBaseSkillData():getBaseData()
	-- if not data or #data == 0 then return end

	--self:updateUI()

end

function ClsRoleAttrSkillView:askData(  )
	getGameData():getBaseSkillData():askBaseInfo()
	getGameData():getPartnerData():askRoleInfo()

end

function ClsRoleAttrSkillView:initUI(  )
	--self:mkUI()
	self:initBtns()

	self:hideAddAttr()	
	self:updateUI()
end


function ClsRoleAttrSkillView:mkUI()
	local ClsPlayerInfoItem = require("ui/tools/clsPlayerInfoItem")
    local cash_layer = ClsPlayerInfoItem.new(ITEM_INDEX_CASH)
    self.coin_panel:addCCNode(cash_layer)

	local partner_data = getGameData():getPartnerData()
	local data = partner_data:getRoleInfo()

	local seaman_res = string.format("ui/seaman/seaman_%s.png", data.icon)
	self.captain_head:changeTexture(seaman_res, UI_TEX_TYPE_LOCAL)

	local role_job_pic = JOB_RES[data.profession]
	self.job_icon:changeTexture(role_job_pic, UI_TEX_TYPE_PLIST)
	self.job_type:setText(ROLE_OCCUP_NAME[data.profession])

	local nobilityMsg = nobility_data[data.nobility] or {}
    local file_name = nobilityMsg.peerage_before or "title_name_knight.png"
    self.title_txt:changeTexture(convertResources(file_name), UI_TEX_TYPE_PLIST)

	self.name_txt:setText(data.name)

	-- self.crit_tips_bg:setTouchEnable(true)
	-- self.crit_tips_bg:addEventListener(function (  )
	-- 	getUIManager():create("gameobj/playerRole/clsRoleLockAttrsTips")
	-- end, TOUCH_EVENT_ENDED)
end

function ClsRoleAttrSkillView:updateCoin()
	local player_data = getGameData():getPlayerData()
	local base_skill_data = getGameData():getBaseSkillData()

	local lv = base_skill_data:getAverageLV()
	local exp = base_skill_gen[lv].sin_exp 
	self.exp_num:setText(exp)

	local cost_num = 0
	local is_show_red = true

	if base_skill_data:isConsumeCoin() then
		cost_num = base_skill_gen[lv].coin_consume
		is_show_red = player_data:getCash() < cost_num
	else
		cost_num = base_skill_gen[lv].exp_consume
		is_show_red = player_data:getExp() < cost_num
	end
	self.cost_num:setText(cost_num)

	setUILabelColor(self.cost_num, is_show_red and ccc3(dexToColor3B(COLOR_RED)) or ccc3(dexToColor3B(COLOR_COFFEE)))
end

function ClsRoleAttrSkillView:updateUI()
	self.panel:setVisible(true)

	self:updateCoin()

	local partner_data = getGameData():getPartnerData()
	local data = partner_data:getRoleInfo()
	local power = getGameData():getPlayerData():getBattlePower()

	self.prestige_num:setText(power)

    local base_data = getGameData():getBaseSkillData():getBaseData()

    for i = 1, 4 do
    	self.skills[i].property_num:setText(base_data[i].attr)

    	self.skills[i].skill_level:setText(string.format(ui_word.SHIPYARD_LEVEL_TEXT, base_data[i].level))
    	
    	local base_skill = base_skill_attr[base_data[i].level + 1]
    	if base_skill then
    		local exp = base_skill.exp
	    	self.skills[i].exp_progress:setPercentage(math.floor(base_data[i].exp/exp*100))
	    else
	    	self.skills[i].exp_progress:setPercentage(0)
	    end
    end

    --self:updateSkillAttrs()
end

function ClsRoleAttrSkillView:updateSkillAttrs(  )
	local base_skill_data = getGameData():getBaseSkillData()
    local level_limit = base_skill_data:getBaseSkillLimitLevel()
	local skill_attr_info = base_skill_data:getUnlockSkillAttrInfo(level_limit)

    self.crit_icon:changeTexture(convertResources(skill_attr_info.icon), UI_TEX_TYPE_PLIST)	
    self.crit_text:setText(skill_attr_info.attr)
    self.crit_tips:setText(string.format(ui_word.ROLE_SKILL_ATTRS_LBL,skill_attr_info.level_limit))
end

function ClsRoleAttrSkillView:askUpgrade()
	local player_data = getGameData():getPlayerData()
	local base_skill_data = getGameData():getBaseSkillData()

	local lv = base_skill_data:getAverageLV()
	if base_skill_data:isConsumeCoin() then
		local money = base_skill_gen[lv].coin_consume
		if player_data:getCash() < money then
			alert:showJumpWindow(CASH_NOT_ENOUGH, self, {need_cash = money})
			return
		end
	else
		if player_data:getExp() < base_skill_gen[lv].exp_consume then
			alert:showJumpWindow(EXP_NOT_ENOUGH, self)
			return
		end
	end

	getGameData():getBaseSkillData():askUpgrade()
end

function ClsRoleAttrSkillView:BtnUpgradeLongClick()
	self.btn_upgrade_delay = true

	local action_1 = CCDelayTime:create(0.5)
	local action_2 = CCCallFunc:create(function()
		getGameData():getBaseSkillData():askUpgrade()
	end)

	self.btn_upgrade:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(action_2, action_1)))
end

function ClsRoleAttrSkillView:initBtns()
	self.btn_upgrade:setPressedActionEnabled(true)

	self.btn_upgrade:addEventListener(function()
		local action_1 = CCDelayTime:create(1.5)
		local action_2 = CCCallFunc:create(function()
			self:BtnUpgradeLongClick()
		end)

		self.btn_upgrade:runAction(CCSequence:createWithTwoActions(action_1, action_2))
	end, TOUCH_EVENT_BEGAN)

	self.btn_upgrade:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)

		self.btn_upgrade:stopAllActions()

		if self.btn_upgrade_delay then
			self.btn_upgrade_delay = false
			return
		end

		self:askUpgrade()
	end, TOUCH_EVENT_ENDED)

	self.btn_upgrade:addEventListener(function()
		self.btn_upgrade_delay = false
		self.btn_upgrade:stopAllActions()
	end, TOUCH_EVENT_CANCELED)

	local changeConsumeType = function()
		local base_data = getGameData():getBaseSkillData()
		local is_consume_coin = base_data:isConsumeCoin()
		self.cost_icon:setVisible(is_consume_coin)
		self.consume_exp_icon:setVisible(not is_consume_coin)
		self.consume_exp_check:setSelectedState(not is_consume_coin)
		self:updateCoin()
	end

	self.consume_exp_check:setTouchEnabled(true)
	self.consume_exp_check:addEventListener(function()
		local player_data = getGameData():getPlayerData()
		local lv = player_data:getLevel()

		if lv < CONSUME_EXP_LIMIT then
			alert:warning({msg = ui_word.LEVEL_LIMIT_FORTY})
			self.consume_exp_check:setSelectedState(false)
			return
		end

		local base_data = getGameData():getBaseSkillData()
		base_data:setConsumeCoin(false)

		changeConsumeType()
	end, CHECKBOX_STATE_EVENT_SELECTED)

	self.consume_exp_check:addEventListener(function()
		local base_data = getGameData():getBaseSkillData()
		base_data:setConsumeCoin(true)

		changeConsumeType()
	end, CHECKBOX_STATE_EVENT_UNSELECTED)

	changeConsumeType()
end

function ClsRoleAttrSkillView:btnUpgrade(value)
	if not value then
		self.btn_upgrade:disable()
	else
		self.btn_upgrade:active()
	end
end

function ClsRoleAttrSkillView:upgradeEffect(modify_index)
	local modify_data = getGameData():getBaseSkillData():getModifyData()

	if not modify_data then return end

	self:stopEffect(modify_index)
end

function ClsRoleAttrSkillView:stopEffect(index)
	local modify_data = getGameData():getBaseSkillData():getModifyData()

	if not modify_data or not modify_data[index] then return end

	audioExt.playEffect(music_info.UI_SKILL_FRAME.res)

	local delay_time = 1.5

	local show_saoguang = false
	for i = 1, 4 do
		--self.skills[i].light:stopAllActions()

		--self.skills[i].light:setVisible(modify_data[i] ~= nil)

		if modify_data[i] then
			local array_effect = CCArray:create()
			array_effect:addObject(CCCallFunc:create(function ()
				self.skills[i].effect:setVisible(true)
				self.skills[i].effect:setText(ui_word.MAIN_EXP .. "+" .. modify_data[i].exp)

				composite_effect.new("tx_skill_upgrade_zhang", 0, 0, self.skills[i].skill,delay_time)
				
				if modify_data[i].attr > 0 then
					show_saoguang = true
					self.skills[i].property_plus:setVisible(true)
					self.skills[i].property_plus:setText("+" .. modify_data[i].attr)

					composite_effect.new("tx_skill_upgrade", 0, 0, self.skills[i].skill)
				end				
			end))
			array_effect:addObject(CCDelayTime:create(delay_time))
			array_effect:addObject(CCCallFunc:create(function ()
				if modify_data[i].baoji then
					composite_effect.new("tx_skill_upgrade_dian", 0, 0, self.skills[i].skill,1.0)
					composite_effect.new("tx_skill_upgrade_zi", -20, 30, self.skills[i].skill,1.0)
				end				
			end))
			self:runAction(CCSequence:create(array_effect))
		end
	end

	self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delay_time), CCCallFunc:create(
		function()
			self:hideAddAttr()
		end
	)))

	if show_saoguang then
		composite_effect.new("tx_skill_upgrade_saoguang", 0, 0, self.property_info)
	end

	self:updateUI()
end

function ClsRoleAttrSkillView:hideAddAttr()
	for i = 1, 4 do
		self.skills[i].property_plus:setVisible(false)
		self.skills[i].effect:setVisible(false)
		--self.skills[i].light:setVisible(false)
	end
end

function ClsRoleAttrSkillView:stopCircleEffect()
	-- for i = 1, 4 do
	-- 	if not tolua.isnull(self.skills[i].light) then
	-- 		self.skills[i].light:stopAllActions()
	-- 		self.skills[i].light:setVisible(false)
	-- 	end
	-- end
end

function ClsRoleAttrSkillView:onFinish()
	UnRegTrigger(CASH_UPDATE_EVENT, "clsRoleAttrSkillView")

	self:stopCircleEffect()
end

return ClsRoleAttrSkillView