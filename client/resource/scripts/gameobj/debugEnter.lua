local ui_word = require("scripts/game_config/ui_word")
local ListCell = require("ui/tools/ListCell")
local ListView = require("ui/tools/ListView")

local TextureCachedInfoPanel = class("TextureCachedInfoPanel", function() return CCLayerColor:create(ccc4(0,0,0,0)) end)
function TextureCachedInfoPanel:ctor()
	cclog("==============================2DCachedTextureInfo begin===============================================")
	CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
	cclog("==============================2DCachedTextureInfo end==============================")

	cclog("==============================flash begin===============================================")
	dumpGaf()
	cclog("==============================flash end==============================")	
	
end

local SpriteFrameCachedInfoPanel = class("SpriteFrameCachedInfoPanel", function() return CCLayerColor:create(ccc4(0,0,0,150)) end)
function SpriteFrameCachedInfoPanel:ctor()
	-- local items = {}

	-- if self.listView~=nil then
	-- 	self.listView:removeFromParentAndCleanup(true)
	-- 	self.listView = nil
	-- end
	-- local cell_size = CCSize(display.width,30)
	-- for k,guild in ipairs(guildList) do
	-- 	local item = ListCell.new(cell_size)
	-- 	item:addChild(createBMFont({text =PANEL_ENTERS[i].name,size = 16,align=ui.TEXT_ALIGN_CENTER, x=0,y=PANEL_ENTERS[i].y}))
	-- 	table.insert(items,item)
	-- end

	-- self.listView = ListView.new(CCRect(0,0,display.width,display.height), items, 7, ListView.DIRECTION_VERTICAL,1)
	-- self.listView:setTouchEnabled(true)
	-- self:addChild(self.listView)
end

local DebugMainLayer = class("DebugMainLayer", function() return CCLayerColor:create(ccc4(0,0,0,120)) end)
local MAIN_MAGIN_X = 100
local PANEL_MAGIN_X = 100

local PANEL_TYPE_2TC = 1
local PANEL_TYPE_3TC = 2
local PANEL_TYPE_3EF = 3
local PANEL_TYPE_NOR = 4
local PANEL_TYPE_LUA = 5

local PANEL_ENTERS = {
	{["type"]=PANEL_TYPE_2TC,["name"]= "2DTextureCached"},
	{["type"]=PANEL_TYPE_3TC,["name"]= "3DTextureCached"},
	{["type"]=PANEL_TYPE_3EF,["name"]= "3DEffect"},
	{["type"]=PANEL_TYPE_NOR,["name"]= "NormalMemory"},
	{["type"]=PANEL_TYPE_LUA,["name"]= "LuaMemory"},
}

