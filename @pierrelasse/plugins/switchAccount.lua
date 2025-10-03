local AsyncPlayerPreLoginEvent = import("org.bukkit.event.player.AsyncPlayerPreLoginEvent")
local CraftPlayerProfile = importOrNil("com.destroystokyo.paper.profile.CraftPlayerProfile")

local complete = require("@pierrelasse/lib/complete")
local profileResolver = require("@pierrelasse/lib/profileResolver")


local this = {
    COMMAND = "switchaccount",
    PERMISSION = "switchaccount"
}

---@type java.Map<string, java.Object>
this.map = java.map()

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

        local target = bukkit.player(args[2] or sender.getName())
        if target == nil then
            bukkit.send(sender, "§cPlayer not found!")
            return
        end


        local function set(profile)
            local playerProfile = CraftPlayerProfile(
                profile.uuid,
                profile.name
            )

            this.map.put(target.getName(), playerProfile)

            bukkit.send(sender, "§2"..target.getName().."§a will now log in as §2"..profile.name.."§a the next time!")
        end

        local offlinePlayer = bukkit.offlinePlayer(name)
        if offlinePlayer ~= nil then
            set({ uuid = offlinePlayer.getUniqueId(), name = offlinePlayer.getName() })
            return
        end

        bukkit.send(sender, "§7Resolving...")
        tasks.async(function()
            local result, err = profileResolver.fetch(name)
            tasks.wait(0, function()
                if result == nil then
                    bukkit.send(sender, "§cCould not fetch UUID! §7("..err..")")
                    return
                end
                set(result)
            end)
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
                complete(completions, args[1],
                    bukkit.playersLoop(), function(i)
                        ---@cast i bukkit.entity.Player
                        return i.getName()
                    end)
            end
        end)

    events.listen(AsyncPlayerPreLoginEvent, function(event)
        local name = event.getName() ---@type string

        local changeTo = this.map.remove(name)
        if changeTo == nil then return end

        event.setPlayerProfile(changeTo)
    end)
        .priority("LOWEST")
end)

return this
