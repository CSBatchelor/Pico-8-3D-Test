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