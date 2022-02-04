--[[ I have no idea what i'm doing
here we go

Made by Joshua Miertschin as a getting-back-into-code project. It went well.

I need to generate a map, and load into an array, then display that array dynamcically so that it's captured in each frame
then calculate mine y/n, then do the math of where numbers are
and lastly, display them

    basic setup -
    --{mine, covered, flagged, text}

    true/false for if it's covered or not
    true/flase for it flagged
    true/flase for if it's a mine

    does math for numbers right away too
]]

--game setup
local fieldX = 25
local fieldY = 13
local MinesSet = 69
local MineFlagged = 0
local timeElapsed = 0
local focused

--boolean game logic
local clicked = false
local GameLost = false
local inPlay = false
local GameWon = false
local field = {}

--misc. math
local fieldSize = fieldX*fieldY
local Mines = MinesSet
--make a clear board of the game size +1 on each side full of -4s to make my math later not freak out

--logic functions
local function resetField(X,Y)--resets field, ready for generation\
    MineFlagged = 0
    inPlay = false
    for x = 0,X+1,1 do
        field[x] = {}
        for y = 0,Y+1,1 do
            if (x == 0 or y == 0) or (x > X or y > Y) then
                field[x][y] = {false, false, false, 8}--{not mine, not covered, flagged, 8}
            else
            field[x][y] = {false, true, false, 8}--{not mine, covered, not flagged, 8}
            end
            --print(field[x][y][1], field[x][y][2], field[x][y][3], field[x][y][4])
        end
    end
end

resetField(fieldX,fieldY)

local function randomMine(size, mines)
    if love.math.random(1,size+mines) <= mines then
        return true
    end
    return false
end

local function generate(X,Y,forceX,forceY)--the actual generator, with options for placing a forced empty square
    timeElapsed = 0
    love.math.setRandomSeed(love.math.random(0,10000))
    fieldSize = fieldX*fieldY
    Mines = MinesSet
    local mines = Mines
    for x = 1,X,1 do
        for y = 1,Y,1 do
            field[x][y][1] = randomMine(fieldSize, mines)
            if field[x][y][1] then
                mines = mines - 1
            end
            fieldSize = fieldSize - 1
            print( "field:" .. fieldSize .. "  mines:" .. mines)
        end
    end
    Mines = Mines - mines
    fieldSize = (fieldX*fieldY)-Mines
    print("generated map")
    if forceX and forceY then
        for x = -1,1,1 do -- force the 3x3 around the first click to not have mines, always creating a 0 space
            for y = -1,1,1 do
                if field[forceX+x][forceY+y][1] then
                    field[forceX+x][forceY+y][1] = false
                    Mines = Mines - 1
                    fieldSize = fieldSize + 1
                    print("removing mines")
                end
            end
        end 
    end
    for x = 1,X,1 do
        for y = 1,Y,1 do
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

local function mineHit()
    GameLost = true
    inPlay = false
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

local function clear(X,Y)                               -- clears spaces around a "0" space that just got cleared, it calls itself creating a recursive function that i'm quite proud works at all.
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
    local flags = 0
    for x = -1,1,1 do --counts flags around Number
        for y = -1,1,1 do
            if field[X+x][Y+y][3] then
                flags = flags + 1
            end
        end
    end
    print("flags:" .. flags)
    if flags >= field[X][Y][4] then
        --print('flags good')
        for x = -1,1,1 do
            for y = -1,1,1 do
                if not field[X+x][Y+y][3] then
                    if field[X+x][Y+y][2] then
                        field[X+x][Y+y][2] = false
                        fieldSize = fieldSize - 1
                        if field[X+x][Y+y][1] then
                            mineHit()
                        elseif field[X+x][Y+y][4] == 0 then
                            clear(X+x,Y+y)
                        end
                    end
                end
            end
        end
    end
end

local mineCube = love.graphics.newImage("/assets/mineCube.png")
local textCube = love.graphics.newImage("/assets/textCube.png")
local bombCube = love.graphics.newImage("/assets/bombCube.png")
local flagCube = love.graphics.newImage("/assets/flagCube.png")
local lost = love.graphics.newImage("/assets/lost.png")
local win = love.graphics.newImage("/assets/win.png")
local textColon = love.graphics.newImage("/assets/textColon.png")
local numbers = {
"/assets/text0.png",
"/assets/text1.png",
"/assets/text2.png",
"/assets/text3.png",
"/assets/text4.png",
"/assets/text5.png",
"/assets/text6.png",
"/assets/text7.png",
"/assets/text8.png",
"/assets/text9.png"}
local fileIs = love.graphics.newArrayImage(numbers)
print("files loaded")
love.graphics.setBackgroundColor(.5,.5,.5)


