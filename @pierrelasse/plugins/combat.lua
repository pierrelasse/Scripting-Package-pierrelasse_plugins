local this = {
    TIMER = 20,

    ---@type fun(player: bukkit.entity.Player, timer: integer)
    DISPLAY_FUNC = function(player, timer)
        bukkit.sendActionBar(player, "§7Combat: §c"..timer)
    end
}

---@type java.Map<string, integer>
this.timers = java.map()

---@param player string|bukkit.entity.Player
function this.is(player)
    local playerId
    if type(player) == "string" then
        playerId = player
    else
        playerId = bukkit.uuid(player)
    end
    return this.timers.containsKey(playerId)
end

---@param player bukkit.entity.Player
---@param timerOverride? integer
function this.enter(player, timerOverride)
    local playerId = bukkit.uuid(player)

    local timer = timerOverride or this.TIMER
    this.timers.put(playerId, timer)

    this.DISPLAY_FUNC(player, timer)
end

---@param player bukkit.entity.Player
function this.exit(player)
    local playerId = bukkit.uuid(player)

    if not this.timers.containsKey(playerId) then return end
    this.timers.remove(playerId)

    this.DISPLAY_FUNC(player, 0)
end

---@param player bukkit.entity.Player
function this.getTimer(player)
    local playerId = bukkit.uuid(player)

    return this.timers.get(playerId) or 0
end

events.onStarted(function()
    tasks.every(20, function()
        local itr = this.timers.entrySet().iterator() ---@type java.Iterator<java.Map.Entry<string, integer>>
        while itr.hasNext() do
            local entry = itr.next()
            local pId = entry.getKey()
            local timer = entry.getValue() - 1

            if timer > 0 then
                entry.setValue(timer)
            else
                itr.remove()
            end

            local p = bukkit.playerByUUID(pId)
            if p ~= nil then
                this.DISPLAY_FUNC(p, timer)
            end
        end
    end)
end)

return this
