local PlayerQuitEvent = import("org.bukkit.event.player.PlayerQuitEvent")
local BlockPlaceEvent = import("org.bukkit.event.block.BlockPlaceEvent")
local BlockBreakEvent = import("org.bukkit.event.block.BlockBreakEvent")


Lang.get("en"):put({
    pierrelasse = {
        plugins = {
            staff = {
                void = {
                    world = {
                        load = "§8Loading world",
                        error = "§cError loading world"
                    },
                    teleporting = "§7Teleporting",
                    teleported = "§2{0}§a was teleported §7(from {1})",
                    teleportingBack = "§aTeleporting §2{0}§a back",
                    mustBeInVoidWorld = "§cYou have to be in the void world!"
                }
            }
        }
    }
})

local this = {
    WORLD_NAME = "void",

    PERMISSION = "!.staff.void",

    COMMAND = "void",

    ALLOW_BLOCK_MODIFICATION = false
}

---@type bukkit.World?
this.world = nil

---@type bukkit.Location
this.fallbackLocation = nil

---uuid -> location
---@type java.Map<string, bukkit.Location>
this.locations = java.map()

events.onStarted(function()
    this.world = bukkit.world(this.WORLD_NAME)

    commands.add(this.COMMAND, function(sender, args)
        if this.world == nil then
            Lang.send(sender, "pierrelasse/plugins/staff/void/world/load")

            local creator = bukkit.worldManager.create(this.WORLD_NAME)
            creator:setupVoid()
            local world = creator:create()
            if world == nil then
                Lang.send(sender, "pierrelasse/plugins/staff/void/world/error")
                return
            end
            this.world = world
        end

        if args[1] == nil then
            Lang.send(sender, "pierrelasse/plugins/staff/void/teleporting")
            sender.teleport(this.world.getSpawnLocation())
        else
            local target = bukkit.getPlayer(args[1])
            if target == nil then
                Lang.send(sender, "generic/targetNotFound")
                return
            end
            local targetId = bukkit.uuid(target)

            local isTargetInWorld = target.getWorld() == this.world
            if isTargetInWorld then
                Lang.sendF(sender, "pierrelasse/plugins/staff/void/teleportingBack", target.getName())
                bukkit.teleport(target, this.locations.get(targetId))
                this.locations.remove(targetId)
            else
                if sender.getWorld() ~= this.world then
                    Lang.send(sender, "pierrelasse/plugins/staff/void/mustBeInVoidWorld")
                    return
                end

                local prevLoc = target.getLocation()
                this.locations.put(targetId, prevLoc)
                bukkit.teleport(target, sender.getLocation())

                Lang.sendF(
                    sender, "pierrelasse/plugins/staff/void/teleporting",
                    target.getName(),
                    (prevLoc.getWorld().getName()..","..prevLoc.getX()..","..prevLoc.getY()..","..prevLoc.getZ()))
            end
        end
    end)
        .complete(function(completions, sender, args)
            if #args == 1 then
                -- TODO
                ---@type string?
                local input
                if args[1] ~= nil then input = string.lower(args[1]) end
                for player in bukkit.playersLoop() do
                    ---@type string
                    local name = player.getName()
                    if input == nil or name:lower():startsWith(input) and sender.canSee(player) then
                        completions.add(name)
                    end
                end
            elseif #args == 2 then
                completions.add("back")
            end
        end)
        .permission(this.PERMISSION)

    events.onStopping(function()
        for playerId in forEach(this.locations.keySet()) do
            local player = bukkit.playerByUUID(playerId)
            if player ~= nil then
                local loc = this.locations.get(playerId)
                player.teleport(loc)
            end
        end
    end)

    events.listen(PlayerQuitEvent, function(event)
        local player = event.getPlayer()
        local playerId = bukkit.uuid(player)
        if this.locations.containsKey(playerId) then
            player.teleport(this.locations.get(playerId))
            this.locations.remove(playerId)
            for p in bukkit.playersLoop() do
                if p.hasPermission(this.PERMISSION) then
                    -- TODO
                    bukkit.send(p, "§4"..player.getName().."§c hat den Server verlassen")
                end
            end
        end
    end)

    if not this.ALLOW_BLOCK_MODIFICATION then
        events.listen(BlockPlaceEvent, function(event)
            local block = event.getBlock()
            if block.getWorld() ~= this.world then return end
            if bukkit.isInCreativeOrSpec(event.getPlayer()) then return end
            event.setCancelled(true)
        end)

        events.listen(BlockBreakEvent, function(event)
            local block = event.getBlock()
            if block.getWorld() ~= this.world then return end
            if bukkit.isInCreativeOrSpec(event.getPlayer()) then return end
            event.setCancelled(true)
        end)
    end
end)

return this
