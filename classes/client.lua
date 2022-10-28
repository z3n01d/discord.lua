-- Modules

local class = require("./emitter.lua")
local http = require("coro-http")
local timer = require("timer")
local json = require("json")

-- Constants

local API = "https://discord.com/api/v9/"

-- Objects

local Message = require("./message.lua")
local Channel = require("./channel.lua")
local Interaction = require("./interaction.lua")
local User = require("./user.lua")
local WebSocketManager = require("./webSocketManager.lua")

local colors = require("../ansicolors.lua")

local main = class:extend()

local function log(text)
    print(colors("%{green}[DISCORD.LUA]%{reset} " .. text))
end

function main:new(token)
    main.super.new(self)
    self.token = token
end

function main:getChannel(channelId)

    local channelObj = nil

    coroutine.wrap(function()
        local headers = {
            {"Content-Type", "application/json"},
            {"Authorization", string.format("Bot %s",self.token)}
        }
        local res,body = http.request("GET",string.format("%s/channels/%s",API,channelId),headers)
        local rawData = json.parse(body)
        channelObj = Channel(self,rawData)
    end)()

    while not channelObj do
        timer.sleep(1)
    end

    return channelObj
end

function main:registerGuildCommand(guildId,data)
    local url = string.format("%s/applications/%s/guilds/%s/commands",API,self.application.id,guildId)
    local headers = {
        {"Content-Type", "application/json"},
        {"Authorization", string.format("Bot %s",self.token)}
    }
    coroutine.wrap(function ()
        local res,body = http.request("POST",url,headers,json.stringify(data))
    end)()
end

function main:bulkEditGuildCommands(guildId,data)
    local url = string.format("%s/applications/%s/guilds/%s/commands",API,self.application.id,guildId)
    local headers = {
        {"Content-Type", "application/json"},
        {"Authorization", string.format("Bot %s",self.token)}
    }
    coroutine.wrap(function ()
        local res,body = http.request("PUT",url,headers,json.stringify(data))
    end)()
end

function main:registerCommand(data)
    local url = string.format("%s/applications/%s/commands",API,self.application.id)
    local headers = {
        {"Content-Type", "application/json"},
        {"Authorization", string.format("Bot %s",self.token)}
    }
    coroutine.wrap(function ()
        local res,body = http.request("POST",url,headers,json.stringify(data))
    end)()
end

function main:bulkEditCommands(data)
    local url = string.format("%s/applications/%s/commands",API,self.application.id)
    local headers = {
        {"Content-Type", "application/json"},
        {"Authorization", string.format("Bot %s",self.token)}
    }
    coroutine.wrap(function ()
        local res,body = http.request("PUT",url,headers,json.stringify(data))
    end)()
end

function main:getCommands()
    local url = string.format("%s/applications/%s/commands",API,self.application.id)
    local headers = {
        {"Content-Type", "application/json"},
        {"Authorization", string.format("Bot %s",self.token)}
    }

    local commands = nil

    coroutine.wrap(function ()
        local res,body = http.request("GET",url,headers)
        commands = json.parse(body)
    end)()

    while not commands do
        timer.sleep(1)
    end

    return commands
end

function main:getCurrentUser()
    local headers = {
        {"Content-Type", "application/json"},
        {"Authorization", string.format("Bot %s",self.token)}
    }
    local url = string.format("%s/users/@me",API)

    local user = nil

    coroutine.wrap(function()
        local res,body = http.request("GET",url,headers)
        local data = json.parse(body)
        user = User(self,data)
    end)()

    while not user do
        timer.sleep(1)
    end

    return user
end

function main:getGatewayBot()
    local headers = {
        {"Content-Type", "application/json"},
        {"Authorization", string.format("Bot %s",self.token)}
    }
    local url = string.format("%s/gateway/bot",API)

    local user = nil

    coroutine.wrap(function()
        local res,body = http.request("GET",url,headers)
        local data = json.parse(body)
        user = data
    end)()

    while not user do
        timer.sleep(1)
    end

    return user
end

function main:getGuildCommands(guildId)
    local url = string.format("%s/applications/%s/guilds/%s/commands",API,self.application.id,guildId)
    local headers = {
        {"Content-Type", "application/json"},
        {"Authorization", string.format("Bot %s",self.token)}
    }
    return coroutine.wrap(function()
        local res,body = http.request("GET",url,headers)
        return json.parse(body)
    end)()
end

function main:login()
    WebSocketManager(self)
end

return main