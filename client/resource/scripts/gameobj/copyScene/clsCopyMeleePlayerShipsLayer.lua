--
-- Author: lzg0946
-- Date: 2016-09-05 15:17:18
-- Function: 大乱斗系统的船

local copySceneConfig = require("gameobj/copyScene/copySceneConfig")
local ui_word = require("game_config/ui_word")
local ClsAlert = require("ui/tools/alert")
local rpc_down_info = require("game_config/rpc_down_info")

local ClsCopyPlayerShipsLayer = require("gameobj/copyScene/clsCopyPlayerShipsLayer")

local clsCopyMeleePlayerShipsLayer = class("clsCopyMeleePlayerShipsLayer", ClsCopyPlayerShipsLayer)

function clsCopyMeleePlayerShipsLayer:onEnter()
    clsCopyMeleePlayerShipsLayer.super.onEnter(self)
end

function clsCopyMeleePlayerShipsLayer:onExit()
    clsCopyMeleePlayerShipsLayer.super.onExit(self)
end

local DIS2 = 320*320
function clsCopyMeleePlayerShipsLayer:updateShipInfo(uid, ship)
    local has_attack = false
    local px, py = self.m_player_ship:getPos()
    local sx, sy = ship:getPos()
    local dis2 = (px - sx)*(px - sx) + (py - sy)*(py - sy)
    local copySceneManage = require("gameobj/copyScene/copySceneManage")
    if dis2 < DIS2 and true == copySceneManage:getSceneAttr("isAttack") then
        has_attack = true
    end

    if has_attack then
        if tolua.isnull(ship.ui.attack_btn) then
            local copy_scene_layer = getUIManager():get("ClsCopySceneLayer")
            local attack_btn = copy_scene_layer:createButton({image = "#explore_plunder.png"})
            local show_text_lab = createBMFont({text = ui_word.STR_ATTACK, size = 16, color = ccc3(dexToColor3B(COLOR_RED_STROKE)), x = 0, y = 8})
            attack_btn:addChild(show_text_lab)
            attack_btn:regCallBack(function()
                if self.m_ship_data:isGhostStatus(self.m_my_uid) then
                    ClsAlert:warning({msg = ui_word.GUILD_STRONGHOLD_GHOST_CAN_NOT_FIGHT})
                    return
                end

                if self.m_ship_data:isFighting(uid) then
                    ClsAlert:warning({msg = rpc_down_info[142].msg})
                    return
                end

                self:askAttack(uid)
            end)

            attack_btn:setPosition(ccp(0, -30))
            attack_btn:setTouchEnabled(true)
            ship.ui:addChild(attack_btn)
            ship.ui.attack_btn = attack_btn
        end
    else
        if not tolua.isnull(ship.ui.attack_btn) then
            ship.ui.attack_btn:removeFromParentAndCleanup(true)
        end
        ship.ui.attack_btn = nil
    end
end

function clsCopyMeleePlayerShipsLayer:updateShipStatus(uid)
    clsCopyMeleePlayerShipsLayer.super.updateShipStatus(self, uid)
    self:updateRankShipColor(uid)
    self:tryAddHeadEvent(uid)
    self:updateShipScale(uid) --加buff后改变船大小
end

function clsCopyMeleePlayerShipsLayer:updateShipScale(uid)
    local ship = self:getShipWithMyShip(uid)
    local pos_info = self.m_ship_data:getPosInfo(uid)
    if ship then
        if pos_info and pos_info.status.ship_scale then
            if not ship.init_scale then
                ship.init_scale = ship.node:getScaleX()
            end
            ship.node:setScale(ship.init_scale * (1.5^pos_info.status.ship_scale))
        end
    end
end

function clsCopyMeleePlayerShipsLayer:updateRankShipColor(uid)
    local ship = self:getShipWithMyShip(uid)
    local copy_scene_data = getGameData():getCopySceneData()
    if ship then
        local color = copy_scene_data:getRankNameColor(uid)
        ship:updatePlayerNameColor(color)
    end
end

function clsCopyMeleePlayerShipsLayer:tryAddHeadEvent(uid)
	local ship = self:getShipWithMyShip(uid)
	if ship then
		local touch_bg_spr = ship:getCaptainBgSpr()
		local copySceneManage = require("gameobj/copyScene/copySceneManage")
		if not tolua.isnull(touch_bg_spr) and not touch_bg_spr.is_reg_touch then
			touch_bg_spr.is_reg_touch = true
			self.m_parent:regTouchEvent(touch_bg_spr, function(event, x, y)
				if event == "began" or event == "ended" then
					if copySceneManage:doLogic("isLockShowPlayerDetail") or copySceneManage:getSceneAttr("isAttack") then return false end
					local pos = touch_bg_spr:convertToNodeSpace(ccp(x,y))
					local size = touch_bg_spr:getContentSize()
					local touch_rect = CCRect(0, 0, size.width, size.height)
					if touch_rect:containsPoint(ccp(pos.x, pos.y)) then
						if event == "ended" then
							local copySceneManage = require("gameobj/copyScene/copySceneManage")
							if copySceneManage:getSceneAttr("isAttack") then
								return true
							end
							local playerData = getGameData():getPlayerData()
							if uid == playerData:getUid() then
								return true
							end
							getUIManager():create("gameobj/captionInfo/clsCaptainInfoMain", nil, uid)
						end
						return true
					end
					return false
				end
			end)
		end
	end
end

function clsCopyMeleePlayerShipsLayer:touchShip(node)
    if not node then return end
    local index = node:getTag("playerShipsLayerBase")
    if not index then return end
    local uid = tonumber(index)
    local ship = self.m_player_ships[uid]
    if ship then
        return self.m_touch_manage:touchShip(uid, ship)
    end
end

return clsCopyMeleePlayerShipsLayer
