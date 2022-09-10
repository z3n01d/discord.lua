-- Modules

local class = require("./object.lua")
local ws = require("coro-websocket")
local http = require("coro-http")
local timer = require("timer")
local json = require("json")

-- Constants

local GATEWAY_HOST = "gateway.discord.gg"
local GATEWAY_PATH = "/?v=9&encoding=json"
local API = "https://discord.com/api/v9/"

-- Objects

local Message = require("./message.lua")
local Channel = require("./channel.lua")
local Interaction = require("./interaction.lua")

local main = class:extend()

local events = {
    ["MESSAGE_CREATE"] = "messageCreate",
    ["READY"] = "ready",
    ["INTERACTION_CREATE"] = "interactionCreate"
}

local function log(text)
    print(string.format("[DISCORD.LUA] %s",text))
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

function main:login()
    coroutine.wrap(function()
        local res,read,write = nil,nil,nil

        local sucess,err = pcall(function()
            res,read,write = ws.connect{
                host = GATEWAY_HOST,
                path = GATEWAY_PATH,
                tls = true,
                port = 443
            }
        end)

        if not sucess then return print(err) end
    
        coroutine.wrap(function()
            for e in read do
                local pl = json.parse(e.payload)

                if pl ~= nil then
                    if pl.op == 0 then

                        local event = events[pl.t] or pl.t
    
                        local args = {}
                        
                        if event == "messageCreate" then
                            table.insert(args,Message(self,pl.d))
                        end

                        if event == "interactionCreate" then
                            table.insert(args,Interaction(self,pl.d))
                        end
    
                        if #args > 0 then
                            self:emit(event,table.unpack(args))
                        else
                            self:emit(event)
                        end
                    end

                    if pl.op == 1 then
                        log("Got HEARTBEAT")
                    end
    
                    if pl.op == 10 then
                        log("Got HELLO")
    
                        local heartbeat_pl = {
                            op = 1,
                            d = nil
                        }
                        local heartbeat_interval = pl.d.heartbeat_interval 
    
                        timer.setInterval(heartbeat_interval,function()
                            coroutine.wrap(function()
                                write{
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
                            write{
                                opcode = 2,
                                payload = json.stringify(identify_pl)
                            }
                        end)()
    
                    end
                end
            end
        end)()
    end)()
end

return main