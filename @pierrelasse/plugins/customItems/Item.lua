local cfg = require("@pierrelasse/plugins/customItems/_cfg")
local manager = require("@pierrelasse/plugins/customItems/manager")


---@param v string|adventure.text.Component
local function cmpToStr(v)
    if comp ~= nil and comp.is(v) then
        ---@cast v adventure.text.Component
        return comp.legacySerialize(v)
    end
    return v
end

---@class pierrelasse.plugins.customItems.Item.Ability<E> : {
--- activate: fun(player: bukkit.entity.Player, event: E): nil|true|boolean;
---}
---@field hidden? true|boolean
---@field name? string|adventure.text.Component
---@field description? string|adventure.text.Component

---@class pierrelasse.plugins.customItems.Item
---@field id string
---@field hidden? true
---@field description? string|adventure.text.Component
---@field item? bukkit.ItemBuilder
---@field [string] unknown
---
---@field abilityPassive? pierrelasse.plugins.customItems.Item.Ability<nil>
---@field abilityLeftClick? pierrelasse.plugins.customItems.Item.Ability<pierrelasse.lib.clickListener.Event>
---@field abilityRightClick? pierrelasse.plugins.customItems.Item.Ability<pierrelasse.lib.clickListener.Event>
---@field abilityPlace? pierrelasse.plugins.customItems.Item.Ability<{ block: bukkit.block.Block; itemStack: bukkit.ItemStack; }>
---@field abilityConsume? pierrelasse.plugins.customItems.Item.Ability<{ itemStack: bukkit.ItemStack; }>
---@field abilityShoot? pierrelasse.plugins.customItems.Item.Ability<{ itemStack: bukkit.ItemStack; consumable: bukkit.ItemStack?; projectile: bukkit.Entity; force: java.float; }>
local this = {
    COLOR_ACTION = "<#7ff1f1>",
    COLOR_ACTION_KEY = "<#15a3d7>"
}
this.__index = this

---@param id string
function this.new(id)
    return setmetatable({ id = id }, this)
end

---@param itemStack bukkit.ItemStack
function this:check(itemStack)
    return manager.getFromItem(itemStack).id == self.id
end

function this:validate()
    if self.item == nil then return "MISSING_ITEM" end
end

function this:buildItem()
    return self.item:clone()
        :dataContainer(function(container)
            container.set(cfg.ITEM_ID, "STRING", self.id)
        end)
        :lore(function(lines)
            if self.description ~= nil then
                for line in forEach(cmpToStr(self.description):split("\n")) do
                    lines.add("§7"..line)
                end
            end

            ---@param ability pierrelasse.plugins.customItems.Item.Ability
            ---@param action string
            local function add(ability, action)
                if ability == nil then return end
                if ability.hidden == true then return end

                lines.add("")
                if ability.name == nil then
                    lines.add(comp.legacySerialize(comp.mm(
                        self.COLOR_ACTION_KEY.."<b>"..action
                    )))
                else
                    lines.add(comp.empty()
                        .append(comp.mm(self.COLOR_ACTION).append(comp.from(ability.name))
                            .decorate(comp.textDecoration("underlined")))
                        .append(comp.mm(self.COLOR_ACTION_KEY.." <b>"..action))
                    )
                end
                if ability.description ~= nil then
                    for line in forEach(cmpToStr(ability.description):split("\n")) do
                        lines.add("§7"..line)
                    end
                end
            end

            add(self.abilityPassive, "PASSIVE")
            add(self.abilityLeftClick, "LEFT-CLICK")
            add(self.abilityRightClick, "RIGHT-CLICK")
            add(self.abilityConsume, "CONSUME")
            add(self.abilityPlace, "PLACE")
        end)
end

manager.Item = this
return this
