-- label

module("ui_ext", package.seeall)

Label = class("Label",function(itemParams)
    return ui.newTTFLabel(itemParams)
end)

Label.ctor = function(self,itemParams) -- 

end
