-- u3d scene 解析

local animationParse = require("gameobj/u3d/u3dAnimationParse")
local u3dObjectCreator = require("gameobj/u3d/u3dObjectCreator")
local SceneEffect = require("gameobj/battle/sceneEffect")
local game3d = require("game3d")
--local ClsSea3d = require("gameobj/sea3d")

local ClsU3dSceneParse = class("ClsU3dSceneParse")

local SEA_ORDER = 0
local SHIP_ORDER = 1
local UI_ORDER = 2

function ClsU3dSceneParse:ctor(cocos_parent, scene_cfg, scene_id)
	self.m_cocos_parent = cocos_parent
	self.m_scene_cfg = scene_cfg
	self.m_node3d_tab = {}
	self.m_scene_ui = nil
	self.m_scene_id = scene_id or SCENE_ID.ROLE
	self:init3d()
	self:init2d()
	self:parse()
end 

function ClsU3dSceneParse:init3d()
	local scene_id = self.m_scene_id
	local layer_sea_id = 0
	local layer_ship_id = 1

	-- scene
	game3d:createScene(scene_id)
	-- layerSea
	game3d:createLayer(scene_id, layer_sea_id, self.m_cocos_parent, SEA_ORDER)

	-- layerShip
	game3d:createLayer(scene_id, layer_ship_id, self.m_cocos_parent, SHIP_ORDER)

	self.m_layer3d_sea = game3d:getLayer3d(scene_id, layer_sea_id)
	self.m_layer3d_ship = game3d:getLayer3d(scene_id, layer_ship_id)
end 

function ClsU3dSceneParse:clickObject(x, y)
	local viewport = Game.getInstance():getViewport()
	x = viewport:width()  / (display.cx * 2) * x
	y = viewport:height() / (display.cy * 2) * y
	y = y + viewport:y()
	x = x + viewport:x()
	y = display.heightInPixels - y

	local scene3d = game3d:getScene(self.m_scene_id)
	local ray = Ray.new()
	scene3d:getActiveCamera():pickRay(viewport, x, y, ray)
	local distance = ray:intersects(Plane.new(0, 1, 0, 0))
	if distance ~= Ray.INTERSECTS_NONE() then
		local result = PhysicsController.HitResult.new()
		if Game.getInstance():getPhysicsController():rayTest(ray, distance, result) then 
			return result:object():getNode()
		end 
	end 
end

function ClsU3dSceneParse:createSea3d()
	local sea = ClsSea3d.new("res/sea_3d/loginSea.conf", Vector3.new(-9, 8.231198, -15.7))
	-- local sea = ClsSea3d.new("res/sea_3d/loginSea.conf", Vector3.new(0, 8.231198, 0))
	self.m_sea_node = sea.node
	self.m_layer3d_ship:addChild(self.m_sea_node)
	self.m_sea_node:getSea():setUnlimit(true)
end

function ClsU3dSceneParse:init2d()
	self.m_scene_ui = display.newLayer()
	self.m_cocos_parent:addChild(self.m_scene_ui, UI_ORDER)
end

--自己写拷贝函数，防止不想拷的也拷出去，顺便也可以优化下性能
local function copyParams(params)
	local new_params = {}
	new_params.node_path_str = params.node_path_str
	new_params.root_anim_cfg = params.root_anim_cfg
	return new_params
end

function ClsU3dSceneParse:parse()
	local parseObject
	parseObject = function(data, parent, params)
		
		--判定是否是我们封装的节点
		local parent_node = parent
		local is_add_node_record = false
		if parent.getNode and "function" == type(parent.getNode) and 
			parent.addChildNode and "function" == type(parent.addChildNode) then
			parent_node = parent:getNode()
			is_add_node_record = true
		end 
		
		for key ,value in pairs(data) do
			local node = nil 
			local node_params = copyParams(params)
			local creator_func = u3dObjectCreator[value.type]
			if type(creator_func) == "function" then
				if value.animations then
					node_params.root_anim_cfg = value.animations[1]  --暂时支持根对象动画一个
					node_params.node_path_str = "root"
				else
					if node_params.node_path_str then
						node_params.node_path_str = string.format("%s/%s", node_params.node_path_str, tostring(key))
					else --如果不存在节点路径，可以认为是根节点
						node_params.node_path_str = "root"
					end
				end
				print("create---------------------"..key)
				
				node = creator_func(self, parent_node, key, value, node_params)
			else
				print("miss parse type-------------->", tostring(key), tostring(value.type))
			end
			
			if not node then return end 
			
			if is_add_node_record then
				parent:addChildNode(key, node)
			end
			
			local link_particles = value.link_particle or {}
			for k, v in ipairs(link_particles) do
				local particle_parent = node:getTrueModelNode()
				if particle_parent then
					particle_parent = particle_parent:findNode(v.parent_name)
					if particle_parent then
						print("create---------------------"..v.name)
						local params = copyParams(node_params)
						params.follow_node = particle_parent
						self.m_node3d_tab[v.name] = u3dObjectCreator.particleSystem(self, node:getTrueModelNode(), v.name, v, params)
					end
				end
			end
			
			-- 递归孩子
			self.m_node3d_tab[key] = node
			if value.children then 
				if node.getNode and "function" == type(node.getNode) then
					parseObject(value.children, node, copyParams(node_params))
				else
					parseObject(value.children, node, copyParams(node_params))
				end
			end
		end 
	end 

	self.m_node3d_tab = {}
	parseObject(self.m_scene_cfg, self.m_layer3d_ship, {node_path_str = nil})
end

------------------下面为get, set方法
-- 获取名字为name的node
function ClsU3dSceneParse:getNodeByName(name)
	return self.m_node3d_tab[name]
end

function ClsU3dSceneParse:getSceneUi()
	return self.m_scene_ui
end

function ClsU3dSceneParse:getScene()
	return game3d:getScene(self.m_scene_id)
end 

function ClsU3dSceneParse:release()
	self.m_layer3d_ship = nil
	self.m_layer3d_sea = nil
	if self.m_node3d_tab then
		for k, v in pairs(self.m_node3d_tab) do
			v:release()
		end
	end
	self.m_node3d_tab = nil
	self.m_cocos_parent = nil
	self.m_sea_node = nil
	game3d:releaseScene(self.m_scene_id)
	
end 

return ClsU3dSceneParse