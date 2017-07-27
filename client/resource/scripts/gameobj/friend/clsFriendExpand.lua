local Alert = require("ui/tools/alert")
local news = require("game_config/news")
local music_info = require("game_config/music_info")
local ui_word = require("game_config/ui_word")

local ClsBaseView = require("ui/view/clsBaseView")
local ClsFriendExpand = class("ClsFriendExpand", ClsBaseView)

function ClsFriendExpand:setBindCell(cell, no_effect) --绑定
	self.data = cell.m_cell_date
	self:checkTouchEnable()
	local world_pos = cell:getWorldPosition()
	local cell_height = cell:getHeight()
	local self_size = self.panel:getSize()

	local pos_x = world_pos.x + 560
	local pos_y = world_pos.y - (self_size.height - cell_height) / 2

	self:setPosition(ccp(pos_x, pos_y))

	if not no_effect then
		local Tips = require("ui/tools/Tips")
	    Tips:runAction(self.panel, true)
	end
end

function ClsFriendExpand:isOnePerson(uid)
	if self.data.uid == uid then
		return true
	else
		return false
	end
end

function ClsFriendExpand:pkFriend()
	local friend_data_handler = getGameData():getFriendDataHandler()
	local is_at_line = friend_data_handler:isAtLine(self.data.uid)
	if not is_at_line then
		Alert:warning({msg = ui_word.FRIEND_PK_NOT_AT_LINE_TIP})
		return
	end
	
    friend_data_handler:askFriendPk(self.data.uid)
end

function ClsFriendExpand:checkRoleInfo()	
	local playerData = getGameData():getPlayerData()
	if self.data.uid == playerData:getUid() then
		getUIManager():create("gameobj/playerRole/clsRoleInfoView")
	else
		getUIManager():create("gameobj/captionInfo/clsCaptainInfoMain", nil, self.data.uid)
	end
end

function ClsFriendExpand:sendMsg()
	getUIManager():close("ClsFriendExpand")
	getUIManager():close("ClsFriendMainUI")

	local component_ui = getUIManager():get("ClsChatComponent")
	local panel_ui = component_ui:getPanelByName("ClsChatSystemPanel")
	local main_ui = component_ui:getPanelByName("ClsChatSystemMainUI")
	main_ui:setPlayerBtnInfo(PLAYER_STATUS_PRIVATE, {uid = self.data.uid, name = self.data.name})
	panel_ui:toMainUI({["kind"] = INDEX_PLAYER})
end


function ClsFriendExpand:deleteObj()
	getUIManager():close("ClsFriendExpand")
	getUIManager():create("gameobj/friend/clsFriendTipUI", nil, {kind = DELETE_FRIEND_TIP, uid = self.data.uid})
end

function ClsFriendExpand:addFriend()
	local friend_data_handler = getGameData():getFriendDataHandler()
	local cur_num = friend_data_handler:getFriendNum()
	if cur_num <= FRIENT_MAX_NUM then
		friend_data_handler:askRequestAddFriend(self.data.uid)
	else
		Alert:warning({msg = ui_word.FRIEND_ADD_FAILED})
	end
end

function ClsFriendExpand:regTouch()
	self:regTouchEvent(self, function(event_type, x, y)
        if event_type == "began" then
        	local pos_x, pos_y = self:getPosition()
    		local size = self.panel:getContentSize()
    		local touch_x = x - pos_x
            local touch_y = y - pos_y
    		if touch_x > 0 and touch_y > 0 and touch_x < size.width and touch_y < size.height then
                return true
            else
            	self:close()
            	return false
            end
        end
    end)
end

return ClsFriendExpand