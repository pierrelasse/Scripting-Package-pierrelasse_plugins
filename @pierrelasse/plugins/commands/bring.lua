local simpleTargets = require("@pierrelasse/lib/simpleTargets")


Lang.get("en"):put({
    pierrelasse = {
        plugins = {
            commands = {
                ["bring"] = {
                    teleported = "Teleported {0} to you"
                }
            }
        }
    }
})

Lang.get("de"):put({
    pierrelasse = {
        plugins = {
            commands = {
                ["bring"] = {
                    teleported = "{0} zu dir teleportiert"
                }
            }
        }
    }
})

local this = {
    COMMAND = "bring",
    PERMISSION = "commands.bring"
}

events.onStarted(function()
    commands.add(this.COMMAND, function(sender, args) ---@cast sender bukkit.entity.Player
        if args[1] == nil then
            bukkit.send(sender, "§cUsage: /"..this.COMMAND.." <target: player>")
            return
        end

        local target = simpleTargets.find(sender, args[1])
        if target == nil then
            bukkit.send(sender, "§cTarget not found!") -- TODO
            return
        end

        bukkit.teleport(target, sender.getLocation())

        Lang.sendF(sender, "pierrelasse/plugins/commands/bring/teleported",
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
