--[[
	Author: MakingPanorama
	Description: The lightweightest template addon Overthrow
]]

if _G.COverthrowLight == nil then
	_G.COverthrowLight = class({})
end

-- Required files
require('events')
require('utils/timers')
require('treasure')

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]

	-- Precache only NEED resources to add them
	PrecacheResource("particle", "particles/experience_border.vpcf", context)

	PrecacheItemByNameSync( "item_bag_of_gold", context )

	PrecacheResource( "particle", "particles/items2_fx/veil_of_discord.vpcf", context )	
	PrecacheResource( "particle", "particles/treasure_courier_death.vpcf", context )

	PrecacheItemByNameSync( "item_treasure_chest", context )
	PrecacheModel( "item_treasure_chest", context )

	PrecacheResource( "soundfile", "soundevents/game_sounds_overthrow.vsndevts", context )
end

-- Create the game mode when we activate
function Activate()
	COverthrowLight:InitGameMode()
end

function COverthrowLight:InitGameMode()
	print( "[OVERTHROW LIGHT] Addon Loading" )
	print( "[OVERTHROW LIGHT] Addon Version: 0.01 pre-alpha" )
	print( "[OVERTHROW LIGHT] Light Version: 0.2 alpha" )
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
	
	--- Example listener
	--ListenToGameEvent("do", Dynamic_Wrap(COverthrowLight, 'DOSOMETHING'), self)
	ListenToGameEvent( "dota_npc_goal_reached", Dynamic_Wrap( COverthrowLight, "OnNPCGoalReached" ), self )
	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( COverthrowLight, "OnStateChanged" ), self )

	-- Register color for teams
	self.m_TeamColors = {}
	self.m_TeamColors[DOTA_TEAM_GOODGUYS] = { 61, 210, 150 }	--		Teal
	self.m_TeamColors[DOTA_TEAM_BADGUYS]  = { 243, 201, 9 }		--		Yellow
	self.m_TeamColors[DOTA_TEAM_CUSTOM_1] = { 197, 77, 168 }	--      Pink
	self.m_TeamColors[DOTA_TEAM_CUSTOM_2] = { 255, 108, 0 }		--		Orange
	self.m_TeamColors[DOTA_TEAM_CUSTOM_3] = { 52, 85, 255 }		--		Blue
	self.m_TeamColors[DOTA_TEAM_CUSTOM_4] = { 101, 212, 19 }	--		Green
	self.m_TeamColors[DOTA_TEAM_CUSTOM_5] = { 129, 83, 54 }		--		Brown
	self.m_TeamColors[DOTA_TEAM_CUSTOM_6] = { 27, 192, 216 }	--		Cyan
	self.m_TeamColors[DOTA_TEAM_CUSTOM_7] = { 199, 228, 13 }	--		Olive
	self.m_TeamColors[DOTA_TEAM_CUSTOM_8] = { 140, 42, 244 }	--		Purple

	for team = 0, (DOTA_TEAM_COUNT-1) do
		color = self.m_TeamColors[ team ]
		if color then
			SetTeamCustomHealthbarColor( team, color[1], color[2], color[3] )
		end
	end

	-- Change slots in teams
	if GetMapName() == "forest_solo" then
		GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 1)
		GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 1)
		local players = GetNumConnectedHumanPlayers() + 1
		for i=0,players do
			GameRules:SetCustomGameTeamMaxPlayers(6+i, 1)
		end
	
	elseif GetMapName() == "desert_duo" then
		GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 2)
		GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 2)
		GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_1, 2)
		GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_2, 2)
	end
end

-- Evaluate the state of the game
function COverthrowLight:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then

	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end