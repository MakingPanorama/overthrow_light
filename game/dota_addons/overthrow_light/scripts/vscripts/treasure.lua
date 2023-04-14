if treasure == nil then
    treasure = {}
end

treasureSpawnLocation = 0
treasureTimeDelay = 180
function treasure:Init()
    treasureTimeDelay = 10

    -- First timer init for treasure
    CustomGameEvent:Send_ServerToAllClients("timer_refresh", {
        time = treasureTimeDelay
    })

    -- Create timer to make work treasure system
    Timers:CreateTimer(treasureTimeDelay, function()
        self:StartTreasure()
        
        return treasureTimeDelay
    end)

    print("Should be initialized")
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
    -- First warn item
    CustomGameEventManager:Send_ServerToAllClients("treasure_appear", {})
    -- Second make a delay then create treasure courier that will reach the target and drop treasure
    self:startMoving()
    -- Play sound
    EmitGlobalSound( "Overthrow.Item.Warning" )
    print('[OVERTHROW LIGHT] Treasure preparing.')
end

function treasure:startMoving()
    Timers:CreateTimer(5, function()
        local courier = CreateUnitByName('npc_dota_treasure_courier', Vector(0,0,700), false, nil, nil, DOTA_TEAM_NEUTRALS)
        courier:FindAbilityByName('dota_ability_treasure_courier'):SetLevel(1)

        local entity = self:GetRSpawnEntity()
        courier:SetInitialGoalEntity( entity )
    end)
end

function treasure:TreasureDrop( npc )
    -- When courier reaches the goal, drop treasure
    npc:RemoveSelf()
    -- Create item in world and place

    -- Play sound
    EmitGlobalSound( "lockjaw_Courier.Impact" )
	EmitGlobalSound( "lockjaw_Courier.gold_big" )
    print('[OVERTHROW LIGHT] Treasure delivered!')
    -- Refresh treasure timer on client-side
    CustomGameEventManager:Send_ServerToAllClients("timer_refresh", {
        time = treasureTimeDelay
    })
end