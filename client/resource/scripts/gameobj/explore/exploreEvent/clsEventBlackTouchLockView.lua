--2016/12/06
--create by wmh0497
--挡住视线的触摸层

local clsEventBlackTouchLockView = class("ClsEventBlackTouchLockView", require("ui/view/clsBaseView"))

--页面参数配置方法，注意，是静态方法
function clsEventBlackTouchLockView:getViewConfig(name_str)
	return {
		name = name_str,
		type = UI_TYPE.TIP,
		is_swallow = true,
	}
end

--页面创建时调用
function clsEventBlackTouchLockView:onEnter(name_str)
	self.m_black_layer = CCLayerColor:create(ccc4(0, 0, 0, 255))
	self:addChild(self.m_black_layer)
end

function clsEventBlackTouchLockView:getBlackLayer()
	return self.m_black_layer
end

return clsEventBlackTouchLockView
