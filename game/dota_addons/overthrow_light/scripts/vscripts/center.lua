--[[
    Name: Center
    Description: Because I'm lazy to add overboss unit AI I decided to make a init with timer
--]]
-- I would appreciate to not use unit overboss, so I do init and make a timer
function COverthrowLight:InitCenter()
    -- Create timer that will randomly toss coin
    Timers:CreateTimer(RandomInt(3, 10), function()
        -- Toss coin
        self:TossCoin( Vector(0,0,0) )
        return RandomInt(2, 10)
    end)
end

function COverthrowLight:TossCoin( vLocation )
    -- Create coin and launch it
    local coin = CreateItem("item_bag_of_gold", nil, nil)
    local toss = CreateItemOnPositionForLaunch(Vector(0,0,0), coin)
    coin:LaunchLoot(false, 700, 0.75, vLocation + RandomVector(RandomInt(200, 830)))
    coin:SetCurrentCharges( 150 )

    -- Remove after some delay
    Timers:CreateTimer(10, function()
        UTIL_Remove(coin)
        UTIL_Remove(toss)
    end)
end