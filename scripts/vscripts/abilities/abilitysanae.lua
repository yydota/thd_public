if AbilitySanae == nil then
	AbilitySanae = class({})
end

function OnSanae01SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local time = 0
	local finaldamage=keys.ability:GetAbilityDamage()+FindTelentValue(caster,"special_bonus_unique_lion_2")
	caster:SetContextThink("OnSanae01SpellStart", 
		function()
			if GameRules:IsGamePaused() then return 0.03 end
			if time>=keys.Duration then return nil end
			local targets = FindUnitsInRadius(
		   		caster:GetTeam(),		--caster team
		  		keys.target_points[1],		--find position
		   		nil,					--find entity
		   		keys.Radius,		--find radius
		   		DOTA_UNIT_TARGET_TEAM_ENEMY,
		   		keys.ability:GetAbilityTargetType(),
		   		0, 
		   		FIND_CLOSEST,
		   		false
	    	)
			for _,v in pairs(targets) do
				if caster:HasModifier("modifier_item_wanbaochui") then
					if v:IsHero() then 
						local damage_table = {
							ability = keys.ability,
							victim = v,
							attacker = caster,
							damage = finaldamage*1.5,
							damage_type = keys.ability:GetAbilityDamageType(), 
							damage_flags = keys.ability:GetAbilityTargetFlags()
						}
						UnitDamageTarget(damage_table)
					else
						local damage_table = {
							ability = keys.ability,
							victim = v,
							attacker = caster,
							damage = finaldamage,
							damage_type = keys.ability:GetAbilityDamageType(), 
							damage_flags = keys.ability:GetAbilityTargetFlags()
						}
						UnitDamageTarget(damage_table)
					end
				
				else
					local damage_table = {
						ability = keys.ability,
						victim = v,
						attacker = caster,
						damage = finaldamage,
						damage_type = keys.ability:GetAbilityDamageType(), 
						damage_flags = keys.ability:GetAbilityTargetFlags()
					}
					UnitDamageTarget(damage_table)
				end

				keys.ability:ApplyDataDrivenModifier( caster, v, "modifier_sanae01_slow", {Duration=1} )
		    end
		    time = time + 1
		    return 1
		end,
	0)
	
	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_cyclone.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, keys.target_points[1])
	ParticleManager:SetParticleControl(effectIndex, 3, keys.target_points[1])
	ParticleManager:SetParticleControl(effectIndex, 6, keys.target_points[1])
	ParticleManager:DestroyParticleSystem(effectIndex,false)
	Timer.Wait 'ability_sanea_01_effect' (1.5,
			function()
				effectIndex = ParticleManager:CreateParticle("particles/items_fx/cyclone.vpcf", PATTACH_CUSTOMORIGIN, caster)
				ParticleManager:SetParticleControl(effectIndex, 0, keys.target_points[1])
				ParticleManager:SetParticleControl(effectIndex, 1, keys.target_points[1])
				ParticleManager:DestroyParticleSystem(effectIndex,false)
			end
	)
end

function OnSanae02SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local targets = keys.target_entities
	local finaldamage=keys.ability:GetAbilityDamage()+FindTelentValue(caster,"special_bonus_unique_lion_4")
	
	for _,v in pairs(targets) do
		if caster:HasModifier("modifier_item_wanbaochui") then
			if v:IsHero() then 		
				local damage_table = {
					ability = keys.ability,
					victim = v,
					attacker = caster,
					damage = finaldamage*1.5,
					damage_type = keys.ability:GetAbilityDamageType(), 
					damage_flags = keys.ability:GetAbilityTargetFlags()
				}
				UnitDamageTarget(damage_table)
			else
				local damage_table = {
					ability = keys.ability,
					victim = v,
					attacker = caster,
					damage = finaldamage,
					damage_type = keys.ability:GetAbilityDamageType(), 
					damage_flags = keys.ability:GetAbilityTargetFlags()
				}
				UnitDamageTarget(damage_table)	
			end
		else
			local damage_table = {
				ability = keys.ability,
				victim = v,
				attacker = caster,
				damage = finaldamage,
				damage_type = keys.ability:GetAbilityDamageType(), 
				damage_flags = keys.ability:GetAbilityTargetFlags()
			}
			UnitDamageTarget(damage_table)	
		end

		
		UtilStun:UnitStunTarget( caster,v,keys.StunDuration+FindTelentValue(caster,"special_bonus_unique_lion_3"))
	end
