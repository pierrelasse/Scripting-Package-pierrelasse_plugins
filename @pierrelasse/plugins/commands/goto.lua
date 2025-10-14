local simpleTargets = require("@pierrelasse/lib/simpleTargets")


Lang.get("en"):put({
    pierrelasse = {
        plugins = {
            commands = {
                ["goto"] = {
                    teleported = "Teleported to {0}"
                }
            }
        }
    }
})

local this = {
    COMMAND = "goto",
    PERMISSION = "commands.goto"
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

        bukkit.teleport(sender, target.getLocation())

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
