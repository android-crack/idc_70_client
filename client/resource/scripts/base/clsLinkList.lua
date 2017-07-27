--2016/10/21
--create by wmh0497
--双向链表

local ClsLinkList = class("ClsLinkList")

function ClsLinkList:ctor()
    self.m_front_ref = nil
    self.m_back_ref = nil
    self.m_count = 0
end

function ClsLinkList:getCount()
    return self.m_count
end

--这个函数是加载尾的
function ClsLinkList:pushBack(value)
    local node = self:getListNode(value)
    
    if self.m_front_ref and self.m_back_ref then
        node.pre = self.m_back_ref
        self.m_back_ref.next = node
        self.m_back_ref = node
    else
        self.m_front_ref = node
        self.m_back_ref = node
    end
    
    self.m_count = self.m_count + 1
end

function ClsLinkList:pushFront(value)

    local node = self:getListNode(value)
    
    if self.m_front_ref and self.m_back_ref then
        self.m_front_ref.pre = node
        node.next = self.m_front_ref
        self.m_front_ref = node
    else
        self.m_front_ref = node
        self.m_back_ref = node
    end
    self.m_count = self.m_count + 1
end

function ClsLinkList:popBack()
    self:removeNode(self.m_back_ref)
end

function ClsLinkList:popFront()
    self:removeNode(self.m_front_ref)
end

--[[
for k, v in list.walk() do
end --]]
--遍历链表内容 function(index, value)
function ClsLinkList:walk()
    local i = 1
    local cur_node = self.m_front_ref
    return function()
        if cur_node then
            local value = cur_node.value
            local key = i
            i = i + 1
            cur_node = cur_node.next
            return key, value
        end
    end
end

--反向遍历链表内容从尾开始
function ClsLinkList:rewalk()
    local i = self.m_count
    local cur_node = self.m_back_ref
    return function()
        if cur_node then
            local value = cur_node.value
            local key = i
            cur_node = cur_node.pre
            i = i - 1
            return key, value
        end
    end
end

function ClsLinkList:getValue(index)
    local cur_node = self.m_front_ref
    local i = 1
    while (cur_node) do
        if i == index then
            return cur_node.value
        end
        i = i + 1
        cur_node = cur_node.next
    end
end

--外部不能调用
function ClsLinkList:removeNode(node)
    if node and self.m_front_ref and self.m_back_ref then
        if node.pre then
            node.pre.next = node.next
        else
            self.m_front_ref = node.next
        end
        if node.next then
            node.next.pre = node.pre
        else
            self.m_back_ref = node.pre
        end
        node.pre = nil
        node.next = nil
        node.value = nil
        self.m_count = self.m_count - 1
    end
end

function ClsLinkList:removeByValue(value)
    local cur_node = self.m_front_ref
    while (cur_node) do
        if cur_node.value == value then
            self:removeNode(cur_node)
            break
        end
        cur_node = cur_node.next
    end
end

function ClsLinkList:removeByIndex(index)
    local cur_node = self.m_front_ref
    local i = 1
    while (cur_node) do
        if i == index then
            self:removeNode(cur_node)
            break
        end
        i = i + 1
        cur_node = cur_node.next
    end
end

function ClsLinkList:insert(index, value)
    if not self.m_front_ref then
        self:pushBack(value)
        return
    end
    
    if index > self.m_count then
        if index == self.m_count + 1 then
            self:pushBack(value)
        else
            print(string.format("error!!!!!!!!!!!!!!!!!!!, has error index %d, current count is %d", index, self.m_count))
        end
        return
    end
    
    --插入
    local cur_node = self.m_front_ref
    local i = 1
    while (cur_node) do
        if i == index then
            local node = self:getListNode(value)
            
            if not cur_node.pre then
                self.m_front_ref = node
            else
                cur_node.pre.next = node
            end
            node.pre = cur_node.pre
            
            cur_node.pre = node
            node.next = cur_node
            
            self.m_count = self.m_count + 1
            break
        end
        i = i + 1
        cur_node = cur_node.next
    end
end

function ClsLinkList:printList()
    print("list -------------------", self.m_count)
    for k, v in self:walk() do
        print(string.format("[%d] = %s", k, tostring(v)))
    end
    print("- - - - - - - - - - - - ")
end

function ClsLinkList:getListNode(value)
    return {["pre"] = nil, ["next"] = nil, ["value"] = value}
end

return ClsLinkList