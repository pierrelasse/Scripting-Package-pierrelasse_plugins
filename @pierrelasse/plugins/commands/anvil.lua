local this = {
    COMMAND = "anvil",
    PERMISSION = "commands.anvil",
}

events.onStarted(function()
    commands.add(this.COMMAND, function(sender, args) ---@cast sender bukkit.entity.Player
        local target = sender -- TODO

        target.openAnvil(target.getLocation(), true)
    end)
        .permission(this.PERMISSION)
end)

return this
