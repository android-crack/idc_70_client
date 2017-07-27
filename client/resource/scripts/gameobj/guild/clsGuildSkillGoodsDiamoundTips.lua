
local music_info = require("game_config/music_info")
local ClsBaseView = require("ui/view/clsBaseView")
local ui_word = require("game_config/ui_word") 
--clsGuildSkillDiamoundTips
local ClsGuildSkillGoodsDiamoundTips= class("ClsGuildSkillGoodsDiamoundTips", ClsBaseView)

local CLOSE_TIPS = true
function ClsGuildSkillGoodsDiamoundTips:getViewConfig()
    return {
        effect = UI_EFFECT.SCALE,    --(选填) ui出现时的播放特效
		is_back_bg = true, 
    }
end

function ClsGuildSkillGoodsDiamoundTips:onEnter(call_back,diamound_num)
	self.call_back = call_back
	self.diamound_num = diamound_num
   	local btn_panel = GUIReader:shareReader():widgetFromJsonFile("json/tips_institute.json")
	self:addWidget(btn_panel)
	self.panel = btn_panel

	local background = getConvertChildByName(self.panel, "panel")
	self.size = background:getContentSize()
	self:setPosition(ccp(display.cx - self.size.width/2,display.cy - self.size.height/2))

	self:regTouchEvent(self, function(event, x, y)
		return self:onTouch(event, x, y) end)
	---self:runAction(CCFadeTo:create(0.24 , 0.5 * 255))

    self:initBaseUI()
    self:initEvent()
end

function ClsGuildSkillGoodsDiamoundTips:initBaseUI()
	--技能图标
	local widget_name = {
		"btn_check",
		"btn_sure",
		"btn_close",
		"text_2",
	}

	for k,v in pairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end

	self.text_2:setText(string.format(ui_word.GUILD_RESEARCH_TIPS_LAB, self.diamound_num))
end

function ClsGuildSkillGoodsDiamoundTips:initEvent(  )
	self.btn_check:addEventListener(function (  )
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		getGameData():getGuildResearchData():setResearchTipsStatus(CLOSE_TIPS)
	end,CHECKBOX_STATE_EVENT_SELECTED)

	self.btn_check:addEventListener(function (  )
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		getGameData():getGuildResearchData():setResearchTipsStatus(not CLOSE_TIPS)
	end,CHECKBOX_STATE_EVENT_UNSELECTED)

	self.btn_sure:setPressedActionEnabled(true)
	self.btn_sure:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self.call_back()
		self:close()

	end, TOUCH_EVENT_ENDED)

	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:close()
	end, TOUCH_EVENT_ENDED)
end


function ClsGuildSkillGoodsDiamoundTips:onTouch(event, x, y)
	if event == "began" then
		self:onTouchBegan(x, y)
	end
end

function ClsGuildSkillGoodsDiamoundTips:onTouchBegan(x , y)
	if x > display.cx - self.size.width/2 and x < display.cx  + self.size.width/2 and y > display.cy- self.size.height/2  and y < display.cy + self.size.height/2 then	
		return true
	else
		self:close()
		return false
	end
end

function ClsGuildSkillGoodsDiamoundTips:onExit()

end

return ClsGuildSkillGoodsDiamoundTips