--
-- 点击队伍中的队员弹出来的那个窗口
--
local ui_word           = require("game_config/ui_word")
local music_info        = require("game_config/music_info")

local ClsExpandWin      = require("ui/clsExpandWin")
local ClsTeamExpandWin  = class("clsTeamExpandWin", ClsExpandWin)


function ClsTeamExpandWin:getViewConfig()
	return 
	{
    	name       = "ClsTeamExpandWin",
        is_swallow = false,  
    }
end
--[[
	getUIManager():create("gameObj/team/clsTeamExpandWin", nil, parameter)
	parameter = 
	{
		["select_uid"] =  选中的人的uid,
		["item"]       =  哪个面板创建的
	}
	传入ClsTeamExpandWin需要的参数,然后该类创建clsExpandWin需要的参数
--]]
function ClsTeamExpandWin:onEnter(my_parameter)
	self.select_uid    = my_parameter.select_uid

	-- 父类clsExpandWin需要的参数
	self.parameter     = 
	{
		["cells"]      = {},
		["pos_type"]   = POS_TYP.BOTTOM,
		["item"]       = my_parameter.item
	}

	-- 如果判断之后发现没有按钮可以展示
	if not self:initParameter() then
		self:close()
		return
	end
	-- 调用父类onEnter
	ClsTeamExpandWin.super.onEnter(self, self.parameter)
end

-- 静态变量
-- 按钮条件以及对应的按钮文本和点击之后调用的函数名
ClsTeamExpandWin["btn_info"] = {
	[1] = {
		condition = {["self"] = true},
		info      = {text = ui_word.TEAM_LEAVE,	event_func = "toLeaveTeam"} 
	},
	[2] = {
		condition = {["self"] = false, ["not_myfriend"] = true}, 
		info      = {text = ui_word.TEAM_ADD_FRIEND, event_func = "toAddFriend"} 
	},
	[3] = {
		condition = {["team_lead"] = true, ["self"] = false},
		info      = {text = ui_word.TEAM_PROMOTE_LEADER, event_func = "toPromoteLeader"} 
	},
	[4] = {
		condition = {["team_lead"] = true, ["self"] = false},
		info      = {text = ui_word.TEAM_ASK_LEAVE,	event_func = "toTickMember"} 
	},
	[5] = {
		condition = {["self"] = false},	
		info      = {text = ui_word.TEAM_CHECK_INFO, event_func = "toCheckInfo"} 
	},
}

-- 从ClsTeamExpandWin传进来的参数去初始化父类clsExpandWin需要的参数
-- return false 没有可显示的按钮就直接close
function ClsTeamExpandWin:initParameter()
	local can_result = self:judgeShowView(self.select_uid)

	-- 没有一个可以显示
	if table.count(can_result) == 0 then return false end
	-- 按结果加不同按钮
	for k, v in pairs(can_result) do
		local panel    = GUIReader:shareReader():widgetFromJsonFile("json/main_team_btn.json")
		local btn      = getConvertChildByName(panel, "btn")
		local btn_text = getConvertChildByName(panel, "btn_text")

		btn_text:setText(v.text)
		btn:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self:close()
			ClsTeamExpandWin[v.event_func](self)
		end, TOUCH_EVENT_ENDED)

		table.insert(self.parameter.cells, panel)
	end

	return true
end

----------------------- 判断能显示什么按钮 ---------------------------------

function ClsTeamExpandWin:judgeShowView(select_uid)
	local can_result   = {}
	local judge_result = 
	{
		["self"]         = self:isClickOwn(select_uid),
		["not_myfriend"] = not self:isMyFriend(select_uid),
		["team_lead"]    = self:isTeamLeader(),
	}

	for k, v in ipairs(ClsTeamExpandWin.btn_info) do
		local is_available = true
        if v.condition then
            for g, h in pairs(v.condition) do
               if judge_result[g] ~= h then
                    is_available = false
                    break
               end
            end
        end
        if is_available then
        	table.insert(can_result, v.info)
        end
	end
	return can_result
end

function ClsTeamExpandWin:isTeamLeader()
	local teamData = getGameData():getTeamData()
    return teamData:isTeamLeader()
end

function ClsTeamExpandWin:isMyFriend(select_uid)
	local friendDataHandle = getGameData():getFriendDataHandler()
    return friendDataHandle:isMyFriend(select_uid)
end

function ClsTeamExpandWin:isClickOwn(select_uid)
	local playerData = getGameData():getPlayerData()
    if select_uid == playerData:getUid() then
        return true
    end
    return false
end

--------------------------------- 不同按钮事件 -------------------------------
function ClsTeamExpandWin:toLeaveTeam()
	local team_data_handler = getGameData():getTeamData()
	team_data_handler:askLeaveTeam()
end

function ClsTeamExpandWin:toAddFriend()
	local friend_data_handler = getGameData():getFriendDataHandler()
	friend_data_handler:askRequestAddFriend(self.select_uid)
end

function ClsTeamExpandWin:toTickMember()
	local team_data_handler = getGameData():getTeamData()
	team_data_handler:tickTeamPlayer(self.select_uid) 
end

function ClsTeamExpandWin:toPromoteLeader()
	local team_data_handler = getGameData():getTeamData()
	team_data_handler:askPromoteLeader(self.select_uid)
end

function ClsTeamExpandWin:toCheckInfo()
	local playerData = getGameData():getPlayerData()
    if self.select_uid == playerData:getUid() then
        getUIManager():create("gameobj/playerRole/clsRoleInfoView")
    else
        getUIManager():create("gameobj/captionInfo/clsCaptainInfoMain", nil, self.select_uid)
    end
end

return ClsTeamExpandWin