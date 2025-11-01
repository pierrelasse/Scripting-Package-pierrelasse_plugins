local BlockPlaceEvent = import("org.bukkit.event.block.BlockPlaceEvent")
local PlayerItemConsumeEvent = import("org.bukkit.event.player.PlayerItemConsumeEvent")

local clickListener = require("@pierrelasse/lib/clickListener")
local manager = require("@pierrelasse/plugins/customItems/manager")


events.onStarted(function()
    clickListener.listen(function(event)
        local itemStack = event.item

        local item = manager.getFromItem(itemStack)
        if item == nil then return end

        if event.button == "right" then
            if item.abilityRightClick ~= nil then
                if item.abilityRightClick.activate(event.player, event) == true then
                    event.event.setCancelled(true)
                end
                return true
            end
        elseif event.button == "left" then
            if item.abilityLeftClick ~= nil then
                if item.abilityLeftClick.activate(event.player, event) == true then
                    event.event.setCancelled(true)
                end
                return true
            end
        end
    end)

    events.listen(PlayerItemConsumeEvent, function(event)
        local itemStack = event.getItem() ---@type bukkit.ItemStack

        local item = manager.getFromItem(itemStack)
        if item == nil then return end

        if item.abilityConsume ~= nil then
            local player = event.getPlayer() ---@type bukkit.entity.Player

            if item.abilityConsume.activate(player, {
                player = player,
                itemStack = itemStack
            }) == true then
                event.setCancelled(true)
            end
        end
    end)

    events.listen(BlockPlaceEvent, function(event)
        local itemStack = event.getItemInHand() ---@type bukkit.ItemStack

        local item = manager.getFromItem(itemStack)
        if item == nil then return end

        if item.abilityPlace ~= nil then
            local player = event.getPlayer() ---@type bukkit.entity.Player
            local block = event.getBlock() ---@type bukkit.block.Block
            if item.abilityPlace.activate(player, {
                player = player,
                block = block,
                itemStack = itemStack
            }) == true then
                event.setCancelled(true)
            end
        end
    end)
end)
