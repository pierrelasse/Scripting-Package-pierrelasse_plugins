local complete = require("@pierrelasse/lib/complete")
local itemEdit = require("@pierrelasse/plugins/itemEdit/")
local completer = require("@pierrelasse/plugins/itemEdit/completer")


itemEdit.registerSubCommand("enchant", {
    execute = function(player, args)
        local itemStack = itemEdit.checkItemStack(player)
        if not itemStack then return end
        local meta = itemStack.getItemMeta()
        if meta == nil then return end

        local enchantment = completer.enchantmentF(args[2])
        if enchantment == nil then
            itemEdit.send(player, "§cEnchantment not found!")
            return
        end

        local level = tonumber(args[3], 10)
        if level == nil then
            if #args >= 3 then
                itemEdit.send(player, "§cInvalid level")
                return
            end

            itemEdit.send(player, "Level of §f"..tostring(enchantment.getKey())
                .."§8: §f"..meta.getEnchantLevel(enchantment))
            return
        end

        if level == 0 then
            local enchants = meta.getEnchants() ---@type java.Map<bukkit.enchantments.Enchantment, integer>
            meta.removeEnchantments()
            for entry in forEach(enchants.entrySet()) do
                ---@cast entry java.Map.Entry<bukkit.enchantments.Enchantment, integer>

                local k, v = entry.getKey(), entry.getValue()
                if k ~= enchantment then
                    meta.addEnchant(k, v, true)
                end
            end

            itemStack.setItemMeta(meta)
            itemEdit.send(player, "Removed enchantment §f"..tostring(enchantment.getKey()))
        else
            if not meta.addEnchant(bukkit.enchantment(enchantment), level, true) then
                itemEdit.send(player, "§cNothing changed!")
                return
            end
            itemStack.setItemMeta(meta)
            itemEdit.send(player, "Added enchantment §f"..tostring(enchantment.getKey()).." "..level)
        end
    end,
    complete = function(completions, player, args)
        if #args == 2 then
            completer.enchantmentC(completions, args[2])
        elseif #args == 3 then
            local compl = { "0" }

            local enchantment = completer.enchantmentF(args[2])

            if enchantment ~= nil then
                local maxLevel = enchantment.getMaxLevel()
                for i = 1, maxLevel, 1 do
                    compl[i + 1] = tostring(i)
                end
            end

            complete(completions, args[3], compl)
        end
    end
})
