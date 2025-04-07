pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
entity = setmetatable(
    {
        posX = 0,
        posY = 0,
        dirX = 0,
        dirY = 0,
        planeX = 0,
        planeY = 0.5,
        moveSpeed = 3.0,
        rotationSpeed = 0.25,
        new = function(self, table)
            table = table or {}
            setmetatable(table, { __index = self })
            self.mapX = flr(table.posX)
            self.mapY = flr(table.posY)
            return table
        end,
        draw2d = function(_ENV)
            -- Circle, representing the entity position
            circ(posX * 8, posY * 8, 2, 12)
            -- Line, representing the entity facing direction
            line(posX * 8, posY * 8, posX * 8 + dirX * 4, posY * 8 + dirY * 4, 12)
        end,
        move = function(_ENV, dt)
            -- Rotate right
            if btn(0) then
                local oldDirX = dirX
                dirX = dirX * cos(rotationSpeed * dt) - dirY * sin(rotationSpeed * dt)
                dirY = oldDirX * sin(rotationSpeed * dt) + dirY * cos(rotationSpeed * dt)

                local oldPlaneX = planeX
                planeX = planeX * cos(rotationSpeed * dt) - planeY * sin(rotationSpeed * dt)
                planeY = oldPlaneX * sin(rotationSpeed * dt) + planeY * cos(rotationSpeed * dt)
            end

            -- Rotate left
            if btn(1) then
                local oldDirX = dirX
                dirX = dirX * cos(-rotationSpeed * dt) - dirY * sin(-rotationSpeed * dt)
                dirY = oldDirX * sin(-rotationSpeed * dt) + dirY * cos(-rotationSpeed * dt)

                local oldPlaneX = planeX
                planeX = planeX * cos(-rotationSpeed * dt) - planeY * sin(-rotationSpeed * dt)
                planeY = oldPlaneX * sin(-rotationSpeed * dt) + planeY * cos(-rotationSpeed * dt)
            end

            -- Move forward
            if btn(2) then
                local nextMapX = flr((posX + dirX * moveSpeed * dt))
                if mget(nextMapX, mapY) == 0 then
                    posX += dirX * moveSpeed * dt
                    mapX = nextMapX
                end

                local nextMapY = flr((posY + dirY * moveSpeed * dt))
                if mget(mapX, nextMapY) == 0 then
                    posY += dirY * moveSpeed * dt
                    mapY = nextMapY
                end
            end

            -- Move backward
            if btn(3) then
                local nextMapX = flr((posX - dirX * moveSpeed * dt))
                if mget(nextMapX, mapY) == 0 then
                    posX -= dirX * moveSpeed * dt
                    mapX = nextMapX
                end

                local nextMapY = flr((posY - dirY * moveSpeed * dt))
                if mget(mapX, nextMapY) == 0 then
                    posY -= dirY * moveSpeed * dt
                    mapY = nextMapY
                end
            end
        end
    }, { __index = _ENV }
)



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
    player:move(dt)

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

function _raycast(x)
    ray:doRaycast()
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
ray = setmetatable(
    {
        x = 0,
        owningEntity = nil,
        cameraX = 0,
        sideDistX = 0,
        sideDistY = 0,
        perpWallDist = 0,
        stepDistX = 0,
        stepDistY = 0,
        hit = 0,
        side = 0,
        deltaDistX = 0,
        deltaDistY = 0,
        dirX = 0,
        dirY = 0,
        mapX = 0,
        mapY = 0,
        new = function(self, table)
            table = table or {}
            setmetatable(table, { __index = self })
            table.cameraX = 2 * table.x / 128 - 1
            return table
        end,
        draw2d = function(_ENV)
            line(owningEntity.posX * 8, owningEntity.posY * 8, owningEntity.posX * 8 + dirX * perpWallDist * 8, owningEntity.posY * 8 + dirY * perpWallDist * 8, 10)
        end,
        draw3d = function(_ENV)
            linHeight = 127 / perpWallDist
            drawStart = -linHeight / 2 + 64
            if drawStart < 0 then drawStart = 0 end
            drawEnd = linHeight / 2 + 64
            if drawEnd >= 127 then drawEnd = 127 end
            if side == 0 then
                color = 8
            else
                color = 12
            end
            line(x, drawStart, x, drawEnd, color)
        end,
        doRaycast = function(_ENV)
            dirX = owningEntity.dirX + owningEntity.planeX * cameraX
            dirY = owningEntity.dirY + owningEntity.planeY * cameraX

            deltaDistX = abs(1 / dirX)
            deltaDistY = abs(1 / dirY)

            mapX = owningEntity.mapX
            mapY = owningEntity.mapY

            if dirX < 0 then
                stepX = -1
                sideDistX = (owningEntity.posX - mapX) * deltaDistX
            else
                stepX = 1
                sideDistX = (mapX + 1.0 - owningEntity.posX) * deltaDistX
            end

            if dirY < 0 then
                stepY = -1
                sideDistY = (owningEntity.posY - mapY) * deltaDistY
            else
                stepY = 1
                sideDistY = (mapY + 1.0 - owningEntity.posY) * deltaDistY
            end

            hit = 0
            while hit == 0 do
                if sideDistX < sideDistY then
                    sideDistX += deltaDistX
                    mapX += stepX
                    side = 0
                else
                    sideDistY += deltaDistY
                    mapY += stepY
                    side = 1
                end

                if mget(mapX, mapY) > 0 then
                    hit = 1
                    if (side == 0) then
                        perpWallDist = (sideDistX - deltaDistX)
                    else
                        perpWallDist = (sideDistY - deltaDistY)
                    end
                end
            end
        end
    }, { __index = _ENV }
)

__gfx__
00000000555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000100000100000100000100000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000100000100000100000100000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000


































































