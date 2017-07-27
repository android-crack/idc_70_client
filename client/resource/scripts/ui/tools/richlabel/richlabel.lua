 

local DEF = require("ui/tools/richlabel/richlabeldef")
local parseString = require("ui/tools/richlabel/parse_string")
local ModCommonBase = require("gameobj/commonFuns")
local ui_word = require("game_config/ui_word")
	
local ClsRichLabel = class("ClsRichLabel", function (width, height)
	local rich_spr = display.newSprite()
	rich_spr:setContentSize(CCSize(width, height))
	rich_spr:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_BOTTOM])
	return rich_spr
end)

function ClsRichLabel:ctor(width, height, size)
	self.font_size = size or 14
	-- 是否忽略宽度
	self.is_ignore_width = false

	-- 塞进RichLabel的每个元素
	self.elements = {}
	-- 对self.elements的所有元素进行换行拆分后的所有元素
	self.elements_seperated = {}

	self.m_define_width = width
	self.m_define_height = height
	-- 宽高
	self.contentsize = CCSize(width, height)

	-- 行数
	self.line = 0
	-- 每次绘制一个元素时每行开始的位置
	self.line_start_pos = 0
	-- 行高：元素绘制本身需要预留的高度
	self.line_height  = {}
	self.omit_info = {}
	self.omit_info.max_line = 1000000
	self.omit_info.is_element_parse = true
	self.omit_info.is_active_omit = false
	self.omit_info.is_make_mark = false


	-- 行间距：额外增加的高度
	self.vertical_space = 0

	self.m_is_touch_b = false --是否可点击
	self.m_touch_params = {}  --回调参数
	self.m_touch_callback = nil --回调

	self.m_spr_elements = {}  --正在显示的元素

	self.is_center_b = false
	self.m_is_accpet_touch_callback = nil
	self.m_real_width = 0--实际的宽度

	self:initTouchHander()
end 

function ClsRichLabel:setElements(elements)
	self.elements = elements
end

function ClsRichLabel:insertElement(element, index)
	self.elements[index] = element
end

function ClsRichLabel:pushBackElement(element)
	self.elements[#self.elements + 1] = element
end

function ClsRichLabel:removeElementByIndex(index)
	table.remove(self.elements, index)
end

function ClsRichLabel:removeElement(element)
	for i, v in ipairs(self.elements) do
		if v == element then 
			table.remove(self.elements, i)
			return 
		end
	end
end

function ClsRichLabel:getStringText()
	local str = ""
	for _, element in ipairs(self.elements) do
		if element.text then
			str = str .. element.text
		end
	end
	return str
end


-- [[
-- 设置行间距
--]]
function ClsRichLabel:setVerticalSpace(space)
    self.vertical_space = space
end

-- [[
-- 设置宽高
--]]
function ClsRichLabel:setSize(contentsize)
	self.contentsize = contentsize
	self:setContentSize(contentsize)
end

-- [[
-- 获取宽高
--]]

function ClsRichLabel:setMaxLine(max_line)
	self.omit_info.max_line = max_line
end

function ClsRichLabel:getLineNum()
	return self.line
end

function ClsRichLabel:getSize()
	return CCSize(self.contentsize.width, self.line_height[self.line])
end

--[[
-- 是否忽略宽度限制
--]]
function ClsRichLabel:setIgnoreWidth(ignore)
	self.is_ignore_width = ignore
end

function ClsRichLabel:getOmitLenght(sign_color)
	if not self.omit_info.omit_sign_len or (self.omit_info.omit_sign_color ~= sign_color) then
		self.omit_info.omit_sign_color = sign_color
		local lab = createBMFont({text = "......", size = self.font_size, color = ccc3(dexToColor3B(sign_color))})
		self.omit_info.omit_sign_len = lab:getContentSize().width + 1
	end
	return self.omit_info.omit_sign_len
end

--[[
-- 更新每行距离TOPLEFT的高度
--]]
function ClsRichLabel:updateLineHeight(c_height)
    local height = (self.line_height[self.line - 1] or 0) + c_height
    if self.line >= 2 then
        height = height + self.vertical_space
    end
    if height < (self.line_height[self.line] or 0) then return end 
    self.line_height[self.line] = height
end

function ClsRichLabel:updateLineWidth(width)
	if self.is_ignore_width then 
		self.contentsize.width = width
	end
end

-- [[
-- 换行：行数+1， line_start_pos设置为0（从头位置开始)
--]]
function ClsRichLabel:addNewLine(is_update_height, height, width)
    if self.line ~= 0 and is_update_height then --第0行不需要
        -- 在换行之前更新上一行的高度
        self:updateLineHeight(height)
    end
	if width then 
		self:updateLineWidth(width)
	end

    self.line = self.line + 1
    self.line_start_pos = 0

    if self.line >= 2 then
    	self.m_real_width = self.m_define_width
    end
