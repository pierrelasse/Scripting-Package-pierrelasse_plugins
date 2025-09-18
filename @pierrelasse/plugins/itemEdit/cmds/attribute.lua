local UUID = import("java.util.UUID")
local Attribute = import("org.bukkit.attribute.Attribute")
local EquipmentSlot = import("org.bukkit.inventory.EquipmentSlot")
local EquipmentSlotGroup = import("org.bukkit.inventory.EquipmentSlotGroup")
local AttributeModifier = import("org.bukkit.attribute.AttributeModifier")
local AttributeModifier_Operation = import("org.bukkit.attribute.AttributeModifier$Operation")

local itemEdit = require("@pierrelasse/plugins/itemEdit/")


local actions = { "add", "remove" }

itemEdit.registerSubCommand("attribute", {
    execute = function(player, args)
        local itemStack = itemEdit.checkItemStack(player)
        if not itemStack then return end

        local action = table.key(actions, args[2])
        if action == nil then
            itemEdit.send(player, "§cUsage: /ie attribute <add|remove> ...")
            return
        end

        -- add <attribute> amount [operation] [equip]
        if action == 1 then
            local attribute
            if args[3] ~= nil then
                for i in forEach(Attribute.values()) do
                    if i.getKey().toString() == args[3] then
                        attribute = i
                        break
                    end
                end
            end
            if attribute == nil then
                itemEdit.send(player, "§cInvalid attribute")
                return
            end

            local amount = tonumber(args[4])
            if amount == nil then
                itemEdit.send(player, "§cInvalid amount")
                return
            end

            local operation
            for i in forEach(AttributeModifier_Operation.values()) do
                if i.toString() == args[5] then
                    operation = i
                    break
                end
            end
            if operation == nil then
                itemEdit.send(player, "§cInvalid operation")
                return
            end

            local slot
            for i in forEach(EquipmentSlot.values()) do
                i = i.toString()
                if i == args[6] then
                    slot = i
                    break
                end
            end

            local modifier
            if bukkit.version.after(1, 20, 6) then
                local group
                if slot == nil then
                    group = EquipmentSlotGroup.ANY
                else
                    group = EquipmentSlotGroup.ANY
                    print("NOT ANY TODO") -- TODO
                end

                modifier = AttributeModifier(
                    UUID.randomUUID(),
                    attribute.getKey().toString(),
                    amount,
                    operation,
                    group
                )
            else
                if slot == nil then
                    itemEdit.send(player, "§cInvalid slot")
                    return
                end

                modifier = AttributeModifier(
                    UUID.randomUUID(),
                    attribute.getKey().toString(),
                    amount,
                    operation,
                    slot
                )
            end

            local meta = itemStack.getItemMeta()
            if meta == nil then return end

            meta.addAttributeModifier(attribute, modifier)

            itemStack.setItemMeta(meta)
            itemEdit.send(player,
                          "Added attribute §f"..
                          attribute.getKey().toString()..
                          "§7 with amount §f"..amount.."§7 to §f"
                          ..args[6].."§7 and operation §f".."???") -- operation.toString()

            return
        end

        if action == 2 then
            itemEdit.send(player, "§cComing soon") -- TODO
        end
    end,
    complete = function(completions, player, args)
        if #args == 2 then
            for _, action in ipairs(actions) do
                completions.add(action)
            end
            return
        end

        local action = table.key(actions, args[2])
        if action == nil then return end

        local function completeAttributes()
            for attribute in forEach(Attribute.values()) do
                completions.add(attribute.getKey().toString())
            end
        end

        local function completeSlots()
            -- TODO: EquipmentSlotGroup
            for equipmentSlot in forEach(EquipmentSlot.values()) do
                completions.add(equipmentSlot.toString())
            end
        end

        if #args == 3 then
            completeAttributes()
            if action == 2 then
                completeSlots()
            end
            return
        end

        if action ~= 1 then return end

        if #args == 4 then
            completions.add("<amount>")
            return
        end

        if #args == 5 then
            for i in forEach(AttributeModifier_Operation.values()) do
                completions.add(i.toString())
            end
            return
        end

        if #args == 6 then
            completeSlots()
        end
    end
})
