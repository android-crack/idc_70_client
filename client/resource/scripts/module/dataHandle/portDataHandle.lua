local boat_info=require("game_config/boat/boat_info")
local goods_info=require("game_config/port/goods_info")
local sailor_info=require("game_config/sailor/sailor_info")
local mission_port_power_info = require("game_config/mission/mission_port_power_info")
local port_power = require("game_config/mission/port_power")
local area_info = require("game_config/port/area_info")
local ui_word = require("game_config/ui_word")
local port_info = require("game_config/port/port_info")
local tool=require("module/dataHandle/dataTools")
local Alert = require("ui/tools/alert")
local tips = require("game_config/tips")

local PortData = class("PortData")

function PortData:ctor()
    self.portId=nil       --港口id
    self.isPortInfoByServer = false
    self.portInfo={}     --港口信息
    self.openInfo={}    --开放功能
    --local blckMarketInfo={}   --黑市商人
    self.portList=nil  --被系统占领的感慨

    self.noFirst=false
    self.effectPorts={}    --保存港口的特效状态  1 有特效   0 没特效
    self.enter_call_back_list = {}
    self.pop_info = nil --快捷弹框的信息
    self.has_pop_window = nil  --默认没有弹框
    self.battle_reward_list = {}
    self.arrest_mark = false
    self.cur_feature_id = nil  --默认没有预开放功能
    self.port_power_info = {} --当前港口势力归属列表
    self.change_power_info = {} --当前势力的变化
    self.explore_difference_power_info = {} --当前势力与上一次势力的变化, 探索小地图所用
    self.port_difference_power_info = {} --当前势力与上一次势力的变化, 港口表现所用
end

function PortData:setArrestMark(id)
    self.arrest_mark = id
end

function PortData:getArrestMark()
    return self.arrest_mark
end

function PortData:getIsProtectArea(area_id)
	local area_item = area_info[area_id]
	if area_item and area_item.is_protect == 1 then
		return true
	end
	return false
end

--领取奖励
function PortData:askInvestReward(portId, step)
    GameUtil.callRpc("rpc_server_port_invest_reward", {portId, step}, "rpc_client_port_invest_reward")
end

function PortData:askUpLoadBoat(boat_key)
    GameUtil.callRpc("rpc_server_partner_auto_upload_boat", {boat_key})
end

function PortData:askUpLoadBaowu(baowu_key)
    GameUtil.callRpc("rpc_server_partner_auto_upload_baowu", {baowu_key})
end

function PortData:askBackEnterPort()
    GameUtil.callRpc("rpc_server_back_enter_port", {})
end

--添加进入港口时的判断事件
function PortData:setEnterPortCallBack(call_back, is_reamin)
    if is_reamin == nil then
        is_reamin = false
    end

    if type(call_back) == "function" then
        call_back = {call = call_back, is_reamin = is_reamin}
    end
    table.insert(self.enter_call_back_list, call_back)
end

--检查执行进入的事件列表并将该移除的移除
function PortData:checkEnterPortCallBack()
    local remain_list = {}
    for k, v in ipairs(self.enter_call_back_list) do
        if type(v.call) == "function" then
            v.call()
        end

        if v.is_reamin then
            table.insert(remain_list, v)
        end
    end
    self.enter_call_back_list = remain_list
end

function PortData:askPortInfo()
    GameUtil.callRpc("rpc_server_port_main_info", {self.portId})
    GameUtil.callRpc("rpc_server_map_hotsell_port", {})  --星级商品
end

function PortData:updatePort()
    if self.portId and self.isPortInfoByServer then
        local port_layer = getUIManager():get("ClsPortLayer")
        if not tolua.isnull(port_layer) then
            port_layer:updateUI(self.portInfo)
        end
    end
end

function PortData:clearPortId()
    self.portId = nil
    self.isPortInfoByServer = false
end

function PortData:changePortId(id)
    if not self.portId or self.portId ~= id then
        if not self.effectPorts[id] then
            self.effectPorts[id] = 1
        end
        
        self.portId = id
        self.portInfo = tool:getPort(id)
    end
    self.isPortInfoByServer = false
    self:askPortInfo()
end

function PortData:getPortId()
    return self.portId
end

function PortData:getPortType()
    return self.portInfo.portType
end

function PortData:getPortPeople()
    return table.clone(self.portInfo.people)
end

function PortData:getPortAreaName()
    return self.portInfo.sea_area
end

