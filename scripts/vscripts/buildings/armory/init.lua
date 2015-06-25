function BattleBeyond_setUpgradeAura( event )
    local caster = event.caster
    local disable = ( event.Disable == "1" ) and true or false
    local ability = event.ability
    local abilityname = ability:GetAbilityName()
    local newability = event.ReplacementAbility
    
    if ( disable ) then
        BattleBeyond_setAbilityLevel( caster, abilityname, 0 )
    else
        caster:RemoveAbility( abilityname )
        caster:AddAbility( newability )
        BattleBeyond_setAbilityLevel( caster, newability, 1 )
    end
    caster:SetModel( caster.Model )
end

function BattleBeyond_setAbilityLevel( caster, ability_name, level )
    if ( caster:HasAbility( ability_name ) ) then
        local ability = caster:FindAbilityByName( ability_name )
        ability:SetLevel( level )
    end
end