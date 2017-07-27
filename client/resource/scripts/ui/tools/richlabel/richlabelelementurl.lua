local ClsRichLabelElementURL = class("ClsRichLabelElementURL", function()
	return display.newSprite()
end)

function ClsRichLabelElementURL:ctor(param)
	self.type = param.type
	self.m_richlabel = param.richlabel
	local text = string.format("%s", param.text)
	local url =  param.url
	local listener = function() 
		print("rich text url listener")
		local module_game_sdk = require("module/sdk/gameSdk")
		module_game_sdk.openURL(param.url)
	end

	local label = createBMFont({text = text, size = param.size, color = ccc3(dexToColor3B(param.color))})
	local label_size = label:getContentSize()
	local item = require("ui/view/clsViewButton").new({labelNode = label, x = label_size.width/2, y = label_size.height/2 + label:getStrokeSize()/2})
	item:setAnchorPoint(ccp(0,0))
	self.m_richlabel:regTouchEvent(item, function(...) return item:onTouch(...) end)
end

function ClsRichLabelElementURL:getType()
	return self.type
end


return ClsRichLabelElementURL