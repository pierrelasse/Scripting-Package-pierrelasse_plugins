local AsyncChatEvent = import("io.papermc.paper.event.player.AsyncChatEvent")

local complete = require("@pierrelasse/lib/complete")


Lang.get("en"):put({
    pierrelasse = {
        plugins = {
            staff = {
                mutechat = {
                    stateOn = "on",
                    stateOff = "off",
                    invalidState = "§cInvalid state!",
                    muted = comp.empty()
                        .appendNewline()
                        .append(comp.from("§cThe chat has been muted!"))
                        .appendNewline(),
                    alreadyMuted = "§cThe chat is already muted!",
                    unmuted = comp.empty()
                        .appendNewline()
                        .append(comp.from("§aThe chat has been unmuted!"))
                        .appendNewline(),
                    alreadyUnmuted = "§cThe chat is already unmuted!",
                    currentlyMuted = "§cThe chat is currently muted!"
                }
            }
        }
    }
})

local this = {
    COMMAND = "mutechat",
    PERMISSION = "!.staff.mutechat",

    BYPASS_PERMISSION = "!.staff.mutechat.bypass"
}

this.state = false

events.onStarted(function()
    commands.add(this.COMMAND, function(sender, args)
        local l = Lang.l(sender)

        if args[1] == nil then
            this.state = not this.state
        elseif args[1] == l:t("pierrelasse/plugins/staff/mutechat/stateOn") then
            if this.state == true then
                Lang.send(sender, "pierrelasse/plugins/staff/mutechat/alreadyMuted")
                return
            end
            this.state = true
        elseif args[1] == l:t("pierrelasse/plugins/staff/mutechat/stateOff") then
            if this.state == false then
                Lang.send(sender, "pierrelasse/plugins/staff/mutechat/alreadyUnmuted")
                return
            end
            this.state = false
        else
            Lang.send(sender, "pierrelasse/plugins/staff/mutechat/invalidState")
            return
        end

        local silent = args[2] == "-s" or args[1] == "-s"
        if silent then return end

        if this.state then
            Lang.sendMult(
                function(il)
                    return il:tc("pierrelasse/plugins/staff/mutechat/muted")
                end, bukkit.playersLoop())
        else
            Lang.sendMult(
                function(il)
                    return il:tc("pierrelasse/plugins/staff/mutechat/unmuted")
                end, bukkit.playersLoop())
        end
    end)
        .permission(this.PERMISSION)
        .complete(function(completions, sender, args)
            if #args == 1 then
                local l = Lang.l(sender)
                complete(completions, args[1], {
                    l:t("pierrelasse/plugins/staff/mutechat/stateOn"),
                    l:t("pierrelasse/plugins/staff/mutechat/stateOff"),
                    "-s"
                })
            elseif #args == 2 then
                complete(completions, args[2], { "-s" })
            end
        end)

    events.listen(AsyncChatEvent, function(event)
        if not this.state then return end

        local player = event.getPlayer() ---@type bukkit.entity.Player
        if player.hasPermission(this.BYPASS_PERMISSION) then return end

        event.setCancelled(true)

        Lang.send(player, "pierrelasse/plugins/staff/mutechat/currentlyMuted")
    end)
        .priority("LOW")
end)

return this
