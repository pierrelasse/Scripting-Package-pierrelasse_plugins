local complete = require("@pierrelasse/lib/complete")
local simpleTargets = require("@pierrelasse/lib/simpleTargets")


Lang.get("en"):put({
    pierrelasse = {
        plugins = {
            commands = {
                gamemode = {
                    invalid = comp.mm("<red>Invalid game mode!"),
                    set = "Set {0}'s game mode to {1}",
                    setOwn = "Set own game mode to {1}",
                    mode = {
                        SURVIVAL = "Survival",
                        CREATIVE = "Creative",
                        ADVENTURE = "Adventure",
                        SPECTATOR = "Spectator"
                    }
                }
            }
        }
    }
})

Lang.get("de"):put({
    pierrelasse = {
        plugins = {
            commands = {
                gamemode = {
                    invalid = comp.mm("<red>Ungültiger Game-Mode!"),
                    set = "Den Game-Mode von {0} auf {1} gesetzt",
                    setOwn = "Eigenen Game-Mode auf {1} gesetzt",
                    mode = {
                        SURVIVAL = "Survival",
                        CREATIVE = "Creative",
                        ADVENTURE = "Adventure",
                        SPECTATOR = "Spectator"
                    }
                }
            }
        }
    }
})

local this = {
    PERMISSION = "commands.gamemode",

    MAP = {
        [bukkit.gameMode("SURVIVAL")]  = { "survival", "s", "0" },
        [bukkit.gameMode("CREATIVE")]  = { "creative", "c", "1" },
        [bukkit.gameMode("ADVENTURE")] = { "adventure", "a", "2" },
        [bukkit.gameMode("SPECTATOR")] = { "spectator", "sp", "3" },
    }
}

---@param str string
function this.gameModeFromString(str)
    for k, v in pairs(this.MAP) do
        local key = table.key(v, str)
        if key ~= nil then
            return k
        end
    end
end

---@protected
---@param sender java.Object
---@param target bukkit.entity.Player
---@param gameMode bukkit.GameMode
function this.set(sender, target, gameMode)
    if target.getGameMode() == gameMode then return end

    target.setGameMode(gameMode)

    local stringifiedGameMode = Lang.l(sender):t("pierrelasse/plugins/commands/gamemode/mode/"..gameMode.name())
    if target == sender then
        Lang.sendF(sender, "pierrelasse/plugins/commands/gamemode/setOwn",
            stringifiedGameMode)
    else
        Lang.sendF(sender, "pierrelasse/plugins/commands/gamemode/set",
            target.getName(), stringifiedGameMode)
    end
end

---@param name string
---@param gameMode bukkit.GameMode
local function registerCommandStandard(name, gameMode)
    commands.add(name, function(sender, args)
        local target = simpleTargets.find(sender, args[1], sender)
        if target == nil then
            bukkit.send(sender, "§cTarget not found!") -- TODO
            return
        end

        this.set(sender, target, gameMode)
    end)
        .permission(this.PERMISSION)
        .complete(function(completions, sender, args)
            if #args == 1 then
                simpleTargets.complete(sender, completions, args[1])
            end
        end)
end

events.onStarted(function()
    for gameMode, values in pairs(this.MAP) do
        registerCommandStandard("gm"..values[2], gameMode)
    end

    commands.add("gm", function(sender, args)
        if args[1] == nil then
            bukkit.send(sender, "§cUsage: /gm <gameMode> [<target: player>]")
            return
        end

        local gameMode = this.gameModeFromString(args[1])
        if gameMode == nil then
            Lang.send(sender, "pierrelasse/plugins/commands/gamemode/invalid")
            return
        end

        local target = simpleTargets.find(sender, args[2], sender)
        if target == nil then
            bukkit.send(sender, "§cTarget not found!") -- TODO
            return
        end

        this.set(sender, target, gameMode)
    end)
        .permission(this.PERMISSION)
        .complete(function(completions, sender, args)
            if #args == 1 then
                complete(
                    completions, args[1],
                    table.valuesLoop(this.MAP), function(i)
                        return i[1]
                    end)
            elseif #args == 2 then
                simpleTargets.complete(sender, completions, args[2])
            end
        end)
end)

return this
