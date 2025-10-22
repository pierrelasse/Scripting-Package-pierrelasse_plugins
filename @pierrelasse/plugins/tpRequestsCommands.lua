local simpleTargets = require("@pierrelasse/lib/simpleTargets")
local nameFormatter = require("@pierrelasse/lib/nameFormatter")
local tpRequests = require("@pierrelasse/plugins/tpRequests")


Lang.get("en"):put({
    pierrelasse = {
        plugins = {
            tpRequestsCommands = {
                send = {
                    to = comp.mm("Sent a TPA request to {0}"),
                    here = comp.mm("Sent a TPA-here request to {0}"),

                    fail = comp.mm("<red>Could not send request request! <gray>({0})")
                },
                receive = {
                    to = comp.mm("You received a TPA request from {0}"),
                    here = comp.mm("You received a TPA-here request from {0}"),

                    accept = {
                        to = comp.mm("{0} accepted your TPA request"),
                        here = comp.mm("{0} accepted your TPA-here request")
                    }
                },
                accept = {
                    requestNotFound = comp.mm("<red>Request not found!"),

                    screen = {
                        title = {
                            to = "Teleport to {0}?",
                            here = "Teleport {0} to you?"
                        },
                        cancel = comp.mm("<red>Cancel"),
                        accept = {
                            wait = comp.mm("<#518745>{0}..."),
                            desc = {
                                to = comp.mm("<gray>Teleport {0} to you"),
                                here = comp.mm("<gray>Teleport <u>you</u> to {0}")
                            },
                            label = comp.mm("<green>Accept")
                        }
                    }
                },
            }
        }
    }
})

Lang.get("de"):put({
    pierrelasse = {
        plugins = {
            tpRequestsCommands = {
                send = {
                    to = comp.mm("TPA-Anfrage an {0} gesendet"),
                    here = comp.mm("TPA-hier-Anfrage an {0} gesendet"),

                    fail = comp.mm("<red>Anfrage konnte nicht gesendet werden! <gray>({0})")
                },
                receive = {
                    to = comp.mm("Du hast eine TPA-Anfrage von {0} erhalten"),
                    here = comp.mm("Du hast eine TPA-hier-Anfrage von {0} erhalten"),

                    accept = {
                        to = comp.mm("{0} hat deine TPA-Anfrage akzeptiert"),
                        here = comp.mm("{0} hat deine TPA-hier-Anfrage akzeptiert")
                    }
                },
                accept = {
                    requestNotFound = comp.mm("<red>Anfrage nicht gefunden!"),

                    screen = {
                        title = {
                            to = "{0} zu dir teleportieren?",
                            here = "Zu {0} teleportieren?"
                        },
                        cancel = comp.mm("<red>Abbrechen"),
                        accept = {
                            wait = comp.mm("<#518745>{0}..."),
                            desc = {
                                to = comp.mm("<gray>{0} zu dir teleportieren"),
                                here = comp.mm("<gray><u>dich</u> zu {0} teleportieren")
                            },
                            label = comp.mm("<green>Akzeptieren")
                        }
                    }
                },
            }
        }
    }
})


local this = {
    COMMAND_SEND = "tpa",
    COMMAND_SEND_PERMISSION = "commands.tpa",

    COMMAND_SENDHERE = "tpahere",
    COMMAND_SENDHERE_PERMISSION = "commands.tpahere",

    COMMAND_ACCEPT = "tpaccept",
    COMMAND_ACCEPT_PERMISSION = "commands.tpaccept"
}

