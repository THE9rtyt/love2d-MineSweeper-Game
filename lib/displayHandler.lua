local displayHandler = {}
-------------------------------------------------------------------------------------
-- Handles drawing screen features and private vars, each section in its own function
-------------------------------------------------------------------------------------
local cubeWidth,cubeScale,textScale,windowX,windowY,fieldX,fieldY
local rowsX = {}
local rowsY = {}
local topBar = 70 -- width of top menu bar
local standard = 101--the standard size of an asset image in pixels
local menuSize = 1.2*standard
local menuScale = menuSize/standard --scale for menu numbers and stuff
local numberSpace = 19*menuScale --calc pixels for number spacing in menu
local menuNumSpacing = 150
local menuRect = {
    x = 130,
    y = 90
}


-------------
--load assets
-------------
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
print("assets loaded")

--------------------
--module I/O methods
--------------------

function displayHandler.GetWindowInfo() --so the mouseHandler can 
    return rowsX,rowsY,topBar,windowX,windowY,menuRect,menuNumSpacing
end

function displayHandler.getCubeWidth()
    return cubeWidth
end

function displayHandler.init(settings,X,Y)--load field settings into display handler for field size
    fieldX = settings.fieldX
    fieldY = settings.fieldY
    displayHandler.resize(X,Y)
    love.graphics.setBackgroundColor(.5,.5,.5)
    print("displayHandler Intialized!")
end

-------------------
--private function
-------------------

local function getDigit(num,place, multiplier)
    if not multiplier then multiplier = 1 end
    return math.floor(num%(place*10*multiplier)/(place*multiplier))
end

local function drawMenuNumber(var, offset)
    --draw background box
    love.graphics.setColor(0.7,0.7,0.7)
    love.graphics.rectangle("fill", windowX/2-(menuRect.x/2)+offset, windowY/2-(menuRect.y/2),menuRect.x,menuRect.y)

    --draw numbers
    love.graphics.setColor(0,0,0)
    if var >=10 then --tens digit
        love.graphics.drawLayer(fileIs, getDigit(var,10)+1 , windowX/2-(menuSize)/2-numberSpace+offset, windowY/2-(standard*menuScale)/2, 0, menuScale, menuScale)
    end
    if var >=1  then --ones digit
        love.graphics.drawLayer(fileIs, getDigit(var,1)+1 , windowX/2-(menuSize)/2+numberSpace+offset, windowY/2-standard*menuScale/2, 0, menuScale, menuScale)
    end
end
--------------------------------------
-- public methods for drawing features
--------------------------------------
function displayHandler.resize(X,Y)--does all the math required to make drawing lines and click locationing
    windowX = X
    windowY = Y
    Y = Y-topBar
    rowsX[fieldX+1] = X
    rowsY[fieldY+1] = Y

    local cubeWidthX = (X/fieldX)
    local cubeWidthY = (Y/fieldY)

    if cubeWidthY*fieldX > X then --wide boi
        cubeWidth = cubeWidthX
    else -- should be tall boi
        cubeWidth = cubeWidthY
    end
    for i = 0,((fieldX > fieldY) and fieldX or fieldY),1 do --create grid lines for row check & drawing for mines in X
        rowsX[i] = (X/2 - (fieldX*cubeWidth)/2) + cubeWidth*(i-1) -- center of window, remove half the total field size, then add where we are for the current grid line
        rowsY[i] = (Y/2 - (fieldY*cubeWidth)/2) + cubeWidth*(i-1) + topBar
        --print("Xrows: " .. rowsX[i] .. "   Yrows: " .. rowsY[i])
    end
    cubeScale = (cubeWidth)/standard
    textScale = topBar/standard
end

