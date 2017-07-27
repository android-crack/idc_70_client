local LEVEL_LIMET = 20
local ClsBroadcastDataHander = class("ClsBroadcastDataHander")

function ClsBroadcastDataHander:ctor()
	self.broadcast_list = {}
	self.scrolled_message_num = 0 --当前滚完的消息数
end

function ClsBroadcastDataHander:insertMsgTolist(info)
	local player_data = getGameData():getPlayerData()
	if player_data:getLevel() < LEVEL_LIMET then
		return
	end
	
	info.message = replaceValidText(info.message) -- 屏蔽词
	table.insert(self.broadcast_list, info)
	local broad_cast = getUIManager():get("ClsBroadcast")
	if tolua.isnull(broad_cast) then
		getUIManager():create("gameobj/chat/clsBroadcast")
	end
end

function ClsBroadcastDataHander:getBroadcastList()
	return self.broadcast_list
end

function ClsBroadcastDataHander:getCurrentScrolledIndex()
	return self.scrolled_message_num + 1
end

function ClsBroadcastDataHander:setScrolledMessageNum()
	self.scrolled_message_num = self.scrolled_message_num + 1
end

return ClsBroadcastDataHander
