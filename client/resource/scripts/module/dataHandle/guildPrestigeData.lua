local tool=require("module/dataHandle/dataTools")
local news=require("game_config/news")
local Alert = require("ui/tools/alert")
local message_parse = require("module/message_parse")
local error_info=require("game_config/error_info")
local music_info = require("game_config/music_info")
local ui_word = require("game_config/ui_word")

--威望
local donateData = {
	[1] = {gold=10,contribution=100,prestige=1},
	[2] = {gold=100,contribution=1200,prestige=12},
	[3] = {gold=1000,contribution=15000,prestige=150},
}

local GuildPrestigeData = class("GuildPrestigeData")

function GuildPrestigeData:ctor()
	self.guildPrestige = {}
	self.guildStar = nil
	self.guildStarName = nil
	self.guildStarLevel = nil
	self.guildStarIcon = nil
	self.guildEventsTab = {}  --30条
	self.guildUiEventFunc = nil
	self.guildSaluteTime = nil  --是否已经敬礼了
	self.guildSaluteUiFuc = nil
	self.donateValue = nil
	self.saluteTimes = nil --受致敬的次数
	self.saluteLimit = nil --致敬的总次数
end

function GuildPrestigeData:askGuildDonate(value)
	self.donateValue=value or 0
	local playerData = getGameData():getPlayerData()
	if playerData:getGold()<self.donateValue then
		local element = getUIManager():get("ClsGuildMainUI")
		Alert:showJumpWindow(DIAMOND_NOT_ENOUGH, element)
	else
		audioExt.playEffect(music_info.COMMON_GOLD.res)
		GameUtil.callRpc("rpc_server_group_donate", {value},"rpc_client_group_donate")
	end
end

function GuildPrestigeData:receiveGuildDonateResult()  --声望信息有变化刷新公会数据
	Alert:warning({msg =string.format(news.GUILD_DONATE_SUCESS.msg,self.donateValue), size = 26})
	local guildInfoData = getGameData():getGuildInfoData()
	guildInfoData:askGuildInfo()
end

function GuildPrestigeData:getDonateData()
	return donateData
end

function GuildPrestigeData:askGuildPrestigeInfo()
	GameUtil.callRpc("rpc_server_group_honour_info", {},"rpc_client_group_honour_info")
end

function GuildPrestigeData:receiveGuildPrestige(prestigeData)
	self.guildPrestige = prestigeData
	EventTrigger(EVENT_GUILD_UPDATE_REQUEST_PRESTIGE)
end

function GuildPrestigeData:getGuildPrestige()
	return self.guildPrestige
end

function GuildPrestigeData:receiveGuildStar(starId)
	self.guildStar = starId

	local guild_main_ui = getUIManager():get("ClsGuildMainUI")
	if not tolua.isnull(guild_main_ui) then
		guild_main_ui:updateGuildStar()
		-- return
	end

	local guild_prestige_ui = getUIManager():get("ClsGuildPrestigePanel")
	if not tolua.isnull(guild_prestige_ui) then
		self:dealSaluteTime()
	end
end

function GuildPrestigeData:getStarId()
	return self.guildStar
end

function GuildPrestigeData:askGuildEvent()
	GameUtil.callRpc("rpc_server_group_event_list")
end

function GuildPrestigeData:receiveAllGuildEvents(list)
	for k,v in ipairs(list) do
		v.msg=message_parse.parse(v.msg)
	end
	self.guildEventsTab=list

	if type(self.guildUiEventFunc)=="function" then
		self.guildUiEventFunc(self.guildEventsTab)
	end
	
	-- local guild_event_ui = getUIManager():get("clsGuildInfoEventPanel")
 --    if not tolua.isnull(guild_event_ui) then
 --    	guild_event_ui:updateGuildEvent(self.guildEventsTab)
 --    end
end

function GuildPrestigeData:receiveGuildEvent(event)
	event.msg=message_parse.parse(event.msg)
	table.print(event)
	local eventNum=#self.guildEventsTab
	if eventNum>=30 then   --删除前面的几条保留29 条并+进新的一条
		for i=1,eventNum-29 do
			table.remove(self.guildEventsTab,1)
	end
	end
	table.insert(self.guildEventsTab,#self.guildEventsTab+1,event)

	if type(self.guildUiEventFunc)=="function" then
		self.guildUiEventFunc(self.guildEventsTab)
	end
end

function GuildPrestigeData:regEventUiFunc(func)
	self.guildUiEventFunc=func
end

function GuildPrestigeData:regSaluteUiFunc(func)
	self.guildSaluteUiFuc=func
end

function GuildPrestigeData:dealSaluteTime()
	if type(self.guildSaluteUiFuc)=="function" then
		self.guildSaluteUiFuc(self.guildSaluteTime, self.guildStar)
	end
end

function GuildPrestigeData:setSaluteTime(saluteTime)
	self.guildSaluteTime = saluteTime
	self:dealSaluteTime()
end


function GuildPrestigeData:askSalute()
	GameUtil.callRpc("rpc_server_group_prestige_salute", {}, "rpc_client_group_prestige_salute")
end

function GuildPrestigeData:askSaluteReward() 
	GameUtil.callRpc("rpc_server_group_salute_reward", {}, "rpc_client_group_salute_reward")
end

function GuildPrestigeData:askGuildStartList()
	GameUtil.callRpc("rpc_server_group_invest_rank", {}, "rpc_client_group_invest_rank")
end

function GuildPrestigeData:askGuildCurStartList()
	GameUtil.callRpc("rpc_server_group_invest_rank_cur", {}, "rpc_client_group_invest_rank_cur")
end

function GuildPrestigeData:receiveSaluteResult(result, err, salute_reward)
	if result == 1 then
		self.guildSaluteTime = 1
		self:setSaluteTime(self.guildSaluteTime, self.guildStar)
		Alert:showCommonReward(salute_reward)
	else
		Alert:warning({msg = error_info[err].message, size = 26})
	end
end

function GuildPrestigeData:receiveSaluteLimit(salute_times, salute_limit)
	self.saluteTimes = salute_times
	self.saluteLimit = salute_limit
	self:setSaluteTime(self.guildSaluteTime, self.guildStar)
end

function GuildPrestigeData:setStarData(info)
	self.guildStarName = info.star_name
	self.guildStarLevel = info.star_grade
	self.guildStarIcon = info.star_icon
	self.guildSaluteTime = info.has_salute
	self.guildStar = info.star_member
	self.saluteTimes = info.salute_times
	self.saluteLimit = info.salute_limit
end

function GuildPrestigeData:getStarData()
	return {name = self.guildStarName, 
			level = self.guildStarLevel, 
			icon = self.guildStarIcon, 
			saluteTimes = self.saluteTimes,
			saluteLimit = self.saluteLimit,
		}
end

return GuildPrestigeData
