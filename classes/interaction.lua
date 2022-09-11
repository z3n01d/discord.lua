local http = require("coro-http")
local json = require("json")

local API = "https://discord.com/api/v9/"

local class = require("./object.lua")
local main = class:extend()

function main:new(client,data)
    self.rawData = data
    self.client = client
    self.headers = {
        {"Content-Type", "application/json"},
        {"Authorization", string.format("Bot %s",self.client.token)}
    }
    self.id = self.rawData.id
    self.applicationId = self.rawData.id
    self.type = self.rawData.type
    self.id = self.rawData.id
    self.guildId = self.rawData.guild_id
    self.channelId = self.rawData.channel_id
    self.applicationId = self.rawData.application_id
    self.token = self.rawData.token
    if self.rawData.data ~= nil then
        self.data = self.rawData.data
    end
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

    local res = {
        type = 4,
        data = cont
    }

    coroutine.wrap(function()
        http.request("POST",string.format("%s/interactions/%s/%s/callback",API,self.id,self.token),self.headers,json.stringify(res))
    end)()
end

function main:createFollowup(content)
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

    local res = {
        type = 4,
        data = cont
    }

    coroutine.wrap(function()
        http.request("POST",string.format("%s/webhooks/%s/%s",API,self.applicationId,self.token),self.headers,json.stringify(res))
    end)()
end

return main