--drawing field numbers and stuff
local rowsX = {}
local rowsY = {}
local windowX, windowY, flags = love.window.getMode()
local cubeWidth
local cubeScale
local cubeWidthX
local cubeWidthY
local topBar = 70
local textScale

function love.resize(X, Y) --activated everytime the window is resized, it then redoes all the math for love.draw so it's always displayed correctly
    windowX = X
    windowY = Y
    Y = Y-topBar
    rowsX[fieldX+1] = X
    rowsY[fieldY+1] = Y
    cubeWidthX = (X/fieldX)
    cubeWidthY = (Y/fieldY)
    if cubeWidthY*fieldX > X then --wide boi
        cubeWidth = cubeWidthX
    else -- should be tall boi
        cubeWidth = cubeWidthY
    end
    for i = 0,(fieldX > fieldY) and fieldX or fieldY,1 do --create grid lines for row check & drawing for mines in X
        rowsX[i] = (X/2 - (fieldX*cubeWidth)/2) + cubeWidth*i
        rowsY[i] = (Y/2 - (fieldY*cubeWidth)/2) + cubeWidth*i + topBar
        --print("Xrows" .. rowsX[i])
    end
    cubeScale = (cubeWidth)/101
    textScale = topBar/101
end

love.resize(windowX,windowY)

function love.focus(f)
    if f then
        focused = true
    else
        focused = false
    end
end

function love.update(t)
    if focused and inPlay then
        timeElapsed = timeElapsed + t
    end
end

function love.draw()
    --drawing top bar
    love.graphics.setColor(0.7,0.7,0.7)
    love.graphics.rectangle("fill",0,0,windowX,topBar)

    love.graphics.setColor(0,0,0)
    love.graphics.draw(textColon, 20, 0, 0, textScale, textScale) --colon for minute divider
    if timeElapsed >= 60 then --minute digit
        love.graphics.drawLayer(fileIs, math.floor(timeElapsed%600/60-1)+2 ,0, 0, 0, textScale, textScale)
    else
        love.graphics.drawLayer(fileIs, 1 ,0, 0, 0, textScale, textScale)
    end
    if timeElapsed >= 10 then --tens second digit
        love.graphics.drawLayer(fileIs, math.floor(timeElapsed%60/10-1)+2 , 20*2, 0, 0, textScale, textScale)
    else
        love.graphics.drawLayer(fileIs, 1, 20*2, 0, 0, textScale, textScale)
    end
    if timeElapsed >= 1 then --ones second digit
        love.graphics.drawLayer(fileIs, math.floor(timeElapsed%10-1)+2 , 20*2+30, 0, 0, textScale, textScale)
    else
        love.graphics.drawLayer(fileIs, 1, 20*2+30, 0, 0, textScale, textScale)
    end

    local score = Mines - MineFlagged
    --print(score)
    if score >= 100 then -- hundreds digit
        love.graphics.drawLayer(fileIs, math.floor(score%1000/100)+1 , windowX-30*2-101*textScale, 0, 0, textScale, textScale)
    end
    if score >=10 then --tens digit
        love.graphics.drawLayer(fileIs, math.floor(score%100/10)+1 , windowX-30*1-101*textScale, 0, 0, textScale, textScale)
    end
    if score >=1  then --ones digit
        love.graphics.drawLayer(fileIs, math.floor(score%10)+1 , windowX-101*textScale, 0, 0, textScale, textScale)
    end

    if GameWon then --win image
        love.graphics.draw(win, windowX/2 - 85*textScale, 0, 0, textScale, textScale)
    end
    if GameLost then --lost image
        love.graphics.draw(lost, windowX/2 - 85*textScale, 0, 0, textScale, textScale)
    end

    for x = 1,fieldX,1 do --draw field
        for y = 1,fieldY,1 do
            love.graphics.setColor(0,0,0)
            love.graphics.rectangle("line", rowsX[x]-cubeWidth, rowsY[y]-cubeWidth, cubeWidth, cubeWidth)
            love.graphics.setColor(1,1,1)
            if field[x][y][2] == true then --check if covered
                --print("boop X:" .. rowsX[x] .. "  Y:" .. rowsY[y])
                love.graphics.draw(mineCube, rowsX[x]-cubeWidth, rowsY[y]-cubeWidth, 0, cubeScale, cubeScale)
                if field[x][y][3] then --check if flagged, will not draw if it's not covered
                    love.graphics.draw(flagCube, rowsX[x]-cubeWidth, rowsY[y]-cubeWidth, 0, cubeScale, cubeScale)
                else 
                end
            else 
                if field[x][y][1] then --exploded bomb
                    love.graphics.draw(bombCube, rowsX[x]-cubeWidth, rowsY[y]-cubeWidth, 0, cubeScale, cubeScale)
                else --text
                    love.graphics.draw(textCube, rowsX[x]-cubeWidth, rowsY[y]-cubeWidth, 0, cubeScale, cubeScale)
                    if field[x][y][4] ~= 0 then
                        love.graphics.drawLayer(fileIs, field[x][y][4]+1, rowsX[x]-cubeWidth, rowsY[y]-cubeWidth, 0, cubeScale, cubeScale)
                    end
                end
            end
        end
    end
