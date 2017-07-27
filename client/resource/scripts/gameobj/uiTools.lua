--require("game_config/sailor/sailor_job")
local sailorJobs=require("game_config/sailor/id_job")
local skill_site=require("game_config/skill/skill_site")
local skill_info=require("game_config/skill/skill_info")
local tool=require("module/dataHandle/dataTools")
local ui_word = require("game_config/ui_word")
local music_info = require("game_config/music_info")
local news = require("game_config/news") 
local Alert = require("ui/tools/alert")

local Tools={}

function Tools:showGetRewardEfffect(parent, endCallBack, image, num, startPoint, destination, name, is_widget, reward)
	if tolua.isnull(parent) then
		return
	end

	local resPlist = {
		["ui/baowu.plist"] = 1,
		["ui/equip_icon.plist"] = 1,
		["ui/material_icon.plist"] = 1,
	}
		
	LoadPlist(resPlist)
	local CompositeEffect = require("gameobj/composite_effect")
	local point = startPoint or ccp(display.cx,display.cy + 30)
	local rect = CompositeEffect.new("tx_jiangli", point.x, point.y, parent, 999, nil, nil, nil, is_widget)
	rect:setScale(0)
	local function endCall()
		local array = CCArray:create()
		local time = 0.5
		array:addObject(CCDelayTime:create(time))
		array:addObject(CCCallFunc:create(function()
			UnLoadPlist(resPlist)
			if endCallBack then
				endCallBack()
			end
		end))
		parent:runAction(CCSequence:create(array))
	end
	-- num = num or 0
	local icon = display.newSprite(image)
	local size = icon:getContentSize()
	-- local numLabel = createBMFont({text = tostring(num), size = 20, color = ccc3(dexToColor3B(COLOR_GREEN_STROKE))})
	local nameLabel = nil
	-- if name then
	-- 	nameLabel = createBMFont({text = name, size = 20, color = ccc3(dexToColor3B(COLOR_GREEN_STROKE))})
	-- 	nameLabel:setPosition(ccp(size.width / 2, -size.height / 2 + 35))
	-- 	icon:addChild(nameLabel)
	-- end
	-- if image == "#common_icon_coin.png" or image == "#explore_food.png" then
	-- 	numLabel:setAnchorPoint(ccp(0, 0.55))
	-- 	numLabel:setPosition(ccp(size.width + 2, size.height / 2))
	-- else
	-- 	numLabel:setPosition(ccp(size.width / 2 + 30, size.height / 2 - 10))
	-- end
	-- icon:addChild(numLabel)
	local array = CCArray:create()
	local time = 0.28
	array:addObject(CCScaleTo:create(time, 1.2))
	array:addObject(CCMoveBy:create(time, ccp(0, 90)))
	array:addObject(CCCallFunc:create(function()
		
	end))
	local allArray = CCArray:create()
	allArray:addObject(CCSpawn:create(array))

	local array = CCArray:create()
	array:addObject(CCDelayTime:create(time))
	array:addObject(CCScaleTo:create(0.02, 1.0))
	array:addObject(CCDelayTime:create(0.32))

	allArray:addObject(CCSpawn:createWithTwoActions(CCSequence:create(array), CCCallFunc:create(function()
		
	end) ))
	--飞到左下角
	array = CCArray:create()
	array:addObject(CCScaleTo:create(0.32, 0.2))
	array:addObject(CCFadeTo:create(0.32, 255 * 0.5))
	array:addObject(CCMoveTo:create(0.32, destination or ccp(800, 30)))
	local spawn = CCSpawn:create(array)
	allArray:addObject(CCSpawn:createWithTwoActions(CCSequence:createWithTwoActions(CCDelayTime:create(0.64), spawn), CCCallFunc:create(function()
		
	end) ))

	--移除消失
	array = CCArray:create()
	array:addObject(CCDelayTime:create(0.96))
	array:addObject(CCCallFunc:create(function()
		rect:removeFromParentAndCleanup(true)
		endCall()
	end))

	allArray:addObject(CCSpawn:createWithTwoActions(CCSequence:create(array), CCCallFunc:create(function()
		
	end)))

	if reward then
		local item_res, amount, scale, name, _, _, color = getCommonRewardIcon(reward)
		local default_color = 1
		local msg = string.format(ui_word.REWARD_TIP,RICHTEXT_COLOR_NORMAL[color]..name,RICHTEXT_COLOR_NORMAL[default_color]..amount)
	    local item = {
	        ["msg"] = msg,
	        ["show"] = true,
	    }

		Alert:warning(item)
	end

	local allSpawn = CCSpawn:create(allArray)
	rect:runAction(allSpawn)
	rect:addChild(icon, 100)
