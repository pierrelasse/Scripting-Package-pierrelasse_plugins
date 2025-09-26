local cfg = require("@pierrelasse/plugins/customItems/_cfg")
local manager = require("@pierrelasse/plugins/customItems/manager")


---@class pierrelasse.plugins.customItems.Item.Ability
---@field hidden? true|boolean
---@field name? string
---@field description? string
---@field activate fun(player: bukkit.entity.Player, data?: any, event?: java.Object): boolean? ---@return if it activated

---@class pierrelasse.plugins.customItems.Item
---@field id string
---@field description? string
---@field item? bukkit.ItemBuilder
---
---@field abilityLeftClick? pierrelasse.plugins.customItems.Item.Ability
---@field abilityRightClick? pierrelasse.plugins.customItems.Item.Ability
---@field abilityConsume? pierrelasse.plugins.customItems.Item.Ability
---@field abilityPlace? pierrelasse.plugins.customItems.Item.Ability
local this = {}
this.__index = this

function this.new()
    local self = setmetatable({}, this)

    return self
end

---@param id string
---@param builder fun(item: pierrelasse.plugins.customItems.Item)
function manager.make(id, builder)
    local item = this.new()
    item.id = id

    builder(item)

    local err = item:validate()
    if err ~= nil then
        error("could not validate item "..id..": "..err)
    end

    manager.map.put(id, item)
end

---@param itemStack bukkit.ItemStack
function this:check(itemStack)
    return manager.getFromItem(itemStack).id == self.id
end

function this:validate()
    if self.item == nil then
        return "missing item"
    end

    return nil
end

function this:buildItem()
    return self.item:clone()
        :dataContainer(function(container)
            container.set(cfg.ITEM_ID, "STRING", self.id)
        end)
        :use(function(builder)
            local lore = {}

            if self.description ~= nil then
                lore[#lore + 1] = ""
                for line in forEach(self.description:split("\n")) do
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
                    lore[#lore + 1] = "§#7ff1f1§n"..ability.name.."§#15a3d7 §l"..action
                end
                if ability.description ~= nil then
                    for line in forEach(ability.description:split("\n")) do
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

return this
