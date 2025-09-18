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

    MONITORED_BLOCKS = {
        "DIAMOND_ORE",
        "DEEPSLATE_DIAMOND_ORE",

        "ANCIENT_DEBRIS",

        "EMERALD_ORE",
        "DEEPSLATE_EMERALD_ORE",

        "GOLD_ORE",
        "DEEPSLATE_GOLD_ORE"
    }
}

this.processedBlocks = makeMap()

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

---@param startBlock java.Object
---@param material java.Object
local function findVein(startBlock, material)
    ---@type java.Set<bukkit.block.Block>
    local vein = makeSet()

    local toCheck = ArrayDeque(7)
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
    local prefix = comp.from("§3[§bS§3] ")
    Lang.sendMult(
        function(l)
            local hover = l:tc("pierrelasse/plugins/staff/spec/clickToSpectate")
            local clickEvent = comp.clickEvent("RUN_COMMAND", "/spec "..player.getName())
            return comp.empty()
                .append(prefix)
                .append(
                    l:tcf("pierrelasse/plugins/staff/xray/notify_name", player.getName())
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
        end,
        bukkit.playersLoop(),
        function(p) return p.hasPermission(this.PERMISSION) end
    )
end

events.onStarted(function()
    tasks.every(20 * 60, function() this.processedBlocks.clear() end)

    events.listen(BlockBreakEvent, function(event)
        local block = event.getBlock()
        local blockMaterial = block.getType()
        if table.key(this.MONITORED_BLOCKS, blockMaterial.name()) == nil then return end

        local player = event.getPlayer()
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