---@param receiver bukkit.entity.Player
---@param request pierrelasse.plugins.tpRequests.Request
function this.accept(receiver, request)
    local l = Lang.l(receiver)

    local sender = bukkit.playerByUUID(request.senderId)
    if sender == nil then
        bukkit.send(receiver, "§cSender not found") -- TODO
        return
    end

    local senderName = sender.getName()

    local screen = bukkit.guimaker.Screen.new(comp.legacySerialize(l:tcf(
            "pierrelasse/plugins/tpRequestsCommands/accept/screen/title/"..(request.here and "here" or "to"),
            senderName
        )),
        3
    )

    screen:button(
        screen:slot(2, 2),
        bukkit.buildItem("RED_STAINED_GLASS_PANE")
        :name(l:tc("pierrelasse/plugins/tpRequestsCommands/accept/screen/cancel"))
        :build(),
        function()
            screen:close(receiver)
        end
    )

    screen:set(
        screen:slot(2, 5),
        bukkit.buildItem("PLAYER_HEAD")
        :playerHead_player(sender)
        :name(nameFormatter.prefixName(sender))
        :build()
    )

    local WAIT_SECONDS = 5
    local slot = screen:slot(2, 8)
    local lore = l:tcf("pierrelasse/plugins/tpRequestsCommands/accept/screen/accept/desc/"..
        (request.here and "here" or "to"), senderName)
    screen:closeable(tasks.doFor(20 * WAIT_SECONDS, 20,
        function(_, count)
            screen:set(slot,
                bukkit.buildItem("GREEN_STAINED_GLASS_PANE")
                :name(l:tcf("pierrelasse/plugins/tpRequestsCommands/accept/screen/accept/wait", WAIT_SECONDS - count))
                :lore(lore)
                :build())
        end,
        function()
            screen:button(
                slot,
                bukkit.buildItem("LIME_STAINED_GLASS_PANE")
                :name(l:tc("pierrelasse/plugins/tpRequestsCommands/accept/screen/accept/label"))
                :lore(lore)
                :build(),
                function()
                    screen:close(receiver)

                    tpRequests.acceptRequest(request)

                    Lang.sendF(sender, "pierrelasse/plugins/tpRequestsCommands/receive/accept/"..
                        (request.here and "here" or "to"),
                        receiver.getName())
                end
            )
        end
    ).cancel)

    screen:open(receiver)
end

events.onStarted(function()
    commands.add(this.COMMAND_SEND, function(sender, args) ---@cast sender bukkit.entity.Player
        local target = simpleTargets.find(sender, args[1])
        if target == nil then
            bukkit.send(sender, "§cTarget not found!") -- TODO
            return
        end

        local err = tpRequests.sendRequest(sender, target)
        if err ~= nil then
            Lang.sendF(sender, "pierrelasse/plugins/tpRequestsCommands/send/fail", err)
            return
        end

        Lang.sendF(sender, "pierrelasse/plugins/tpRequestsCommands/send/to", target.getName())
        Lang.sendF(target, "pierrelasse/plugins/tpRequestsCommands/receive/to", sender.getName())
    end)
        .permission(this.COMMAND_SEND_PERMISSION)
        .complete(function(completions, sender, args)
            if #args == 1 then
                simpleTargets.complete(sender, completions, args[1], true)
            end
        end)
    commands.add(this.COMMAND_SENDHERE, function(sender, args) ---@cast sender bukkit.entity.Player
        local target = simpleTargets.find(sender, args[1])
        if target == nil then
            bukkit.send(sender, "§cTarget not found!") -- TODO
            return
        end

        local err = tpRequests.sendRequest(sender, target, true)
        if err ~= nil then
            Lang.sendF(sender, "pierrelasse/plugins/tpRequestsCommands/send/fail", err)
            return
        end

        Lang.sendF(sender, "pierrelasse/plugins/tpRequestsCommands/send/here", target.getName())
        Lang.sendF(target, "pierrelasse/plugins/tpRequestsCommands/received/here", sender.getName())
    end)
        .permission(this.COMMAND_SENDHERE_PERMISSION)
        .complete(function(completions, sender, args)
            if #args == 1 then
                simpleTargets.complete(sender, completions, args[1], true)
            end
        end)

    commands.add(this.COMMAND_ACCEPT, function(sender, args) ---@cast sender bukkit.entity.Player
        local receiverId = bukkit.uuid(sender)

        if #args == 0 then
            local request, err = tpRequests.getLatestRequest(receiverId)
            if request == nil then
                bukkit.send(sender, "Error: "..err)
                return
            end

            this.accept(sender, request)
        else
            local target = simpleTargets.find(sender, args[1])
            if target == nil then
                bukkit.send(sender, "§cTarget not found!") -- TODO
                return
            end

            local request = tpRequests.getRequest(receiverId, bukkit.uuid(target))
            if request == nil then
                Lang.send(sender, "pierrelasse/plugins/tpRequestsCommands/accept/requestNotFound")
                return
            end

            this.accept(sender, request)
        end
    end)
        .permission(this.COMMAND_ACCEPT_PERMISSION)
        .complete(function(completions, sender, args)
            if #args == 1 then
                simpleTargets.complete(sender, completions, args[1], true)
            end
        end)
end)

return this
