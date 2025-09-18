local simpleTargets = require("@pierrelasse/lib/simpleTargets")
local cfg = require("@pierrelasse/plugins/admincommands/_cfg")


local PERMISSION = cfg.permissionPrefix.."invsee"

commands.add("invsee", function(sender, args)
    local target = simpleTargets.find(sender, args[1])
    if target == nil then
        bukkit.send(sender, cfg.message.targetNotFound)
        return
    end

    sender.openInventory(target.getInventory())
end)
    .permission(PERMISSION)
    .complete(function(completions, sender, args)
        if #args == 1 then
            simpleTargets.complete(sender, completions, args[1])
        end
    end)
