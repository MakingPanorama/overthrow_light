-- Calls when game state has changed
function COverthrowLight:OnStateChanged()
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        -- Initiliaze treasure.lua to make work
        treasure:Init()
        print("State changed")
    end
end

-- Drop item when treasure waypoint is reached
function COverthrowLight:OnNPCGoalReached( kv )
    local npc = EntIndexToHScript( kv.npc_entindex )
    if npc:GetUnitName() == "npc_dota_treasure_courier" then
        treasure:TreasureDrop(npc)
    end
end