local simpleTargets = require("@pierrelasse/lib/simpleTargets")
local cfg = require("@pierrelasse/plugins/admincommands/_cfg")


local PERMISSION = cfg.permissionPrefix..".cloneinv"

commands.add("cloneinv", function(sender, args)
    if args[1] == nil then
        sender.sendMessage("§cUsage: /cloneinv <to: player> <from: player>")
        return
    end

    local to = simpleTargets.find(sender, args[1])
    if to == nil then
        bukkit.send(sender, "§cMissing to!")
        return
    end
    local from = simpleTargets.find(sender, args[2], sender)
    if from == nil then return end

    to.getInventory().setContents(from.getInventory().getContents())
    to.getInventory().setArmorContents(from.getInventory().getArmorContents())

    bukkit.send(sender, "§aCloned inventory to §2"..to.getName().."§a from §2"..from.getName())
end)
    .permission(PERMISSION)
    .complete(function(completions, sender, args)
        if #args == 1 then
            simpleTargets.complete(sender, completions, args[1])
        elseif #args == 2 then
            simpleTargets.complete(sender, completions, args[1])
        end
    end)
