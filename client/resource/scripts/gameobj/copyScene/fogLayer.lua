--迷雾层
local music_info = require("game_config/music_info")
local fog_config = {   -- 迷雾配置
    [1] = {pos = ccp(168,549), off_x = -15, off_y = 9},
    [2] = {pos = ccp(795,577), off_x = 10, off_y = 6},
    [3] = {pos = ccp(794,98), off_x = 12, off_y = -23},
    [4] = {pos = ccp(145,143), off_x = -21, off_y = -12},
    [5] = {pos = ccp(335,-29), off_x = -13, off_y = -23},
    [6] = {pos = ccp(868,410), off_x = 14, off_y = 6},
    [7] = {pos = ccp(37,326), off_x = -15, off_y = -16},
    [8] = {pos = ccp(351,669), off_x = 0, off_y = 12},
    [9] = {pos = ccp(575,701), off_x = 12, off_y = 8},
    [10] = {pos = ccp(665,-1), off_x = 12, off_y = -24},
    [11] = {pos = ccp(50,364), off_x = -12, off_y = 8},
    [12] = {pos = ccp(383,675), off_x = 16, off_y = 15},
    [13] = {pos = ccp(873,364), off_x = 17, off_y = -22},
    [14] = {pos = ccp(611,-13), off_x = -15, off_y = -30},
}

local function newLayer()
    return CCLayer:create()
end

local ClsFogLayer = class("ClsFogLayer", newLayer);

function ClsFogLayer:ctor(param)
   self.fog_type = param.type or 1 --依据type，选择不同的迷雾配置位置，位置策划填
   self.btn_call_back = param.call_back
   self.exit_call_back = param.exit_call_back
   self:evShowForge()
end

function ClsFogLayer:evShowForge()  --显示迷雾
    self.fog_tab = {}
    for k, v in ipairs(fog_config) do
        self.fog_tab[k] = getChangeFormatSprite("ui/bg/bg_fog.png")
        self.fog_tab[k]:setScale(2)
        self.fog_tab[k]:setPosition(v.pos)
        self:addChild(self.fog_tab[k])
    end 
end

function ClsFogLayer:setExitCallBack(value)
   self.exit_call_back = value
end

function ClsFogLayer:setBtnCallBack(value)
    self.btn_call_back = value
end

function ClsFogLayer:evHideForge()
    audioExt.playEffect(music_info.EX_FOG.res)
    local t = 1
    for i, v in ipairs(fog_config) do
        local ac = CCMoveBy:create(t, ccp(v.off_x * 25, v.off_y * 25))
        local action = nil
        if i == #fog_config then --移除最后一个
            local actionArray = CCArray:create()
            local function callBack()
               if self.exit_call_back then
                    self.exit_call_back()
                end
            end
            local funcCallBack = CCCallFunc:create(callBack)
            actionArray:addObject(ac)
            actionArray:addObject(funcCallBack)
            action = CCSequence:create(actionArray)
        else
            action = ac
        end
        self.fog_tab[i]:runAction(action)
    end
end

function ClsFogLayer:openForget(skill_id)--开瞭望镜
    audioExt.playEffect(music_info.EX_FOG.res)  
    local function call_back()
        local level = 1
        local appointSkills = getGameData():getSailorData():getRoomSailorsSkill()
        level = appointSkills[skill_id].level
        local t = 0.5
        for i, v in pairs(fog_config) do
            local ac = CCMoveBy:create(t, ccp(v.off_x * level, v.off_y * level))
            local action = nil
            if i == #fog_config then
                local actionArray = CCArray:create()
                local function removeBtn()
                    if self.btn_call_back then
                        self.btn_call_back()  --移除望远镜按钮
                    end
                end
                local funcCallBack = CCCallFunc:create(removeBtn)
                actionArray:addObject(ac)
                actionArray:addObject(funcCallBack)
                action = CCSequence:create(actionArray)
            else
                action = ac
            end
            self.fog_tab[i]:runAction(action)
        end
    end
    call_back()
end

return ClsFogLayer
