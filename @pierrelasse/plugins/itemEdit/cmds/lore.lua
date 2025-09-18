local itemEdit = require("@pierrelasse/plugins/itemEdit/")


local ACTIONS = { "add", "set", "remove", "clear", "insert", "copy", "copybook", "copyfile", "paste", "replace" }

itemEdit.registerSubCommand("lore", {
    execute = function(player, args)
        local itemStack = itemEdit.checkItemStack(player)
        if not itemStack then return end
        local meta = itemStack.getItemMeta()
        if meta == nil then return end

        if args[2] == nil then
            itemEdit.send(player, "§cUsage: /ie lore <"..table.concat(ACTIONS, "|").."> ...")
            return
        end
        local action = table.key(ACTIONS, args[2])
        if action == nil then
            itemEdit.send(player, "§cAction not found")
            return
        end

        local function getNewLines()
            if #args < 3 then return {} end
            local text = table.concat(args, " ", 3)
            text = text:replace("&", "§") -- TODO
            text = bukkit.hex(text)
            return text:split("\\n")
        end

        local lore = meta.getLore() or makeList()

        if action == 1 then -- add
            for line in forEach(getNewLines()) do lore.add(line) end
            itemEdit.send(player, "Line to lore added")
        elseif action == 2 then -- set
            lore.clear()
            for line in forEach(getNewLines()) do lore.add(line) end
            itemEdit.send(player, "Lore set")
        elseif action == 3 then -- remove
            itemEdit.send(player, "§cNot implemented")
        elseif action == 4 then -- clear
            lore.clear()
            itemEdit.send(player, "Lore removed")
        elseif action == 5 then  -- insert
            itemEdit.send(player, "§cNot implemented")
        elseif action == 6 then  -- copy
            itemEdit.send(player, "§cNot implemented")
        elseif action == 7 then  -- copybook
            itemEdit.send(player, "§cNot implemented")
        elseif action == 8 then  -- copyfile
            itemEdit.send(player, "§cNot implemented")
        elseif action == 9 then  -- paste
            itemEdit.send(player, "§cNot implemented")
        elseif action == 10 then -- replace
            itemEdit.send(player, "§cNot implemented")
        end

        meta.setLore(lore)
        itemStack.setItemMeta(meta)
    end,
    complete = function(completions, player, args)
        if #args == 2 then
            for _, action in ipairs(ACTIONS) do
                completions.add(action)
            end
        end
    end
})
