--
-- Author: lzg0496
-- Date: 2017-03-04 14:23:15
-- Function: 副本结束阵营界面

local clsBaseView = require("ui/view/clsBaseView")
local cfg_music_info = require("game_config/music_info")
local composite_effect = require("gameobj/composite_effect")

local clsCopySceneResultUI = class("clsCopySceneResultUI", clsBaseView)

function clsCopySceneResultUI:getViewConfig()
	return {is_back_bg = true}
end

function clsCopySceneResultUI:onEnter(is_win)
	audioExt.pauseMusic()
	self:mkUI()
	self:configEvent()
	self:initUI(is_win)
end

function clsCopySceneResultUI:mkUI()
	self.panel = createPanelByJson("json/portfight_result.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)

	local need_widget_name = {
		btn_exit = "btn_exit",
		btn_rank = "btn_rank",
		pal_effect = "result_panel",
	}

	for k, v in pairs(need_widget_name) do
		self[k] = getConvertChildByName(self.panel, v)
	end

	self.btn_exit:setVisible(false)
	self.btn_rank:setVisible(false)
	self.btn_exit:setTouchEnabled(false)
	self.btn_rank:setTouchEnabled(false)
end

function clsCopySceneResultUI:initUI(is_win)
	local center_x = self.pal_effect:getContentSize().width / 2
	if is_win then
		local pos_1 = ccp(center_x, 230)
		composite_effect.new("tx_0011", pos_1.x, pos_1.y, self.pal_effect, nil, nil, nil, nil, true)

		local pos_2 = ccp(center_x, 225)
		composite_effect.new("tx_0018", pos_2.x, pos_2.y, self.pal_effect, nil, nil, nil, nil, true)
		
		--碎花星
		local pos_5 = ccp(center_x, 270)
		composite_effect.new("tx_0017", pos_5.x, pos_5.y, self.pal_effect, nil, nil, nil, nil, true)

		local funcs = function()
			self.gaf_win_tanqi:removeFromParentAndCleanup(true)
			
			local pos_4 = ccp(center_x, 225)
			composite_effect.new("tx_0020", pos_4.x, pos_4.y, self.pal_effect, nil, nil, nil, nil, true)
			self.btn_exit:setVisible(true)
			self.btn_rank:setVisible(true)
			self.btn_exit:setTouchEnabled(true)
			self.btn_rank:setTouchEnabled(true)
		end

		--Win字样
		local pos_3 = ccp(center_x, 175)
		self.gaf_win_tanqi = composite_effect.new("tx_0021", pos_3.x, pos_3.y, self.pal_effect, nil, funcs, nil, nil, true)
		audioExt.playEffect(cfg_music_info.BATTLE_WIN.res)
		return
	end

	local pos = ccp(center_x, 700)
	composite_effect.new("tx_0008", pos.x, pos.y,  self.pal_effect, nil, nil, nil, nil, true)

	local arr_action = CCArray:create()
	arr_action:addObject(CCDelayTime:create(2))
	arr_action:addObject(CCCallFunc:create(function()
		self.btn_exit:setVisible(true)
		self.btn_rank:setVisible(true)
		self.btn_exit:setTouchEnabled(true)
		self.btn_rank:setTouchEnabled(true)
	end))

	self:runAction(CCSequence:create(arr_action))

	audioExt.playEffect(cfg_music_info.BATTLE_FAIL.res)
end

function clsCopySceneResultUI:configEvent()
	self.btn_exit:setPressedActionEnabled(true)
	self.btn_exit:addEventListener(function()
	   audioExt.playEffect(cfg_music_info.COMMON_BUTTON.res)
	   self:close()
	   local copy_scene_manage = require("gameobj/copyScene/copySceneManage")
	   copy_scene_manage:sendExitSceneMessage()
	end, TOUCH_EVENT_ENDED)

	self.btn_rank:setPressedActionEnabled(true)
	self.btn_rank:addEventListener(function()
	   audioExt.playEffect(cfg_music_info.COMMON_BUTTON.res)
	   self:close()
	   local copy_scene_manage = require("gameobj/copyScene/copySceneManage")
	   copy_scene_manage:doLogic("showMVP")
	end, TOUCH_EVENT_ENDED)
end

function clsCopySceneResultUI:onExit()
	audioExt.resumeMusic()
end


return clsCopySceneResultUI
