local ui_word = require("game_config/ui_word")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsDailyActivityTeamRank = class("ClsDailyActivityTeamRank", function() return UIWidget:create() end)
local widget_name = {
	"cup_icon",
	"list_name",
	"list_score",
	"list_rank",
	"cup_num"
}

local RankCell = class("RankCell", require("ui/view/clsScrollViewItem"))

function RankCell:initUI(cell_data)
	self.m_uid = cell_data.uid
	local player = cell_data
	local sp_rank = {}
	local panel = GUIReader:shareReader():widgetFromJsonFile("json/activity_everyday_rank.json")
	convertUIType(panel)
	for k,v in pairs(widget_name) do
		sp_rank[v] = getConvertChildByName(panel, v)
	end
	sp_rank.cup_icon:setVisible(false)
	sp_rank.list_rank:setVisible(true)
	self:addChild(panel)
	local color = COLOR_YELLOW
	local playerData = getGameData():getPlayerData()
	local uid = playerData:getUid()  ----玩家id
	if uid == player.uid then
		color = COLOR_GREEN
	end
	local no_1 = 1
	local no_2 = 2
	local no_3 = 3

	if player.rank <4 then 
		sp_rank.cup_icon:changeTexture("common_top_"..player.rank..".png", UI_TEX_TYPE_PLIST)
		sp_rank.cup_icon:setVisible(true)
		sp_rank.cup_num:setText(player.rank)
		sp_rank.list_rank:setVisible(false)
	else
		sp_rank.list_rank:setText(player.rank)
	end
	sp_rank.list_name:setText(player.name)
	sp_rank.list_name:setColor(ccc3(dexToColor3B(color)))
	sp_rank.list_score:setText(player.point)
	sp_rank.list_score:setColor(ccc3(dexToColor3B(color)))
end

function RankCell:onTap(x, y)
	local playerData = getGameData():getPlayerData()
	if self.m_uid == playerData:getUid() then
		getUIManager():create("gameobj/playerRole/clsRoleInfoView")
	else
		getUIManager():create("gameobj/captionInfo/clsCaptainInfoMain", nil,self.m_uid)
	end
end

function ClsDailyActivityTeamRank:ctor(status)
	getUIManager():get("ClsWeeklyRace"):regChild("ClsDailyActivityTeamRank",self)
	self:askData()
	--self:mkListView()
end

function ClsDailyActivityTeamRank:askData(  )
	local daily_activity_data = getGameData():getDailyActivityData()
	daily_activity_data:askWeeklyRaceRankList()
end

function ClsDailyActivityTeamRank:mkListView()

	local _listcellTab = {}
	local daily_activity_data = getGameData():getDailyActivityData()
	local rank_list = daily_activity_data:getRankList() ----玩家积分排名

	for k,v in pairs(rank_list) do
		local _cell = RankCell.new(CCSize(300, 60),v)
		_listcellTab[k] = _cell
	end
	self.list_view = ClsScrollView.new(467, 325, true,function()end, {is_fit_bottom = true})
	self.list_view:setPosition(ccp(470, 50))
	self:addChild(self.list_view)
	self.list_view:addCells(_listcellTab)

	local ClsWeeklyRace = getUIManager():get("ClsWeeklyRace")
	if not tolua.isnull(ClsWeeklyRace) then
		ClsWeeklyRace:updataMyRank()
	end
end

return ClsDailyActivityTeamRank