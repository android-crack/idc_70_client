----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_yumou = class("cls_yumou", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_yumou.get_status_id = function(self)
	return "yumou";
end


-- 状态名 
cls_yumou.get_status_name = function(self)
	return T("预谋");
end

-- 增减益 
cls_yumou.get_status_type = function(self)
	return T("增益");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------
cls_yumou.affect_buff = function(self, targetBuff, tbResult)
	local rate = self.tbResult.yumou_baoji_rate
    local times = self.tbResult.baoji_times
    
    if rate > math.random(1000) then
        tbResult.sub_hp = tbResult.sub_hp * times
        tbResult.baoji_flg = true
    end
	return tbResult
end