function BattleBeyond_generateGold( event )
    local caster = event.caster
    local modifier = caster:FindModifierByName( event.Modifier )
    local count = caster:GetModifierStackCount( event.Modifier, caster )
    
    if ( count == -1 ) then
        count = 0
    end
    
    caster:SetModifierStackCount( event.Modifier, caster, count + 1 )
end