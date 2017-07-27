local material_data_handle = class("MaterialData")

--[[
class thing_info {
int id;
int iAmount;
}

void rpc_server_material_all_info(object oUser);
void rpc_client_material_all_info(int uid, thing_info *list);

void rpc_server_drawing_all_info(object oUser);
void rpc_client_drawing_all_info(int uid, thing_info *list);

--]]

--[[
material_data_handle.material_data = {
[1001] = { count = 3},
[1002] = { count = 2},
[1003] = { count = 2},
[1004] = { count = 3},
[1005] = { count = 2},
[1006] = { count = 2},
}
--]]

material_data_handle.ctor = function(self)
    self.material_data = {}
    self.drawing_data = {}
end

material_data_handle.get_material_by_id = function( self, id)
    return self.material_data[id]
end

material_data_handle.get_materials = function( self )
    local tool = require("module/dataHandle/dataTools")
    
    local materials = {}
    for k,v in pairs(self.material_data) do
        if v.count > 0 then
            local material = table.clone(v)
            material.id = k
            material.baseData = tool:getItem(ITEM_INDEX_MATERIAL, k)
            if material.baseData then
                materials[#materials + 1] = material
            end
        end
    end
    return materials
end

material_data_handle.get_materialDic = function( self )
    return self.material_data
end

material_data_handle.set_material_item = function(self, id, m_count)
    self.material_data[id] = { count = m_count }
end

material_data_handle.add_material_item = function(self, id, m_count)
    if not self.material_data[id] then
        self.material_data[id] = { count = m_count }
    else
        self.material_data[id].count =self.material_data[id].count + m_count
    end
end

material_data_handle.set_material_list = function( self, material_list )
    for _, material_item in pairs(material_list) do
        self:set_material_item( material_item.id, material_item.iAmount )
    end
end

material_data_handle.del_material = function( self, id, count )
    if self.material_data[id] then
        self.material_data[id].count = self.material_data[id].count - count
    end
end

material_data_handle.add_material_by_list = function( self, list)
    for _, item in pairs( list ) do
        self:add_material_item( item.id, item.iAmount )
    end
end

--------------------------------------------------------------

material_data_handle.get_drawing_by_id = function( self, id)
    return self.drawing_data[id]
end


material_data_handle.set_drawing_item = function(self, id, m_count)
    self.drawing_data[id] = { count = m_count }
end

material_data_handle.add_drawing_item = function(self, id, m_count)
    if not self.drawing_data[id] then
        self.drawing_data[id] = { count = m_count }
    else
        self.drawing_data[id].count =self.drawing_data[id].count + m_count
    end
end

material_data_handle.set_drawing_list = function( self, drawing_list )
    for _, drawing_item in pairs(drawing_list) do
        self:set_drawing_item( drawing_item.id, drawing_item.iAmount )
    end
end

material_data_handle.del_drawing = function( self, id, count )
    if self.drawing_data[id] then
        self.drawing_data[id].count = self.drawing_data[id].count - count
    end
end


material_data_handle.add_drawing_by_list = function( self, list)
    for _, item in pairs( list ) do
        self:add_drawing_item( item.id, item.iAmount )
    end
end

return material_data_handle