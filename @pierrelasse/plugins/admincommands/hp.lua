local simpleTargets = require("@pierrelasse/lib/simpleTargets")
local cfg = require("@pierrelasse/plugins/admincommands/_cfg")


local PERMISSION = cfg.permissionPrefix..".hp"

commands.add("hp", function(sender, args)
    if #args < 2 then
        sender.sendMessage("§cUsage: /hp <target: player> <amount: integer>")
        return
    end

    local target = simpleTargets.find(sender, args[1])
    if target == nil then
        bukkit.send(sender, cfg.message.targetNotFound)
        return
    end

    local amount = tonumber(args[2])
    if amount == nil or not (amount >= 0) then
        bukkit.send(sender, "§cInvalid amount!")
        return
    end
    local maxHealth = target.getMaxHealth()
    if amount > maxHealth then
        amount = maxHealth
    end

    target.setHealth(amount)
    bukkit.send(sender, "§7Set §e"..target.getName().."'s§7 health points to §c❤"..amount)
end)
    .permission(PERMISSION)
    .complete(function(completions, sender, args)
        if #args == 1 then
            simpleTargets.complete(sender, completions, args[1])
        end
    end)
