local simpleTargets = require("@pierrelasse/lib/simpleTargets")


Lang.get("en"):put({
    pierrelasse = {
        plugins = {
            commands = {
                ecsee = {
                    opened = "Opened {0}'s ender chest"
                }
            }
        }
    }
})

Lang.get("de"):put({
    pierrelasse = {
        plugins = {
            commands = {
                ecsee = {
                    opened = "Ender-Kiste von {0} geöffnet"
                }
            }
        }
    }
})

local this = {
    COMMAND = "ecsee",
    PERMISSION = "commands.ecsee"
}

events.onStarted(function()
    commands.add("ecsee", function(sender, args) ---@cast sender bukkit.entity.Player
        local target = simpleTargets.find(sender, args[1])
        if target == nil then
            bukkit.send(sender, "§cTarget not found!") -- TODO
            return
        end

        sender.openInventory(target.getEnderChest())

        Lang.sendF(sender, "pierrelasse/plugins/commands/ecsee/opened",
            target.getName())
    end)
        .permission(this.PERMISSION)
        .complete(function(completions, sender, args)
            if #args == 1 then
                simpleTargets.complete(sender, completions, args[1])
            end
        end)
end)

return this
