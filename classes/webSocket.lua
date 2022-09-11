local ws = require("coro-websocket")
local json = require("json")
local class = require("./object.lua")

local GATEWAY_HOST = "gateway.discord.gg"
local GATEWAY_PATH = "/?v=9&encoding=json"

local main = class:extend()

local OP_CODES = {
    [0] = "DISPATCH",
    [1] = "HEARTBEAT",
    [2] = "IDENTIFY",
    [3] = "PRESENCE_UPDATE",
    [4] = "VOICE_STATE_UPDATE",
    [6] = "RESUME",
    [7] = "RECONNECT",
    [8] = "REQUEST_GUILD_MEMBERS",
    [9] = "INVALID_SESSION",
    [10] = "HELLO",
    [11] = "HEARTBEAT_ACK"
}

function main:new()
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

    self.send = write
    self.get = read
    self.listeners = {}
    
    coroutine.wrap(function()
        for e in self.get do
            local pl = json.parse(e.payload)

            if pl ~= nil then
                self:emit(OP_CODES[pl.op] or tostring(pl.op),pl)
            end
        end
    end)()
end

function main:on(event,func)
    if not self.listeners[event] then
        self.listeners[event] = func
    end
end

function main:emit(event,...)
    if self.listeners[event] then
        self.listeners[event](...)
    end
end

return main