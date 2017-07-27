--
-- Author: lzg0946
-- Date: 2016-09-05 16:19:39
-- Function: 三个心

local ui_word = require("scripts/game_config/ui_word")
local ClsComponentBase = require("ui/view/clsComponentBase")

local ClsHeartUiComponent = class("ClsHeartUiComponent", ClsComponentBase)

local MAX_HEART = 5

function ClsHeartUiComponent:onStart()
    self.m_my_uid = getGameData():getSceneDataHandler():getMyUid()
    self.m_my_name = getGameData():getSceneDataHandler():getMyName()
    self.m_explore_sea_ui = self.m_parent:getJsonUi()
    self:initUI()
end

function ClsHeartUiComponent:initUI()
	local melee_panel = getConvertChildByName(self.m_explore_sea_ui, "copy_melee")
	melee_panel:setVisible(true)
	self.attr_panel = getConvertChildByName(self.m_explore_sea_ui, "attr_bg")
	self.heart_panel = getConvertChildByName(self.m_explore_sea_ui, "heart_panel")
	self.attr_panel:setVisible(false)
	self.heart_panel:setVisible(true)
	for i = 1, MAX_HEART do
		local str_child_name = string.format("spr_heart_icon_%d", i)
		local str_child_name_1 = string.format("heart_icon_%d", i)
		self[str_child_name] = getConvertChildByName(self.heart_panel, str_child_name_1)
		self[str_child_name]:setVisible(true)
	end

	self.up_attr_lab = getConvertChildByName(self.attr_panel, "attr_text")
	self.up_attr_lab.tips_str = self.up_attr_lab:getStringValue()
	self.up_attr_lab:setText("")
end

function ClsHeartUiComponent:updateHeart(amount)
	for i = 1, MAX_HEART do
		local str_child_name = string.format("spr_heart_icon_%d", i)
		self[str_child_name]:setVisible(not (i > amount))
	end

	--[[if 1 <= amount and amount <= MAX_HEART - 1 then
		self.attr_panel:setVisible(true)
		local num_n = (MAX_HEART - amount)*20
		local str = self.up_attr_lab.tips_str .. num_n .. "%"
		self.up_attr_lab:setText(str)
	else
		self.attr_panel:setVisible(false)
		self.up_attr_lab:setText("")
	end]]
end

function ClsHeartUiComponent:updateAttrText(val)
	if val then
		self.attr_panel:setVisible(true)
		local str = self.up_attr_lab.tips_str..val.."%"
		self.up_attr_lab:setText(str)
	end
end

return ClsHeartUiComponent
