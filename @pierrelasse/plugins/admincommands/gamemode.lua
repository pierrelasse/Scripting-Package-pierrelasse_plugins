local complete = require("@pierrelasse/lib/complete")
local simpleTargets = require("@pierrelasse/lib/simpleTargets")
local cfg = require("@pierrelasse/plugins/admincommands/_cfg")


local PERMISSION = "admincommands.gamemode"
local MAP = {
    [bukkit.gameMode("SURVIVAL")]  = { "survival", "s", "0" },
    [bukkit.gameMode("CREATIVE")]  = { "creative", "c", "1" },
    [bukkit.gameMode("ADVENTURE")] = { "adventure", "a", "2" },
    [bukkit.gameMode("SPECTATOR")] = { "spectator", "sp", "3" },
}

local function sendSuccessMessage(sender, target, gamemode)
    local stringifiedGameMode = MAP[gamemode][1]
    if target == sender then
        bukkit.send(sender, "§7Set own game mode to §e"..stringifiedGameMode)
    else
        bukkit.send(sender, "§7Set §e"..target.getName().."'s§7 game mode to §e"..stringifiedGameMode)
    end
end

local function registerCommandStandard(name, gamemode)
    commands.add(name, function(sender, args)
        local target = simpleTargets.find(sender, args[1], sender)
        if target == nil then
            bukkit.send(sender, cfg.message.targetNotFound)
            return
        end
        target.setGameMode(gamemode)
        sendSuccessMessage(sender, target, gamemode)
    end)
        .permission(PERMISSION)
        .complete(function(completions, sender, args)
            if #args == 1 then
                simpleTargets.complete(sender, completions, args[1])
            end
        end)
end

for gamemode, values in pairs(MAP) do
    registerCommandStandard("gm"..values[2], gamemode)
end

commands.add("gm", function(sender, args)
    local gamemode
    for loopGameMode, values in pairs(MAP) do
        local key = table.key(values, args[1])
        if key ~= nil then
            gamemode = loopGameMode
            break
        end
    end
    if gamemode == nil then
        bukkit.send(sender, "§cInvalid gamemode!")
        return
    end

    local target = simpleTargets.find(sender, args[2], sender)
    if target == nil then
        bukkit.send(sender, cfg.message.targetNotFound)
        return
    end

    if target.getGameMode() == gamemode then return end

    target.setGameMode(gamemode)
    sendSuccessMessage(sender, target, gamemode)
end)
    .permission(PERMISSION)
    .complete(function(completions, sender, args)
        if #args == 1 then
            complete(
                completions, args[1],
                table.valuesLoop(MAP), function(i)
                    return i[1]
                end)
        elseif #args == 2 then
            simpleTargets.complete(sender, completions, args[2])
        end
    end)
