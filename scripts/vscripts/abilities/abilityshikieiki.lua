--[[
04技能buff持续时间不能固定,只能重新设定SetDuration;不能禁止使用物品。
]]

local MODIFIER_NAME_ACCUSATION_TIMER="modifier_thdots_shikieiki01_accusation_timer"
local MODIFIER_NAME_ACCUSATION="modifier_thdots_shikieiki1_accusation"
function GetAccusationCount(Caster,Target)
	local modifiers=Target:FindAllModifiersByName(MODIFIER_NAME_ACCUSATION_TIMER)
	local ModifierCount=0
	if modifiers then
		for _,modifier in pairs(modifiers) do
			if modifier and modifier:GetCaster()==Caster then
				ModifierCount=ModifierCount+1
			end
		end
	end
	--print("GetAccusationCount:"..tostring(ModifierCount))
	return ModifierCount
end
function DelAccusation(Caster,Target,DelNum)
	DelNum=DelNum or 99
	local ModifierCount=0
	local modifiers=Target:FindAllModifiersByName(MODIFIER_NAME_ACCUSATION_TIMER)
	local DelCount=0
	if modifiers then
		table.sort(modifiers,function(a,b)
			if a and b and a:GetRemainingTime()<b:GetRemainingTime() then return true end
		end)
		
		for _,modifier in pairs(modifiers) do
			if modifier and modifier:GetCaster()==Caster then
				if DelNum>DelCount then
					modifier:Destroy()
					DelCount=DelCount+1
				end
			end
		end
	end
	--print("DelAccusation:"..tostring(DelCount))
	return DelCount
end
-------------------------------------------------------------------
function Shikieiki01_OnSpellStart(keys)	
	if is_spell_blocked(keys.target) then return end
	if (keys.target:IsBuilding() == true ) then return end
	local Ability=keys.ability
	local Caster=keys.caster
	local Target=keys.target
	
	Ability:ApplyDataDrivenModifier(Caster,Target,keys.ModifierName,{Duration=keys.Duration})
end
function Shikieiki01_Modifier_Accusation_OnKill(keys)
	local Ability=keys.ability
	local Caster=Ability:GetCaster()
	local Attacker=keys.attacker
	local Target=keys.unit
	local DamageHPPct
	if (Attacker:GetClassname()=="npc_dota_roshan" ) then return end
	if (Attacker:IsBuilding() == true ) then return end
	if Target:IsRealHero() then
		DamageHPPct=keys.DamageHpPctOnkillHero*0.01
	else
		DamageHPPct=keys.DamageHpPctOnkillCreep*0.01
	end
	
	local TriggerNum=DelAccusation(Caster,Attacker,keys.AccusationTriggerNum)
	local Damage=Attacker:GetMaxHealth()*DamageHPPct*TriggerNum
	if Attacker:IsRealHero() == true then
		UnitDamageTarget{
		ability = keys.ability,
		victim = Attacker,
		attacker = Caster,
		damage = Damage,
		damage_type = Ability:GetAbilityDamageType()
	}
	end
	--print("Shikieiki01_Modifier_Accusation_OnKill| Damage:"..tostring(Damage))
end

