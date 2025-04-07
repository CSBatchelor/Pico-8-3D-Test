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