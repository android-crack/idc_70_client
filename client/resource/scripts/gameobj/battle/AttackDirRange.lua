local AttackDirRange = {}

require("resource_manager")

local function GetSpriteModel (path, w, h, color, alpha)
    color = color or Vector4.one()
    alpha = alpha or 0
    local billboard_width = w
	local billboard_height = h or w
	local mesh = Mesh.createQuad(-(billboard_width / 2.0), -(billboard_height / 2.0), billboard_width, billboard_height)
	
    mesh:setBoundingBox(BoundingBox.new(-billboard_width / 2, -billboard_height / 2, 1, billboard_width / 2, billboard_height / 2 , 1))
    mesh:setBoundingSphere(BoundingSphere.new(Vector3.zero(), billboard_width));
	local model = Model.create(mesh)

    local material = Material.create(MODEL_3D_PATH.."spriteModel.material")
    if not material then return model end

    if alpha < 1 then 
		material:getStateBlock():setDepthWrite(false)
	end
    material:getParameter("u_color"):setValue(color)
    material:getParameter("minAlpha"):setValue(alpha)
	local sampler = material:getParameter("u_texture"):setValue(path, false)
	sampler:setWrapMode("CLAMP", "CLAMP")
    sampler:setFilterMode("LINEAR", "LINEAR")
	model:setMaterial(material)

	return model
end

local function GetSpriteNode(path, w, h, color, alpha)
	local node = Node.create()
	node:setId(path)
	local model = GetSpriteModel(path, w, h, color, alpha)
	node:setModel(model)
	return node
end

function SetSpriteModelAlpha(node, color)
	local model = node:getModel()
	local material = model:getMaterial()
	color = color or Vector4.one()
	local color = material:getParameter("u_color"):setValue(color)
end

function AttackDirRange.showAttackDirection(parent,length, depth, color, alpha)
	local path = "res/battle_3d/range_1.png"
    depth = depth or 0
	picWidth = 216
	picHeight = 550 
	width = length * picWidth/picHeight
    local AttackDirNode = GetSpriteNode(path, width, length, color, alpha)
    parent:addChild(AttackDirNode)
    AttackDirNode:rotateX(-90 * 0.0174532925)
      
    local dir = AttackDirNode:getForwardVectorWorld():normalize()
    dir:scale(length / 2 )
    local attackPos = AttackDirNode:getTranslation()
    attackPos:add(dir)
    AttackDirNode:setTranslation(attackPos:x(), depth, attackPos:z())

	return AttackDirNode
end

function AttackDirRange.setAttackDirectionTarget(attackNode, target)
	if attackNode:isActive() then 
		local targetNode = target and target.node
		
		local min = attackNode:getModel():getMesh():getBoundingBox():min()
		local max = attackNode:getModel():getMesh():getBoundingBox():max()
		local length = max:y() - min:y()
		local attackPos = attackNode:getTranslation()
		local depth = attackPos:y()

		attackNode:rotateX(math.rad(90))    
		attackNode:setTranslation(0, 0, 0)
		if targetNode ~= nil then 
			LookAtPoint(attackNode, targetNode:getTranslation())
		end 
		local dir = attackNode:getForwardVectorWorld():normalize()
		attackNode:rotateX(-math.rad(90))
		dir:scale(length / 2 )
		attackPos = attackNode:getTranslation()
		attackPos:add(dir)
		attackNode:setTranslation(attackPos:x(), depth, attackPos:z()) 
	end 
end
 

function AttackDirRange.showGuanQuanPic(mountNode)
	local path = "res/battle_3d/wofang.png"

	local length = 150
    local sphereNode = GetSpriteNode(path, length)
    sphereNode:rotateX(-90 * 0.0174532925)
    mountNode:addChild(sphereNode)
	
    sphereNode:setTranslation(0, 3,0)
	return sphereNode
end 
		

function AttackDirRange.showAttackRange(parent, length, depth, color, alpha, skill_type)
    depth = depth or 0
    local res_path = "res/battle_3d/range_circle.png"
    local sphereNode = GetSpriteNode(res_path, length*2, length*2, color, alpha)
    sphereNode:rotateX(-90 * 0.0174532925)
    parent:addChild(sphereNode)
    sphereNode:setTranslation(0, depth,0)
	return sphereNode
end 

local function GetSkillRankModel(path, w, h, color, alpha)
    color = color or Vector4.one()
    alpha = alpha or 0
    local billboard_width = w
	local billboard_height = h or w
	local mesh = Mesh.createQuad(-(billboard_width / 2.0), 0, billboard_width, billboard_height)
	
    mesh:setBoundingBox(BoundingBox.new(-billboard_width / 2, -billboard_height / 2, 1, billboard_width, billboard_height , 1))
    mesh:setBoundingSphere(BoundingSphere.new(Vector3.zero(), billboard_width));
	local model = Model.create(mesh)

    local material = Material.create(MODEL_3D_PATH.."spriteModel.material")
    if alpha < 1 then 
		material:getStateBlock():setDepthWrite(false)
	end
    material:getParameter("u_color"):setValue(color)
    material:getParameter("minAlpha"):setValue(alpha)
	local sampler = material:getParameter("u_texture"):setValue(path, false)
	sampler:setWrapMode("CLAMP", "CLAMP")
    sampler:setFilterMode("LINEAR", "LINEAR")
	model:setMaterial(material)

	return model
end

local function GetSkillNode(path, w, h, color, alpha)
	local node = Node.create()
	node:setId(path)
	local model = GetSkillRankModel(path, w, h, color, alpha)
	node:setModel(model)
	return node
end

function AttackDirRange.showUnSelectSkillRank(parent, length, depth, skill_type)
	local path = "res/battle_3d/battle_range_bar_1.png"
	local picWidth = 300
	local picHeight = 550 
	depth = depth or 0
	local color = nil
    if tonumber(skill_type) > 100 then
    	path = "res/battle_3d/range_1.png"
    	color =  Vector4.new(1, 0, 0, 0.7)
    	picWidth = 200
    end

	
	local width = length * picWidth/picHeight
    local AttackDirNode = GetSkillNode(path, width, length, color)
    AttackDirNode:setInheritedScale(false)
    parent:addChild(AttackDirNode)
    AttackDirNode:rotateX(-90 * 0.0174532925)
    local point = parent:getTranslation()
  	local dir = parent:getForwardVectorWorld():normalize()
  	--LookAtPoint(AttackDirNode, parent:getTranslation())
   	local attackPos = AttackDirNode:getTranslation()
    attackPos:add(dir)
 --    AttackDirNode:setTranslation(attackPos:x(), depth, attackPos:z())
 --    AttackDirNode:setInheritedRotation(false)
 --    AttackDirNode:rotateX(math.rad(90))    
	-- AttackDirNode:setTranslation(0, 0, 0)
	-- --AttackDirNode:rotateY(10 * 0.0174532925)
	-- AttackDirNode:rotateX(-math.rad(90))
    AttackDirNode:setTranslation(attackPos:x(), depth, attackPos:z()) 
	return AttackDirNode
end


return AttackDirRange
