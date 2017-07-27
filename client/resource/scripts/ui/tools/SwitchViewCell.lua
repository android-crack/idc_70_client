
local SwitchViewCell  = class("SwitchViewCell", function(size)
	local node = display.newNode()
	if size then node:setContentSize(size) end
	--de:registerNodeEvent()
	--require("framework.api.EventProtocol").extend(node)
	return node
end)

function SwitchViewCell:ctor(size,config)
	if not config then return end
	self.config = config
	if config.res then
		self.sprite=display.newSprite(config.res,size.width/2,size.height/2)
		self.sprite:setOpacity(180)
		self:addChild(self.sprite)
	end
end

--自己重写这些函数
function SwitchViewCell:onTap(x,y)  --被点击
end

--自己重写这些函数
function SwitchViewCell:onLongTap(x,y)  --长按
end

function SwitchViewCell:makeSelectEffect()
	local arrayAction=CCArray:create()
	arrayAction:addObject(CCFadeTo:create(0.1,255))
	arrayAction:addObject(CCScaleTo:create(0.2,1.1))
	arrayAction:addObject(CCMoveBy:create(0.2,ccp(0,3)))

	return CCSequence:create(arrayAction)
end

function SwitchViewCell:makeUnSelectEffect()
	local arrayAction=CCArray:create()
	arrayAction:addObject(CCFadeTo:create(0.1,128))
	arrayAction:addObject(CCScaleTo:create(0.2,1))
	arrayAction:addObject(CCMoveBy:create(0.2,ccp(0,-3)))

	return CCSequence:create(arrayAction)
end

function SwitchViewCell:select(index)   --被选中当前的
	EventTrigger(EVENT_SWITCH_SELECT,self.config,index)
	local childs = self:getChildren()
	if tolua.isnull(childs) then return end
	for i = 0, childs:count()-1 do
		local child = childs:objectAtIndex(i)
		if not tolua.isnull(child) then
			local node=tolua.cast(child,"CCNode")
			node:stopAllActions()
			node:runAction(self:makeSelectEffect())
		end
	end
end

function SwitchViewCell:unSelect(index)
	EventTrigger(EVENT_SWITCH_UNSELECT,self.config,index)
	local childs = self:getChildren()
	if tolua.isnull(childs) then return end
	for i = 0, childs:count()-1 do
		local child = childs:objectAtIndex(i)
		if not tolua.isnull(child) then
			local node=tolua.cast(child,"CCNode")
			node:stopAllActions()
			local action=self:makeUnSelectEffect()
			if action then
				node:runAction(action)
			else
				node:setScale(1)
				node:setOpacity(128)
			end
		end
	end
end

return SwitchViewCell
