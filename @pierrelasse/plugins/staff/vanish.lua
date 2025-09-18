local PlayerJoinEvent = import("org.bukkit.event.player.PlayerJoinEvent")


Lang.get("en"):put({
    pierrelasse = {
        plugins = {
            staff = {
                vanish = {
                    enabled = "§aVanish enabled!",
                    enabledLvl = "§aVanish enabled (lvl {0})",
                    alreadyEnabled = "§cVanish is already enabled!",
                    disabled = "§aVanish disabled!",
                    alreadyDisabled = "§cVanish is already disabled!",
                    invalidLevel = "§cInvalid level!",
                    noLevelAccess = "§cYou don't have access to this level!"
                }
            }
        }
    }
})

local this = {
    HIGHEST_LEVEL = 9,
    UPDATE_INTERVAL = 20 * 10,
    PERMISSION = "!.staff.vanish",
    COMMAND = { "vanish", "v" }
}

this.storage = bukkit.Storage.new("pierrelasse", "vanish")
this.storage:loadSave()

---@param playerId string
function this.getLevel(playerId)
    return this.storage:get("states."..playerId, 0)
end

---@param playerId string
---@param level integer
function this.setLevel(playerId, level)
    this.storage:set("states."..playerId, level ~= 0 and level or nil)
end

---@param playerId string
function this.isActive(playerId)
    return this.getLevel(playerId) > 0
end

---@deprecated
---@param player bukkit.entity.Player
function this.getLVL(player)
    scripting.warningDeprecated("pierrelasse/plugins/staff/vanish#getLVL")
    return this.getLevel(bukkit.uuid(player))
end

---@param player bukkit.entity.Player
function this.getHighestLevel(player)
    local level = 0
    for i = 1, this.HIGHEST_LEVEL do
        if player.hasPermission(this.PERMISSION..".level"..i) then
            level = i
        end
    end
    return level
end

---@package
---@param highestLevel integer
---@param level? number
---@return boolean
function this.canSee(highestLevel, level)
    return level == nil or highestLevel >= level
end

---@param otherPlayer bukkit.entity.Player
---@param highestLevel integer
---@param player bukkit.entity.Player
---@param level? integer
function this.updateSee(otherPlayer, highestLevel, player, level)
    if this.canSee(highestLevel, level) then
        otherPlayer.showPlayer(bukkit.platform, player)
    else
        otherPlayer.hidePlayer(bukkit.platform, player)
    end
end

---@param player bukkit.entity.Player
function this.updateSees(player)
    local playerId = bukkit.uuid(player)
    local level = this.getLevel(playerId)
    for p in bukkit.playersLoop() do
        this.updateSee(p, this.getHighestLevel(p), player, level)
    end
end

events.onStarted(function()
    events.listen(PlayerJoinEvent, function(event)
        local player = event.getPlayer() ---@type bukkit.entity.Player
        local highestLevel = this.getHighestLevel(player)

        for p in bukkit.playersLoop() do
            p.hidePlayer(bukkit.platform, player)

            this.updateSee(player, highestLevel, p, this.getLevel(bukkit.uuid(p)))
        end

        tasks.wait(1, function()
            this.updateSees(player)
        end)
    end)

    commands.add(this.COMMAND, function(sender, args)
        ---@cast sender bukkit.entity.Player

        local playerId = bukkit.uuid(sender)
        local currentLevel = this.getLevel(playerId)

        if (args[1] == nil and currentLevel > 0) or args[1] == "0" then
            if currentLevel == 0 then
                Lang.send(sender, "pierrelasse/plugins/staff/vanish/alreadyDisabled")
                return
            end

            this.setLevel(playerId, 0)

            this.updateSees(sender)
            Lang.send(sender, "pierrelasse/plugins/staff/vanish/disabled")
            return
        end

        local level
        if args[1] == nil then
            level = 1
        else
            level = tonumber(args[1], 10)
            if level == nil then
                Lang.send(sender, "pierrelasse/plugins/staff/vanish/invalidLevel")
                return
            end
        end

        if level > this.getHighestLevel(sender) then
            Lang.send(sender, "pierrelasse/plugins/staff/vanish/noLevelAccess")
            return
        end

        if currentLevel == level then
            Lang.send(sender, "pierrelasse/plugins/staff/vanish/alreadyEnabled")
            return
        end

        this.setLevel(playerId, level)
        this.updateSees(sender)

        if level == 1 then
            Lang.send(sender, "pierrelasse/plugins/staff/vanish/enabled")
        else
            Lang.sendF(sender, "pierrelasse/plugins/staff/vanish/enabledLvl", level)
        end
    end)
        .permission(this.PERMISSION)

    tasks.every(this.UPDATE_INTERVAL, function()
        for p in bukkit.playersLoop() do
            local pId = bukkit.uuid(p)

            local level = this.getLevel(pId)
            local highest = this.getHighestLevel(p)
            if level > highest then
                this.setLevel(pId, highest)
            end

            this.updateSees(p)
        end
    end)

    tasks.wait(0, function()
        for p in bukkit.playersLoop() do
            this.updateSees(p)
        end
    end)
end)

return this
