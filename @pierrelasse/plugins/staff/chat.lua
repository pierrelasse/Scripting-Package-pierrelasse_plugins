local nameFormatter = require("@pierrelasse/lib/nameFormatter")


local this = {
    PREFIX = comp.from("§3[§bS Chat§3] "),

    COMMAND = { "staffchat", "sc" },
    PERMISSION = "!.staff.chat"
}

events.onStarted(function()
    commands.add(this.COMMAND, function(sender, args)
        ---@cast sender bukkit.entity.Player

        local message = table.concat(args, " ")
        if #message == 0 then
            bukkit.send(sender, "§cUsage: /staffchat <message...>")
            return
        end

        Lang.sendMult(
            function(l)
                return comp.empty()
                    .append(this.PREFIX)
                    .append(comp.from(nameFormatter.prefixName(sender)))
                    .append(comp.text(":").color(comp.colorN("GRAY")))
                    .appendSpace()
                    .append(comp.text(message).color(comp.colorHex("#e6fffe")))
            end,
            bukkit.playersLoop(), function(p)
                return p.hasPermission(this.PERMISSION)
            end)
    end)
        .permission(this.PERMISSION)
        .complete(function(completions, sender, args)
            if #args == 1 then
                completions.add("<message>")
            end
        end)
end)

return this
