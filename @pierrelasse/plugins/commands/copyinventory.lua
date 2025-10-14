local simpleTargets = require("@pierrelasse/lib/simpleTargets")


Lang.get("en"):put({
    pierrelasse = {
        plugins = {
            commands = {
                copyinventory = {
                    invalidDestination = comp.mm("<red>Invalid destination!"),
                    copied = "Copied inventory from {0} to {1}!",
                    copiedLog = "{0} copied the inventory from {1} ➡ {2}"
                }
            }
        }
    }
})

Lang.get("de"):put({
    pierrelasse = {
        plugins = {
            commands = {
                copyinventory = {
                    invalidDestination = comp.mm("<red>Ungültiges Ziel!"),
                    copied = "Inventar von {0} zu {1} kopiert!"
                }
            }
        }
    }
})

local this = {
    COMMAND = "copyinventory",
    PERMISSION = "commands.copyinventory"
}

local logDark = require("@pierrelasse/plugins/staff/log").dark:sub("commands/copyinventory")

events.onStarted(function()
    commands.add(this.COMMAND, function(sender, args)
        if #args == 0 then
            bukkit.send(sender, "§cUsage: /"..this.COMMAND.." <destination: player> [<source: player>]")
            return
        end

        local destination = simpleTargets.find(sender, args[1])
        if destination == nil then
            Lang.send(sender, "pierrelasse/plugins/commands/copyinventory/invalidDestination")
            return
        end

        local source = simpleTargets.find(sender, args[2], sender)
        if source == nil then return end

        if destination == source then return end

        destination.getInventory().setContents(source.getInventory().getContents())

        logDark:log(function(l)
            return l:tcf("pierrelasse/plugins/commands/copyinventory/copiedLog",
                sender.getName(), source.getName(), destination.getName())
        end, sender)
        Lang.sendF(sender, "pierrelasse/plugins/commands/copyinventory/copied",
            source.getName(), destination.getName())
    end)
        .permission(this.PERMISSION)
        .complete(function(completions, sender, args)
            if #args == 1 then
                simpleTargets.complete(sender, completions, args[1])
            elseif #args == 2 then
                simpleTargets.complete(sender, completions, args[1])
            end
        end)
end)

return this
