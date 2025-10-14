local simpleTargets = require("@pierrelasse/lib/simpleTargets")


Lang.get("en"):put({
    pierrelasse = {
        plugins = {
            commands = {
                heal = {
                    healed = comp.mm("Healed {0} by <red>❤{1}")
                }
            }
        }
    }
})

local this = {
    COMMANDS = "heal",
    PERMISSION = "commands.heal",
    FEED = true
}

events.onStarted(function()
    local feed = this.FEED and require("@pierrelasse/plugins/commands/feed")

    commands.add(this.COMMANDS, function(sender, args)
        local target = simpleTargets.find(sender, args[1], sender)
        if target == nil then
            bukkit.send(sender, "§cTarget not found!") -- TODO
            return
        end

        if this.FEED then feed.feed(sender, target) end

        local oldHealth = target.getHealth()
        local newHealth = target.getMaxHealth()

        if oldHealth == newHealth then return end

        target.setHealth(newHealth)

        Lang.sendF(sender, "pierrelasse/plugins/commands/heal/healed",
            target.getName(), newHealth - oldHealth)
    end)
        .permission(this.PERMISSION)
        .complete(function(completions, sender, args)
            if #args == 1 then
                simpleTargets.complete(sender, completions, args[1])
            end
        end)
end)

return this
