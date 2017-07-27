--************************************--
-- author: hal
-- data: 2015-07-24
-- descript: 维护一个按先后顺序建立的特效队列
--
-- modify:
-- who         data            reason
--
--
--************************************--

local battleRecording = require("gameobj/battle/battleRecording")

function trace_debug( str )
	-- body
	print( str );
end
function report_debug( switch, str )
	-- body
	assert( switch, str );
end
local debug = { 
	report = report_debug,
	trace = function( ... )
		-- body
	end,
};

require( "resource_manager" )

local configValueCache = {}
local getValueFromCache = function(fileName, index)
	local isFind = true
	configValueCache[fileName] = configValueCache[fileName] or {}
	if not configValueCache[fileName][index] then
		configValueCache[fileName][index] = {}
		isFind = false
	end
	
	return configValueCache[fileName][index], isFind
end

-- 展示
local render_param_mapping = 
{
    u_diffuseTexture = "texture",
	u_texSpeed = "Vector4",
	u_mainIntensity = "number",
	u_mainColor = "Vector4",
	u_diffuseTextureST = "Vector4",
	u_maskTexST = "Vector4",
	u_maskTex = "texture",
	u_flowTexColor = "Vector4",
	u_flowTexST = "Vector4",
	u_flowTex = "texture",
	u_flowIntensity = "number",
	cullface = "renderstate",
	blend = "renderstate",
	blendSrc = "renderstate",
	blendDst = "renderstate",
}

local function replaceRenderParameter(effect, flow_param, path_base, node_name )
	if not effect then return end
	for param_name, param_value in pairs( flow_param ) do

		local draw_param = effect:getParameter( param_name );
		local param_type = render_param_mapping[ param_name ];
		if param_type == "Vector4" then
			draw_param:setValue( Vector4.new( param_value[1], param_value[2], param_value[3], param_value[4] ) );
		elseif param_type == "Vector3" then
			draw_param:setValue( Vector3.new( param_value[1], param_value[2], param_value[3] ) );
		elseif param_type == "number" then
			draw_param:setValue( param_value );
		elseif param_type == "texture" then
			local samplername 
			if string.find(param_value.path, ".png") then 
				samplername = get3DSamplePath(path_base, node_name, param_value.path)
			else
				samplername = param_value.path
			end
			local sampler = draw_param:setValue(samplername, param_value.mipmap == "true" )
			if sampler then
				sampler:setWrapMode( param_value.wrapS, param_value.wrapT );
				sampler:setFilterMode( param_value.minFilter, param_value.magFilter );
			end
		elseif param_type == "renderstate" then 
			effect:getStateBlock():setState(param_name, param_value)
		end
	end
end



--------------------------------------
-- 特效基类
local ClsEffect = class( "ClsEffect" )

function ClsEffect:ctor( ... )
	-- body
	self.type = "";							-- 类型（纹理or模型or粒子）
	self.original = Vector3.new( 0, 0, 0 );	-- 对象的原始相对位置
	self.speed = 15;						-- 运动速度

	self.title = "";						-- 节点名字

	-- 其它属性
	self.parameters = {};
end

-- 创建并初始化对象
function ClsEffect:create( target, parent, config, fileName )
	-- body
	debug.trace( T("对象创建未实现。---------------------------- By Hal" ));
end

-- 获取类型
function ClsEffect:getType( ... )
	-- body
	return self.type;
end

-- 获取名字
function ClsEffect:getTitle( ... )
	-- body
	return self.title;
end

-- 获取对象
function ClsEffect:getTargets( ... )
	-- body
	return nil;
end

-- 设置根位置
function ClsEffect:under( position )
	-- body
end

-- 跟随到指定位置
function ClsEffect:follow( position, second )
	-- body
end

-- 设置速度
function ClsEffect:setSpeed( speed )
	-- body
	self.speed = speed;
end

-- 设置属性
function ClsEffect:setParameters( param_type, param_value )
	-- body
	if not param_type then return end
	if not param_value then return end

	self.parameters[ param_type ] = param_value;

end

-- 设置根位置
function ClsEffect:offset( position, offset )
	-- body
	local foothold = Vector3.new( 0, 0, 0 );
	Vector3.add( position, offset, foothold );
	return foothold;
end

