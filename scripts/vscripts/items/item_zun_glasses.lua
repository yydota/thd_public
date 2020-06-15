item_zun_glasses = item_zun_glasses or class({})

function item_zun_glasses:GetIntrinsicModifierName()
	return "modifier_item_zun_glasses_passive"
end

function item_zun_glasses:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("DOTA_Item.Pipe.Activate")
	caster:RemoveModifierByName("modifier_item_zun_glasses_active")
	caster:AddNewModifier(caster,self,"modifier_item_zun_glasses_active",{Duration = self:GetSpecialValueFor("duration")})
end

modifier_item_zun_glasses_passive = modifier_item_zun_glasses_passive or class({})
LinkLuaModifier("modifier_item_zun_glasses_passive","items/item_zun_glasses.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_item_zun_glasses_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
end

function modifier_item_zun_glasses_passive:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end

function modifier_item_zun_glasses_passive:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_strength")	
end

function modifier_item_zun_glasses_passive:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_item_zun_glasses_passive:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_magical_armor")
end



modifier_item_zun_glasses_active = modifier_item_zun_glasses_active or class({})
LinkLuaModifier("modifier_item_zun_glasses_active","items/item_zun_glasses.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_item_zun_glasses_active:IsDebuff() return false end
function modifier_item_zun_glasses_active:IsHidden() return false end
function modifier_item_zun_glasses_active:IsPurgable() return false end
function modifier_item_zun_glasses_active:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_zun_glasses_active:OnCreated(params)
	self.block = self:GetAbility():GetSpecialValueFor("barrier_block")
	self.health = self.block

	self.particle = ParticleManager:CreateParticle("particles/items2_fx/pipe_of_insight.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControlEnt(self.particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(self.particle, 2, Vector(self:GetParent():GetModelRadius() * 1.2, 0, 0))
	self:AddParticle(self.particle, false, false, -1, false, false)
end

function modifier_item_zun_glasses_active:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_SPELL_DAMAGE_CONSTANT
	}
end
-- function modifier_item_zun_glasses_active:GetStatusEffectName()
-- 	return "particles/units/heroes/hero_pugna/pugna_decrepify.vpcf"
-- end

-- function modifier_item_zun_glasses_active:GetEffectAttachType()
-- 	return PATTACH_POINT_FOLLOW
-- end

function modifier_item_zun_glasses_active:GetModifierIncomingSpellDamageConstant(keys)
	if IsClient() then
		return self.block
	else
		if keys.damage_type == DAMAGE_TYPE_MAGICAL then
			if keys.original_damage <= self.health then
					SendOverheadEventMessage(nil, OVERHEAD_ALERT_MAGICAL_BLOCK, self:GetParent(),keys.original_damage, nil)
					self.health = self.health - keys.original_damage
					return keys.original_damage * (-1)
				else
					SendOverheadEventMessage(nil, OVERHEAD_ALERT_MAGICAL_BLOCK, self:GetParent(),self.health, nil)
					self:Destroy()
					return self.health * (-1)
			end
		end
	end
end