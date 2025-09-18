local simpleTargets = require("@pierrelasse/lib/simpleTargets")
local cfg = require("@pierrelasse/plugins/admincommands/_cfg")


local PERMISSION = cfg.permissionPrefix..".feed"

local function execute(sender, target)
    local oldFoodLevel = target.getFoodLevel()
    local newFoodLevel = 20
    local oldSaturation = target.getSaturation()
    local newSaturation = math.max(oldSaturation, 5)

    target.setFoodLevel(newFoodLevel)
    target.setSaturation(newSaturation)

    bukkit.send(sender, "§7Fed §e"..target.getName().."§7 by §6"..(newFoodLevel - oldFoodLevel)..
        " §e"..(newSaturation - oldSaturation))
end

commands.add("feed", function(sender, args)
    local target = simpleTargets.find(sender, args[1], sender)
    if target == nil then
        bukkit.send(sender, cfg.message.targetNotFound)
        return
    end
    execute(sender, target)
end)
    .permission(PERMISSION)
    .complete(function(completions, sender, args)
        if #args == 1 then
            simpleTargets.complete(sender, completions, args[1])
        end
    end)

return execute
