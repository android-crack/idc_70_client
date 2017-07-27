-- Author: clr
-- Date: 2016-02-16 14:53:49
-- require("gameobj/mission/missionInfo")
local music_info = require("game_config/music_info")
local voice_info = getLangVoiceInfo()
local missionGuide = require("gameobj/mission/missionGuide")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local ClsPortMainUI = require("gameobj/port/clsPortMainUI")
local ClsDataTools = require("module/dataHandle/dataTools")
local ClsBroadcast = require("gameobj/chat/clsBroadcast")
local portAnimation = require("gameobj/port/portAnimation")
local MyTransition = require("ui/tools/MyTransition")
local CompositeEffect = require("gameobj/composite_effect")
local boat_info = require("game_config/boat/boat_info")
local on_off_info = require("game_config/on_off_info")
local UiTools = require("gameobj/uiTools")
local Alert = require("ui/tools/alert")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsDialogSequene = require("gameobj/quene/clsDialogQuene")
local ClsShipRewardPop = require("gameobj/quene/clsShipRewardPop")


local ClsPortLayer = class("ClsPortLayer", ClsBaseView)

local platePanelKeys = {
    on_off_info.PORT_MARKET.value,
    on_off_info.PORT_TOWN.value,
    on_off_info.PORT_UNION.value,
    on_off_info.PORT_HOTEL.value,
    on_off_info.PORT_SHIPYARD.value,
    on_off_info.PORT_QUAY_EXPLORE.value,
}

function ClsPortLayer:onCtor(isFirst, call_back)
    self.armatureTab = {}
    self.effectArmature = {}
    self.isFirstEnter = isFirst
    self.enter_port_call_back = call_back
    self:setIsEnable(true)

    self.port_layer = UIWidget:create()
    self:addWidget(self.port_layer)

    local portData = getGameData():getPortData()
    portData:updatePort()
end


