local error_info = require("game_config/error_info")
local Alert = require("ui/tools/alert")
local news=require("game_config/news")
local music_info=require("game_config/music_info")
local port_info=require("game_config/port/port_info")
local sailor_info = require("game_config/sailor/sailor_info")
local voice_info = getLangVoiceInfo()
local ui_word = require("game_config/ui_word")
local scheduler = CCDirector:sharedDirector():getScheduler()
--port

-- class port_info_t {
--          int invest;
--          int investStep;
--          int investSailor;
--          int firstEnterPort;
--          int status;
-- }
-- void rpc_client_port_main_info(int uid, port_info_t portInfo);
function rpc_client_port_main_info(info)
	local investData = getGameData():getInvestData()
	local portData = getGameData():getPortData()

	local data_struct_of_investData = {}
	data_struct_of_investData.portId = portData:getPortId()
	data_struct_of_investData.investStep = info.investStep
	investData:setPortInvestData(data_struct_of_investData)

    local portData = getGameData():getPortData()
	portData:receivePortInfo(info)

    ----进港显示海神奖励
    local sailor_id = getGameData():getActivityData():getSeagodRewardId()
	if sailor_id then

		getUIManager():create("gameobj/sailor/clsSailorWineRecruit", {}, sailor_id)
		getGameData():getActivityData():clearSeagodRewardId()
	end

	--[[local portId = portData:getPortId()
	for key, value in pairs(port_info) do
		if value.sea_area == port_info[portId].sea_area and key ~= portId then
			GameUtil.callRpc("rpc_server_port_sailor_list",  {key}, "rpc_client_port_sailor_list")
		end
	end]]
end

function rpc_client_all_port_invest_info(port_invest_info_t)
    local invest_data = getGameData():getInvestData()
    for k, info in pairs(port_invest_info_t) do
        invest_data:setPortInvestData(info)
    end
end

--投资奖励
function rpc_client_port_invest_reward(rewards)
	local invest_data = getGameData():getInvestData()
	invest_data:setInvestStepRewardData(rewards)
	-- 投资奖励
	-- Alert:showCommonReward(rewards)
end

--[[function  rpc_client_port_unlock_teacher(result,err)        --invest info
	if result==1 then
		portData:setTutorUnlock(1)
	else
		Alert:warning({msg =news.SAILOR_STUDY_TEACHER_UNLOCK.msg, size = 26})
	end
end]]
local alert_view_fun

-- 自动卸任通知
function rpc_client_port_unset_invest_sailor_tips(port_id, sailor_id, invest_step,new_sailor_id, new_port)
	local port_data = getGameData():getPortData()
	if port_data:isAlertSailorAppiont() then return end



	local port_layer = getUIManager():get("ClsPortLayer")
	if not tolua.isnull(port_layer) then --在港口
		if tolua.isnull(port_layer.portItem) then
			-- dialogSequence:insertDialogTable({fun = function ()
			-- 	port_data:alertSailorView(port_id, sailor_id, invest_step, new_sailor_id, new_port)
			-- end, dialogType = dialogType.un_appiont_alert})

		else
    		port_data:pushSailorAppiont(function()
    			port_data:alertSailorView(port_id, sailor_id, invest_step, new_sailor_id, new_port)
    		end)
		end

	else
    	port_data:pushSailorAppiont(function ( )
    		port_data:alertSailorView(port_id, sailor_id, invest_step, new_sailor_id, new_port)
    	end)

	end

end

function rpc_client_port_baowu(baowuId)

end

--[[function rpc_client_port_invest_share(result, errNo)
end]]

--[[	int portId;
	int baowuId;]]
--function rpc_client_black_market_info(list)
--	portData:receiveBlackMarketInfo(list)
--end

--[[--港口体力换取功能按钮
function  rpc_client_port_unlock(portId,result,error)
	portData:receiveOpenPortResult(portId,result,error)
end]]

