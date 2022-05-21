local fieldHandler   = require("lib.fieldHandler")
local displayHandler = require("lib.displayHandler")

--[[mouse stuff, now fully contained in the function, and like 30 less loops and ifs! woo for 3d Arrays
game loss to show all mines, and defeat anymore clicking
using the repeat commands allows it to scale to the size of the array, which changes based on game size

    update, it's now a library woo
]]

local mouseHandler = {}
local rowsX = {}
local rowsY = {}
local topBar,windowX,windowY,fieldX,fieldY,menuRect,menuNumSpacing

--------------
-- I/O Methods
--------------
function mouseHandler.init(settings)--load field settings into display handler for field size
    fieldX = settings.fieldX
    fieldY = settings.fieldY
    --mouseHandler tags off of math that the displayHandler does
    rowsX,rowsY,topBar,windowX,windowY,menuRect,menuNumSpacing = displayHandler.GetWindowInfo()
    print("mouseHandler Intialized!")
end

-------------------
--private function
-------------------
local function findRow(clickLocation,rowArray)
    for Row,value in pairs(rowArray) do
        if clickLocation < (value+displayHandler.getCubeWidth()) then
            return Row
        end
    end --this function should never get to the end of this loop
    return 0 -- in the event it makes it here, we give it a number that will make it do nothing
end

local function findBarItem(clickX)
    for Index,key in pairs(displayHandler.getTopBarItems()) do
        if clickX < key then
            return Index --see displayHandler topBarMenuItems var for Index info
        end
    end
    return 0
end

local function limit(var,change)
    if var+change > 99 or var+change < 1 then
        return var
    else
        return var+change
    end
end



----------------------------------------
-- public method for Mouse Click Events
----------------------------------------
function mouseHandler.mousePress(x,y, button,status)
    print("click X:" .. x .. " Y:" .. y .. " button:" .. button)
    local clickX = findRow(x,rowsX)
    local clickY = findRow(y,rowsY)
    print("click X:" .. clickX .. " Y:" .. clickY)
    if status.menu then
        if y <= topBar then
            local hit = findBarItem(x)
            if hit == 2  then--settings button hit
                print('settingsHit!')
                status.menu = false
                status.resetNeeded = true
            end
        else
            print('menu stuff')
            --nothing to add atm
        end
    else --game view
        if y <= topBar then --top bar hit
            local hit = findBarItem(x)
            if hit == 2 then
                print('settingsHit!')
                status.menu = true
            elseif hit == 4 then
                status.flagMode = not status.flagMode
            elseif hit == 6 then
                print('resetHit!')
                fieldHandler.resetField()
                status.gameEnded = false
                status.clicked = false
                status.inPlay = false
                status.timeElapsed = 0
            end
        elseif ((clickX < 1 or clickX > fieldX) or (clickY < 1 or clickY > fieldY)) then
            print("click not on minefield!")
        elseif button == 3 then
            print("middle click!")
            fieldHandler.resetField()
            status.resetNeeded = true
        else
            if not status.gameEnded then --Game is not ended
                if not status.clicked then -- is the field hasn't been clicked
                    status.clicked = true --it has now been clicked
                    if status.forceEmpty then
                        fieldHandler.generate(clickX,clickY)
                    else
                        fieldHandler.generate()
                    end
                    status.inPlay = true --begin play
                end
                status = fieldHandler.click({x = clickX,y = clickY,button = button}, status)
            end
        end
    end
print("EndTurn")
return status
end --mousePress()

function mouseHandler.wheelmoved(x,y, settings)
    local mouseX, mouseY = love.mouse.getPosition()
    --settings.fieldY = limit(settings.fieldY,y)
    if mouseY > windowY/2-menuRect.y/2 and mouseY < windowY/2+menuRect.y/2 then
        if mouseX > windowX/2-menuRect.x/2-menuNumSpacing and mouseX < windowX/2+menuRect.x/2-menuNumSpacing then
            settings.fieldX = limit(settings.fieldX,y)
        end
        if mouseX > windowX/2-menuRect.x/2 and mouseX < windowX/2+menuRect.x/2 then
        settings.fieldY = limit(settings.fieldY,y)
        end
        if mouseX > windowX/2-menuRect.x/2+menuNumSpacing and mouseX < windowX/2+menuRect.x/2+menuNumSpacing then
            settings.Mines = limit(settings.Mines,y)
        end
    end
    return settings
end

return mouseHandler