local simpleTargets = require("@pierrelasse/lib/simpleTargets")


Lang.get("en"):put({
    pierrelasse = {
        plugins = {
            commands = {
                invulnerable = {
                    enable = "Set {0} to be invulnerable",
                    disable = "Set {0} to be vulnerable"
                }
            }
        }
    }
})

local this = {
    COMMAND = { "invulnerable", "god" },
    PERMISSION = "commands.invulnerable"
}

events.onStarted(function()
    commands.add(this.COMMAND, function(sender, args)
        local target = simpleTargets.find(sender, args[1], sender)
        if target == nil then
            bukkit.send(sender, "§cTarget not found!") -- TODO
            return
        end

        local oldState = target.isInvulnerable()
        local newState
        if args[2] == nil then
            newState = not oldState
        else
            if args[2] == "true" then
                newState = true
            elseif args[2] == "false" then
                newState = false
            end

            if newState == oldState then return end
        end

        target.setInvulnerable(newState)

        Lang.sendF(sender, "pierrelasse/plugins/commands/invulnerable/"..(newState and "enable" or "disable"),
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
