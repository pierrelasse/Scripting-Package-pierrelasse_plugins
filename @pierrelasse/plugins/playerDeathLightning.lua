local PlayerDeathEvent = import("org.bukkit.event.entity.PlayerDeathEvent")


events.onStarted(function()
    events.listen(PlayerDeathEvent, function(event)
        local player = event.getPlayer() ---@type bukkit.entity.Player
        local location = player.getLocation()

        bukkit.spawnLightning(location, false)
    end)
end)
