--2016/07/23
--create by wmh0497
--组件基类

local ClsComponentBase = class("ClsComponentBase")

function ClsComponentBase:ctor(parent)
    self.m_parent = parent
end

function ClsComponentBase:onStart(...)
    
end

function ClsComponentBase:update(dt)
end

function ClsComponentBase:onClose(...)
end

return ClsComponentBase



