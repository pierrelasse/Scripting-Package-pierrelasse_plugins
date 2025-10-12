local nameFormatter = require("@pierrelasse/lib/nameFormatter")
local SimpleCooldowns = require("@pierrelasse/lib/SimpleCooldowns")


Lang.get("en"):put({
    pierrelasse = {
        plugins = {
            staff = {
                helpop = {
                    needMessage = comp.from("§cPlease specify a message!"),
                    waitBeforeUsingAgain = comp.from("§cPlease wait before using HelpOP again!"),
                    sent = comp.from("§aHelpOP sent! Staff will be with you shortly")
                }
            }
        }
    }
})

local this = {
    PERMISSION = "!.staff.helpop",

    COMMAND = "helpop",
    COOLDOWN = 10
}

this.log = require("@pierrelasse/plugins/staff/log"):sub("helpop", "HelpOP", function(player)
    return player.hasPermission(this.PERMISSION)
end)

this.cooldowns = SimpleCooldowns.new()

events.onStarted(function()
    commands.add(this.COMMAND, function(sender, args) ---@cast sender bukkit.entity.Player
        local message = table.concat(args, " "):trim()
        if #message == 0 then
            Lang.send(sender, "pierrelasse/plugins/staff/helpop/needMessage")
            return
        end

        if this.cooldowns:checkOrSet(bukkit.uuid(sender), "", this.COOLDOWN) then
            Lang.send(sender, "pierrelasse/plugins/staff/helpop/waitBeforeUsingAgain")
            return
        end

        this.log:log(function(l)
            return comp.empty()
                .append(comp.from(nameFormatter.prefixName(sender)))
                .append(comp.text(":").color(comp.colorN("GRAY")))
                .appendSpace()
                .append(comp.text(message).color(comp.colorHex("#eff5ff")))
        end)

        Lang.send(sender, "pierrelasse/plugins/staff/helpop/sent")
    end)
end)

return this
