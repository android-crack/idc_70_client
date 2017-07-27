--------剧情对话（压黑边的形式）
local ui = require("base/ui/ui")
local sailor_info = require("game_config/sailor/sailor_info")
local commonBase = require("gameobj/commonFuns")
local tool = require("module/dataHandle/dataTools")
local RichLabel = require("module/richLabel")
local ui_word = require("game_config/ui_word")
local plotVoiceAudio=require("gameobj/plotVoiceAudio")
------------------------------------------------------
-- modify By Hal 2015-09-06, Type(BUG) - redmine 19304
local RichLabel = require("module/richLabel")
------------------------------------------------------
local ClsBaseView = require("ui/view/clsBaseView")
local PlotDialog = class("PlotDialog", ClsBaseView)

function PlotDialog:getViewConfig()
    return {
        name = "PlotDialog",
        type = UI_TYPE.DIALOG,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
    }
end

PlotDialog.textureRes = {}

local dialog_voice_handler = nil

---显示头像类型(依据任务配置表)
local SEAMAN_DATA = {
	ROLE_HEAD = 1, 
	SEAMAN_HEAD = 2, 
	MATE = 999,
}

---显示水手、大副对话
local DIALOG_TYPE = {
	SEAMAN = 1,
	MATE = 2,
}

function PlotDialog:onEnter(dialog_tab)
	self.dialog_tab = dialog_tab
	self.dialog_count = #self.dialog_tab 
	self.dialog_index = 1		
	---当前对话框类型
	self.curShowType = 0
	self.showDialog = true
	---内容淡入的时间(解决背景框缩放时字体不清晰的问题)
	self.contentTime = 0
	self.textureRes = {}
	local playerData = getGameData():getPlayerData()
	self.player_name = playerData:getName()
	self:regTouchEvent(self, function(eventType, x, y)
		if eventType =="began" then 
			if not self.notClick then
			   self:say(self.dialog_tab[self.dialog_index])
			end
			return true 
		end
	end)
	
	if self.dialog_count > 0 then
		self:say(self.dialog_tab[self.dialog_index])
	end
	self:setTouchEnabled(true)
end

