local http = require("coro-http")

local json = require("json")

local class = require("./object.lua")
local main = class:extend()

local API = "https://discord.com/api/v9/"

function main:new(client,data)
    self.rawData = data
    self.client = client
    self.id = self.rawData.id
    self.guildId = self.rawData.guild_id
end

function main:send(content)
    local cont = nil

    if type(content) == "string" then
        cont = {
            content = content
        }
    elseif type(content) == "table" then
        cont = content
    end

    if cont == nil then
        error("content must be string or table")
    end

    local headers = {
        {"Content-Type", "application/json"},
        {"Authorization", string.format("Bot %s",self.client.token)}
    }

    coroutine.wrap(function()
        http.request("POST",string.format("%s/channels/%s/messages",API,self.id),headers,json.stringify(cont))
    end)()
end

return main