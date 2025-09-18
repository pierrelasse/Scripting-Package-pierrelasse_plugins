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

#### [pierrelasse/plugins/headdb](./@pierrelasse/plugins/headdb/)

WIP.
A very lightweight version of [github/TheSilentPro/HeadDB](https://github.com/TheSilentPro/HeadDB).
