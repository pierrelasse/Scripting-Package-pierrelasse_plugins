local EntityDamageEvent = import("org.bukkit.event.entity.EntityDamageEvent")
local EntityDamageByEntityEvent = import("org.bukkit.event.entity.EntityDamageByEntityEvent")
local PlayerQuitEvent = import("org.bukkit.event.player.PlayerQuitEvent")

local combat = require("@pierrelasse/plugins/combat")


local this = {
    ---@type fun(player: bukkit.entity.Player)
    ON_LOGOUT = function(player)
        -- player.setHealth(0) -- TODO
    end,

    ---@type fun(victim: bukkit.entity.Player, attacker): boolean, boolean
    CAN_ENTER_COMBAT = function(victim, attacker)
        return true, not bukkit.isInCreativeOrSpec(attacker)
    end,

    ---@type fun(player: bukkit.entity.Player): boolean
    ON_DEATH = function(player)
        return true
    end
}

events.onStarted(function()
    events.listen(EntityDamageEvent, function(event)
        local player = event.getEntity() ---@type bukkit.entity.Player
        if not bukkit.isPlayer(player) then return end

        local finalDamage = event.getFinalDamage() ---@type java.float
        if not (finalDamage > 0) then return end

        if instanceof(event, EntityDamageByEntityEvent) then
            local attacker = event.getDamager() ---@type bukkit.entity.Player
            if not bukkit.isPlayer(attacker) then return end

            local enterVictim, enterAttacker = this.CAN_ENTER_COMBAT(player)
            if enterVictim then combat.enter(player) end
            if enterAttacker then combat.enter(attacker) end
        end

        if finalDamage >= player.getHealth() then
            if this.ON_DEATH(player) == true then
                combat.exit(player)
            end
        end
    end)
        .priority("HIGHEST")

    events.listen(PlayerQuitEvent, function(event)
        local player = event.getPlayer() ---@type bukkit.entity.Player

        local timer = combat.getTimer(player)
        combat.exit(player)

        if timer > 0 then
            this.ON_LOGOUT(player)
        end
    end)
end)

return this
