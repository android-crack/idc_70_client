--2016/07/13
--create by wmh0497
--任务添加的npc
local ClsExploreNpcBase  = require("gameobj/explore/exploreNpc/exploreNpcBase")
local ClsExploreShip3d = require("gameobj/explore/exploreShip3d")
local ClsAlert = require("ui/tools/alert")
local ui_word = require("game_config/ui_word")
local composite_effect = require("gameobj/composite_effect")

local ClsExplorePlunderMissionPirateNpc = class("ClsExplorePlunderMissionPirateNpc", ClsExploreNpcBase)

function ClsExplorePlunderMissionPirateNpc:initNpc(data)
	self.m_attr = data.attr
	self.m_create_tpos = {x = self.m_attr.sea_pos[1], y = self.m_attr.sea_pos[2]}
	local pos = self.m_explore_layer:getLand():cocosToTile2(self.m_create_tpos)
	self.m_create_pos = {x = pos.x, y = pos.y}
	self.m_ship = nil
	self.m_is_send_msg = false
end

local CREATE_DIS2 = 1000*1000
local REMOVE_DIS2 = 1200*1200
function ClsExplorePlunderMissionPirateNpc:update(dt)
    if self.m_is_send_msg then
        return
    end
    local px, py = self:getPlayerShipPos()
    local dis2 = self:getDistance2(self.m_create_pos.x, self.m_create_pos.y, px, py)
    if self.m_ship then
        if dis2 > REMOVE_DIS2 then
            self:removeShip()
        end
    elseif dis2 < CREATE_DIS2 then
        self:createShip()
    end
end

function ClsExplorePlunderMissionPirateNpc:touch()
	if getGameData():getTeamData():isLock() then
		ClsAlert:warning({msg = ui_word.STR_COPY_QTE_TEAM_TIP})
		return true
	end
	GameUtil.callRpc("rpc_server_fight_player_robot")
	return true
end

function ClsExplorePlunderMissionPirateNpc:createShip()
	 if self.m_ship then
		return
	end

	self.m_ship = ClsExploreShip3d.new({
			id = self.m_attr.ship_id,
			pos = ccp(self.m_create_pos.x, self.m_create_pos.y),
			speed = EXPLORE_ADD_SPEED,
			name = self.m_attr.name,
			ship_ui = getShipUI(),
		})
	local id_str = tostring(self.m_id)
	self.m_ship.land = self.m_explore_layer:getLand()
	self.m_ship.node:setTag("exploreMainMissionPirateNpc", id_str)
	self.m_ship.node:setTag("exploreNpcLayer", id_str)
	
	local attack_btn = self.m_explore_layer:createButton({image = "#explore_plunder.png"})
	local show_text_lab = createBMFont({text = ui_word.STR_ATTACK, size = 16, color = ccc3(dexToColor3B(COLOR_RED_STROKE)), x = 0, y = 8})
	attack_btn:addChild(show_text_lab)
	attack_btn:regCallBack(function() 
		if not tolua.isnull(self.m_ship.ui.loot_guide) then
			self.m_ship.ui.loot_guide:removeFromParentAndCleanup(true)
		end
		self:touch()
	end)
	attack_btn:setPosition(ccp(0, -18))
	self.m_ship.ui:addChild(attack_btn)
	self.m_ship.ui.attack_btn = attack_btn

	self.m_ship.ui.loot_guide = composite_effect.bollow("tx_1042_1", 0, 0, attack_btn)
	
	self.m_ship:setAngle(Math.random(360))
	
	local sailor_info = require("game_config/sailor/sailor_info")
	local sailor_item = sailor_info[self.m_attr.head_id]
	local icon_pos = ccp(-38, 140)
	local job_str = SAILOR_JOB_BG[sailor_item.job[1]].normal
	local captain_bg = display.newSprite(string.format("#%s", job_str))
	captain_bg:setScale(0.9)
	captain_bg:setPosition(ccp(icon_pos.x, icon_pos.y - 20))
	self.m_ship.ui:addChild(captain_bg, 0)
	
	local icon_sprite = display.newSprite(sailor_item.res)
	icon_sprite:setPosition(ccp(icon_pos.x, icon_pos.y - 10))
	icon_sprite:setScale(0.3)
	self.m_ship.ui:addChild(icon_sprite, 1)
end

function ClsExplorePlunderMissionPirateNpc:removeShip()
    if self.m_ship then
        self.m_ship:release()
    end
    self.m_ship = nil
end

function ClsExplorePlunderMissionPirateNpc:release()
    self:removeShip()
end

return ClsExplorePlunderMissionPirateNpc