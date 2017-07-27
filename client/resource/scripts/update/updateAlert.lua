local convertTab = {
    Widget = "UIWidget",
    RootWidget = "UIRootWidget",
    Layout = "UILayout",
    Button = "UIButton",
    CheckBox = "UICheckBox",
    ImageView = "UIImageView",
    Label = "UILabel",
    LabelAtlas = "UILabelAtlas",
    LabelBMFont = "UILabelBMFont",
    ListView = "UIListView",
    LoadingBar = "UILoadingBar",
    ScrollView = "UIScrollView",
    Slider = "UISlider",
    TextField = "UITextField",
    PageView = "UIPageView"
}

local function convertUIType(ui)
    if ui then 
        tolua.cast(ui, convertTab[ui:getDescription()])
    end
end

local function getConvertChildByName(parent, childName)
	local child = parent:getChildByName(childName)
    if child then 
        convertUIType(child)
    end
    return child
end

local UpdateAlert = {}

-- 更新app
function UpdateAlert:updateApp()
	local scene = CCDirector:sharedDirector():getRunningScene()
	local panel = GUIReader:shareReader():widgetFromJsonFile("json/tips_update.json")
	panel:setAnchorPoint(ccp(0.5, 0.5))
	panel:setPosition(ccp(display.cx, display.cy))
	local layer = UILayer:create()
	scene:addChild(layer, 100)
	layer:addWidget(panel)
	
	local btn_ok = getConvertChildByName(panel, "btn_middle")
	btn_ok:setPressedActionEnabled(true)
	
	local function closeGame()
		CCDirector:sharedDirector():endToLua()
	end 
	
	btn_ok:addEventListener(function()
		if GTab.APP_URL ~= nil and GTab.APP_URL ~= "" then
            CCNative:openURL( GTab.APP_URL )
        end
		closeGame()
	end, TOUCH_EVENT_ENDED)
	
	local btn_close = getConvertChildByName(panel, "btn_close")
	btn_close:setPressedActionEnabled(true)
	btn_close:addEventListener(closeGame, TOUCH_EVENT_ENDED)
	
	local txt_change = getConvertChildByName(panel, "txt_change")
	txt_change:setVisible(true)
end 

--更新patch
function UpdateAlert:updatePatch(callback ,size)
	local scene = CCDirector:sharedDirector():getRunningScene()
	local panel = GUIReader:shareReader():widgetFromJsonFile("json/tips_update.json")
	panel:setAnchorPoint(ccp(0.5, 0.5))
	panel:setPosition(ccp(display.cx, display.cy))
	local layer = UILayer:create()
	scene:addChild(layer, 100)
	layer:addWidget(panel)
	
	local btn_ok = getConvertChildByName(panel, "btn_middle")
	btn_ok:setPressedActionEnabled(true)
	
	local function closeGame()
		CCDirector:sharedDirector():endToLua()
	end 
	
	btn_ok:addEventListener(function()
		layer:removeFromParentAndCleanup(true)
		if callback then callback() end
		--require("update/updatePatch"):start(UpdateInfo)
	end, TOUCH_EVENT_ENDED)
	
	local btn_close = getConvertChildByName(panel, "btn_close")
	btn_close:setPressedActionEnabled(true)
	btn_close:addEventListener(closeGame, TOUCH_EVENT_ENDED)
	
	local show_size = size/(1024*1024)
	if show_size < 0.01 then 
		show_size = 0.01
	end 
	local show_size = string.format("%.2f", show_size)
	local txt_update = getConvertChildByName(panel, "txt_update")
	local txt = txt_update:getStringValue()
	txt_update:setText(string.format(txt, show_size))
	txt_update:setVisible(true)
end 

