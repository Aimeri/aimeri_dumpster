local QBCore = exports['qbx_core']:GetCoreObject()

local dumpsterLocks = {}
local dumpsterCooldowns = {}

math.randomseed(os.time())

local function notify(src, msg, type)
    TriggerClientEvent('ox_lib:notify', src, {
        description = msg,
        type = type or "inform"
    })
end

local function getRandomLoot()
    local loot = {}

    if math.random(1, 100) <= 33 then
        return loot
    end

    local common = Config.CommonLoot[math.random(#Config.CommonLoot)]
    table.insert(loot, {
        item = common.item,
        quantity = math.random(common.min, common.max)
    })

    for _, rare in pairs(Config.RareLoot) do
        if math.random(1, 100) <= rare.chance then
            table.insert(loot, {
                item = rare.item,
                quantity = rare.quantity
            })
            break
        end
    end

    return loot
end

RegisterNetEvent('aimeri_dumpster:server:searchDumpster', function(name)
    local src = source

    if dumpsterCooldowns[name] and os.time() - dumpsterCooldowns[name] < Config.Cooldown then
        return notify(src, "Dumpster is on cooldown", "error")
    end

    dumpsterCooldowns[name] = os.time()

    local loot = getRandomLoot()

    for _, v in pairs(loot) do
        exports.ox_inventory:AddItem(src, v.item, v.quantity)
    end

    notify(src, "You found something!", "success")
end)

RegisterNetEvent('aimeri_dumpster:server:openDumpsterInventory', function(name)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)

    if not player then return end

    local cid = player.PlayerData.citizenid

    if dumpsterLocks[name] and dumpsterLocks[name].owner ~= cid then
        return notify(src, "Locked dumpster", "error")
    end

    exports.ox_inventory:openInventory('stash', {
        id = name,
        label = "Dumpster",
        slots = 40,
        weight = 1000000
    })
end)

RegisterNetEvent('aimeri_dumpster:server:padlockDumpster', function(name)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)

    local cid = player.PlayerData.citizenid

    if dumpsterLocks[name] then
        return notify(src, "Already locked", "error")
    end

    dumpsterLocks[name] = { owner = cid }

    MySQL.insert('INSERT INTO aimeri_dumpster (dumpster_name, owner_cid) VALUES (?, ?)', {
        name, cid
    })

    exports.ox_inventory:RemoveItem(src, 'padlock', 1)

    notify(src, "Dumpster locked", "success")
end)

RegisterNetEvent('aimeri_dumpster:server:attemptBobbyPin', function(name, success)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)

    local lock = dumpsterLocks[name]
    if not lock then return notify(src, "Not locked", "error") end

    exports.ox_inventory:RemoveItem(src, 'bobbypin', 1)

    if success then
        dumpsterLocks[name] = nil
        MySQL.query('DELETE FROM aimeri_dumpster WHERE dumpster_name = ?', { name })
        notify(src, "Unlocked!", "success")
    else
        notify(src, "Failed", "error")
    end
end)