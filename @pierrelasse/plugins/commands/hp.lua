local complete = require("@pierrelasse/lib/complete")
local simpleTargets = require("@pierrelasse/lib/simpleTargets")


Lang.get("en"):put({
    pierrelasse = {
        plugins = {
            commands = {
                hp = {
                    invalidAmount = comp.mm("<red>Invalid amount!"),
                    set = comp.mm("Set {0}'s health points to <red>❤{1}"),
                    setLog = comp.mm("{0} set {1}'s health points to <#B30000>❤{2}")
                }
            }
        }
    }
})

local this = {
    COMMAND = "hp",
    PERMISSION = "commands.hp"
}

local logDark = require("@pierrelasse/plugins/staff/log").dark:sub("commands/hp")

---@param sender java.Object
---@param target bukkit.entity.Player
---@param amount number
function this.set(sender, target, amount)
    local maxHealth = target.getMaxHealth()
    if amount > maxHealth then amount = maxHealth end

    if target.getHealth() == amount then return end

    target.setHealth(amount)

    if target ~= sender then
        logDark:log(function(l, fmt)
            return l:tcf("pierrelasse/plugins/commands/hp/setLog",
                fmt:player(sender), fmt:player(target), amount)
        end, sender)
    end
    Lang.sendF(sender, "pierrelasse/plugins/commands/hp/set",
        target.getName(), amount)
end

events.onStarted(function()
    commands.add(this.COMMAND, function(sender, args)
        if #args == 0 then
            bukkit.send(sender, "§cUsage: /hp <amount: number> [<target: player>]")
            return
        end

        local amount = tonumber(args[1])
        if amount == nil or not (amount >= 0) then
            Lang.send(sender, "pierrelasse/plugins/commands/hp/invalidAmount")
            return
        end

        local target = simpleTargets.find(sender, args[2], sender)
        if target == nil then
            bukkit.send(sender, "§cTarget not found!") -- TODO
            return
        end

        this.set(sender, target, amount)
    end)
        .permission(this.PERMISSION)
        .complete(function(completions, sender, args)
            if #args == 1 then
                local target = simpleTargets.find(sender, args[2], sender)
                local maxHealth = target and target.getMaxHealth() or 20
                complete(completions, args[1], { "0", maxHealth * .5, maxHealth })
            elseif #args == 2 then
                simpleTargets.complete(sender, completions, args[2])
            end
        end)
end)

return this
