local this = {
    COMMAND = "anvil",
    PERMISSION = "commands.anvil",
}

events.onStarted(function()
    commands.add(this.COMMAND, function(sender, args) ---@cast sender bukkit.entity.Player
        sender.openAnvil(sender.getLocation(), true)
    end)
        .permission(this.PERMISSION)
end)

return this
