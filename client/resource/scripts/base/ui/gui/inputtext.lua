-- 输入框

module("ui_ext", package.seeall)

InputText = class("InputText",function(itemParams)
    return ui.newEditBox(itemParams)
end)

ImageLabel.ctor = function(self,itemParams)

end 