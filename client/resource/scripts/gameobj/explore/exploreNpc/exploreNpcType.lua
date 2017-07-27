local config = {
    PIRATE = "pirate",
    PIRATE_BOSS = "pirate_boss",
    REWARD_PIRATE = "reward_pirate",
    MISSION_XUANWO = "mission_xuanwo",
    MINERAL_POINT = "mineral_point",
    WORLD_MISSION = "world_mission",
    MISSION_PIRATE = "mission_pirate",
    CONVOY_MISSION = "convoy_mission", -- 运镖npc
    PLUNDER_MISSION_PIRATE = "plunder_mission_pirate", --主线任务的被掠夺船
    RELIC_EXPLORE_PIRATE = "relic_explore_pirate",
    NPC_CUSTOM_ID = {},
}

config.NPC_CUSTOM_ID[config.REWARD_PIRATE] = -1
config.NPC_CUSTOM_ID[config.MISSION_XUANWO] = -2
config.NPC_CUSTOM_ID[config.WORLD_MISSION] = -3
config.NPC_CUSTOM_ID[config.MISSION_PIRATE] = -4
config.NPC_CUSTOM_ID[config.CONVOY_MISSION] = -5
config.NPC_CUSTOM_ID[config.PLUNDER_MISSION_PIRATE] = -6
config.NPC_CUSTOM_ID[config.RELIC_EXPLORE_PIRATE] = "relic_pirate_npc_%d"

return config
