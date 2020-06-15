if AbilityYugi == nil then
	AbilityYugi = class({})
end

function OnYugi03Damage(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	local Attacker = keys.attacker
	if(target:IsBuilding())then
		return
	end

	local telentDamage = FindTelentValue(caster,"special_bonus_unique_centaur_1") * caster:GetStrength()

	local dealdamage = keys.BounsDamage + telentDamage

	if Attacker:IsRealHero() then
		dealdamage = dealdamage
	else dealdamage = dealdamage* 0.35
	end

	local damage_table = {
			ability = keys.ability,
			victim = target,
			attacker = caster,
			damage = dealdamage,
			damage_type = keys.ability:GetAbilityDamageType(),
	    	damage_flags = 0
	}
	UnitDamageTarget(damage_table)
	UtilStun:UnitStunTarget( caster,target,1.0)
end

function OnYugi04SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	local vecTarget = target:GetOrigin()
	target:SetContextNum("ability_yugi04_point_x",vecTarget.x,0)
	target:SetContextNum("ability_yugi04_point_y",vecTarget.y,0)
	if target:IsHero() then
		-- caster:EmitSound("Voice_Thdots_Yugi.AbilityYugi04_1")
		caster:EmitSound("Voice_Thdots_Yugi.AbilityYugi04")
	end
end

function OnYugi04SpellThink(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	if(target:GetClassname()=="npc_dota_roshan")then
		return
	end
	local vecPoint = Vector(target:GetContext("ability_yugi04_point_x"),target:GetContext("ability_yugi04_point_y"),0)
	local dis = GetDistanceBetweenTwoVec2D(target:GetOrigin(),vecPoint)

	if(dis>keys.AbilityRadius)then
		--[[local damage_table = {
			victim = target,
			attacker = caster,
			damage = 99999,
			damage_type = keys.ability:GetAbilityDamageType(),
	    	damage_flags = DOTA_UNIT_TARGET_FLAG_INVULNERABLE
		}
		UnitDamageTarget(damage_table)]]--
		if(caster~=nil)then
			target:Kill(keys.ability, caster)
		else
			target:Kill(keys.ability, nil)
		end
		
		target:EmitSound("Ability.SandKing_CausticFinale")
		-- if target:IsHero() then
		-- 	target:EmitSound("Voice_Thdots_Yugi.AbilityYugi04_2")
		-- end
		local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_fallback_mid.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin())
		ParticleManager:DestroyParticleSystem(effectIndex,false)
	end
end

function OnYugi04SpellEnd(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target

	local dealdamage = target:GetMaxHealth() * (keys.DamagePercent+FindTelentValue(caster,"special_bonus_unique_centaur_3")) / 100
	local damage_table = {
		ability = keys.ability,
		victim = target,
		attacker = caster,
		damage = dealdamage,
		damage_type = keys.ability:GetAbilityDamageType(),
	    damage_flags = DOTA_UNIT_TARGET_FLAG_INVULNERABLE
	}
	UnitDamageTarget(damage_table)
	target:EmitSound("Ability.SandKing_CausticFinale")
	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_fallback_mid.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin())
	ParticleManager:DestroyParticleSystem(effectIndex,false)
end

function OnYugiKill(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local ability = caster:FindAbilityByName("ability_thdots_yugi04")
	if FindTelentValue(caster,"special_bonus_unique_centaur_2") ~= 0 and keys.unit:IsHero()==true and keys.unit:IsIllusion()==false then
		ability:EndCooldown()
	end
end

function OnYugi04wanbaochui(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	-- if is_spell_blocked(target) then return end
	target:EmitSound("Hero_Axe.JungleWeapon.Dunk")
	local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/yugi/yugi_slam.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin())
	ParticleManager:DestroyParticleSystem(effectIndex,false)
	local effectIndex1 = ParticleManager:CreateParticle("particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_fallback_mid.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex1, 0, target:GetOrigin())
	ParticleManager:DestroyParticleSystem(effectIndex1,false)
	keys.ability:ApplyDataDrivenModifier( caster, target, "modifier_thdots_yugi04_think_interval", {duration=keys.ability_duration} )
	if caster:HasModifier("modifier_item_wanbaochui") then
		local targets = FindUnitsInRadius(
			caster:GetTeam(),		
			target:GetOrigin(),	
			nil,					
			350,		
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			keys.ability:GetAbilityTargetType(),
			0,
			FIND_CLOSEST,
			false
		)
		for k,v in pairs(targets) do
			keys.ability:ApplyDataDrivenModifier( caster, v, "modifier_thdots_yugi04_think_interval", {duration=keys.ability_duration} )
			
			if v~=target then
				local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/yugi/yugi_slam.vpcf", PATTACH_CUSTOMORIGIN, caster)
				ParticleManager:SetParticleControl(effectIndex, 0, v:GetOrigin())
				ParticleManager:DestroyParticleSystem(effectIndex,false)
			end
		end
	end
end

