local class = require("./object.lua")
local main = class:extend()

function main:new()
    self.type = 2
    self.style = 1
    self.label = ""
    self.custom_id = ""
    self.url = ""
    self.disabled = false
end

function main:setStyle(style)
    self.style = style
end
function main:setLabel(str)
    self.label = str
end
function main:setCustomId(str)
    self.custom_id = str
end
function main:setUrl(str)
    self.url = str
end
function main:setDisabled(disabled)
    self.disabled = disabled
end

return main