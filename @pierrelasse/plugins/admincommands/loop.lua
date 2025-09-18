local cfg = require("@pierrelasse/plugins/admincommands/_cfg")


local PERMISSION = cfg.permissionPrefix.."loop"

commands.add("loop", function(sender, args)
    ---@cast sender bukkit.entity.Player

    if #args < 3 then
        bukkit.send(sender, "§cUsage: /loop <delay: integer> <amount: integer> <message: string...>")
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

    bukkit.send(sender, "§7Chatting §ex"..amount.." "..delay.."t§7: §f"..message)
end)
    .permission(PERMISSION)
    .complete(function(completions, sender, args)
        if #args == 1 then
            completions.add("<delay>")
        elseif #args == 2 then
            completions.add("<amount>")
        elseif #args == 3 then
            completions.add("/")
        end
    end)
