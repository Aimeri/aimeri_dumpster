Config = {}

Config.DebugLock = false

Config.Target = "ox_target"

Config.Cooldown = 300

Config.SkillChecks = {
    search = { 'easy', 'easy', 'medium' },
    bobbypin = { 'medium', 'hard', 'hard' }
}

Config.DumpsterProps = {
    `prop_dumpster_01a`,
    `prop_dumpster_02a`,
    `prop_dumpster_02b`,
    `prop_dumpster_4a`,
    `prop_dumpster_4b`,
}

Config.CommonLoot = {
    { item = 'recyclablematerial', min = 1, max = 3 },
    --{ item = 'item_name', min = 1, max = 4 },
}

Config.RareLoot = {
    { item = 'pistol_ammo', chance = 3, quantity = 1 },
    --{ item = 'item_name', chance = 4, quantity = 1 },
}