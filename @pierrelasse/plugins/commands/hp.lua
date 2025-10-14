local complete = require("@pierrelasse/lib/complete")
local simpleTargets = require("@pierrelasse/lib/simpleTargets")


Lang.get("en"):put({
    pierrelasse = {
        plugins = {
            commands = {
                hp = {
                    invalidAmount = comp.mm("<red>Invalid amount!"),
                    set = comp.mm("Set {0}'s health points to <red>❤{1}")
                }
            }
        }
    }
})

local this = {
    COMMAND = "hp",
    PERMISSION = "commands.hp"
}

---@param sender java.Object
---@param target bukkit.entity.Player
---@param amount number
function this.set(sender, target, amount)
    local maxHealth = target.getMaxHealth()
    if amount > maxHealth then amount = maxHealth end

    if target.getHealth() == amount then return end

    target.setHealth(amount)

    Lang.sendF(sender, "pierrelasse/plugins/commands/hp/set",
        target.getName(), amount)
end

events.onStarted(function()
    commands.add(this.COMMAND, function(sender, args)
        if #args < 2 then
            bukkit.send(sender, "§cUsage: /hp <target: player> <amount: number>")
            return
        end

        local target = simpleTargets.find(sender, args[1])
        if target == nil then
            bukkit.send(sender, "§cTarget not found!") -- TODO
            return
        end

        local amount = tonumber(args[2])
        if amount == nil or not (amount >= 0) then
            Lang.send(sender, "pierrelasse/plugins/commands/hp/invalidAmount")
            return
        end

        this.set(sender, target, amount)
    end)
        .permission(this.PERMISSION)
        .complete(function(completions, sender, args)
            if #args == 1 then
                simpleTargets.complete(sender, completions, args[1])
            elseif #args == 2 then
                local target = simpleTargets.find(sender, args[1])
                local maxHealth = target and target.getMaxHealth() or 20

                complete(completions, args[2], { "0", maxHealth * .5, maxHealth })
            end
        end)
end)

return this
