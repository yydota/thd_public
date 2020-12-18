item_fan = item_fan or class({})

function item_fan:GetIntrinsicModifierName()
	return "modifier_item_fan_passive"
end

modifier_item_fan_passive = modifier_item_fan_passive or class({})
LinkLuaModifier("modifier_item_fan_passive","items/item_fan.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_fan_passive:IsHidden() return true end

function modifier_item_fan_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end

function modifier_item_fan_passive:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_strength")	
end

function modifier_item_fan_passive:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function item_fan:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("cast_range")
end

function item_fan:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local ability = self
	local start_position = caster:GetOrigin()
	local end_position = self:GetCursorPosition()
	local direct = ((end_position - start_position) * Vector(1, 1, 0)):Normalized()
	local particle = "particles/units/heroes/hero_death_prophet/death_prophet_carrion_swarm.vpcf"
	caster:EmitSound("Hero_DeathProphet.CarrionSwarm")
	local bo = ProjectileManager:CreateLinearProjectile({
				Source = caster,
				Ability = ability,
				vSpawnOrigin = caster:GetOrigin(),
				bDeleteOnHit = true,
			    iUnitTargetTeam	 	= ability:GetAbilityTargetTeam(),
	   			iUnitTargetType 	= ability:GetAbilityTargetType(),
				EffectName = "ability_effect_path",
				fDistance = 975,
				fStartRadius = 200,
				fEndRadius = 200,
				-- vVelocity = ((point - caster:GetAbsOrigin()) * Vector(1, 1, 0)):Normalized() * 1500,
				vVelocity = ((end_position - start_position) * Vector(1, 1, 0)):Normalized() * 1500,
				bReplaceExisting = false,
				bProvidesVision = false,	
				bHasFrontalCone = false,
				iUnitTargetTeam = ability:GetAbilityTargetTeam(),							
				iUnitTargetType = ability:GetAbilityTargetType(),
			})
	self.particle = ParticleManager:CreateParticle(particle,PATTACH_WORLDORIGIN,nil)
	ParticleManager:SetParticleControl(self.particle, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.particle, 1, Vector(direct.x*1500,direct.y*1500,0))
	ParticleManager:SetParticleControl(self.particle, 2, Vector(200,200,200))
end

function item_fan:OnProjectileHit(hTarget, vLocation)
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = hTarget
	local ability = self
	local time_min = math.floor(GameRules:GetDOTATime(false, false)/60)
	local damage = ability:GetSpecialValueFor("damage") + ability:GetSpecialValueFor("damage_bonus_time") * time_min
	if hTarget then
		local damageTable = {victim = target,
							damage = damage,
							damage_type = DAMAGE_TYPE_MAGICAL,
							attacker = caster,
							ability = ability
							}
		local damage_dealt = UnitDamageTarget(damageTable)
	else
		ParticleManager:DestroyParticleSystem(self.particle,true)
	end
end