-- panel 

module("ui_ext", package.seeall)

Panel = class("Panel", function(itemParams)
    return ui.newPanel(itemParams)
end)

Panel.ctor = function(self,itemParams) -- 

end
