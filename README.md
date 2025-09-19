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
