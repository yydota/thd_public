if AbilitySuika == nil then
	AbilitySuika = class({})
end
function OnSuika02Switch(keys)
	local caster=keys.caster
	if caster:HasModifier("passive_suika02_attack") then
		caster:RemoveModifierByName("passive_suika02_attack")
	else 
		keys.ability:ApplyDataDrivenModifier(caster,caster,"passive_suika02_attack",{duration = -1})
	end
end

function OnSuika02Start(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targets = keys.target_entities
	for _,v in pairs(targets) do
		local deal_damage = keys.ability:GetAbilityDamage()
		local damage_table = {
			    victim = v,
			    attacker = caster,
			    damage = deal_damage,
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
		}
		UnitDamageTarget(damage_table)
	end
end

function OnSuika02ULTStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targets = keys.target_entities
	local abilityLevel = caster:GetContext("ability_thdots_suika02_level") 
	for _,v in pairs(targets) do
		local deal_damage = 60 + (abilityLevel - 1) * 30
		local damage_table = {
				ability = keys.ability,
			    victim = v,
			    attacker = caster,
			    damage = deal_damage,
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
		}
		UnitDamageTarget(damage_table)
	end
end

function OnSuika03Start(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ability_duration = ability:GetSpecialValueFor("ability_duration")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_suika03_states", {})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_suika03_think_interval", {})
	if caster:GetUnitName() == "npc_dota_hero_tidehunter" then
		caster:EmitSound("Voice_Thdots_Suika.AbilitySuika01")
	end
	local ModifierSuika03=caster:FindModifierByName("modifier_thdots_Suika_04")
	if ModifierSuika03 then
		caster.suika03_time = ModifierSuika03:GetRemainingTime()
		ModifierSuika03:SetDuration(caster.suika03_time + ability_duration, true)
		if caster:FindModifierByName("modifier_thdots_Suika_04_telent") then
			caster:FindModifierByName("modifier_thdots_Suika_04_telent"):SetDuration(caster.suika03_time + ability_duration, true)
		end
	end
end

function OnSuika03End(keys)
	local caster = keys.caster
	local ability = keys.ability
	print("caster.suika03_time is:")
	print(caster.suika03_time)
end

function OnSuika03Spawn(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local Caster = keys.caster
	local CasterName = Caster:GetClassname()
	local bonusAttack = 0 
	local attack = 0
	local health = Caster:GetMaxHealth()*0.4
    for i=0,5 do
        item = Caster:GetItemInSlot(i)
        if(item~=nil)then
            bonusAttack = item:GetSpecialValueFor("bonus_damage")
            if(bonusAttack~=nil)then
                attack = bonusAttack + attack
            end
        end
	end 
	local Damage = (Caster:GetAttackDamage()+attack)*0.4
	if CasterName == "npc_dota_hero_tidehunter" then
		local unit = CreateUnitByName(
			"npc_dota_suika_03_smallsuika"
			,caster:GetOrigin() - caster:GetForwardVector() * 100
			,false
			,caster
			,caster
			,caster:GetTeam()
			)
		keys.ability:ApplyDataDrivenModifier(Caster, unit, "modifier_thdots_suika03_unit", {})
		unit:SetBaseMaxHealth(health)
		unit:SetBaseDamageMax(Damage)
		unit:SetBaseDamageMin(Damage)
		unit:SetContextThink("npc_dota_suika_03_smallsuika_timer",
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			unit:RemoveSelf() 
			return nil
		end, 5.0+FindTelentValue(Caster,"special_bonus_unique_tidehunter_4")) 
	else
		local unit = CreateUnitByName(
			"npc_dota_satori_03_smallsatori"
			,caster:GetOrigin() - caster:GetForwardVector() * 100
			,false
			,caster
			,caster
			,caster:GetTeam()
			)
		keys.ability:ApplyDataDrivenModifier(Caster, unit, "modifier_thdots_suika03_unit", {})
		unit:SetBaseMaxHealth(health)
		unit:SetBaseDamageMax(Damage)
		unit:SetBaseDamageMin(Damage)		
		unit:SetContextThink("npc_dota_suika_03_smallsuika_timer",
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			unit:RemoveSelf() 
			return nil
		end, 5.0) 
	end	
end

function OnSuika04SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local Caster = keys.caster
	local CasterName = Caster:GetClassname()
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("duration") + FindTelentValue(caster,"special_bonus_unique_tidehunter_3")
	if FindTelentValue(caster,"special_bonus_unique_tidehunter")~=0 then
		keys.ability:ApplyDataDrivenModifier( caster, caster, "modifier_thdots_Suika_04_telent", {duration = duration} )
	end
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_Suika_04", {duration = duration})
	if CasterName == "npc_dota_hero_tidehunter" then
		caster:EmitSound("Voice_Thdots_Suika.AbilitySuika04")
		caster:SetModelScale(2.0)
		local ability = caster:FindAbilityByName("ability_thdots_suika02") 
		caster:SetContextNum("ability_thdots_suika02_level", ability:GetLevel(), 0) 
		caster:RemoveAbility("ability_thdots_suika02") 
		caster:RemoveModifierByName("passive_suika02_attack") 
		caster:AddAbility("ability_thdots_suika02_ult")
		local abilityUlt = caster:FindAbilityByName("ability_thdots_suika02_ult")
		abilityUlt:SetLevel(keys.ability:GetLevel())
	else
		caster:SetModelScale(2.0)
	end
	ability:SetActivated(false)
	-- caster:SetContextThink("ability_thdots_suika04_duration", 
	-- 	function ()
	-- 		if GameRules:IsGamePaused() then return 0.03 end
	-- 		if CasterName == "npc_dota_hero_tidehunter" then
	-- 			caster:RemoveAbility("ability_thdots_suika02_ult") 
	-- 			caster:AddAbility("ability_thdots_suika02")
	-- 			caster:RemoveModifierByName("passive_suika02_ult_attack") 
	-- 			local ability02 = caster:FindAbilityByName("ability_thdots_suika02")
	-- 			ability02:SetLevel(caster:GetContext("ability_thdots_suika02_level"))
	-- 			caster:SetModelScale(1.0)
	-- 		else
	-- 			caster:SetModelScale(1.0)
	-- 		end
			
	-- 		caster:RemoveModifierByName("modifier_thdots_Suika_04")
	-- 		caster:RemoveModifierByName("modifier_thdots_Suika_04_telent") 
	-- 		ability:SetActivated(true)
	-- 	end
	-- ,duration) 
end

function OnSuika04End( keys )
	local caster = EntIndexToHScript(keys.caster_entindex)
	local Caster = keys.caster
	local CasterName = Caster:GetClassname()
	local ability = keys.ability
	if CasterName == "npc_dota_hero_tidehunter" then
		caster:RemoveAbility("ability_thdots_suika02_ult") 
		caster:AddAbility("ability_thdots_suika02")
		caster:RemoveModifierByName("passive_suika02_ult_attack") 
		local ability02 = caster:FindAbilityByName("ability_thdots_suika02")
		ability02:SetLevel(caster:GetContext("ability_thdots_suika02_level"))
		caster:SetModelScale(1.0)
	else
		caster:SetModelScale(1.0)
	end	
	caster:RemoveModifierByName("modifier_thdots_Suika_04")
	caster:RemoveModifierByName("modifier_thdots_Suika_04_telent") 
	ability:SetActivated(true)
end

function Suika_04_wanbaochui_check(keys)
	local caster = keys.caster
	local casterName = caster:GetClassname()
	local abilityEx = nil
	if casterName == "npc_dota_hero_tidehunter" and caster:HasModifier("modifier_item_wanbaochui") then
		abilityEx = caster:FindAbilityByName("ability_thdots_suikaex")
		abilityEx:SetLevel(1)
	else
		abilityEx = caster:FindAbilityByName("ability_thdots_suikaex")
		if abilityEx == nil then return end
		abilityEx:SetLevel(0)
	end
end