-- 跟随到指定位置
function ClsEffect:walk( position, original, offset, aspeed, second )
	-- body
	local direction = Vector3.new( 0, 0, 0 );
	Vector3.subtract( position, original, direction );
	direction:normalize();

	-- 如果加速太高，就转为匀速运动
	local speed = aspeed * second;
	if speed > self.speed then
		speed = self.speed;
	end
	local distance = speed * second;

	direction.scale( distance );

	local foothold = Vector3.new( 0, 0, 0 );
	Vector3.add( original, direction, foothold );
	Vector3.add( foothold, offset, foothold );

	return foothold;
end

-- 特效更新
function ClsEffect:update( millisecond )
	-- body
	return true;
end

-- 设置期间
function ClsEffect:setDuration( duration )
	-- body
end

-- 展示
function ClsEffect:display( is_show )
	-- body
end

-- 枚举本身的对象
function ClsEffect:enumObject( batch_object )
	-- body
end

-- 特效回收
function ClsEffect:release( ... )
	-- body
end

--------------------------------------
-- 纹理类特效
local ClsTextureEffect = class( "ClsTextureEffect", ClsEffect)

function ClsTextureEffect:ctor( ... )
	-- body
	self.type = "texture";
	self.target = nil;
	self.visible = false;
end

-- 创建并初始化对象
function ClsTextureEffect:create( target, parent, config, fileName)
	-- body
	self.target = target;
	self.title = config:getId();

	return true;

end

-- 展示
function ClsTextureEffect:display( is_show )
	-- body
	if not self.target then return end

	local target_model = self.target:getModel();
	if not target_model then return end

	local target_material = target_model:getFirstMaterial();
	local original_tech = target_material:getTechnique();
	local original_tech_name = original_tech:getId();
	local technique_name = string.gsub( original_tech_name, "_outline", "" );

	local is_use_outline = self.parameters[ "outline" ];
	if not is_use_outline then
		-- 不用处理
	else
		technique_name = technique_name.."_outline";
	end

	local technique = target_material:getTechnique( technique_name );
	if technique then 
		target_material:setTechnique( technique_name );
	else
		return
	end

	self.visible = is_show;
	if self.visible then

		local flow_name = self.parameters[ "flow_name" ];
		if not flow_name then return end

		local flow_config = require( "game_config/model_flow/"..flow_name );
		if flow_config then

			local flow_param = flow_config[ flow_name ];
			if flow_param then
				local pass = technique:getPass( "texture_flow" );
				replaceRenderParameter( pass, flow_param, SHIP_3D_PATH, flow_name );
			end
		end
	end

end

-- 特效回收
function ClsTextureEffect:release( ... )
	-- body

end

--------------------------------------
-- 模具类特效
local ClsModelEffect = class( "ClsModelEffect", ClsEffect)
	

function ClsModelEffect:ctor( ... )
	-- body
	self.type = "model";

	self.filename = nil;						-- 对应的文件名
	self.position = Vector3.new( 0, 0, 0 );		-- 初始相对位置(相对原点的偏移位置)
	self.rotation = Quaternion.new();			-- 初始旋转量(相对原点的旋转量)
	self.scale = Vector3.new( 1, 1, 1 );		-- 初始缩放
	self.model = nil;							-- 模具对象
end


