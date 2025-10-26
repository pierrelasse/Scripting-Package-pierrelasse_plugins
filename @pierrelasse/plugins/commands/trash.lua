local ArrayDeque = import("java.util.ArrayDeque")


Lang.get("en"):put({
    pierrelasse = {
        plugins = {
            commands = {
                trash = {
                    title = "Trash",
                    close = comp.mm("<red>Close"),
                    history = {
                        item = comp.mm("<green>History"),
                        title = "Trashed Items",
                        back = comp.mm("<green>Back"),
                        maxHistorySize = comp.mm("<gray>Max history size: {0}"),
                        restoreAction = comp.mm("<yellow>Click to restore!")
                    }
                }
            }
        }
    }
})

Lang.get("de"):put({
    pierrelasse = {
        plugins = {
            commands = {
                trash = {
                    title = "Müll",
                    close = comp.mm("<red>Schließen"),
                    history = {
                        item = comp.mm("<green>Verlauf"),
                        title = "Gelöschte Items",
                        back = comp.mm("<green>Zurück"),
                        maxHistorySize = comp.mm("<gray>Max. Verlauf größe: {0}"),
                        restoreAction = comp.mm("<yellow>Klicke um das Item wiederherzustellen!")
                    }
                }
            }
        }
    }
})

local this = {
    ---@type integer
    HISTORY_SIZE = 5,

    COMMAND = "trash",
    ---@type string?
    PERMISSION = "commands.trash"
}

---@type java.Map<string, java.Collection<bukkit.ItemStack>>
this.history = java.map()

---@param player bukkit.entity.Player
---@param itemStack bukkit.ItemStack
function this.trashItemStack(player, itemStack)
    if this.HISTORY_SIZE == 0 then return end

    local playerId = bukkit.uuid(player)

    local playerHistory = java.mapComputeIfAbsent(this.history, playerId, function() return ArrayDeque(1) end)

    while playerHistory.size() >= this.HISTORY_SIZE do
        playerHistory.removeLast()
    end

    playerHistory.addFirst(itemStack)
end

---@param player bukkit.entity.Player
---@param idx integer
---@param cb? fun(itemStack: bukkit.ItemStack): nil|false|boolean
function this.untrashItemStack(player, idx, cb)
    if this.HISTORY_SIZE == 0 then return end

    local playerId = bukkit.uuid(player)

    local playerHistory = this.history.get(playerId)
    if playerHistory == nil then return end

    local i = 1
    local itr = playerHistory.iterator()
    while itr.hasNext() do
        local itemStack = itr.next()
        if i == idx then
            if cb and cb(itemStack) ~= false then
                itr.remove()
            end
            return itemStack
        end
        i = i + 1
    end
end

---@param player bukkit.entity.Player
function this.openHistory(player)
    local l = Lang.l(player)
    local playerId = bukkit.uuid(player)

    local screen = bukkit.guimaker.Screen.new(l:t("pierrelasse/plugins/commands/trash/history/title"), 3)

    screen:fill(
        bukkit.buildItem("BLACK_STAINED_GLASS_PANE"):hideTooltip():build(),
        screen:slot1(3, 1), screen:slot1(3, 9)
    )

    screen:button1(
        screen:slot1(3, 5),
        bukkit.buildItem("ARROW")
        :name(l:tc("pierrelasse/plugins/commands/trash/history/back"))
        :build(),
        function() this.open(player) end
    )

    local ui = {}

    function ui.items()
        local playerHistory = this.history.get(playerId)
        local playerHistoryItr = forEach(playerHistory or java.array(nil, 0))

        local startSlot = screen:slot1(1, 1)
        local endSlot = screen:slot1(2, 9)

        for slot = startSlot, endSlot do
            local itemStack = playerHistoryItr()

            if itemStack == nil then
                screen:set1(slot, nil)
            else
                screen:button1(slot,
                    bukkit.modifyItem(itemStack.clone())
                    :lore(function(list)
                        list.add("")
                        list.add(comp.legacySerialize(l:tc("pierrelasse/plugins/commands/trash/history/restoreAction")))
                    end)
                    :build(),
                    function(event)
                        if event.action == "PICKUP_ALL" then
                            this.untrashItemStack(player, slot, function(trashedItemStack)
                                if not bukkit.hasInventorySpace(player.getInventory(), trashedItemStack) then return false end
                                bukkit.addItem(player, trashedItemStack)
                            end)

                            ui.items()
                        end
                    end
                )
            end
        end

        local noticeItemSlot = this.HISTORY_SIZE + 1
        if noticeItemSlot <= endSlot then
            screen:set1(noticeItemSlot, bukkit.buildItem("BARRIER")
                :name(l:tcf("pierrelasse/plugins/commands/trash/history/maxHistorySize", this.HISTORY_SIZE))
                :build())
        end
    end

    ui.items()

    screen:open(player)
end

---@param player bukkit.entity.Player
function this.open(player)
    local l = Lang.l(player)

    local screen = bukkit.guimaker.Screen.new(l:t("pierrelasse/plugins/commands/trash/title"), 3)

    screen:fill(
        bukkit.buildItem("BLACK_STAINED_GLASS_PANE"):hideTooltip():build(),
        screen:slot1(3, 1), screen:slot1(3, 9)
    )

    screen:button1(
        screen:slot1(3, 5),
        bukkit.buildItem("BARRIER")
        :name(l:t("pierrelasse/plugins/commands/trash/close"))
        :build(),
        function() screen:close(player) end
    )

    local startSlot = screen:slot1(1, 1)
    local endSlot = screen:slot1(2, 9)

    local function trashItems()
        local count = 0
        for slot = startSlot, endSlot do
            local itemStack = screen:get1(slot)
            if itemStack ~= nil then
                this.trashItemStack(player, itemStack)
                screen:set1(slot, nil)
                count = count + 1
            end
        end
        if count ~= 0 then
            bukkit.playSound(player, "entity.generic.burn", .6, 1.4)
        end
    end

    ---@param event bukkit.guimaker.EventBase
    local function cb(event)
        event.cancelled = false
    end
    for slot = startSlot, endSlot do
        screen:listen(slot, { put = cb, take = cb, drag = cb })
    end

    if this.HISTORY_SIZE ~= 0 then
        screen:button1(
            screen:slot1(3, 9),
            bukkit.buildItem("WRITABLE_BOOK")
            :name(l:tc("pierrelasse/plugins/commands/trash/history/item"))
            :build(),
            function()
                trashItems()
                this.openHistory(player)
            end
        )
    end

    screen:closeable(trashItems)

    screen:open(player)
end

events.onStarted(function()
    commands.add(this.COMMAND, function(sender, args) ---@cast sender bukkit.entity.Player
        this.open(sender)
    end)
        .permission(this.PERMISSION)
end)

return this
