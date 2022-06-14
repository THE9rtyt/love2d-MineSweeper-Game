local displayHandler = {}
-------------------------------------------------------------------------------------
-- Handles drawing screen features and private vars, each section in its own function
-------------------------------------------------------------------------------------
local cubeWidth,cubeScale,textScale,windowX,windowY,fieldX,fieldY
local rowsX = {}
local rowsY = {}
local topBarMenuItems = {}
local topBar = 70 -- width of top menu bar
local timerOffset = 0
local standard = 101 --the standard size of an asset image in pixels
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
local mineCube = love.graphics.newImage("/assets/mineCube.png",{})
local textCube = love.graphics.newImage("/assets/textCube.png",{})
local bombCube = love.graphics.newImage("/assets/bombCube.png",{})
local flagCube = love.graphics.newImage("/assets/flagCube.png",{})
local lost = love.graphics.newImage("/assets/lost.png",{})
local win = love.graphics.newImage("/assets/win.png",{})
local textColon = love.graphics.newImage("/assets/textColon.png",{})
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
    return topBar
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

function displayHandler.findRows(clickX,clickY) --this exists just for the mouseHandler
    for Row,value in pairs(rowsX) do
        if clickX < (value+cubeWidth) then
            clickX = Row
            break
        end
    end --this function should never get to the end of this loop

    for Row,value in pairs(rowsY) do
        if clickY < (value+cubeWidth) then
            clickY = Row
            break
        end
    end
    return clickX,clickY -- in the event it makes it here, we give it a number that will make it do nothing
end

function displayHandler.findBarItem(clickX)
    for Index,key in pairs(topBarMenuItems) do
        if clickX < key then
            print(Index, key)
            return Index --see displayHandler topBarMenuItems var for Index info
        end
    end
    return 0
end

function displayHandler.findMenuNum(clickX,clickY)
    if clickY > windowY/2-menuRect.y/2 and clickY < windowY/2+menuRect.y/2 then
        if clickX > windowX/2-menuRect.x/2-menuNumSpacing and clickX < windowX/2+menuRect.x/2-menuNumSpacing then
            return "fieldX"
        end
        if clickX > windowX/2-menuRect.x/2 and clickX < windowX/2+menuRect.x/2 then
            return "fieldY"
        end
        if clickX > windowX/2-menuRect.x/2+menuNumSpacing and clickX < windowX/2+menuRect.x/2+menuNumSpacing then
            return "Mines"
        end
    end
end

-------------------
--private function
-------------------

local function getDigit(num,place, multiplier)
    if not multiplier then multiplier = 1 end
    if not place then place = 1 end
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

    topBarMenuItems = {
        windowX/2 - topBar*3,   --clock     Index 1
        windowX/2 - topBar*2,   --setting   Index 2
        windowX/2 - topBar/2,   --spacer1   Index 3
        windowX/2 + topBar/2,   --flagMode  Index 4
        windowX/2 + topBar*2,   --spacer2   Index 5
        windowX/2 + topBar*3,   --reset     Index 6
        windowX                 --score     Index 7
    }
end

function displayHandler.drawTopBar(score,status)--draws topbar,time,score,gamestatus
    --drawing top bar
    love.graphics.setColor(0.7,0.7,0.7)
    love.graphics.rectangle("fill",0,0,windowX,topBar)

    --drawing timer
    love.graphics.setColor(0,0,0)

    --colon for minute divider
    love.graphics.draw(textColon, 20+timerOffset, 0, 0, textScale, textScale)

    if status.timeElapsed >= 600 then -- tens minute digit
        love.graphics.drawLayer(fileIs, getDigit(status.timeElapsed,1,600)+1 ,0, 0, 0, textScale, textScale)
        timerOffset = 30
    end

    love.graphics.drawLayer(fileIs, getDigit(status.timeElapsed,1,60)+1 ,timerOffset, 0, 0, textScale, textScale)

    love.graphics.drawLayer(fileIs, getDigit(status.timeElapsed%60,10)+1 , 20*2+timerOffset, 0, 0, textScale, textScale)

    love.graphics.drawLayer(fileIs, getDigit(status.timeElapsed,1)+1 , 20*2+30+timerOffset, 0, 0, textScale, textScale)


    --making settings button
    love.graphics.setColor(0.9,0.9,0.9)
    love.graphics.rectangle("fill", topBarMenuItems[2]-topBar,0,topBar,topBar)

    --making reset button
    love.graphics.setColor(0.9,0.9,0.9)
    love.graphics.rectangle("fill", topBarMenuItems[6]-topBar,0,topBar,topBar)

    love.graphics.setColor(0,0,0)


    --print(score)
    for _,v in pairs({100,10,1}) do
        if score >= v then -- hundreds digit
            love.graphics.drawLayer(fileIs, getDigit(score,v)+1 , windowX-math.log(v,10)*30-standard*textScale, 0, 0, textScale, textScale)
        end
    end

    if status.gameEnded then --win image
        if status.win then
            love.graphics.draw(win, windowX/2 - 85*textScale, 0, 0, textScale, textScale)
        else
        --lost image
        love.graphics.draw(lost, windowX/2 - 85*textScale, 0, 0, textScale, textScale)
        end
    else
        if status.flagMode then
            love.graphics.setColor(1.0,1.0,1.0)
        else
            love.graphics.setColor(0.5,0.5,0.5)
        end
        love.graphics.draw(flagCube, topBarMenuItems[4]-topBar, 0, 0, textScale, textScale)
    end

end --displayHandler.drawTopBar()

function displayHandler.drawfield(field)--draws the field
    for x = 1,fieldX,1 do --draw field
        for y = 1,fieldY,1 do
            love.graphics.setColor(0,0,0)
            love.graphics.rectangle("line", rowsX[x], rowsY[y], cubeWidth, cubeWidth)
            love.graphics.setColor(1,1,1)
            if field[x][y].covered then --check if covered
                --print("boop X:" .. rowsX[x] .. "  Y:" .. rowsY[y])
                love.graphics.draw(mineCube, rowsX[x], rowsY[y], 0, cubeScale, cubeScale)
                if field[x][y].flagged then --check if flagged, will not draw if it's not covered
                    love.graphics.draw(flagCube, rowsX[x], rowsY[y], 0, cubeScale, cubeScale)
                else 
                end
            else 
                if field[x][y].mine then --exploded bomb
                    love.graphics.draw(bombCube, rowsX[x], rowsY[y], 0, cubeScale, cubeScale)
                else --text
                    love.graphics.draw(textCube, rowsX[x], rowsY[y], 0, cubeScale, cubeScale)
                    if field[x][y].number > 0 then
                        love.graphics.drawLayer(fileIs, field[x][y].number+1, rowsX[x], rowsY[y], 0, cubeScale, cubeScale)
                    end
                end
            end
        end
    end
end --displayHandler.drawfield()

function displayHandler.drawMenu(settings)
    --print fieldY
    --needs to hold center of fieldY menu Location and scale w/ 3/2 digits
    love.graphics.setColor(0.8,0.9,0.9)
    love.graphics.rectangle("fill", topBarMenuItems[2]-topBar,0,topBar,topBar)
    drawMenuNumber(settings.fieldX,-menuNumSpacing)
    drawMenuNumber(settings.fieldY,0)
    drawMenuNumber(settings.Mines,menuNumSpacing)
end

return displayHandler