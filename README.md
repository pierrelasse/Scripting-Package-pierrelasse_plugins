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

### [pierrelasse/plugins/commands/anvil](./@pierrelasse/plugins/commands/anvil.lua)

A simple /anvil command.

Configurable using:

```lua
paman.needAndApply("pierrelasse/plugins/commands/anvil", function(p)
    p.COMMAND = "anvil"
    p.PERMISSION = "commands.anvil"
end)
```

### [pierrelasse/plugins/commands/bring](./@pierrelasse/plugins/commands/bring.lua)

Teleport a player to you using `/bring <target: player>`.

Configurable using:

```lua
paman.needAndApply("pierrelasse/plugins/commands/bring", function(p)
    p.COMMAND = "bring"
    p.PERMISSION = "commands.bring"
end)
```

### [pierrelasse/plugins/commands/craft](./@pierrelasse/plugins/commands/craft.lua)

A simple `/craft` command.

Configurable using:

```lua
paman.needAndApply("pierrelasse/plugins/commands/craft", function(p)
    p.COMMAND = "craft"
    p.PERMISSION = "commands.craft"
end)
```

### [pierrelasse/plugins/commands/feed](./@pierrelasse/plugins/commands/feed.lua)

Restore a player's food bar using `/feed <target: player>`.

Configurable using:

```lua
paman.needAndApply("pierrelasse/plugins/commands/feed", function(p)
    p.COMMAND = "feed"
    p.PERMISSION = "commands.feed"
end)
```

### [pierrelasse/plugins/commands/gamemode](./@pierrelasse/plugins/commands/gamemode.lua)

Adds `/gm <gameMode> [<target: player>]` and `/gm<gameMode> [<target: player>]`.

Configurable using:

```lua
paman.needAndApply("pierrelasse/plugins/commands/gamemode", function(p)
    p.PERMISSION = "commands.gm"

    -- Remove `/gms` & `/gm survival`.
    p.MAP[bukkit.gameMode("SURVIVAL")] = nil
end)
```

### [pierrelasse/plugins/commands/goto](./@pierrelasse/plugins/commands/goto.lua)

Teleport you to a player using `/goto <target: player>`.

Configurable using:

```lua
paman.needAndApply("pierrelasse/plugins/commands/goto", function(p)
    p.COMMAND = "goto"
    p.PERMISSION = "commands.goto"
end)
```

### [pierrelasse/plugins/commands/heal](./@pierrelasse/plugins/commands/heal.lua)

Restore a player's health & food bar using `/heal <target: player>`.<br>
Uses `pierrelasse/plugins/commands/feed` to restore the food bar.

Configurable using:

```lua
paman.needAndApply("pierrelasse/plugins/commands/heal", function(p)
    p.COMMAND = "heal"
    p.PERMISSION = "commands.heal"
    p.FEED = true
end)
```

### [pierrelasse/plugins/commands/hp](./@pierrelasse/plugins/commands/hp.lua)

Set a player's health using `/hp <target: player> <amount: number>`.<br>
Example: `/hp player1 10` - Sets the health of player1 to 5 hearts.

Configurable using:

```lua
paman.needAndApply("pierrelasse/plugins/commands/hp", function(p)
    p.COMMAND = "hp"
    p.PERMISSION = "commands.hp"
end)
```

### [pierrelasse/plugins/commands/invulnerable](./@pierrelasse/plugins/commands/invulnerable.lua)

Set a player's invulnerable state using `/invulnerable <target: player> [<state: boolean>]`.<br>
This is basically a /god command.

Configurable using:

```lua
paman.needAndApply("pierrelasse/plugins/commands/invulnerable", function(p)
    p.COMMAND = { "invulnerable", "god" }
    p.PERMISSION = "commands.invulnerable"
end)
```

### [pierrelasse/plugins/commands/respawn](./@pierrelasse/plugins/commands/respawn.lua)

Respawn a dead player using `/respawn <target: player>`.<br>

Configurable using:

```lua
paman.needAndApply("pierrelasse/plugins/commands/respawn", function(p)
    p.COMMAND = "respawn"
    p.PERMISSION = "commands.respawn"
end)
```

### [pierrelasse/plugins/customItems](./@pierrelasse/plugins/customItems/)

WIP.

Library for creating items with "abilities".

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

### [pierrelasse/plugins/staff/log](./@pierrelasse/plugins/staff/log.lua)

Interface for messaging staff.

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

### [pierrelasse/plugins/headDrops](./@pierrelasse/plugins/headDrops.lua)

Drop heads for mobs on death.

ie. if you kill a creeper, it drops their head.

Configurable using:

```lua
local headDrops = require("@pierrelasse/plugins/headDrops")

-- Disable drops for allays.
headDrops.MAP.ALLAY = nil

-- Make cows drop a stone.
headDrops.MAP.COW = { material = "STONE" }

-- Make spiders drop a custom item.
headDrops.MAP.SPIDER = function(entity)
    return bukkit.buildItem("STICK")
        :name("Spider Stick")
end

-- Map all drops.
headDrops.ITEM = function(entity, drop)
    -- 30% chance that there is no drop.
    if random:chance(30) then
        return nil
    end

    return drop
end
```

### [pierrelasse/plugins/homes](./@pierrelasse/plugins/homes.lua)

Interface for storing & managing home locations.

Configurable using:

```lua
local homes = require("@pierrelasse/plugins/homes")

-- Set the max homes for all players to 5.
-- `playerId` is the uuid of the requested player as string.
homes.GET_MAX_HOMES = function(playerId)
    return 5
end

-- Add 'myworld' as an allowed world.
homes.ALLOWED_WORLDS.add("myworld")

-- Disallow setting homes in the nether.
homes.ALLOWED_WORLDS.remove("world_nether")
```

### [pierrelasse/plugins/playerDeathLightning](./@pierrelasse/plugins/playerDeathLightning.lua)

Spawns an effect only (no damage or fire) lightning on player deaths.

### [pierrelasse/plugins/switchAccount](./@pierrelasse/plugins/switchAccount.lua)

Allows you to log in as other players.

Example:

1. Player1: /switchaccount Player2
2. Player1 reconnects
3. Player1 joins as Player2
4. Player2 (secretly Player2) reconnects
5. Player1 joins

Useful for recording, testing, and much more!
