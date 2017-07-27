--
-- Author: lzg0496
-- Data: 2016-12-29
-- Function: 存储市政工作数据
--

local clsMunicipalWorkData = class("clsMunicipalWorkData")

function clsMunicipalWorkData:ctor()
    self.task_list = {}
end

function clsMunicipalWorkData:setTaskList(info_list)
    self.task_list = info_list
    local port_town_ui = getUIManager():get("clsPortTownUI")
    if not tolua.isnull(port_town_ui) then
        port_town_ui:updateUI()
    end
end

function clsMunicipalWorkData:getTaskList()
    return self.task_list
end

---------------------------------------------------------- 协议请求 -----------------------------------------------------------------

function clsMunicipalWorkData:askTaskInfo()
    GameUtil.callRpc("rpc_server_government_work_info", {})
end

function clsMunicipalWorkData:askTaskAccept(task_id)
    GameUtil.callRpc("rpc_server_government_work_accept", {task_id})
end

function clsMunicipalWorkData:askTaskReward(task_id)
    GameUtil.callRpc("rpc_server_government_work_reward", {task_id})
end


---------------------------------------------------------- 协议请求 -----------------------------------------------------------------

return clsMunicipalWorkData