function DebugMainLayer:ctor()
	self.panelEnters = {}
	local enterX = 5
	local enterY = 400
	for i=1,#PANEL_ENTERS do
		local enter = createBMFont({text =PANEL_ENTERS[i].name,size = 20,align=ui.TEXT_ALIGN_LEFT, x=enterX,y=enterY})
		enter:setAnchorPoint(ccp(0,0.5))
		enter.pType = PANEL_ENTERS[i].type
		self:addChild(enter)
		self.panelEnters[#self.panelEnters+1] = enter

		enterY = enterY-(enter:getContentSize().height/2+5)
		local line = createBMFont({text ="--------------------",size = 20,align=ui.TEXT_ALIGN_LEFT, x=enterX,y=enterY})
		line:setAnchorPoint(ccp(0,0.5))
		self:addChild(line)
		enterY = enterY-(enter:getContentSize().height/2+5)
	end

	self.curPanel = nil

	local function onTouch(eventType, x, y)
		local pos = self:convertToNodeSpace(ccp(x, y))
		if eventType == "began" then
			for i=1,#self.panelEnters do
				if self.panelEnters[i]:getTouchRect():containsPoint(pos) then
					self:turnPanel(self.panelEnters[i].pType)
					break
				end
			end
			if self:boundingBox():containsPoint(pos) then
				return true
			end
			return false
		elseif eventType == "ended" then
			
		end
	end

	self:registerScriptTouchHandler(onTouch, false, -128, true)
	self:setTouchEnabled(true)
	self:setZOrder(50)

	--self:turnPanel(PANEL_TYPE_TC)
end

function DebugMainLayer:turnPanel(type)
	if self.curPanel~=nil then
		self.curPanel:removeFromParentAndCleanup(true)
		self.curPanel = nil
	end
	local panel = nil
	if type == PANEL_TYPE_2TC then
		panel = TextureCachedInfoPanel.new()
	elseif type == PANEL_TYPE_3TC then
		Texture.getTotalTextureSize()
	elseif type == PANEL_TYPE_3EF then 
		cclog("==============================3DEffect begin==============================")
		local texture = ParticleEmitter.GetTotalMemory()
		print(texture/1024 .."KB")
		cclog("==================================3DEffect end===========================================")
	elseif  type == PANEL_TYPE_NOR then
		cclog("=========================dump memory begin====================================================")
		dumpMemory()
		cclog("=========================dump memory end====================================================")
	elseif type == PANEL_TYPE_LUA then
		local count = collectgarbage("count") / 1024
		cclog(T("lua 内存：%dM"), count)
	else
		return 
	end
	if panel==nil then
		return
	end
	self.curPanel=panel
	self.curPanel:setPosition(ccp(PANEL_MAGIN_X,0))
	self:addChild(self.curPanel)
end

local DebugEnterLayer = class("DebugEnterLayer", function() return CCLayerColor:create(ccc4(0,0,0,0)) end)
function DebugEnterLayer:ctor()
	--ping值显示
	-- rpc_ping_label = createBMFont({text ="ping".." : ",size = 20,align=ui.TEXT_ALIGN_CENTER,x = 40,y = 140})
	-- self:addChild(rpc_ping_label)


	self.debugMainLayer = nil

	if DEBUG > 0 then 
		local progress_pos = {20,70}
		
		rpc_ping_value = createBMFont({text = "",size = 10,align=ui.TEXT_ALIGN_CENTER, x = progress_pos[1] + 20,y = progress_pos[2]})
		rpc_ping_value:setAnchorPoint(ccp(0,0.5))
		self:addChild(rpc_ping_value)
		self.bg = CCLayerColor:create(ccc4(0,0,0,100))
		self.bg:setZOrder(-1)
		self.bg:setTouchEnabled(false)
		self.bg:setVisible(false)
		self:addChild(self.bg)

		self.lb_enter = createBMFont({text ="debug",size = 20,align=ui.TEXT_ALIGN_CENTER, x=40,y=85})
		self:addChild(self.lb_enter)

		self.touchBeginPos = ccp(0,0)
		self.touchEndPos = ccp(0,0)

		local function onTouch(eventType, x, y)
			local pos = self:convertToNodeSpace(ccp(x, y))
			if eventType == "began" then
				self.touchBeginPos.x,self.touchBeginPos.y = pos.x,pos.y
				if self.lb_enter:getTouchRect():containsPoint(pos) then
					return true
				end
				return false
			elseif eventType == "moved" then
				
			elseif eventType == "ended" then
				self.touchEndPos.x,self.touchEndPos.y = pos.x,pos.y
				local touchDis = math.sqrt(math.pow(self.touchBeginPos.x-self.touchEndPos.x,2)+math.pow(self.touchBeginPos.y-self.touchEndPos.y,2))
				if touchDis<=10 then
					self:switchMainLayer()
				end
			else

			end
		end

		self:registerScriptTouchHandler(onTouch, false, -129, true)
		self:setTouchEnabled(true)
	end
	self:setZOrder(50)
end

function DebugEnterLayer:switchMainLayer()
	if self.debugMainLayer == nil then
		self.debugMainLayer = DebugMainLayer.new()
		self.debugMainLayer:setPosition(ccp(MAIN_MAGIN_X,0))
		self.bg:setVisible(true)
		self:addChild(self.debugMainLayer)
	else
		self.bg:setVisible(false)
		self.debugMainLayer:removeFromParentAndCleanup(true)
		self.debugMainLayer = nil
	end
end

return DebugEnterLayer