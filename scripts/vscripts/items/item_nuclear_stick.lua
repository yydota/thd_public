item_nuclear_stick = {}

LinkLuaModifier("modifier_item_nuclear_stick", "items/item_nuclear_stick", LUA_MODIFIER_MOTION_NONE)

function item_nuclear_stick:GetIntrinsicModifierName()
	return "modifier_item_nuclear_stick"
end

modifier_item_nuclear_stick = {}

function modifier_item_nuclear_stick:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_BONUS,		
		MODIFIER_PROPERTY_MANA_BONUS,				
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,	
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_PROPERTY_TOOLTIP,
		-- MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		-- MODIFIER_PROPERTY_MANA_REGEN_PERCENTAGE
	}
end
function modifier_item_nuclear_stick:GetModifierHealthBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_health")
end
function modifier_item_nuclear_stick:GetModifierManaBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_mana")
end
function modifier_item_nuclear_stick:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end
function modifier_item_nuclear_stick:GetModifierConstantManaRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end
function modifier_item_nuclear_stick:GetModifierPercentageCooldown()
	return self:GetAbility():GetSpecialValueFor("reduction_cooldown")
end

function modifier_item_nuclear_stick:OnTooltip()
	return self:GetAbility():GetSpecialValueFor("regen_amplify")
end
function modifier_item_nuclear_stick:GetModifierHealAmplify_PercentageTarget()
	return self:GetAbility():GetSpecialValueFor("regen_amplify")
end

-- function modifier_item_nuclear_stick:GetModifierHPRegenAmplify_Percentage()
-- 	return self:GetAbility():GetSpecialValueFor("bonus_regen_amplify")
-- end
-- function modifier_item_nuclear_stick:GetModifierPercentageManaRegen()
-- 	return self:GetAbility():GetSpecialValueFor("bonus_regen_amplify")
-- end