--港口被占的协议
--rpc_server_checkpoint_occupied_ports()
function  rpc_client_checkpoint_occupied_ports(portList)
    local portData = getGameData():getPortData()
    portData:receiveOccupiedPorts(portList)
end

--任命水手
function rpc_client_port_set_invest_sailor(result, error, portId, sailorId)

	-- if result == 1 then
	-- 	local appoint_sailor = getUIManager():get("clsAppointSailorUI")
	-- 	if not tolua.isnull(appoint_sailor) then
	-- 		--myTransition:delLayer(appoint_sailor)
	-- 		appoint_sailor:close()
	-- 	end

	-- 	local port_info = require("game_config/port/port_info")
	-- 	local sailor_info = require("game_config/sailor/sailor_info")
	-- 	local str_msg = string.format(ui_word.PORT_INVEST_APPOINT_SUCCESS,
	-- 			sailor_info[sailorId].name, port_info[portId].name)
	-- 	Alert:warning({msg = str_msg, size = 26})
	-- 	local investData = getGameData():getInvestData()
	-- 	investData:sendPortInvest()
 --        investData:sendGetPortInvestSailor()
	-- else
	-- 	Alert:warning({msg = error_info[error].message, size = 26})
	-- 	local appoint_sailor = getUIManager():get("clsAppointSailorUI")
	-- 	if not tolua.isnull(appoint_sailor) then
	-- 		--appoint_sailor:setTouch(true)
	-- 	end
	-- end
end

--卸任水手
function rpc_client_port_unset_invest_sailor(result, error, portId, sailorId)
	-- if result == 1 then

	-- 	local port_info = require("game_config/port/port_info")
	-- 	local sailor_info = require("game_config/sailor/sailor_info")
	-- 	local str_msg = string.format(ui_word.PORT_INVEST_DEPARTURE_SUCCESS,
	-- 			port_info[portId].name, sailor_info[sailorId].name)
	-- 	Alert:warning({msg = str_msg, size = 26})
	-- 	local appoint_sailor = getUIManager():get("clsAppointSailorUI")
	-- 	if not tolua.isnull(appoint_sailor) then
	-- 		appoint_sailor:updateUI()
	-- 	end

	--     if getUIManager():isLive("ClsSailorListView") then
	--         getUIManager():get("ClsSailorListView"):updateList()
	--     end

	-- 	local investData = getGameData():getInvestData()
 --        investData:sendGetPortInvestSailor()
	-- 	if portId == investData:getInvestPortId() then
	-- 		investData:sendPortInvest()
	-- 	else
	-- 		local new_port_id = investData:getInvestPortId()
	-- 		investData:setInvestPortId(portId)
	-- 		investData:sendPortInvest()
	-- 		investData:setInvestPortId(new_port_id)
	-- 		investData:sendPortInvest()
	-- 	end
	-- else
	-- 	Alert:warning({msg = error_info[error].message, size = 26})
	-- 	local appoint_sailor = getUIManager():get("clsAppointSailorUI")
	-- 	if not tolua.isnull(appoint_sailor) then
	-- 		--appoint_sailor:setTouch(true)
	-- 	end
	-- 	-- local PortTownUI = element_mgr:get_element("PortTownUI")
	-- 	-- if not tolua.isnull(PortTownUI) then
	-- 	-- 	PortTownUI:setTouch(true)
	-- 	-- end
	-- end
end