-- 创建并初始化对象
function ClsModelEffect:create( target, parent, config, fileName, index)
	-- body
	self.title = config:getId()
	local configCache, result = getValueFromCache(fileName, index)
	local model_name
	local animation_name
	local action_name
	local liuguang_name
	if result then
		model_name = configCache["model_name"]
		animation_name = configCache["animation_name"]
		action_name = configCache["action_name"]
		liuguang_name = configCache["liuguang"]
		self.position:set(configCache["position"]["x"],
		 				  configCache["position"]["y"],
		 				  configCache["position"]["z"])
		self.scale:set(configCache["scale"]["x"],
					   configCache["scale"]["y"],
					   configCache["scale"]["z"])
		self.rotation:set(configCache["rotate"]["x"],
						  configCache["rotate"]["y"],
						  configCache["rotate"]["z"],
						  configCache["rotate"]["w"])
	else
		model_name = config:getString("model_name")
		configCache["model_name"] = model_name
		animation_name = config:getString("animation_name")
		configCache["animation_name"] = animation_name
		action_name = config:getString("action_name")
		configCache["action_name"] = action_name
		liuguang_name = config:getString("liuguang")
		configCache["liuguang"] = liuguang_name
		config:getVector3( "position", self.position )
		configCache["position"] = {["x"] = self.position:x(), 
								   ["y"] = self.position:y(),
								   ["z"] = self.position:z()}
		config:getVector3( "scale", self.scale )
		configCache["scale"] = {["x"] = self.scale:x(),
								["y"] = self.scale:y(),
								["z"] = self.scale:z()}
		config:getQuaternionFromAxisAngle( "rotate", self.rotation )
		configCache["rotate"] = {["x"] = self.rotation:x(),
			 					 ["y"] = self.rotation:y(),
			 					 ["z"] = self.rotation:z(),
			 					 ["w"] = self.rotation:w()}
	end
	
	local body = nil
	if model_name and model_name ~= "" then 
		--local gpb_path = string.format( "%s%s/%s.gpb", MODEL_3D_PATH, model_name, model_name )
		--self.model = ResourceManager:LoadModel( gpb_path, string.format("%s", model_name))
		local ClsModel3D = require("gameobj/model3d")
		body = ClsModel3D.new({path = MODEL_3D_PATH, node_name = model_name, parent = parent})
	else
		return 
	end
	
	self.model = body.node
	self.model:setTag( "_name", self.title );
	self.model:setTranslation( Vector3.zero() );
	self.model:setIdentity();
	self.model:setTranslation( self.position );
	self.model:scale( self.scale );
	self.model:rotate( self.rotation );

	local position = target:getTranslationWorld();
	self.original = Vector3.new( position:x(), position:y(), position:z() );

	-- 处理动作
	if action_name and action_name ~= "" then
		local action_data = require(string.format("game_config/u3d_data/action/%s", action_name))
		require("module/u3dAnimationParse"):loadAnimation(body, action_data, false)
	end
	
	-- 流光
	if liuguang_name and liuguang_name ~= "" then 
		body:setFlowState(liuguang_name)
	end
	return true
end

-- 获取对象
function ClsModelEffect:getTargets( ... )
	-- body
	return self.model;
end

-- 设置根位置
function ClsModelEffect:under( position )
	-- body
	self.original = self:offset( position, self.position );
end

-- 跟随到指定位置
function ClsModelEffect:follow( position, second )
	-- body
	self.speed = 15;
	self.original = self:walk( position, self.original, self.position, self.speed, second );
end

-- 特效更新
function ClsModelEffect:update( millisecond )
	-- body
	-- self.model:setTranslation( self.original );

	return true;
end

-- 展示
function ClsModelEffect:display( is_show )
	-- body
	if not self.model then return end

	self.model:setActive( is_show );
	-- Play animation
	local animations = self.model:getAnimation("animations")
	if animations then 
		local clip = animations:getClip("move")
		if clip then 
			clip:play()
		end
	end
end

-- 枚举本身的对象
function ClsModelEffect:enumObject( batch_object )
	-- body
	table.insert( batch_object, { sort = self.type, node = self.model } );
end

-- 特效回收
function ClsModelEffect:release( ... )
	-- body
	if self.model ~= nil then
		local parect = self.model:getParent();
		if parect ~= nil then
			parect:removeChild( self.model );
		end
	end
	self.model = nil
end

--------------------------------------
-- 粒子类特效
local ClsParticleEffect = class( "ClsParticleEffect", ClsEffect)


function ClsParticleEffect:ctor( ... )
	-- body
	self.type = "particle";

	self.filename = nil;						-- 对应的文件名
	self.position = Vector3.new( 0, 0, 0 );		-- 初始相对位置(相对原点的偏移位置)
	self.rotation = Vector4.new( 0, 0, 0, 0 );	-- 初始旋转量(相对原点的旋转量)
	self.emitter = nil;							-- 粒子对象
	self.node = nil;							-- 本身

	self.parent = nil;							-- 父对象

end

