--create by pyq0639 17/03/15
local ui_word = require("game_config/ui_word")
local cfg_copy_scene_melee_objects = require("game_config/copyScene/top_fight_objects")
local ClsCopySceneEventObject = require("gameobj/copyScene/copyEventObject")
local cfg_copy_scene_prototype = require("game_config/copyScene/copy_scene_prototype")
local ClsExploreShip3d = require("gameobj/explore/exploreShip3d")
local ClsMeleeBossEvent = class("ClsMeleeBossEvent", ClsCopySceneEventObject)

function ClsMeleeBossEvent:initEvent(prop_data)
	self.is_touch = false
	self.event_data = prop_data
    self.event_create_time = prop_data.create_time
    self.event_id = prop_data.id
    self.event_type = prop_data.type
    self.config = cfg_copy_scene_melee_objects[prop_data.attr.index]

    local ship_pos = ccp(prop_data.sea_pos.x, prop_data.sea_pos.y)
    self.m_ship = ClsExploreShip3d.new({
        id = self.config.boatId,
        pos = ship_pos,
        speed = 0,
        name_color = COLOR_RED_STROKE,
        ship_ui = getSceneShipUI(),
    })
    self.item_model = self.m_ship
    self.item_model.id = self.event_id
    self.item_model.node:setTag("scene_event_id", tostring(self.event_id))
    self.hp = self.event_data.attr.amount
    self.max_hp = self.config.max_num
end

function ClsMeleeBossEvent:initUI()
	local hpProgressBg = self:createHpProgress()
    local valuePercent = self.hp / self.max_hp * 100
    self.hpProgress:setPercentage(valuePercent)
    self.item_model.ui:addChild(hpProgressBg)
    hpProgressBg:setPosition(ccp(1, -65))

    if tolua.isnull(self.m_name_ui) then
        self.m_name_ui = display.newSprite("#explore_name1.png")
        local ui_size = self.m_name_ui:getContentSize()
        local name_lab = createBMFont({text = self.config.name, size = 24, color = ccc3(dexToColor3B(COLOR_WHITE)), x = ui_size.width/2, y = ui_size.height/2 + 7})
        self.m_name_ui:addChild(name_lab)
        self.item_model.ui:addChild(self.m_name_ui)
        self.m_name_ui:setPosition(ccp(1, -1))
        self.m_name_ui:setScale(0.6)
    end
	if tolua.isnull(self.m_ship.ui.attack_btn) then
        local copy_scene_layer = getUIManager():get("ClsCopySceneLayer")
        local attack_btn = copy_scene_layer:createButton({image = "#explore_plunder.png"})
        local show_text_lab = createBMFont({text = ui_word.STR_ATTACK, size = 16, color = ccc3(dexToColor3B(COLOR_RED_STROKE)), x = 0, y = 8})
        attack_btn:addChild(show_text_lab)
        attack_btn:regCallBack(function()
            self:sendSalvageMessage()
        end)

        attack_btn:setPosition(ccp(0, -30))
        attack_btn:setTouchEnabled(true)
        self.m_ship.ui:addChild(attack_btn)
        self.m_ship.ui.attack_btn = attack_btn
    end
end

function ClsMeleeBossEvent:updataAttr(key, value)
	if key == "amount" then
		self.hp = value
		local valuePercent = self.hp / self.max_hp * 100
    	self.hpProgress:setPercentage(valuePercent)
	end
end

function ClsMeleeBossEvent:release()
    if self.item_model then
        self.item_model:release()
        self.item_model = nil
        self.m_ship = nil
    end
end

return ClsMeleeBossEvent