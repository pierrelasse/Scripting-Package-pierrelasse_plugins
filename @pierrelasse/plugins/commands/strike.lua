local simpleTargets = require("@pierrelasse/lib/simpleTargets")


Lang.get("en"):put({
    pierrelasse = {
        plugins = {
            commands = {
                strike = {
                    struk = "Struk {0} with lightning",
                    strukLog = "{0} struk {1} with lightning"
                }
            }
        }
    }
})

local this = {
    COMMAND = "strike",
    PERMISSION = "commands.strike"
}

local logDark = require("@pierrelasse/plugins/staff/log").dark:sub("commands/strike")

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

        bukkit.spawnLightning(target.getLocation(), false)

        if target ~= sender then
            logDark:log(function(l, fmt)
                return l:tcf("pierrelasse/plugins/commands/strike/strukLog",
                    fmt:player(sender), fmt:player(target))
            end, sender)
        end
        Lang.messageF(sender, "pierrelasse/plugins/commands/strike/struk",
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
