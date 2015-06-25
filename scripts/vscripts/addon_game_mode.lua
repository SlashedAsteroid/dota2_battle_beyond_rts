require( 'libraries/timers' )
require( 'gamemode' )

function Precache( context )
    PrecacheResource( "model_folder", "models/props_structures", context )
    PrecacheResource( "model_folder", "models/creeps/lane_creeps/creep_radiant_ranged", context )
    PrecacheResource( "model_folder", "models/particle", context )
end

function Activate()
	GameRules.AddonTemplate = BattleBeyond()
	GameRules.AddonTemplate:InitGameMode()
end

function BattleBeyond:InitGameMode()
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
	ListenToGameEvent( 'dota_player_pick_hero', Dynamic_Wrap( BattleBeyond, 'OnPlayerPickHero' ), self )
end

function BattleBeyond:OnThink()
	if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end

function BattleBeyond:OnPlayerPickHero( keys )
	local hero = EntIndexToHScript( keys.heroindex )
	local player = EntIndexToHScript( keys.player )
	local playerID = hero:GetPlayerID()
	
	local origin = Vector( 200, 200, 128 )
    
    local settler = CreateUnitByName( "battlebeyond_unit_settler", origin, true, hero, hero, hero:GetTeamNumber() )
    settler:SetOwner( hero )
    settler:SetControllableByPlayer( playerID, true )
    settler:SetAbsOrigin( origin )
end