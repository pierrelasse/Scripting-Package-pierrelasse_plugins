local Scripting = import("net.bluept.scripting.Scripting")


local IS_VELOCITY = Scripting.getPlatform().getName() == "velocity"
local COMMAND_NAME = IS_VELOCITY and "evalv" or "eval"

local function send(target, message)
    if bukkit ~= nil then
        bukkit.send(target, message)
    elseif velocity ~= nil then
        velocity.send(target, message)
    else
        print("eval: "..tostring(target)..": "..message) -- fallback
    end
end

local counter = 0

events.onStarted(function()
    commands.add(COMMAND_NAME, function(sender, args)
        local code = table.concat(args, " ")
        if #code == 0 then
            send(sender, "§cUsage: /"..COMMAND_NAME.." <code...>")
            return
        end

        send(sender, "§7executing: "..code)

        local env = setmetatable({}, { __index = _ENV })
        env.sender = sender

        counter = counter + 1
        local chunk, err = load(code, "eval#"..counter, "bt", env)

        if chunk == nil then
            send(sender, "§cError loading: §r"..err)
            return
        end

        local success, result = pcall(chunk)
        if success then
            if result ~= nil then
                send(sender, "§7 Result: §r"..tostring(result))
            end
        else
            send(sender, "§cError: §r"..tostring(result))
        end
    end)
        .permission("scripting.eval")
end)
