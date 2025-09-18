local complete = require("@pierrelasse/lib/complete")


---@alias pierrelasse.plugins.itemEdit.Execute fun(player: bukkit.entity.Player, args: java.array<string>)
---@alias pierrelasse.plugins.itemEdit.Complete fun(completions: java.List<string>, player: bukkit.entity.Player, args: java.array<string>)

---@class pierrelasse.plugins.itemEdit.SubCommand
---@field desc string?
---@field execute pierrelasse.plugins.itemEdit.Execute
---@field complete? pierrelasse.plugins.itemEdit.Complete

local this = {
    PREFIX = "§2[§aItemEdit§2] §7",
    COMMAND = { "itemedit", "ie" },
    PERMISSION = "op"
}

---@type java.Map<string, pierrelasse.plugins.itemEdit.SubCommand>
this.cmds = java.map()

---@param name string
---@param cmd pierrelasse.plugins.itemEdit.SubCommand
function this.registerSubCommand(name, cmd)
    this.cmds.put(name, cmd)
end

---@param player bukkit.entity.Player
---@param message string
function this.send(player, message)
    bukkit.send(player, this.PREFIX..message)
end

---@param player bukkit.entity.Player
---@return bukkit.ItemStack?
function this.checkItemStack(player)
    if not bukkit.isPlayer(player) then return end
    local itemStack = player.getInventory().getItemInMainHand()
    if itemStack.getType().isAir() then return end
    return itemStack
end

events.onStarted(function()
    require("@pierrelasse/plugins/itemEdit/cmds/attribute")
    require("@pierrelasse/plugins/itemEdit/cmds/basic")
    require("@pierrelasse/plugins/itemEdit/cmds/enchant")
    require("@pierrelasse/plugins/itemEdit/cmds/lore")
    require("@pierrelasse/plugins/itemEdit/cmds/skull")

    commands.add(this.COMMAND, function(sender, args)
        if not bukkit.isPlayer(sender) then return end
        ---@cast sender bukkit.entity.Player

        if args[1] == nil then
            local s = "§cUsage: /ie <subcommand> <...>"
            for name in forEach(this.cmds.keySet()) do
                s = s.."\n§8 - §7"..name
                local cmd = this.cmds.get(name)
                if cmd.desc ~= nil then
                    s = s.."§8 - §7"..cmd.desc
                end
            end
            this.send(sender, s)
            return
        end

        local cmd = this.cmds.get(args[1])
        if cmd == nil then
            sender.sendMessage("§cSub-Command not found")
            return
        end
        local execute = cmd.execute
        execute(sender, args)
    end)
        .complete(function(completions, sender, args)
            ---@cast sender bukkit.entity.Player

            local cmd = this.cmds.get(args[1])
            if cmd == nil then
                complete(completions, args[2], forEach(this.cmds.keySet()))
                return
            end

            local cmdComplete = cmd.complete
            if cmdComplete == nil then return end
            cmdComplete(completions, sender, args)
        end)
        .permission(this.PERMISSION)
end)

return this
