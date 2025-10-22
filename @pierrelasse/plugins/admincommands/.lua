local Permission = import("org.bukkit.permissions.Permission")

local paman = require("@base/paman")
local cfg = require("@pierrelasse/plugins/admincommands/_cfg")


---@diagnostic disable: deprecated
events.onStarted(function()
    local pluginManager = bukkit.Bukkit.getPluginManager()
    ---@param perm string
    ---@param addPerm string
    local function addPermChild(perm, addPerm)
        local permission = pluginManager.getPermission(perm)
        if permission == nil then
            permission = Permission(perm)
            pluginManager.addPermission(permission)
        end
        permission.getChildren().put(addPerm, true)
        permission.recalculatePermissibles()
    end

    if cfg.modules.remove("cloneinv") then
        paman.needAndApply("pierrelasse/plugins/commands/copyinventory", function(p)
            p.COMMAND = { "copyinventory", "cloneinv" }
            addPermChild(cfg.permissionPrefix.."cloneinv", "commands.copyinventory")
        end)
    end
    if cfg.modules.remove("ecsee") then
        paman.needAndApply("pierrelasse/plugins/commands/ecsee", function(p)
            addPermChild(cfg.permissionPrefix.."ecsee", "commands.ecsee")
        end)
    end
    if cfg.modules.remove("feed") then
        paman.needAndApply("pierrelasse/plugins/commands/feed", function(p)
            addPermChild(cfg.permissionPrefix.."feed", "commands.feed")
        end)
    end
    if cfg.modules.remove("fly") then
        paman.needAndApply("pierrelasse/plugins/commands/fly", function(p)
            addPermChild(cfg.permissionPrefix.."fly", "commands.fly")
        end)
    end
    if cfg.modules.remove("gamemode") then
        paman.needAndApply("pierrelasse/plugins/commands/gamemode", function(p)
            addPermChild(cfg.permissionPrefix.."gamemode", "commands.gamemode")
        end)
    end
    if cfg.modules.remove("heal") then
        paman.needAndApply("pierrelasse/plugins/commands/heal", function(p)
            addPermChild(cfg.permissionPrefix.."heal", "commands.heal")
        end)
    end
    if cfg.modules.remove("hp") then
        paman.needAndApply("pierrelasse/plugins/commands/hp", function(p)
            addPermChild(cfg.permissionPrefix.."hp", "commands.hp")
        end)
    end
    if cfg.modules.remove("invsee") then
        paman.needAndApply("pierrelasse/plugins/commands/invsee", function(p)
            addPermChild(cfg.permissionPrefix.."invsee", "commands.invsee")
        end)
    end
    if cfg.modules.remove("speed") then
        paman.needAndApply("pierrelasse/plugins/commands/speed", function(p)
            addPermChild(cfg.permissionPrefix.."speed", "commands.speed")
        end)
    end
end)
