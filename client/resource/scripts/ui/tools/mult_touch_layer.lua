---- 多点触摸

local Mult_touch = {}
--{x1, y1, id1, x2, y2, id2, ......}
-- 参数 :layer、 最小缩放、最多缩放、显示宽度、高度
function Mult_touch:initTouchLayer(layer)
	if not tolua.isnull(layer) then
		self.layer = layer
		self.mutilTouchhappened = 0  -- mutilTouchhappened = 2的时候为多点触摸
		
		local function onTouchEvent(event, touches)
			return self:onTouch(event, touches)
		end
		layer:registerScriptTouchHandler(onTouchEvent, true, 0, true)
		layer:setTouchEnabled(true)
	end
end

function Mult_touch:onTouch(event, touches)
	self.mutilTouchhappened = #touches/3
	if event == "began" then
		return self:onTouchBegan(touches)
	elseif event == "moved" then
		self:onTouchMoved(touches)
	elseif event == "ended" then
		self:onTouchEnded(touches)
	end 
end 

function Mult_touch:onTouchBegan(touches)

	self.lastPos = nil
	if type(self.layer.onTouchBegan) == "function" then 
		return self.layer.onTouchBegan(touches[1], touches[2], self.mutilTouchhappened > 1)
	end 
end 


function Mult_touch:onTouchMoved(touches)
	if self.mutilTouchhappened > 1 then  -- 多点
		self:moveLayer(touches)
	elseif type(self.layer.onTouchMoved) == "function" then 
		self.layer.onTouchMoved(touches[1], touches[2], self.mutilTouchhappened > 1)
	end 
end 


function Mult_touch:onTouchEnded(touches)
	
	if type(self.layer.onTouchEnded) == "function" then 
		self.layer.onTouchEnded(touches[1], touches[2], self.mutilTouchhappened > 1)
	end 
	self.lastPos = nil
end 

function Mult_touch:moveLayer(touches)  -- 缩放/移动
	
	if not self.lastPos then 
		self.lastPos = {}
		self.lastPos.x = (touches[1] + touches[4])/2  -- 取中点为滑动点
		self.lastPos.y = (touches[2] + touches[5])/2
		self.lastPos.dis = Math.distance(touches[1], touches[2], touches[4], touches[5]) -- 2点距离
		return false
	else  -- 多点，进行缩放
		
		local x = (touches[1] + touches[4])/2  -- 取中点为滑动点
		local y = (touches[2] + touches[5])/2
		local dis = Math.distance(touches[1], touches[2], touches[4], touches[5])
		local curPos = {x = x, y = y, dis = dis}
		if type(self.layer.onMutilTouchMoved) == "function" then 
			self.layer.onMutilTouchMoved(curPos, self.lastPos)
		end 
		
		self.lastPos = curPos
		return true
	end 

end 

function Mult_touch:clear()
	self.layer = nil
end

return Mult_touch





















