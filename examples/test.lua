local discord = require("discord.lua")
local client = discord.Client("bots_token") --Get it from: https://discord.com/developers/applications/

--Executes when bot is ready 
client:on("ready",function()
    print("Bot is online and ready.")
end)

--This event Executes every time that message is sent
client:on("messageCreate",function(msg)
    if msg.content == "!test" then
        msg:reply("Test successful! Your first command is working.")
    end
end)

--Bot login
client:login()