end

function Tools:showAction(object, offX, offY, noEnter, callBack, showTime) --面板进入出去动画
	local offX = offX or 0
	local offY = offY or 0
	local showTime = showTime or 0.5
	local array = CCArray:create()
	local action = nil
	if noEnter then
		action = CCEaseBackIn:create(CCMoveBy:create(showTime, ccp(offX, offY)))
	else
		action = CCEaseBackOut:create(CCMoveBy:create(showTime, ccp(offX, offY)))
	end
	array:addObject(action)
	array:addObject(CCCallFunc:create(function() 
		if type(callBack) == "function" then
			callBack()
		end
	end))
	object:runAction(CCSequence:create(array))
end

function Tools:getLoginStatus(orign_time)
	local last_login_time =  ""
	local user_judget_time = 0
	if orign_time ~= ONLINE then
		local original_time = os.time() - tonumber(orign_time)
		if original_time <= 0 then
			original_time = 5 
		end
	    local time, time_tab = tool:getMostCnTimeStr(original_time)
	    if tonumber(time_tab.d) > 0 then
	    	user_judget_time = 25  --超过24小时写死25小时用于判断
	    	last_login_time = string.format(news.FRIENDS_LOGIN_DAY.msg, time_tab.d)
	    elseif tonumber(time_tab.h) > 0 then
	    	last_login_time = string.format(news.FRIENDS_LOGIN_HOUR.msg, time_tab.h)
	    elseif tonumber(time_tab.m) > 0 then
	    	last_login_time = string.format(news.FRIENDS_LOGIN_MINUTE.msg, time_tab.m)
	    elseif tonumber(time_tab.s) > 0 then
	    	last_login_time = string.format(news.FRIENDS_LOGIN_MINUTE.msg, tostring(1))
	    end
	else
		last_login_time = ui_word.FRIEND_ONLINE
	end

	if orign_time == 0 then 
		user_judget_time = 0 
	end
	return last_login_time, user_judget_time
end

function Tools:scrollTipShowAction(target,callback)
	target:setScaleY(0)
    local array = CCArray:create()
    array:addObject(CCScaleTo:create(0.1, 0.95, 1.13))
    array:addObject(CCScaleTo:create(0.05, 0.95, 1.13))
    array:addObject(CCScaleTo:create(0.1, 1, 1))
    array:addObject(CCCallFunc:create(function ()
    	if type(callback) == "function" then
    		callback()
    	end
    end))
    local scale_action = CCSequence:create(array)
    target:runAction(CCSpawn:createWithTwoActions(scale_action, CCFadeIn:create(0.1)))
end

function Tools:scrollTipCloseAction(target,callback)
	target:setScaleY(1)
    local array = CCArray:create()
    -- array:addObject(CCScaleTo:create(0.05, 1, 1.13))
    -- array:addObject(CCScaleTo:create(0.1, 0.95, 1.13))
    array:addObject(CCScaleTo:create(0.3, 1, 0))
    array:addObject(CCCallFunc:create(function ()
    	if type(callback) == "function" then
    		callback()
    	end
    end))
    local scale_action = CCSequence:create(array)
    target:runAction(CCSpawn:createWithTwoActions(scale_action, CCFadeOut:create(0.3)))
end

function Tools:autoUpdatePos(btn, btn_sp, btn_label)
	local btn_size = btn:getSize()
    local spr_size = btn_sp:getSize()
    local sp_pos = btn_sp:getPosition()
    local label_size = btn_label:getSize()
    local label_pos = btn_label:getPosition()
    local spr_scale = btn_sp:getScale()
    spr_scale = string.format("%0.1f", spr_scale)
    
    local sp_cur_width = spr_size.width * spr_scale
    local offset = label_pos.x - (sp_pos.x + sp_cur_width / 2)
    if offset < 0 then
        offset = 0
    end

    local total_width = sp_cur_width + offset + label_size.width
    local sp_final_x = -(total_width / 2) + sp_cur_width / 2
    local label_final_x = sp_final_x + sp_cur_width / 2 + offset
    btn_sp:setPosition(ccp(sp_final_x, sp_pos.y))
    btn_label:setPosition(ccp(label_final_x, label_pos.y))
end

return Tools
