local http = require("coro-http")

local json = require("json")

local class = require("./object.lua")
local Channel = require("./channel.lua")
local main = class:extend()

local API = "https://discord.com/api/v9/"

function main:new(client,data)
    self.rawData = data
    self.client = client
    self.headers = {
        {"Content-Type", "application/json"},
        {"Authorization", string.format("Bot %s",self.client.token)}
    }
    self.id = self.rawData.id
    self.channelId = self.rawData.channel_id
    self.content = self.rawData.content
end

function main:reply(content)
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

    cont.message_reference = {
        message_id = self.id,
        fail_if_not_exists = false
    }

    coroutine.wrap(function()
        http.request("POST",string.format("%s/channels/%s/messages",API,self.channelId),self.headers,json.stringify(cont))
    end)()
end

return main