local simpleTargets = require("@pierrelasse/lib/simpleTargets")
local cfg = require("@pierrelasse/plugins/admincommands/_cfg")


local PERMISSION = cfg.permissionPrefix.."sudo"
local MESSAGE_SUDOING = "§7Sudoing §e%s§7:§f %s"

commands.add("sudo", function(sender, args)
    local target = simpleTargets.find(sender, args[1])
    if target == nil then
        bukkit.send(sender, cfg.message.targetNotFound)
        return
    end
    local msg = table.concat(args, " ", 2)

    local message = "§7Sudoing §e"..target.getName().."§7:§f "..msg
    bukkit.send(sender, message)

    target.chat(msg)
end)
    .permission(PERMISSION)
    .complete(function(completions, sender, args)
        if #args == 1 then
            simpleTargets.complete(sender, completions, args[1])
        elseif #args == 2 then
            completions.add("/")
        end
    end)
