local class = require("./object.lua")
local webSocket = require("./webSocket.lua")
local fs = require("fs")
local timer = require("timer")
local json = require("json")

local Message = require("./message.lua")
local Channel = require("./channel.lua")
local Interaction = require("./interaction.lua")
local User = require("./user.lua")

local colors = require("../ansicolors.lua")

local events = {
    ["MESSAGE_CREATE"] = "messageCreate",
    ["READY"] = "ready",
    ["INTERACTION_CREATE"] = "interactionCreate"
}

local function log(text)
    print(colors("%{green}[DISCORD.LUA]%{reset} " .. text))
end

local main = class:extend()

if _G.SHARDING == nil then
    _G.SHARDING = false
end

function main:new(client)
    coroutine.wrap(function ()
        self.client = client
        self.socket = webSocket()

        self.socket:on("DISPATCH",function(pl)
            local event = events[pl.t] or pl.t
        
            local args = {}
                            
            if event == "messageCreate" then
                table.insert(args,Message(self.client,pl.d))
            end

            if event == "interactionCreate" then
                table.insert(args,Interaction(self.client,pl.d))
            end

            if event == "ready" then
                self.client.application = pl.d.application
                self.client.user = User(self.client,pl.d)
            end
        
            if #args > 0 then
                self.client:emit(event,table.unpack(args))
            else
                self.client:emit(event)
            end
        end)

        self.socket:on("HEARTBEAT",function()
            log("Got heartbeat")
        end)

        self.socket:on("HELLO",function(pl)
            log("Got HELLO")

            local cache = (fs.readFileSync("gateway.json") and json.parse(fs.readFileSync("gateway.json"))) or {}

            local heartbeat_pl = {
                op = 1,
                d = nil
            }
            local heartbeat_interval = pl.d.heartbeat_interval 
        
            timer.setInterval(heartbeat_interval,function()
                coroutine.wrap(function()
                    self.socket.send{
                        opcode = 1,
                        payload = json.stringify(heartbeat_pl)
                    }
                end)()
            end)

            local identify_pl = {
                op = 2,
                d = {
                    token = self.client.token,
                    intents = 513,
                    properties = {
                        os = "linux",
                        browser = "discord.lua",
                        device = "discord.lua"
                    }
                }
            }
        
            coroutine.wrap(function()
                local res,body = self.socket.send{
                    opcode = 2,
                    payload = json.stringify(identify_pl)
                }
            end)()

            local gatewayBot = self.client:getGatewayBot()
            local shards = gatewayBot.shards
            
            if shards >= 1 and not _G.SHARDING then
                log("Sharding")
                shards = shards - 1
                cache.shards = shards + 1
                if shards > 0 then
                    for i = 1,shards do
                        log(string.format("Shard %s finished",tostring(i)))
                        main(self.client)
                    end
                else
                    log("Shard 1 finished")
                end
                _G.SHARDING = true
            end

            fs.writeFileSync("gateway.json",json.stringify(cache))
        end)
    end)()
end

return main