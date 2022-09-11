local class = require("./object.lua")
local main = class:extend()

function main:new(client,data)
    self.rawData = data
    self.id = self.rawData.id
    self.bot = self.rawData.bot
    self.avatar = self.rawData.avatar
    self.banner = self.rawData.banner
end

return main