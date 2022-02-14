local fieldHandler = {}

---------------------------------------------------------
-- Handles all private field vars and manages interaction
---------------------------------------------------------
local field,fieldSize,flags,fieldX,fieldY,mines

-------------------
--private functions
-------------------
local function mineHit() --uncovers all bombs
    print('yeah rip')
    for x = 1,fieldX,1 do
        for y = 1,fieldY,1 do
            if field[x][y][1] then -- finds mines and uncovers them
                field[x][y] = {true, false, true, 0}
                print("Boom!")
            else end
        end
    end
end

local function clear(X,Y)-- clears spaces around a "0" space that just got cleared, it calls itself creating a recursive function that i'm quite proud works at all.
    for x = -1,1,1 do                                   --begin search of left square
        for y = -1,1,1 do                               --begin search of top,left square
            if not field[X+x][Y+y][3] then              -- if not flagged
                if field[X+x][Y+y][2] then              -- if it is covered
                    field[X+x][Y+y][2] = false          --uncover
                    fieldSize = fieldSize - 1           --remove fieldSize counter
                    if field[X+x][Y+y][4] == 0 then     -- it is text space of 0
                        clear(X+x,Y+y)                  --recursive function
                    end
                end
            end
        end
    end
end

local function clearNum(X,Y) --clears spaces around a number, and doesn't remove flags
    local flagCount = 0
    for x = -1,1,1 do --counts flags around Number
        for y = -1,1,1 do
            if field[X+x][Y+y][3] then
                flagCount = flagCount + 1
            end
        end
    end
    print("flags:" .. flagCount)
    if flagCount >= field[X][Y][4] then
        --print('flags good')
        for x = -1,1,1 do
            for y = -1,1,1 do
                if not field[X+x][Y+y][3] then
                    if field[X+x][Y+y][2] then
                        field[X+x][Y+y][2] = false
                        fieldSize = fieldSize - 1
                        if field[X+x][Y+y][1] then
                            mineHit()
                            return true --send back mine hit
                        elseif field[X+x][Y+y][4] == 0 then
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

function fieldHandler.getFlags()
    return flags
end

function fieldHandler.getField()
    return field
end

function fieldHandler.getScore()
    return (mines-flags)
end

function fieldHandler.fieldSize()
    return fieldSize
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
            if (x == 0 or y == 0) or (x > fieldX or y > fieldY) then
                field[x][y] = {false, false, false, 8}--{not mine, not covered, flagged, 8}
            else
            field[x][y] = {false, true, false, 8}--{not mine, covered, not flagged, 8}
            end
            --print(field[x][y][1], field[x][y][2], field[x][y][3], field[x][y][4])
        end
    end
    return field
end

function fieldHandler.generate(forceX,forceY)--the actual generator, with options for placing a forced empty square
    love.math.setRandomSeed(love.math.random(0,10000))
    fieldSize = fieldX*fieldY
    local tempMines = mines
    for x = 1,fieldX,1 do
        for y = 1,fieldY,1 do
            print( "field:" .. fieldSize .. "  mines:" .. tempMines)
            field[x][y][1] = randomMine(fieldSize, tempMines)
            if field[x][y][1] then
                tempMines = tempMines - 1
            end
            fieldSize = fieldSize - 1
        end
    end
    print("generated map")
    if forceX and forceY then
        for x = -1,1,1 do -- force the 3x3 around the first click to not have mines, always creating a 0 space
            for y = -1,1,1 do
                if field[forceX+x][forceY+y][1] then
                    field[forceX+x][forceY+y][1] = false
                    mines = mines - 1
                    print("removing mines")
                end
            end
        end 
    end
    fieldSize = (fieldX*fieldY)-mines
    for x = 1,fieldX,1 do
        for y = 1,fieldY,1 do
            local mineT = 0
            if field[x][y-1][1] then mineT = mineT + 1 end
            if field[x-1][y-1][1] then mineT = mineT + 1 end
            if field[x-1][y][1] then mineT = mineT + 1 end
            if field[x-1][y+1][1] then mineT = mineT + 1 end
            if field[x][y+1][1] then mineT = mineT + 1 end
            if field[x+1][y-1][1] then mineT = mineT + 1 end
            if field[x+1][y][1] then mineT = mineT + 1 end
            if field[x+1][y+1][1] then mineT = mineT + 1 end
            --print(mineT)
            field[x][y][4] = mineT
            --holy crap this somehow works... or it doesn't.. not wait it does
        end
    end
    print("numbers generated")
end --end generate

function fieldHandler.click(clickX,clickY,button) --manages clicks on the field and updates itself
    local mine = false
    if button == 1 then -- mine check, if it clicks on an uncovered it just sets the uncovered flag again and nothing changes
        print("left click!")
        if not field[clickX][clickY][3] then --if not flagged
            if not field[clickX][clickY][1] then --if it's not a mine
                if field[clickX][clickY][2] then -- if it is covered
                    field[clickX][clickY][2] = false
                    fieldSize = fieldSize - 1
                    if field[clickX][clickY][4] == 0 then --if it's empty and covered run clear()
                        clear(clickX,clickY)
                    end
                elseif field[clickX][clickY][4] then -- not covered and text > 0
                    mine = clearNum(clickX,clickY)
                end
            else
                mineHit()
                mine = true
            end
        end
    elseif button == 2 then --simply flips the flag to true
        print("right click!")
        if field[clickX][clickY][2] then
            field[clickX][clickY][3] = not field[clickX][clickY][3]
            if field[clickX][clickY][3] then
                flags = flags + 1
            else
                flags = flags - 1
            end
        end
    end
    if fieldSize == 0 then 
        return true 
    else
        return mine
    end
end

return fieldHandler