end

function OnSanae02FireEffect(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local effectIndex = ParticleManager:CreateParticle("particles/heroes/sanae/ability_sanea_02_effect.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(effectIndex, 0, keys.target_points[1])
	ParticleManager:SetParticleControl(effectIndex, 1, keys.target_points[1])
	ParticleManager:SetParticleControl(effectIndex, 2, keys.target_points[1])
	ParticleManager:SetParticleControl(effectIndex, 3, keys.target_points[1])
	ParticleManager:SetParticleControl(effectIndex, 5, keys.target_points[1])
	ParticleManager:SetParticleControl(effectIndex, 6, keys.target_points[1])
	ParticleManager:DestroyParticleSystem(effectIndex,false)
end

function OnSanae04SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_lion"))
	keys.ability:SetContextNum("ability_sanea_04_invulnerable_time", 0, 0) 
	local effectIndex = ParticleManager:CreateParticle("particles/heroes/sanae/ability_sanea_04_effect_b.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(effectIndex , 0, caster, 5, "follow_origin", Vector(0,0,0), true)
	--ParticleManager:SetParticleControlEnt(effectIndex, 1, caster, 0, follow_origin, caster:GetOrigin(), false)
	--ParticleManager:SetParticleControlEnt(effectIndex, 2, caster, 0, follow_origin, caster:GetOrigin(), false)
	--ParticleManager:SetParticleControlEnt(effectIndex, 7, caster, 0, follow_origin, caster:GetOrigin(), false)
	caster:SetContextThink("ability_sanea_04_invulnerable_effect", 
		function()
			if GameRules:IsGamePaused() then return 0.03 end
			ParticleManager:DestroyParticleSystem(effectIndex,true)
			return nil
		end, 
	keys.Duration)
end

function OnSanae04Invulnerable(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local targets = keys.target_entities
	local time = keys.ability:GetContext("ability_sanea_04_invulnerable_time")

	keys.ability:SetContextNum("ability_sanea_04_invulnerable_time", time + 0.1, 0) 

	for _,v in pairs(targets) do
		if(v:GetContext("ability_sanea_04_invulnerable")~=TRUE)then
			keys.ability:ApplyDataDrivenModifier( caster, v, "modifier_sanae04_invulnerable", {Duration=keys.Duration - time} )
			local unitEffectIndexUnit = ParticleManager:CreateParticle("particles/thd2/items/item_tsundere.vpcf", PATTACH_CUSTOMORIGIN, v)
			ParticleManager:SetParticleControlEnt(unitEffectIndexUnit, 0, v, 5, "follow_origin", v:GetOrigin(), false)
			v:SetContextNum("ability_sanea_04_invulnerable_effect_index", unitEffectIndexUnit, 0) 
			v:SetContextThink("ability_sanea_04_invulnerable_timer", 
			function()
				if GameRules:IsGamePaused() then return 0.03 end
				if(GetDistanceBetweenTwoVec2D(caster:GetOrigin(),v:GetOrigin())>=keys.Radius or v:GetContext("ability_sanea_04_invulnerable")~=TRUE)then
			    	v:RemoveModifierByName("modifier_sanae04_invulnerable")
			    	v:SetContextNum("ability_sanea_04_invulnerable", FALSE, 0)
			    	ParticleManager:DestroyParticleSystem(v:GetContext("ability_sanea_04_invulnerable_effect_index"),true)
			    	return nil
			    else
			    	return 0.1
			    end
			end, 
			0)
			v:SetContextThink("ability_sanea_04_invulnerable_timer_end", 
			function()
				if GameRules:IsGamePaused() then return 0.03 end
			    v:SetContextNum("ability_sanea_04_invulnerable", FALSE, 0)
			    return nil
			end, 
			keys.Duration - time)
			v:SetContextNum("ability_sanea_04_invulnerable", TRUE, 0) 
		end
	end
end