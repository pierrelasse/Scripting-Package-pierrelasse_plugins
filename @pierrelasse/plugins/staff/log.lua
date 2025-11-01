local nameFormatter = require("@pierrelasse/lib/nameFormatter")


---@alias pierrelasse.plugins.staff.log.CanSee fun(player: bukkit.entity.Player): boolean

---@class pierrelasse.plugins.staff.log.Formatter
local Formatter = {
    ---@private
    ---@type pierrelasse.plugins.staff.log.Logger
    log = nil
}
Formatter.__index = Formatter

---@param player bukkit.entity.Player|java.Object
function Formatter:player(player)
    -- TODO
    if not bukkit.isPlayer(player) then
        return comp.text("CONSOLE")
            .hoverEvent(comp.hoverEvent("SHOW_TEXT", comp.text("This is the console or a command block, etc.")))
    end ---@cast player bukkit.entity.Player

    local playerName = player.getName()

    local hover = comp.text(playerName)
        .appendNewline()
        .append(comp.text(player.getUniqueId().toString())
            .color(comp.colorN("DARK_GRAY")))
        .appendNewline()
        .append(comp.text("Click to spectate!"))

    return comp.legacyDeserialize(nameFormatter.prefixName(player))
        .hoverEvent(comp.hoverEvent("SHOW_TEXT", hover))
        .clickEvent(comp.clickEvent("SUGGEST_COMMAND", "/spec "..playerName))
end

---@class pierrelasse.plugins.staff.log.Logger
local this = {
    ---@type java.List<string>
    path = nil,
    ---@type pierrelasse.plugins.staff.log.Formatter
    formatter = nil,

    ---@type string?
    name = nil,
    ---@type string|adventure.text.Component?
    description = nil,
    ---@type java.List<pierrelasse.plugins.staff.log.CanSee>
    canSee = nil,

    baseCmp = comp.empty()
}
this.__index = this

---@package
function this.new()
    local self = setmetatable({}, this)

    self.path = java.list()
    self.formatter = setmetatable({ log = self }, Formatter)
    self.canSee = java.list()

    return self
end

---@param id string
---@param name? string
---@param canSee? pierrelasse.plugins.staff.log.CanSee
function this:sub(id, name, canSee)
    local new = setmetatable({}, { __index = self })

    new.path = self.path.clone()
    new.path.add(id)

    new.name = name

    new.canSee = self.canSee.clone()
    if canSee ~= nil then
        new.canSee.add(canSee)
    end

    return new
end

function this:getPrefix()
    return comp.mm(self.name == nil
        and "<dark_aqua>[<aqua>S<dark_aqua>]"
        or "<dark_aqua>[<aqua>S "..self.name.."<dark_aqua>]")
end

---@param message string|adventure.text.Component|(fun(l: pierrelasse.lang.Locale, fmt: pierrelasse.plugins.staff.log.Formatter): adventure.text.Component)
---@param filter? (bukkit.entity.Player|java.Object)|(fun(p: bukkit.entity.Player): nil|boolean)
function this:log(message, filter)
    local pathStr = arrays.concat(self.path.toArray(), "/")

    local prefix_hover = comp.from("§7This is a staff message!") -- TODO
    if self.description ~= nil then
        prefix_hover = prefix_hover
            .appendNewline().append(comp.from(self.description))
    end
    prefix_hover = prefix_hover.appendNewline().append(comp.text(pathStr).color(comp.colorN("DARK_GRAY")))

    local prefix = self:getPrefix()

    local getMessage ---@type fun(l: pierrelasse.lang.Locale): adventure.text.Component
    if type(message) == "function" then
        getMessage = message
    elseif comp.is(message) then ---@cast message adventure.text.Component
        getMessage = function() return message end
    else
        getMessage = function() return comp.from(tostring(message)) end
    end

    if type(filter) ~= "function" and filter ~= nil then
        if bukkit.isPlayer(filter) then
            local filtering = filter
            filter = function(p) return p ~= filtering end
        else
            filter = nil
        end
    end

    Lang.sendMult(
        function(l)
            return self.baseCmp
                .append(prefix.hoverEvent(comp.hoverEvent("SHOW_TEXT", prefix_hover)))
                .appendSpace()
                .append(getMessage(l, self.formatter))
        end,
        bukkit.playersLoop(),
        function(p)
            for predicate in forEach(self.canSee) do
                if predicate(p) == false then return false end
            end
            if filter and filter(p) == false then return false end
            return true
        end
    )
end

---@class pierrelasse.plugins.staff.log.StaffLogger.Base : pierrelasse.plugins.staff.log.Logger
---@field dark pierrelasse.plugins.staff.log.Logger
local self = this.new()
self.canSee.add(function(player)
    return player.hasPermission("!.staff") or player.isOp()
end)

local dark = this.new()
self.dark = dark
dark.canSee = self.canSee
dark.baseCmp = comp.mm("<#B3B3B3><i>")
function dark:getPrefix()
    return comp.mm(self.name == nil
        and "<dark_gray>[<gray>S</gray>]"
        or "<dark_gray>[<gray>S</gray>] [<gray>"..self.name.."</gray>]")
end

return self
