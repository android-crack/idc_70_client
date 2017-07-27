--
-- Author: Ltian
-- Date: 2015-10-26 14:06:08
--
local ClsMailData = class("ClsMailData")

local NORMAL_MAIL_TYPE = 1
local GUILD_MAIL_TYPE = 2

function ClsMailData:ctor()
	self.mail_info = {}
	
	-- 最大数量邮件，目前写死客户端
	self.max_count_mail = 50  
end

function ClsMailData:sortAllMail()
	table.sort(self.mail_info, function(a, b)
		if a.time == b.time then
			return a.id > b.id
		else
			return a.time > b.time
		end
	end)
	for k, v in ipairs(self.mail_info) do
		if v.argsJson then
			if string.len(v.argsJson) > 0 and nil == v.guildInfo then
				v.guildInfo = json.decode(v.argsJson)
			end
		end
	end
end

function ClsMailData:setMailInfo(data)
	self.mail_info = data
	self:sortAllMail()
end

function ClsMailData:getMailInfo()
	return self.mail_info
end

function ClsMailData:getMailMaxCount()
	return self.max_count_mail
end

function ClsMailData:getMailByID(mail_id)
	for k,v in pairs(self.mail_info) do
		if mail_id == v.id then
			return v
		end
	end
	return nil
end

function ClsMailData:readMail(mail_id)
	GameUtil.callRpc("rpc_server_mail_read", {mail_id})
end

function ClsMailData:updateMailInfoStatus(mail_id, status)
	if 3 == status then
		local result_tab = {}
		for k, v in ipairs(self.mail_info) do
			if mail_id ~= v.id then
				result_tab[#result_tab + 1] = v
			end
		end
		self.mail_info = result_tab
		self:sortAllMail()
		return
	end
	
	for k,v in pairs(self.mail_info) do
		if mail_id == v.id then
			v.status = status
			return
		end
	end
end

function ClsMailData:insertMailInfo(data)
	for k, v in pairs(self.mail_info) do
		if v.id == data.id then
			self.mail_info[k] = data
			self:sortAllMail()
			return
		end
	end
	self.mail_info[#self.mail_info + 1] = data
	self:sortAllMail()
end
function ClsMailData:getMailCount()
	return #self.mail_info
end

function ClsMailData:getLimit20Mail()
	-- local max_count = #self.mail_info
	-- if max_count > self.max_count_mail then 
	-- 	max_count = self.max_count_mail
	-- end 

	-- local result_tab = {}
	-- for i = 1, max_count do
	-- 	result_tab[i] = self.mail_info[i]
	-- end
	return self.mail_info
end

function ClsMailData:getSortedLimit20Mail()
	local result_tab = self:getLimit20Mail()
	table.sort(result_tab, function(a, b)
		if a.status == b.status then
			if a.time == b.time then
				return a.id > b.id
			else
				return a.time > b.time
			end
		else
			return a.status < b.status
		end
	end)
	return result_tab
end

function ClsMailData:isGuildMail(data)
    if data then
        if data.type == GUILD_MAIL_TYPE then
            return true
        end
    end
    return false
end

return ClsMailData