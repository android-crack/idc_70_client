---- 3D模型测试

local Sprite3d = require("gameobj/sprite3d")
local model_info = require("game_config/model_info")
local Main3d = require("gameobj/mainInit3d")
local Game3d = require("game3d")
local particle = require("particle_system")

local ClsModelTest = class("ClsModelTest", function() return CCLayerColor:create(ccc4(100,100,100,255)) end )


function ClsModelTest:ctor()
	self.node_name = "boat01"
	self.level = 0
	self.path = SHIP_3D_PATH
	self.id = 1
	self.is_ship = true

	self:init3D()
	self:initUI()
	self:rotation3D()
	self:showModel()
end 

function ClsModelTest:init3D()
	local scene_id = SCENE_ID.TEST
    local layer_sea_id = 0
	
	-- scene
	Main3d:createScene(scene_id)
	-- layerSea
	Game3d:createLayer(scene_id, layer_sea_id, self)
	
	self.layer_sea = Game3d:getLayer3d(scene_id, layer_sea_id)
end 


function ClsModelTest:initUI()
	
	--editbox
	local node_label = createBMFont({text = "模型名字", size = 20, x = 50, y = 500 })
	self:addChild(node_label)
    local editbox_size = CCSize(200,40)
    local frame1 = display.newScale9Sprite("ui/login/login_input.png")
    self.editBox1 = CCEditBox:create(editbox_size, frame1)   
    self.editBox1:setPosition(200,500)
    --self.editBox1:setPlaceholderFont("ui/font/microhei_bold.fnt", 20)
    --self.editBox1:setFont("ui/font/microhei_bold.fnt", 18)

    self.editBox1:setPlaceHolder("boat01")
    self.editBox1:setPlaceholderFontColor(ccc3(dexToColor3B(COLOR_CREAM_STROKE)))
    self.editBox1:setFontColor(ccc3(dexToColor3B(COLOR_CREAM_STROKE)))
    self.editBox1:setInputFlag(kEditBoxInputFlagSensitive)

    self.editBox1:registerScriptEditBoxHandler(function(eventType)
		if eventType == "return" then 
			self:changeNode(self.editBox1:getText())
		end
    end)
    self:addChild(self.editBox1)
	
	-- level
	local level_label = createBMFont({text = "模型等级", size = 20, x = 50, y = 400 })
	self:addChild(level_label)
    local editbox_size = CCSize(200,40)
    local frame1 = display.newScale9Sprite("ui/login/login_input.png")
    self.editBox2 = CCEditBox:create(editbox_size, frame1) 
    
    self.editBox2:setPosition(200,400)
    --self.editBox2:setPlaceholderFont("ui/font/microhei_bold.fnt", 20)
    --self.editBox2:setFont("ui/font/microhei_bold.fnt", 18)

    self.editBox2:setPlaceHolder("0")
    self.editBox2:setPlaceholderFontColor(ccc3(dexToColor3B(COLOR_CREAM_STROKE)))
    self.editBox2:setFontColor(ccc3(dexToColor3B(COLOR_CREAM_STROKE)))
    self.editBox2:setInputFlag(kEditBoxInputFlagSensitive)

    self.editBox2:registerScriptEditBoxHandler(function(eventType)
		if eventType == "return" then 
			self:changeLevel(self.editBox2:getText())
		end 
    end)
    self:addChild(self.editBox2)
	
	-- animation
	local animation_label = createBMFont({text = "动作名字", size = 20, x = 50, y = 300 })
	self:addChild(animation_label)
    local editbox_size = CCSize(200,40)
	local frame1 = display.newScale9Sprite("ui/login/login_input.png")
    self.editBox3 = CCEditBox:create(editbox_size, frame1) 
    
    self.editBox3:setPosition(200,300)
    --self.editBox3:setPlaceholderFont("ui/font/microhei_bold.fnt", 20)
    --self.editBox3:setFont("ui/font/microhei_bold.fnt", 18)

    self.editBox3:setPlaceHolder("move")
    self.editBox3:setPlaceholderFontColor(ccc3(dexToColor3B(COLOR_CREAM_STROKE)))
    self.editBox3:setFontColor(ccc3(dexToColor3B(COLOR_CREAM_STROKE)))
    self.editBox3:setInputFlag(kEditBoxInputFlagSensitive)

    self.editBox3:registerScriptEditBoxHandler(function(eventType)
		if eventType == "return" then 
			self:changeAnimation(self.editBox3:getText())
		end 
    end)
    self:addChild(self.editBox3)
	
	--editbox
	local label = createBMFont({text = "特效名字", size = 20, x = 550, y = 500 })
	self:addChild(label)
    local editbox_size = CCSize(200,40)
    local frame1 = display.newScale9Sprite("ui/login/login_input.png")
    self.editBox4 = CCEditBox:create(editbox_size, frame1)   
    self.editBox4:setPosition(700,500)
    --self.editBox1:setPlaceholderFont("ui/font/microhei_bold.fnt", 20)
    --self.editBox1:setFont("ui/font/microhei_bold.fnt", 18)

    self.editBox4:setPlaceholderFontColor(ccc3(dexToColor3B(COLOR_CREAM_STROKE)))
    self.editBox4:setFontColor(ccc3(dexToColor3B(COLOR_CREAM_STROKE)))
    self.editBox4:setInputFlag(kEditBoxInputFlagSensitive)

    self.editBox4:registerScriptEditBoxHandler(function(eventType)
		if eventType == "return" then 
			self:changeParticle(self.editBox4:getText())
		end
    end)
    self:addChild(self.editBox4)
	
	local btn = MyMenuItem.new({image = "#common_btn_blue1.png", imageSelected = "#common_btn_blue2.png",x = 200, y = 200,
        text = "检查所有模型", fsize = 25})
	local menu = MyMenu.new({btn})
    self:addChild(menu)
	btn:regCallBack(function()
		self:showAllModel()
	end)
	
	local btn = MyMenuItem.new({image = "#common_btn_blue1.png", imageSelected = "#common_btn_blue2.png",x = 200, y = 100,
        text = "检查所有模型动作", fsize = 25})
	local menu = MyMenu.new({btn})
    self:addChild(menu)
	btn:regCallBack(function()
		self:showAllModelAnimation()
	end)
	
	local btn = MyMenuItem.new({image = "#common_btn_blue1.png", imageSelected = "#common_btn_blue2.png",x = 500, y = 100,
        text = "检查所有特效", fsize = 25})
	local menu = MyMenu.new({btn})
    self:addChild(menu)
	btn:regCallBack(function()
		self:showAllParticle()
	end)
	
