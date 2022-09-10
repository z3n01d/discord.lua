local discord = require("discord.lua")
local client = discord.Client("your_token")

client:on("ready",function()
    print("Ready.")
end)

client:on("messageCreate",function(msg)
    if msg.content == "!test" then
        msg:reply("Test succeeded")
    end
end)

client:login()