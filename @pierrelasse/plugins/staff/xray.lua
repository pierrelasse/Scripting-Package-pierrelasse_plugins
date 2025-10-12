local ArrayDeque = import("java.util.ArrayDeque")
local BlockBreakEvent = import("org.bukkit.event.block.BlockBreakEvent")


Lang.get("en"):put({
    pierrelasse = {
        plugins = {
            staff = {
                xray = {
                    notify_name = "§#B6DCF2{0}",              -- TODO
                    notify_found = "§#DADF91 found x{0} {1}", -- TODO
                    clickToSpectate = "§eClick to spectate this player!"
                }
            }
        }
    }
})

local this = {
    PERMISSION = "!.staff.xray",

    MONITORED_BLOCKS = java.setOf(
        "DIAMOND_ORE",
        "DEEPSLATE_DIAMOND_ORE",

        "ANCIENT_DEBRIS",

        "EMERALD_ORE",
        "DEEPSLATE_EMERALD_ORE",

        "GOLD_ORE",
        "DEEPSLATE_GOLD_ORE"
    ),

    --- seconds
    CLEAR_INTERVAL = 60
}

this.log = require("@pierrelasse/plugins/staff/log"):sub("xray", "X-Ray", function(player)
    return player.hasPermission(this.PERMISSION)
end)

this.processedBlocks = java.map()

local function getAdjacentBlocks(block)
    return arrayOf(
        block.getRelative(1, 0, 0),
        block.getRelative(-1, 0, 0),
        block.getRelative(0, 1, 0),
        block.getRelative(0, -1, 0),
        block.getRelative(0, 0, 1),
        block.getRelative(0, 0, -1)
    )
end

---@param startBlock bukkit.block.Block
---@param material bukkit.Material
local function findVein(startBlock, material)
    local vein = java.set() ---@type java.Set<bukkit.block.Block>

    local toCheck = ArrayDeque(7) ---@type java.Collection<bukkit.block.Block>
    toCheck.add(startBlock)
    while not toCheck.isEmpty() do
        local block = toCheck.poll()
        toCheck.remove(block)

        if block.getType() == material and vein.add(block) then
            for relative in forEach(getAdjacentBlocks(block)) do
                if not vein.contains(relative) and not this.processedBlocks.containsKey(relative) then
                    toCheck.add(relative)
                end
            end
        end
    end

    return vein
end

---@param player bukkit.entity.Player
---@param block bukkit.block.Block
---@param amount integer
---@param material bukkit.Material
function this.notify(player, block, amount, material)
    local playerName = player.getName()

    local clickEvent = comp.clickEvent("RUN_COMMAND", "/spec "..playerName)

    this.log:log(function(l)
        local hover = l:tc("pierrelasse/plugins/staff/spec/clickToSpectate")

        return comp.empty()
            .append(
                l:tcf("pierrelasse/plugins/staff/xray/notify_name", playerName)
                .clickEvent(clickEvent)
                .hoverEvent(comp.hoverEvent("SHOW_TEXT", hover))
            )
            .append(
                l:tcf("pierrelasse/plugins/staff/xray/notify_found", amount, material.name():lower())
                .clickEvent(clickEvent)
                .hoverEvent(comp.hoverEvent(
                    "SHOW_TEXT",
                    comp.from("§7"..block.getWorld().getName()..
                        ", "..block.getX()..","..block.getY()..","..block.getZ()
                        .."\n\n")
                    .append(hover)
                ))
            )
    end)
end

events.onStarted(function()
    tasks.every(20 * this.CLEAR_INTERVAL, function() this.processedBlocks.clear() end)

    events.listen(BlockBreakEvent, function(event)
        local block = event.getBlock() ---@type bukkit.block.Block
        local blockMaterial = block.getType()
        if not this.MONITORED_BLOCKS.contains(blockMaterial.name()) then return end

        local player = event.getPlayer() ---@type bukkit.entity.Player
        if bukkit.isInCreativeOrSpec(player) then return end

        if this.processedBlocks.containsKey(block) then return end

        local vein = findVein(block, blockMaterial)
        local count = vein.size()

        local now = time.unixMs()
        for b in forEach(vein) do
            this.processedBlocks.put(b, now)
        end

        this.notify(player, block, count, blockMaterial)
    end)
        .priority("HIGH")
end)

return this
