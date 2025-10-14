local simpleTargets = require("@pierrelasse/lib/simpleTargets")


Lang.get("en"):put({
    pierrelasse = {
        plugins = {
            commands = {
                doas = {
                    did = "Sudoded {0}: {1}",
                    didLog = "{0} sudoded {1}: {2}"
                }
            }
        }
    }
})

local this = {
    COMMAND = "sudo",
    PERMISSION = "commands.doas"
}

local logDark = require("@pierrelasse/plugins/staff/log").dark:sub("commands/doas")

events.onStarted(function()
    commands.add(this.COMMAND, function(sender, args)
        local target = simpleTargets.find(sender, args[1])
        if target == nil then
            bukkit.send(sender, "§cTarget not found!") -- TODO
            return
        end

        local message = table.concat(args, " ", 2)

        target.chat(message)

        logDark:log(function(l)
            return l:tcf("pierrelasse/plugins/commands/doas/didLog",
                sender.getName(), target.getName(), message)
        end, sender)
        Lang.sendF(sender, "pierrelasse/plugins/commands/doas/did",
            target.getName(), message)
    end)
        .permission(this.PERMISSION)
        .complete(function(completions, sender, args)
            if #args == 1 then
                simpleTargets.complete(sender, completions, args[1])
            elseif #args == 2 then
                completions.add("/")
            end
        end)
end)

return this