-- 创建并初始化粒子对象
function ClsParticleEffect:create( target, parent, config, fileName, index)
	-- body
	self.title = config:getId();
	
	local configCache, result = getValueFromCache(fileName, index)
	--从缓存里构建
	if result then
		self.filename = configCache["file"]
		self.order = configCache["order"]
		self.position:set(configCache["position"]["x"], 
						  configCache["position"]["y"],
						  configCache["position"]["z"])
		self.rotation:set(configCache["rotate"]["x"],
		  				  configCache["rotate"]["y"],
		  				  configCache["rotate"]["z"],
		  				  configCache["rotate"]["w"])
	else
		self.filename = config:getPath( "file" );
		configCache["file"] = self.filename
		self.order = config:getInt("order");
		configCache["order"] = self.order
		config:getVector3( "position", self.position );
		configCache["position"] = {["x"] = self.position:x(), 
								   ["y"] = self.position:y(),
								   ["z"] = self.position:z()}
		config:getVector4( "rotate", self.rotation );
		configCache["rotate"] = {["x"] = self.rotation:x(),
								 ["y"] = self.rotation:y(),
								 ["z"] = self.rotation:z(),
								 ["w"] = self.rotation:w()}
	end
	self.emitter = ResourceManager:LoadParticleEmitter( self.filename, self.order )--ParticleEmitter.create( self.filename, self.order );
	if self.emitter == nil then
		debug.report( false, "error:"..self.filename.." not find!!!!" );
	else
		debug.trace( self.filename.." loaded!! ---------------------------------- By Hal" );
	end

	self.node = Node.create();
	parent:addChild( self.node );
	parent:setTranslation( Vector3.zero() );
	self.node:setIdentity();
	self.node:setTranslation( self.position )
	self.node:setRotation(self.rotation:x(), self.rotation:y(), self.rotation:z(), self.rotation:w())
	self.node:setParticleEmitter( self.emitter );
	self.node:setTag( "_order", tostring( self.order ) );
	self.node:setTag( "_name", self.title );
	self.node:setId( self.title );

	self.parent = parent;
	local position = target:getTranslationWorld();
	self.original = Vector3.new( position:x(), position:y(), position:z() );

	return true;
	
end

-- 获取对象
function ClsParticleEffect:getTargets( ... )
	-- body
	return self.node;
end

-- 设置根位置
function ClsParticleEffect:under( position )
	-- body
	self.original = self:offset( position, self.position );
end

-- 跟随到指定位置
function ClsParticleEffect:follow( position, second )
	-- body
	self.speed = 15;
	local original = self.original;
	self.original = self:walk( position, self.original, self.position, self.speed, second );
end

-- 特效更新
function ClsParticleEffect:update( millisecond )
	-- body
	-- 更新新位置
	-- self.node:setTranslation( self.original );

	if self.emitter then
		return self.emitter:isStarted();
	end
	return false;
end

-- 展示
function ClsParticleEffect:display( is_show )
	-- body
	if self.emitter == nil then return end
	if self.node == nil then return end

	if is_show == true then
		self.emitter:start();
	else
		self.emitter:stop();
	end

	self.node:setActive( is_show );
end

-- 设置期间
function ClsParticleEffect:setDuration( duration )
	-- body
	if self.emitter ~= nil then
		self.emitter:setSystemDuration( tonumber( duration ) );
	end
end

-- 枚举本身的对象
function ClsParticleEffect:enumObject( batch_object )
	-- body
	table.insert( batch_object, { sort = self.type, node = self.node } );
end

-- 特效回收
function ClsParticleEffect:release( ... )
	-- body
	if self.emitter ~= nil then
		local emitter = self.emitter;
		local node = emitter:getNode();
		node:setParticleEmitter( nil );

		local parect = self.node:getParent();
		if parect ~= nil then
			parect:removeChild( self.node );
		end
	end
end

local ENUM_EFFECT_POSITION = {
	FIXED = 1,
	BINDING = 2,
	FOLLOW = 3,
};

local ENUM_EFFECT_INTERRUOT = {
	END = 1,
	HIDE = 2,
	RELEASE = 3,
};

--------------------------------------
-- 特效构成器
local ClsCompriseEffect = class( "ClsCompriseEffect" )

function ClsCompriseEffect:ctor( ... )
	-- body
	self.priority = 0;			-- 优先级
	self.property = 0;			-- 关系

	self.style = ENUM_EFFECT_POSITION.BINDING;				
								-- 风格（定点、绑定 or 跟随）

	self.period = -1;			-- 生命周期
	self.elapse = 0;			-- 流逝的时间

	self.batch_effect = {};		-- 特效
	self.root_node = nil;		-- 根节点
	self.parent = nil;			-- 父对象

end

