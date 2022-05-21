local fieldHandler = {}

---------------------------------------------------------
-- Handles all private field vars and manages interaction
---------------------------------------------------------
local field,fieldSize,flags,fieldX,fieldY,mines

local AdjacentIndex = {
    { x = -1, y = -1},
    { x =  0, y = -1},
    { x =  1, y = -1},
    { x = -1, y =  0},
    { x =  1, y =  0},
    { x = -1, y =  1},
    { x =  0, y =  1},
    { x =  1, y =  1},
}

-------------------
--private functions
-------------------
local function mineHit() --uncovers all bombs
    print('yeah rip')
    for x = 1,fieldX,1 do
        for y = 1,fieldY,1 do
            if field[x][y].mine then -- finds mines and uncovers them
                field[x][y].covered = false
                print("Boom!")
            else end
        end
    end
end

local function clear(X,Y)-- clears spaces around a "0" space that just got cleared, it calls itself creating a recursive function that i'm quite proud works at all.
    for x = -1,1,1 do                         --begin search at left square
        for y = -1,1,1 do                     --begin search at top,left square
            local space = field[X+x][Y+y]     --define temp variable for quicker table look up
            if not space.flagged then              -- if not flagged
                if space.covered then              -- if it is covered
                    space.covered = false          --uncover
                    fieldSize = fieldSize - 1 --remove fieldSize counter
                    if space.number == 0 then     -- it is text space of 0
                        clear(X+x,Y+y)        --recursion
                    end
                end
            end
        end
    end
end

local function clearNum(X,Y) --clears spaces around a number, and doesn't remove flags
    local flagCount = 0
    for _,loc in pairs(AdjacentIndex) do
        if field[X + loc.x][ Y + loc.y].flagged then
            flagCount = flagCount + 1
        end
    end
    --print("flags:" .. flagCount)
    if flagCount >= field[X][Y].number then
        --printf('flags good')
        for x = -1,1,1 do
            for y = -1,1,1 do
                local space = field[X+x][Y+y] --define temp variable for quicker table look up and reduved stack buildup
                if not space.flagged then
                    if space.covered then
                        space.covered = false
                        fieldSize = fieldSize - 1
                        if space.mine then
                            mineHit()
                            return true --send back mine hit
                        elseif space.number == 0 then
                            clear(X+x,Y+y)
                        end
                    end
                end
            end
        end
    end
    return false --no mine hit
end

local function randomMine(size, mines)
    return love.math.random(1,size+mines) <= mines
end


--------------------
--module I/O methods
--------------------
function fieldHandler.fieldInit(settings)
    fieldSize = settings.fieldX*settings.fieldY
    fieldX = settings.fieldX
    fieldY = settings.fieldY
    mines = settings.Mines
    print("fieldHandler Intialized!")
end

function fieldHandler.getField()
    return field
end

function fieldHandler.getScore()
    return (mines-flags)
end

----------------------------------
-- public methods for field Events
----------------------------------
function fieldHandler.resetField()--generates a field of size X,Y and a border
    field = {}
    flags = 0
    for x = 0,fieldX+1,1 do
        field[x] = {}
        for y = 0,fieldY+1,1 do
            field[x][y]  = {
                mine = false,
                covered = true,
                flagged = false,
                number = 8}
            if (x == 0 or y == 0) or (x > fieldX or y > fieldY) then
                field[x][y].covered = false
            end
        end
    end
    return field
end

function fieldHandler.generate(forceX,forceY)--the actual generator, with options for placing a forced empty square
    repeat
        fieldSize = fieldX*fieldY
        local tempMines = mines --tracker for how many mines haven't been generated
        for x = 1,fieldX,1 do
            for y = 1,fieldY,1 do
                fieldSize = fieldSize - 1
                field[x][y].mine = randomMine(fieldSize, tempMines)
                if field[x][y].mine then
                    tempMines = tempMines - 1
                end
            end
        end
        mines = mines - tempMines

        print("generated map")

        fieldSize = (fieldX*fieldY)-mines
        print("fieldSize:"..fieldSize)
        for x = 1,fieldX,1 do
            for y = 1,fieldY,1 do
                local mineT = 0
                for _,loc in pairs(AdjacentIndex) do
                    if field[x + loc.x][ y + loc.y].mine then mineT = mineT + 1 end
                end
                field[x][y].number = mineT
            end
        end

        print("numbers generated")
        
    until((not (forceX and forceY)) or (field[forceX][forceY].number == 0 and not field[forceX][forceY].mine))
end --fieldHandler.generate()

function fieldHandler.click(clickData, status) --manages clicks on the field and updates itself
    local click = field[clickData.x][clickData.y]
    if clickData.button == 1  and (not status.flagMode or (click.number > 0 and not click.covered)) then -- mine check, if it clicks on an uncovered it just sets the uncovered flag again and nothing changes
        print("left click!")
        if not click.flagged then --if not flagged
            if not click.mine then --if it's not a mine
                if click.covered then -- if it is covered
                    click.covered = false
                    fieldSize = fieldSize - 1
                    if click.number == 0 then --if it's empty and covered run clear()
                        clear(clickData.x,clickData.y)
                    end
                elseif click.number then -- not covered and text > 0
                    status.gameEnded = clearNum(clickData.x,clickData.y)
                end
            else
                mineHit()
                status.gameEnded = true
            end
        end
    elseif clickData.button == 2 or status.flagMode then --simply flips the flag to true
        print("right click!")
        if click.covered then
            click.flagged = not click.flagged
            if click.flagged then
                flags = flags + 1
            else
                flags = flags - 1
            end
        end
    end
    if fieldSize == 0 then 
        status.gameEnded = true
        status.win = true
    end
    return status
end

return fieldHandler