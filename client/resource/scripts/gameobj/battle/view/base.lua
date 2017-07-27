local ClsView = class("ClsView")

function ClsView:ctor(...)
    self.args = {}
end

function ClsView:GetId()
    return "base"
end

function ClsView:InitArgs(...) 
end

-- 播放
function ClsView:Show()
end

-- 记录协议时，一般是录像时执行
function ClsView:record(battleRecord)
end

-- 收到协议时，一般是播放方执行
function ClsView:gotProtcol(cur_frame)
end

function ClsView:serialize(frame)
    local args = {frame, self.args}
    local str = json.encode(args)

    return str  
end

function ClsView:unserialize(str)
    local tb = json.decode(str)

    local max = 1

    self.args = {}
    if type(tb[2]) == "table" then
        for k, v in pairs(tb[2]) do
            if max < k then
                max = k
            end
            self.args[k] = v
        end
    end

    for i = 1, max do
        if self.args[i] == nil then
            self.args[i] = nil
        end
    end

    self:InitArgs(unpack(self.args))

    return tb[1]
end

-- 记录view从何人来
function ClsView:setSourceId(uid)
    self.__source_id = uid
end

function ClsView:getSourceId()
    return self.__source_id or 0
end

return ClsView
