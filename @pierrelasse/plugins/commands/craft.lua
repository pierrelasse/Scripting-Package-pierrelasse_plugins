local this = {
    COMMAND = "craft",
    PERMISSION = "commands.craft",
}

events.onStarted(function()
    commands.add(this.COMMAND, function(sender, args) ---@cast sender bukkit.entity.Player
        sender.openWorkbench(sender.getLocation(), true)
    end)
        .permission(this.PERMISSION)
end)

return this
