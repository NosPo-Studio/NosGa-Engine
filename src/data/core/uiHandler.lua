local global = ...

local uiHandler = {
    guiApplications = {}
}

function uiHandler.update(signal) 

end

function uiHandler.draw()

end

function uiHandler.listApplication(application)
    uiHandler.guiApplications[application] = true
end

function uiHandler.ignoreApplication(application)
    uiHandler.guiApplications[application] = nil
end

function uiHandler.stop()
    for app in pairs(uiHandler.guiApplications) do
        app:stop()
        uiHandler.guiApplications[app] = nil
    end
end

--===== init =====--
if global.conf.useDoubleBuffering then
    uiHandler.update = function(signal)
        for app in pairs(uiHandler.guiApplications) do
            local suc, err = coroutine.resume(app.coroutine, table.unpack(signal))

            if suc == false then
                global.error("[GUI]: ", err, debug.traceback(app.coroutine))
            end
        end
    end

    uiHandler.draw = function()
        for app in pairs(uiHandler.guiApplications) do
            app:draw()
        end
    end
end

return uiHandler