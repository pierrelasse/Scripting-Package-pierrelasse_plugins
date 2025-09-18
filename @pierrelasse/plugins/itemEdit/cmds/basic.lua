local complete = require("@pierrelasse/lib/complete")
local itemEdit = require("@pierrelasse/plugins/itemEdit/")
local completer = require("@pierrelasse/plugins/itemEdit/completer")

---@param input string
local function revertColor(input)
    input = input:gsub("§x§(%x)§(%x)§(%x)§(%x)§(%x)§(%x)", function(r1, r2, g1, g2, b1, b2)
        return "§#"..r1..r2..g1..g2..b1..b2
    end)
    input = input:gsub("§([0-9a-fklmnor#])", "&%1")
    return input
end


itemEdit.registerSubCommand("type", {
    execute = function(player, args)
        local itemStack = itemEdit.checkItemStack(player)
        if not itemStack then return end

        local material = completer.materialItemF(args[2])
        if material == nil then
            itemEdit.send(player, "§cInvalid material!")
            return
        end

        itemStack.setType(material)

        itemEdit.send(player, "Material set to §f"..tostring(material.getKey()))
    end,
    complete = function(completions, player, args)
        if #args == 2 then
            completer.materialItemC(completions, args[2])
        end
    end
})

itemEdit.registerSubCommand("amount", {
    execute = function(player, args)
        local itemStack = itemEdit.checkItemStack(player)
        if not itemStack then return end

        local amount = tonumber(args[2], 10)
        if amount == nil then
            itemEdit.send(player, "§cInvalid amount!")
            return
        end

        itemStack.setAmount(amount)

        itemEdit.send(player, "Amount set to §f"..amount)
    end,
    complete = function(completions, player, args)
        local itemStack = itemEdit.checkItemStack(player)
        if not itemStack then return end

        complete(completions, args[2], {
            "1", "10", "64", "100", "127",
            itemStack.getAmount() })
    end
})

itemEdit.registerSubCommand("damage", {
    execute = function(player, args)
        local itemStack = itemEdit.checkItemStack(player)
        if not itemStack then return end

        local maxDurability = itemStack.getType().getMaxDurability()

        if args[2] == nil then
            itemEdit.send(player, "Durability: §f"..itemStack.getDurability().." / "..maxDurability)
            return
        end

        local durability = tonumber(args[2], 10)
        if durability == nil then
            itemEdit.send(player, "§cInvalid durabiltiy!")
            return
        end
        durability = numbers.clamp(durability, 0, maxDurability)

        itemStack.setDurability(durability)

        itemEdit.send(player, "Durability set to §f"..durability)
    end,
    complete = function(completions, player, args)
        if #args == 2 then
            local compl = { "0" }

            local itemStack = itemEdit.checkItemStack(player)
            if itemStack then
                local max = itemStack.getType().getMaxDurability()
                if max > 0 then
                    compl[2] = max
                    compl[3] = math.floor(max / 2)
                    compl[4] = math.floor(max / 4)
                    compl[5] = math.floor(max / 4 * 3)
                end
            end

            complete(completions, args[2], compl)
        end
    end
})

itemEdit.registerSubCommand("rename", {
    execute = function(player, args)
        local itemStack = itemEdit.checkItemStack(player)
        if not itemStack then return end
        local meta = itemStack.getItemMeta()
        if meta == nil then return end

        local name = arrays.concat(args, " ", 2)
            :gsub("&([0-9a-fklmnor#])", "§%1")
        name = bukkit.hex(name)

        meta.setDisplayName(name)

        itemStack.setItemMeta(meta)
        itemEdit.send(player, "Display name set to §f"..name)
    end,
    complete = function(completions, player, args)
        if #args == 2 then
            local itemStack = itemEdit.checkItemStack(player)
            if not itemStack then return end
            local meta = itemStack.getItemMeta()
            if meta == nil then return end

            local displayName = meta.getDisplayName() ---@type string

            complete(completions, args[2], { revertColor(displayName) })
        end
    end
})

itemEdit.registerSubCommand("unbreakable", {
    execute = function(player, args)
        local itemStack = itemEdit.checkItemStack(player)
        if not itemStack then return end
        local meta = itemStack.getItemMeta()
        if meta == nil then return end

        local state ---@type boolean
        if args[2] == nil then
            state = not meta.isUnbreakable()
        elseif args[2] == "true" then
            state = true
        elseif args[2] == "false" then
            state = false
        else
            itemEdit.send(player, "§cInvalid state!")
            return
        end

        meta.setUnbreakable(state)

        itemStack.setItemMeta(meta)
        itemEdit.send(player, "Unbreakable: §f"..tostring(state))
    end,
    complete = function(completions, player, args)
        if #args == 2 then
            local itemStack = itemEdit.checkItemStack(player)
            if not itemStack then return end
            local meta = itemStack.getItemMeta()
            if meta == nil then return end

            complete(completions, args[2], { meta.isUnbreakable() and "false" or "true" })
        end
    end
})
