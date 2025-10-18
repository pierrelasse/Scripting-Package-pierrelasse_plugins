local complete = require("@pierrelasse/lib/complete")
local simpleTargets = require("@pierrelasse/lib/simpleTargets")


Lang.get("en"):put({
    pierrelasse = {
        plugins = {
            commands = {
                fly = {
                    enable = "{0} can now fly",
                    enableLog = "{0} enabled {1}'s fly",  -- TODO
                    disable = "{0} can no longer fly",
                    disableLog = "{0} disabled {1}'s fly" -- TODO
                }
            }
        }
    }
})

Lang.get("de"):put({
    pierrelasse = {
        plugins = {
            commands = {
                fly = {
                    enable = "{0} kann nun fliegen",
                    disable = "{0} kann nun nicht mehr fliegen"
                }
            }
        }
    }
})

local this = {
    COMMAND = "fly",
    PERMISSION = "commands.fly"
}

local logDark = require("@pierrelasse/plugins/staff/log").dark:sub("commands/fly")

events.onStarted(function()
    commands.add(this.COMMAND, function(sender, args)
        local target = simpleTargets.find(sender, args[1], sender)
        if target == nil then
            bukkit.send(sender, "§cTarget not found!") -- TODO
            return
        end

        local oldState = target.getAllowFlight()

        local newState
        if args[2] == nil then
            newState = not oldState
        else
            if args[2] == "true" then
                newState = true
            elseif args[2] == "false" then
                newState = false
            end

            if newState == oldState then return end
        end

        target.setAllowFlight(newState)
        if newState and not target.isOnGround() then target.setFlying(newState) end

        if target ~= sender then
            logDark:log(function(l)
                return l:tcf("pierrelasse/plugins/commands/fly/"..(newState and "enable" or "disable").."Log",
                    sender.getName(), target.getName())
            end, sender)
        end
        Lang.sendF(sender, "pierrelasse/plugins/commands/fly/"..(newState and "enable" or "disable"),
            target.getName())
    end)
        .permission(this.PERMISSION)
        .complete(function(completions, sender, args)
            if #args == 1 then
                simpleTargets.complete(sender, completions, args[1])
            elseif #args == 2 then
                complete(completions, args[2], { "true", "false" })
            end
        end)
end)

return this
