abilityhatate = class({})
count = 0

function Kogasa01OnSpellStart( keys )
	local caster = keys.caster
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_ability_thdots_kogasa01", {})
	caster:EmitSound("Hero_Razor.Storm.Loop")
	if FindTelentValue(caster,"special_bonus_unique_kogasa_4") == 1 then 
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_ability_thdots_kogasa01_talent", {})
	end
end

function Kogasa01OnDeath( keys )
	keys.caster:RemoveModifierByName("modifier_ability_thdots_kogasa01")
	keys.caster:StopSound("Hero_Razor.Storm.Loop")
end

function Kogasa02OnSpellStart( keys )
	local caster = keys.caster
	caster:Purge(false,true,false,true,false)
	local duration = FindValueTHD("duration",keys.ability) + FindTelentValue(caster,"special_bonus_unique_kogasa_3")
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_ability_thdots_kogasa02", {Duration = duration})
	caster:EmitSound("Hero_Juggernaut.BladeFuryStart")
	if FindTelentValue(caster,"special_bonus_unique_kogasa_5") ~= 0 then
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_ability_thdots_kogasa02_talent", {Duration = duration})
	end
	if caster:HasModifier("modifier_item_wanbaochui") then
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_ability_thdots_kogasa02_wanbaochui", {Duration = duration})
	end
	caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2,caster:GetDisplayAttackSpeed()/100)
end

function Kogasa02OnThink( keys )
	local caster = keys.caster
	local ability = keys.ability
	local speed = 40/caster:GetDisplayAttackSpeed()-- 60是转速常数，值越大伤害越低
	if(ability:GetContext("ability_Kogasa02_Count") == nil)then
	    ability:SetContextNum("ability_Kogasa02_Count",0,0)
		count = ability:GetContext("ability_Kogasa02_Count")
	end
	count = count + 0.03
	ability:SetContextNum("ability_Kogasa02_Count",count,0)
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.radius + FindTelentValue(caster,"special_bonus_unique_kogasa_5"), ability:GetAbilityTargetTeam(),ability:GetAbilityTargetType(),0,0,false)
	if math.abs(count%speed) < 0.03 then
		for _,v in pairs(targets) do
			local damage = caster:GetAverageTrueAttackDamage(caster) * keys.attack_bonus + keys.damage
			if v:IsCreep() then
				if not v:IsNeutralUnitType() then
					damage = damage * keys.creep_damage/100
				end
			elseif v:IsBuilding() then
				damage = damage * keys.bulding_damge/100
			end
			local damage_table = {
							ability = ability,
							victim = v,
							attacker = caster,
							damage = damage,
							damage_type = ability:GetAbilityDamageType(), 
							damage_flags = 0
						}
			local effectIndex = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_ti8_sword/juggernaut_crimson_blade_fury_abyssal_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW,v)
			ParticleManager:DestroyParticleSystem(effectIndex,false)
			UnitDamageTarget(damage_table)
		end
	end
end

function Kogasa02OnDestroy( keys )
	local caster = keys.caster
	caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_2)
	caster:StopSound("Hero_Juggernaut.BladeFuryStart")
	caster:EmitSound("Hero_Juggernaut.BladeFuryStop")
	count = 0
end

function Kogasa02Wanbaochui(keys )
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_ability_thdots_kogasa02_wanbaochui_stun", {})
	caster:StartGestureWithPlaybackRate(ACT_DOTA_DIE,1.5)
end

function Kogasa03OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	THDReduceCooldown(ability,FindTelentValue(caster,"special_bonus_unique_kogasa_2"))
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_ability_thdots_kogasa03", {Duration = FindValueTHD("duration",keys.ability)})
	if (ability:GetContext("ability_Kogasa03_Count") == nil)then
	    ability:SetContextNum("ability_Kogasa03_Count",caster:GetModelScale(),0)
	end
	caster:SetModelScale(2.5)
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_3)
	ProjectileManager:ProjectileDodge(caster)
	local max_count = FindValueTHD("max_count",keys.ability)
end

function Kogasa03End( keys )
	keys.caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_3)
	keys.caster:SetModelScale(keys.ability:GetContext("ability_Kogasa03_Count"))
	keys.caster:Purge(false,true,false,true,false)
end

function Kogasa03OnKill( keys )
	local caster = keys.caster
	local max_count = FindValueTHD("max_count",keys.ability) + FindTelentValue(caster,"special_bonus_unique_kogasa_1")
	local count = caster:GetModifierStackCount("modifier_ability_thdots_kogasa03_agi", caster)
	if caster:FindAbilityByName("ability_thdots_kogasa03") == nil then return end
	if count <= max_count then
		caster:SetModifierStackCount("modifier_ability_thdots_kogasa03_agi", caster, count + 1)
	else
		caster:SetModifierStackCount("modifier_ability_thdots_kogasa03_agi", caster, max_count)
	end
end

function Kogasa04OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_ability_thdots_kogasa04", {})
	if (ability:GetContext("ability_Kogasa04_Count") == nil)then
	    ability:SetContextNum("ability_Kogasa04_Count",0,0)
	    Kogasa04_count = ability:GetContext("ability_Kogasa04_Count")
	end
	caster:StartGesture(ACT_DOTA_AMBUSH)
end