function PortData:getPortAreaId()
    return self.portInfo.areaId
end

function PortData:getPortFlipX()
    return self.portInfo.flipX
end

function PortData:getPortName()
    return self.portInfo.name
end

function PortData:getPortInfo()
    return self.portInfo
end

function PortData:getOpenInfo()
    return self.openInfo
end

--港口
function PortData:receivePortInfo(info)
    self.isPortInfoByServer = true
    self.openInfo={}
    --  self.openInfo.openHotel=info.pubType --0没有 1开放 2未解锁 3 解锁
    --  self.openInfo.openShip=info.shipyardType --0没有 1开放 2未解锁 3 解锁
    --self.openInfo.tutor=info.unlockTeacher
    --  self.openInfo.status=info.status   --0 没开启，1 锁，2 开锁
    self.openInfo.firstEnterPort=info.firstEnterPort
    --    print("第一次进港口的状态值--------------------------------->",info.firstEnterPort)
    if info.firstEnterPort==1 then
        self.effectPorts[self.portId]=1
    else
        self.effectPorts[self.portId]=0
    end

    local port_layer = getUIManager():get("ClsPortLayer")
    if not tolua.isnull(port_layer) then
        port_layer:updateUI(self.portInfo)
    end
end
--被系统占领的港口
function PortData:receiveOccupiedPorts(portList_)
--    print("++++++++++++++++++++被抢港口列表+++++++++++++++=")
    self.portList=portList_
    --    portList={1,2,3}
end

function PortData:getOccupidePortNameTab()
    if not self.portList or #self.portList ==0 then return end
    local nameTab={}
    if self.portList then
        for i=1,3 do
            if self.portList[i] then nameTab[i]=port_info[self.portList[i]].name end
        end
    end
    self.portList=nil
--    print("++++++++++++++++++++被抢港口列表名字+++++++++++++++=")
    return nameTab
end

local function getMaxId(lock)
    if not lock then return end
    for i=7,1 do
        if lock[i] then return lock[i].id end
    end
end

function PortData:getEffect()
    if self.effectPorts[self.portId]==1 or not self.noFirst then
        return true
    end
end

function PortData:setEffect()
    self.effectPorts[self.portId]=0
    self.noFirst=true
end

function PortData:receivePortEffectList(portList)
    for portId, info in pairs(port_info) do
        self.effectPorts[portId]=1
    end

    for k, v in pairs(portList) do
        if v.portId then self.effectPorts[v.portId]=0 end
    end
end

--function PortData:receiveBlackMarketInfo(list)
--    blckMarketInfo = list   --黑市商人
--    EventTrigger(EVENT_PORT_BLACK_MARKET_INFO)
--end

--[[function PortData:getBlackMarketInfo()
    return blckMarketInfo   --黑市商人
end]]

--[[function PortData:askBlackMarketInfo()
    GameUtil.callRpc("rpc_server_black_market_info", {},"rpc_client_black_market_info")
end]]

-----快捷弹框----
function PortData:askForCloseWindow()
    GameUtil.callRpc("rpc_server_use_window", {})
end

--快捷弹框，道具/投资奖励
function PortData:receivePopWindow(info)
    self.pop_info = info
    self.has_pop_window = true
end

function PortData:hasPopWindow()
    return self.has_pop_window
end

function PortData:getPopWindowInfo()
    return self.pop_info
end

function PortData:clearPopWindow()
    self.has_pop_window = nil
end


