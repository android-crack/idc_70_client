--
-- Author: lzg0496
-- Date: 2016-12-29
-- Function: 市政厅工作协议
--
--

local cfg_error_info = require("game_config/error_info")
local ClsAlert = require("ui/tools/alert")


local askWorkInfo = function()
    local municipal_work_data = getGameData():getMunicipalWorkData()
    municipal_work_data:askTaskInfo()
end

-- class info {
--      int workId
--      int status
--      int remain_time
-- }
--
function rpc_client_government_work_info(info_list)
    local municipal_work_data = getGameData():getMunicipalWorkData()
    municipal_work_data:setTaskList(info_list)  
end

function rpc_client_government_work_accept(error_code)
    if error_code ~= 0 then
        ClsAlert:warning({msg = cfg_error_info[error_code].message})
        return 
    end
    askWorkInfo()
end

function rpc_client_government_work_reward(error_code, rewards)
    if error_code ~= 0 then
        ClsAlert:warning({msg = cfg_error_info[error_code].message})
        return 
    end

    if type(rewards) == "table" then
        ClsAlert:showCommonReward(rewards, function()
            askWorkInfo()   
        end)
    end
end
