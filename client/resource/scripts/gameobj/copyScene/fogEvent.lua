--迷雾事件
local ClsCopySceneEventObject = require("gameobj/copyScene/copyEventObject")
local propEntity = require("gameobj/copyScene/copySceneProp")
local ClsSceneManage = require("gameobj/copyScene/copySceneManage") 
local tips = require("game_config/tips")
local ClsSceneConfig = require("game_config/copyScene/copy_scene_prototype") 

local ClsFogEventObject = class("ClsFogEventObject", ClsCopySceneEventObject);

function ClsFogEventObject:getEventId()
	return self.event_id
end

function ClsFogEventObject:initEvent(prop_data)
    self.event_create_time = prop_data.create_time
    self.event_id = prop_data.id
    self.event_type = prop_data.type
    self.skill_id = 1062
    self.tips_id = 11
    --创建迷雾层
    local ClsFogLayer = require("gameobj/copyScene/fogLayer")
   
    self.fog_layer = ClsFogLayer.new({})
    local running_scene = GameUtil.getRunningScene()
    running_scene:addChild(self.fog_layer, 7)
    self.fog_layer:setVisible(false)
    --
    self:createBtn()
    
    ClsSceneManage:showDialogBoxWithSailorId(12)
end

function ClsFogEventObject:update(dt)
    local top_left = ccp(8, 4)
    local right_bottom = ccp(21, 17)
    local ship_pos = ccp(0, 0)
    if self.is_time_out then
        return
    end
    
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage") 
    local scene_layer = ClsSceneManage:getSceneLayer()
    if not tolua.isnull(scene_layer) then
        local ship_x, ship_y = scene_layer.player_ship:getPos()
        ship_pos = ClsSceneManage:getSceneMapLayer():cocosToTileSize(ccp(ship_x, ship_y))
    end
    local visible_b = false
    if top_left.x < ship_pos.x and ship_pos.x < right_bottom.x and (top_left.y < ship_pos.y and ship_pos.y < right_bottom.y) then
        visible_b = true
        self:showEventEffect()
    else
        self:stopEventEffect()
    end
    if not tolua.isnull(self.fog_layer) then
        self.fog_layer:setVisible(visible_b)
    end
    if not tolua.isnull(self.fog_menu) then
        self.fog_menu:setVisible(visible_b)
    end
end

function ClsFogEventObject:stopEventEffect()
    self.forgeBtn:stopAllActions()
    self.forgeBtn.m_pNormalImage:stopAllActions()
end

function ClsFogEventObject:createBtn() --创建迷雾按钮
    
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage") 
    local scene_layer = ClsSceneManage:getSceneLayer()

    self.forgeBtn = MyMenuItem.new({image = "#explore_skill.png", isAudio = false, unSelectScale = 0.7, selectScale = 0.6})
    local btnSize = self.forgeBtn:getContentSize()
    local skill_cfg = require("game_config/skill/skill_info")
    local skill = display.newSprite(skill_cfg[self.skill_id].res)
    local size = self.forgeBtn.m_pNormalImage:getContentSize()
    skill:setPosition(ccp(size.width / 2, size.height / 2))
    self.forgeBtn.m_pNormalImage:addChild(skill)

    local shipUi = scene_layer.player_ship.ui
    self.forgeBtn:setPositionY(100)
    self.forgeBtn:setScale(0.7)
    local btnMenu = MyMenu.new({self.forgeBtn})
    btnMenu.camera = scene_layer:getCamera()
    self.fog_menu = btnMenu
    self.fog_menu:setVisible(false)
    shipUi:addChild(btnMenu)
    

    local function fog_exit_call()
        self:__endEvent()
    end
    local function btn_call_back()
        if not tolua.isnull(self.fog_menu) then
            self.fog_menu:setVisible(false)
        end
    end
    self.fog_layer:setBtnCallBack(btn_call_back)
    self.fog_layer:setExitCallBack(fog_exit_call)
    self.forgeBtn:regCallBack(function()
        -----
     self.fog_layer:openForget(self.skill_id)
        -- if true then
        --     self.fog_layer:openForget(self.skill_id)
        -- else
        --     self:showSkillTips()
        -- end

    end)

end

function ClsFogEventObject:__endEvent()
    ClsFogEventObject.super.__endEvent(self)
    if not tolua.isnull(self.fog_layer) then
        self.fog_layer:removeFromParentAndCleanup(true)
        self.fog_layer = nil
    end
end

function ClsFogEventObject:release()
    if self.is_time_out then
        return
    end
    --self:__endEvent()  当时间到时，先播放迷雾散开，在删除事件
    if not tolua.isnull(self.fog_menu) then
        self.fog_menu:removeFromParentAndCleanup(true)
    end
    if not tolua.isnull(self.fog_layer) then
        self.fog_layer:evHideForge()  -- evHideForge 这个借口里面会调用__endEvent
    end
    self.is_time_out = true
end

function ClsFogEventObject:updataAttr(keys, values) --更新属性
    --更新事件属性
  
end

function ClsFogEventObject:initUI()
  
end

function ClsFogEventObject:showEventEffect()
    local fadeIn = CCFadeTo:create(0.5, 255 * 0.5)
    local fadeOut = CCFadeTo:create(0.5, 255)
    self.forgeBtn:stopAllActions()
    local actions = CCArray:create()
    actions:addObject(fadeIn)
    actions:addObject(fadeOut)
    local action = CCSequence:create(actions)
    self.forgeBtn.m_pNormalImage:setCascadeOpacityEnabled(true)
    self.forgeBtn.m_pNormalImage:stopAllActions()
    self.forgeBtn.m_pNormalImage:runAction(CCRepeatForever:create(action))

    actions = CCArray:create()
    actions:addObject(CCDelayTime:create(5))
    local function stopAction()
        if not tolua.isnull(self.forgeBtn.m_pNormalImage) then
            self.forgeBtn.m_pNormalImage:stopAllActions()
        end
    end
    local funcCallBack = CCCallFunc:create(stopAction)
    actions:addObject(funcCallBack)
    action = CCSequence:create(actions)
    self.forgeBtn:runAction(action)
end

function ClsFogEventObject:touch(node)
    if not node then return end
    
    return nil
end

return ClsFogEventObject
