local ShipBuffIconNode = class("ShipBuffIconNode",function() return display.newNode() end)

local png_sort = {
    "gong",
    "fang",
    "su",
    "liao",
    "ruo",
}

function ShipBuffIconNode:ctor(parent, reverseFlag, buff_pic)
    self.buff_icon = buff_pic
    self.buff_icon_count = {}
    --self.buff_icon_retain = {}

    self.parent = parent
    self.reverseFlag = reverseFlag
end

function ShipBuffIconNode:InsertBuffIcon(buffIconPath)

    -- if tolua.isnull(self) or buffIconPath == "" then
    --     return
    -- end

    -- if self.buff_icon[buffIconPath] then
    --     self.buff_icon_retain[buffIconPath] = self.buff_icon_retain[buffIconPath] + 1
    --     return
    -- end

 --    local iconSprite = display.newSprite("#"..buffIconPath)
 --    if not iconSprite then
 --        return
 --    end
	-- iconSprite:setAnchorPoint(ccp(0.5, 1))
    if buffIconPath == "" then
        return 
    end


    local index = 0
    for k, v in ipairs(png_sort) do
        local i, j = string.find(buffIconPath, v)
        if i and j then
            index = k 
            break
        end
    end

    if index == 0 then return end 
    self.buff_icon[index]:setVisible(true)

   self.buff_icon[index]:changeTexture(buffIconPath, UI_TEX_TYPE_PLIST)

    if self.buff_icon[index]:isVisible() then
        self.buff_icon_count[#self.buff_icon_count + 1] = buffIconPath        
    end

end


function ShipBuffIconNode:RemoveBuffIcon(buffIconPath)

    if buffIconPath == "" then
        return 
    end
    -- if tolua.isnull(self) or not self.buff_icon[buffIconPath] then
    --     return
    -- end

    -- if self.buff_icon_retain[buffIconPath] > 1 then
    --     self.buff_icon_retain[buffIconPath] = self.buff_icon_retain[buffIconPath] - 1
    --     return
    -- end

    --self:removeChild(self.buff_icon[buffIconPath])

    local index = 0
    for k, v in ipairs(png_sort) do
        local i, j = string.find(buffIconPath, v)
        if i and j then
            index = k 
            break
        end
    end
    self.buff_icon[index]:setVisible(false)

    --self.buff_icon[buffIconPath] = nil
    for k, v in ipairs(self.buff_icon_count) do
        if v == buffIconPath then
            table.remove(self.buff_icon_count, k)
            break
        end
    end
    --self.buff_icon_retain[buffIconPath] = nil
end

return ShipBuffIconNode