function displayHandler.drawTopBar(time_s, score,status,fieldSize)--draws topbar,time,score,gamestatus
    --drawing top bar
    love.graphics.setColor(0.7,0.7,0.7)
    love.graphics.rectangle("fill",0,0,windowX,topBar)

    --drawing timer
    love.graphics.setColor(0,0,0)

    local timerOffest = 0
    if time_s >= 600 then -- tens minute digit
        love.graphics.drawLayer(fileIs, getDigit(time_s,1,600)+1 ,0, 0, 0, textScale, textScale)
        timerOffest = 30
    end

    if time_s >= 60 then --minute digit
        love.graphics.drawLayer(fileIs, getDigit(time_s,1,60)+1 ,timerOffest, 0, 0, textScale, textScale)
    else
        love.graphics.drawLayer(fileIs, 1 ,0, 0, 0, textScale, textScale)
    end

    --colon for minute divider
    love.graphics.draw(textColon, 20+timerOffest, 0, 0, textScale, textScale)

    if time_s >= 10 then --tens second digit
        love.graphics.drawLayer(fileIs, math.floor(time_s%60/10-1)+2 , 20*2+timerOffest, 0, 0, textScale, textScale)
    else
        love.graphics.drawLayer(fileIs, 1, 20*2, 0, 0, textScale, textScale)
    end

    if time_s >= 1 then --ones second digit
        love.graphics.drawLayer(fileIs, math.floor(time_s%10-1)+2 , 20*2+30+timerOffest, 0, 0, textScale, textScale)
    else
        love.graphics.drawLayer(fileIs, 1, 20*2+30, 0, 0, textScale, textScale)
    end

    --making settings button
    love.graphics.setColor(0.9,0.9,0.9)
    love.graphics.rectangle("fill", 20*2+30+30+topBar,0,topBar,topBar)

    --making reset button
    love.graphics.setColor(0.9,0.9,0.9)
    love.graphics.rectangle("fill", 20*2+30+30+topBar,0,topBar,topBar)

    love.graphics.setColor(0,0,0)


    --print(score)
    if score >= 100 then -- hundreds digit
        love.graphics.drawLayer(fileIs, getDigit(score,100)+1 , windowX-30*2-standard*textScale, 0, 0, textScale, textScale)
    end
    if score >=10 then --tens digit
        love.graphics.drawLayer(fileIs, getDigit(score,10)+1 , windowX-30*1-standard*textScale, 0, 0, textScale, textScale)
    end
    if score >=1  then --ones digit
        love.graphics.drawLayer(fileIs, getDigit(score,1)+1 , windowX-standard*textScale, 0, 0, textScale, textScale)
    end

    if status.gameEnded then --win image
        if fieldSize == 0 then
            love.graphics.draw(win, windowX/2 - 85*textScale, 0, 0, textScale, textScale)
        else
        --lost image
        love.graphics.draw(lost, windowX/2 - 85*textScale, 0, 0, textScale, textScale)
        end
    end
end

function displayHandler.drawfield(field)--draws the field
    for x = 1,fieldX,1 do --draw field
        for y = 1,fieldY,1 do
            love.graphics.setColor(0,0,0)
            love.graphics.rectangle("line", rowsX[x], rowsY[y], cubeWidth, cubeWidth)
            love.graphics.setColor(1,1,1)
            if field[x][y][2] == true then --check if covered
                --print("boop X:" .. rowsX[x] .. "  Y:" .. rowsY[y])
                love.graphics.draw(mineCube, rowsX[x], rowsY[y], 0, cubeScale, cubeScale)
                if field[x][y][3] then --check if flagged, will not draw if it's not covered
                    love.graphics.draw(flagCube, rowsX[x], rowsY[y], 0, cubeScale, cubeScale)
                else 
                end
            else 
                if field[x][y][1] then --exploded bomb
                    love.graphics.draw(bombCube, rowsX[x], rowsY[y], 0, cubeScale, cubeScale)
                else --text
                    love.graphics.draw(textCube, rowsX[x], rowsY[y], 0, cubeScale, cubeScale)
                    if field[x][y][4] ~= 0 then
                        love.graphics.drawLayer(fileIs, field[x][y][4]+1, rowsX[x], rowsY[y], 0, cubeScale, cubeScale)
                    end
                end
            end
        end
    end
end

function displayHandler.drawMenu(settings_d)
    --print fieldY
    --needs to hold center of fieldY menu Location and scale w/ 3/2 digits
    love.graphics.setColor(0.8,0.9,0.9)
    love.graphics.rectangle("fill", 20*2+30+30+topBar,0,topBar,topBar)
    drawMenuNumber(settings_d.fieldX,-menuNumSpacing)
    drawMenuNumber(settings_d.fieldY,0)
    drawMenuNumber(settings_d.Mines,menuNumSpacing)
end

return displayHandler