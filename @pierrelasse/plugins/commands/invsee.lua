local simpleTargets = require("@pierrelasse/lib/simpleTargets")


Lang.get("en"):put({
    pierrelasse = {
        plugins = {
            commands = {
                invsee = {
                    opened = "Opened {0}'s inventory"
                }
            }
        }
    }
})

Lang.get("de"):put({
    pierrelasse = {
        plugins = {
            commands = {
                invsee = {
                    opened = "Inventar von {0} geöffnet"
                }
            }
        }
    }
})

local this = {
    COMMAND = "invsee",
    PERMISSION = "commands.invsee"
}

events.onStarted(function()
    commands.add(this.COMMAND, function(sender, args) ---@cast sender bukkit.entity.Player
        local target = simpleTargets.find(sender, args[1])
        if target == nil then
            bukkit.send(sender, "§cTarget not found!") -- TODO
            return
        end

        sender.openInventory(target.getInventory())

        Lang.sendF(sender, "pierrelasse/plugins/commands/invsee",
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
