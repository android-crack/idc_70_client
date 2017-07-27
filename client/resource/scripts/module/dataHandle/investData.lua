local news=require("game_config/news")
local tool=require("module/dataHandle/dataTools")
local goods_info=require("game_config/port/goods_info")
local tips = require("game_config/tips")
local Alert = require("ui/tools/alert")
local portButtonEffect = require("gameobj/port/portButtonEffect")
local port_locks=require("game_config/port/port_lock")
local prosper_stage=require("game_config/prosper/prosper_stage")
local port_reward_info = require("game_config/port/port_reward_info")
local item_info = require("game_config/propItem/item_info")
local sailor_info = require("game_config/sailor/sailor_info")
local equip_material_info = require("game_config/boat/equip_material_info")
local ui_word = require("game_config/ui_word")

local InvestData=class("InvestData")

function InvestData:ctor()
	self.invest = nil
	self.step = nil
	self.buildLock = true
	self.rewards = nil --投资奖励信息
	self.port_id = nil
	self.is_send_all_port = false --是否请求过全部港口信息
	self.m_list = {} --存放港口的投资信息列表
	self.investSailors = 0 --已经任命了多少个水手到港口中
end
--[[
@api
	处理服务器返回的投资信息
	返回一个参数data 结构如下
	----
	data
		port_info_t
			portId
			investStep
	----
]]
function InvestData:setPortInvestData(data)

	-- 解析字段
	local portId = data.portId
	local investStep = data.investStep

	self.step = investStep
	-- print(portId)
	-- print(investStep)
	-- print(self.m_list)

	-- 存放投资信息
	local item = {}
	item.portId = portId
	item.investStep = investStep
	self.m_list[item.portId] = item

	-- 更新相关市场数据
	local marketData = getGameData():getMarketData()
	marketData:setLockGoods(portId,investStep)
end

function InvestData:isUnlock()
	return self.buildLock
end

function InvestData:getInvest()
	return self.invest
end

function InvestData:getStep()
	return self.step
end

function InvestData:getPortLocks()
	local portData = getGameData():getPortData()
	return tool:getPortLocks(portData:getPortId())
end

function InvestData:getInvestSailor()
	return self.investSailor
end

function InvestData:setInvestSailors(num)
	self.investSailors = num
end

function InvestData:getInvestSailors()
	return self.investSailors or 0
end

function InvestData:setInvestStepRewardData(rewards)
	self.rewards = rewards

	-- --港口快捷弹框存在，则有动画
	-- local portData = getGameData():getPortData()
	-- local has_pop_win = portData:hasPopWindow()
	-- if has_pop_win then
	-- 	local port_layer = getUIManager():get("ClsPortLayer")
	-- 	if not tolua.isnull(port_layer) then
	-- 		Alert:showCommonReward(rewards)
	-- 	end
	-- end
end

function InvestData:getInvestStepRewardData()
	return self.rewards
end

function InvestData:getSailorExpStep()
	return self.sailorExpStep
end

function InvestData:getInvestDataByPortId(port_id)
	return self.m_list[port_id]
end

function InvestData:setInvestPortId(port_id)
	self.port_id = port_id
end

-- function InvestData:getInvestPortId()
-- 	return self.port_id
-- end

--根据港口ID和投资阶段，获取该港口的奖励资源信息
function InvestData:getReward(port_id, step)
	local is_lock_goods = 0
	local reward_res = ""
	local lock = port_locks[port_id][step].lock
	local sailor_star = 0
	local is_item = false
	if lock then
		is_lock_goods = 1
		reward_res = goods_info[lock.id].res
	else
		local key = string.format(" %d_%d", port_id, step)
		local reward_data = port_reward_info[key]
		local r_type = reward_data.type
		if r_type == "item" then
			reward_res = item_info[reward_data.id].res
			sailor_star = item_info[reward_data.id].quality
			is_item = true
		elseif r_type == "sailor" then
			reward_res = sailor_info[reward_data.id].res
			sailor_star = sailor_info[reward_data.id].star
		elseif r_type == "material" then
			reward_res = equip_material_info[reward_data.id].res
			is_item = true
		elseif r_type == "honour" then
			reward_res = "#common_icon_honour.png"
			is_item = true
		end
	end

	return is_lock_goods, reward_res, sailor_star,is_item
end

--根据港口ID和投资阶段，获取该港口的奖励资源信息
function InvestData:getPortReward(port_id, step)
	local is_lock_goods = 0
	local reward_res = ""
	local item_type = ""
	local item_name = ""
	local lock = port_locks[port_id][step].lock
	local sailor_star = 0
	if lock then
		is_lock_goods = 1
		item_type = ui_word.PORT_INVEST_TYPE_GOODS
		item_name = goods_info[lock.id].name
	else
		local key = string.format(" %d_%d", port_id, step)
		local reward_data = port_reward_info[key]
		local r_type = reward_data.type
		if r_type == "item" then
			item_type = ui_word.PORT_INVEST_TYPE_ITEM
			item_name = item_info[reward_data.id].name
		elseif r_type == "sailor" then
			item_type = ui_word.PORT_INVEST_TYPE_SAILOR
			item_name = sailor_info[reward_data.id].name
		elseif r_type == "material" then
			item_type = ui_word.PORT_INVEST_TYPE_MATERIAL
			item_name = equip_material_info[reward_data.id].name
		elseif r_type == "honour" then
			item_type = ""
			item_name = ui_word.PORT_HONOR
		end
	end

	return item_type , item_name
end

function InvestData:isSendAllPort()
	return self.is_send_all_port
end


---------------------------------------------- 协议请求 ---------------------------------------------------

function InvestData:sendAllPortInvestInfo()
	self.is_send_all_port = true
	GameUtil.callRpc("rpc_server_all_port_invest_info")
end

--任命水手在市政厅
function InvestData:sendSetAppointSailor(sailor_id)
	GameUtil.callRpc("rpc_server_port_set_invest_sailor", {self.port_id, sailor_id}, "rpc_client_port_set_invest_sailor")
end

--卸任命水手在市政厅
function InvestData:sendUnsetAppointSailor(sailor_id)
	GameUtil.callRpc("rpc_server_port_unset_invest_sailor", {sailor_id}, "rpc_client_port_unset_invest_sailor")
end

function InvestData:sendPortInvest(port_id)
	port_id = port_id or self.port_id
	GameUtil.callRpc("rpc_server_port_invest_info", {port_id})
end

function InvestData:sendGetPortInvestSailor()
	-- GameUtil.callRpc("rpc_server_port_invest_sailor_amount", {})
end
--[[
@api
	请求提升投资级别协议
]]
function InvestData:requestLevelUpInvest(port_id)
	-- rpc_server_port_invest
	GameUtil.callRpc("rpc_server_port_invest", {port_id})
end

---------------------------------------------- 协议请求 ---------------------------------------------------

return InvestData
