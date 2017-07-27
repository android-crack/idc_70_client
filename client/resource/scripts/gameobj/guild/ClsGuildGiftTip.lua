-- 商会商店礼包提示界面
local music_info = require("scripts/game_config/music_info")
local ui_word = require("scripts/game_config/ui_word")
local ClsBaseView = require("ui/view/clsBaseView")
local CompositeEffect = require("gameobj/composite_effect")

local ClsGuildGiftTip = class("ClsGuildGiftTip", ClsBaseView)
local touch_rect = CCRect(368, 148, 82, 66)

function ClsGuildGiftTip:getViewConfig(...)
    return {
    		type =  UI_TYPE.TOP,
			is_swallow = false,   
		}
end

function ClsGuildGiftTip:onEnter(parameter)
	self.gift_info = parameter.gift_info
    self.res_plist = {
        ["ui/box.plist"] = 1
    }

    LoadPlist(self.res_plist)

    self.armature_tab = {
        "effects/tx_0190.ExportJson",
    }

    LoadArmature(self.armature_tab)
    self:configUI()
end

function ClsGuildGiftTip:configUI()
	local box_effect = CompositeEffect.new("tx_0190", 400, 177, self)
	local array = CCArray:create()
	array:addObject(CCDelayTime:create(1))
	array:addObject(CCCallFunc:create(function( )
		local show_lable = createBMFont({text = ui_word.GUILD_GIFT_GET_TEXT, size = 16, width = 260, color = ccc3(dexToColor3B(COLOR_GREEN_STROKE)),fontFile = FONT_CFG_1, x = 100, y = -30})
		box_effect:addChild(show_lable)
	end))
	self:runAction(CCSequence:create(array))

	self:regTouchEvent(self, function(eventType, x, y)
		local touch_point = ccp(x, y)
		is_in = touch_rect:containsPoint(touch_point)
		if is_in then
			self:onTouchCB()
		end
	end)
end

function ClsGuildGiftTip:onTouchCB()
	self:closeView()
	local guild_shop_data = getGameData():getGuildShopData()
	guild_shop_data:askGrabGuildGif(self.gift_info.giftId)
    
end

function ClsGuildGiftTip:closeView()
	self:close()
end

function ClsGuildGiftTip:getData()
	return self.gift_info
end

function ClsGuildGiftTip:updateData(info)
	self.gift_info = info
end

function ClsGuildGiftTip:onExit()
	UnLoadPlist(self.res_plist)
	UnLoadArmature(self.armature_tab)
    ReleaseTexture()
end

return ClsGuildGiftTip