-- 创建
function ClsCompriseEffect:create( target, filename, batch_exclude )
	-- body
	debug.trace( string.format( "load { %s } ------------------------------------ By Hal", filename ) );

	if target == nil then return false; end
	if filename == nil then return false; end
	if filename == "" then return false; end

	local properties = ResourceManager:LoadPropertiesFile( filename )
	if properties == nil then
		properties = ResourceManager:LoadPropertiesFile( EFFECT_3D_PATH.."tx_qihuo.particlesystem" )
	end	
	
	local archives = properties:getNamespace( "ParticleSystem", true, false );
	archives:rewind();

	-------------------------------------------------
	-- FIX: 对于仅有流光的特效此物有点多余
	self.root_node = Node.create();
	self.root_node:setIdentity();

	local name = archives:getId()
	self.root_node:setTag( "_name", name );
	self.root_node:setId( name.."-root" );
	-------------------------------------------------
	local tempIndex = 0
	while true do

		-- 获取粒子特效子段设置
		local configs = archives:getNextNamespace();
		tempIndex = tempIndex + 1
		if configs == nil then break end

		local child_type = configs:getNamespace();
		if child_type == nil then debug.report( false, "error: namespace empty!!!!" ); break; end

		local object = nil;

		-- 检查排除类型
		local need_create = true;
		for _, exclude_type in ipairs( batch_exclude ) do
			if child_type == exclude_type then
				need_create = false;
				break;
			end
		end

		-- 在排除表中，则不再加载
		if need_create == true then

			-- 按不同类型创建对象
			if child_type == "Model" then
				object = ClsModelEffect.new();
			elseif child_type == "Emitter" then
				object = ClsParticleEffect.new();
			else
				object = ClsTextureEffect.new();
			end

			-- 初始化对象
			if object ~= nil then
				if object:create( target, self.root_node, configs, filename, tempIndex ) then
					table.insert( self.batch_effect, object );
				end
			else
				debug.report( false, "error: "..filename.." unload!!!")
			end

		else
			debug.trace( string.format( "exclude { %s } ------------------------------------ By Hal", configs:getId() ) );
		end

	end

	self.parent = target;

	return true;

end

-- 获取根节点
function ClsCompriseEffect:getNode( ... )
	-- body
	return self.root_node;
end

-- 更新
function ClsCompriseEffect:update( second )
	-- body
	local last_elapse = self.elapse;

	-- 将流逝的时间累计
	self.elapse = self.elapse + second;

	local finish = true;
	for _, effect in ipairs( self.batch_effect ) do
		local result = effect:update( self.elapse );
		if result == true then
			finish = false;
		end
	end

	if finish == false then

		-- 检查特效的生命周期
		if self.period <= 0 then finish = false; end			-- 生命周期为负（一般为-1），为无限期（循环）特效
		if self.elapse < self.period then
			finish = false;
		end

	else
		-- 粒子都结束了，就等于结束了
	end

	return finish;
end

-- 显示
function ClsCompriseEffect:display( is_show )
	self:perform("display", is_show)
end

-- 设置特定参数
function ClsCompriseEffect:setParameters( effect_sort, param_type, param_value )
	-- body
	local effect_count = #self.batch_effect;
	if effect_count == 0 then return false; end

	for _, effects in ipairs( self.batch_effect ) do
		if effect_sort == nil or effect_sort == "all" then
			-- 如果没有设定或设定为全部，则所有对象加上此外部参数
			effects:setParameters( param_type, param_value );
		elseif effect_sort == effects:getType() then 
			-- 如果设定了类型，则所有指定类型加上此外部参数
			effects:setParameters( param_type, param_value );
		elseif effect_sort == string.format( "#%s", effects:getTitle() ) then
			-- 如果类型为：#effectTitle 则对应的目标更新外部参数
			effects:setParameters( param_type, param_value );
		end

	end
end

-- 刷新对象
function ClsCompriseEffect:refresh( unity_title, function_name, ... )
	-- body
	local effect_count = #self.batch_effect;
	if effect_count == 0 then return false; end

	for _, effects in ipairs( self.batch_effect ) do
		if unity_title == nil or unity_title == "all" then
			-- 如果没有设定或设定为全部，则所有对象加上此外部参数
			effects[ function_name ]( effects, ... );
		elseif unity_title == effects:getTitle() then 
			-- 如果设定了类型，则所有指定类型加上此外部参数
			effects[ function_name ]( effects, ... );
		end

	end

