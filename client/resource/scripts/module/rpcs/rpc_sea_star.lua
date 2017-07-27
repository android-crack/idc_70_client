--
-- Author: 0496
-- Date: 2016-03-08 19:39:58
-- Function: 有关海上新星系统的返回协议

local alert = require("ui/tools/alert")
local error_info = require("game_config/error_info")
local ClsDialogSequene = require("gameobj/quene/clsDialogQuene")
local ClsSailorWineRecuitQuene = require("gameobj/quene/clsSailorWineRecuitQuene")


function rpc_client_new_star_list(info)
	getGameData():getSeaStarData():initInfoData(info)
end

function rpc_client_new_star_progress_get(mission_id, result, error, rewards)
	if result == 0 then
		local msg = error_info[error].message
		alert:warning({msg = msg})
		return
	end

    alert:showCommonReward(rewards, function() 
        local index = mission_id % 5
        if index == 0 then
            index = 5
        end
        local seaStarUI = getUIManager():get("ClsSeaStarUI")
        if not tolua.isnull(seaStarUI) then
            seaStarUI:doPassAction(index) 
        end
    end)
end

function rpc_client_new_star_total_get(index, result, error, rewards)
	if result == 0 then
		local msg = error_info[error].message
		alert:warning({msg = msg})
		return
	end

    if rewards[1].type == ITEM_INDEX_BOAT then
    	return
    end

    if rewards[1].type == ITEM_INDEX_SAILOR then
        ClsDialogSequene:insertTaskToQuene(ClsSailorWineRecuitQuene.new({sailor_id = rewards[1].id, call_back = function (  )
            getGameData():getSeaStarData():askSeaStarList()
        end}))
        return
    end
    alert:showCommonReward(rewards, function() getGameData():getSeaStarData():askSeaStarList() end)
end