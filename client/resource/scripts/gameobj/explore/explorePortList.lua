
local SwitchView=require("ui/tools/SwitchView")
local ListView = class("ListView",SwitchView)

function ListView:onTouchEndedWithTap(x, y) --点击，非拖动
    local count=#self.cells
    if count==0 or not self.rect:containsPoint(ccp(x, y)) then return end
    for i=1,count do
        local pos =self.view:convertToNodeSpace(ccp(x,y))
        if self.cells[i]:boundingBox():containsPoint(pos) then

            if i~=self.index then
                self.index = i
            end
            if type(self.cells[self.index].onTap)=="function" then
                self.cells[self.index]:onTap(x,y)
            end
        end
    end
end

function ListView:onTouchMoved(x, y)
    ListView.super.onTouchMoved(self, x, y)

    if self.touchMovedCallBack ~= nil then
        self.touchMovedCallBack(x, y)
    end
end

function ListView:setTouchMovedCallBack(callBack)
    self.touchMovedCallBack = callBack
end

return ListView