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

local settingsLoader = require('lib.settingsLoader')
local fieldHandler = require('lib.fieldHandler')
local displayHandler = require('lib.displayHandler')
local mouseHandler   = require('lib.mouseHandler')

local status = {}

local settings

function love.load()
    settings = settingsLoader.load()
    status = {
        clicked = false,
        gameEnded = false,
        win = false,
        inPlay = false,
        timeElapsed = 0,
        menu = false,
        resetNeeded = false,
        flagMode = false,
        forceEmpty = settings.forceEmpty
    }

    --game setup
    fieldHandler.fieldInit(settings)
    fieldHandler.resetField()

    --Initialize displayHandler
    local windowX, windowY = love.window.getMode()
    displayHandler.init(settings,windowX,windowY)

    --Initialize mouseHandler
    mouseHandler.init(settings)
end

function love.resize(X, Y) --activated everytime the window is resized, it then redoes all the math for love.draw so it's always displayed correctly
    displayHandler.resize(X,Y)
end

function love.focus(f)
    if f then
        status.inPlay = true
    else
        status.inPlay = false
    end
end

function love.update(t)
    if status.inPlay and not status.gameEnded then
        status.timeElapsed = status.timeElapsed + t
    end
end

function love.draw()
    if not status.menu then
        displayHandler.drawTopBar(fieldHandler.getScore(), status)
        displayHandler.drawfield(fieldHandler.getField())
    else
        displayHandler.drawMenu(settings)
    end
end

function love.mousepressed(x, y, button, istouch)
    status = mouseHandler.mousePress(x,y,button,status)
    if status.resetNeeded then
        settingsLoader.save(settings)
        love.load()
    end
end

function love.quit()
    print("bye lol.")
end

function love.wheelmoved( x,y )
    if status.menu then
        settings = mouseHandler.wheelmoved( x,y,settings )
    --save settings, when we exit the menu we'll actually load them
    end
end