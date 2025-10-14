local Display_Billboard = import("org.bukkit.entity.Display$Billboard")
local Transformation = import("org.bukkit.util.Transformation")
local AxisAngle4f = import("org.joml.AxisAngle4f")
local Vector3f = import("org.joml.Vector3f")


Lang.get("en"):put({
    pierrelasse = {
        plugins = {
            staff = {
                displayer = {
                    enabled = "{0}§a display enabled",
                    disabled = "{0}§a display disabled"
                }
            }
        }
    }
})

Lang.get("de"):put({
    pierrelasse = {
        plugins = {
            staff = {
                displayer = {
                    enabled = "{0}§a Anzeige aktiviert",
                    disabled = "{0}§a Anzeige deaktiviert"
                }
            }
        }
    }
})

local this = {
    PERMISSION_PREFIX = "!.staff.display."
}

---@type table<string, {
--- command: string;
--- text: adventure.text.Component;
---}>
this.DISPLAYS = {
    admin = {
        command = "admindisplay",
        text = comp.mm("<#FE122E><b><u>ADMINISTRATION")
    },
    mod = {
        command = "moddisplay",
        text = comp.mm("<#12B024><b><u>MODERATION")
    }
}

events.onStarted(function()
    for id, data in pairs(this.DISPLAYS) do
        ---@type java.Map<bukkit.entity.Player, java.array<bukkit.entity.TextDisplay>>
        local players = java.map()

        commands.add(data.command, function(sender, args) ---@cast sender bukkit.entity.Player
            if players.remove(sender) ~= nil then
                Lang.sendF(sender, "pierrelasse/plugins/staff/displayer/disabled", comp.empty().append(data.text))
                return
            end

            local active = true

            ---@type java.array<bukkit.entity.TextDisplay>
            local entities = java.array(nil, 6)
            players.put(sender, entities)

            local legacyText = comp.legacySerialize(data.text)

            local function spawnDisplay()
                local entity = bukkit.spawn(
                    sender.getLocation()
                    .add(
                        random:float(-1, 1),
                        -.5,
                        random:float(-1, 1)
                    ),
                    "TEXT_DISPLAY"
                ) ---@cast entity bukkit.entity.TextDisplay
                entity.addScoreboardTag("temp")
                entity.addScoreboardTag("staffdisplay")
                entity.setBillboard(Display_Billboard.CENTER)
                entity.setText(legacyText)

                entity.setInterpolationDelay(-1)
                entity.setInterpolationDuration(40)

                tasks.wait(1, function()
                    entity.setTransformation(Transformation(
                        Vector3f(0, 3, 0), -- transformation
                        AxisAngle4f(),     -- left rotation
                        Vector3f(1),       -- scale
                        AxisAngle4f()      -- right rotation
                    ))
                end)

                return entity
            end

            for idx = 1, 6 do
                local tick = random:integer(1, 40)
                tasks.every(1, function(task)
                    if not active then
                        task.cancel()
                        return
                    end

                    tick = tick - 1
                    if tick > 1 then return end
                    tick = random:integer(1, 40)

                    local prevEntity = entities[idx]
                    if prevEntity ~= nil then bukkit.deleteEntity(prevEntity) end
                    if sender.getGameMode().name() == "SPECTATOR" then -- TODO: vanish support?
                        entities[idx] = nil
                    else
                        local entity = spawnDisplay()
                        entities[idx] = entity
                    end
                end)
            end

            tasks.every(1, function(task)
                if not sender.isOnline() or players.get(sender) ~= entities then
                    active = false
                    task.cancel()

                    for ent in forEach(entities) do
                        bukkit.deleteEntity(ent)
                    end
                end
            end)

            Lang.sendF(sender, "pierrelasse/plugins/staff/displayer/enabled", comp.empty().append(data.text))
        end)
            .permission(this.PERMISSION_PREFIX..id)

        events.onStopping(function()
            for list in forEach(players.values()) do
                for ent in forEach(list) do
                    bukkit.deleteEntity(ent)
                end
            end
        end)
    end
end)

return this
