modifier_cast_range_lua = class({})

function cast_range_start( keys )
	local caster = keys.caster
	local ability = keys.ability
	caster:AddNewModifier(caster, ability, "modifier_cast_range_lua", {})
end

function modifier_cast_range_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_CAST_RANGE_BONUS
	}
	return funcs
end

function modifier_cast_range_lua:GetModifierCastRangeBonus()
	return caster:FindAbilityByName("ability_thdots_Utsuho04"):GetSpecialValueFor("cast_range_bonus")
	
end