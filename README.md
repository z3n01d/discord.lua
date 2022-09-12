# discord.lua
An object oriented Discord API wrapper written in Luvit runtime enviroment.

# Installation
## 1st method (recommended)
Use git clone to clone this repo in your deps folder

```
git clone https://github.com/RealJace/discord.lua.git deps/discord.lua
```
You may also need to install these packages : 

```
lit install creationix/coro-http
lit install creationix/coro-websocket
lit install luvit/secure-socket
```
## 2st method
Use Luvit's built in package manager (coming soon)

# Examples

## First command

```
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
```

You can also find this in examples folder.

More comming soon.