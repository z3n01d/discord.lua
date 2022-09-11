-- Modules

local class = require("./object.lua")
local http = require("coro-http")
local timer = require("timer")
local json = require("json")
local webSocket = require("./webSocket.lua")

-- Constants

local API = "https://discord.com/api/v9/"

-- Objects

local Message = require("./message.lua")
local Channel = require("./channel.lua")
local Interaction = require("./interaction.lua")
local User = require("./user.lua")

local colors = require("../ansicolors.lua")

local main = class:extend()

local events = {
    ["MESSAGE_CREATE"] = "messageCreate",
    ["READY"] = "ready",
    ["INTERACTION_CREATE"] = "interactionCreate"
}

local function log(text)
    print(colors("%{green}[DISCORD.LUA]%{reset} " .. text))
end

function main:new(token)
    self.token = token
    self._listeners = {}
end

function main:on(event,fun)
    self._listeners[event] = fun
end

function main:emit(event,...)
    if self._listeners[event] then
        self._listeners[event](...)
    end
end

function main:getChannel(channelId)
    coroutine.wrap(function()
        local headers = {
            {"Content-Type", "application/json"},
            {"Authorization", string.format("Bot %s",self.token)}
        }
        local res,body = http.request("GET",string.format("%s/channels/%s",API,channelId),headers)
        local rawData = json.parse(body)
        local channelObj = Channel(self,rawData)
        return channelObj
    end)()
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
    return coroutine.wrap(function ()
        local res,body = http.request("GET",url,headers)
        return json.parse(body)
    end)()
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
    coroutine.wrap(function ()
        local socket = webSocket()
        socket:on("DISPATCH",function(pl)
            local event = events[pl.t] or pl.t
        
            local args = {}
                            
            if event == "messageCreate" then
                table.insert(args,Message(self,pl.d))
            end

            if event == "interactionCreate" then
                table.insert(args,Interaction(self,pl.d))
            end

            if event == "ready" then
                p(pl.d)
                p(json.parse(pl.d["_trace"][1]))
                self.application = pl.d.application
                self.user = User(self,pl.d)
            end
        
            if #args > 0 then
                self:emit(event,table.unpack(args))
            else
                self:emit(event)
            end
        end)

        socket:on("HEARTBEAT",function()
            log("Got heartbeat")
        end)

        socket:on("HELLO",function(pl)
            log("Got HELLO")
        
            local heartbeat_pl = {
                op = 1,
                d = nil
            }
            local heartbeat_interval = pl.d.heartbeat_interval 
        
            timer.setInterval(heartbeat_interval,function()
                coroutine.wrap(function()
                    socket.send{
                        opcode = 1,
                        payload = json.stringify(heartbeat_pl)
                    }
                end)()
            end)
        
            local identify_pl = {
                op = 2,
                d = {
                    token = self.token,
                    intents = 513,
                    properties = {
                        os = "linux",
                        browser = "discord.lua",
                        device = "discord.lua"
                    }
                }
            }
        
            coroutine.wrap(function()
                socket.send{
                    opcode = 2,
                    payload = json.stringify(identify_pl)
                }
            end)()
        end)
    end)()
end

return main