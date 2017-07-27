local ui_word = require("game_config/ui_word")
local music_info = require("game_config/music_info")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsSelectTeamType = class("ClsSelectTeamType", ClsBaseView)

local btn_name = {
	"btn_free",
	"btn_team"
}

function ClsSelectTeamType:getViewConfig()
    return {
        is_swallow = false,
    }
end

function ClsSelectTeamType:onEnter(pos)
	self:setIsWidgetTouchFirst(true)
	self:initView(pos)

	self:regTouchEvent(self, function(event_type, x, y)
	    local pos_x, pos_y = self:getPosition()
		local size = self.panel:getContentSize()
		local touch_rect = CCRect(pos_x, pos_y, size.width, size.height)
        if event_type == "began" then
        	if not touch_rect:containsPoint(ccp(x, y)) then
        		self:close()
        		return false
        	end
        	return true
        end
    end)
end

function ClsSelectTeamType:initView(pos)
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/team_invite_btn.json")
	self.panel:setPosition(ccp(pos.x, pos.y))
	self:addWidget(self.panel)
	for i,v in ipairs(btn_name) do
		self[v] = getConvertChildByName(self.panel, v)
		self[v]:setPressedActionEnabled(true)
		self[v]:addEventListener(function ()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self:btnCall(i)
		end, TOUCH_EVENT_ENDED)
	end
end

function ClsSelectTeamType:btnCall(index)
	local team_data = getGameData():getTeamData()
	team_data:changeInviteType(tonumber(index))
	self:close()
end

return ClsSelectTeamType