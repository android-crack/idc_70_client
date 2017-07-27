-- 3d 场景相关

-- 不同3d场景的 id（名字）
SCENE_ID = {
	TEST = "testScene3d",
	ROLE = "roleScene3d",
	SHOP = "shopScene3d",
	BACKPACK = "backpackScene3d",
	BOAT_TIP = "baotTipsInfoScene3d",
	ELITE = "eliteBattleScene3d",
	BATTLE = "battleScene3d",
	EXPLORE = "exploreScene3d",
	PREVIEW = "previewScene3d",
	VIP = "vipCardScene3d",
	MISSION = "missionScene3d",
	BOAT_DONATE = "boatDonateScene3d",
	SHIP_EFFECT_UI = "shipEffectUI",
}


local ClsGame3d = class("ClsGame3d")

function ClsGame3d:init()
	self.is_init = true
	self.scene_tab = {}
	self.layer2d_tab = {}
	self.layer3d_tab = {}
	self.pause_count = 1
end 

function ClsGame3d:createScene(scene_id)
	if not self.is_init then 
		self:init()
	end 
	
	if self.scene_tab[scene_id] == nil then 
		local scene = Scene.create(scene_id)
		local root_node = scene:addNode("root3d")
		root_node:setLayer(0)
		-- 为了清缓冲区，解决渲染bug
		local layer2d = CCLayer3D:create(0)
		CCDirector:sharedDirector():getRunningScene():addChild(layer2d, -9999)
		self.scene_tab[scene_id] = scene
		self.layer2d_tab[scene_id] = {}
		self.layer3d_tab[scene_id] = {}
		self:resume()
	end 
	
	return self.scene_tab[scene_id]
end 

function ClsGame3d:getScene(scene_id)
	return self.scene_tab[scene_id]
end 

function ClsGame3d:pause()
	if self.pause_count == 0 then 
		CCPlatform3D:pause()
		ResourceManager:ClearCache()
	end 
	self.pause_count = self.pause_count + 1
end 

function ClsGame3d:resume()
	if self.pause_count == 1 then 
		CCPlatform3D:resume()
	end 
	self.pause_count = self.pause_count - 1
end 

function ClsGame3d:releaseScene(scene_id)
	if self.scene_tab[scene_id] then 
		self.scene_tab[scene_id]:removeAllNodes()
		self.scene_tab[scene_id] = nil
		self.layer2d_tab[scene_id] = nil
		self.layer3d_tab[scene_id] = nil
		collectgarbage("collect")
		collectgarbage("collect")
		self:pause()
	end 
end 

function ClsGame3d:releaseAllScenes()
	for k, v in pairs(self.scene_tab) do
		self:releaseScene(k)
	end 
	
	self.is_init = false
	self.scene_tab = nil
	self.pause_count = 1
end 

function ClsGame3d:getRootNode(scene_id)
	local scene = self.scene_tab[scene_id]
	if scene then 
		return scene:findNode("root3d", false)
	end 
end 

function ClsGame3d:getLayer3d(scene_id, layer_id)
	return self.layer3d_tab[scene_id][layer_id]
end 

function ClsGame3d:getLayer2d(scene_id, layer_id)
	return self.layer2d_tab[scene_id][layer_id]
end 

function ClsGame3d:createLayer(scene_id, layer_id, parent, zorder)
	local root_node = self:getRootNode(scene_id)
	if root_node == nil or tolua.isnull(parent) then
		return false
	end 
	
	local order = zorder or 0
	local layer2d = CCLayer3D:create(layer_id)
	layer2d:setSceneName(scene_id)
	parent:addChild(layer2d, order)
	
	local layer3d = Node.create()
	root_node:addChild(layer3d)	
	layer3d:setLayer(layer_id)
	
	self.layer2d_tab[scene_id][layer_id] = layer2d 
	self.layer3d_tab[scene_id][layer_id] = layer3d
end 

return ClsGame3d



