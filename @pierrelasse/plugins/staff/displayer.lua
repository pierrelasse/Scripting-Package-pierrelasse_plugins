local Display_Billboard = import("org.bukkit.entity.Display$Billboard")
local Transformation = import("org.bukkit.util.Transformation")
local AxisAngle4f = import("org.joml.AxisAngle4f")
local Vector3f = import("org.joml.Vector3f")


Lang.get("en"):put({
    pierrelasse = {
        plugins = {
            staff = {
                displayer = {
                    enabled = "§aDisplay enabled",
                    disabled = "§aDisplay disabled"
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
--- text: string;
--- actives?: java.Set<bukkit.entity.Player>;
---}>
this.DISPLAYS = {
    admin = {
        command = "admindisplay",
        text = "§#FE122E§l§nADMINISTRATION"
    },
    mod = {
        command = "moddisplay",
        text = "§#12B024§l§nMODERATION"
    }
}

---@type java.List<bukkit.entity.TextDisplay>
this.entities = makeList()

events.onStarted(function()
    for id, data in pairs(this.DISPLAYS) do
        ---@type java.Set<bukkit.entity.Player>
        local actives = makeSet()
        data.actives = actives

        commands.add(data.command, function(sender, args)
            ---@cast sender bukkit.entity.Player

            if data.actives.contains(sender) then
                data.actives.remove(sender)
                Lang.send(sender, "pierrelasse/plugins/staff/displayer/disabled")
                return
            end
            data.actives.add(sender)

            local function doSpawn()
                local entity = bukkit.spawn(
                    sender.getLocation()
                    .add(
                        math.random(-1, 1),
                        -.5,
                        math.random(-1, 1)
                    ),
                    "TEXT_DISPLAY"
                )
                ---@cast entity bukkit.entity.TextDisplay
                entity.addScoreboardTag("temp")
                entity.addScoreboardTag("staffdisplay")
                entity.setBillboard(Display_Billboard.VERTICAL)
                entity.setText(bukkit.hex(data.text))

                this.entities.add(entity)

                tasks.wait(1, function()
                    entity.setInterpolationDelay(-1)
                    entity.setInterpolationDuration(40)
                    entity.setTransformation(Transformation(
                        Vector3f(0, 3, 0), -- transformation
                        AxisAngle4f(),     -- left rotation
                        Vector3f(1),       -- scale
                        AxisAngle4f()      -- right rotation
                    ))
                end)

                return entity
            end

            local function launch()
                local offset = 0
                local entity = doSpawn()

                local function run()
                    offset = offset + 1

                    if offset > 40
                    or not actives.contains(sender)
                    or not sender.isOnline() then
                        this.entities.remove(entity)
                        bukkit.deleteEntity(entity)
                        if actives.contains(sender) then
                            tasks.wait(1, launch)
                        end
                        return
                    end
                    tasks.wait(1, run)
                end

                tasks.wait(1, run)
            end

            for _ = 1, 6 do
                tasks.wait(math.random(1, 15), launch)
            end

            Lang.send(sender, "pierrelasse/plugins/staff/displayer/enabled")
        end)
            .permission(this.PERMISSION_PREFIX..id)
    end

    events.onStopping(function()
        for ent in forEach(this.entities) do
            bukkit.deleteEntity(ent)
        end
    end)
end)

return this
