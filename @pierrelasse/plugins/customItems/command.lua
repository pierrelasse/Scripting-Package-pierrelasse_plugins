local complete = require("@pierrelasse/lib/complete")
local cfg = require("@pierrelasse/plugins/customItems/_cfg")
local manager = require("@pierrelasse/plugins/customItems/manager")


events.onStarted(function()
    if cfg.COMMAND == nil then return end

    commands.add(cfg.COMMAND.name, function(sender, args)
        ---@cast sender bukkit.entity.Player

        if args[1] == nil then
            bukkit.send(sender, "§cUsage: /customitem <item>")
            return
        end
        local item = manager.get(args[1])
        if item == nil then
            bukkit.send(sender, "§cItem not found!")
            return
        end

        bukkit.addItem(sender, item:buildItem():build())
        bukkit.send(sender, comp.mm("<green>Item <dark_green>"..item.id.."</dark_green> given!"))
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
