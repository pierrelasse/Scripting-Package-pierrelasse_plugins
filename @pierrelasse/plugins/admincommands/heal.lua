local simpleTargets = require("@pierrelasse/lib/simpleTargets")
local cfg = require("@pierrelasse/plugins/admincommands/_cfg")
local feed = require("@pierrelasse/plugins/admincommands/feed")


local PERMISSION = cfg.permissionPrefix.."heal"

commands.add("heal", function(sender, args)
    local target = simpleTargets.find(sender, args[1], sender)
    if target == nil then
        bukkit.send(sender, cfg.message.targetNotFound)
        return
    end

    feed(sender, target)

    local oldHealth = target.getHealth()
    local newHealth = target.getMaxHealth()
    target.setHealth(newHealth)

    bukkit.send(sender, "§7Healed §e"..target.getName().." §7by §c❤"..(newHealth - oldHealth))
end)
    .permission(PERMISSION)
    .complete(function(completions, sender, args)
        if #args == 1 then
            simpleTargets.complete(sender, completions, args[1])
        end
    end)
