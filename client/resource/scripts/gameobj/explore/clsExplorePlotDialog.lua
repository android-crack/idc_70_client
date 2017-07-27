--
-- Author: lzg0496
-- Date: 2017-02-17 15:14:08
-- Function: 事件弹提示

local clsBaseView = require("ui/view/clsBaseView")
local sailor_info = require("game_config/sailor/sailor_info")
local ui_word = require("game_config/ui_word")

local clsExplorePlotDialog = class("clsExplorePlotDialog", clsBaseView)

function clsExplorePlotDialog:getViewConfig()
    return {
        is_swallow = false,
    }
end

function clsExplorePlotDialog:onEnter(cfg)
    self.cfg = cfg
    if cfg.beganCallBack then
        cfg.beganCallBack()
    end

    local name = nil
    local seaman = nil
    local nameLabel = nil
    local desLabel = nil
    local plot_bg = getChangeFormatSprite("ui/bg/bg_plot.png")
    --
    local seaman_res = "ui/seaman/seaman_101.png"
    local scale = false
    if cfg.is_player or not sailor_info[cfg.seaman_id] then
        local sceneDataHandle = getGameData():getSceneDataHandler()
        local icon = sceneDataHandle:getMyIcon()
        seaman_res = string.format("ui/seaman/seaman_%s.png", icon)

        local role_name = sceneDataHandle:getMyName()
        name = string.format("%s%s", role_name, ui_word.SIGN_COLON)
        scale = false
    else
        seaman_res = sailor_info[cfg.seaman_id].res
        name = sailor_info[cfg.seaman_id].name .. ui_word.SIGN_COLON
        if sailor_info[cfg.seaman_id].star >= 6 then
            scale = true
        end
    end
    
    seaman = display.newSprite(seaman_res, 120, 0)
    seaman:setAnchorPoint(ccp(0,0))
    --
    if scale then
        local seaman_width = seaman:getContentSize().width
        seaman:setScale(130 / seaman_width)
    end

    plot_bg:addChild(seaman)
    nameLabel = createBMFont({text = name, fontFile = FONT_MICROHEI_BOLD, size = 20, 
                color = ccc3(dexToColor3B(COLOR_CREAM_STROKE)), x = 0, y = 0 })
    nameLabel:setAnchorPoint(ccp(0, 1))
    plot_bg:addChild(nameLabel)
    local lx, ly = 290, 120
    nameLabel:setPosition(lx, ly)
    --
    local msg_str = cfg.txt
    desLabel = createBMFont({text = msg_str, fontFile = FONT_COMMON, size = 18, width = 570,
                color = ccc3(dexToColor3B(COLOR_WHITE_STROKE)), x = 0, y = 0 })
    desLabel:setAnchorPoint(ccp(0, 1.0))
    local lx, ly = 290, Math.floor(plot_bg:getContentSize().height * 0.65) + 10
    desLabel:setPosition(lx, ly)    
    plot_bg:addChild(desLabel)  
    
    local ac_time = 0.2 
    plot_bg:setAnchorPoint(ccp(0, 0))
    plot_bg:setOpacity(0)
    plot_bg:setPosition(ccp(0, 0))  
    plot_bg:runAction(CCSequence:createWithTwoActions(CCFadeIn:create(ac_time), CCCallFunc:create(function()  end)))
    
    self:addChild(plot_bg)
    
    seaman:runAction(CCFadeIn:create(0.2))
    nameLabel:runAction(CCFadeIn:create(1))
    desLabel:runAction(CCFadeIn:create(1))

    local is_close = false
    local function layerEndCall()
        if is_close then
            return 
        end
        is_close = true
        local dt = 0.5
        local ac1 = CCFadeOut:create(dt)
        local ac2 = CCCallFunc:create(function() 
            self:close()
        end)
        local seq = CCSequence:createWithTwoActions(ac1, ac2)
        self:runAction(seq)
    end
    
    local is_lock_touch = cfg.is_lock_touch
    local touch_priority = cfg.touch_priority or TOUCH_PRIORITY_CRAZY
    self:regTouchEvent(self, function(eventType, x, y) 
		if eventType =="began" then
			if true == is_lock_touch then
				return true
			end
			
			layerEndCall()
			-- 0-150像素内 触摸屏蔽
			if y > 150 then 
				return false 
			end
			return true 
		end
    end)

    if true ~= is_lock_touch then
        local delay = cfg.delay_time or 5.0
        local delayAction = CCDelayTime:create(delay)
        local funcAction = CCCallFunc:create(function() 
            layerEndCall()
        end)
        local seq = CCSequence:createWithTwoActions(delayAction, funcAction)
        self:runAction(seq)
    end
end

function clsExplorePlotDialog:onExit()
    local back = self.cfg.call_back
    if type(back) == "function"  then
        back()
    end
end

return clsExplorePlotDialog