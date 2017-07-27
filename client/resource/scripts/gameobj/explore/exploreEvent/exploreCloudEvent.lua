--2016/06/20
--create by wmh0497
--云

local ClsExploreEventBase = require("gameobj/explore/exploreEvent/exploreEventBase")
local ClsCommonBase = require("gameobj/commonFuns")
local music_info = require("game_config/music_info")
local explore_event = require("game_config/explore/explore_event")
local explore_skill = require("game_config/explore/explore_skill")

local CloudSp = class("CloudSp", function(res) return display.newSprite(res) end)

function CloudSp:ctor(res)
    self.m_is_runing = false
end

function CloudSp:setMoveInfo(move_time, move_speed, begin_pos, end_pos, end_callback)
    self.m_move_time = move_time
    self.m_end_pos = end_pos
    self.m_move_speed = move_speed
    self.m_begin_pos = begin_pos
    self.m_end_callback = end_callback
end

function CloudSp:getBeginPos()
    return self.m_begin_pos
end

function CloudSp:begin()
    if self.m_is_runing==true then
        return
    end
    self.m_is_runing = true
    
    local cam = getExploreLayer():getCamera()
    local ex, ey, ez = cam:getEyeXYZ(0,0,0)
    
    self:setPosition(self.m_begin_pos.x + ex, self.m_begin_pos.y + ey)

    local array = CCArray:create()
    array:addObject(CCMoveTo:create(self.m_move_time, ccp(self.m_end_pos.x + ex, self.m_end_pos.y + ey)))
    array:addObject(CCFadeOut:create(0.5))
    array:addObject(CCCallFunc:create(function()
        if self.m_end_callback then
            self.m_end_callback()
        end
    end))
    self:runAction(CCSequence:create(array))
end

local cloud_record = {}
local ClsExploreCloudEvent = class("ClsExploreCloudEvent", ClsExploreEventBase)

function ClsExploreCloudEvent:clearCloudRecord()
    cloud_record = {}
end

function ClsExploreCloudEvent:initEvent(event_date)
    self.m_event_data = event_date
    local event_config_item = explore_event[self.m_event_data.evType]
    self.m_event_config_item = event_config_item
    self.m_event_type = event_config_item.event_type
    self.m_is_release = false
    self.m_cloud_spr = nil
    self:createCloudSpr()
end

function ClsExploreCloudEvent:createCloudSpr()
	local cloudSp = CloudSp.new("explorer/explore_yun"..Math.random(2)..".png")
	local begin_pos = ccp(0,0)
	local end_pos = ccp(0,0)
	local move_speed = 20 + Math.random(30)
	if self.m_event_data.createPos then
		local cam = getExploreLayer():getCamera()
		local ex, ey, ez = cam:getEyeXYZ(0,0,0)
		begin_pos.x = self.m_event_data.createPos.x - ex
		begin_pos.y = self.m_event_data.createPos.y - ey
		end_pos.x = display.cx
		end_pos.y = display.cy
	else
		local w, h = display.width,display.height
		local cloudYs = {}
		for k, v in pairs(cloud_record) do
			if not tolua.isnull(v) then
				local cloudY1 = {["y1"]=0,["y2"]=h}
				local cloudY2 = {["y1"]=0,["y2"]=h}

				cloudY1["y2"] = v:getBeginPos().y - v:getContentSize().height/2 - cloudSp:getContentSize().height/2
				cloudY2["y1"] = v:getBeginPos().y + v:getContentSize().height/2 + cloudSp:getContentSize().height/2
				if cloudY1["y2"]<0 then
					cloudY1["y2"] = 0
				end
				if cloudY2["y1"]>h then
					cloudY2["y1"] = h
				end
				if cloudY1["y1"]~=cloudY1["y2"] then
					cloudYs[#cloudYs+1] = cloudY1
				end
				if cloudY2["y1"]~=cloudY2["y2"] then
					cloudYs[#cloudYs+1] = cloudY2
				end
				break
			end
		end

		local sp_w = cloudSp:getContentSize().width
		begin_pos.x = w + sp_w/2+5
		if #cloudYs>0 then
			local cloudY = cloudYs[Math.random(1,#cloudYs)]
			begin_pos.y = cloudY["y1"] + (cloudY["y2"]-cloudY["y1"])/10*Math.random(10) --防止数字过大导致随机失败
		else
			begin_pos.y = Math.random(h)
		end
		end_pos.x = -sp_w/2-Math.random(w)
		end_pos.y = end_pos.y
	end
	
    local move_time = Math.abs(end_pos.x - begin_pos.x)/move_speed
    if not tolua.isnull(self.m_ships_layer) then
        cloudSp:setMoveInfo(move_time, move_speed, begin_pos, end_pos, function()
                self:removeCloudSpr()
                self:sendRemoveEvent(self.m_success_flag)
            end)
        self.m_ships_layer:addChild(cloudSp)
        cloudSp:begin()
        table.insert(cloud_record, cloudSp)
    end
    self.m_cloud_spr = cloudSp
end

function ClsExploreCloudEvent:removeCloudSpr()
    if not tolua.isnull(self.m_cloud_spr) then
        for k, v in pairs(cloud_record) do
            if v == self.m_cloud_spr then
                table.remove(cloud_record, k)
                break
            end
        end
        self.m_cloud_spr:removeFromParentAndCleanup(true)
        self.m_cloud_spr = nil
    end
end

function ClsExploreCloudEvent:release()
    if self.m_is_release then
        return
    end
    self.m_is_release = true
    self:removeCloudSpr()
end

return ClsExploreCloudEvent