end

--[[mouse stuff, now fully contained in the function, and like 30 less loops and ifs! woo for 3d Arrays
game loss to show all mines, and defeat anymore clicking
using the repeat commands allows it to scale to the size of the array, which changes based on game size
]]

local function findRow(clickLocation,rowArray,fieldLength)
    for ArrayLook = 0,fieldLength,1 do
        if clickLocation < rowArray[ArrayLook] then
            return ArrayLook
        end
    end --this function should never get to the end of this loop
    return 0 -- in the event it makes it here, we give it a number that will make it not do anything
end

function love.mousepressed(x, y, button, istouch)
    print("click X:" .. x .. " Y:" .. y .. " button:" .. button)
    print(fieldSize)
    local clickX = findRow(x,rowsX,fieldX)
    local clickY = findRow(y,rowsY,fieldY)
    --print("Row   X:" .. clickX .. " Y:" .. clickY)
    --{mine, covered, flagged, text}
    if ((clickX < 1 or clickX > fieldX) or (clickY < 1 or clickY > fieldY)) then --cancel input if clicked outside of game area, like grey space when window is rectangular
        button = 0 -- cancels all logic afterwards
    elseif button == 3 then
        resetField(fieldX,fieldY)
        clicked = false
        GameLost = false
        inPlay = false
    elseif clicked == false then --check is firct click
        print("first click")
        generate(fieldX,fieldY,clickX,clickY)
        inPlay = true
        print("Begin Game")
        clicked = true --won't repeat until the game is reset
        GameLost = false
        GameWon = false
    elseif GameLost == true then --mine has been clicked,
        if button == 3 then
            resetField(fieldX,fieldY)
            clicked = false
        else button = 0 end
    end

    print(button)
    if fieldSize == 0 then
        button = 0
    end
    
    if button == 1 then -- mine check, if it clicks on an uncovered it just sets the uncovered flag again and nothing changes
        print("left click")
        if not field[clickX][clickY][3] then --if not flagged
            if not field[clickX][clickY][1] then --if it's not a mine
                if field[clickX][clickY][2] then -- if it is covered
                    field[clickX][clickY][2] = false
                    fieldSize = fieldSize - 1
                    if field[clickX][clickY][4] == 0 then --if it's empty and covered run clear()
                        clear(clickX,clickY)
                    end
                elseif field[clickX][clickY][4] then -- not covered and text > 0
                    clearNum(clickX,clickY)
                end
            else
                mineHit()
            end            
        end
    elseif button == 2 then --simply flips the flag to true
        print("right click")
        if field[clickX][clickY][2] then
            field[clickX][clickY][3] = not field[clickX][clickY][3]
            if field[clickX][clickY][3] then
                MineFlagged = MineFlagged + 1
            else
                MineFlagged = MineFlagged - 1
            end
        end
    end
    if fieldSize == 0 then
        inPlay = false
        if not GameLost then
            GameWon = true
        end
    end
print("EndTurn")
end