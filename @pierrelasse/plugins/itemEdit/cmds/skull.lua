local itemEdit = require("@pierrelasse/plugins/itemEdit/")


-- registerSubCommand("skullowner", {
--     exec = function(player, args)
--         local itemStack = getItemStack(player)
--         if itemStack == nil then return end

--         local meta = itemStack.getItemMeta()
--         if meta == nil then return end
--         if not instanceof(meta, SkullMeta) then
--             send(player, MSG_INVALID_ITEM_TYPE)
--             return
--         end

--         local name = args[2]
--         if name == nil then
--             meta.setOwner(nil)
--             send(player, "Removed owner")
--             return
--         else
--             if string.length(name) < 3 or string.length(name) > 16 then
--                 send(player, "§cInvalid name")
--                 return
--             end

--             meta.setOwner(name)
--             send(player, "Set owner to §f"..name)
--         end

--         itemStack.setItemMeta(meta)
--         player.updateInventory()
--     end,
--     complete = function(completions, player, args)
--     end
-- })
