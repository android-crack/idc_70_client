--
-- Author: Ltian
-- Date: 2016-11-19 10:12:31
--

--注意在这个文件的外部少用require，防止出现重复包含的问题

local TRUE_VALUE = 1
local STOP_MOVE_FORMAT = "LogicHander_lockmove_view_%s"
local STOP_FOOD_FORMAT = "LogicHander_lockfood_view_%s"
local ClsUILogicHander = class("ClsUILogicHander")

function ClsUILogicHander:ctor()
	self.m_view_list = require("game_config/view_logic_cfg")
end

function ClsUILogicHander:isCreate(view_cfg_item)
	local name_str = view_cfg_item.name
	local view_list_item = self.m_view_list[name_str]
	if not view_list_item then return true end
	if view_list_item.is_member_lock == TRUE_VALUE then
		if getGameData():getTeamData():isLock(true) then
			return false
		end
	end
	if view_list_item.is_explore_lock == TRUE_VALUE then
		if getUIManager():isLive("ExploreLayer") then
			local ui_word = require("game_config/ui_word")
			require("ui/tools/alert"):warning({msg = ui_word.LOCK_IN_EXPLORE})
			return false
		end
	end
	return true
end

function ClsUILogicHander:doViewOnCreate(view_name_str)
	local view_list_item = self.m_view_list[view_name_str]
	if not view_list_item then return end
	local explore_layer = getUIManager():get("ExploreLayer")
	if not tolua.isnull(explore_layer) then
		if view_list_item.is_move_stop == TRUE_VALUE then
			explore_layer:getShipsLayer():setStopShipReason(string.format(STOP_MOVE_FORMAT, view_name_str))
		end
		if view_list_item.is_stop_food_down == TRUE_VALUE then
			explore_layer:getShipsLayer():setStopFoodReason(string.format(STOP_FOOD_FORMAT, view_name_str))
		end
	end
end

function ClsUILogicHander:doViewOnClose(view_name_str)
	local view_list_item = self.m_view_list[view_name_str]
	if not view_list_item then return end
	local explore_layer = getUIManager():get("ExploreLayer")
	if not tolua.isnull(explore_layer) then
		if view_list_item.is_move_stop == TRUE_VALUE then
			explore_layer:getShipsLayer():releaseStopShipReason(string.format(STOP_MOVE_FORMAT, view_name_str))
		end
		if view_list_item.is_stop_food_down == TRUE_VALUE then
			explore_layer:getShipsLayer():releaseStopFoodReason(string.format(STOP_FOOD_FORMAT, view_name_str))
		end
	end
end

function ClsUILogicHander:doOnEnter()
	local auto_trade_data = getGameData():getAutoTradeAIHandler()
	local is_auto_trade = auto_trade_data:getIsAutoTrade()
	if is_auto_trade then
		auto_trade_data:showAIMaskLayer()
	end
	
	---自动悬赏
    local missionDataHandler = getGameData():getMissionData()
    local is_auto_task = missionDataHandler:getAutoPortRewardStatus()
    if is_auto_task then
        local ClsAutoPortRewardLayer = getUIManager():get("ClsAutoPortRewardLayer")
        if tolua.isnull(ClsAutoPortRewardLayer) then
            getUIManager():create("gameobj/port/clsAutoPortRewardLayer")
        end    	
    end

end

function ClsUILogicHander:doOnExit()
	local ClsDialogSequence = require("gameobj/quene/clsDialogQuene")
	ClsDialogSequence:resetQuene()
end

return ClsUILogicHander