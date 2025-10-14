Lang.get("en"):put({
    pierrelasse = {
        plugins = {
            commands = {
                loop = {
                    doing = "Looping x{0} ⏱{1}: {2}"
                }
            }
        }
    }
})

Lang.get("de"):put({
    pierrelasse = {
        plugins = {
            commands = {
                loop = {
                    doing = "Loopt x{0} ⏱{1}: {2}"
                }
            }
        }
    }
})

local this = {
    COMMAND = "loop",
    PERMISSION = "commands.loop"
}

events.onStarted(function()
    commands.add(this.COMMAND, function(sender, args) ---@cast sender bukkit.entity.Player
        if #args < 3 then
            bukkit.send(sender, "§cUsage: /"..this.COMMAND.." <delay: integer> <amount: integer> <message: string...>")
            return
        end

        local delay = tonumber(args[1], 10)
        local amount = tonumber(args[2], 10)
        local message = table.concat(args, " ", 3)

        tasks.repeatFor(
            amount, delay,
            function(task)
                if not sender.isOnline() then
                    task.cancel()
                    return
                end

                sender.chat(message)
            end)

        Lang.sendF(sender, "pierrelasse/plugins/commands/loop/doing",
            amount, delay, message)
    end)
        .permission(this.PERMISSION)
        .complete(function(completions, sender, args)
            if #args == 1 then
                completions.add("<delay>")
            elseif #args == 2 then
                completions.add("<amount>")
            elseif #args == 3 then
                completions.add("/")
            end
        end)
end)

return this
