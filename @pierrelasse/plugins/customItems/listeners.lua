local BlockPlaceEvent = import("org.bukkit.event.block.BlockPlaceEvent")
local PlayerItemConsumeEvent = import("org.bukkit.event.player.PlayerItemConsumeEvent")

local clickListener = require("@pierrelasse/lib/clickListener")
local manager = require("@pierrelasse/plugins/customItems/manager")


events.onStarted(function()
    clickListener.listen(function(event)
        local itemStack = event.item
        local item = manager.getFromItem(itemStack)
        if item == nil then return end

        local player = event.player

        if event.button == "right" then
            if item.abilityRightClick ~= nil then
                item.abilityRightClick.activate(player, itemStack, event.event)
            end
        elseif event.button == "left" then
            if item.abilityLeftClick ~= nil then
                item.abilityLeftClick.activate(player, itemStack, event.event)
            end
        end
    end)

    events.listen(PlayerItemConsumeEvent, function(event)
        local itemStack = event.getItem() ---@type bukkit.ItemStack

        local item = manager.getFromItem(itemStack)
        if item == nil then return end

        local player = event.getPlayer()

        if item.abilityConsume ~= nil then
            item.abilityConsume.activate(player, itemStack, event)
        end
    end)

    events.listen(BlockPlaceEvent, function(event)
        local itemStack = event.getItemInHand() ---@type bukkit.ItemStack

        local item = manager.getFromItem(itemStack)
        if item == nil then return end

        if item.abilityPlace ~= nil then
            local block = event.getBlock() ---@type bukkit.block.Block
            local player = event.getPlayer() ---@type bukkit.entity.Player
            item.abilityPlace.activate(player, block, event)
        end
    end)
end)
