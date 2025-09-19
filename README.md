# Scripting Package - pierrelasse/plugins

Various features, interfaces, and more made by me that can change the gameplay.

### [pierrelasse/plugins/admincommands](./@pierrelasse/plugins/admincommands/)

Operator utilities like /heal, /invsee, /sudo, /fly.

A full list of commands: cloneinv, ecsee, feed, fly, gm, gms, gmc, gma, gmsp, heal, hp, invsee, loop, speed, sudo

Configurable using:

```lua
local admincommandsCfg = require("@pierrelasse/plugins/admincommands/_cfg")

-- Set the prefix for permissions.
-- Example: fly permission: myserver.commands.fly
admincommandsCfg.permissionPrefix = "myserver.commands."

-- Disable modules
admincommandsCfg.modules.remove("fly") -- disables /fly
admincommandsCfg.modules.remove("loop") -- disables /loop
```

### [pierrelasse/plugins/headdb](./@pierrelasse/plugins/headdb/)

WIP.
A very lightweight version of [github/TheSilentPro/HeadDB](https://github.com/TheSilentPro/HeadDB).

### [pierrelasse/plugins/itemEdit](./@pierrelasse/plugins/itemEdit/)

Still work in progress but usable.

A very lightweight version of [github/emanondev/ItemEdit](https://github.com/emanondev/ItemEdit).

Commands:

-   /ie damage
-   /ie amount
-   /ie lore
-   /ie rename
-   /ie enchant
-   /ie unbreakable
-   /ie attribute
-   /ie type

### [pierrelasse/plugins/staff/chat](./@pierrelasse/plugins/staff/chat.lua)

Chat for staff.

`/staffchat <message>` to send a message to all players that have the `!.staff.chat` perrmision.

Configurable using:

```lua
local staff_chat = require("@pierrelasse/plugins/staff/chat")

-- Set the command to /hello instead of /staffchat, /sc.
staff_chat.COMMAND = "hello"

-- Set the send & recive permission.
staff_chat.PERMISSION = "myserver.staff.chat"
```

### [pierrelasse/plugins/staff/displayer](./@pierrelasse/plugins/staff/displayer.lua)

// TODO

### [pierrelasse/plugins/staff/helpop](./@pierrelasse/plugins/staff/helpop.lua)

// TODO

### [pierrelasse/plugins/staff/mutechat](./@pierrelasse/plugins/staff/mutechat.lua)

// TODO

### [pierrelasse/plugins/staff/spec](./@pierrelasse/plugins/staff/spec.lua)

// TODO

### [pierrelasse/plugins/staff/vanish](./@pierrelasse/plugins/staff/vanish.lua)

// TODO

### [pierrelasse/plugins/staff/void](./@pierrelasse/plugins/staff/void.lua)

// TODO

### [pierrelasse/plugins/staff/xray](./@pierrelasse/plugins/staff/xray.lua)

// TODO

### [pierrelasse/plugins/combat](./@pierrelasse/plugins/combat.lua)

Interface for storing & managing combat timers.

Configurable using:

```lua
local combat = require("@pierrelasse/plugins/combat")

-- Set the default combat timer duration.
combat.TIMER = 15 -- seconds

-- Set callback to update the display.
-- It is called atleast every second for players in combat.
combat.DISPLAY_FUNC = function(player, timer)
    bukkit.sendActionBar(player, "§7Combat: §c"..timer)
end
```

### [pierrelasse/plugins/combatListener](./@pierrelasse/plugins/combatListener.lua)

Implementation that manages what happens if a player is attacked, dies, or logs out.

Configurable using:

```lua
local combatListener = require("@pierrelasse/plugins/combatListener")

-- Set what happens if a player logs out while in combat.
combatListener.ON_LOGOUT = function(player)
    player.setHealth(0) -- kills the player
end

-- If a player should get set into combat when attacked/attacking or not.
combatListener.CAN_ENTER_COMBAT = function(victim, attacker)
    -- victims always get put into combat
    local canVictimEnter = true

    -- attackers get put into combat if not in creative or spectator mode
    local canAttackerEnter = not bukkit.isInCreativeOrSpec(attacker)

    return canVictimEnter, canAttackerEnter
end

-- Set what happens on a player's death.
combatListener.ON_DEATH = function(player)
    return true -- if the player should exit combat or not
end
```

### [pierrelasse/plugins/economy](./@pierrelasse/plugins/economy.lua)

Interface for storing & managing balances.<br>
A Vault integration might be added later.

### [pierrelasse/plugins/eval](./@pierrelasse/plugins/eval.lua)

Run code ingame using `/eval <code...>`.

Example: `/eval print("hello!")`<br>
Permission: `scripting.eval`
