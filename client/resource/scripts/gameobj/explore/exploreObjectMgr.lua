--探索视野管理器
local ExploreObjectMgr = class("ExploreObjectMgr")

local single_instance = nil

function ExploreObjectMgr:ctor()
	self.is_pause = false
	self.object_dic = {}
end 

function ExploreObjectMgr:update(dt)  --刷新
	local exploreLayer = getUIManager():get("ExploreLayer")
	if is_pause then return end 
	-- if tolua.isnull(exploreLayer) then
		-- return
	-- end
	-- if not exploreLayer.player_ship then
		-- return
	-- end
	local px, py = exploreLayer.player_ship:getPos()
	local cur_distance = 0
	
	for k,v in pairs(self.object_dic) do
		if v:isActive() or v:isWillActive() then
			cur_distance = Math.distance(px, py, v.pos.x, v.pos.y) 
			if not v:isInField()then
				if cur_distance <= v:getInFieldDistance() and v:canInField(cur_distance) then
					v:onInField()
				end
			else
				if cur_distance >= v:getOutFieldDistance() and v:canOutField(cur_distance) then
					v:onOutField()
				elseif v:canUpdate() then
					v:onUpdate(dt)
				end
			end
		end
	end 
end

function ExploreObjectMgr:addExploreObject(object)
	if not object or not object.key then return end
	object:setDeadCallBack(function(key)
		self:removeExploreObject(key)
	end)
	self.object_dic[object.key] = object
end

function ExploreObjectMgr:removeExploreObject(key)
	if not key then return end
	self.object_dic[key] = nil
end

function ExploreObjectMgr:setPause(is_pause)
	self.is_pause = is_pause

	for k,v in pairs(self.object_dic) do
		if v:isActive() then
			v:setPause(is_pause)
		end
	end
end

function ExploreObjectMgr:clear()
	self.is_pause = true
	self.object_dic = {}
end

--------------------

function ExploreObjectMgr.getInstance()
	if not single_instance then
		single_instance = ExploreObjectMgr.new()
	end
	return single_instance
end 

function ExploreObjectMgr.pure()
	if single_instance then
		single_instance:clear()
	end
	single_instance = nil
end

return ExploreObjectMgr