-- login layer

local ClsBaseView = require("ui/view/clsBaseView")
local ClsLoginLayerBase = class("ClsLoginLayerBase", ClsBaseView)

--login_type   决定了如何登录：绑定帐号登录，验证token登录，断线重连

function ClsLoginLayerBase:getViewConfig(...)
    return {
        name =  "LoginLayer",   
        type =  UI_TYPE.DIALOG,   
    }
end

function ClsLoginLayerBase:onEnter()
    audioExt.stopMusic()
    audioExt.stopAllEffects()
    
    local ClsDialogSequene = require("gameobj/quene/clsDialogQuene")
    ClsDialogSequene:pauseQuene("LoginLayer")

    self.interval_time = 2000
    self.cur_click_time = 0
    self:mkUi()
    local music_info = require("game_config/music_info")
    local sound = music_info.LOGIN_BGM
    audioExt.playMusic(sound.res, true)
end

function ClsLoginLayerBase:mkUi()
    self:mkNormalUI()
    self:mkJsonUI()
end

--创建平台无台的控件：背景，选服，防沉迷。。。。
function ClsLoginLayerBase:mkNormalUI()
    local sprite = display.newSprite()
    self:addChild(sprite, -1)
    --背景相关
    local bg = CCNode:create()
    bg:setContentSize(CCSize(display.width,display.height))
    sprite:addChild(bg)

    local CompositeEffect = require("gameobj/composite_effect")

    --背景特效
    self.bgEffect = CompositeEffect.new("tx_0035", display.cx, display.cy, bg)
    self.bgEffect:setScale(1)
    self.bgEffect:runAction(CCScaleTo:create(4, 0.8))

    --太阳
    self.sunEffect = CompositeEffect.new("tx_0035sun", display.cx, display.cy, self.bgEffect)

    --小鸟从左到右飞 
    local bird_01_start_pos = ccp(-960, display.height + 60)
    local bird_01_end_pos = ccp(display.width + 300, display.height + 100)
    self.birdEffect = CompositeEffect.new("tx_0035bird01", 0, display.height + 60, self.bgEffect)
    self.birdEffect:setScale(1.25)
    self.birdEffect:setVisible(false)

    local array = CCArray:create()
    array:addObject(CCCallFunc:create(function()
        self.birdEffect:setVisible(true)
        if not tolua.isnull(self.birdEffect02) then
            self.birdEffect02:setVisible(false)
            self.birdEffect02:removeFromParentAndCleanup(true)
            self.birdEffect02 = nil
        end
        self.birdEffect:setPosition(bird_01_start_pos)
    end))
    array:addObject(CCMoveTo:create(5, bird_01_end_pos))

    array:addObject(CCCallFunc:create(function()
        self.birdEffect:setVisible(false)
        --从右面向上飞小鸟
        self.birdEffect02 = CompositeEffect.new("tx_0035bird02", display.cx + 200, display.cy + 70, self.bgEffect)
        self.birdEffect02:setScale(1.25)
    end))

    array:addObject(CCDelayTime:create(2.25))

    self.birdEffect:runAction(CCRepeatForever:create(CCSequence:create(array)))
    
    --CompositeEffect.new("tx_txt_trade_1",  display.cx, display.cy, self)
    
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("effects/tx_qianghua.ExportJson")
    local armature = CCArmature:create("tx_qianghua")
    --self:addChild( armature)
end

function ClsLoginLayerBase:mkJsonUI()
end

--是否可以点击太快了，间隔时间定为1500
function ClsLoginLayerBase:checkClickOperate(call_back)
    if CCTime:getmillistimeofCocos2d() - self.cur_click_time < self.interval_time then 
        return false
    end
    self.cur_click_time = CCTime:getmillistimeofCocos2d()
    
    local ClsUpdateAlert = require("update/updateAlert")
    ClsUpdateAlert:showStopSvrNoticeInfo(function( ... )
        -- if not ClsUpdateAlert:checkUpdate() then 
        --     return
        -- end
        if STOP_SVR_ANNOUNCE then
            local Alert = require("ui/tools/alert")
            local ui_word = require("game_config/ui_word")
            Alert:warning({msg = ui_word.LOGIN_MAINTAIN, size = 26})
            return
        end

        local start_and_login_data = getGameData():getStartAndLoginData()
        local left_time = start_and_login_data:getWaitingLoginLeftTime()
        if left_time then
            local reLinkUI = require("ui/loginRelinkUI"):maintainObj()
            reLinkUI:mkWaitingLoginDialog(left_time)
            return false
        end

        call_back()
    end)
end


function ClsLoginLayerBase:onExit()
    ReleaseTexture(self)
end

function ClsLoginLayerBase:onFinish()  -- 释放
    if not tolua.isnull(self.bgEffect) then
        self.bgEffect:removeTexture()
    end

    if not tolua.isnull(self.birdEffect) then
        self.birdEffect:removeTexture()
    end

    if not tolua.isnull(self.birdEffect02) then
        self.birdEffect02:removeTexture()
    end
    
end

return ClsLoginLayerBase
