local complete = require("@pierrelasse/lib/complete")
local cfg = require("@pierrelasse/plugins/customItems/_cfg")
local manager = require("@pierrelasse/plugins/customItems/manager")


events.onStarted(function()
    if cfg.COMMAND == nil then return end

    commands.add(cfg.COMMAND.name, function(sender, args) ---@cast sender bukkit.entity.Player
        if args[1] == nil then
            bukkit.send(sender, "§cUsage: /customitem <item>")
            return
        end
        local item = manager.get(args[1])
        if item == nil then
            bukkit.send(sender, "§cItem not found!")
            return
        end

        local amount ---@type integer?
        if args[2] ~= nil then
            amount = tonumber(args[2], 10)
            if not numbers.between(amount, 1, numbers.INTEGER_MAX) then
                bukkit.send(sender, "§cInvalid amount!")
                return
            end
        end

        local target = sender

        local itemBuilder = item:buildItem()
        if amount ~= nil then
            itemBuilder:amount(amount)
        end
        bukkit.addItem(target, itemBuilder:build())

        local str = "Gave"
        if amount ~= nil then
            str = str.." "..amount
        end
        str = str.." ["..item.id.."] to "..target.getName()
        bukkit.send(sender, comp.mm(str))
    end)
        .permission(cfg.COMMAND.permission)
        .complete(function(completions, sender, args)
            if #args == 1 then
                complete(completions, args[1],
                    forEach(manager.map.entrySet()),
                    function(i) ---@cast i java.Map.Entry<string, pierrelasse.plugins.customItems.Item>
                        if i.getValue().hidden ~= true then
                            return i.getKey()
                        end
                    end)
            end
        end)
end)
