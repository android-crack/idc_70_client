-- quick cocos2d 自带一个class文件，这文件暂时不用
-- 请不要require这个文件 -- canux 2013-0516

--基础类库

--获取一个class的父类
function Super(TmpClass)
	return getmetatable(TmpClass).__index
end

--判断一个class或者对象是否
function IsSub(clsOrObj, Ancestor) 
	local Temp = clsOrObj
	while  1 do
		local mt = getmetatable(Temp)
		if mt then
			Temp = mt.__index
			if Temp == Ancestor then
				return true
			end
		else
			return false
		end
	end
end

--暂时没有一个比较好的方法来防止将Class的table当成一个实例来使用
--大家命名一个Class的时候一定要和其产生的实例区别开来。
clsObject = {
		--用于区别是否是一个对象 or Class or 普通table
		__ClassType = "<base class>"
}

clsObject.Inherit = function (self, o)	
	o = o or {}

	--没有对table属性做深拷贝，如果这个类有table属性应该在init函数中初始化
	--不应该把一个table属性放到class的定义中
	setmetatable(o, {__index = self})

	return o
end

clsObject.New = function (self, ... )
	local o = {}

	--没有初始化对象的属性，对象属性应该在init函数中显示初始化
	--如果是子类，应该在自己的init函数中先调用父类的init函数

	setmetatable(o, {__index = self } )

	-- 定义对象类型
	o.__ObjectType="object of " .. (self.__ClassType or "<base class>")

	if o.__init__ then
		local arg = {...}
		o:__init__(unpack(arg))
	end

	o.IsClass = function(self)
		return false
	end 

	o.IsObject = function(self)
		return true
	end

	return o
end

clsObject.__init__ = function(self)
	--nothing
end

-- 区分普通Table 和Class用，不是表示本Table为类原形
clsObject.IsClass = function (self)
	return true
end

clsObject.IsObject = function (self)
	return false
end

--[[ -- 暂时没有对象删除方法
function clsObject:Destroy()
	--所有对象释放的时候删除callout
	CALLOUT.RemoveObjCallOut(self)
end
--]]