end 

function ClsModelTest:showAllModel()
	for k ,v in pairs(model_info) do 
		local node_name = k
		self:changeNode(node_name)
		print("检查", node_name)
		for level = 1, 6 do 
			print("等级", level)
			self:changeLevel(level)
			
			if self.select_node.broken_tex_res == nil then 
				break
			end 
			if self.is_ship then 
				self.select_node:changeTexture(self.select_node.broken_tex_res)
			end 
		end 
	end 
	
	print("检查完毕")
end 

function ClsModelTest:showAllModelAnimation()
	self.model_tab = {}
	
	for k ,v in pairs(model_info) do 
		table.insert(self.model_tab, {name = k, v = v})
	end 
	
	local function step()
		local model = table.remove(self.model_tab)
		if model == nil then 
			print("检查完毕")
			return 
		end 
		
		local node_name = model.name
		self:changeNode(node_name)
		print("检查动作", node_name)
		local animation =  self.select_node.animation
		local dt = 0
		if animation then 
			local count = animation:getClipCount()
			local i = 0
			local play = nil
			play = function()
				local clip = animation:getClip(i)
				print("动作名：", clip:getId(), i, count)
				local duration = clip:getDuration()/ 1000
				
				dt = dt + duration
				clip:play()
				i = i + 1
				
				if i >= count then 
					return step()
				end 
				
				require("framework.scheduler").performWithDelayGlobal(play, duration)
			end 
			return play()
		else 
			
			return step()
		end 
	end 
	
	step()
end 

function ClsModelTest:showAllParticle()
	local lfs = require"lfs"
	local str = ".particlesystem"
	
	local function showDir(dir)
		for file in lfs.dir(dir) do
		if string.find(file, str) then
			local file_name = string.gsub(file, str, "")
			print(file_name)
			self:changeParticle(file_name)
		end 
	end 
	end 
	
	-- 登录 
	local dir = EFFECT_PATH
	showDir(dir)
	
	dir = EFFECT_3D_PATH
	showDir(dir)
end 

function ClsModelTest:changeAnimation(name)
	if name == "" then return end 
	self.select_node:playAnimation(name, true)
end 

function ClsModelTest:changeLevel(level)
	if level == "" then return end 
	self.level = tonumber(level)
	self:showModel()
end 

function ClsModelTest:changeNode(node_name)
	if node_name == "" then return end 
	if not model_info[node_name] then 
		local msg =  "配置表中没有这个模型" .. node_name
		require("ui/tools/alert"):warning({msg = msg})
		print(msg)
		return 
	end 
	
	local sub = string.sub(node_name, 1,4)
	
	if sub == "boat" then 
		self.is_ship = true 
		local id = tonumber(string.sub(node_name, 5,-1))
		self.id = id
		self.path = SHIP_3D_PATH
	else 
		self.path = MODEL_3D_PATH
		self.is_ship = false
	end 
	
	self.node_name = node_name
	self:showModel()
end 

function ClsModelTest:showModel()
	if self.select_node then 
		self.select_node:release()
		self.select_node = nil
	end 
	
	local item = {
		parent = self.layer_sea,
		is_ship = self.is_ship,
		id = self.id,
		path = self.path,
		node_name = self.node_name,
		ani_name = self.node_name,
		star_level = self.level,
		pos = {x = 0, y = 0, angle = 0}
	} 
	self.select_node = Sprite3d.new(item)
	
end 

function ClsModelTest:changeParticle(path)
	if self.particle then 
		self.particle:Release()
		self.particle = nil
	end 
	local res = EFFECT_3D_PATH .. path .. ".particlesystem"
	if not fileExist(res) then 
		res = EFFECT_PATH .. path .. ".particlesystem"
		if not fileExist(res) then 
			local msg =  "没有这个特效" .. path
			require("ui/tools/alert"):warning({msg = msg})
			return
		end 
	end 
	print(res)
	self.particle = particle.new(res)
	self.particle:Show()
	self.layer_sea:addChild( self.particle.root_node)
end 

function ClsModelTest:rotation3D()
	if self.hander_time then return end 
	
	local rootNode = self.layer_sea
	local angle_speed = 25
	local function step(dt)
		rootNode:rotateY(math.rad(angle_speed*dt))
	end 
end 


function startTestScene()
	local function scene() 
		local runScene = GameUtil.getRunningScene()
		local layer = ClsModelTest.new()
		runScene:addChild(layer)
	end 
	GameUtil.runScene(scene, SCENE_TYPE_PORT)
end   