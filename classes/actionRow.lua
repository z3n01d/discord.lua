local class = require("./object.lua")
local main = class:extend()

function main:new()
    self.type = 1
    self.components = {}
end

function main:addComponent(comp)
    table.insert(self.components,comp)
end

return main