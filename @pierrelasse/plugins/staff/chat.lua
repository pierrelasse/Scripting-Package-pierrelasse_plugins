local nameFormatter = require("@pierrelasse/lib/nameFormatter")


local this = {
    COMMAND = { "staffchat", "sc" },
    PERMISSION = "!.staff.chat"
}

this.log = require("@pierrelasse/plugins/staff/log"):sub("staffchat", "Chat", function(player)
    return player.hasPermission(this.PERMISSION)
end)

events.onStarted(function()
    commands.add(this.COMMAND, function(sender, args) ---@cast sender bukkit.entity.Player
        local message = table.concat(args, " ")
        if #message == 0 then
            bukkit.send(sender, "§cUsage: /staffchat <message...>")
            return
        end

        this.log:log(function(l)
            return comp.empty()
                .append(comp.from(nameFormatter.prefixName(sender)))
                .append(comp.text(":").color(comp.colorN("GRAY")))
                .appendSpace()
                .append(comp.text(message).color(comp.colorHex("#e6fffe")))
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
