local PlayerQuitEvent = import("org.bukkit.event.player.PlayerQuitEvent")


Lang.get("en"):put({
    pierrelasse = {
        plugins = {
            staff = {
                spec = {
                    enabled = "§aSpectator enabled!",
                    disabled = "§aSpectator disabled!",
                    disableTTP = "§eClick to disable the spectator mode!",
                    clickToSpectate = "§eClick to spectate this player!",
                    clickToSpectateTarget = "§eClick to spectate {0}!" -- unused
                }
            }
        }
    }
})

local this = {
    PERMISSION = "!.staff.spec",

    ---@type bukkit.GameMode*
    RESTORE_GAMEMODE = "SURVIVAL"
}

-- uuid -> location
---@type java.Map<string, bukkit.Location>
local locations = makeMap()
this.locations = locations

events.onStarted(function()
    commands.add("spec", function(sender, args)
        ---@cast sender bukkit.entity.Player
        local playerId = bukkit.uuid(sender)
        local l = Lang.l(sender)

        local function turnOn(target)
            bukkit.setGameMode(sender, "SPECTATOR")

            if not locations.containsKey(playerId) then
                locations.put(playerId, sender.getLocation())

                local cmp = comp.text(l:t("pierrelasse/plugins/staff/spec/enabled"))
                    .hoverEvent(comp.hoverEvent("SHOW_TEXT", l:tc("pierrelasse/plugins/staff/spec/disableTTP")))
                    .clickEvent(comp.clickEvent("RUN_COMMAND", "/spec *off"))
                bukkit.send(sender, cmp)
            end

            if target ~= nil then
                bukkit.teleport(sender, target)
            end
        end

        local function turnOff()
            local loc = locations.get(playerId)
            if loc == nil then return end
            bukkit.teleport(sender, loc)
            locations.remove(playerId)
            bukkit.setGameMode(sender, this.RESTORE_GAMEMODE)
            Lang.send(sender, "pierrelasse/plugins/staff/spec/disabled")
        end

        local function toggle()
            if locations.containsKey(playerId) then
                turnOff()
            else
                turnOn(nil)
            end
        end

        if args[1] == nil then
            toggle()
            return
        end

        if args[1] == "*off" then
            turnOff()
            return
        end

        local target = bukkit.getPlayer(args[1])
        if target == nil or not sender.canSee(target) then
            Lang.send(sender, "generic/targetNotFound")
            return
        end

        turnOn(target)
    end)
        .permission(this.PERMISSION)
        .complete(function(completions, sender, args)
            ---@type string?
            local input
            if args[1] ~= nil then input = string.lower(args[1]) end
            for p in bukkit.playersLoop() do
                ---@type string
                local name = p.getName()
                if input == nil or name:lower():startsWith(input) and sender.canSee(p) then
                    completions.add(name)
                end
            end
        end)

    events.listen(PlayerQuitEvent, function(event)
        local player = event.getPlayer()
        local playerId = bukkit.uuid(player)

        local loc = locations.get(playerId)
        if loc == nil then return end

        player.teleport(loc)
        bukkit.setGameMode(player, this.RESTORE_GAMEMODE)
        locations.remove(playerId)
    end)
        .priority("LOW")

    events.onStopping(function()
        for playerId in forEach(locations.keySet()) do
            local player = bukkit.playerByUUID(playerId)
            if player ~= nil then
                local loc = locations.get(playerId)
                player.teleport(loc)
                bukkit.setGameMode(player, this.RESTORE_GAMEMODE)
            end
        end
    end)
end)

return this
