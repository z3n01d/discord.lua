local class = require("./object.lua")
local main = class:extend()

function main:new()
    self.title = ""
    self.description = ""
    self.url = ""
    self.footer = nil
    self.image = nil
    self.thumbnail = nil
    self.video = nil
    self.author = nil
    self.fields = {}
end

function main:setTitle(str)
    self.title = str
end

function main:setDescription(str)
    self.description = str
end

function main:setUrl(str)
    self.url = str
end

function main:setFooter(tbl)
    self.footer = tbl
end

function main:setImage(tbl)
    self.image = tbl
end

function main:setThumbnail(tbl)
    self.thumbnail = tbl
end

function main:setVideo(tbl)
    self.video = tbl
end

function main:setAuthor(tbl)
    self.author = tbl
end

function main:addField(tbl)
    table.insert(self.fields,tbl)
end

return main