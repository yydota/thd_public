if AbilityTensi == nil then
	AbilityTensi = class({})
end
function OnTensi02Switch(keys)
	local caster=keys.caster
	if caster:HasModifier("passive_tensi02_attack") then
		caster:RemoveModifierByName("passive_tensi02_attack")
	else 
		keys.ability:ApplyDataDrivenModifier(caster,caster,"passive_tensi02_attack",{duration = -1})
	end
end

function OnTensi02SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	if(keys.ability:GetContext("ability_tensi_02_reset")==nil)then
		keys.ability:SetContextNum("ability_tensi_02_reset",TRUE,0)
	end
	if(keys.ability:GetContext("ability_tensi_02_reset")==TRUE)then
		keys.ability:SetContextNum("ability_tensi_02_reset",FALSE,0)
		local resetTime = keys.AbilityMulti/(caster:GetPrimaryStatValue())
		Timer.Wait 'ability_tensi_02_reset_timer' (resetTime,
			function()
				keys.ability:SetContextNum("ability_tensi_02_reset",TRUE,0)
			end
		)
	else
		return
	end
	local telentdamage = FindTelentValue(caster,"special_bonus_unique_earthshaker") * caster:GetStrength()
	local vecCaster = caster:GetOrigin()
	local targets = keys.target_entities
	for _,v in pairs(targets) do
		local damage_table = {
				ability = keys.ability,
			    victim = v,
			    attacker = caster,
			    damage = keys.BounsDamage + telentdamage,
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
		}
		UnitDamageTarget(damage_table)
		UtilStun:UnitStunTarget(caster,v,keys.Duration)		            
	end
	if (targets[1] == nil) then
		return
	end
	local effectIndex = ParticleManager:CreateParticle("particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_echoslam_start_fallback_low_egset.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, targets[1]:GetOrigin())
	ParticleManager:SetParticleControl(effectIndex, 1, targets[1]:GetOrigin())
	ParticleManager:DestroyParticleSystem(effectIndex,false)
	targets[1]:EmitSound("Hero_EarthShaker.Totem.Attack")
end

function OnTensi02SpellRandom(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	if FindTelentValue(caster,"special_bonus_unique_earthshaker_2")==0 then 
		return
	else	
		if caster:IsRealHero() then
			local telentdamage = FindTelentValue(caster,"special_bonus_unique_earthshaker") * caster:GetStrength()
			local vecCaster = caster:GetOrigin()
			local targets = keys.target_entities
			for _,v in pairs(targets) do
				local damage_table = {
						ability = keys.ability,
						victim = v,
						attacker = caster,
						damage = keys.BounsDamage + telentdamage,
						damage_type = keys.ability:GetAbilityDamageType(), 
						damage_flags = 0
				}
				UnitDamageTarget(damage_table)
				UtilStun:UnitStunTarget(caster,v,keys.Duration)		            
			end
			if (targets[1] == nil) then
				return
			end
			local effectIndex = ParticleManager:CreateParticle("particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_echoslam_start_fallback_low_egset.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControl(effectIndex, 0, targets[1]:GetOrigin())
			ParticleManager:SetParticleControl(effectIndex, 1, targets[1]:GetOrigin())
			ParticleManager:DestroyParticleSystem(effectIndex,false)
			targets[1]:EmitSound("Hero_EarthShaker.Totem.Attack")
		end
	end
end



function OnTensi03Passive(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	caster:Heal(keys.BounsHealth+FindTelentValue(caster,"special_bonus_unique_earthshaker_3"), caster)
	caster:GiveMana(keys.BounsMana+FindTelentValue(caster,"special_bonus_unique_earthshaker_3"))
	if caster:HasModifier("active_tensi03_attacked") then
		caster:Heal(keys.BounsHealth+FindTelentValue(caster,"special_bonus_unique_earthshaker_3"), caster)
	end
end

function OnTensi03SpellStart(keys)
	local caster=keys.caster
	local MaxStackCount = keys.MaxStackCount
	
	if caster:HasModifier("modifier_tensi03_bonus_attackspeed")~=true then
		caster.ModifierCount = 0
	end
	if caster.ModifierCount >= MaxStackCount then
		caster.ModifierCount = MaxStackCount
	else
		caster.ModifierCount = caster.ModifierCount+1
	end
	keys.ability:ApplyDataDrivenModifier(caster,caster,"modifier_tensi03_bonus_attackspeed",{})
	caster:SetModifierStackCount("modifier_tensi03_bonus_attackspeed",keys.ability,caster.ModifierCount)
	
end

function Tensiwanbaochuicheck(keys)
	local caster = keys.caster
	local casterName = caster:GetClassname()
	local abilityEx=nil
	if casterName == "npc_dota_hero_earthshaker" and caster:HasModifier("modifier_item_wanbaochui") then
		abilityEx = caster:FindAbilityByName("ability_thdots_tensiex")
		abilityEx:SetLevel(1)
	else
		abilityEx = caster:FindAbilityByName("ability_thdots_tensiex")
		abilityEx:SetLevel(0)
	end
end


function Tensiwanbaochuibuff(keys)
	local ability=keys.ability
	local caster=keys.caster
	local target=keys.target
	if is_spell_blocked(target,caster) then return end
	target:EmitSound("DOTA_Item.HeavensHalberd.Activate")
	if(caster:GetTeam() == keys.target:GetTeam())then
		keys.ability:ApplyDataDrivenModifier(caster, keys.target, "modifier_tensi_wanbaochui_buff", {})
		keys.ability:ApplyDataDrivenModifier(caster, keys.target, "modifier_tensi_wanbaochui_buff_2", {})
	else
		if is_spell_blocked(keys.target) then return end
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_tensi_wanbaochui_buff", {}) 
	end
end