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
---@field abilityLeftClick? pierrelasse.plugins.customItems.Item.Ability<pierrelasse.lib.clickListener.Event>
---@field abilityRightClick? pierrelasse.plugins.customItems.Item.Ability<pierrelasse.lib.clickListener.Event>
---@field abilityConsume? pierrelasse.plugins.customItems.Item.Ability<{ player: bukkit.entity.Player; itemStack: bukkit.ItemStack; }>
---@field abilityPlace? pierrelasse.plugins.customItems.Item.Ability<{ player: bukkit.entity.Player; block: bukkit.block.Block; itemStack: bukkit.ItemStack; }>
local this = {}
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
        :use(function(builder)
            local lore = {}

            if self.description ~= nil then
                for line in forEach(cmpToStr(self.description):split("\n")) do
                    lore[#lore + 1] = "§7"..line
                end
            end

            ---@param ability pierrelasse.plugins.customItems.Item.Ability
            ---@param action string
            local function add(ability, action)
                if ability == nil then return end
                if ability.hidden == true then return end

                lore[#lore + 1] = ""
                if ability.name == nil then
                    lore[#lore + 1] = "§#15a3d7§l"..action
                else
                    lore[#lore + 1] = "§#7ff1f1§n"..cmpToStr(ability.name).."§#15a3d7 §l"..action
                end
                if ability.description ~= nil then
                    for line in forEach(cmpToStr(ability.description):split("\n")) do
                        lore[#lore + 1] = "§7"..line
                    end
                end
            end

            add(self.abilityLeftClick, "LEFT-CLICK")
            add(self.abilityRightClick, "RIGHT-CLICK")
            add(self.abilityConsume, "CONSUME")
            add(self.abilityPlace, "PLACE")

            builder:lore(lore)
        end)
end

manager.Item = this
return this