end

-- 执行操作
function ClsCompriseEffect:perform(function_name, ...)
	local effect_count = #self.batch_effect
	if effect_count == 0 then return false end

	for _, effects in ipairs(self.batch_effect) do
		effects[function_name](effects, ...)
	end
end

-- 删除
function ClsCompriseEffect:release( ... )
	-- body
	local effect_count = #self.batch_effect;
	if effect_count == 0 then return false; end

	for _, effect in ipairs( self.batch_effect ) do
		effect:release();
	end

	self.batch_effect = {};

	-- 删除节点
	if self.root_node then
		local parent = self.root_node:getParent();
		if parent then
			parent:removeChild( self.root_node );
		end
	end

end

--------------------------------------
-- 特效管理器

local modelparticles_config_cache = {}

local create_modelparticles_config_by_properties = function(prop_filename)
	if modelparticles_config_cache[prop_filename] then
		return modelparticles_config_cache[prop_filename]
	end
	
	local effect_loader = ResourceManager:LoadPropertiesFile(prop_filename)
	
	if not effect_loader then
		return
	end
	
	local batch_effect = effect_loader:getNamespace("ModelParticleConfig", true, false)
	
	if not batch_effect then
		return
	end
	
	batch_effect:rewind()
	
	local effects_config = {}
	
	local cur_lua_config = nil
	local cur_prop_config = batch_effect:getNextNamespace()
	
	while cur_prop_config do
		cur_lua_config = {}
		
		cur_lua_config.name = cur_prop_config:getId()
		cur_lua_config.filename = cur_prop_config:getPath("file")
		
		cur_lua_config.position = Vector3.new(0, 0, 0)
		cur_lua_config.rotation = Vector4.new(0, 0, 0, 0)
		cur_lua_config.scale = Vector3.new(0, 0, 0)
		
		cur_prop_config:getVector3("position", cur_lua_config.position)
		cur_prop_config:getVector4("rotation", cur_lua_config.rotation)
		cur_prop_config:getVector3("scale", cur_lua_config.scale)
		
		if cur_lua_config.scale:isZero() then
			cur_lua_config.scale = nil
		end
		
		table.insert(effects_config, cur_lua_config)
		
		cur_prop_config = batch_effect:getNextNamespace()
	end
	
	modelparticles_config_cache[prop_filename] = effects_config
	
	return effects_config
end

local ClsEffectControl = class( "ClsEffectControl" )

function ClsEffectControl:ctor(target)
	self.batch_effects = {} 			-- 对象身上的所有特效
	self.target = target 				-- 特效所属对象

	self.batch_trigger = {} 			-- 特效触发器
end

function ClsEffectControl:foreachEffect(func)
	for _, effect_info in pairs(self.batch_effects) do
		func(effect_info)
	end
end

function ClsEffectControl:preload(filename)
	if filename == nil or filename == "" then
		return false
	end
	
	local effects_config = create_modelparticles_config_by_properties(filename)
	
	if not effects_config then
		return false
	end
	
	for _, sub_config in ipairs(effects_config) do
		local histroy = self:getEffect(sub_config.name)
		
		if not histroy then
			histroy = {
				name = sub_config.name,		-- 名称 
				batch = {},					-- 批量效果组合 ( 存储 subject )
				notify = nil,				-- 回调
				active = false,				-- 是否活跃
			}
			
			self:setEffect(histroy.name, histroy)
		end

		table.insert(histroy.batch, {
			filename = sub_config.filename,	-- 文件名
			position = sub_config.position,	-- 偏移
			rotation = sub_config.rotation,	-- 旋转
			scale = sub_config.scale,		-- 缩放
			effect = nil,					-- 特效对象
		})
	end
end

-- 生成特效数据
function ClsEffectControl:generate( effect_name, filename, position, rotation )
	-- body
	if effect_name == nil then return false end
	if effect_name == "" then return false end
	if filename == nil then return false end
	if filename == "" then return false end
	if position == nil then return false end
	if rotation == nil then return false end

	local object = nil
	
	-- 单个效果定义
	local subject = { 
		filename = nil,								-- 文件名
		position = Vector3.new( 0, 0, 0 ), 			-- 偏移
		rotation = Vector4.new( 0, 0, 0, 0 ), 		-- 旋转
		effect = nil,								-- 特效对象
	}

	local log = { 
		name = nil,									-- 名称 
		batch = {},									-- 批量效果组合 ( 存储 subject )
		notify = nil,								-- 回调
		active = false,								-- 是否活跃
	};

	log.name = effect_name
	subject.filename = filename
	subject.position = position
	subject.rotation = rotation


	local histroy = self:getEffect(log.name)
	
	if histroy == nil then
		-- 创建一个新的集合
		table.insert(log.batch, subject)
		self:setEffect(log.name, log)
	else
		table.insert(histroy.batch, subject)
	end

