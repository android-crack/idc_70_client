
local LoopCell  = class("LoopCell", function(params)--size 大小 pos位置(1开始) 

	local node = display.newNode()
	params.size=params.size or CCSize(0,0)
	node:setContentSize(params.size)
	return node
end)

function LoopCell:ctor(params)
	--LoopCell.super.ctor()
	assert(type(params.pos) == "number",
           "LoopCell:ctor() - invalid pos")
end

--自己重写这些函数

function LoopCell:onTap(x,y)  --被点击
	
end

return LoopCell
