local control_sprite = {}

control_sprite.create = function(args, parent)
	args = args or {}

	local sprite = display.newSprite( args.path )
	sprite:setCascadeOpacityEnabled( true )

	if args.x and args.y then
		sprite:setPosition( args.x, args.y )
	end

	if args.anchor_x and args.anchor_y then
		sprite:ignoreAnchorPointForPosition(false)
		sprite:setAnchorPoint(ccp(args.anchor_x, args.anchor_y))
	else
		--sprite:setAnchorPoint(ccp(0, 0))
		sprite:ignoreAnchorPointForPosition(true)
	end

    if args.scale then
        sprite:setScale(args.scale)
    end
    if args.scale_y then
        sprite:setScaleY(args.scale_y)
    end
    if args.scale_x then
        sprite:setScaleX(args.scale_x)
    end
        
	if parent then 
		parent:addChild( sprite ) 
	end
	

	return sprite
end

control_sprite.updateSprite = function(sprite, spriteName)
	local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(spriteName)
	if frame then
		sprite:setDisplayFrame(frame)
	else
		local tex = CCTextureCache:sharedTextureCache():addImage(spriteName)
		sprite:setTexture(tex)
	end
end

return control_sprite