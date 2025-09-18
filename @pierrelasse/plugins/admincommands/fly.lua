local complete = require("@pierrelasse/lib/complete")
local simpleTargets = require("@pierrelasse/lib/simpleTargets")
local cfg = require("@pierrelasse/plugins/admincommands/_cfg")


local PERMISSION = cfg.permissionPrefix..".fly"

commands.add("fly", function(sender, args)
    local target = simpleTargets.find(sender, args[1], sender)
    if target == nil then return end

    local state
    if args[2] == "on" then
        state = true
    elseif args[2] == "off" then
        state = false
    else
        state = not target.getAllowFlight()
    end

    if state then
        target.setAllowFlight(true)
        target.setFlying(true)
    else
        target.setAllowFlight(false)
    end
    bukkit.send(sender, "§e"..target.getName().."§7 can "..(state and "now" or "no longer").." fly")
end)
    .permission(PERMISSION)
    .complete(function(completions, sender, args)
        if #args == 1 then
            simpleTargets.complete(sender, completions, args[1])
        elseif #args == 2 then
            complete(completions, args[2], { "on", "off" })
        end
    end)
