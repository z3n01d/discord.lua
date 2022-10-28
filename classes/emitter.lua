local class = require("./object.lua")
local main = class:extend()

function main:new()
    self.listeners = {}
end

function main:emit(event,...)
    local args = ...
    coroutine.wrap(function ()
        for ev,func in pairs(self.listeners) do
            if ev == event then
                func(args)
            end
        end
    end)()
end

function main:on(event,func)
    assert(type(event) == "string","event must be a string")
    assert(type(func) == "function","func must be a function")
    
    self.listeners[event] = func
end

return main