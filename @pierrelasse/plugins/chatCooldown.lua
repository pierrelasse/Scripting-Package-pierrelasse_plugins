local AsyncPlayerChatEvent = import("org.bukkit.event.player.AsyncPlayerChatEvent")

local SimpleCooldowns = require("@pierrelasse/lib/SimpleCooldowns")


Lang.get("en"):put({
    pierrelasse = {
        plugins = {
            chatCooldown = {
                cooldown = comp.mm("<red>Please wait before sending another message! <#b4453b>({0}s)"),
                highCooldownLog = "{0}'s cooldown is {1}s: {2}",
                tooQuicklyLog = "{0} sent another message within {1}s: {2}"
            }
        }
    }
})

Lang.get("de"):put({
    pierrelasse = {
        plugins = {
            chatCooldown = {
                cooldown = comp.mm("<red>Bitte warte bevor du eine weitere Nachricht sendest! <#b4453b>({0}s)")
            }
        }
    }
})

local this = {
    ---@param player bukkit.entity.Player
    ---@return number -- seconds
    COOLDOWN_INCREASE = function(player)
        return 1.5
    end,

    ---@param player bukkit.entity.Player
    ---@return number -- seconds
    COOLDOWN_THRESHOLD = function(player)
        return 1.8
    end,

    -- seconds
    REPORT_HIGH_COOLDOWN_AT = 5
}

this.log = require("@pierrelasse/plugins/staff/log"):sub("chat") -- TODO: canSee

this.cooldowns = SimpleCooldowns.new()

events.onStarted(function()
    events.listen(AsyncPlayerChatEvent, function(event)
        local player = event.getPlayer() ---@type bukkit.entity.Player

        local playerId = bukkit.uuid(player)

        if this.cooldowns:checkOrSet(playerId, "min", .15) then
            event.setCancelled(true)
            this.log:log(function(l)
                return l:tcf("pierrelasse/plugins/chatCooldown/tooQuicklyLog",
                    player.getName(), .15 - this.cooldowns:getRemaining(playerId, "min"), event.getMessage())
            end)
            return
        end

        local increase = this.COOLDOWN_INCREASE(player)
        local threshold = this.COOLDOWN_THRESHOLD(player)

        local remaining = this.cooldowns:getRemaining(playerId, "")

        if this.REPORT_HIGH_COOLDOWN_AT ~= nil and remaining >= this.REPORT_HIGH_COOLDOWN_AT then
            this.log:log(function(l, fmt)
                return l:tcf("pierrelasse/plugins/chatCooldown/highCooldownLog",
                    fmt:player(player), remaining, event.getMessage())
            end)
        end

        if not this.cooldowns:checkAndAdd(playerId, "", increase, threshold) then return end

        event.setCancelled(true)

        Lang.messageF(player, "pierrelasse/plugins/chatCooldown/cooldown",
            numbers.round(this.cooldowns:getRemaining(playerId, ""), 1))
    end)
        .priority("LOW")
end)

return this
