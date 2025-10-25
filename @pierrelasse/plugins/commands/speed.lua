local complete = require("@pierrelasse/lib/complete")
local simpleTargets = require("@pierrelasse/lib/simpleTargets")


Lang.get("en"):put({
    pierrelasse = {
        plugins = {
            commands = {
                speed = {
                    missingPermissionOther = comp.mm(
                        "<red>You don't have the permission to change the speed for others!"),
                    invalidMode = comp.mm("<red>Invalid mode!"),
                    invalidSpeed = comp.mm("<red>Invalid speed!"),
                    set = "Set {0}'s {1} speed to {2}",
                    setLog = "{0} set {1}'s {2} speed to {3}",
                    setOwn = "Set own {1} speed to {2}"
                }
            }
        }
    }
})

local this = {
    COMMAND = "speed",
    PERMISSION = "commands.speed"
}
this.PERMISSION_OTHER = this.PERMISSION..".other"

local logDark = require("@pierrelasse/plugins/staff/log").dark:sub("commands/speed")

events.onStarted(function()
    commands.add(this.COMMAND, function(sender, args)
        if #args == 0 then
            bukkit.send(sender,
                "§cUsage: /"..this.COMMAND.." <speed: number{0-10}|reset> [<target: player>] [<fly|walk>]")
            return
        end

        local target = simpleTargets.find(sender, args[2], sender)
        if target == nil then
            bukkit.send(sender, "§cTarget not found!")
            return
        end

        if sender ~= target and not sender.hasPermission(this.PERMISSION_OTHER) then
            Lang.send(sender, "pierrelasse/plugins/commands/speed/missingPermissionOther")
            return
        end

        local mode
        if args[3] == nil then
            mode = target.isFlying()
        elseif args[3] == "fly" then
            mode = true
        elseif args[3] == "walk" then
            mode = false
        else
            Lang.send(sender, "pierrelasse/plugins/commands/speed/invalidMode")
            return
        end

        local speed
        if args[1] == "reset" then
            speed = mode and .1 or .2
        else
            speed = tonumber(args[1])
            if speed == nil then
                Lang.send(sender, "pierrelasse/plugins/commands/speed/invalidSpeed")
                return
            end
            if speed < -10 or speed > 10 then
                Lang.send(sender, "pierrelasse/plugins/commands/speed/invalidSpeed")
                return
            end
            speed = speed / 10
            if speed < -1 or speed > 1 then
                Lang.send(sender, "pierrelasse/plugins/commands/speed/invalidSpeed")
                return
            end
        end

        if mode then target.setFlySpeed(speed) else target.setWalkSpeed(speed) end

        if target ~= sender then
            logDark:log(function(l, fmt)
                return l:tcf("pierrelasse/plugins/commands/speed/setLog",
                    fmt:player(sender), fmt:player(target), mode and "flying" or "walking", speed)
            end, sender)
        end
        Lang.sendF(sender, "pierrelasse/plugins/commands/speed/"..((sender == target) and "setOwn" or "set"),
            target.getName(), mode and "flying" or "walking", speed)
    end)
        .permission(this.PERMISSION)
        .complete(function(completions, sender, args)
            if #args == 1 then
                complete(completions, args[1], { "reset" })
            elseif #args == 2 then
                simpleTargets.complete(sender, completions, args[2])
            elseif #args == 3 then
                complete(completions, args[3], { "fly", "walk" })
            end
        end)
end)

return this