function PlotDialog:act_call_back(item)
	if tolua.isnull(self.plot_bg) then return end   
   	if not tolua.isnull(self.seaman) then
	   self.seaman:removeFromParentAndCleanup(true)
	end 
	if not tolua.isnull(self.label) then
       self.label:removeFromParentAndCleanup(true)
	end
   	self.dialog_index = self.dialog_index + 1
	local seaman_info = item[1]
	local name = item[2]..":"
	local is_right = (item[3] == 2)
	local txtTab = item[4] 
	local playerData = getGameData():getPlayerData()
	local role_id = playerData:getRoleId()  -- 不同的角色，对话可能不同
	local role_name = playerData:getName()
	local txt = txtTab[role_id] or txtTab
	local musicName = item[5]
	local delayTime = item[6]
	if type(musicName) == "string" and string.len(musicName) > 0 then
	   if dialog_voice_handler ~= nil and type(dialog_voice_handler) == "number" then
		   audioExt.stopEffect(dialog_voice_handler)
		   dialog_voice_handler = nil
	   end 
	   dialog_voice_handler = plotVoiceAudio.playVoiceEffect(musicName)
	end
	if type(txt) ~= "string" then
		txt = ""
	end
	if delayTime ~= nil and delayTime > 0 then
		self.notClick = true
		local act = CCSequence:createWithTwoActions(CCDelayTime:create(delayTime), CCCallFunc:create(function()
			self:say(self.dialog_tab[self.dialog_index])
		end))
		self:runAction(act)
	else
		self.notClick = false
	end
	
	txt = commonBase:repString(txt)	
	if seaman_info == SEAMAN_DATA.MATE then
		self.seaman = display.newSprite("#common_head_bg2.png", display.left + 80, display.bottom + 70)
		self.seaman:setOpacity(0)
		self.plot_bg:addChild(self.seaman)
		local mateSize = self.seaman:getContentSize()
		
		local sailor_data = getGameData():getSailorData()
		local roomSailor = sailor_data:getCaptain()
		if roomSailor then
			local sailor = tool:getSailor(roomSailor)
			local spriteHead = display.newSprite(sailor.res)
			self.textureRes[#self.textureRes + 1] = sailor.res
			local headSize = spriteHead:getContentSize()
			spriteHead:setScale(mateSize.height / headSize.height)
			spriteHead:setPosition(mateSize.width * 0.5, mateSize.height * 0.5)
			self.seaman:addChild(spriteHead)			
			name = sailor.name ..":"
		end
		
		local mate_frame = display.newSprite("#common_head_name.png", mateSize.width * 0.5, 15)
		local mate_size = mate_frame:getContentSize()
		local mate_label = createBMFont({text = ui_word.SAILOR_DAFU, size = 16, fontFile = FONT_TITLE})
		mate_label:setPosition(mate_size.width*0.5, mate_size.height*0.5)
		mate_frame:addChild(mate_label)
		self.seaman:addChild(mate_frame)
	else
		local icon = playerData:getIcon()
    	local seaman_res = string.format("ui/seaman/seaman_%s.png", icon)
		if type(seaman_info) == "table" then
			local seamanId = seaman_info[1]
			local seamanType = seaman_info[2]
			if seamanType == SEAMAN_DATA.SEAMAN_HEAD then
				--水手头像
				seaman_res = sailor_info[seamanId].res
			end
		else
			if sailor_info[seaman_info] then
				seaman_res = sailor_info[seaman_info].res
			end
		end
		self.seaman = display.newSprite(seaman_res)
		self.textureRes[#self.textureRes + 1] = seaman_res
		self.plot_bg:addChild(self.seaman)	
		local seaman_width = self.seaman:getContentSize().width
		local scale = 130/seaman_width
		self.seaman:setScale(scale)
		self.seaman:setAnchorPoint(ccp(0,0))
		
		if not is_right then--头像放左边
			self.last_dir = 0
			self.seaman:setPosition(ccp(120, -8))
		else--右边
			self.last_dir = 1
			self.seaman:setPosition(ccp(700, -8))
		end
	end
	
	if seaman_info ~= SEAMAN_DATA.MATE then
		if item[1] == 0 then
			name = self.player_name..":"
		else
			name = item[2]..":"
		end
	end

	if tolua.isnull(self.name) then
		self.name = createBMFont({text = name, fontFile = FONT_MICROHEI_BOLD, size = 20, 
					color = ccc3(dexToColor3B(COLOR_CREAM_STROKE)), x = 0, y = 0 })
		self.name:setAnchorPoint(ccp(0, 1))
		self.plot_bg:addChild(self.name)
	else
		self.name:setString(name)
	end
	local lx, ly = 290, 120
	if is_right then
		lx = 108
	end
	if seaman_info == SEAMAN_DATA.MATE then
		lx = 180
	end
	self.name:setPosition(lx, ly)
	txt = "$(font:FONT_CFG_1)"..txt
	if tolua.isnull(self.label) then 
		------------------------------------------------------
		self.label = createRichLabel( txt, 600, 34, 18, 2);
		-- self.label = RichLabel.new({str = txt,font = FONT_CFG_1,fontSize = 18,rowWidth = 640, rowSpace = 4,color = ccc3(dexToColor3B(COLOR_WHITE_STROKE))})
		------------------------------------------------------
		
		--self.label = RichLabel.new({str = txt,font = "Arial",fontSize = 18,rowWidth = 560,rowSpace = -4})	
		self.plot_bg:addChild(self.label)
	else
		self.label:removeFromParentAndCleanup(true)
		------------------------------------------------------
		self.label = createRichLabel( txt, 600, 34, 18, 2);
		-- self.label = RichLabel.new({str = txt,font = FONT_CFG_1,fontSize = 18,rowWidth = 640, rowSpace = 4,color = ccc3(dexToColor3B(COLOR_WHITE_STROKE))})
		------------------------------------------------------

		--self.label = RichLabel.new({str = txt,font = "Arial",fontSize = 18,rowWidth = 560,rowSpace = -4})	
	    self.plot_bg:addChild(self.label)	
	end 
	
	local lab_height_n = self.label:getContentSize().height
	local lab_y = math.floor(self.plot_bg:getContentSize().height * 0.5) + 4 - lab_height_n/2
	if (lab_y + lab_height_n) > (ly - 26) then
		lab_y = (ly - 26) - lab_height_n
	end
	
	local lx = 290
	if is_right then  --头像在右边
		lx = 108
	end
	if seaman_info == SEAMAN_DATA.MATE then
		lx = 180
	end
				
	self.label:setPositionX(lx)
	self.label:setPositionY(lab_y)
	self.seaman:runAction(CCFadeIn:create(0.2))
	self.name:runAction(CCFadeIn:create(0.2))
	self.label:runAction(CCFadeIn:create(1))
end

---水手对话
function PlotDialog:initSailorDialog(item)
	self:seamanBgActions(item)
end

--水手对话框动画
function PlotDialog:seamanBgActions(item) 
    local plotPosY = -3
    local is_right = (item[3] == 2)
	-- 剧情动画表现
	if tolua.isnull(self.plot_bg) then
		self.plot_bg = getChangeFormatSprite("ui/bg/bg_plot.png")
		self.bg_size = self.plot_bg:getContentSize()
		self:addChild(self.plot_bg, -1)
		local ac_time = 0.2	
		if not is_right then  -- 头像放左边   	
			-- 对话条 
			self.plot_bg:setAnchorPoint(ccp(0, 0))
			--self.plot_bg:setScaleX(1)
			--self.plot_bg:setOpacity(255)
			self.plot_bg:setPosition(ccp(0, plotPosY))	
			--local scale = CCScaleTo:create(ac_time, 1)
			--local fade  = CCFadeIn:create(ac_time)
			local ac1 = CCFadeIn:create(ac_time)
			local ac2 = CCCallFunc:create(function() self:act_call_back(item) end)
			self.plot_bg:runAction(CCSequence:createWithTwoActions(ac1, ac2))
		else            -- 右边
			-- 对话条
			self.plot_bg:setAnchorPoint(ccp(1, 0))
			-- self.plot_bg:setScaleX(0)
			-- self.plot_bg:setOpacity(0)
			self.plot_bg:setPosition(ccp(display.width, plotPosY))	
			-- local scale = CCScaleTo:create(ac_time, 1)
			-- local fade  = CCFadeIn:create(ac_time)
			local ac1 = CCFadeIn:create(ac_time)
			local ac2 = CCCallFunc:create(function() self:act_call_back(item) end)
			self.plot_bg:runAction(CCSequence:createWithTwoActions(ac1, ac2))
		end 
	else
	    self:act_call_back(item)
	end 	
end

----判断显示大副对话还是水手对话
function PlotDialog:selectDialogShow(item)
	if not item or self.dialog_index > self.dialog_count then --对话完毕
		self:hideDialog()
		return true
	end
	self:initSailorDialog(item)
	return false
end

-- item = {seaman_info = 1(说明：0：代表本角色；>0：代表水手；{}表格形式), 
-- name = "", is_right = true, txt = "" }
function PlotDialog:say(item)
	self.notClick = true
    if self:selectDialogShow(item) then return end 
end

function PlotDialog:hideDialog()
	if not self.showDialog then return end
	local dt = 0.5
	local ac1 = CCFadeOut:create(dt)
	local ac2 = CCCallFunc:create(function() 
		--释放资源
		for k,v in ipairs(self.textureRes) do
			RemoveTextureForKey(v)
		end
		self.textureRes = {}
		-- EventTrigger(EVENT_PORT_SETTOUCH, true)
		
		self:endSayAction()
	end)
	local seq = CCSequence:createWithTwoActions(ac1, ac2)
	self:runAction(seq)
	self.showDialog = false
end 

-- 结束对话动画
function PlotDialog:endSayAction()   
	local ac_time = 0.2
	local plotPosY = 0

	local ac1 = CCFadeOut:create(ac_time)
	local ac2 = CCCallFunc:create(function() 
		self:close("PlotDialog")
	end)
	self.plot_bg:runAction(CCSequence:createWithTwoActions(ac1, ac2))
end 

function PlotDialog:onExit()
	if type(self.dialog_tab.call_back) == "function" then
		self.dialog_tab.call_back()
	end
end

return PlotDialog 