--页面参数配置方法，注意，是静态方法
function ClsPortLayer:getViewConfig()
    return {
        name = "ClsPortLayer",       --(选填）默认 class的名字
        type = UI_TYPE.VIEW,        --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        -- is_swallow = true,          --(选填) 默认true, 是否吞掉下层页面的触摸事件
        -- effect = UI_EFFECT.FADE,    --(选填) ui出现时的播放特效
    }
end

function ClsPortLayer:onEnter()
    local port_data = getGameData():getPortData()
    local mark = port_data:getArrestMark()
    local cur_id = port_data:getPortId()
    if mark ~= cur_id then
        port_data:setArrestMark(cur_id)
        local loot_data = getGameData():getLootData()
        loot_data:askArrest()
        loot_data:askReportList()
        loot_data:askTraceingPlayerInfo()
    end
    self:regFunc()
end

function ClsPortLayer:regFunc()
    -- self:registerScriptHandler(function(event)
    --     if event == "exit" then
    --         self:onExit()
    --     elseif event == "enter" then
    --         self:onEnter()
    --     end
    -- end)

    RegTrigger(EVENT_ADD_PORT_ITEM, function(node, callBack, noEffect)  --往港口界面上添加"界面（不是其他小东西哦）"的快捷方法
        if tolua.isnull(self) then return end
        self:addItem(node, callBack, noEffect)
    end)

    -- RegTrigger(EVENT_DEL_PORT_ITEM, function(not_touch) --删除当前添加在港口上的界面的快捷方法
    --     self:hideChatMainUI()
    --     if tolua.isnull(self) or tolua.isnull(self.portItem) then return end
    --     self.portItem:removeFromParentAndCleanup(true)
    --     self.portItem = nil
    --     if not not_touch then
    --         self:setTouch(true)
    --     end
    -- end)

    -- RegTrigger(EVENT_DELETE_ITEMS_LAYER, function(withEffect, call_back)
    --     self:hideChatMainUI()
    --     if tolua.isnull(self) then EventTrigger(EVENT_MAIN_SELECT_LAYER, TYPE_LAYER_PORT) return end
    --     local curItemsLayer = self:getChildByTag(ZORDER_UI_LAYER)
    --     if not tolua.isnull(curItemsLayer) then
    --         if withEffect ~= nil and withEffect == true then
    --             MyTransition:delLayer(curItemsLayer, call_back)
    --         else
    --             MyTransition:delLayer(curItemsLayer, call_back, true)
    --         end
    --     else
    --         self:setTouch(true)
    --     end
    -- end)

    RegTrigger(EVENT_PORT_CHANGE_BOAT,function(boatId)  --换船主界面的船显示
        if tolua.isnull(self) then return end
        self:changeBoat(boatId)
    end)

    --显示隐藏港口名
    RegTrigger(EVENT_SHOW_PORT_NAME, function(isShow)
        if tolua.isnull(self) or tolua.isnull(self.spriteNameBg) then return end
        self.spriteNameBg:setVisible(isShow)
        self.effect_node:setVisible(isShow)
    end)
end

function ClsPortLayer:updateUI(portInfo)

    ---请求海上新星
    local seaStarData = getGameData():getSeaStarData()
    seaStarData:askSeaStarList()

    
    self.port_layer:removeCCNode(true)
    self.effecting = false
    self.buttonMap = {}
    local portData = getGameData():getPortData()
    self.portType = portData:getPortType()
    if self.isFirstEnter then  --连续播放问题
        audioExt.playMusic(music_info[portInfo.music].res, true)
    end

    local portCfg = ClsDataTools:getPortSet(self.portType)
    self:mkUi(portCfg, portInfo)
    self.mainLayer = ClsPortMainUI.new()
    self.port_layer:addChild(self.mainLayer)
    self:checkMissionGuide() --是否需要走重登绿字流程
    self:mkMenu(portCfg, portInfo)
    self:enterPort(portCfg, portInfo)

    --主界面的自己船舶
    local partner_data = getGameData():getPartnerData()
    local boat_id = partner_data:getShowMainBoatId()
    if boat_id and boat_id ~= 0 then
        EventTrigger(EVENT_PORT_CHANGE_BOAT, boat_id)
    end

end

function ClsPortLayer:getMainUI()
    return self.mainLayer
end

function ClsPortLayer:mkUi(portCfg, portInfo)
    if not tolua.isnull(self.spriteBg) then
        self.spriteBg:removeFromParentAndCleanup(true)
    end
    self.spriteBg = display.newSprite()
    self.spriteBg:setContentSize(CCSize(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT))
    self.spriteBg:setPosition(display.cx, display.cy)
    self.port_layer:addCCNode(self.spriteBg)
    -- use rgb565
    self.bgResPath = portCfg.res
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
    self.spriteBgPhoto = display.newSprite(portCfg.res, display.cx, display.cy)
	CCTexture2D:setDefaultAlphaPixelFormat(TextureFormat["default"])
    self.spriteBg:addChild(self.spriteBgPhoto)

    local portData = getGameData():getPortData()
    if portData:getPortFlipX() == 1 then
        self.spriteBg:setFlipX(true)
        self.spriteBgPhoto:setFlipX(true)
    end
    --得到缩放的比例
    self.bgScale = CONFIG_SCREEN_WIDTH/self.spriteBgPhoto:getContentSize().width
    self.spriteBgPhoto:setScale(self.bgScale)
end

function ClsPortLayer:createChatComponent(enable)
    local battle_data = getGameData():getBattleDataMt()
    if not battle_data:IsBattleStart() then
        getUIManager():close("ClsChatComponent")
        getUIManager():create("gameobj/chat/clsChatComponent", {before_view = "ClsPortLayer"})
    end
end

function ClsPortLayer:mkMenu(cfg,portInfo)
    self:createChatComponent()
    getUIManager():create("gameobj/team/clsTeamMissionPortUI")
    self.mision_port_ui = getUIManager():get("ClsTeamMissionPortUI")
    self.mision_port_ui:setPosition(781, 208)
    self.mision_port_ui:setTouch(false)

    getUIManager():create("gameobj/port/clsGuidePortLayer")
    self.guide_layer = getUIManager():get("ClsGuidePortLayer")
end

function ClsPortLayer:checkMissionGuide()
    local missionDataHandler = getGameData():getMissionData()
    local doingMissionInfo = missionDataHandler:getMissionAndDailyMissionInfo()
    if missionDataHandler:getIsFirstIntoPort() and (#doingMissionInfo > 0) then
        getGameData():getCityChallengeData():askMissionList()

        if doingMissionInfo[1].status == MISSION_STATUS_DOING then
            local guide_list = doingMissionInfo[1].super_mission_guide_1
            if guide_list and #guide_list > 0 then
                ClsGuideMgr:cleanGuide(doingMissionInfo[1].id)
                ClsGuideMgr:addGuide(doingMissionInfo[1].id, guide_list, true)
                return
            end
        end

        local branch_index = 2
        for branch_index = 2 , #doingMissionInfo do
            local guide_list = doingMissionInfo[branch_index].super_mission_guide_1
            if guide_list and #guide_list > 0 then
                ClsGuideMgr:cleanGuide(doingMissionInfo[branch_index].id)
                ClsGuideMgr:addGuide(doingMissionInfo[branch_index].id, guide_list, true)
                return
            end
        end
    end
end

function ClsPortLayer:popBattleReward()
    local port_data = getGameData():getPortData()
    local reward = port_data:popBattleReward()

    if not reward then return end

    local elite_boat = getGameData():getBoatData():getEliteRewardBoat()
    if #elite_boat > 0 then
        local boat_reward = {}
        local other_reward = {}


        for k,v in pairs(reward) do
            if v.type == ITEM_INDEX_BOAT then
                boat_reward[#boat_reward + 1] = v
            else
                other_reward[#other_reward + 1] = v
            end
        end

        if #boat_reward > 0 then
           -- print("===========================精英战役获得船只----------队列")
            ClsDialogSequene:insertTaskToQuene(ClsShipRewardPop.new({boatInfo = elite_boat[1], callBackFunc = function ( )
                if type(other_reward) == "table" and #other_reward > 0 then
                    print("==============================回调奖励")
                    Alert:showCommonReward(other_reward)
                end
                getGameData():getBoatData():clearEliteRewardBoat()
            end}))

            return
        end

    end

    if type(reward) == "table" and #reward > 0 then
        Alert:showCommonReward(reward)
    end
end

function ClsPortLayer:resumeQuene()
    ClsDialogSequene:resetSaveDialogTable()
    ClsDialogSequene:resumeQuene("clsPortEffect")
    ClsDialogSequene:resumeQuene("enter_port")
    ClsDialogSequene:resumeQuene("LoginLayer")
    ClsDialogSequene:resumeQuene("battle_scene")
end

function ClsPortLayer:enterPort(portCfg)  --特效可以在此屏蔽
    self:setTouch(false)
    self:playCaptainVoice()
    local portData = getGameData():getPortData()
    self.showEffect = portData:getEffect()
    if self.showEffect then  -- 过度效果暂时屏蔽
        mkPortEnterEffect(self,portCfg,function()
            portData:setEffect()
            portAnimation:mkPeople(self, portCfg)
            self:judgeIsHaveRelicMission()
            self:autoShowMissionMateGuide()
            portAnimation:mkEffect(self,portCfg)
            portAnimation:mkNPCBubble(self, portCfg)
            portAnimation:mkNPCTalk(self, portCfg)
            --如果播放港口特效时，刚好切换到其他界面，回调函数则不设置self:setTouch(true)
            if not tolua.isnull(self) and tolua.isnull(self.portItem) then
                self:setTouch(true)
            end
            self:resumeQuene()
            self:autoPopView()
            self.mainLayer:updateUIAfterEffect()
        end)
    else
        mkPortUIEnterEffect(self, function()
            portAnimation:mkPeople(self,portCfg)
            self:judgeIsHaveRelicMission()
            portAnimation:mkEffect(self,portCfg)
            portAnimation:mkNPCBubble(self, portCfg)
            portAnimation:mkNPCTalk(self, portCfg)
            --如果播放港口特效时，刚好切换到其他界面，回调函数则不设置self:setTouch(true)
            if not tolua.isnull(self) and tolua.isnull(self.portItem) then
                self:setTouch(true)
            end
            self:autoPopView()
            self:autoShowMissionMateGuide()
            self:resumeQuene()
            self.mainLayer:updateUIAfterEffect()
        end)
    end
end

function ClsPortLayer:playCaptainVoice()
    local playerData = getGameData():getPlayerData()
    if playerData:getFirstLogin() then
        return
    end
    local sailor_data = getGameData():getSailorData()
    local captainInfo = sailor_data:getCaptain()
    if captainInfo and not sailor_data.hasPlay then
        sailor_data.hasPlay = true
        if sailor_data:getAppointSex(captainInfo) == 1 then
            audioExt.playEffect(voice_info.VOICE_PLOT_1016.res)
        else
            audioExt.playEffect(voice_info.VOICE_PLOT_1017.res)
        end
    end
end

--判断是否能够接遗迹任务
function ClsPortLayer:judgeIsHaveRelicMission()
    local collect_data = getGameData():getCollectData()
    local port_data = getGameData():getPortData()
    local port_type = port_data:getPortType()
    if not port_type then return end
    local port_config = ClsDataTools:getPortSet(port_type)
    local port_id = port_data:getPortId() --当前港口id
    local mission_relic_id = collect_data:getRelicIdByPortId(port_id)
    if not mission_relic_id then
        self:delRelicMissionIcon()
        return
    end
    portAnimation:mkRelicMissionIcon(self, port_config)
end

function ClsPortLayer:delRelicMissionIcon()
    portAnimation:delRelicMissionIcon(self)
end

function ClsPortLayer:autoPopView()
    local login_data_handle = getGameData():getLoginVipAwardData()
    login_data_handle:operatePopInfo()
    -- 自动弹出组队界面
    -- getGameData():getTeamData():autoPopView()
    --战斗奖励
    self:popBattleReward()
    --市政厅水手经验弹框
    getGameData():getPortData():popSailorAppiont()
    --战斗结束跳转
    getGameData():getPortData():autoPopBattleEndLayer()
    --任务下发弹框
    getGameData():getMissionData():autoPopPanelView()

    --有队伍邀请数据自动弹邀请界面
    getGameData():getTeamData():autoPopInviteView()
    if type(self.enter_port_call_back) == "function" then
        require("framework.scheduler").performWithDelayGlobal(function()
            if type(self.enter_port_call_back) == "function" then
                self.enter_port_call_back(self)
                self.enter_port_call_back = nil
            end
        end,0.7)
    end
    --getGameData():getPortData():showPowerChangeEffect()

    -- 有市政厅任务且当前港口非挑战港口（非队员）
    local city_challenge_handle = getGameData():getCityChallengeData()
    if city_challenge_handle:isPopChallengeView() then
        city_challenge_handle:toOpenPanel("challenge")
    end
end

function ClsPortLayer:playBroadcast()
    local endCallBack = function()
        if self.broadcast_entity then
            self.broadcast_entity = nil
        end
    end

    local broadcast_data = getGameData():getBroadcastData()
    local broadcast_list = broadcast_data:getBroadcastList()
    local index = broadcast_data:getCurrentScrolledIndex()
    if #broadcast_list > 0 and broadcast_list[index] then
        if not self.broadcast_entity then
            self.broadcast_entity = ClsBroadcast.new(self, endCallBack)
            self.broadcast_entity:playPlot(broadcast_list[index])
        end
    end
end

function ClsPortLayer:autoShowMissionMateGuide()
    --掠夺失败，回到港口，有战报的话弹出提示
    local lootDataHandle = getGameData():getLootData()
    self.mainLayer:updateCenterBtn()
end

function ClsPortLayer:removeTimeHander()
    local scheduler = CCDirector:sharedDirector():getScheduler()
    if self.hander_time then
        scheduler:unscheduleScriptEntry(self.hander_time)
        self.hander_time = nil
    end
end

function ClsPortLayer:ajustPortMissionForceGuide()
    for k,v in ipairs(platePanelKeys) do
        if missionGuide:guideIsOpen(v) then
            local curItemsLayer = self:getChildByTag(ZORDER_UI_LAYER)
            if not tolua.isnull(curItemsLayer) then
                EventTrigger(EVENT_DELETE_ITEMS_LAYER, false)
            elseif not self.showPlate then
                -- EventTrigger(EVENT_HIDE_MENU)
            end
            return
        end
    end

    local curItemsLayer = self:getChildByTag(ZORDER_UI_LAYER)
    if not tolua.isnull(curItemsLayer) then
        EventTrigger(EVENT_DELETE_ITEMS_LAYER, false)
    end
    return
end

-- 港口添加界面
function ClsPortLayer:addItem(node, callBack, notEffect, delayTime)
    if not tolua.isnull(self.portItem) or tolua.isnull(node) then return end
    if not tolua.isnull(self.armatureAnimation) then self.armatureAnimation:gotoAndPause(1) end
    self.portItem = node
    self.portItem:setTag(ZORDER_UI_LAYER)
    if notEffect then
        self:setTouch(false)
        self:addChild(self.portItem, portZorder.ITEM)
    else
        local delay_time = delayTime or 0.4
        MyTransition:addLayer(self, self.portItem, portZorder.ITEM, callBack, delay_time)
    end
end

function ClsPortLayer:changeBoat(boatId) --玩家自己的船
    if tolua.isnull(self.spriteBg) then return end
    if not tolua.isnull(self.boatSprite) then self.boatSprite:removeFromParentAndCleanup(true) end

    ------------------------------组队港口显示队员们的船-----------------------------------
    local portData = getGameData():getPortData()
    self.portType = portData:getPortType()
    self:clearOldBoat()
    if getGameData():getTeamData():isInTeam() then
        self:updateTeamBoat(boatId)
        return
    end
    -------------------------------这个代码可能会被删除--------------------------------------------
    local portCfg = ClsDataTools:getPortSet(self.portType)
    local boat = boat_info[boatId]
    if not boat then
        return
    end
    local key = boat.armature
    self.armatureTab[key] = "armature/ship/"..key.."/"..key..".ExportJson"

    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(self.armatureTab[key])
    self.boatSprite = CCArmature:create(key)
    self.boatSprite:getAnimation():playByIndex(0)
    local x, y = getX(portCfg.pointBoat[1]), portCfg.pointBoat[2]
    self.boatSprite:setPosition(x, y)
    self.boatSprite:setScale(0.4)
    self.boatSprite:setCascadeOpacityEnabled(true)
    self.spriteBg:addChild(self.boatSprite, 2)

    if not tolua.isnull(self.reverseSprite) then
        self.reverseSprite:removeFromParentAndCleanup(true)
    end
    self.reverseBoatRes = boat.reverseRes
    self.reverseSprite = display.newSprite(boat.reverseRes, x + boat.shadePos[1], y + boat.shadePos[2])
    self.reverseSprite:setScale(0.4)
    self.reverseSprite:setCascadeOpacityEnabled(true)
    self.spriteBg:addChild(self.reverseSprite)

    if tolua.isnull(self.wave) then
        self.wave= CompositeEffect.bollow("tx_2022", x + boat.pos1[1], y + boat.pos1[2], self.spriteBg)
        self.wave:setZOrder(3)
    else
        self.wave:setPosition(x + boat.pos1[1], y + boat.pos1[2])
    end
    self.wave:setScale(boat.scale1 / 100)
end

function ClsPortLayer:clearOldBoat()
    if type(self.boat_sprite) == "table"and #self.boat_sprite > 0 then
        for i,v in ipairs(self.boat_sprite) do
            if not tolua.isnull(v) then
                v:removeFromParentAndCleanup(true)
            end
        end
    end
    if type(self.reverse_sprite) == "table"and #self.reverse_sprite > 0 then
        for i,v in ipairs(self.reverse_sprite) do
            if not tolua.isnull(v) then
                v:removeFromParentAndCleanup(true)
            end
        end
    end

    if type(self.team_wave) == "table"and #self.team_wave > 0 then
        for i,v in ipairs(self.team_wave) do
            if not tolua.isnull(v) then
                v:removeFromParentAndCleanup(true)
            end
        end
    end
    if not tolua.isnull(self.reverseSprite) then
        self.reverseSprite:removeFromParentAndCleanup(true)
    end
    if not tolua.isnull(self.wave) then
        self.wave:removeFromParentAndCleanup(true)
    end
end

function ClsPortLayer:updateTeamBoat(boat)
    local team_data = getGameData():getTeamData()
    local team_list = team_data:getMyTeamInfo().info
    local portCfg = ClsDataTools:getPortSet(self.portType)
    local boat_poss = portCfg.team_pointBoat

    self.team_wave = {}
    self.reverse_sprite = {}
    self.boat_sprite = {}

    for i,v in ipairs(team_list) do
        local boat_id = v.flagShip

        if v.uid == getGameData():getPlayerData():getUid() then
            boat_id = boat
        end
        local boat = boat_info[boat_id]
        local key = boat.armature
        self.armatureTab[key] = "armature/ship/"..key.."/"..key..".ExportJson"

        CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(self.armatureTab[key])
        self.boat_sprite[i] = CCArmature:create(key)
        self.boat_sprite[i]:getAnimation():playByIndex(0)
        local x, y = getX(portCfg.team_pointBoat[(i -1)*2 + 1]), portCfg.team_pointBoat[(i -1)*2 + 2]

        self.boat_sprite[i]:setPosition(x, y)
        self.boat_sprite[i]:setScale(0.4)
        self.boat_sprite[i]:setCascadeOpacityEnabled(true)
        self.spriteBg:addChild(self.boat_sprite[i], 2)

        self.reverse_sprite[i] = display.newSprite(boat.reverseRes, x + boat.shadePos[1], y + boat.shadePos[2])
        self.reverse_sprite[i]:setScale(0.4)
        self.reverse_sprite[i]:setCascadeOpacityEnabled(true)
        self.spriteBg:addChild(self.reverse_sprite[i])

        self.team_wave[i] = CompositeEffect.bollow("tx_2022", x + boat.pos1[1], y + boat.pos1[2], self.spriteBg)
            self.team_wave[i]:setZOrder(3)
        self.team_wave[i]:setScale(boat.scale1 / 100)

    end
end

function ClsPortLayer:updateFristRecharge(  )
    if not tolua.isnull(self.mainLayer) then
        self.mainLayer:initFirstRechargeBtn()
    end
end


function ClsPortLayer:initTreasureInfo()
	if not tolua.isnull(self.mainLayer) then
        self.mainLayer:initTreasureInfo()
    end
end

function ClsPortLayer:showActivityTips(id, real_time)
	if not tolua.isnull(self.mainLayer) then
        self.mainLayer:showActivityTips(id, real_time)
    end
end

function ClsPortLayer:closeFeatureTips(id, is_activity)
	if not tolua.isnull(self.mainLayer) then
        self.mainLayer:closeFeatureTips(id, is_activity)
    end
end

function ClsPortLayer:showFuncTips()
	if not tolua.isnull(self.mainLayer) then
        self.mainLayer:showFuncTips()
    end
end

function ClsPortLayer:checkShowActivityEffect()
	if not tolua.isnull(self.mainLayer) then
        self.mainLayer:checkShowActivityEffect()
    end
end

function ClsPortLayer:updateLockExploreTimer()
	if not tolua.isnull(self.mainLayer) then
        self.mainLayer:updateLockExploreTimer()
    end
end

function ClsPortLayer:updateExpBuffStatus()
    if not tolua.isnull(self.mainLayer) then
        self.mainLayer:updateExpBuffStatus()
    end
end

function ClsPortLayer:updataSeaStarTask()
	if not tolua.isnull(self.mainLayer) then
        self.mainLayer:updataSeaStarTask()
    end
end

function ClsPortLayer:setName(name)
	if not tolua.isnull(self.mainLayer) then
        self.mainLayer:setName(name)
    end
end

function ClsPortLayer:updateProsperLevel()
    if not tolua.isnull(self.mainLayer) then
        self.mainLayer:updateProsperLevel()
    end
end

function ClsPortLayer:updatePlayerInfo(kind, value, max)
	if not tolua.isnull(self.mainLayer) then
        self.mainLayer:updatePlayerInfo(kind, value, max)
    end
end

function ClsPortLayer:updateBattlePower()
	if not tolua.isnull(self.mainLayer) then
        self.mainLayer:updateBattlePower()
    end
end

function ClsPortLayer:updateHead(res)
	if not tolua.isnull(self.mainLayer) then
        self.mainLayer:updateHead(res)
    end
end

function ClsPortLayer:updateCenterBtn()
	if not tolua.isnull(self.mainLayer) then
        self.mainLayer:updateCenterBtn()
    end
end

function ClsPortLayer:updateItemTips()
	if not tolua.isnull(self.mainLayer) then
        self.mainLayer:updateItemTips()
    end
end

function ClsPortLayer:setPopDisappear(close)
	if not tolua.isnull(self.mainLayer) then
        self.mainLayer:setPopDisappear(close)
    end
end

function ClsPortLayer:jugeShowQuestionBtn()
    if not tolua.isnull(self.mainLayer) then
        self.mainLayer:jugeShowQuestionBtn()
    end
end

function ClsPortLayer:open(key)
	if not tolua.isnull(self.mainLayer) then
        self.mainLayer:open(key)
    end
end

function ClsPortLayer:removeBtn51()
    if not tolua.isnull(self.mainLayer) then
        self.mainLayer:removeBtn51()
    end
end

function ClsPortLayer:onExit()
    if not tolua.isnull(self.mainLayer) then
        self.mainLayer:onExit()
    end

    self:removeTimeHander()
    if self.fadeBgTimer then    --特效变灰白的定时器卸载
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.fadeBgTimer)
    end
    portAnimation.relic_people_index = nil
    UnLoadArmature(self.effectArmature)
    UnLoadArmature(self.armatureTab) --移除 self.armatureTab
    ReleaseTexture(self)
	
	UnRegTrigger(EVENT_ADD_PORT_ITEM)
	UnRegTrigger(EVENT_PORT_CHANGE_BOAT)
	UnRegTrigger(EVENT_SHOW_PORT_NAME)
end

function ClsPortLayer:setTouch(enable) --触摸的开关,牌子的是否掉下
    self:setIsEnable(enable)
    if tolua.isnull(self) then return end
    self:setViewTouchEnabled(enable)

    if not tolua.isnull(self.mainLayer) then
        self.mainLayer:setTouch(enable)
    end

    if enable then
        if not tolua.isnull(self.shadeLayer) then
            self.shadeLayer:removeFromParentAndCleanup(true)
        end
    end

    if type(self.peoples) == "table" then --小人是否可点
        for _, people in pairs(self.peoples) do
            people.button:setEnabled(enable)
        end
    end

    if not tolua.isnull(self.spriteBg) and not tolua.isnull(self.spriteBg.talk_node) then
        self.spriteBg.talk_node:setTouchEnabled(enable)
    end
end

function ClsPortLayer:canEnterArena()
    getUIManager():create("gameobj/arena/clsArenaMainUI")
end

function ClsPortLayer:notCanEnterArena(msg)
    self:setTouch(true)
    Alert:warning({msg = msg})
end

function ClsPortLayer:setIsEnable(enable)
    self.touchEnable = enable
end

function ClsPortLayer:preClose()
    if self.mainLayer then
        self.mainLayer:preClose()
    end
end

function ClsPortLayer:getIsEnable()
    return self.touchEnable
end

return ClsPortLayer
