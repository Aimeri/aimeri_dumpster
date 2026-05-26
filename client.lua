local QBCore = exports['qbx_core']:GetCoreObject()

local insideDumpster = false

local dumpsters = {
    `prop_dumpster_01a`,
    `prop_dumpster_02a`,
    `prop_dumpster_02b`,
    `prop_dumpster_3a`,
    `prop_dumpster_4a`,
    `prop_dumpster_4b`,
    `prop_bin_02a`,
    `prop_bin_01a`,
    `prop_bin_05a`,
    `prop_bin_07a`,
    `prop_bin_07c`,
    `prop_bin_08a`
}

local function notify(msg, type)
    lib.notify({ description = msg, type = type or "inform" })
end

local function playAnim(dict, anim, flag)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(10) end
    TaskPlayAnim(PlayerPedId(), dict, anim, 3.0, 3.0, -1, flag, 0, false, false, false)
end

local function stopAnim()
    ClearPedTasks(PlayerPedId())
end

local function getClosestDumpsterName()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    local closest, dist = nil, 2.5

    for _, model in pairs(dumpsters) do
        local obj = GetClosestObjectOfType(coords, 2.5, model, false, false, false)

        if obj ~= 0 then
            local objCoords = GetEntityCoords(obj)
            local d = #(coords - objCoords)

            if d < dist then
                closest = objCoords
                dist = d
            end
        end
    end

    if closest then
        return ("dumpster_%d_%d_%d"):format(
            math.floor(closest.x),
            math.floor(closest.y),
            math.floor(closest.z)
        )
    end

    return nil
end

CreateThread(function()
    for _, model in pairs(dumpsters) do
        exports.ox_target:addModel(model, {
            {
                name = "open_dumpster",
                icon = "fa-solid fa-box-open",
                label = "Open Dumpster",
                distance = 2.5,
                onSelect = function()
                    TriggerEvent("aimeri_dumpster:client:openDumpster")
                end
            },
            {
                name = "search_dumpster",
                icon = "fa-solid fa-magnifying-glass",
                label = "Search Dumpster",
                distance = 2.5,
                onSelect = function()
                    TriggerEvent("aimeri_dumpster:client:searchDumpster")
                end
            },
            {
                name = "hide_dumpster",
                icon = "fa-solid fa-user-secret",
                label = "Hide In Dumpster",
                distance = 2.5,
                onSelect = function()
                    TriggerEvent("aimeri_dumpster:client:HideInDumpster")
                end
            }
        })
    end
end)

RegisterNetEvent("aimeri_dumpster:client:openDumpster", function()
    local name = getClosestDumpsterName()
    if not name then return end

    playAnim("missheist_agency3aig_23", "urinal_sink_loop", 49)

    local cancelled = not lib.progressBar({
        duration = 2000,
        label = "Opening Dumpster",
        canCancel = true,
        disable = { move = true, car = true, combat = true }
    })

    stopAnim()

    if cancelled then return notify("Cancelled", "error") end

    TriggerServerEvent("aimeri_dumpster:server:openDumpsterInventory", name)
end)

RegisterNetEvent("aimeri_dumpster:client:searchDumpster", function()
    local name = getClosestDumpsterName()
    if not name then return end

    --local success = lib.skillCheck({'easy','easy','medium'}, {'w','a','s','d'})

    local success = lib.skillCheck(Config.SkillChecks.search, {'w', 'a', 's', 'd'})

    if not success then
        return notify("Failed to search dumpster", "error")
    end

    playAnim("missheist_agency3aig_23", "urinal_sink_loop", 49)

    local cancelled = not lib.progressBar({
        duration = 2000,
        label = "Searching Dumpster",
        canCancel = false,
        disable = { move = true, car = true, combat = true }
    })

    stopAnim()

    if cancelled then return end

    TriggerServerEvent("aimeri_dumpster:server:searchDumpster", name)
end)

RegisterNetEvent("aimeri_dumpster:client:HideInDumpster", function()
    local ped = PlayerPedId()

    local cancelled = not lib.progressBar({
        duration = 5000,
        label = "Opening Lid",
        canCancel = true,
        disable = { move = true, car = true, combat = true }
    })

    if cancelled then return end

    local pos = GetEntityCoords(ped)

    for _, model in pairs(dumpsters) do
        local obj = GetClosestObjectOfType(pos, 1.5, model, false, false, false)

        if obj ~= 0 then
            AttachEntityToEntity(ped, obj, -1, 0.0, -0.2, 2.0, 0, 0, 0, true, true, true, false, 2, true)

            playAnim("timetable@floyd@cryingonbed@base", "base", 1)

            SetEntityVisible(ped, false)
            insideDumpster = true

            CreateThread(function()
                while insideDumpster do
                    Wait(0)

                    lib.showTextUI("[E] Exit Dumpster")

                    if IsControlJustReleased(0, 38) then
                        insideDumpster = false
                        ClearPedTasks(ped)
                        DetachEntity(ped, true, true)
                        SetEntityVisible(ped, true)
                        lib.hideTextUI()
                    end
                end
            end)
        end
    end
end)

exports.ox_inventory:registerHook('useItem', function(payload)
    local name = payload.item.name
    local dumpsterName = getClosestDumpsterName()
    if not dumpsterName then return end

    if name == 'padlock' then
        TriggerServerEvent('aimeri_dumpster:server:padlockDumpster', dumpsterName)

    elseif name == 'bobbypin' then
        --local success = lib.skillCheck({'medium','hard','hard'}, {'w','a','s','d'})
        local success = lib.skillCheck(Config.SkillChecks.bobbypin, {'w', 'a', 's', 'd'})
        TriggerServerEvent('aimeri_dumpster:server:attemptBobbyPin', dumpsterName, success)
    end
end)