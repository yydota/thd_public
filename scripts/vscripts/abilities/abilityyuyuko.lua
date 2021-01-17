if AbilityYuyuko == nil then
	AbilityYuyuko = class({})
end

function OnYuyuko04PhaseStart(keys)
end

function OnYuyuko04SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_necrophos"))
	local vecCaster = caster:GetOrigin()
	local vecForward = caster:GetForwardVector() 
	local unit = CreateUnitByName(
		"npc_dota2x_unit_yuyuko_04"
		,caster:GetOrigin() - vecForward * 100
		,false
		,caster
		,caster
		,caster:GetTeam()
	)
	local ability_dummy_unit = unit:FindAbilityByName("ability_dummy_unit")
	ability_dummy_unit:SetLevel(1)
	
	unit:StartGesture(ACT_DOTA_IDLE)
	local forwardRad = GetRadBetweenTwoVec2D(caster:GetOrigin(),unit:GetOrigin())
	unit:SetForwardVector(Vector(math.cos(forwardRad+math.pi/2),math.sin(forwardRad+math.pi/2),0))

	local effectIndex2 = ParticleManager:CreateParticle("particles/heroes/yuyuko/ability_yuyuko_04_effect_d.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex2, 0, caster:GetOrigin())
	ParticleManager:DestroyParticleSystem(effectIndex2,false)

	unit:SetContextThink("ability_yuyuko_04_unit_remove", 
		function () 
			if GameRules:IsGamePaused() then return 0.03 end
			unit:RemoveSelf()
			return nil
		end, 
		2.0)

	keys.ability:SetContextNum("ability_yuyuko_04_time_count", keys.DamageCount, 0) 

	-- local particle_death = "particles/units/heroes/hero_skeletonking/wraith_king_reincarnate.vpcf"
	-- local particle_death_fx = ParticleManager:CreateParticle(particle_death, PATTACH_CUSTOMORIGIN, caster)
	-- ParticleManager:SetParticleAlwaysSimulate(particle_death_fx)
	-- ParticleManager:SetParticleControl(particle_death_fx, 0, caster:GetAbsOrigin())
	-- ParticleManager:SetParticleControl(particle_death_fx, 1, Vector(3, 0, 0))
	-- ParticleManager:SetParticleControl(particle_death_fx, 11, Vector(10, 0, 0))
	-- ParticleManager:ReleaseParticleIndex(particle_death_fx)
	-- local particle_death_2 = "particles/units/heroes/hero_necrolyte/necrolyte_spirit.vpcf"
	-- local particle_death_fx_2 = ParticleManager:CreateParticle(particle_death_2, PATTACH_CUSTOMORIGIN, caster)
	-- ParticleManager:SetParticleAlwaysSimulate(particle_death_fx_2)
	-- ParticleManager:SetParticleControl(particle_death_fx_2, 0, caster:GetAbsOrigin())
	-- ParticleManager:SetParticleControl(particle_death_fx_2, 2, Vector(500, 0, 0))
	-- ParticleManager:ReleaseParticleIndex(particle_death_fx_2)
end

function OnYuyuko04SpellRemove(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
end

function OnYuyuko04SpellThink(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local targets = keys.target_entities

	local timecount = keys.ability:GetContext("ability_yuyuko_04_time_count")
	if(timecount>=0)then
		timecount = timecount - 1
		keys.ability:SetContextNum("ability_yuyuko_04_time_count", timecount, 0) 
		for _,v in pairs(targets) do    
			if((v:GetTeam()~=caster:GetTeam()) and (v:IsInvulnerable() == false) and (v:IsBuilding() == false) and (v:IsAlive() == true) and (v:GetClassname()~="npc_dota_roshan")) and (v:GetClassname()~="trigger_dota") then
				local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/yuyuko/ability_yuyuko_04_effect.vpcf", PATTACH_CUSTOMORIGIN, caster)
				ParticleManager:SetParticleControl(effectIndex, 0, v:GetOrigin())
				ParticleManager:DestroyParticleSystem(effectIndex,false)

				effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/yuyuko/ability_yuyuko_04_effect_a.vpcf", PATTACH_CUSTOMORIGIN, caster)
				ParticleManager:SetParticleControl(effectIndex, 0, v:GetOrigin())
				ParticleManager:SetParticleControl(effectIndex, 5, v:GetOrigin())
				ParticleManager:DestroyParticleSystem(effectIndex,false)

				local effectIndex2 = ParticleManager:CreateParticle("particles/heroes/yuyuko/ability_yuyuko_04_effect_d.vpcf", PATTACH_CUSTOMORIGIN, caster)
				ParticleManager:SetParticleControl(effectIndex2, 0, v:GetOrigin())
				ParticleManager:DestroyParticleSystem(effectIndex2,false)


				local vecV = v:GetOrigin()
				local deal_damage = (v:GetMaxHealth() - v:GetHealth())*keys.DamageMulti
				local boolDamage
				if((v:GetHealth()<=deal_damage) or (v:IsHero()==false))then
					boolDamage = true
				else
					boolDamage = false
				end

				if(v:IsHero()==false) then
					v:Kill(keys.ability,caster)
				else
					local damage_table = {
						ability = keys.ability,
						victim = v,
						attacker = caster,
						damage = deal_damage,
						damage_type = keys.ability:GetAbilityDamageType(), 
						damage_flags = 0
					}
					UnitDamageTarget(damage_table)
					if caster:HasModifier("modifier_item_wanbaochui") then
						UtilStun:UnitStunTarget(caster,v,0.1)
					end
				end

				if(boolDamage)then
					local DamageTargets = FindUnitsInRadius(
					   caster:GetTeam(),		--caster team
					   vecV,					--find position
					   nil,						--find entity
					   keys.DamageRadius,		--find radius
					   DOTA_UNIT_TARGET_TEAM_ENEMY,
					   keys.ability:GetAbilityTargetType(),
					   0, FIND_CLOSEST,
					   false
				    )
					for _,v in pairs(DamageTargets) do
					    local damage_table_death = {
					    	ability = keys.ability,
							victim = v,
							attacker = caster,
							damage = keys.ability:GetAbilityDamage(),
							damage_type = keys.ability:GetAbilityDamageType(), 
							damage_flags = 0
						}
						UnitDamageTarget(damage_table_death)
						if caster:HasModifier("modifier_item_wanbaochui") then
							UtilStun:UnitStunTarget(caster,v,0.3)
						end
					end
				end		

				return
			end
		end
		
	else
		caster:RemoveModifierByName("modifier_thdots_yuyuko04_think_interval") 
	end
end


--[[
function OnYuyukoKill(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local ability =keys.ability
	
	if caster:HasModifier("modifier_item_wanbaochui") and keys.unit:IsHero()==true and keys.unit:IsIllusion()==false then 
		if(caster:GetContext("Yuyuko_buff")==nil)then
			caster:SetContextNum("Yuyuko_buff",0,0)
			local stack_count = caster:GetContext("Yuyuko_buff")
		end
		if  caster:HasModifier("modifier_yuyuko_wanbaochui_buff")==false then
			stack_count = 2
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_yuyuko_wanbaochui_buff", {})
			caster:SetModifierStackCount("modifier_yuyuko_wanbaochui_buff", ability, stack_count)
		else
			stack_count = stack_count+1
			caster:SetModifierStackCount("modifier_yuyuko_wanbaochui_buff", ability, stack_count)
		end
	end
end
]]--