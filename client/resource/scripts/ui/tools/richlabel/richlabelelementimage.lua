local ClsRichLabelElementImage = class("ClsRichLabelElementImage", function(param)
	local size = param.img:getContentSize()
	if param.text then 
	    local color = ccc3(dexToColor3B(param.color))
    	local label = createBMFont({text = param.text, fontFile = FONT_COMMON,  color = color, size = param.text_size, x = size.width/2, y = size.height/2 })
        param.img:addChild(label)
	end
	return param.img
end)

function ClsRichLabelElementImage:ctor(param)
	self.type = param.type
	self.scale = param.scale or 1
    self:init()
end

function ClsRichLabelElementImage:init()
    self:setScale(self.scale)
end

function ClsRichLabelElementImage:getType()
	return self.type
end


return ClsRichLabelElementImage