-- 虚拟模拟组队数据
-- Author: Ltian
-- Date: 2016-10-10 11:16:53
--
local ui_word = require("game_config/ui_word")

local data = {
	[1] = {
	    ["id"] = 2.000000,
	    ["info"] = {
	        },
	    ["invite_type"] = 1.000000,
	    ["leader"] = 10351.000000,
	    ["leader_elite_id"] = 31.000000,
	    ["port_id"] = 6.000000,
	    ["type"] = 1.000000,
    },
}

local info1 = {
    ["flagShip"] = 3.000000,
    ["grade"] = 3.000000,
    ["icon"] = "8",
    ["name"] = ui_word.VIRTUAL_NAME_1,
    ["name_status"] = 0.000000,
    ["profession"] = 3,
    ["uid"] = 101.000000,
}

local info2 = {
    ["flagShip"] = 6.000000,
    ["grade"] = 3.000000,
    ["icon"] = "1",
    ["name"] = ui_word.VIRTUAL_NAME_2,
    ["name_status"] = 0.000000,
    ["profession"] = 2,
    ["uid"] = 102.000000,
}

local ClsAlert = require("ui/tools/alert")

local ClsVirtualTeamData = class("virtualTeamData")
function ClsVirtualTeamData:ctor()
	self.lock = false
	self:initMyData()
end

function ClsVirtualTeamData:initMyData()
	local player_data = getGameData():getPlayerData()
	self.my_name = player_data:getName()
	self.my_uid = player_data:getUid()
	self.my_level = player_data:getLevel()
	self.my_icon = player_data:getIcon()
	self.my_rolo_id = player_data:getRoleId()
	self.my_info = {
		["flagShip"] = 6.000000,
	    ["grade"] = self.my_level,
	    ["icon"] = tostring(self.my_icon),
	    ["name"] = self.my_name,
	    ["name_status"] = 0.000000,
	    ["profession"] = self.my_rolo_id,
	    ["uid"] = self.my_uid,
	}
end

function ClsVirtualTeamData:reset()
	self.lock = false
end

function ClsVirtualTeamData:createVirtualTeam()
	if self.lock then return end
	self.lock = true
	self.team_data = table.clone(data)
	self:joinVirtualTeam()
	rpc_client_team_list(self.team_data)
	local running_scene = GameUtil.getRunningScene()
	local touch_layer = display.newLayer()
	touch_layer:registerScriptTouchHandler(function(eventType, x, y) 
		if eventType =="began" then
			return true 
		end
	end, false, TOUCH_PRIORITY_MISSION - 50, true)

	running_scene:addChild(touch_layer)
	touch_layer:setTouchEnabled(true)
	local array = CCArray:create()
	array:addObject(CCDelayTime:create(1))
	array:addObject(CCCallFunc:create(function()
		self.team_data[1].info[2] = info1
		rpc_client_team_list(self.team_data)
		ClsAlert:warning({msg = info1.name..ui_word.JOIN_TEAM})
	end))
	array:addObject(CCDelayTime:create(1))
	array:addObject(CCCallFunc:create(function ()
		
		self.team_data[1].info[3] = info2
		rpc_client_team_list(self.team_data)
		ClsAlert:warning({msg = info2.name..ui_word.JOIN_TEAM})
		if not tolua.isnull(touch_layer) then
			touch_layer:removeFromParentAndCleanup(true)
		end
		self:addGuide()
	end))
	display.getRunningScene():runAction(CCSequence:create(array))
end

function ClsVirtualTeamData:joinVirtualTeam()
	table.insert(self.team_data[1].info, 1, self.my_info)
	getGameData():getTeamData():setMyTeamInfo(self.team_data[1])
	getGameData():getTeamData():setTeamLeader(true)
	rpc_client_team_list(self.team_data)
end

function ClsVirtualTeamData:addGuide()
	-- local guide_item = {}
	-- guide_item.radius = 50
	-- guide_item.pos = {x = 880, y = 50}
	-- guide_item.rotation = 0
	-- guide_item.autoRelease = true
	-- guide_item.guideType = 1
	-- local running_scene = GameUtil.getRunningScene()
	-- local guide_layer = createMissionGuideLayer( guide_item )
	-- running_scene:addChild(guide_layer, 1000000)
end

function ClsVirtualTeamData:askToBattle()
	getGameData():getTeamData():setMyTeamInfo(nil)
	local mission_id = getGameData():getTeamData():getVirtualTeamFightMissionID()
	getGameData():getMissionData():gotoMissionBattle(mission_id)
end



return ClsVirtualTeamData