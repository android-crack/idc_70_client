-- @author: mid
-- @date: 2016年12月10日17:42:51
-- @desc: 获得新称号tips

local CompositeEffect = require("gameobj/composite_effect")

local clsObtainNewTitleTips = class("clsObtainNewTitleTips", require("ui/view/clsBaseView"))

function clsObtainNewTitleTips:onEnter(data)
	self.callback = data.callback
	self:playObtinNewTitle()
end

function clsObtainNewTitleTips:playObtinNewTitle()
	self.node_inverst_level_up_effect = UIWidget:create()
	self:addWidget(self.node_inverst_level_up_effect)
	self.node_inverst_level_up_effect:removeAllChildren()
	local effect_layer = UIWidget:create()
	effect_layer:setPosition(ccp(display.cx , display.cy+180))
	self:addWidget(effect_layer)

	-- self.m_armature_tab = {"effects/tx_new_title.ExportJson"}
	-- LoadArmature(self.m_armature_tab)
	-- -- local effect =  CCParticleSystemQuad:create("effects/tx_new_title0.plist")
	-- -- self:addChild(effect)
	-- -- effect:setPosition(ccp(display.cx + 170, display.cy))

	local music_info = require("game_config/music_info")
	audioExt.playEffect(music_info.GET_NEW_TITLE.res, false)

	-- local arma = CCArmature:create()
	-- arma:getAnimation():playByIndex(0,-1,-1,0)
	-- effect_layer:addCCNode(arma)

	CompositeEffect.new("tx_new_title", -100, 0, effect_layer, nil, nil, nil, nil, true)

	local function close_callback()
		self.callback()
		self:close()
	end

	-- 自动关闭按钮倒计时
	local close_op_1 = CCDelayTime:create(1.6)
	-- 关闭函数回调
	local close_op_2 = CCCallFunc:create(close_callback)

	local arr = CCArray:create()
	arr:addObject(close_op_1)
	arr:addObject(close_op_2)
	self:stopAllActions()
	self:runAction(CCSequence:create(arr))

end

function clsObtainNewTitleTips:onExit()
	UnLoadArmature(self.m_armature_tab)
	ReleaseTexture(self)
end

return clsObtainNewTitleTips
