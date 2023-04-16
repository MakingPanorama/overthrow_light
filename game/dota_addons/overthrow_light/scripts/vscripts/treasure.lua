--[[
    Name: Treasure System
    Description: Treasure system in overthrow is needed to make game
    more intresting and give chance to weak player comeback. This is very optional,
    but you can make yours system.
--]]
if treasure == nil then
    treasure = {}
end

-- Load tiers item that should be dropped from treasure
local tiers_item = LoadKeyValues("scripts/treasure/tiers.kv")
-- Init default treasure locals
treasureSpawnLocation = 0
treasureTimeDelay = 180
-- Initliaze process
function treasure:Init()
    -- First timer init for treasure
    --[[CustomGameEventManager:Send_ServerToAllClients("timer_refresh", {
        time = treasureTimeDelay
    })]]

    -- Instead of making this we can use nettables for more productivity
    CustomNetTables:SetTableValue("game_state", "timers", {
        timeTreasure = treasureTimeDelay,
    })
    

    -- Create timer to make work treasure system
    Timers:CreateTimer(treasureTimeDelay, function()
        self:StartTreasure()
        return treasureTimeDelay
    end)
end

function treasure:GetRSpawnEntity()
    local nMaxSpawns = 8
    if GetMapName() == "desert_quintet" then
        print("map is desert_quintet")
        nMaxSpawns = 6
    elseif GetMapName() == "temple_quartet" then
        print("map is temple_quartet")
        nMaxSpawns = 4
    end
    local spawnEntity = Entities:FindByName(nil, "item_spawn_"..RandomInt(1, nMaxSpawns))
    return spawnEntity
end

function treasure:StartTreasure()
    -- Create a vision in treasure location
    local entity = self:GetRSpawnEntity()
    createUnitRevealVision( entity:GetAbsOrigin() )
    -- Send event to player side
    CustomGameEventManager:Send_ServerToAllClients("warning_treasure_popup", {
        duration = 3
    }) 
    -- Second make a delay then create treasure courier that will reach the target and drop treasure
    self:startMoving( entity )
    -- Play sound
    EmitGlobalSound( "Overthrow.Item.Warning" )
    print('[OVERTHROW LIGHT] Treasure preparing.')
end

function treasure:startMoving( entity )
    Timers:CreateTimer(10, function()
        local courier = CreateUnitByName('npc_dota_treasure_courier', Vector(0,0,700), false, nil, nil, DOTA_TEAM_GOODGUYS)
        courier:AddNewModifier(courier, nil, "modifier_treasure_courier_invulnerable", {})
        courier:SetInitialGoalEntity( entity )
    end)
end

function createUnitRevealVision( vLocation )
    -- Create vision revealer unit
    local unit = CreateUnitByName("npc_vision_revealer", vLocation, false, nil, nil, DOTA_TEAM_GOODGUYS)
    -- Set custom identifier for comfortable using __index
    unit.customIdentifier = "vision_revealer"
    -- Add modifier to unit to provide vision
    unit:AddNewModifier(unit, nil, "modifier_treasure_vision_granter", {})
    -- Create timer to remove unit
    Timers:CreateTimer(15, function()
        UTIL_Remove(unit)
    end)
end

-- Drops treasure
function treasure:TreasureDrop( npc )
    -- Create item in world and launch
    local origin = npc:GetAbsOrigin()
    local treasureItem = CreateItem("item_treasure_chest", npc, npc)
    local drop = CreateItemOnPositionForLaunch(origin + Vector(0,0,400), treasureItem)
    treasureItem:LaunchLootInitialHeight(false, 0, 0, 0.5, Vector(origin.x,origin.y,0))
    treasureItem:SetForwardVector(treasureItem:GetRightVector())
    -- After 0.75 delay knockback all units in 200 radius
    Timers:CreateTimer(0.3, function()
        local unitsInRadius = FindUnitsInRadius(DOTA_TEAM_NOTEAM, origin, nil, 200, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
        local center = origin
        local modifierKnockback =
	    {   
            center_x = center.x,
            center_y = center.y,
            center_z = center.z,
            duration = 0.4,
            knockback_duration = 0.4,
            knockback_distance = 400,
            knockback_height = 200,
	    }

        for _, unit in pairs(unitsInRadius)  do
            unit:AddNewModifier( unit, nil, "modifier_knockback", modifierKnockback )
        end
    end)
    -- Play sound
    EmitGlobalSound( "lockjaw_Courier.Impact" )
	EmitGlobalSound( "lockjaw_Courier.gold_big" )
    print('[OVERTHROW LIGHT] Treasure delivered!')
    -- Refresh treasure timer
    CustomNetTables:SetTableValue("game_state", "timers", {
        timeTreasure = treasureTimeDelay,
    })
    -- When courier reaches the goal, drop treasure
    print(treasureItem)
    UTIL_Remove(npc)
end