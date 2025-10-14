local simpleTargets = require("@pierrelasse/lib/simpleTargets")


Lang.get("en"):put({
    pierrelasse = {
        plugins = {
            commands = {
                respawn = {
                    notDead = comp.mm("<red>{0} is not dead!"),
                    respawned = "Respawned {0}"
                }
            }
        }
    }
})

Lang.get("de"):put({
    pierrelasse = {
        plugins = {
            commands = {
                respawn = {
                    notDead = comp.mm("<red>{0} ist nicht tot!"),
                    respawned = "{0} wiederbelebt"
                }
            }
        }
    }
})

local this = {
    COMMAND = "respawn",
    PERMISSION = "commands.respawn"
}

events.onStarted(function()
    commands.add(this.COMMAND, function(sender, args)
        if args[1] == nil then
            bukkit.send(sender, "§cUsage: /"..this.COMMAND.." <target: player>")
            return
        end

        local target = simpleTargets.find(sender, args[1])
        if target == nil then
            bukkit.send(sender, "§cTarget not found!") -- TODO
            return
        end

        if not target.isDead() then
            Lang.sendF(sender, "pierrelasse/plugins/commands/respawn/notDead",
                target.getName())
            return
        end

        target.spigot().respawn()

        Lang.sendF(sender, "pierrelasse/plugins/commands/respawn/respawned",
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