end

function ClsRichLabel:insertSubText(element, start, current, sub_text_tab, end_x)
	local sub_text = ModCommonBase:utf8sub(element.text, start, current - start + 1)

	local e = table.clone(element)
	e.text = sub_text
	e.posx = self.line_start_pos
	e.width = end_x - e.posx
	e.line = self.line
	e.size = self.font_size
	sub_text_tab[#sub_text_tab + 1] = e

end

function ClsRichLabel:handerOmitBackText()
	if not self.omit_info.is_active_omit then return end
	while(true) do
		local len_n = #self.elements_seperated
		local element = self.elements_seperated[len_n]
		if not element then break end
		if element.cut_omit_index then
			element.text = ModCommonBase:utf8sub(element.text, 1, element.cut_omit_index) .. "......"
			break
		else
			table.remove(self.elements_seperated, len_n)
		end
	end
	self.line = self.omit_info.max_line
end
--[[
-- 文字拆分
--]]
function ClsRichLabel:oversizeHandleText(element)
	local str_len = ModCommonBase:utfstrlen(element.text)
	local e_font = element.font or FONT_CFG_1
	local e_color = element.color
	local lab = createBMFont({text = element.text, size = self.font_size, fontFile = e_font, color = ccc3(dexToColor3B(e_color))})
	local letters_size_tab = {}
	if lab.getLettersSizeList then
		letters_size_tab = lab:getLettersSizeList(str_len)
	else
		local ascii_size = require(string.format("%s/asciisize_%d", DEF.SIZECFG_PATH, self.font_size))
		for i = 1, str_len do
			local uftchar = ModCommonBase:utf8sub(element.text, i, 1)
			local charbyte = string.byte(uftchar)
			letters_size_tab[i] = ascii_size[charbyte]
		end
	end
	local sub_text_tab = {}
	local start = 1
	local width = self.line_start_pos
	local lab_height = lab:getContentSize().height
	
		--逐个字符加长度
		for i = 1, str_len do
			if not self.omit_info.is_element_parse then break end
			local size = letters_size_tab[i] or {["width"] = 0, ["height"] = 0}
			
			--如果当前文本宽度加上下一个字符的宽度超过文本的总宽度，则在换新行之前画出文本
			local is_width_out = (width + size.width > self.contentsize.width)
			if self.line >= self.omit_info.max_line then
				if not self.omit_info.is_make_mark then
					if (width + size.width) >= (self.contentsize.width - self.font_size*4) then
						print(width + size.width - self.contentsize.width, e_color)
						if (width + size.width) >= (self.contentsize.width - self:getOmitLenght(e_color)) then --减少创建获取的消耗
							self.omit_info.is_make_mark = true
							element.cut_omit_index = i - start
						end
					end
				end
				if is_width_out then
					self.omit_info.is_active_omit = true
					self.omit_info.is_element_parse = false
				end
			end

			if (not is_width_out and i < str_len) then 
				width = width + size.width
				if self.line < 2 then
					self.m_real_width = self.m_real_width + size.width
				end
			elseif (is_width_out and i < str_len) then
				self:insertSubText(element, start, i - 1, sub_text_tab, width)
				element.cut_omit_index = nil
				-- 设置截取字符开始位置
				start = i
				self:addNewLine(true, lab_height, width)
				width = self.line_start_pos + size.width
			elseif (is_width_out and i == str_len) then 
				self:insertSubText(element, start, i - 1, sub_text_tab, width)
				element.cut_omit_index = nil
				start = i
				self:addNewLine(true, lab_height, width)
				width = self.line_start_pos

				self:insertSubText(element, start, start, sub_text_tab, size.width)
				self:updateLineHeight(lab_height)
				self.line_start_pos = size.width
			elseif (not is_width_out and i == str_len) then 
				self:insertSubText(element, start, str_len, sub_text_tab, width + size.width)
				element.cut_omit_index = nil
				self.line_start_pos = width + size.width
				if self.line < 2 then
					self.m_real_width = self.m_real_width + size.width
				end
				self:updateLineHeight(lab_height)
			end
			
		end
	if 1 == #sub_text_tab and (not self.omit_info.is_make_mark) then --优化用，减少每次都创建label的问题
		sub_text_tab[1].label_node = lab
	end
	return sub_text_tab
end

--[[
-- 图片是否超出范围情况处理
--]]
function ClsRichLabel:oversizeHandleImage(element) 
    local params = element.params
	local params_tab = string.split(params, ',')
	local config = {}
	local raw_res = params_tab[1] or ""
    local res, nores1,nores2, scale_n = parseString.getImgConfig(raw_res)
    config.res = res
    config.scale = scale_n or 1
	config.text = params_tab[2]
	config.color = parseString.getColorNumFromStr(params_tab[3])
	
    local img = display.newSprite(config.res)
    local size = img:getContentSize()
    size.width = size.width*config.scale
    size.height = size.height*config.scale
    
    local left_width = self.contentsize.width - self.line_start_pos
    if size.width < left_width then 
        self:updateLineHeight(size.height)
        posx = self.line_start_pos
        self.line_start_pos = self.line_start_pos + size.width
        self.m_real_width = self.m_real_width + size.width
    elseif size.width > left_width and size.width < self.contentsize.width then 
        self:addNewLine()
        posx = self.line_start_pos
        self.line_start_pos = size.width
    else
        echoInfo("image too big!")
    end

    self:updateLineHeight(size.height)
	config.img = img
	config.type  = element.type
	config.posx = posx
    config.width = size.width
	config.line = self.line 
	config.text_size = self.font_size
	return { config }
end

--[[
-- 图片是否超出范围情况处理
--]]
function ClsRichLabel:oversizeHandleImageBtn(element) 
    local params = element.params
    local cut_index_n = string.find(params, ',')
    local res_str = params
    local scale_n = 1
    local params_str = nil
    if ( cut_index_n ) then
        res_str = string.sub( params, 1, cut_index_n - 1 ) 
        res_str = string.trim(res_str)
        params_str = string.sub( params, cut_index_n + 1 )
        params_str = string.trim(params_str)
    end
    local btn_res, btn_select_res, btn_disabled_res, scale_n = parseString.getImgConfig(res_str)
    local config = {}
    config.btn_res =btn_res
    config.btn_select_res = btn_select_res
    config.btn_disabled_res = btn_disabled_res
    config.btn_scale = scale_n
    

    local btn = require("ui/view/clsViewButton").new({image = btn_res, imageSelected = btn_select_res, imageDisabled = btn_disabled_res})
    local btn_size = btn:getContentSize()
    local size = {}
    size.width = btn_size.width*scale_n
    size.height = btn_size.height*scale_n
    
    local left_width = self.contentsize.width - self.line_start_pos
    if size.width < left_width then 
    	self.m_real_width = self.m_real_width + size.width
        self:updateLineHeight(size.height)
        posx = self.line_start_pos
        self.line_start_pos = self.line_start_pos + size.width
    elseif size.width > left_width and size.width < self.contentsize.width then 
        self:addNewLine()
        posx = self.line_start_pos
        self.line_start_pos = size.width
    else
        echoInfo("image too big!")
    end

    self:updateLineHeight(size.height)
	config.type  = element.type
	config.posx = posx
	config.width = size.width
	config.line = self.line 
    config.btn = btn
    config.params = params_str
	return { config }
end

--[[
-- 超链接拆分处理
--]]
function ClsRichLabel:oversizeHandleURL(element) 
    local params = element.params
	local params_tab = string.split(params, ',')
	local text = string.format("%s", params_tab[1])
	local url = params_tab[2] or ""
	local color = parseString.getColorNumFromStr(params_tab[3])
    return self:oversizeHandleText({text=text, color = color, url = url, type = element.type})
end

--[[
-- 其他自定义类型的label
--]]
function ClsRichLabel:oversizeHandleTextCustom(element)
	if nil == element.text then
		element.text = element.params
	end
	return self:oversizeHandleText(element)
end

function ClsRichLabel:oversizeHandleTextCustom(element)
	if nil == element.text then
		element.text = element.params
	end
	return self:oversizeHandleText(element)
end

function ClsRichLabel:oversizeHandleTextCustomWithBox(element)
	if nil == element.text then
		element.text = string.format(ui_word.NAME_BOX, element.params)
	end
	return self:oversizeHandleText(element)
end

local OVERSIZE_HANDLER = 
{
	[DEF.PARSE_TYPE.TEXT] = ClsRichLabel.oversizeHandleText,
    [DEF.PARSE_TYPE.IMGBTN] = ClsRichLabel.oversizeHandleImageBtn,
    [DEF.PARSE_TYPE.IMAGE] = ClsRichLabel.oversizeHandleImage,
    [DEF.PARSE_TYPE.URL] = ClsRichLabel.oversizeHandleURL,
	[DEF.PARSE_TYPE.NAME] = ClsRichLabel.oversizeHandleTextCustomWithBox,
	[DEF.PARSE_TYPE.PORT] = ClsRichLabel.oversizeHandleTextCustomWithBox,
	[DEF.PARSE_TYPE.VIEW] = ClsRichLabel.oversizeHandleTextCustomWithBox,
	[DEF.PARSE_TYPE.FORCE] = ClsRichLabel.oversizeHandleTextCustomWithBox,
	[DEF.PARSE_TYPE.MISSIONC] = ClsRichLabel.oversizeHandleTextCustom,
	[DEF.PARSE_TYPE.CHAT_PLAYERC] = ClsRichLabel.oversizeHandleTextCustom,
	[DEF.PARSE_TYPE.CHAT_REWARDC] = ClsRichLabel.oversizeHandleTextCustom,
	[DEF.PARSE_TYPE.CALL] = ClsRichLabel.oversizeHandleTextCustom,
	[DEF.PARSE_TYPE.MSGCALL] = ClsRichLabel.oversizeHandleTextCustom,
}

function ClsRichLabel:update()
	self:removeAllChildren()
	self.m_spr_elements = {}
	if self.is_ignore_width then 
		self.contentsize.width = 99999
	else
		
	end
	self:addNewLine()
	--根据宽高自适应切分
    local real_elements = {}
	for i, v in ipairs(self.elements) do
		local size_handler = OVERSIZE_HANDLER[v.type]
		if size_handler then 
			real_elements  = size_handler(self, v)
			table.fcat(real_elements, self.elements_seperated)
		else
			if v.is_touch_b and (true == v.is_touch_b) then
				if not self.m_is_touch_b then
					self.m_is_touch_b = true
					self.m_touch_params = v.params
				end
			end
		end
		if not self.omit_info.is_element_parse then
			self:handerOmitBackText()
			break
		end
	end
	self:setSize(CCSize(self.contentsize.width, self.line_height[self.line] or 0))
	if #self.elements <= 0 then
		return
	end

	--想获取每行差多少
	local line_width = {}
	if self.is_center_b and (not self.is_ignore_width) then
		for i, v in ipairs(self.elements_seperated) do
			local creator = DEF.ELEMENT_CREATOR[v.type]
			if creator then 
				line_width[v.line] = (self.contentsize.width - v.posx - v.width)/2
			end
		end
	end
	for i, v in ipairs(self.elements_seperated) do
		local creator = DEF.ELEMENT_CREATOR[v.type]
		if creator then
			v.richlabel = self
			local element = creator.new(v) 
			local offset_x = line_width[v.line] or 0
			local posy = self.line_height[self.line] - self.line_height[v.line] + (v.height or 0)
			display.align(element, display.BOTTOM_LEFT, v.posx + offset_x, posy)
			self:addChild(element)
			if self.is_ignore_width and i == #self.elements_seperated then
				local x, y = element:getPosition()
				self.contentsize.width = x + element:getContentSize().width
				self:setSize(CCSize(self.contentsize.width, self.line_height[self.line]))
			end
			self.m_spr_elements[#self.m_spr_elements + 1] = element
		end 
    end
end

function ClsRichLabel:setTextCenter(is_center_b)
    is_center_b = is_center_b or false
    self.is_center_b = is_center_b
end

function ClsRichLabel:setCallback(call_back)
    self.m_touch_callback = call_back
end

function ClsRichLabel:getCallBack()
	return self.m_touch_callback
end

function ClsRichLabel:activeCallback()
    if true == self.m_is_touch_b then
        if type(self.m_touch_callback) == "function" then
            self.m_touch_callback(unpack(self.m_touch_params))
        end
    end
end

function ClsRichLabel:judgeIsCanTouch(call)
	self.judge_touch_call = call
end

function ClsRichLabel:initTouchHander()
	self.m_touch_dispatcher = require("ui/view/clsTouchDispatcher").new()
	self:addChild(self.m_touch_dispatcher)
	self:regTouchEvent(self, function(event, x, y)
		if not self.m_is_touch_b then return false end
		local pos = self:convertToNodeSpace(ccp(x,y))
		if event == "began" then
			if pos.x > 0 and (pos.x < self:getSize().width) and
				pos.y > 0 and (pos.y < self:getSize().height) then
				return true
			end
		elseif event == "ended" then
			self:activeCallback()
		end
	end, -1000)
end

function ClsRichLabel:regTouchEvent(node, touch_func, order_n)
	order_n = order_n or 0
	if tolua.isnull(node) or ("function" ~= type(touch_func)) then
		return
	end
	self.m_touch_dispatcher:insertTouchEvent(node, touch_func, order_n)
end

function ClsRichLabel:regTouchFromView(view_obj, order_n)
	if not tolua.isnull(view_obj) then
		order_n = order_n or 0
		local touch_func = function(event, x, y)
			if type(self.judge_touch_call) == "function" then 
				if not self.judge_touch_call(x, y) then
					return false
				end
			end
			return self.m_touch_dispatcher:onTouch(event, x, y)
		end
		view_obj:regTouchEvent(self, touch_func, order_n)
	end
end

function ClsRichLabel:setString(str)
	self.elements_seperated = {}
	self.line = 0
    self.line_start_pos = 0
	self.omit_info.is_element_parse = true
	self.omit_info.is_active_omit = false
	self.omit_info.is_make_mark = false
	local parse_tab = parseStr(str)
	self:setElements(parse_tab)
	-- table.print(parse_tab)
	self:update()
end

function ClsRichLabel:setParseList(parse_list)
    self.elements_seperated = {}
	self.line = 0
    self.line_start_pos = 0
	self:setElements(parse_list)
    self:update()
end

function ClsRichLabel:setCallElementCallback(key_str, call_back)
	local elements = self:getCallElementsByKey(key_str)
	for k, v in ipairs(elements) do
		v:setCallback(call_back)
	end
end
function ClsRichLabel:getCallElementsByKey(key_str)
	key_str = key_str or ""
	local tab = {}
	for k, v in ipairs(self.m_spr_elements) do
		if v.getType then
			if DEF.PARSE_TYPE.CALL == v:getType() then
				if v:getKey() == key_str then
					tab[#tab + 1] = v
				end
			end
		end
	end
	return tab
end

function ClsRichLabel:setButtonElementCallback(call_back)
    local btn = self:getButtonElement()
    if btn then
        btn:setCallback(call_back)
    end
end

function ClsRichLabel:getButtonElement()
	for k, v in ipairs(self.m_spr_elements) do
		if v.getType then
			if DEF.PARSE_TYPE.IMGBTN == v:getType() then
				return v
			end
		end
	end
    return nil
end

function ClsRichLabel:changeTargetColor(type_str, org_color, change_color)
	if type_str and org_color and change_color then
		org_color = parseString.getColorNum(org_color)
		for k, v in ipairs(self.m_spr_elements) do
			if v.getType and v.getTextColor then
				if (v:getType() == type_str) and (v:getTextColor() == org_color) then
					v:setTextColor(change_color)
				end
			end
		end
	end
end

-- 普通文本的特定颜色内容改颜色
function ClsRichLabel:changeNormalTextTargetColor(org_color, change_color)
	self:changeTargetColor(DEF.PARSE_TYPE.TEXT, org_color, change_color)
end

function ClsRichLabel:setRealSize()
	self:setSize(CCSize(self.m_real_width, self.m_define_height))
end

------------------------------------------------------------------------
--$(button:#btn_1.png|#btn_2.png|#btn_3.png|0.5,参数) --0.5为缩放 #btn_2.png,#btn_3.png,0.5,参数均为可选项，可不填
--createRichLabel("aaaa$(chat_playerc:刚刚刚)bbbb$(chat_rewardc:嗷嗷嗷)cccc", 200, 100, 18)
function createRichLabel(str, width, height, font_size, vertical_space, is_ignore_width, is_center_b, is_auto)
	local rich_label = ClsRichLabel.new(width, height, font_size)
	rich_label:setVerticalSpace(vertical_space or -4)
	rich_label:setIgnoreWidth(is_ignore_width)
	rich_label:setTextCenter(is_center_b)
	rich_label:setString(str)
	if is_auto then
		rich_label:setRealSize()
	end
	return rich_label
end

--[[
params:
	is_auto:获取单行实际大小
	vertical_space：行间距
	is_ignore_width：无限宽
	is_center_b：是否juzhong
	max_line = 最大行数
--]]
function createRichLabelParams(str, width, height, font_size, params)
	params = params or {}
	local rich_label = ClsRichLabel.new(width, height, font_size)
	rich_label:setVerticalSpace(params.vertical_space or -4)
	rich_label:setIgnoreWidth(params.is_ignore_width or false)
	rich_label:setTextCenter(params.is_center_b or false)
	rich_label:setMaxLine(params.max_line or 1000000)
	rich_label:setString(str)
	if params.is_auto then
		rich_label:setRealSize()
	end
	return rich_label
end

function getRichLabelText(str)
	local parse_tab = parseStr(str)
	local result_str = ""
	for k, v in ipairs(parse_tab) do
		if v.text then
			result_str = result_str .. v.text
		end
	end
	return result_str
end
