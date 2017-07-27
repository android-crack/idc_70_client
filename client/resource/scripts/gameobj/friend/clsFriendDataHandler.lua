
local ClsDataHandler = class("ClsDataHandler")

function ClsDataHandler:ctor(key)
	self.key = key
	self.uid_list = {}
	self.num_list = {}
end

--插入数据到uid_list
function ClsDataHandler:initUidListByUid(uid)
	--初始化
	self.uid_list[uid] = {}
end

function ClsDataHandler:initUidListByInfo(info)
	self.uid_list[info.uid] = info
end

function ClsDataHandler:insertDataToUidList(info)
	--有就更新最新的，没有就初始化
	if self.uid_list[info.uid] then
		for k, v in pairs(info) do
			self.uid_list[info.uid][k] = v
		end
	else
		self.uid_list[info.uid] = info
	end
end

--更新数据值为列表
function ClsDataHandler:updateDataList(list)
	for k, v in ipairs(list) do
		self:updateData(v)
	end
end

--更新数据单个
function ClsDataHandler:updateData(info)
	if not self.uid_list[info.uid] then return end

	self.uid_list[info.uid][info.key] = info.value

	for k, v in ipairs(self.num_list) do
		if v.uid == info.uid then
			v[info.key] = info.value
			break
		end
	end
end

--插入数据到num_list
function ClsDataHandler:insertDataToNumList(info)
	local is_exist = false
	for k, v in ipairs(self.num_list) do
		if v.uid == info.uid then
			for i, j in pairs(self.uid_list[info.uid]) do
				self.num_list[k][i] = j
			end
			is_exist = true
			break
		end
	end
	if not is_exist then
		table.insert(self.num_list, self.uid_list[info.uid])
	end
end

function ClsDataHandler:removeObj(uid)
	self.uid_list[uid] = nil
	for k, v in ipairs(self.num_list) do
		if v.uid == uid then
			table.remove(self.num_list, k)
			break
		end
	end
end

function ClsDataHandler:clean()
	self.uid_list = {}
	self.num_list = {}
end

return ClsDataHandler