function Kogasa04OnDestroy( keys )
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_ability_thdots_kogasa04")
	caster:RemoveModifierByName("modifier_ability_thdots_kogasa04_invisble")
	caster:RemoveModifierByName("modifier_invisible")
	caster:RemoveGesture(ACT_DOTA_AMBUSH)
	Kogasa04_count = 0
	keys.ability:SetContextNum("ability_Kogasa04_Count", Kogasa04_count,0)
end


function Kogasa04OnThink( keys )
	local caster = keys.caster
	local ability = keys.ability
	local preparetime = FindValueTHD("preparetime",keys.ability)
	Kogasa04_count = ability:GetContext("ability_Kogasa04_Count")
	Kogasa04_count = Kogasa04_count + 0.05
	ability:SetContextNum("ability_Kogasa04_Count", Kogasa04_count,0)
	if Kogasa04_count > 0.5 and Kogasa04_count < preparetime then
		 local target = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, FindValueTHD("radius",ability),ability:GetAbilityTargetTeam(),ability:GetAbilityTargetType(), DOTA_UNIT_TARGET_FLAG_INVULNERABLE,0,false)
		 print(#target)
		if #target > 0 then
			caster:Stop()
			caster:RemoveGesture(ACT_DOTA_AMBUSH)	
			caster:RemoveModifierByName("modifier_ability_thdots_kogasa04")
			caster:RemoveModifierByName("modifier_ability_thdots_kogasa04_invisble")
			Kogasa04_count = 0
			ability:SetContextNum("ability_Kogasa04_Count", Kogasa04_count,0)
		end
	elseif Kogasa04_count >= preparetime then
		if caster:FindModifierByName("modifier_ability_thdots_kogasa04_invisble") == nil then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_ability_thdots_kogasa04_invisble", {})
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_invisible", {})
		end
		if caster:FindAbilityByName("ability_thdots_kogasaex") ~= nil then
			caster:Heal(caster:GetMaxHealth()*0.001, caster)
			caster:SetMana(caster:GetMana()+caster:GetMaxMana()*0.001)
		end
		local target = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, FindValueTHD("radius",ability)+FindTelentValue(caster,"special_bonus_unique_kogasa_6"),ability:GetAbilityTargetTeam(),DOTA_UNIT_TARGET_HERO, 0,0,false)
		if #target > 0 then
			local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, FindValueTHD("damage_radius",ability)+FindTelentValue(caster,"special_bonus_unique_kogasa_6"),ability:GetAbilityTargetTeam(),ability:GetAbilityTargetType(), 0,0,false)
			for _,v in pairs(targets) do
				local damage_table = {
					ability = ability,
					victim = v,
					attacker = caster,
					damage = FindValueTHD("base_damage",ability) + caster:GetAverageTrueAttackDamage(caster) * FindValueTHD("attack_bonus",ability),
					damage_type = keys.ability:GetAbilityDamageType(), 
					damage_flags = 0
				}
				UtilStun:UnitStunTarget(caster,v,FindValueTHD("stun_duration",ability))
				UnitDamageTarget(damage_table)
				if v:IsRealHero() then
					if caster:FindModifierByName("modifier_ability_thdots_kogasa04_movespeed") == nil then
						ability:ApplyDataDrivenModifier(caster, caster, "modifier_ability_thdots_kogasa04_movespeed", {})
					end
					local count = caster:GetModifierStackCount("modifier_ability_thdots_kogasa04_movespeed", caster)
					local max_count = FindValueTHD("max_count",ability)
					if count < max_count then
							caster:SetModifierStackCount("modifier_ability_thdots_kogasa04_movespeed", caster, count + FindValueTHD("movespeed",ability))
						elseif count >= max_count then
							caster:SetModifierStackCount("modifier_ability_thdots_kogasa04_movespeed", caster, max_count)
						end
					end
					if caster:FindAbilityByName("ability_thdots_kogasa03") ~= nil then
						local agi_ability = caster:FindAbilityByName("ability_thdots_kogasa03")
						local agi_max_count = FindValueTHD("max_count",agi_ability) + FindTelentValue(caster,"special_bonus_unique_kogasa_1")
						local agi_count = caster:GetModifierStackCount("modifier_ability_thdots_kogasa03_agi", caster)
						if agi_count <= agi_max_count then
							caster:SetModifierStackCount("modifier_ability_thdots_kogasa03_agi", caster, agi_count + 10)
							if agi_count + 10 >= agi_max_count then
								caster:SetModifierStackCount("modifier_ability_thdots_kogasa03_agi", caster, agi_max_count)
							end
						else
						caster:SetModifierStackCount("modifier_ability_thdots_kogasa03_agi", caster, agi_max_count)
					end
				end
			end
			local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start.vpcf", PATTACH_ABSORIGIN_FOLLOW,caster)
			ParticleManager:DestroyParticleSystem(effectIndex,false)
			caster:RemoveGesture(ACT_DOTA_AMBUSH)	
			caster:RemoveModifierByName("modifier_ability_thdots_kogasa04")
			caster:RemoveModifierByName("modifier_ability_thdots_kogasa04_invisble")
			caster:RemoveModifierByName("modifier_invisible")
			caster:StartGesture(ACT_DOTA_CAST_ABILITY_4_END)
			Kogasa04_count = 0
			ability:SetContextNum("ability_Kogasa04_Count", Kogasa04_count,0)
			StartSoundEventFromPosition("Hero_Kogasa04", caster:GetAbsOrigin())
			StartSoundEventFromPosition("Hero_EarthShaker.EchoSlam.Arcana", caster:GetAbsOrigin())
		end
	end
end

