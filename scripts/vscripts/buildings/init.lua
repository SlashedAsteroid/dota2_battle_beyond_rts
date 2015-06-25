BattleBeyond_unitTypes = {}

BattleBeyond_unitTypes['building_village'] = {}
BattleBeyond_unitTypes['building_village']['model'] = "models/props_structures/good_ancient001.vmdl"
BattleBeyond_unitTypes['building_village']['model_scale'] = 0.6
BattleBeyond_unitTypes['building_village']['collision_hull'] = 160
BattleBeyond_unitTypes['building_village']['abilities'] = { "battlebeyond_ability_unit_create_settler", "battlebeyond_ability_unit_create_worker"  }

BattleBeyond_unitTypes['building_barracks'] = {}
BattleBeyond_unitTypes['building_barracks']['model'] = "models/props_structures/good_barracks_melee001.vmdl"
BattleBeyond_unitTypes['building_barracks']['model_scale'] = 0.6
BattleBeyond_unitTypes['building_barracks']['collision_hull'] = 140
BattleBeyond_unitTypes['building_barracks']['abilities'] = { "battlebeyond_ability_unit_create_settler", "battlebeyond_ability_unit_create_worker" }

--function BattleBeyond_createunitType( unit_name, unit_model, unit_model_scale, unit_abilities )
--    BattleBeyond_unitTypes[unit_name] = {}
--    table.insert( BattleBeyond_unitTypes[unit_name], { model = unit_model, model_scale = unit_model_scale, abilities = unit_abilities } )
--end
--BattleBeyond_createunitType( "building_village", "models/props_structures/good_ancient001.vmdl", 0.6, { "battlebeyond_ability_unit_create_settler" }  )

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
            BattleBeyond_assignBuildingAbilities( building, unitType )
    end )
    
    if ( unitType == 'building_village' ) then
        caster:Destroy()
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
    local origin_new = origin + origin_edit:Normalized() * 280
    
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
    caster:SetModel( BattleBeyond_unitTypes[caster.Type]['model'] )
end