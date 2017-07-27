-- 图片按钮，只有1张图

module("ui_ext", package.seeall)

ImageButton = class("ImageButton",function()
    return CCMenu:create()
end)

ImageButton.ctor = function(self,itemParams) -- 

	local px = itemParams.x
	local py = itemParams.y
	self.item = ui.newImageMenuItem(itemParams)
	self.item:setAnchorPoint(ccp(0,1))
	self.item:setPosition(ccp(0,0))
	self:addChild(self.item)
	
	self:setPosition(ccp(px, py))
end

ImageButton.registerCallback = function(self,listener)
	if type(listener) == "function" then
        self.item:registerScriptTapHandler(function(tag)
            listener(tag)
        end)
    end
end