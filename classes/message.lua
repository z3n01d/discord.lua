local http = require("coro-http")

local json = require("json")

local timer = require("timer")

local class = require("./object.lua")
local User = require("./user.lua")
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
    self.author = User(self.client,self.rawData.author)
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
    local _,body = nil,nil
    coroutine.wrap(function()
        local _,body = http.request("POST",string.format("%s/channels/%s/messages",API,self.channelId),self.headers,json.stringify(cont))
        return json.parse(body)
    end)()

    while not body do
        timer.sleep(1)
    end

    local data = json.parse(body)
    local msg = main(self.client,data)

    return msg
end

function main:edit(content)
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

    coroutine.wrap(function()
        local res,body = http.request("PATCH",string.format("%s/channels/%s/messages/%s",API,self.channelId,self.id),self.headers,json.stringify(cont))
    end)()
end

function main:delete()
    coroutine.wrap(function()
        http.request("DELETE",string.format("%s/channels/%s/messages/%s",API,self.channelId,self.id),self.headers)
    end)()
end

return main