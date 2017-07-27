--
-- Author: Ltian
-- Date: 2015-06-16 18:59:55
--

local SailorAttView = class("SailorAttView", function () return CCLayer:create() end)
local sailor_exp_info = require("game_config/sailor/sailor_exp_info")
local ui_word = require("game_config/ui_word")

function SailorAttView:ctor(data, noShowName, pos, show_add_att)
	self.sailorDatas = data
    self.noShowName = noShowName
	self:initUI(tolua.isnull(pos) and ccp(0,0) or pos)
	self:setData(data)
end
function SailorAttView:initUI(pos)
	--航海士名字
	self.sailorName = createBMFont({text = "", size = 15, color = ccc3(dexToColor3B(COLOR_CREAM_STROKE)), fontFile = FONT_CFG_1})
	self.sailorName:setPosition(ccp(100,70))
	--航海士等级
	self.sailorLevel = createBMFont({text = "LV.34", size = 15, color = ccc3(dexToColor3B(COLOR_WHITE_STROKE))})
	self.sailorLevel:setPosition(ccp(20,45))
	--属性提升label
	-- self.attDes = createBMFont({text = sailor_job[self.sailorDatas.job[1]].explain .. "kkkkkkkkk", anchor = ccp(0,0.5), size = 15, 
        -- color = ccc3(dexToColor3B(COLOR_CREAM_STROKE)), fontFile = FONT_CFG_1})
	-- self.attDes:setPosition(ccp(55 + pos.x, -140 + pos.y))
	--经验条
    local progressBg = display.newSprite("#common_bar_bg1.png")
    progressBg:setAnchorPoint(ccp(0, 0.5))
    progressBg:setScale(0.85)
    local size = progressBg:getContentSize()
    local progresBar = CCProgressTimer:create(display.newSprite("#common_bar1.png"))
    progresBar:setType(kCCProgressTimerTypeBar)
    progresBar:setMidpoint(ccp(0,1))
    progresBar:setBarChangeRate(ccp(1, 0))
    progresBar:setPosition(ccp(size.width / 2, size.height / 2))
    progressBg:addChild(progresBar)
    self.progresBar = progresBar
    self.progressBg = progressBg
    progressBg:setPosition(ccp(40, 45))
    --
    local percentLable = createBMFont({text = "", size = 14})
    percentLable:setPosition(ccp(size.width / 2, size.height / 2))
    progressBg:addChild(percentLable)
    progressBg:setScale(0.8)
    self.percentLable = percentLable

    local base_y = -140
    local left_x = pos.x
    local right_x = pos.x + 150
    local offset_y = -30
    local person_attr_lab = createBMFont({text = ui_word.SAILOR_PRESON_ATTR, fontFile = FONT_CFG_1, x = left_x, y = base_y + pos.y, size = 16, color = ccc3(dexToColor3B(COLOR_CREAM_STROKE))})
    person_attr_lab:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
    self:addChild(person_attr_lab)
    --左边属性
    local atk_attr_lab = createBMFont({text = ui_word.ATTR_SWORD, fontFile = FONT_CFG_1, x = left_x, y = base_y + pos.y + offset_y, size = 16, color = ccc3(dexToColor3B(COLOR_CREAM_STROKE))})
    atk_attr_lab:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
    self:addChild(atk_attr_lab)
    self.atk_attr_lab = atk_attr_lab
    local hp_attr_lab = createBMFont({text = ui_word.ATTR_HP, fontFile = FONT_CFG_1, x = left_x, y = base_y + pos.y + offset_y*2, size = 16, color = ccc3(dexToColor3B(COLOR_CREAM_STROKE))})
    hp_attr_lab:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
    self:addChild(hp_attr_lab)
    self.hp_attr_lab = hp_attr_lab
    
    local atk_lab_width = atk_attr_lab:getContentSize().width
    local hp_lab_width = hp_attr_lab:getContentSize().width
    local add_x = math.max(atk_lab_width, hp_lab_width)
    self.atk_attr_lab.num_lab = createBMFont({text = "0", size = 16, color = ccc3(dexToColor3B(COLOR_GREEN)),x = add_x})
    self.atk_attr_lab.num_lab:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
    self.atk_attr_lab:addChild(self.atk_attr_lab.num_lab)
    self.hp_attr_lab.num_lab = createBMFont({text = "0", size = 16, color = ccc3(dexToColor3B(COLOR_GREEN)),x = add_x})
    self.hp_attr_lab.num_lab:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
    self.hp_attr_lab:addChild(self.hp_attr_lab.num_lab)
    
    --右边的属性
    local boat_attr_lab = createBMFont({text = ui_word.SAILOR_BOAT_ATTR, fontFile = FONT_CFG_1, x = right_x, y = base_y + pos.y, size = 16, color = ccc3(dexToColor3B(COLOR_CREAM_STROKE))})
    boat_attr_lab:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
    self:addChild(boat_attr_lab)
    
    self.attr_1_lab = createBMFont({text = "", fontFile = FONT_CFG_1, x = right_x, y = base_y + pos.y + offset_y, size = 16, color = ccc3(dexToColor3B(COLOR_CREAM_STROKE))})
    self.attr_1_lab:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
    self.attr_1_lab.num_lab = createBMFont({text = "0", size = 16, color = ccc3(dexToColor3B(COLOR_GREEN))})
    self.attr_1_lab.num_lab:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
    self.attr_1_lab:addChild(self.attr_1_lab.num_lab)
    self:addChild(self.attr_1_lab)
    
    self.attr_2_lab = createBMFont({text = "", fontFile = FONT_CFG_1, x = right_x, y = base_y + pos.y + offset_y*2, size = 16, color = ccc3(dexToColor3B(COLOR_CREAM_STROKE))})
    self.attr_2_lab:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
    self.attr_2_lab.num_lab = createBMFont({text = "0", size = 16, color = ccc3(dexToColor3B(COLOR_GREEN))})
    self.attr_2_lab.num_lab:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
    self.attr_2_lab:addChild(self.attr_2_lab.num_lab)
    self:addChild(self.attr_2_lab)
    
    self:addChild(progressBg, 2)
    self:addChild(self.sailorName)
    self:addChild(self.sailorLevel)
    if self.noShowName == true then
        self.sailorName:setVisible(false)
        person_attr_lab:setVisible(false)
        boat_attr_lab:setVisible(false)
        atk_attr_lab:setVisible(false)
        hp_attr_lab:setVisible(false)
        self.attr_1_lab:setVisible(false)
        self.attr_2_lab:setVisible(false)
    end

