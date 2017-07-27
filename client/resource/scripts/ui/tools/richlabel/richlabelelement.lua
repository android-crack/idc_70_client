require("ui/tools/richlabel/richlabeldef")
local ClsRichLabelElement  = class("ClsRichLabelElement", function()
	return display.newNode()
end)

function ClsRichLabelElement:ctor()
end

function ClsRichLabelElement:getType()
	return ""
end


return ClsRichLabelElement