--检查更新patch
function UpdateAlert:checkUpdate()
	-- 不需要更新
	if GTab.VERSION_UPDATE == GTab.VERSION_SERVER then
		return true
	end 
	
	-- 要求重启更新游戏  
	local scene = CCDirector:sharedDirector():getRunningScene()
	local panel = GUIReader:shareReader():widgetFromJsonFile("json/tips_update.json")
	panel:setAnchorPoint(ccp(0.5, 0.5))
	panel:setPosition(ccp(display.cx, display.cy))
	local layer = UILayer:create()
	scene:addChild(layer, 100)
	layer:addWidget(panel)
	
	local function closeGame()
		CCDirector:sharedDirector():endToLua()
	end 
	
	local btn_ok = getConvertChildByName(panel, "btn_middle")
	btn_ok:setPressedActionEnabled(true)
	btn_ok:addEventListener(closeGame, TOUCH_EVENT_ENDED)
	
	local btn_close = getConvertChildByName(panel, "btn_close")
	btn_close:setPressedActionEnabled(true)
	btn_close:addEventListener(closeGame, TOUCH_EVENT_ENDED)
	
	local txt_restart = getConvertChildByName(panel, "txt_restart")
	txt_restart:setVisible(true)
	
	return false
end 

function UpdateAlert:showMaintainUI(notice)
	local scene = CCDirector:sharedDirector():getRunningScene()
	local panel = GUIReader:shareReader():widgetFromJsonFile("json/tips_maintain.json")
	panel:setAnchorPoint(ccp(0.5, 0.5))
	panel:setPosition(ccp(display.cx, display.cy))
	local layer = UILayer:create()
	scene:addChild(layer, 100)
	layer:addWidget(panel)

	local function closeGame()
		CCDirector:sharedDirector():endToLua()
	end
	
	local title = getConvertChildByName(panel, "title")
	title:setText(notice.title)

	local content = getConvertChildByName(panel, "text")
	content:setText(notice.content)
	
	local btn_close = getConvertChildByName(panel, "btn_close")
	btn_close:setPressedActionEnabled(true)
	btn_close:addEventListener(closeGame, TOUCH_EVENT_ENDED)
end

function UpdateAlert:showStopSvrNoticeInfo(call_back)
	if not (DEBUG and DEBUG <= 0) then
		call_back()
		return
	end
	local notice_id = "1"
	local function getNoticeDataCallBack( content , key )
		local notice_info = json.decode(content)
	    local scene = key or notice_id
	    if notice_info and notice_info[scene] then
	    	local notice = notice_info[scene]
	    	local ClsUpdateAlert = require("update/updateAlert")
	    	ClsUpdateAlert:showMaintainUI(notice)
	    else
	    	call_back()
	    end
	end

	if GTab.CHANNEL_ID == "tencent" then
        local args = {notice_id, function( content )
        	getNoticeDataCallBack(content)
        end}
        -- 调用 Java 方法
        luaj.callStaticMethod("com/qtz/dhh/msdk/DhhMsdk", "getNoticeData", args)
    elseif GTab.CHANNEL_ID == "tencent_ios" then
		local content = QSDK:sharedQSDK():getNoticeData(notice_id)
		getNoticeDataCallBack(content, tonumber(notice_id))
    else
    	call_back()
    end
end

--网络异常提示
function UpdateAlert:showNetworkHelp(callback)
	if self.is_show_network then return end 
	
	local scene = CCDirector:sharedDirector():getRunningScene()
	local panel = GUIReader:shareReader():widgetFromJsonFile("json/tips_network.json")
	panel:setAnchorPoint(ccp(0.5, 0.5))
	panel:setPosition(ccp(display.cx, display.cy))
	local layer = UILayer:create()
	scene:addChild(layer, 9999)
	layer:addWidget(panel)
	
	local btn_close = getConvertChildByName(panel, "btn_close")
	btn_close:setPressedActionEnabled(true)
	btn_close:addEventListener(function()
		layer:removeFromParentAndCleanup(true)
		self.is_show_network = false
		if callback then 
			callback()
		end 
	end, TOUCH_EVENT_ENDED)
	self.is_show_network = true 
end 

return UpdateAlert
 