--[[
@api
	请求港口投资信息返回
	将对UI的操作抽到这边来,数据模块单纯操作数据,尽量避免其他操作
]]
function rpc_client_port_invest_info(data)
	-- 处理数据
	local investData = getGameData():getInvestData()
	investData:setPortInvestData(data)

	-- todo
	-- 刷新市政厅界面数据
	-- 刷新探索地图数据 -- 等照光同学重构探索地图再加上
	local check_target_list = {
		"clsPortTownUI",
		-- "",
	}
	for k,v in pairs(check_target_list) do
		local target_ui = nil
		local is_exist = false
		target_ui = getUIManager():get(v)
		is_exist = not tolua.isnull(target_ui)
		if is_exist then
			target_ui:getTab(1):tryToUpdateUI()
		end
	end

	-- 刷新港口面板
	local explore_map = getUIManager():get("ExploreMap") or getUIManager():get("PortMap")
	if not tolua.isnull(explore_map) then
		local exploreMapData = getGameData():getExploreMapData()
		local cur_select_point_info = exploreMapData:getCurSelectPointInfo()
		if cur_select_point_info then
			explore_map:selectPoint(cur_select_point_info.id, cur_select_point_info.navType)
		else
			explore_map:selectPoint(data.portId, EXPLORE_NAV_TYPE_PORT)
		end
		explore_map:updatePoint(data.portId, EXPLORE_NAV_TYPE_PORT)
	end

end

--快捷弹框，道具或投资奖励
--[[
class win_info_t {
	// 弹窗类型
	int type;
	// 投资奖励为港口id，船为船key，宝物为0，道具为道具id
	int id;
	// 投资奖励为空，船为空，宝物为宝物key，道具为空
	string key;
	// 投资奖励为step，船为数量，宝物为数量，道具为数量
	int amount;
}
--]]
function rpc_client_pop_window(info)
	local portData = getGameData():getPortData()
    portData:receivePopWindow(info)
    local port_layer = getUIManager():get("ClsPortLayer")
    if not tolua.isnull(port_layer) then
        port_layer:updateItemTips()
    end
end

function rpc_client_partner_auto_upload_boat(boat_key, old_power, new_power, err)
	if err ~= 0 then
		Alert:warning({msg = error_info[err].message, size = 26})
		return
	end

	local DialogQuene = require("gameobj/quene/clsDialogQuene")
	--local clsBattlePower = require("gameobj/quene/clsBattlePower")
	--DialogQuene:insertTaskToQuene(clsBattlePower.new({newPower = new_power,oldPower = old_power}))
end

function rpc_client_partner_auto_upload_baowu(baowu_key, old_power, new_power, err)
	if err ~= 0 then
		Alert:warning({msg = error_info[err].message, size = 26})
		return
	end

	local DialogQuene = require("gameobj/quene/clsDialogQuene")
	--local clsBattlePower = require("gameobj/quene/clsBattlePower")
	--DialogQuene:insertTaskToQuene(clsBattlePower.new({newPower = new_power,oldPower = old_power}))
end

function rpc_client_port_invest_sailor_amount(sailor_nums)
    local investData = getGameData():getInvestData()
    investData:setInvestSailors(sailor_nums)
end

function rpc_client_close_window()
	local portData = getGameData():getPortData()
	portData:clearPopWindow()
    local port_layer = getUIManager():get("ClsPortLayer")
    if not tolua.isnull(port_layer) then
        port_layer:setPopDisappear()
    end
end

--功能预开放
function rpc_client_feature_tip_current(current_id)
	
	local config = require("game_config/mission/feature_tip")
	if not config[current_id] then return end
	local portData = getGameData():getPortData()
    portData:receiveFeatureId(current_id)

    local port_layer = getUIManager():get("ClsPortLayer")
    if not tolua.isnull(port_layer) then
	    if current_id == 0 then
		    port_layer:closeFeatureTips(current_id)
		else
			port_layer:showFuncTips()
	    end
    end
end
--[[
[S->C][rpc_client_port_invest{ ['1']=2,['2']=0,['3']=702,} ]
]]
function rpc_client_port_invest(port_id,result_code)
	if result_code ~= 0 then
		Alert:warning({msg = error_info[result_code].message, size = 26})
	else
		local check_target_list = {
			"clsPortTownUI",
			-- "",
		}
		for k,v in pairs(check_target_list) do
			local target_ui = nil
			local is_exist = false
			target_ui = getUIManager():get(v)
			is_exist = not tolua.isnull(target_ui)
			if is_exist then
				target_ui:getTab(1):setIsGoLvUpEffect(true)
			end
		end
	end
end