end

local sailor_attrs = {
    fv_defense = ui_word.BOAT_DURABLE..ui_word.SIGN_COLON,  ----船舶防御
    fv_hp_max = ui_word.STR_BOAT_SAILOR..ui_word.SIGN_COLON,   ----船舶耐久
    fv_att_far = ui_word.FLEET_FAR_PORPERTY..ui_word.SIGN_COLON, ----火炮伤害
    fv_far_range = ui_word.FLEET_PORPERTY_FAR_DIST..ui_word.SIGN_COLON,  ---火炮射程
    fv_att_near = ui_word.FLEET_NEAR_PORPERTY..ui_word.SIGN_COLON,    ---近战伤害
    fv_anger_init = ui_word.FLEET_PORPERTY_INIT_AIR..ui_word.SIGN_COLON, ----起始士气
    fv_speed = ui_word.ATTR_SPEED..ui_word.SIGN_COLON,---航行速度

}

local sailor_star_exp = {
    "d_exp",
    "d_exp",
    "c_exp",  
    "b_exp",  
    "a_exp",
    "s_exp",
}

function SailorAttView:setData(data)
	self.sailorDatas = data
	local name = data.name
	local level = data.level
	local levelStr = "Lv."..level
    local sailor_star = data.star 
    local sailor_exp = sailor_star_exp[sailor_star]  
	local totalExp = sailor_exp_info[data.level][sailor_exp]
    local percent = data.exp / totalExp * 100
     if percent > 100 then
        percent = 100
    end
    local playerData = getGameData():getPlayerData()
    if self.sailorDatas.level >= playerData.maxPlayerLevel then
        percent = 0
    end
    self.progresBar:setPercentage(percent)
    self.percentLable:setString(string.format("%0.1f", percent) .. "%")
	self.sailorName:setString(name)
	self.sailorLevel:setString(levelStr)
    
    if self.noShowName == true then
        return
    end

    local attrs_info = self.sailorDatas
    for k, v in pairs(self.sailorDatas.attrs) do
        attrs_info[v.attrName] = v.attrValue
    end
    self.atk_attr_lab.num_lab:setString(tostring(attrs_info.fv_att_sailor))
    self.hp_attr_lab.num_lab:setString(tostring(attrs_info.fv_hp_sailor))
    
    local num_add_x = 0
    local index = 1
    for k, v in pairs(sailor_attrs) do
        if attrs_info[k] then
            local ui_lab = self["attr_"..index.."_lab"]
            ui_lab:setString(v)
            local now_width = ui_lab:getContentSize().width
            if now_width > num_add_x then
                num_add_x = now_width
            end
            ui_lab.num_lab:setString(tostring(attrs_info[k]))
            index = index + 1
            if index > 2 then
                break
            end
        end
    end
    for i = 1, 2 do
        local ui_lab = self["attr_"..i.."_lab"]
        if i < index then
            ui_lab:setVisible(true)
            ui_lab.num_lab:setPosition(ccp(num_add_x, 0))
        else
            ui_lab:setVisible(false)
        end
    end
end


return SailorAttView