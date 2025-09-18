local complete = require("@pierrelasse/lib/complete")
local simpleTargets = require("@pierrelasse/lib/simpleTargets")
local cfg = require("@pierrelasse/plugins/admincommands/_cfg")


local PERMISSION = cfg.permissionPrefix.."speed"
local PERMISSION_OTHER = PERMISSION..".other"

local MESSAGE_INVALID_MODE = "§cInvalid mode! Modes: fly, walk"
local MESSAGE_INVALID_SPEED = "§cInvalid speed. Must be between 0 and 10"
local MESSAGE_SET = "§7Set §e%s§7 speed to §e%s"
local MESSAGE_SET_OTHER = "§7Set §e%s's %s§7 speed to §e%s"
local MESSAGE_MISSING_OTHER_PERMISSION = "§cMissing permission §e"..PERMISSION_OTHER

commands.add("speed", function(sender, args)
    if args[1] == nil then
        return
    end

    local target = simpleTargets.find(sender, args[2], sender)
    if target == nil then
        bukkit.send(sender, cfg.message.targetNotFound)
        return
    end
    if sender ~= target and not sender.hasPermission(PERMISSION_OTHER) then
        bukkit.send(sender, MESSAGE_MISSING_OTHER_PERMISSION)
        return
    end

    local isFly
    if args[3] == nil then
        isFly = target.isFlying()
    elseif args[3] == "fly" then
        isFly = true
    elseif args[3] == "walk" then
        isFly = false
    else
        bukkit.send(sender, MESSAGE_INVALID_MODE)
        return
    end

    local speed
    if args[1] == "reset" then
        speed = isFly and .1 or .2
    else
        speed = tonumber(args[1])
        if speed == nil then
            bukkit.send(sender, MESSAGE_INVALID_SPEED)
            return
        end
        if speed < -10 or speed > 10 then
            bukkit.send(sender, MESSAGE_INVALID_SPEED)
            return
        end
        speed = speed / 10
        if speed < -1 or speed > 1 then
            bukkit.send(sender, MESSAGE_INVALID_SPEED)
            return
        end
    end

    if isFly then target.setFlySpeed(speed) else target.setWalkSpeed(speed) end

    bukkit.send(sender, sender == target
        and string.format(MESSAGE_SET, isFly and "flying" or "walking", speed)
        or string.format(MESSAGE_SET_OTHER, target.getName(), isFly and "flying" or "walking", speed))
end)
    .permission(PERMISSION)
    .complete(function(completions, sender, args)
        if #args == 1 then
            complete(completions, args[1], { "reset" })
        elseif #args == 2 then
            simpleTargets.complete(sender, completions, args[2])
        elseif #args == 3 then
            complete(completions, args[1], { "fly", "walk" })
        end
    end)
