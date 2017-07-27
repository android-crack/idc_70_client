-- 加载配置文件

local ui_control = require"base.ui.ui_control"
local MyLoadfile = {}


MyLoadfile.load_template = function(self,filename, nameTab)  --nameTab 维护name属性
	
	local tab = LoadJsonFromFile(filename)
	return self:getUI(tab, nameTab)
end	
	
MyLoadfile.getUI = function(self, tab, nameTab)  -- tab 为配置表， nameTab 维护name属性
	
	local p = nil
	if type(tab) ~= "table" then return end
	assert(type(nameTab) == "table", "MyLoadfile.getUI invalid nameTab")
	
	local types = tab["type"]
	if types then
		if  types == "Button" then
			p = ui_control:newButton(tab)
			
		elseif types == "CheckButton" then
			p = ui_control:newCheckButton(tab)
			
		elseif types == "Image" then
			p = ui_control:newImage(tab)
		
		elseif types == "ImageButton" then
			p = ui_control:newImageButton(tab)
		elseif types == "ImageLabel" then
			p = ui_control:newImageLabel(tab)
		
		elseif types == "Panel" then
			p = ui_control:newPanel(tab)
		elseif types == "Label" then
			p = ui_control:newLabel(tab)
		
		elseif types =="ProgressBar" then
			p = ui_control:newProgressBar(tab)
		elseif types =="ProgressBarLabel" then
			p = ui_control:newProgressBarLabel(tab)
		elseif types =="ProgressBarMask" then
			p = ui_control:newProgressBarMask(tab)
		elseif types =="ProgressBarMaskLabel" then
			p = ui_control:newProgressBarMaskLabel(tab)
			
		elseif types =="InputText" then
			p = ui_control:newInputText(tab)
			
		elseif types == "ImgNumber" then
			p = ui_control:newImgNumber(tab)

		elseif types == "Template" then
			nameTab[tab.name] = {}
			p = ui_control:newTemplate(tab, nameTab[tab.name])
			nameTab[tab.name].getNode = p
		end	
	end
	
	
	local ph = 0
	if p then
		p:setAnchorPoint(ccp(0,1)) -- 为适应搜神ui编辑器
		ph = p:getContentSize().height
		
		if type(nameTab[tab.name]) ~= "table" then
			nameTab[tab.name] = {["getNode"] = p}   -- 每个name表的第一位置用来保存自己
		end
		
	end
	local childtab = tab["children"]
	if p and type(childtab) == "table" then
		for k, v in ipairs(childtab) do
			local temp = self:getUI(v, nameTab[tab.name])
			if temp then    
				local y = temp:getPositionY()
				y = ph - y
				temp:setPositionY(y)
				p:addChild(temp)
			end
		end
	end
	return p 
end
	
	
return MyLoadfile

	
