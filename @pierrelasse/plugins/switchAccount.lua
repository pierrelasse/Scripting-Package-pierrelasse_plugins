local AsyncPlayerPreLoginEvent = import("org.bukkit.event.player.AsyncPlayerPreLoginEvent")
local CraftPlayerProfile = importOrNil("com.destroystokyo.paper.profile.CraftPlayerProfile")

local complete = require("@pierrelasse/lib/complete")
local profileResolver = require("@pierrelasse/lib/profileResolver")


local this = {
    COMMAND = "switchaccount",
    PERMISSION = "switchaccount",
    ALLOW_PERSISTENT = true
}

---@type java.Map<string, java.Object>
this.map = java.map()
---@type java.Set<string>
this.persistent = java.set()

events.onStarted(function()
    commands.add(this.COMMAND, function(sender, args)
        if CraftPlayerProfile == nil then
            bukkit.send(sender, "§cNot available!")
            return
        end

        if args[1] == nil then
            bukkit.send(sender, "§cPlease provide a target name!")
            return
        end

        local name = args[1]
        if not profileResolver.isValidPlayerName(name) then
            bukkit.send(sender, "§cInvalid target name!")
            return
        end

        local persistent = false

        local target
        if args[2] == nil then
            target = sender
        else
            if args[2] == "-p" then
                target = sender
                persistent = true
            else
                target = bukkit.offlinePlayer(args[2])
                if target == nil then
                    bukkit.send(sender, "§cPlayer not found!")
                    return
                end
            end
        end

        if args[3] == "-p" then
            persistent = true
        end

        if this.persistent.remove(target.getName()) then
            bukkit.send(sender, "§2"..target.getName().."§a is no longer marked as persistent!")
            return
        end

        if not target.isOnline() then
            bukkit.send(sender, "§cPlayer not found!")
            return
        end

        local function set(profile)
            local playerProfile = CraftPlayerProfile(
                profile.uuid,
                profile.name
            )

            this.map.put(target.getName(), playerProfile)
            if persistent and this.ALLOW_PERSISTENT then
                this.persistent.add(target.getName())
            end

            bukkit.send(sender, "§2"..target.getName().."§a will now log in as §2"..profile.name.."§a the next time!")
        end

        tasks.async(function()
            local result

            local offlinePlayer = bukkit.offlinePlayer(name)
            if offlinePlayer ~= nil then
                result = { uuid = offlinePlayer.getUniqueId(), name = offlinePlayer.getName() }
            else
                local _result, err = profileResolver.fetch(name)
                if _result == nil then
                    bukkit.send(sender, "§cCould not fetch profile! §7("..err..")")
                    return
                end
                result = _result
            end

            tasks.wait(0, function() set(result) end)
        end)
    end)
        .permission(this.PERMISSION)
        .complete(function(completions, sender, args)
            if #args == 1 then
                complete(completions, args[1],
                    bukkit.offlinePlayersLoop(), function(i)
                        ---@cast i bukkit.OfflinePlayer
                        return i.getName()
                    end)
            elseif #args == 2 then
                complete(completions, args[2],
                    bukkit.playersLoop(), function(i)
                        ---@cast i bukkit.entity.Player
                        return i.getName()
                    end)
            elseif #args == 3 then
                complete(completions, args[2], { "-p" })
            end
        end)
end)

-- Make this listener execute as early as possible.
events.listen(AsyncPlayerPreLoginEvent, function(event)
    local name = event.getName() ---@type string

    local changeTo = this.map.get(name)
    if changeTo == nil then return end

    if not this.persistent.contains(name) then
        this.map.remove(name)
    end

    event.setPlayerProfile(changeTo)
end)
    .priority("LOWEST")

return this
