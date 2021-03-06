BattleBeyond_unitTypes = {}

BattleBeyond_unitTypes['building_village'] = {}
BattleBeyond_unitTypes['building_village']['model'] = "models/props_structures/good_ancient001.vmdl"
BattleBeyond_unitTypes['building_village']['model_scale'] = 0.6
BattleBeyond_unitTypes['building_village']['collision_hull'] = 170
BattleBeyond_unitTypes['building_village']['max_hp'] = 1800
BattleBeyond_unitTypes['building_village']['abilities'] = { "battlebeyond_ability_unit_create_settler", "battlebeyond_ability_unit_create_worker"  }
BattleBeyond_unitTypes['building_village']['items'] = { "item_battlebeyond_rally_point" }

BattleBeyond_unitTypes['building_barracks'] = {}
BattleBeyond_unitTypes['building_barracks']['model'] = "models/props_structures/good_barracks_melee001.vmdl"
BattleBeyond_unitTypes['building_barracks']['model_scale'] = 0.6
BattleBeyond_unitTypes['building_barracks']['collision_hull'] = 140
BattleBeyond_unitTypes['building_barracks']['max_hp'] = 1000
BattleBeyond_unitTypes['building_barracks']['abilities'] = { "battlebeyond_ability_unit_create_worker", "battlebeyond_ability_unit_create_swordsman", "battlebeyond_ability_unit_create_archer" }
BattleBeyond_unitTypes['building_barracks']['items'] = { "item_battlebeyond_rally_point" }

BattleBeyond_unitTypes['building_armory'] = {}
BattleBeyond_unitTypes['building_armory']['model'] = "models/props_structures/good_statue008.vmdl"
BattleBeyond_unitTypes['building_armory']['model_scale'] = 0.6
BattleBeyond_unitTypes['building_armory']['collision_hull'] = 80
BattleBeyond_unitTypes['building_armory']['max_hp'] = 1200
BattleBeyond_unitTypes['building_armory']['abilities'] = { "battlebeyond_ability_aura_armor_upgrade_1","battlebeyond_ability_aura_weapon_upgrade_1" }
BattleBeyond_unitTypes['building_armory']['items'] = {}

BattleBeyond_unitTypes['building_seige_workshop'] = {}
BattleBeyond_unitTypes['building_seige_workshop']['model'] = "models/props_structures/good_barracks_ranged001.vmdl"
BattleBeyond_unitTypes['building_seige_workshop']['model_scale'] = 0.6
BattleBeyond_unitTypes['building_seige_workshop']['collision_hull'] = 140
BattleBeyond_unitTypes['building_seige_workshop']['max_hp'] = 1200
BattleBeyond_unitTypes['building_seige_workshop']['abilities'] = { }
BattleBeyond_unitTypes['building_seige_workshop']['items'] = { "item_battlebeyond_rally_point" }

BattleBeyond_unitTypes['building_gold_mine'] = {}
BattleBeyond_unitTypes['building_gold_mine']['model'] = "models/props_structures/good_statue010.vmdl"
BattleBeyond_unitTypes['building_gold_mine']['model_scale'] = 0.7
BattleBeyond_unitTypes['building_gold_mine']['collision_hull'] = 80
BattleBeyond_unitTypes['building_gold_mine']['max_hp'] = 700
BattleBeyond_unitTypes['building_gold_mine']['abilities'] = { "battlebeyond_ability_generate_gold" }
BattleBeyond_unitTypes['building_gold_mine']['items'] = {}

function BattleBeyond_createBuilding( event )
    local caster = event.caster
    local owner = caster:GetOwner()
    local player = caster:GetPlayerOwner()
    local unitType = event.unitType
    local origin = ( unitType == 'building_village' ) and caster:GetOrigin() or event.target_points[1]
    
    local building = CreateUnitByName( "battlebeyond_building_template", origin, true, owner, owner, caster:GetTeamNumber() )
    building:RemoveModifierByName( "modifier_invulnerable" )
    building:SetOwner( player:GetAssignedHero() )
    building:SetControllableByPlayer( player:GetPlayerID(), true )
    building:SetAbsOrigin( origin )
    building:SetHullRadius( BattleBeyond_unitTypes[unitType]['collision_hull'] )
    building.Type = unitType
    Timers:CreateTimer(0.01, function()
            building:SetModel( BattleBeyond_unitTypes[unitType]['model'] )
            building:SetModelScale( BattleBeyond_unitTypes[unitType]['model_scale'] )
            building:SetOriginalModel( BattleBeyond_unitTypes[unitType]['model'] )
            building:SetHealth( BattleBeyond_unitTypes[unitType]['max_hp'] )
            BattleBeyond_assignBuildingAbilities( building, unitType )
    end )
    for _, v in pairs( BattleBeyond_unitTypes[unitType]['items'] ) do
        building:AddItemByName( v )
    end
    if ( unitType == 'building_village' ) then
        caster:Destroy()
    end
