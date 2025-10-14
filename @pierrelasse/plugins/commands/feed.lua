local simpleTargets = require("@pierrelasse/lib/simpleTargets")


Lang.get("en"):put({
    pierrelasse = {
        plugins = {
            commands = {
                feed = {
                    fed = comp.mm("Regenerated {0}'s food by <gold>{1} <yellow>{2}")
                }
            }
        }
    }
})

Lang.get("de"):put({
    pierrelasse = {
        plugins = {
            commands = {
                feed = {
                    fed = comp.mm("Essen von {0} um <gold>{1}</gold> <yellow>{2}</yellow> regeneriert")
                }
            }
        }
    }
})

local this = {
    COMMMAND = "feed",
    PERMISSION = "commands.feed"
}

---@param sender java.Object
---@param target bukkit.entity.Player
function this.feed(sender, target)
    local oldFoodLevel = target.getFoodLevel()
    local newFoodLevel = 20

    local oldSaturation = target.getSaturation()
    local newSaturation = math.max(oldSaturation, 5)

    if  oldFoodLevel == newFoodLevel
    and oldSaturation == newSaturation then
        return
    end

    target.setFoodLevel(newFoodLevel)
    target.setSaturation(newSaturation)

    Lang.sendF(sender, "pierrelasse/plugins/commands/feed/fed",
        target.getName(), newFoodLevel - oldFoodLevel, newSaturation - oldSaturation)
end

events.onStarted(function()
    commands.add(this.COMMMAND, function(sender, args)
        local target = simpleTargets.find(sender, args[1], sender)
        if target == nil then
            bukkit.send(sender, "§cTarget not found!") -- TODO
            return
        end

        this.feed(sender, target)
    end)
        .permission(this.PERMISSION)
        .complete(function(completions, sender, args)
            if #args == 1 then
                simpleTargets.complete(sender, completions, args[1])
            end
        end)
end)

return this
