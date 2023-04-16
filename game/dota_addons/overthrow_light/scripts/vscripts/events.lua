-- Calls when game state has changed
function COverthrowLight:OnStateChanged()
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        -- Initiliaze all system to make work
        COverthrowLight:InitCenter()
        treasure:Init()
        print("[OVERTHROW LIGHT] The state now: ", GameRules:State_Get())
    end
end

-- Calls when npc goal reached
-- Drop item when treasure waypoint is reached
function COverthrowLight:OnNPCGoalReached( kv )
    local npc = EntIndexToHScript( kv.npc_entindex )
    if npc:GetUnitName() == "npc_dota_treasure_courier" then
        treasure:TreasureDrop(npc)
    end
end

-- Calls when team killed hero
-- Initialized nettables for team and increase kills
function COverthrowLight:OnTeamKillCredit( kv )
    local teamnumber = kv.teamnumber

    local team = CustomNetTables:GetTableValue("game_state", "team_"..teamnumber)
    local game_info = CustomNetTables:GetTableValue("game_state", "game_info")
    if team then
        -- Team will win after passing limit of kills
        if team["kills"] >= game_info["int_kills"] then
            GameRules:SetGameWinner( teamnumber )
            print("[OVERTHROW LIGHT] Team by "..teamnumber.." won!")
        end

        CustomNetTables:SetTableValue("game_state", "team_"..teamnumber, {
            kills = tonumber(team["kills"]) + 1,
        })

        print( "[OVERTHROW LIGHT] Succesfuly changed nettable \"team_"..teamnumber.." in \"game_state\"" )
        return
    else
        print( "[OVERTHROW LIGHT] This key is not exists in nettable..." )
    end

    -- Adding team to count kills
    print("[OVERTHROW LIGHT] Adding team in game_state")
    CustomNetTables:SetTableValue("game_state", "team_"..teamnumber, {
        kills = 1,
    })
    print("[OVERTHROW LIGHT] team_"..teamnumber.." successfuly added to game_state")
end

-- Calls when player sends message
-- Can be used for debugging and custom chat
function COverthrowLight:OnChatEvent( kv )
    local message = kv.text
    local prefix = "!"
    if ( message:startsWith(prefix) ) then
        -- Testing server
        --[[if message:contains("test_server") then
            local args = message:split(" ")
            DeepPrintTable(args)
            if #args >= 1 then
                local command = args[1]
                local numOfRequests = tonumber(args[2])
                print( "Number of requests: ", numOfRequests, type(numOfRequests) )
                print( "Command: ", command)

                for i=1, numOfRequests do
                    COverthrowHTTP:TestCall(i)
                end
            end
        end--]]
    end
end