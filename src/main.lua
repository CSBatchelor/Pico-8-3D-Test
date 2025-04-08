#include entity.lua
#include ray.lua

function _init()
    is2d = false
    isDebug = false

    player = entity:new({
        posX = 2.0,
        posY = 4.0,
        dirX = 1
    })

    rays = {}
    for x = 0, 127 do
        add(
            rays, ray:new({
                x = x,
                owningEntity = player
            })
        )
    end
end

function _update60()
    dt = _getDeltaTime()
    doPlayerMove(dt)

    for ray in all(rays) do
        ray:doRaycast()
    end
end

function _draw()
    if is2d then _draw2d() else _draw3d() end
end

function _getDeltaTime()
    local target_fps = stat(8)
    return 1 / target_fps
end

function _draw2d()
    cls()
    map(0, 0, 0, 0, 16, 16)
    player:draw2d()

    for ray in all(rays) do
        ray:draw2d()
    end
end

function _draw3d()
    drawHorizon()

    for ray in all(rays) do
        ray:draw3d()
    end
end

function drawHorizon()
    rectfill(0, 0, 127, 64, 1)
    rectfill(0, 64, 127, 127, 5)
end

function doPlayerMove(dt)
    if not btn(5) then
        if btn(0) then player:move(player.enMoveType.rotateLeft, dt) end
        if btn(1) then player:move(player.enMoveType.rotateRight, dt) end
    else
        if btn(0) then player:move(player.enMoveType.moveLeft, dt) end
        if btn(1) then player:move(player.enMoveType.moveRight, dt) end
    end
    if btn(2) then player:move(player.enMoveType.moveForward, dt) end
    if btn(3) then player:move(player.enMoveType.moveBackward, dt) end
end