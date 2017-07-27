local funs={}

function funs:getSprite(res,x,y,opacity,scale)
    local sprite=display.newSprite(res,x,y)
    if opacity then sprite:setOpacity(opacity) end
    if scale then sprite:setScale(scale) end
    return sprite
end

return funs