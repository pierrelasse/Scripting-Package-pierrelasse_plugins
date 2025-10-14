local simpleTargets = require("@pierrelasse/lib/simpleTargets")


Lang.get("en"):put({
    pierrelasse = {
        plugins = {
            commands = {
                ["goto"] = {
                    teleported = "Teleported to {0}",
                    teleportedLog = "{0} ➡ {1}"
                }
            }
        }
    }
})

Lang.get("de"):put({
    pierrelasse = {
        plugins = {
            commands = {
                ["goto"] = {
                    teleported = "Zu {0} teleportiert"
                }
            }
        }
    }
})

local this = {
    COMMAND = "goto",
    PERMISSION = "commands.goto"
}

local logDark = require("@pierrelasse/plugins/staff/log").dark:sub("tp", "TP")

events.onStarted(function()
    commands.add(this.COMMAND, function(sender, args) ---@cast sender bukkit.entity.Player
        if args[1] == nil then
            bukkit.send(sender, "§cUsage: /"..this.COMMAND.." <target: player>")
            return
        end

        local target = simpleTargets.find(sender, args[1])
        if target == nil or target == sender then
            bukkit.send(sender, "§cTarget not found!") -- TODO
            return
        end

        sender.setFallDistance(0)
        bukkit.teleport(sender, target.getLocation())

        logDark:log(function(l)
            return l:tcf("pierrelasse/plugins/commands/goto/teleportedLog",
                sender.getName(), target.getName())
        end, sender)
        Lang.sendF(sender, "pierrelasse/plugins/commands/goto/teleported",
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
