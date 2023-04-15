-- Instead of creating abilities I'll creating modifiers that should be more easy to use anyways
LinkLuaModifier("modifier_treasure_courier_invulnerable", "utils/modifiers.lua", LUA_MODIFIER_MOTION_NONE)
modifier_treasure_courier_invulnerable = class({})

function modifier_treasure_courier_invulnerable:IsPurgable()
    return false
end

function modifier_treasure_courier_invulnerable:IsPassive()
    return true
end

function modifier_treasure_courier_invulnerable:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_PROVIDES_VISION] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true
    }
end

function modifier_treasure_courier_invulnerable:GetEffectName()
    return "" -- Something to put here
end

function modifier_treasure_courier_invulnerable:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

LinkLuaModifier("modifier_treasure_vision_granter", "utils/modifiers.lua", LUA_MODIFIER_MOTION_NONE)
modifier_treasure_vision_granter = class({})

function modifier_treasure_vision_granter:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_PROVIDES_VISION] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true 
    }
end