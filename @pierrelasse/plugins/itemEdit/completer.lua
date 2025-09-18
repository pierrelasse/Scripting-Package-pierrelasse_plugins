local HashSet = import("java.util.HashSet")
local Material = import("org.bukkit.Material")

local fuzzy = require("@pierrelasse/lib/fuzzy")


---@param s string
local function parseNamespacedKey(s)
    local parts = s:split(":", 3)
    if #parts == 3 then return end
    local namespace, key
    if #parts == 1 then
        namespace = "minecraft"
        key = parts[1]
    else
        namespace = parts[1]
        key = parts[2]
    end
    return bukkit.namespacedKey(key, namespace)
end


local this = {}

do -- material item
    local entries ---@type java.Set<string>
    local function ensure()
        if entries ~= nil then return end
        entries = HashSet(1420)
        for i in forEach(Material.values()) do
            ---@cast i bukkit.Material
            if i.legacy ~= true and i.isItem() then
                entries.add(tostring(i.getKey()))
            end
        end
    end

    ---@param arg string
    function this.materialItemF(arg)
        ensure()
        local n = fuzzy.find(arg, forEach(entries), 15)()
        if n == nil then return end
        return bukkit.materialMatch(n)
    end

    ---@param completions java.List<string>
    ---@param arg string
    function this.materialItemC(completions, arg)
        ensure()
        for v in fuzzy.find(arg, forEach(entries), 15) do
            completions.add(v)
        end
    end
end

do -- enchantment
    local entries ---@type java.Set<string>
    local function ensure()
        if entries ~= nil then return end
        entries = HashSet(45)
        for i in forEach(bukkit.registry.ENCHANTMENT) do
            ---@cast i bukkit.enchantments.Enchantment
            entries.add(tostring(i.getKey()))
        end
    end

    ---@param arg string
    function this.enchantmentF(arg)
        ensure()
        local n = fuzzy.find(arg, forEach(entries), 15)()
        if n == nil or n:isEmpty() then return end
        local key = parseNamespacedKey(n)
        if key == nil then return end
        return bukkit.registry.ENCHANTMENT.get(key)
    end

    ---@param completions java.List<string>
    ---@param arg string
    function this.enchantmentC(completions, arg)
        ensure()
        for v in fuzzy.find(arg, forEach(entries), 15) do
            completions.add(v)
        end
    end
end

return this
