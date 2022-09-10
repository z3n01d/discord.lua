return {
    Client = require("./classes/client.lua"),
    Channel = require("./classes/channel.lua"),
    Embed = require("./classes/embed.lua"),
    ActionRow = require("./classes/actionRow.lua"),
    Button = require("./classes/button.lua"),
    Enums = {
        ButtonStyle = {
            PRIMARY = 1,
            SECONDARY = 2,
            SUCCESS = 3,
            DANGER = 4,
            LINK = 5
        },
        InteractionType = {
            PING = 1,
            APPLICATION_COMMAND = 2,
            MESSAGE_COMPONENT = 3,
            APPLICATION_COMMAND_AUTOCOMPLETE = 4,
            MODAL_SUBMIT = 5
        }
    }
}