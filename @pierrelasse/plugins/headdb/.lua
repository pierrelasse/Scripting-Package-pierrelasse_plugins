local sql = require("@pierrelasse/lib/sql/")


local DB_FILE = "bluept/scripting/@pierrelasse/plugins/headdb/data.db"
local db = sql.connect("jdbc:sqlite:"..DB_FILE)

---@class pierrelasse.plugins.headdb.Entry
---@field id integer
---@field name string
---@field texture string
---@field category string
---@field tags string
---@field collections string

local this = {
    COMMAND = "heads",
    PERMISSION = "headdb"
}

---@param query string
---@return pierrelasse.plugins.headdb.Entry[]
local function search(query)
    local results = {}
    local queryLower = query:lower()

    local rs

    if query:match("^#%d+$") then
        rs = db.query("SELECT id, name, texture, category, tags, collections FROM heads WHERE id = ?",
            { tonumber(query:sub(2)) })
    elseif query:sub(1, 1) == "@" then
        local tag = query:sub(2):lower()
        rs = db.query(
            "SELECT id, name, texture, category, tags, collections FROM heads WHERE lower(tags) LIKE ? ORDER BY name ASC",
            { "%"..tag.."%" })
    elseif query:sub(1, 1) == "$" then
        local collection = query:sub(2):lower()
        rs = db.query(
            "SELECT id, name, texture, category, tags, collections FROM heads WHERE lower(collections) LIKE ? ORDER BY name ASC",
            { "%"..collection.."%" })
    else
        rs = db.query(
            "SELECT id, name, texture, category, tags, collections FROM heads WHERE lower(name) LIKE ? ORDER BY name ASC",
            { "%"..queryLower.."%" })
    end

    while rs.next() do
        table.insert(results, {
            id = rs.getInt("id"),
            name = rs.getString("name"),
            texture = rs.getString("texture"),
            category = rs.getString("category"),
            tags = rs.getString("tags"),
            collections = rs.getString("collections"),
        })
    end

    return results
end

---@param player bukkit.entity.Player
---@param query string
---@param results pierrelasse.plugins.headdb.Entry[]
local function open(player, query, results)
    local items_per_page = (8 - 2 + 1) * (5 - 2 + 1) -- columns 2-8, rows 2-5
    local page = 1

    local function open_page()
        local idx = (page - 1) * items_per_page + 1
        local screen = bukkit.guimaker.Screen.new("Heads ("..query..")", 6)

        for column = 2, 8 do
            for row = 2, 5 do
                local entry = results[idx]
                if entry == nil then
                    goto all_listed
                end

                screen:button(
                    screen:slot(row, column),
                    bukkit.buildItem("PLAYER_HEAD")
                    :playerHead_texture(entry.texture)
                    :displayName("§d"..entry.name)
                    :lore({
                        "§8#"..entry.id,
                        "§7Category: §f"..entry.category,
                        "§7Tags: §f"..arrays.concat(entry.tags:split(","), "§8, §f"),
                        "§7Collections: §f"..arrays.concat(entry.collections:split(","), "§8, §f"),
                        " ",
                        "§eClick to pick!"
                    })
                    :build(),
                    function()
                        local item = bukkit.buildItem("PLAYER_HEAD")
                            :playerHead_texture(entry.texture)
                            :displayName("§d"..entry.name)
                            :lore({
                                "§8#"..entry.id,
                                "§7Category: §f"..entry.category,
                                "§7Tags: §f"..arrays.concat(entry.tags:split(","), "§8, §f"),
                                "§7Collections: §f"..arrays.concat(entry.collections:split(","), "§8, §f")
                            })
                            :build()
                        bukkit.addItem(player, item)
                    end
                )

                idx = idx + 1
            end
        end

        ::all_listed::

        if #results > page * items_per_page then
            screen:button(
                screen:slot(6, 9),
                bukkit.buildItem("ARROW")
                :displayName("§aNext page §7("..page.."/"..math.ceil(#results / items_per_page)..")")
                :build(),
                function()
                    page = page + 1
                    open_page()
                end
            )
        end

        if page > 1 then
            screen:button(
                screen:slot(6, 1),
                bukkit.buildItem("ARROW")
                :displayName("§aPrevious page §7("..page.."/"..math.ceil(#results / items_per_page)..")")
                :build(),
                function()
                    page = page - 1
                    open_page()
                end
            )
        end

        screen:button(
            screen:slot(6, 5),
            bukkit.buildItem("BARRIER")
            :displayName("§cClose")
            :build(),
            function()
                screen:close(player)
            end
        )

        screen:open(player)
    end

    open_page()
end

events.onStarted(function()
    commands.add(this.COMMAND, function(sender, args)
        ---@cast sender bukkit.entity.Player

        if #args == 0 then
            bukkit.send(sender, [[§cMissing query. Use one of the following formats:
§8 - §7Search by name§8: §f<query>
§8 - §7Search by ID§8: §f#<id>
§8 - §7Search by collection§8: §f$<tag>
§8 - §7Search by tags§8: §f@<tag>]])
            return
        end

        local query = table.concat(args, " ")

        bukkit.send(sender, "§7Querying for heads with §f'"..query.."'")

        local results = search(query)

        if #results == 0 then
            bukkit.send(sender, "§cNo matching heads found.")
            return
        end

        open(sender, query, results)
    end)
        .permission(this.PERMISSION)
        .complete(function(completions, sender, args)
            if #args == 1 then
                if #args[1] == 0 then
                    completions.add("<query>")
                    completions.add("#<id>")
                    completions.add("$<collection>")
                    completions.add("@<tag>")
                else
                    completions.add(args[1])
                end
            end
        end)
end)

return this