function PortData:pushBattleReward(battle_reward)
    self.battle_reward_list[#self.battle_reward_list + 1] = battle_reward
end

function PortData:popBattleReward()
    return table.remove(self.battle_reward_list, 1)
end

function PortData:pushSailorAppiont(callback)
    self.sailor_func = callback
end

function PortData:popSailorAppiont()
    if type(self.sailor_func) == "function" then
        --屏蔽
        -- local dialogSequence = require("gameobj/mission/dialogSequence")
        -- local dialogType = dialogSequence:getDialogType()
        -- dialogSequence:insertDialogTable({fun = function ()
        --     if type(self.sailor_func) == "function" then
        --         self.sailor_func()
        --     end
        -- end, dialogType = dialogType.un_appiont_alert})
        
    end
end

function PortData:alertSailorView(port_id, sailor_id, invest_step, new_sailor_id, new_port)
    local port_layer = getUIManager():get("ClsPortLayer")
    if tolua.isnull(port_layer) then --加入在港口没有播放队列暂停了再仍回队列
        self:pushSailorAppiont(function()
            self:alertSailorView(port_id, sailor_id, invest_step)
        end)
        return
    elseif not tolua.isnull(port_layer) and not tolua.isnull(port_layer.portItem) then
        self:pushSailorAppiont(function()
            self:alertSailorView(port_id, sailor_id, invest_step)
        end)
        return
    end
    self:setAlertSailorAppiontStatus(true)
    local sailor = {
        name = sailor_info[sailor_id].name,
        res = sailor_info[sailor_id].res
    }

    if new_sailor_id and new_sailor_id ~= 0 then
        sailor = {
            name = sailor_info[new_sailor_id].name,
            res = sailor_info[new_sailor_id].res
        }        
    end
    local port_name = port_info[port_id].name
    local next_port_name = ""
    if new_port and new_port ~= 0 then
        next_port_name = port_info[new_port].name
    end

    ---奖励类型，奖励名称
    local investData = getGameData():getInvestData()
    local item_type, item_name = investData:getPortReward(port_id, invest_step)
    local str = ""
    if item_type == "" then
        str = string.format(ui_word.INVEST_GO_TO_APPOINT_2 , port_name ,invest_step, item_name, next_port_name) 
    else
        str = string.format(ui_word.INVEST_GO_TO_APPOINT , port_name ,invest_step, item_type, item_name,  next_port_name) 
    end

    local btn_text = ui_word.PORT_MARKET_ACCOUNTANT_BTN_NAME
    btn_text = nil 
    local function onClick()
        local voice_info = getLangVoiceInfo()
        audioExt.playEffect(voice_info["VOICE_PLOT_1028"].res, false)
        local explore_map = getUIManager():get("ExploreMap") or getUIManager():get("PortMap")
        if tolua.isnull(explore_map) then --避免重复弹多个出海界面的问题
            local port_layer = getUIManager():get("ClsPortLayer")
            port_layer:setTouch(false)
            local skip_to_layer = require("gameobj/mission/missionSkipLayer")
            skip_to_layer:skipPortLayer()
        end
    end
    Alert:showDialogTips(sailor, str, btn_text , nil, onClick, nil, ccc4(0, 0, 0, 0), function()
        -- require("gameobj/mission/dialogSequence"):setResumeData()
        -- require("gameobj/mission/dialogSequence"):setResumeDialog()
        self:setAlertSailorAppiontStatus(false)
    end)
    self.sailor_func = nil
        
end

function PortData:setAlertSailorAppiontStatus(status)
    self.is_alert_sailor_appiont_status = status
end

function PortData:isAlertSailorAppiont()
    return self.is_alert_sailor_appiont_status
end

function PortData:saveBattleEndLayer(layer)
    self.battle_end_to_layer = layer
end

function PortData:getBattleEndLayer()
    local layer = self.battle_end_to_layer
    self.battle_end_to_layer = nil
    return layer
end

function PortData:autoPopBattleEndLayer()
    if not self.battle_end_to_layer then
        return
    end
    local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
    local layer = missionSkipLayer:skipLayerByName(self.battle_end_to_layer)
    self.battle_end_to_layer = nil
end

------功能预开放

function PortData:receiveFeatureId(cur_feature_id)
    self.cur_feature_id = cur_feature_id
end

function PortData:getFeatureId()
    return self.cur_feature_id
end
------功能预开放

--自动经商AI中，未入港直接改id数值，不动其他逻辑
function PortData:setPortIdByTradeAI(portId)
    if not self.effectPorts[portId] then
        self.effectPorts[portId] = 1
    end
    self.portId = portId
    self.portInfo = tool:getPort(portId)
end

-------------------- 海域势力相关 -------------------------------------

function PortData:getExploreDiffPowerInfo()
    return self.explore_difference_power_info
end

function PortData:getPortDiffPowerInfo()
    return self.port_difference_power_info
end

function PortData:isPortPowerDiff(port_id)
    print("=============isPortPowerDiff=================")
    return self.port_difference_power_info[port_id]
end

function PortData:clearPortPowerDiff()
    self.port_difference_power_info = {}
end

function PortData:setExploreDiffPowerInfo()
    self.explore_difference_power_info = {}
end

function PortData:setChangePowerInfo(area_id)
    self.change_power_info[area_id] = {}
end

function PortData:getChangePowerInfo(area_id)
    return self.change_power_info[area_id]
end

function PortData:trySetChangePowerInfo(port_power_info_1, port_power_info_2)
    local init_change_power_info = function()
        for k, v in ipairs(port_power) do
            local sea_belong = v.sea_belong 
            for k1, sea_id in pairs(sea_belong) do
                self.change_power_info[sea_id] = {}
                self.change_power_info[sea_id]["del_t"] = {}
                self.change_power_info[sea_id]["add_t"] = {}
                self.change_power_info[sea_id]["up_t"] = {}
                self.change_power_info[sea_id]["down_t"] = {}
            end
        end
    end

    local handler_add_or_del = function(power_info_1, power_info_2, is_add)
        local t = {}
        for k1, v1 in pairs(power_info_1) do
            local find_mark = false
            for k2, v2 in pairs(power_info_2) do
                if v1.power_id == v2.power_id then
                    find_mark = true
                    break
                end
            end
            if not find_mark then
                t[#t + 1] = v1.power_id
            end
        end
        return t
    end

    local handler_up_or_down = function(power_info_1, power_info_2, is_up)
        local t = {}
        for k1, v1 in pairs(power_info_1) do
            local find_mark = false
            for k2, v2 in pairs(power_info_2) do
                if v1.power_id == v2.power_id and v2.amount > v1.amount and is_up then
                    find_mark = true
                    break
                end

                if v1.power_id == v2.power_id and v2.amount < v1.amount and not is_up then
                    find_mark = true
                    break
                end
            end
            if find_mark then
                t[#t + 1] = v1.power_id
            end
        end
        return t
    end
    
    local init_change_power_mark = false
    for k, v in pairs(area_info) do

        local power_info_1 = self:getPortPowerList(port_power_info_1, k)
        local power_info_2 = self:getPortPowerList(port_power_info_2, k)
        local del_t = handler_add_or_del(power_info_1, power_info_2)
        local add_t = handler_add_or_del(power_info_2, power_info_1, true)
        local down_t = handler_up_or_down(power_info_1, power_info_2)
        local up_t = handler_up_or_down(power_info_1, power_info_2, true)
        if #del_t > 0 or #add_t > 0 or #down_t > 0 or #up_t > 0 then
            if not init_change_power_mark then
                init_change_power_mark = true
                init_change_power_info()
                break
            end
        end
    end

    if init_change_power_mark then
        for k, v in pairs(area_info) do
            if self.change_power_info[k] then
                local power_info_1 = self:getPortPowerList(port_power_info_1, k)
                local power_info_2 = self:getPortPowerList(port_power_info_2, k)
                local del_t = handler_add_or_del(power_info_1, power_info_2)
                local add_t = handler_add_or_del(power_info_2, power_info_1, true)
                local down_t = handler_up_or_down(power_info_1, power_info_2)
                local up_t = handler_up_or_down(power_info_1, power_info_2, true)
                self.change_power_info[k]["del_t"] = del_t
                self.change_power_info[k]["add_t"] = add_t
                self.change_power_info[k]["down_t"] = down_t
                self.change_power_info[k]["up_t"] = up_t
            end
        end
    end
end

function PortData:getPortPowerInfo()
    if #self.port_power_info == 0 then
        self:trySetPortPowerInfo()
    end
    return self.port_power_info
end

function PortData:getPortPowerInfoById(port_id)
	local infos = self:getPortPowerInfo()
	if infos then
		return infos[port_id]
	end
end

function PortData:getPortPowerList(port_power_info, area_id)
    local power_list = {}
    for k, v in ipairs(port_power) do
        local sea_belong = v.sea_belong 
        for k1, sea_id in pairs (sea_belong) do
            if sea_id == area_id then
                power_list[#power_list + 1] = {}
                power_list[#power_list]["power_id"] = k
            end
        end
    end

    local port_power_info = port_power_info or self:getPortPowerInfo()
    local map_attr_data = getGameData():getWorldMapAttrsData()
    for k , v in ipairs(power_list) do
        local sum = 0
        local port_ids = {}
        for k1, v1 in ipairs(port_power_info) do 
            if map_attr_data:isMapOpenPort(k1) then
                local m_port_info = port_info[k1]
                if v.power_id == v1.power_id and m_port_info.areaId == area_id then
                    port_ids[#port_ids + 1] = k1
                    sum = sum + 1
                end
            end
        end
        if sum ~= 0 then
            power_list[k]["port_ids"] = port_ids
            power_list[k]["amount"] = sum
        end
    end

    for i = #power_list, 1, -1 do
        if not power_list[i].amount then
            table.remove(power_list, i)
        end
    end

    if not table.is_empty(power_list) then
        table.sort(power_list, function(a, b)
            return a.amount < b.amount
        end)
    end
    return power_list
end

function PortData:trySetPortPowerInfo()
    local mission_data = getGameData():getMissionData()
    local main_line_mission_id = mission_data:getMainLineMission()

    local getCfgId = function(find_mission_id)
        local target_id = 1
        for k, v in ipairs(mission_port_power_info) do
            target_id = k
            local cmp = mission_data:comparemMissionIdSize(v.main_mission_id, find_mission_id)
            if cmp == 1 then
                target_id = k - 1
                break
            end
        end
        return mission_port_power_info[target_id] or mission_port_power_info[1]
    end
    local mission_cfg_item = getCfgId(main_line_mission_id)
    local str_read_power = "game_config/mission/port_power_info_" .. mission_cfg_item.read_port_power_start
    if main_line_mission_id ~= mission_cfg_item.main_mission_id then
        str_read_power = "game_config/mission/port_power_info_" .. mission_cfg_item.read_port_power_end
    end
    local port_power_info = require(str_read_power)
    local tmp_power_info = self:compoundPower(port_power_info, mission_cfg_item)
    local init_diff_mark = false
    for port_id, new_power_data in ipairs(tmp_power_info) do
        local old_power_data = self.port_power_info[port_id]
        if old_power_data then
            if new_power_data.power_id ~= old_power_data.power_id or 
                new_power_data.port_status ~= old_power_data.port_status then
                if not init_diff_mark then
                    init_diff_mark = true
                    self.explore_difference_power_info = {}
                end
                self.explore_difference_power_info[port_id] = {old_power_data, new_power_data}
            end
        end
    end
    if init_diff_mark then
        self.port_difference_power_info = table.clone(self.explore_difference_power_info)
    end
    self:trySetChangePowerInfo(self.port_power_info, tmp_power_info)
    self.port_power_info = tmp_power_info
end

function PortData:compoundPower(port_power_info, mission_cfg_item)
    local MISSION_KEY = 1
    local FINISH_MISSION_KEY = 2
    if not mission_cfg_item.other_mission_cfg then return port_power_info end
    local mission_data = getGameData():getMissionData()
    local mission_list = mission_data:getMissionInfo()
    local main_line_mission_id = mission_data:getMainLineMission()

    local branch_misssions = {}

    local getFinishCfg = function(main_cfg, others_tab) 
        for k, v in ipairs(others_tab) do
            local str_read_power = "game_config/mission/port_power_info_" .. v
            local temp_port_power_info = require(str_read_power)
            for k1, v1 in pairs(temp_port_power_info) do
                main_cfg[k1] = v1
            end
        end
        return main_cfg
    end

    local mission = nil
    for k, v in pairs(mission_list) do
        if v.id == main_line_mission_id then
            mission = v
            break
        end
    end

    if not mission or mission.id ~= mission_cfg_item.main_mission_id then
        return port_power_info
    end
    
    local m_port_power_info = table.clone(port_power_info)

    for k, v in pairs(mission_cfg_item.other_mission_cfg) do
        local other_mission_id = v[MISSION_KEY]
        for mission_order, mission_progress in ipairs(mission.missionProgress) do
            if mission_progress.key == "complete_mission" and (other_mission_id == mission.mission_before[mission_order]) then
                if mission_progress.value >= mission.complete_sum[k] then
                    table.insert(branch_misssions, v[FINISH_MISSION_KEY])
                    desc_index = k
                end
            end
        end    
    end
    return getFinishCfg(m_port_power_info, branch_misssions)
end

--------------------进港弹出特效-------------------------

function PortData:showPowerChangeEffect()
    local port_id = self:getPortId()
    if port_id then
        local info = table.clone(self:isPortPowerDiff(port_id))
        if info then
            local info_c = table.clone(info)
            local dialogQuene = require("gameobj/quene/clsDialogQuene")
            local ClsPortPowerChangeEffectQuene = require("gameobj/quene/clsPortPowerChangeEffectQuene")
            dialogQuene:insertTaskToQuene(ClsPortPowerChangeEffectQuene.new(info_c))
            self:clearPortPowerDiff()
        end
        
    end
end



-------------------- 海域势力相关 -------------------------------------

return PortData
