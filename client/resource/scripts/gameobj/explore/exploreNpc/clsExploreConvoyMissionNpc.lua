-- @author: mid
-- @date: 2016年12月2日17:26:16
-- @desc: 运镖NPC

-- include
local cfg = require("game_config/loot/time_plunder_info")
local explore_npc_base  = require("gameobj/explore/exploreNpc/exploreNpcBase")
local explore_npc_type = require("gameobj/explore/exploreNpc/exploreNpcType")
local npc_type = explore_npc_type.CONVOY_MISSION
local npc_id = explore_npc_type.NPC_CUSTOM_ID[npc_type]

-- const
local CREATE_DIS2       = 1000*1000 -- 创建npc模型的距离
local HIT_DIS2          = 120*120
local REMOVE_DIS2       = 1000*1000 -- 移除npc模型的距离
local TOUCH_ENABLE_DIS2 = 120*120 -- 可点击模型按钮的距离
local CHECK_INTERVIL    = 10 -- 隔帧检测 间隔帧数

-- define
local clsExploreConvoyMissionNpc = class("clsExploreConvoyMissionNpc", explore_npc_base)

-- override
function clsExploreConvoyMissionNpc:initNpc(data)
	data = data.attr
	-- print(" --------------- initNpc data --------------- ")
	-- table.print(data)
	self:resetData()
	self.data = data
	self.click_callback = data.callback
	self.tile_id_pos_table = data.pos_table
	self.cocos_pos_table = self:getCocosPos(data.pos_table) -- 计算方法是固定的,先计算缓存着
end

function clsExploreConvoyMissionNpc:removeNpcFromLayer()
	getGameData():getExploreNpcData():removeNpc(npc_id)
end

function clsExploreConvoyMissionNpc:release()
	self:removeModel()
end

function clsExploreConvoyMissionNpc:touch()
	self.click_callback(self.mission_id)
	return true
end

function clsExploreConvoyMissionNpc:update(dt)

	if self.frame_counter < CHECK_INTERVIL then
		self.frame_counter = self.frame_counter + 1
		return
	end
	self.frame_counter = 0
	local ship_x,ship_y = self:getPlayerShipPos()
	local cocos_pos_table = self.cocos_pos_table
	if self.is_create_model then
		local model_cur_pos = cocos_pos_table[self.mission_id]
		local dis2 = self:getDistance2(model_cur_pos.x,model_cur_pos.y,ship_x,ship_y)
		if dis2 > REMOVE_DIS2 then
			self:removeModel()
		end
		self.is_can_touch = dis2 <TOUCH_ENABLE_DIS2
	else
		for k,v in pairs(cocos_pos_table) do
			local dis2 = self:getDistance2(v.x , v.y, ship_x, ship_y)
			if dis2 < CREATE_DIS2 then
				self:createModelAndIcon(k)
				break
			end
		end
	end
end

-- logic

-- 转化npc的格子坐标(从配置表读取)为探索地图中的cocos坐标
function clsExploreConvoyMissionNpc:getCocosPos(tilePosTable)
	local table = {}
	local util_module = self.m_explore_layer:getLand()
	for k,v in pairs(tilePosTable) do
		table[k] = util_module:cocosToTile2({x=v[1],y=v[2]})
	end
	return table
end

function clsExploreConvoyMissionNpc:resetData()

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
function clsExploreConvoyMissionNpc:removeModel()
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
function clsExploreConvoyMissionNpc:createModelAndIcon(id)
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
function clsExploreConvoyMissionNpc:changeMapType(isAchievable,id)
	local map_type = isAchievable and MAP_SEA or MAP_LAND
	local pos = self.tile_id_pos_table[id]
	if pos then
		-- 不要阻挡了
		-- self.m_explore_layer:getLand():changeMapType(pos[1]-1,pos[2]-1,3,3,map_type)
	end
end

-- 创建模型
function clsExploreConvoyMissionNpc:createModelById(id)
	local cm_item = cfg[id]
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
	local pos = self.cocos_pos_table[id]
	model:setPos(pos.x,pos.y)
	model.node:setTag("exploreNpcLayer", string.format("%d", npc_id))
	self.model = model
	return model
end

-- 创建按钮
function clsExploreConvoyMissionNpc:createBtn()
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

return clsExploreConvoyMissionNpc