end

-- 创建特效
function ClsEffectControl:show(target, effect_name, batch_exclude, duration, position, speed, callback)
	if effect_name == nil or effect_name == "" then return false end

	local log = self:getEffect(effect_name)

	if not log then return false end
	
	target = target or self.target

	if target == nil then return false end

	batch_exclude = batch_exclude or {}

	-- 更新特效状态
	local function updateEffectState(log, subject, effect, root_node, duration, position, speed, callback)
		if not position then
			root_node:setTranslation(subject.position)
		else
			root_node:setTranslation(position)
		end

		if duration then
			effect:perform("setDuration", duration)
		end

		if speed then
			effect:perform("setSpeed", speed)
		end

		-- 设置回调
		if not callback then
			log.notify = nil
		else
			log.notify = callback
		end
	end

	-- 如果对象非活跃，则创建
	if log.active == false then
		for _, subject in ipairs(log.batch) do
			-- 创建特效对象
			local effect = ClsCompriseEffect.new()
			if not effect then return nil end
			if effect:create(target, subject.filename, batch_exclude) == false then return false end

			local root_node = effect:getNode()
			root_node:setTag("_name", log.name)
			target:addChild(root_node)

			if subject.scale then root_node:scale(subject.scale) end

			--root_node:setRotation( subject.rotation:x(), subject.rotation:y(), subject.rotation:z(), subject.rotation:w() );

			updateEffectState(log, subject, effect, root_node, duration, position, speed, callback)

			effect:display(true)

			-- 处理特效间的关系
			-- case 1：并存
			-- case 2：置后
			-- case 3：替换

			-- 目前仅实现并存，其它关系的逻辑可以后直接扩展
			subject.effect = effect
		end
		-- 设置为活跃
		log.active = true
	else
		for _, subject in ipairs(log.batch) do
			if subject.effect ~= nil then
				local root_node = subject.effect:getNode()
				updateEffectState(log, subject, subject.effect, root_node, duration, position, speed, callback)

				subject.effect:display(true)
			end
		end

		return false
	end

	return true
end

-- 将指定编号的特效删除
function ClsEffectControl:hide(effect_name)

	-- 遍历特效表，将指定编号的特效删除
	if not effect_name then
		-- 终止所有特效
		self:foreachEffect(function(log)
			if log.active then
				self:_intterrupt(log, ENUM_EFFECT_INTERRUOT.HIDE)
			end
		end)
	else
		-- 终止指定的特效
		local histroy = self:getEffect(effect_name)
		
		if histroy and histroy.active then
			self:_intterrupt(histroy, ENUM_EFFECT_INTERRUOT.HIDE)
		end
	end
	
	return true
end

-- 设置特效触发
-- @effect_name: 需要定期触发的特效名
-- @callback: 定期回调
-- @heartbeat: 心跳间期
-- @at_once: 是否立即执行一次
-- @exclude_same: 排除同类，即如果心跳卡了多次，仅执行一次
function ClsEffectControl:trigger( effect_name, callback, heartbeat, at_once, exclude_same )
	-- body
	local effect = self.batch_trigger[ effect_name ];
	if effect == nil then
		self.batch_trigger[ effect_name ] = { name = effect_name, trigger = callback, period = 0, interval = heartbeat, except_same = exclude_same };

		-- 是否马上执行一次
		if at_once then
			if callback ~= nil then
				callback( effect_name );
			end
		end
	else
		debug.report( false, "clash: is exist!!!!" );
	end
end

-- 取消特效触发
function ClsEffectControl:untrigger( effect_name )
	-- body
	self.batch_trigger[ effect_name ] = nil;
end

