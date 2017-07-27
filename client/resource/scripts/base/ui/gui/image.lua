--

module("ui_ext", package.seeall)

Image = class("Image",function(itemParams)
    return ui.newImage(itemParams)
end)

Image.ctor = function(self,itemParams) -- 

end