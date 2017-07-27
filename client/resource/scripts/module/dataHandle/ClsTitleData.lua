local dataTools = require("module/dataHandle/dataTools")

local ClsTitleData = class("ClsTitleData")

function ClsTitleData:ctor()
    self.all_titles = {}  --所有称号
    self.m_all_list = {} -- 存放服务器数据
    self.current_title = 0  --当前装备的称号
end
--获取当前装备的称号id
function ClsTitleData:getCurTitle()
    return self.current_title
end
--根据id获取title
function ClsTitleData:getTitleByID(id)
    if not id then return end
    for k, v in ipairs(self.all_titles) do
        if v.id == id then
            local title = table.clone(self.all_titles[k])
            return title
        end
    end
    return nil
end
--设置当前装备的称号
function ClsTitleData:setCurTitle(id)
    if not id then return end
    self.current_title = id
    local clsRoleInfoView = getUIManager():get("ClsRoleInfoView")
    if not tolua.isnull(clsRoleInfoView) then
        local title = self:getTitleByID(id)
        if title then
            local str_performance = title.performance
            if title.priority == 3 then
                str_performance = "$" .. string.split(str_performance, "$")[2]
            end
            clsRoleInfoView:addRichLabel(str_performance, title)
        end
    end
end
--获取所有称号
function ClsTitleData:getAllTitles()
    return self.all_titles
end

--添加称号
function ClsTitleData:addToList(title_l)
    local title = dataTools:getTitle(title_l.id)
    if title then
        local t_performance = string.split(title.performance, "|")
        if title_l.arg_number ~= 0 then
            title.performance = ""
            for i = 1, title_l.arg_number do
                title.performance = title.performance .. string.format(t_performance[i], title_l.args[i])
            end
        end

        title.id = title_l.id
        for k, v in ipairs(self.all_titles) do
            if v.id == title.id then
                table.remove(self.all_titles, k)
                break
            end
        end
        self.all_titles[#self.all_titles + 1] = title
    end
end

function ClsTitleData:setAllTitleList(list)
    self.m_all_list = list
end

function ClsTitleData:getAllTitleList()
    return self.m_all_list
end


function ClsTitleData:delItemOfAllTitleList(id)
    for k,v in pairs(self.m_all_list) do
        if id == v.id then
            self.m_all_list[k] = nil
        end
    end
    -- print('----after del')
    -- table.print(self.m_all_list)
end

function ClsTitleData:addItemOfAllTitleList(item)
    self.m_all_list[#self.m_all_list+1] = item
end

function ClsTitleData:getTitleDataById(id)
    for k,v in pairs(self.m_all_list) do
        if id == v.id then
            return v
        end
    end
    return
end

--所有称号获取
function ClsTitleData:receiveAllTitles(list)
    for k, v in pairs(list) do
        self:addToList(v)
    end
end
--增加新称号
function ClsTitleData:addTitle(title_l)
    self:addToList(title_l)
end
--删除称号
function ClsTitleData:delTitle(title_id)
    if self.current_title == title_id then
        self.current_title = 0
    end
    for k, v in ipairs(self.all_titles) do
        if v.id == title_id then
            table.remove(self.all_titles, k)
            break
        end
    end
end

function ClsTitleData:setIsToPlayEffect(state)
    self.is_to_play_effect = state
end

function ClsTitleData:getIsToPlayEffect()
    return self.is_to_play_effect
end

-- rpc
-- 更换称号
function ClsTitleData:requestChangeTitle(id)
    GameUtil.callRpc("rpc_server_title_current",{id})
end


function ClsTitleData:requestAllTitle()
    GameUtil.callRpc("rpc_server_title_list",{})
end

return ClsTitleData
