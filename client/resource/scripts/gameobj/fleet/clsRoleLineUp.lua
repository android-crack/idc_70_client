

local ClsDataTools = require("module/dataHandle/dataTools")
local music_info = require("game_config/music_info")
local ClsUiTools = require("gameobj/uiTools")
local sailor_info = require("game_config/sailor/sailor_info")

local ClsRoleLineUp = class("ClsRoleLineUp",require("ui/view/clsBaseView"))

local DEFAULD_LINEUP = {8, 3, 7, 13, 9} -- 默认位置

local FIRST_INDEX = 1
local MAX_INDEX = 15 --最大15个格子

function ClsRoleLineUp:getViewConfig()
    return {
        effect = UI_EFFECT.SCALE,
        is_back_bg = true,
    }
end
function ClsRoleLineUp:onEnter()

	self.plist = {
		["ui/shipyard_ui.plist"] = 1,
		["ui/partner.plist"] = 1,
	}
	LoadPlist(self.plist)

    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/partner_lineup.json")
    convertUIType(self.panel)
    self:addWidget(self.panel)

	self.cell_bg = {}
	self.role_list = {}

	for i = FIRST_INDEX, MAX_INDEX do

		self["figure_"..i] = getConvertChildByName(self.panel, "figure_"..i)
		self.cell_bg[#self.cell_bg + 1] = self["figure_"..i]
	end

	self.linup_bg = getConvertChildByName(self.panel, "linup_bg")

  --   self:registerScriptTouchHandler(function(event, x, y)
		-- return self:onTouch(event, x, y) end)
	self:regTouchEvent(self, function(...) return self:onTouch(...) end, self.m_touch_priority)

	self.touch_rect = CCRect(256, 127, 448, 262)
	self:initView()
end

function ClsRoleLineUp:initView()

	for k, v in pairs(self.role_list) do
		if not tolua.isnull(v) then
			v:removeFromParentAndCleanup(true)
		end
	end

	local partner_data = getGameData():getPartnerData()

	local info = partner_data:getPartnersInfo()
	-- local partner_ids = info.ids

	-- self.partner_pos = info:partner_pos

	self.ids = {-1}
	for k, v in pairs(info.ids) do
		self.ids[#self.ids + 1] = v
	end

	self.pos = {info.pos}
	for k, v in pairs(info.partner_pos) do
		self.pos[#self.pos + 1] = v
	end

	-- print('坐标 ------------ ')
	-- table.print(self.pos)
	-- print('id -------------------- ')
	-- table.print(self.ids)

	for k, v in pairs(self.ids) do
		if v ~= 0 then
			local cur_index = self.pos[k]
			-- print(' ------cur_index----',cur_index)
			local pos = self.cell_bg[cur_index]:getPosition()
			-- print(' ---- pos ------------')
			-- print(pos.x,pos.y)

			local pos_1 = self.linup_bg:convertToWorldSpace(ccp(pos.x,pos.y))

			local role_item = self:createRoleItem(v, cur_index, k)
			role_item:setPosition(ccp(pos_1.x+pos.x,pos_1.y+pos.y - 11))
			self:addChild(role_item)

			self.role_list[cur_index] = role_item
		end
	end
end


--cur_index:阵形里的位置比如15
--order:小伙伴的序号1到5
function ClsRoleLineUp:createRoleItem(id, cur_index, order)
	local uiLayer = UILayer:create()
    local head_panel = GUIReader:shareReader():widgetFromJsonFile("json/partner_lineup_head.json")
    convertUIType(head_panel)
    head_panel:setAnchorPoint(ccp(0.5, 0.5))
    uiLayer:addWidget(head_panel)

    --头像
    local head = getConvertChildByName(head_panel, "sailor_head")
    if id == -1 then
    	local player_data = getGameData():getPlayerData()

    	local sailor = ClsDataTools:getSailor(player_data:getIcon())
    	head:changeTexture(sailor.res, UI_TEX_TYPE_LOCAL)
    else

		head:changeTexture(sailor_info[id].res, UI_TEX_TYPE_LOCAL)
    end

    local seaman_width = head:getContentSize().width
	head:setScale(58 / seaman_width)

    --序号
    local num = getConvertChildByName(head_panel, "head_num")
    if order == 1 then
    	num:changeTexture("common_icon_flagship.png", UI_TEX_TYPE_PLIST)
    else
    	num:changeTexture(string.format("partner_num_%s.png", order), UI_TEX_TYPE_PLIST)
    end

    uiLayer.id = id
	return uiLayer
end

function ClsRoleLineUp:onTouch(event, x, y)
	if event == "began" then
		return self:onTouchBegan(x, y)
	elseif event == "moved" then
		self:onTouchMoved(x, y)
	elseif event == "ended" then
		self:onTouchEnded(x, y)
	end
end

function ClsRoleLineUp:onTouchBegan(x, y)
	--print("===========onTouchBegan=======",x, y)
	-- self.role_tag = nil
	if self.touch_rect:containsPoint(ccp(x, y)) then
		if self.role_tag then
			local pos = self:setWorldPoint(self.role_tag)
			self.role_list[self.role_tag]:setPosition(ccp(pos.x, pos.y))
		end
		for k,v in ipairs(self.cell_bg) do
			local pos = v:getPosition()
			local role_pos = self.linup_bg:convertToWorldSpace(ccp(pos.x, pos.y))
			local dis = Math.distance(role_pos.x, role_pos.y, x, y)

			if dis <= 45 and self.role_list[k] then
				self.role_tag = k

				return true
			end
		end
	else
		self:close()
	end
	self.role_tag = nil
	return false
end

function ClsRoleLineUp:onTouchMoved(x, y)
	if not self.role_tag then return end
	if self.touch_rect:containsPoint(ccp(x, y)) then
		self.role_list[self.role_tag]:setPosition(ccp(x,y))
	end
end

function ClsRoleLineUp:onTouchEnded(x, y)
	if not self.role_tag then return end

	local partner_data = getGameData():getPartnerData()
	local cur_select_key = nil
	for k,v in ipairs(self.cell_bg) do
		local pos = v:getPosition()
		local role_pos = self.linup_bg:convertToWorldSpace(ccp(pos.x, pos.y))
		local dis = Math.distance(role_pos.x, role_pos.y, x, y)

		if dis <= 45 then
			cur_select_key = k
			break
		end
	end

	if not cur_select_key or cur_select_key == self.role_tag then
		local pos = self:setWorldPoint(self.role_tag)
		self.role_list[self.role_tag]:setPosition(ccp(pos.x, pos.y))
	elseif self.role_list[cur_select_key] then
		partner_data:askForChangeLineupPos(self.role_list[self.role_tag].id, cur_select_key)

		local pos = self:setWorldPoint(self.role_tag)
		local pos_other = self:setWorldPoint(cur_select_key)

		self.role_list[cur_select_key]:setPosition(ccp(pos.x, pos.y))
		self.role_list[self.role_tag]:setPosition(ccp(pos_other.x, pos_other.y))

		local data = table.clone(self.role_list[self.role_tag])
		self.role_list[self.role_tag] = self.role_list[cur_select_key]
		self.role_list[cur_select_key] = table.clone(data)
	else
		print("===========换位置==========")
		local pos = self:setWorldPoint(cur_select_key)
		self.role_list[cur_select_key] = table.clone(self.role_list[self.role_tag])
		self.role_list[cur_select_key]:setPosition(ccp(pos.x, pos.y))
		self.role_list[self.role_tag] = nil

		partner_data:askForChangeLineupPos(self.role_list[cur_select_key].id, cur_select_key)
	end

	self.role_tag = nil
end

function ClsRoleLineUp:setWorldPoint(tag)
	local pos = self.cell_bg[tag]:getPosition()
	local pos_world = self.linup_bg:convertToWorldSpace(ccp(pos.x,pos.y))

	return pos_world
end

function ClsRoleLineUp:onExit()
	UnLoadPlist(self.plist)
end

return ClsRoleLineUp
