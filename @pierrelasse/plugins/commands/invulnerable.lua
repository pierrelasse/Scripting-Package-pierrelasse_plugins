local complete = require("@pierrelasse/lib/complete")
local simpleTargets = require("@pierrelasse/lib/simpleTargets")


Lang.get("en"):put({
    pierrelasse = {
        plugins = {
            commands = {
                invulnerable = {
                    invalidState = comp.mm("<red>Invalid state!"),
                    enable = "Made {0} invulnerable",
                    enableLog = "{0} made {1} invulnerable",
                    disable = "Made {0} vulnerable",
                    disableLog = "{0} made {0} vulnerable"
                }
            }
        }
    }
})

local this = {
    COMMAND = { "invulnerable", "god" },
    PERMISSION = "commands.invulnerable"
}

local logDark = require("@pierrelasse/plugins/staff/log").dark:sub("commands/invulnerable")

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
            else
                Lang.send(sender, "pierrelasse/plugins/commands/invulnerable/invalidState")
                return
            end

            if newState == oldState then return end
        end

        target.setInvulnerable(newState)

        if target ~= sender then
            logDark:log(function(l)
                return l:tcf("pierrelasse/plugins/commands/invulnerable/"..(newState and "enable" or "disable").."Log",
                    sender.getName(), target.getName())
            end, sender)
        end
        Lang.sendF(sender, "pierrelasse/plugins/commands/invulnerable/"..(newState and "enable" or "disable"),
            target.getName())
    end)
        .permission(this.PERMISSION)
        .complete(function(completions, sender, args)
            if #args == 1 then
                simpleTargets.complete(sender, completions, args[1])
            elseif #args == 2 then
                complete(completions, args[2], { "true", "false" })
            end
        end)
end)

return this
