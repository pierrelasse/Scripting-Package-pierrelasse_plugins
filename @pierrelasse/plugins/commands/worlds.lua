local fs = require("@base/fs")
local complete = require("@pierrelasse/lib/complete")


-- TODO incomplete
Lang.get("en"):put({
    pierrelasse = {
        plugins = {
            commands = {
                worlds = {
                    invalidName = comp.mm("<red>Invalid world name!"),
                    directoryOccupied = comp.mm("<red>Directory occupied. Use a different name!"),
                    errorCopy = comp.mm("<red>Copy failed <gray>{0}"),
                    errorLoad = comp.mm("<red>Loading world failed <gray>{0}"),
                }
            }
        }
    }
})

local this = {
    COMMAND = "worlds",
    PERMISSION = "commands.worlds"
}

events.onStarted(function()
    commands.add(this.COMMAND, function(sender, args)
        if #args == 0 then
            local worlds = bukkit.worlds().toArray()
            arrays.sort(worlds, function(a, b) return a.getName() < b.getName() end)

            local cmp = comp.mm("Worlds:")

            for world in forEach(worlds) do
                cmp = cmp
                    .appendNewline()
                    .append(comp.text(" - ").color(comp.colorN("dark_gray")))
                    .append(comp.text(world.getName()))
                    .appendSpace()
                    .append(comp.text("[TP]"))
            end

            bukkit.send(sender, cmp)
            return
        end

        local worldName = args[1]
        if not bukkit.isValidWorldName(worldName) then
            Lang.message(sender, "pierrelasse/plugins/commands/worlds/invalidName")
            return
        end
        local world = bukkit.world(worldName)

        if args[2] == "clone" then
            local targetName = args[3]
            if targetName == nil or not bukkit.isValidWorldName(targetName) then
                Lang.message(sender, "pierrelasse/plugins/commands/worlds/invalidName")
                return
            end
            local targetPath = fs.file(".", targetName)
            if targetPath.exists() then
                Lang.message(sender, "pierrelasse/plugins/commands/worlds/directoryOccupied")
                return
            end

            local worldPath = fs.file(".", worldName)

            local err = fs.copy(worldPath, targetPath, true)
            if err ~= nil then
                Lang.messageF(sender, "pierrelasse/plugins/commands/worlds/copyFailed", tostring(err))
                return
            end

            local uidDat = fs.file(targetPath, "uid.dat")
            if uidDat.isFile() then uidDat.delete() end

            local sessionLock = fs.file(targetPath, "session.lock")
            if sessionLock.isFile() then sessionLock.delete() end

            local creator = bukkit.worldManager.create(targetName)
            -- TODO
            local targetWorld = creator:create()
            if targetWorld == nil then
                Lang.message(sender, "pierrelasse/plugins/commands/worlds/errorLoad")
                return
            end

            bukkit.send(sender, comp.text("World "..worldName.." cloned to "..targetName)
                .appendSpace()
                .append(comp.text("[TP]").color(comp.colorN("green"))
                    .clickEvent(comp.clickEvent("RUN_COMMAND", "/worlds "..targetName.." tp"))
                    .insertion("/worlds "..targetName.." "))
            )

            return
        end

        if world == nil then
            local worldPath = fs.file(".", worldName)
            local levelDat = fs.file(worldPath, "level.dat")

            local isValidWorldDir = levelDat.isFile()

            if args[2] == nil then
                if isValidWorldDir then
                    bukkit.send(sender, "World found! Use load to load it")
                else
                    bukkit.send(sender, "§cWorld not found! Use create to create it")
                end

                return
            end

            if args[2] == "create" then
                if not worldPath.exists() then
                    if not worldPath.mkdirs() then
                        bukkit.send(sender, "§cCould not create world! §7(DIRECTORY_CREATION_FAILED)")
                        return
                    end
                elseif not worldPath.isDirectory() then
                    bukkit.send(sender, "§cCould not create world! §7(NOT_A_DIRECTORY)")
                    return
                else
                    if #worldPath.list() ~= 0 then
                        if levelDat.isFile() then
                            bukkit.send(sender, "§cDirectory already contains a world! Use load instead")
                            return
                        end

                        if not fs.file(worldPath, "region").isDirectory() then
                            bukkit.send(sender, "§cCould not verify that this directory contains a world!")
                            return
                        end
                    end
                end

                bukkit.send(sender, "§7Creating world... (this can lag)")

                local creator = bukkit.worldManager.create(worldName)
                world = creator:create()
                if world == nil then
                    bukkit.send(sender, "§cWorld creation failed!")
                    return
                end

                bukkit.send(sender, comp.text("World "..worldName.." created!")
                    .appendSpace()
                    .append(comp.text("[TP]").color(comp.colorN("green"))
                        .clickEvent(comp.clickEvent("RUN_COMMAND", "/worlds "..worldName.." tp"))
                        .insertion("/worlds "..worldName.." "))
                )

                return
            end

            if args[2] == "delete" then
                if not isValidWorldDir then
                    bukkit.send(sender, "§cCould not delete world! §7(NOT_A_WORLD_DIRECTORY)")
                    return
                end

                if not fs.remove(worldPath) then
                    bukkit.send(sender, "§cCould not delete world! §7(DELETION_FAILED)")
                    return
                end

                bukkit.send(sender, "World "..worldName.." deleted")

                return
            end

            if args[2] == "load" then
                if not isValidWorldDir then
                    bukkit.send(sender, "§cNot a valid world! Use create instead")
                    return
                end

                local creator = bukkit.worldManager.create(worldName)
                world = creator:create()
                if world == nil then
                    bukkit.send(sender, "§cCould not load world!")
                    return
                end

                bukkit.send(sender, comp.text("World "..worldName.." loaded")
                    .appendSpace()
                    .append(comp.text("[TP]").color(comp.colorN("green"))
                        .clickEvent(comp.clickEvent("RUN_COMMAND", "/worlds "..worldName.." tp"))
                        .insertion("/worlds "..worldName.." "))
                )

                return
            end

            bukkit.send(sender, "§cUsage: /worlds <name> <create|delete|load> ...")
        else
            if world.getName() ~= worldName then
                bukkit.send(sender, "§cA world with different capitalization already exists: "..world.getName())
                return
            end

            if args[2] == nil then
                bukkit.send(sender, "world info...") -- TODO
                return
            end

            if args[2] == "unload" then
                if world == bukkit.baseWorld then
                    bukkit.send(sender, "§cThis world can't be unloaded as it's the base world. "..
                        "It stores things such as player-data")
                    return
                end

                if not world.getPlayers().isEmpty() then
                    bukkit.send(sender, "§cCouldn't unload the world as player(s) are still in it!")
                    return
                end

                if bukkit.worldManager.unloadWorld(world, args[3] ~= "nosave") ~= true then
                    bukkit.send(sender, "§cWorld unload failed!")
                    return
                end

                bukkit.send(sender, "World "..worldName.." unloaded")

                return
            end

            if not bukkit.isPlayer(sender) then return end ---@cast sender bukkit.entity.Player

            if args[2] == "tp" then
                local location
                if args[3] == nil then
                    local spawnLocation = world.getSpawnLocation()
                    location = bukkit.location6(
                        world,
                        spawnLocation.x() + .5, world.getHighestBlockYAt(spawnLocation) + 1, spawnLocation.z() + .5,
                        0, 0
                    )
                elseif args[3] == "current" then
                    if world == sender.getWorld() then return end
                    local currentLoc = sender.getLocation()
                    location = bukkit.location6(
                        world,
                        currentLoc.x(), currentLoc.y(), currentLoc.z(),
                        currentLoc.getYaw(), currentLoc.getPitch()
                    )
                else
                    return
                end

                bukkit.teleport(sender, location)

                return
            end

            bukkit.send(sender, "§cUsage: /worlds <name> <tp|unload|clone> ...")
        end
    end)
        .permission(this.PERMISSION)
        .complete(function(completions, sender, args)
            if #args == 1 then
                complete(completions, args[1],
                    forEach(bukkit.Bukkit.getWorlds()), function(i) return i.getName() end)
                return
            end

            if not bukkit.isValidWorldName(args[1]) then return end

            local world = bukkit.world(args[1]) -- TODO

            if #args == 2 then
                if world == nil then
                    complete(completions, args[2], { "clone", "create", "delete", "load" })
                else
                    complete(completions, args[2], { "clone", "tp", "unload" })
                end
            end

            if #args == 3 then
                if world == nil then return end

                if args[2] == "tp" then
                    complete(completions, args[3], { "current" })
                elseif args[2] == "unload" then
                    complete(completions, args[3], { "nosave" })
                end
            end
        end)
end)

return this
