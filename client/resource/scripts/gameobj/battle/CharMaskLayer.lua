local CharMaskLayer = class( "CharMaskLayer", function() return CCLayerColor:create(ccc4(0,0,0,255*0.5)) end )



function CharMaskLayer:ctor()
	local touch_priority = -127
	self:registerScriptTouchHandler(function(event)
        if event == "began" then
        	if self.is_skip then
        		self.finish_func()
        	end
        end
    end, false, touch_priority, true)

    self:setTouchEnabled(true)

    self.label_text = createBMFont({ fontFile = FONT_CFG_1, text = "", color = ccc3(dexToColor3B(COLOR_WHITE_STROKE)), size = 20, anchor = ccp(0.5,0.5), x = display.cx, y = display.cy, parent = self })


end

function CharMaskLayer:set_text_list( text_list, text_delay, finish_func, is_skip, pos)
	self.finish_func = finish_func
	self.is_skip = is_skip
	if pos then
		self.label_text:setPosition(pos)
	end
	local array = CCArray:create()
	for _, text in ipairs( text_list ) do
		array:addObject(CCCallFunc:create( function() 
			self.label_text:setOpacity(255*0.5)
			self.label_text:setString(text)
		end ))
		array:addObject(CCFadeIn:create(1))
		array:addObject(CCDelayTime:create(text_delay))
		array:addObject(CCFadeOut:create(1))
	end

	array:addObject(CCCallFunc:create( self.finish_func ))
	self.label_text:runAction(CCSequence:create(array))


end


return CharMaskLayer