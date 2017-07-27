
----自动悬赏遮挡层


local alert = require("ui/tools/alert")
local music_info=require("game_config/music_info")
local ClsDataTools = require("module/dataHandle/dataTools")
local ui_word = require("scripts/game_config/ui_word")
local ClsBaseView = require("ui/view/clsBaseView")

local ClsAutoPortRewardLayer = class("ClsAutoPortRewardLayer", ClsBaseView)

--页面参数配置方法，注意，是静态方法
function ClsAutoPortRewardLayer:getViewConfig()
    return {
        name = "ClsAutoPortRewardLayer",       --(选填）默认 class的名字
        type = UI_TYPE.TOP,        --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,          --(选填) 默认true, 是否吞掉下层页面的触摸事件
    }
end

function ClsAutoPortRewardLayer:onEnter()
	self.res_plist = {
		["ui/auto_trade.plist"] = 1,
	}
	LoadPlist(self.res_plist)

	self:initUi()
	self:addBtnEvent()

	self:regTouchEvent(self, function(event, x, y)
		return self:onTouch(event, x, y) end)

	local battle_data = getGameData():getBattleDataMt()
    if not battle_data:IsBattleStart() then
    	local set_y = 0
		local sceneDataHandler = getGameData():getSceneDataHandler()
		if sceneDataHandler:isInExplore() then
			set_y = 10
		end    	
    	getUIManager():close("ClsChatComponent")
        getUIManager():create("gameobj/chat/clsChatComponent", {layer_pos = UI_TYPE.TOP}, {panel_pos = ccp(0, set_y)})
    end
end


function ClsAutoPortRewardLayer:initUi(  )

	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/guild_auto_task.json")
	self:addWidget(self.panel)

	self.time_info = getConvertChildByName(self.panel, "time_info")
	self.btn_end  = getConvertChildByName(self.panel, "btn_end")	

	self:updateTimes()
end

function ClsAutoPortRewardLayer:updateTimes(  )
	-- local missionDataHandler = getGameData():getMissionData()
	-- local auto_mission_times = missionDataHandler:getAutoMissionTimes()

	-- self.time_info:setText(auto_mission_times)
end

function ClsAutoPortRewardLayer:addBtnEvent()

	self.btn_end:setPressedActionEnabled(true)
    self.btn_end:addEventListener(function()
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
    end,TOUCH_EVENT_ENDED)

end


function ClsAutoPortRewardLayer:onTouch(event, x, y)
	if event == "began" then
		return self:onTouchBegan(x, y)
	end
end

function ClsAutoPortRewardLayer:onTouchBegan(x , y)

	local str = ui_word.MISSION_AUTO_PORT_REWARD_STR

	alert:showAttention(str, function()
		local missionDataHandler = getGameData():getMissionData()
		missionDataHandler:askCancelAutoBounty()
	    
	end, nil, nil, {ok_text = ui_word.YES, cancel_text = ui_word.NO, is_notification = true, name_str = "ClsAutoPortRewardLayerCommonTips"})
 
	return true
end

function ClsAutoPortRewardLayer:closeMySelf()
	self:close()

	local battle_data = getGameData():getBattleDataMt()
    if battle_data:IsBattleStart() then
    	return
    end
	getUIManager():close("ClsChatComponent")
	local sceneDataHandler = getGameData():getSceneDataHandler()
	if sceneDataHandler:isInExplore() then
		getUIManager():create("gameobj/chat/clsChatComponent", {before_view = "ExploreUI"}, {panel_pos = ccp(0, 10)})
	end

	local port_layer = getUIManager():get("ClsPortLayer")
	if not tolua.isnull(port_layer) then
		getUIManager():create("gameobj/chat/clsChatComponent", {before_view = "ClsPortLayer"})
	end

end

function ClsAutoPortRewardLayer:onExit()
	UnLoadPlist(self.res_plist)
end

return ClsAutoPortRewardLayer


