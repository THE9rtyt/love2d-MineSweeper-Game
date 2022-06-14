local settingsLoader = {};
--stores and defines all the Field variables and functions Module

function settingsLoader.save(settings)
    local save = love.filesystem.newFile('settings.dat', 'w')

    save:write('return {\n')
    for key, value in pairs(settings) do
        save:write(string.format('    %s = %s,\n', key, tostring(value)))
    end
    save:write('}');
end


function settingsLoader.load()
    local settings = love.filesystem.load('settings.dat')

    if settings then
        print('settings found!')
    else
        print(' no settings found, loading default settings!')
        settings = {
            fieldX = 25,
            fieldY = 13,
            Mines = 69,
            forceEmpty = true,
        }
        return settings
    end
    return settings()
end

function settingsLoader.delete()
    return love.filesystem.remove('settings.dat')
end


return settingsLoader