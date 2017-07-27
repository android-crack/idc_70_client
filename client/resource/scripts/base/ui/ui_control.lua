-- 
require "base.ui.init"
require "base.ui.tools"

local ui_control = {}
local ui = require "base.ui.ui"

ui_control.align = {
	["left"]   = kCCTextAlignmentLeft,
	["center"] = kCCTextAlignmentCenter,
	["right"]  = kCCTextAlignmentRight,
}

ui_control.newButton = function(self,item) 
	assert(type(item)=="table", "newButton item erron")
	
	local path = item.resKey
	local res = path
	if ui.USE_PLIST then  -- 用plist 文件读取
		local restab = split(path,"/")
	    res = "#" .. restab[#restab]     -- 前面加"#" 标记读取方式
	end
	
	
	local itemParams = {}
	itemParams.image = string.format("%s_%d.png",res,1)
    itemParams.imageSelected = string.format("%s_%d.png",res,2)
    itemParams.imageDisabled = string.format("%s_%d.png",res,3)
	itemParams.tag    = 0
    itemParams.x      = item.x or 0
    itemParams.y      = item.y or 0
	itemParams.width  = item.width or 0
	itemParams.height = item.height or 0
	
	local labelParams = nil
	if item.text and item.text ~= "" then
		labelParams = {}
		labelParams.text  = item.text
		labelParams.color = ccc3(dexToColor3B(item.titleColor))
		labelParams.x      = 0
		labelParams.y      = 0
		labelParams.align  = ui.TEXT_ALIGN_CENTER
		labelParams.valign = ui.TEXT_VALIGN_CENTER	
	end
	local btn =ui_ext.Button.new(itemParams, labelParams)
	return btn	
end


ui_control.newCheckButton = function(self,item) 
	assert(type(item)=="table", "newCheckButton item erron")
	
	local path = item.resKey
	local res = path
	if ui.USE_PLIST then  -- 用plist 文件读取
		local restab = split(path,"/")
	    res = "#" .. restab[#restab]     -- 前面加"#" 标记读取方式
	end 
	
	local itemParams = {}
	itemParams.imageSelected = string.format("%s_%d.png",res,1)
    itemParams.imageUnselected = string.format("%s_%d.png",res,2)   
	itemParams.tag    = 0
    itemParams.x      = item.x 
    itemParams.y      = item.y 
	itemParams.width  = item.width
	itemParams.height = item.height
	
	local labelParams = nil
	if item.text then --含有文本
		labelParams = {} 
		labelParams.text  = item.text 
		labelParams.size  = item.fontSize
		labelParams.font  = item.fontStyle
		labelParams.bold  = item.bold   --加粗
		if item.color then
			labelParams.color = ccc3(dexToColor3B(item.color))
		end
		labelParams.x     = 0
		labelParams.y     = 0
		labelParams.align = ui.TEXT_ALIGN_LEFT
		labelParams.valign= ui.TEXT_VALIGN_CENTER
	end

	local btn = ui_ext.CheckButton.new(itemParams, labelParams)
	return btn	
end



ui_control.newImageButton = function(self,item)
	assert(type(item)=="table", "newImageButton item erron")
	
	local path = item.resKey
	local res = path
	if ui.USE_PLIST then  -- 用plist 文件读取
		local restab = split(path,"/")
	    res = "#" .. restab[#restab]     -- 前面加"#" 标记读取方式
	end
	
	local itemParams = {}
	itemParams.image = string.format("%s.png",res)	
    itemParams.x     = item.x or 0
    itemParams.y     = item.y or 0
	
	local btn = ui_ext.ImageButton.new(itemParams)
	return btn	
end

ui_control.newImage = function(self,item)
	assert(type(item)=="table", "newImage item erron")
	
	local path = item.resKey
	local res = path
	if ui.USE_PLIST then  -- 用plist 文件读取
		local restab = split(path,"/")
	    res = "#" .. restab[#restab]     -- 前面加"#" 标记读取方式
	end
	
	local itemParams = {}
	itemParams.image = string.format("%s.png",res)
    itemParams.x     = item.x 
    itemParams.y     = item.y 
	itemParams.width = item.width
	itemParams.height= item.height
	itemParams.scaleX= item.scaleX
	
	local image = ui_ext.Image.new(itemParams)
	return image	
end


ui_control.newPanel = function(self,item)
	assert(type(item)=="table", "newImage item erron")
	
	local path = item.resKey
	local res = path
	if ui.USE_PLIST and path ~= "" then  -- 用plist 文件读取
		local restab = split(path,"/")
	    res = "#" .. restab[#restab]     -- 前面加"#" 标记读取方式
	end
	
	local itemParams = {}
	if res and res ~= "" then 
		itemParams.image = string.format("%s.png",res)
	end
	
    itemParams.x     = item.x 
    itemParams.y     = item.y 
	itemParams.width = item.width
	itemParams.height= item.height

	if item.backgroundAlpha then itemParams.alpha = item.backgroundAlpha * 255 end
	--itemParams.color = ccc3(dexToColor3B(item.backgroundColor))
	
	local panel = ui_ext.Panel.new(itemParams)
	return panel	
end


ui_control.newLabel = function(self,item)
	assert(type(item)=="table", "newLabel item erron")
	
	local itemParams = {}
	itemParams.text  = item.text
    itemParams.x     = item.x 
    itemParams.y     = item.y
	itemParams.font  = item.fontStyle
	itemParams.color = ccc3(dexToColor3B(item.color))
	itemParams.size  = item.fontSize
	itemParams.align = self.align[item.align]
	itemParams.dimensions = CCSize(item.width, item.height)
	itemParams.bold  = item.bold   --加粗	
	local label = ui_ext.Label.new(itemParams)
	return label	
end


ui_control.newTemplate = function(self,item, nameTab) -- 模板控件
	assert(type(item)=="table", "newTemplate item erron")
	local x = item.x
	local y = item.y
	local path = item.path
	
	local res = path
	local myLoadfile = require"base.ui.ui_parser"
	local template = myLoadfile:load_template(string.format("data/uitemplate/%s.json",res), nameTab)
	template:setPosition(x,y)
	return template	
end



--------------------------进度条-------------------------

ui_control.newProgressBar = function(self, item)
	assert(type(item)=="table", "newProgressBar item erron")
	
	local path = item.resKey
	local res = path
	if ui.USE_PLIST then  -- 用plist 文件读取
		local restab = split(path,"/")
	    res = "#" .. restab[#restab]     -- 前面加"#" 标记读取方式
	end
	
	local itemParams = {}
	itemParams.image = string.format("%s_1.png",res)
	itemParams.imagebg = string.format("%s_2.png",res) --背景图
    itemParams.x     = item.x 
    itemParams.y     = item.y 
	itemParams.dir   = item.dir
	itemParams.barX  = item.barX
	itemParams.barY  = item.barY
	itemParams.width = item.width
	if tonumber(item.isSector) == 1 then     --进度条类型，默认条形
		itemParams.types = kCCProgressTimerTypeRadial  --扇形
	end
	
	local pross = ui_ext.ProgressBar.new(itemParams)
	return pross
end

ui_control.newProgressBarLabel = function(self, item)
	assert(type(item)=="table", "newProgressBarLabel item erron")
	
	local path = item.resKey
	local res = path
	if ui.USE_PLIST then  -- 用plist 文件读取
		local restab = split(path,"/")
	    res = "#" .. restab[#restab]     -- 前面加"#" 标记读取方式
	end
	
	local itemParams = {}
	itemParams.image = string.format("%s_1.png",res)
	itemParams.imagebg = string.format("%s_2.png",res) --背景图
    itemParams.x     = item.x 
    itemParams.y     = item.y 
	itemParams.dir   = item.dir
	itemParams.barX  = item.barX
	itemParams.barY  = item.barY
	itemParams.width = item.width
	
	local labelParams = {} --label
	labelParams.labelType = item.labelType
	if  labelParams.labelType == "number" then
		labelParams.text = "0.5/1"
	else
		labelParams.text = "50%"
	end
		
	labelParams.x     = item.labelX
	labelParams.y     = item.labelY
	labelParams.color = ccc3(dexToColor3B(item.color))
	labelParams.size  = item.fontSize
	labelParams.bold  = item.bold
	
	local pross = ui_ext.ProgressBarLabel.new(itemParams, labelParams)
	return pross
end

ui_control.newProgressBarMask = function(self, item)
	assert(type(item)=="table", "newProgressBar item erron")
	
	local path = item.resKey
	local res = path
	if ui.USE_PLIST then  -- 用plist 文件读取
		local restab = split(path,"/")
	    res = "#" .. restab[#restab]     -- 前面加"#" 标记读取方式
	end
	
	local itemParams = {}
	itemParams.image = string.format("%s_1.png",res)
	itemParams.imagebg = string.format("%s_2.png",res) --背景图
    itemParams.x     = item.x 
    itemParams.y     = item.y 
	itemParams.dir   = item.dir
	itemParams.barX  = item.barX
	itemParams.barY  = item.barY
	
	local pross = ui_ext.ProgressBarMask.new(itemParams)
	return pross
end

ui_control.newProgressBarMaskLabel = function(self, item)
	assert(type(item)=="table", "newProgressBarLabel item erron")
	
	local path = item.resKey
	local res = path
	if ui.USE_PLIST then  -- 用plist 文件读取
		local restab = split(path,"/")
	    res = "#" .. restab[#restab]     -- 前面加"#" 标记读取方式
	end
	
	local itemParams = {}
	itemParams.image = string.format("%s_1.png",res)
	itemParams.imagebg = string.format("%s_2.png",res) --背景图
    itemParams.x     = item.x 
    itemParams.y     = item.y 
	itemParams.dir   = item.dir
	itemParams.barX  = item.barX
	itemParams.barY  = item.barY
	
	local labelParams = {} --label
	labelParams.labelType = item.labelType
	if  labelParams.labelType == "number" then
		labelParams.text = "0.5/1"
	else
		labelParams.text = "50%"
	end
		
	labelParams.x     = item.labelX
	labelParams.y     = item.labelY
	labelParams.color = ccc3(dexToColor3B(item.color))
	labelParams.size  = item.fontSize
	labelParams.bold  = item.bold
	
	local pross = ui_ext.ProgressBarMaskLabel.new(itemParams, labelParams)
	return pross
end
------------------------------------------

ui_control.newImageLabel = function(self, item)
	assert(type(item)=="table", "newImageLabel item erron")
	
	local path = item.resKey
	local res = path
	if ui.USE_PLIST then  -- 用plist 文件读取
		local restab = split(path,"/")
	    res = "#" .. restab[#restab]     -- 前面加"#" 标记读取方式
	end
	
	local itemParams  = {}
	itemParams.image  = string.format("%s.png",res) --背景图 
    itemParams.x      = item.x 
    itemParams.y      = item.y 
	itemParams.width  = item.width
	itemParams.height = item.height
	
	local labelParams = {} --label
	labelParams.align = item.align
	labelParams.color = ccc3(dexToColor3B(item.color))
	labelParams.size  = item.fontSize
	labelParams.bold  = item.bold
	labelParams.text  = item.text
	labelParams.font  = item.fontStyle
	labelParams.y     = item.height/2
	labelParams.x     = 5    --偏移 item.align == "left"
	
	if item.align == "center" then 
		labelParams.x = item.width/2
	elseif item.align == "right" then
		labelParams.x = item.width - 5
	end

	local pross = ui_ext.ImageLabel.new(itemParams, labelParams)
	return pross
end

ui_control.newInputText = function(self,item)
	assert(type(item)=="table", "newImage item erron")
	
	local itemParams    = {}
	
	local path = "common/InputTextBg.png"
	local res = path
	if ui.USE_PLIST then  -- 用plist 文件读取
		local restab = split(path,"/")
	    res = "#" .. restab[#restab]     -- 前面加"#" 标记读取方式
	end
	
	itemParams.image    = res
    itemParams.x        = item.x 
    itemParams.y        = item.y 
	itemParams.width    = item.width
	itemParams.height   = item.height
	itemParams.password = item.password
	itemParams.text     = item.text
	itemParams.textColor= ccc3(dexToColor3B(item.textColor))
	itemParams.maxLength= item.maxChars
	
	local inputText = ui_ext.InputText.new(itemParams)
	return inputText	
end

ui_control.newImgNumber = function(self, item)
	assert(type(item) == "table", "newImgNumber item error")

	local itemParams = {}
	local path = "headUI/a"
	local res = path

	if ui.USE_PLIST then  -- 用plist 文件读取
		local restab = split(path,"/")
	    res = "#" .. restab[#restab]     -- 前面加"#" 标记读取方式
	end

	itemParams.res = item.resKey or res
	itemParams.x = item.x or 0
	itemParams.y = item.y or 0
	itemParams.num = item.curNum or 0
	itemParams.dx = item.dx or 0

	local imgNumber = ui_ext.ImageNumber.new(itemParams)
	return imgNumber
end

return ui_control
