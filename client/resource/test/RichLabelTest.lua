local ClsRichLabel = require("ui/tools/richlabel/richlabel")
local str = "$(img:#common_btn_blue1.png,文本,0xFF0000)红字红字红字红字红字红字红字红字红字红字红字红字红字$(c:0x%x)ab中文$(url:全世界xxxxxxxxxxxxxxx,http://www.baidu.com)世界大团大字xxxdd额的顶顶顶顶顶顶顶顶顶顶$()结万岁$(c:0x00FF00)zhong$(c:end)wen2$(imt:"

function asciiSizeGenerator(font_size)
	local t = {}
	for i = 1, 128 do
	   local l = ui.newTTFLabel({text = string.char(i), size = font_size})
	   local size = l:getContentSize()
	   t[i] = {width = size.width, height = size.height}
	end
	table.save(t, string.format("scripts/ui/tools/richlabel/sizecfg/asciisize_%d.lua", font_size))
end
function chineseSizeGenerator(font_size)
	local a = "你"
	local l = ui.newTTFLabel({text = a, size = font_size})
	local size = l:getContentSize()
	local t = {width = size.width, height = size.height}
	table.save(t, string.format("scripts/ui/tools/richlabel/sizecfg/chinesesize_%d.lua", font_size))
end

for i = 12, 26 do
	asciiSizeGenerator(i)
	chineseSizeGenerator(i)
end
local scene = display.getRunningScene() 
local richlabel = createRichLabel(str, display.cx/2, display.cy,14)

richlabel:setVerticalSpace(10)
richlabel:setPosition(110,110)

scene:removeChildByTag(1)
-- richlabel:setIgnoreSize(false)
richlabel:setTag(1)
richlabel:update()
local size = richlabel:getSize()
-- print(size.width, size.height)

scene:addChild(richlabel)



-- local t = oversizeHandleText("x你hao好好哈想你阿豪拉丝x但是x的的啊xlll大杀杀杀laaa", 40)
-- for i, v in ipairs(t) do
	-- local label = ui.newTTFLabel({text = v, x = 200, y = i*30})
	-- label:setAnchorPoint(ccp(0, 0.5))
	-- scene:addChild(label)
-- end
--local t = {}
--local fontSize = 16
--for i = 1, 128 do
--    local l = ui.newTTFLabel({text = string.char(i), size = fontSize})
--    local size = l:getContentSize()
--    t[i] = {width = size.width, height = size.height}
--end
--table.save(t, string.format("ascii_size_%d.lua", fontSize))