function Shikieiki01_Modifier_AccusationTimer_OnCreated(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	local Target=keys.target
	local MaxAccusationNum=keys.MaxAccusationNum
	if Caster:HasModifier("modifier_item_wanbaochui") then
		MaxAccusationNum=999
	end
	local ModifierAccusation=Target:FindModifierByNameAndCaster(MODIFIER_NAME_ACCUSATION,Caster)
	local ModifierCount=GetAccusationCount(Caster,Target)
	local effectIndex = ParticleManager:CreateParticle("particles/heroes/shikieiki/ability_shikieiki_01_guilty.vpcf", PATTACH_CUSTOMORIGIN, Caster)
	ParticleManager:SetParticleControlEnt(effectIndex , 0, Target, 5, "follow_origin", Vector(0,0,0), true)
	--[[local effectIndex = ParticleManager:CreateParticle("particles/heroes/shikieiki/ability_shikieiki_01_guilty_b.vpcf", PATTACH_CUSTOMORIGIN, Caster)
	ParticleManager:SetParticleControlEnt(effectIndex , 0, Target, 5, "follow_origin", Vector(0,0,0), true)
	ParticleManager:SetParticleControl(effectIndex, 1, Vector(0,ModifierCount,0))]]--
	--ParticleManager:SetParticleControl(effectIndex, 1, Target:GetOrigin())
	--ParticleManager:SetParticleControl(effectIndex, 2, Target:GetOrigin())
	--ParticleManager:SetParticleControl(effectIndex, 3, Target:GetOrigin())
	if not ModifierAccusation then
		Ability:ApplyDataDrivenModifier(Caster,Target,MODIFIER_NAME_ACCUSATION,{})
		ModifierAccusation=Target:FindModifierByNameAndCaster(MODIFIER_NAME_ACCUSATION,Caster)
	end
	if ModifierAccusation then
		ModifierAccusation:SetStackCount(ModifierCount)

		--ParticleManager:SetParticleControlEnt(effectIndex , 3, Target, 5, "follow_origin", Vector(0,0,0), true)

	end
	if ModifierCount>MaxAccusationNum then
		DelAccusation(Caster,Target,ModifierCount-MaxAccusationNum)
	end
end

function Shikieiki01_Modifier_AccusationTimer_OnDestroy(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	local Target=keys.target
	local MaxAccusationNum=keys.MaxAccusationNum
	local ModifierAccusation=Target:FindModifierByNameAndCaster(MODIFIER_NAME_ACCUSATION,Caster)
	
	if ModifierAccusation then
		if ModifierAccusation:GetStackCount()>1 then
			ModifierAccusation:DecrementStackCount()
		else
			ModifierAccusation:Destroy()
		end
	end
end

function Shikieiki02_OnSpellStart(keys)
	if is_spell_blocked(keys.target) then return end
	local Ability=keys.ability
	local Caster=keys.caster
	local Target=keys.target
	local AccusationNum=DelAccusation(Caster,Target)
	local StunDuration=keys.StunDurationBase+keys.StunDurationAccusation*AccusationNum
	local Damage=keys.DamageBase+keys.DamageAccusation*AccusationNum
	
	UnitDamageTarget{
		ability = keys.ability,
		victim = Target,
		attacker = Caster,
		damage = Damage,
		damage_type = Ability:GetAbilityDamageType()
	}
	UtilStun:UnitStunTarget(Caster,Target,StunDuration)
	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_purification.vpcf", PATTACH_CUSTOMORIGIN, Target)
	ParticleManager:SetParticleControl(effectIndex, 0, Target:GetOrigin())
	ParticleManager:SetParticleControl(effectIndex, 1, Vector(1,1,1))
	ParticleManager:SetParticleControl(effectIndex, 2, Vector(0,0,0))
	--print("Shikieiki02_OnSpellStart| damage:"..tostring(Damage).." stun:"..tostring(StunDuration))
end

function Shikieiki03_OnAttackLanded(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	local Target=keys.target
	if keys.target:IsBuilding() then return end
	local MaxAccusationNum=keys.MaxAccusationNum
	--if Target:IsRealHero() then
	local AbilityShikieiki01=Caster:FindAbilityByName("ability_thdots_Shikieiki01")
	--print("ability_thdots_Shikieiki01:"..tostring(AbilityShikieiki01))
	if AbilityShikieiki01 then
		if AbilityShikieiki01:GetLevel()<=0 then
			AbilityShikieiki01:SetLevel(1)
			AbilityShikieiki01:ApplyDataDrivenModifier(Caster,Target,MODIFIER_NAME_ACCUSATION_TIMER,{Duration=keys.AccusationDuration})
			AbilityShikieiki01:SetLevel(0)
		else
			AbilityShikieiki01:ApplyDataDrivenModifier(Caster,Target,MODIFIER_NAME_ACCUSATION_TIMER,{Duration=keys.AccusationDuration})
		end
	end
	if Target:HasModifier(MODIFIER_NAME_ACCUSATION) then
		Target:FindModifierByName(MODIFIER_NAME_ACCUSATION):SetDuration(keys.AccusationDuration,true)
	end
	if Caster:HasModifier("modifier_item_wanbaochui") then
		local RandomNumber = RandomInt(1,100)
		if RandomNumber<51 then
			AbilityShikieiki01:ApplyDataDrivenModifier(Caster,Target,MODIFIER_NAME_ACCUSATION_TIMER,{Duration=keys.AccusationDuration})
		    local effectIndex = ParticleManager:CreateParticle("particles/heroes/shikieiki/ability_shikieiki_01_guilty.vpcf", PATTACH_CUSTOMORIGIN, Caster)
			ParticleManager:SetParticleControlEnt(effectIndex , 0, Target, 5, "follow_origin", Vector(0,0,0), true)
		end
	end
	local Damage=keys.DamageOnMaxAccusation*GetAccusationCount(Caster,Target)
	UnitDamageTarget{
		ability = keys.ability,
		victim = Target,
		attacker = Caster,
		damage = Damage,
		damage_type = Ability:GetAbilityDamageType()
		}
end

function Shikieiki04_ModifierDebuff_OnIntervalThink(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	local Target=keys.target
	local Damage=keys.DamagePerSec*0.1
	
	UnitDamageTarget{
		ability = keys.ability,
		victim = Target,
		attacker = Caster,
		damage = Damage,
		damage_type = Ability:GetAbilityDamageType()
	}
end
function Shikieiki04_ModifierKeepDebuffDuration_OnCreated(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	local Target=keys.target
	
	Target.Shikieiki04_Debuff_Duration=keys.DebuffDuration
end
function Shikieiki04_ModifierKeepDebuffDuration_OnDestroy(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	local Target=keys.target
	
	Target.Shikieiki04_Debuff_Duration=nil
	ParticleManager:DestroyParticleSystem(Caster.ability_shikieiki_04_effectIndex,true)
end
function Shikieiki04_ModifierKeepDebuffDuration_OnIntervalThink(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	local Target=keys.target
	local RadiusKeepDuration=keys.RadiusKeepDuration
	local DebuffName=keys.DebuffName
			
	local Modifier04Debuff=Target:FindModifierByNameAndCaster(DebuffName,Caster)
	if Modifier04Debuff then
		Target.Shikieiki04_Debuff_Duration=Target.Shikieiki04_Debuff_Duration or Modifier04Debuff:GetRemainingTime()
		if CalcDistanceBetweenEntityOBB(Caster,Target)<RadiusKeepDuration and Caster:IsAlive() then
			Modifier04Debuff:SetDuration(Target.Shikieiki04_Debuff_Duration,true)
		else
			Target.Shikieiki04_Debuff_Duration=Modifier04Debuff:GetRemainingTime()
		end
	end
	local MaxHealth = Target:GetMaxHealth()
	local Health = Target:GetHealth()

	if (Health/MaxHealth)<=0.1 then
		Ability:ApplyDataDrivenModifier(Caster, Target, "modifier_thdots_shikieiki04_deny", {})
	end
end

function Shikieiki04_ModifierDebuff_OnCreated(keys)
	local Caster=keys.caster
	local Target=keys.target
	local effectIndex = ParticleManager:CreateParticle(
		"particles/heroes/shikieiki/ability_shikieiki_04.vpcf", 
		PATTACH_CUSTOMORIGIN, 
		Target)
	ParticleManager:SetParticleControlEnt(effectIndex , 0, Target, 5, "follow_origin", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effectIndex , 1, Target, 5, "follow_origin", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effectIndex , 4, Target, 5, "follow_origin", Vector(0,0,0), true)
	Caster.ability_shikieiki_04_effectIndex = effectIndex
end

function Shikieiki04_OnSpellStart(keys)

	local caster=keys.caster
	local target = keys.target
	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_storm_spirit"))
	if is_spell_blocked(target) then return end
	caster:EmitSound("Hero_Oracle.FatesEdict.Cast")
	caster:EmitSound("Voice_Thdots_Shikieiki.AbilityShikieiki04")
	caster:EmitSound("Hero_Oracle.FatesEdict")
	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_thdots_shikieiki04_debuff", {})
end