end

function BattleBeyond_checkArea( event )
    local caster = event.caster
    local unitType = event.unitType
    local origin = ( unitType == 'building_village' ) and caster:GetOrigin() or event.target_points[1]
    
    local units = FindUnitsInRadius( caster:GetTeamNumber(), origin, nil, BattleBeyond_unitTypes[unitType]['collision_hull'], DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
    
    local obstructed = ( #units > 0 ) and true or false
    
    if ( obstructed ) and ( #units == 1 ) and ( unitType == 'building_village' ) then
        return
    elseif ( obstructed ) then
        caster:Stop()
    end
end  

function BattleBeyond_assignBuildingAbilities( building, unitType )
    for _, v in pairs( BattleBeyond_unitTypes[unitType]['abilities'] ) do
        building:AddAbility( v )
        BattleBeyond_updateBuildingAbilityLevel( building, v )
    end
end

function BattleBeyond_updateBuildingAbilityLevel( building, abilityname )
    if ( building:HasAbility( abilityname ) ) then
        local ability = building:FindAbilityByName( abilityname )
        ability:SetLevel( 1 )
    end
end

function BattleBeyond_createUnit( event )
    local caster = event.caster
    local owner = caster:GetOwner()
    local player = caster:GetPlayerOwner()
    local unitType = event.unitType
    local origin = caster:GetOrigin()
    local origin_edit = Vector( 0, 0, 0 ) - origin
    local origin_new = origin + origin_edit:Normalized() * ( BattleBeyond_unitTypes[caster.Type]['collision_hull'] + 40 )
    
    local unit = CreateUnitByName( unitType, origin_new, true, owner, owner, caster:GetTeamNumber() )
    FindClearSpaceForUnit( unit, origin_new, true )
    unit:SetOwner( player:GetAssignedHero() )
    unit:SetControllableByPlayer( player:GetPlayerID(), true )
    
    if ( caster.rally_point ) then
        Timers:CreateTimer( 0.05, function()
                unit:MoveToPosition( caster.rally_point:GetAbsOrigin() )
        end )
    end
end

function BattleBeyond_updateModifier( event )
    local caster = event.caster
    local modifier_name = event.Modifier
    local event_type = event.Type
    local modifier = caster:FindModifierByName( modifier_name )
    local count = caster:GetModifierStackCount( modifier_name, caster )
    local increase = ( event_type == "battlebeyond_event_increase_stack" ) and true or false
    
    if ( modifier:GetDuration() == -1 ) then
        modifier:SetDuration( 5, true )
    end
    
    if ( increase ) then
        modifier:SetDuration( modifier:GetRemainingTime(), true )
        caster:SetModifierStackCount( modifier_name, caster, count + 1 )
    else
        caster:SetModifierStackCount( modifier_name, caster, count - 1 )
        BattleBeyond_createUnit( event )
        modifier:SetDuration( 5, true )
        if ( count == 1 ) then
            caster:RemoveModifierByName( modifier_name )
        end
    end
end

function BattleBeyond_setBuildingRallyPoint( event )
    local caster = event.caster
    local currentFlag = caster.rally_point
    local origin = event.target_points[1]
    
    if ( currentFlag ) then
        currentFlag:RemoveSelf()
    end
    
    if ( caster == nil ) then
        return
    end
    
    if ( event.target_points[1] ) then
        local targetEntity = Entities:CreateByClassname("prop_dynamic")
		targetEntity:SetAbsOrigin(origin)
		targetEntity:SetModel("models/particle/legion_duel_banner.vmdl")
		targetEntity:SetModelScale(0.7)
		targetEntity:SetRenderColor( 40, 176, 35 )
		targetEntity:SetAngles( 0, 240, 0 )
		caster.rally_point = targetEntity
	end
end