-- 检查所有的特效
function ClsEffectControl:update( second )
	-- body

	-- 更新所有起效的特效
	self:foreachEffect(function(log)
		-- 检查子对象
		if log.active == true then

			local active = false			-- 检查是否存有存活的对象

			-- 检查所有活跃的特效对象
			for _, subject in ipairs(log.batch) do
				
				local effect = subject.effect
				-- 更新对象，并检查其生命周期
				if effect:update(second) then
					-- 对象已经到期，可以删除
					effect:release()
					subject.effect = nil
				else
					active = true
				end
			end

			if active == false then

				if log.notify ~= nil then
					log.notify(ENUM_EFFECT_INTERRUOT.END)
				end
				log.notify = nil
				log.active = active				-- 更新活跃状态

			end
		end

	end)

	-- 检查所有设置的触发器
	for _, trigger in ipairs(self.batch_trigger) do
		
		trigger.period = trigger.period + second
		local count = math.floor(trigger.period / trigger.interval)
		if count > 0 then

			-- 设置了排同
			if trigger.except_same == true then
				count = 1
			end
			
			for t = 1, count do
				if trigger.trigger ~= nil then
					trigger.trigger(trigger.name)
				end
			end
			trigger.period = trigger.period - (count * trigger.interval)
		end
	end

end

-- 设置特定参数
function ClsEffectControl:setParameters( effect_sort, param_type, param_value )

	self:foreachEffect(function(log)
		if log then
			-- FIX:目前只设置活跃的
			if log.active then

				for _, subject in ipairs(log.batch) do
					subject.effect:setParameters(effect_sort, param_type, param_value)
				end
			end
		end
	end)
end

-- 刷新对象
-- @effect_name：特效名
-- @unity_title：特效内单个对象的索引
function ClsEffectControl:refresh( effect_name, unity_title, function_name, ... )
	local histroy = self:getEffect(effect_name)

	if not histroy then return end
	
	if histroy.active == false then return end

	-- 只更新活跃的
	for _, subject in ipairs(histroy.batch) do
		subject.effect:refresh(unity_title, function_name, ...)
	end

end

-- 终止特效( 私有 )
function ClsEffectControl:_intterrupt( histroy, reason )
	-- body
	if not histroy then return false; end

	for _, subject in ipairs( histroy.batch ) do
		-- 遍历所有特效
		if subject.effect ~= nil then
			-- 清除特效对象
			subject.effect:release();
			subject.effect = nil;
		end
	end

	if histroy.notify ~= nil then
		histroy.notify( reason );
	end
	histroy.notify = nil;
	histroy.active = false;				-- 更新活跃状态	

	return true;
end

-- 枚举指定特效的对象
function ClsEffectControl:enumObject( effect_name, batch_object )
	local histroy = self:getEffect( effect_name )
	if not histroy then
		histroy:perform("enumObject", batch_object)
	end
end

-- 清理所有特效
function ClsEffectControl:release( ... )

	self:foreachEffect(function(log)
		-- 检查子对象
		self:_intterrupt(log, ENUM_EFFECT_INTERRUOT.RELEASE)
	end)

	-- 清除所有的特效
	self.batch_effects = nil
	self.batch_trigger = nil
	self.target = nil 
	
	return true
end

-- 获取特效
function ClsEffectControl:getEffect(effect_name)
	return self.batch_effects[effect_name]
end

-- 缓存特效
function ClsEffectControl:setEffect(effect_name, effect_info)
	self.batch_effects = self.batch_effects or {}

	self.batch_effects[effect_name] = effect_info
end

-- 检查指定特效是否运行中
function ClsEffectControl:isPlaying(effect_name)
	
	local effect_info = self:getEffect(effect_name)
	
	return effect_info and effect_info.active
end

function ClsEffectControl:showAll(target, duration, position, speed, callback)
	self:foreachEffect(function(log)
		self:show(target, log.name, batch_exclude, duration, position, speed, callback)
	end)
end

function ClsEffectControl:hideAll( )
	self:foreachEffect(function(log)
		self:hide(log.name)
	end)
end

function ClsEffectControl:fadeOut(duration, alpha)
	self:foreachEffect(function(log)
		if log.active then 
			for _, subject in pairs(log.batch) do
				for _, effect in pairs(subject.effect.batch_effect) do
					if effect:getType() == "model" then
						Model3DFadeOut(effect.model, duration, alpha)
					end
				end 
			end
		end 
	end)
end 

return ClsEffectControl



