---@alias pierrelasse.plugins.staff.log.CanSee fun(player: bukkit.entity.Player): boolean

---@class pierrelasse.plugins.staff.log.StaffLogger
local this = {
    ---@type java.List<string>
    path = nil,

    ---@type string?
    name = nil,
    ---@type string|adventure.text.Component?
    description = nil,
    ---@type java.List<pierrelasse.plugins.staff.log.CanSee>
    canSee = nil
}
this.__index = this

---@package
function this.new()
    local self = setmetatable({}, this)

    self.path = java.list()
    self.canSee = java.list()

    return self
end

---@param id string
---@param name? string
---@param canSee? pierrelasse.plugins.staff.log.CanSee
function this:sub(id, name, canSee)
    local new = this.new()

    new.path = self.path.clone()
    new.path.add(id)

    new.name = name

    new.canSee = self.canSee.clone()
    if canSee ~= nil then
        new.canSee.add(canSee)
    end

    return new
end

---@protected
function this:getPrefix()
    return comp.mm(self.name == nil
        and "<dark_aqua>[<aqua>S<dark_aqua>]"
        or "<dark_aqua>[<aqua>S "..self.name.."<dark_aqua>]")
end

---@param message string|adventure.text.Component|(fun(l: pierrelasse.lang.Locale): adventure.text.Component)
function this:log(message)
    local pathStr = arrays.concat(self.path.toArray(), "/")

    local prefix_hover = comp.from("§7This is a staff message!")
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

    Lang.sendMult(
        function(l)
            return comp.empty()
                .append(prefix.hoverEvent(comp.hoverEvent("SHOW_TEXT", prefix_hover)))
                .appendSpace()
                .append(getMessage(l))
        end,
        bukkit.playersLoop(),
        function(p)
            for predicate in forEach(self.canSee) do
                if predicate(p) == false then return false end
            end
            return true
        end
    )
end

local self = this.new()
self.canSee.add(function(player)
    return player.hasPermission("!.staff") or player.isOp()
end)

return self
