-- @author: mid
-- @date: 2016年10月21日14:37:09
-- @desc: 随机任务NPC

-- include
local cfg = require("game_config/world_mission/world_mission_info")
local twm_cfg = require("game_config/world_mission/world_mission_team")
local explore_npc_base  = require("gameobj/explore/exploreNpc/exploreNpcBase")
local explore_npc_type = require("gameobj/explore/exploreNpc/exploreNpcType")
local npc_type = explore_npc_type.WORLD_MISSION
local npc_id = explore_npc_type.NPC_CUSTOM_ID[npc_type]


local CHECK_INTERVIL = 10 -- 隔帧检测 间隔帧数
local CREATE_DIS2 = 1000*1000
local REMOVE_DIS2 = 1000*1000
local STOP_DIS2 = 120*120
local TOUCH_ENABLE_DIS2 = 120*120

local clsExploreWorldMissionNpc = class("clsExploreWorldMissionNpc", explore_npc_base)

-- override
function clsExploreWorldMissionNpc:initNpc(data)
	data = data.attr
	self:resetData()
	self.data = data
	self.click_callback = data.callback
	self.tile_id_pos_table = data.id_pos_table
	self.id_pos_table = self:getCocosPos(data.id_pos_table) -- 计算方法是固定的,先计算缓存着
end

function clsExploreWorldMissionNpc:removeNpcFromLayer()
	getGameData():getExploreNpcData():removeNpc(npc_id)
end

function clsExploreWorldMissionNpc:release()
	self:removeModel()
end

function clsExploreWorldMissionNpc:touch()
	self.click_callback(self.mission_id)
	return true
end

function clsExploreWorldMissionNpc:update(dt)
	-- 隔帧检测
	if self.frame_counter < CHECK_INTERVIL then
		self.frame_counter = self.frame_counter + 1
		return
	end
	self.frame_counter = 0
	-- local ship_x,ship_y = self.ship:getPos()
	local ship_x,ship_y = self:getPlayerShipPos()
	local id_pos_table = self.id_pos_table
	-- 如果已经创建
	if self.is_create_model and self.mission_id then
		local model_cur_pos = id_pos_table[self.mission_id]
		local dis2 = self:getDistance2(model_cur_pos.x,model_cur_pos.y,ship_x,ship_y)
		-- 距离太远移除模型
		if dis2 > REMOVE_DIS2 then
			self:removeModel()
		end
		-- 点击属性
		self.is_can_touch = dis2 < TOUCH_ENABLE_DIS2
	else
		-- 检测是否要创建
		for k,v in pairs(id_pos_table) do
			local dis2 = self:getDistance2(v.x , v.y, ship_x, ship_y)
			-- 距离够近创建模型
			if dis2 < CREATE_DIS2 then
				self:createModelAndIcon(k)
				break -- 只创建一个 跳出循环
			end
		end
	end
end

-- logic

-- 转化npc的格子坐标(从配置表读取)为探索地图中的cocos坐标
function clsExploreWorldMissionNpc:getCocosPos(tilePosTable)
	local table = {}
	local util_module = self.m_explore_layer:getLand()
	for k,v in pairs(tilePosTable) do
		table[k] = util_module:cocosToTile2({x=v[1],y=v[2]})
	end
	return table
end

function clsExploreWorldMissionNpc:resetData()

	self.data = nil
	self.click_callback = nil
	self.cocos_pos_table = {}

	self.model = nil
	self.btn = nil
	self.mission_id = nil
	self.frame_counter = 0
	self.is_create_model = false
	self.is_can_touch = false
end

-- 移除npc
function clsExploreWorldMissionNpc:removeModel()
	if self.model then
		self.model:release()
	end
	self:changeMapType(true,self.mission_id)
	self.model = nil
	self.btn = nil
	self.mission_id = nil
	self.frame_counter = 0
	self.is_create_model = false
end

-- 创建模型和图标
function clsExploreWorldMissionNpc:createModelAndIcon(id)
	if self.is_create_model then
		self:removeModel()
	end
	self.mission_id = id
	self:changeMapType(false,id)
	self:createModelById(id)
	self:createBtn()
	self.is_create_model = true
end

-- 修改该模型对应的地图块的寻路属性
function clsExploreWorldMissionNpc:changeMapType(isAchievable,id)
	local map_type = isAchievable and MAP_SEA or MAP_LAND
	local pos = self.tile_id_pos_table[id]
	if pos then
		-- self.m_explore_layer:getLand():changeMapType(pos[1]-1,pos[2]-1,3,3,map_type)
		-- self.m_explore_layer:getLand():changeMapType(pos[1],pos[2],1,1,map_type)
	end
end

-- 创建模型
function clsExploreWorldMissionNpc:createModelById(id)
	local cm_item = cfg[id] or twm_cfg[id]
	local res, animation_res, water_res, sea_level, hit_radius
	res = "bt_base_001"
	animation_res = {"move"}
	water_res = {"meshwave00"}
	sea_level = 0
	hit_radius = 80
	local model_item = require("game_config/model_info")[cm_item.model_res]
	if model_item then
		res = cm_item.model_res
	end
	local data = {}
	data.res = res
	data.animation_res = animation_res
	data.water_res = water_res
	data.sea_level = sea_level
	data.hit_radius = hit_radius
	local model = require("gameobj/explore/exploreProp").new(data)
	local pos = self.id_pos_table[id]
	model:setPos(pos.x,pos.y)
	model.node:setTag("exploreNpcLayer",string.format("%d",npc_id))
	self.model = model
	return model
end

-- 创建按钮
function clsExploreWorldMissionNpc:createBtn()
	local model = self.model
	local mission_id = self.mission_id
	if not model or not mission_id then return end

	local model_height = model.node:getBoundingSphere():radius()

	local btn = getUIManager():get("ExploreLayer"):createButton({image = "#common_btn_help2.png"},100)
	btn:setTouchEnabled(true)
	btn:setPositionY(model_height+25)
	btn:setScale(0.7)
	btn:regCallBack(function()
		self.click_callback(mission_id)
	end)

	self.btn = btn
	model.ui:addChild(btn)
end

return clsExploreWorldMissionNpc


