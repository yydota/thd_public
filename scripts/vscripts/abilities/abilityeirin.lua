if AbilityEirin == nil then
	AbilityEirin = class({})
end

function OnEirin02SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_silencer"))
	keys.ability:SetContextNum("ability_eirin02_spell_x", vecCaster.x, 0)
	keys.ability:SetContextNum("ability_eirin02_spell_y", vecCaster.y, 0)
	keys.ability:SetContextNum("ability_eirin02_spell_z", vecCaster.z, 0)
end

function OnEirin02SpellHit(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	local vecTarget = target:GetOrigin()
	local dealdamage = keys.ability:GetAbilityDamage()
	if caster:HasModifier("modifier_item_wanbaochui") then
		dealdamage=keys.ability:GetAbilityDamage()+caster:GetIntellect()*2.5
	end
	if(target:GetTeam()~=caster:GetTeam())then
		local damage_table = {
				ability = keys.ability,
			    victim = target,
			    attacker = caster,
			    damage = dealdamage,
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
		}
		UnitDamageTarget(damage_table)	
		local spellPoint = Vector(keys.ability:GetContext("ability_eirin02_spell_x"),keys.ability:GetContext("ability_eirin02_spell_y"),keys.ability:GetContext("ability_eirin02_spell_z"))
		local dis = GetDistanceBetweenTwoVec2D(spellPoint,target:GetOrigin())
		local duration = (dis-dis%150)/150*keys.StunDuration
		if(duration>=2.0)then
			duration = 2.0
		end
	    UtilStun:UnitStunTarget(caster,target,duration)
	else
		target:Heal(dealdamage,caster)
	end
	
	local effectIndex = ParticleManager:CreateParticle(
		"particles/units/heroes/hero_witchdoctor/witchdoctor_ward_skull.vpcf", 
		PATTACH_CUSTOMORIGIN, 
		target)
	ParticleManager:SetParticleControl(effectIndex, 0, vecTarget)
	ParticleManager:SetParticleControl(effectIndex, 1, vecTarget)
	ParticleManager:SetParticleControl(effectIndex, 2, vecTarget)
	ParticleManager:DestroyParticleSystem(effectIndex,false)

	EmitSoundOn("Hero_Puck.Dream_Coil", target)


	Timer.Loop 'ability_eirin02_spell_heal' (0.2, 20,
			function(i)
				local targets = FindUnitsInRadius(
				   caster:GetTeam(),		--caster team
				   vecTarget,				--find position
				   nil,						--find entity
				   keys.Radius,				--find radius
				   DOTA_UNIT_TARGET_TEAM_BOTH,
				   keys.ability:GetAbilityTargetType(),
				   0, FIND_CLOSEST,
				   false
			    )
			    if(GetDistanceBetweenTwoVec2D(vecTarget,caster:GetOrigin()) <= keys.Radius)then
					caster:Heal(keys.Damage/5,caster)
			    end
				for k,v in pairs(targets) do
					if(v:GetTeam()~=caster:GetTeam())then
						local damage_table_heal = {
							ability = keys.ability,
				   	 		victim = v,
				   	 		attacker = caster,
				   			damage = keys.Damage/5*0.75,
				   	 		damage_type = keys.ability:GetAbilityDamageType(), 
		    	  	 		damage_flags = 0
						}
				   		UnitDamageTarget(damage_table_heal)
				   	else
						v:Heal(keys.Damage/5,caster)

				   		local healEffectIndex = ParticleManager:CreateParticle(
							"particles/units/heroes/hero_witchdoctor/witchdoctor_voodoo_restoration_heal.vpcf", 
							PATTACH_CUSTOMORIGIN, 
						v)

						ParticleManager:SetParticleControl(healEffectIndex, 0, v:GetOrigin())
				   		Timer.Wait 'ability_eirin02_remove_heal_effect' (1,
							function()
								ParticleManager:DestroyParticleSystem(healEffectIndex,true)
							end
						)
				   	end
			    end
			end
	)
	Timer.Wait 'ability_eirin02_remove_effect' (4,
			function()
				ParticleManager:DestroyParticleSystem(effectIndex,true)
			end
		)
end

function OnEirin03EffectInvisible(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	target:AddNewModifier(nil, nil, "modifier_invisible", {duration=keys.Duration})
end

function OnEirin04SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_silencer_4"))
	keys.ability.target = keys.target
	local effectIndex = ParticleManager:CreateParticle(
			"particles/heroes/eirin/ability_eirin_04.vpcf", 
			PATTACH_CUSTOMORIGIN, 
			keys.target)
	ParticleManager:SetParticleControlEnt(effectIndex , 0, keys.target, 5, "follow_origin", Vector(0,0,0), true)
	ParticleManager:SetParticleControl(effectIndex, 1, keys.target:GetOrigin())
	ParticleManager:DestroyParticleSystemTime(effectIndex,keys.Duration)
	keys.ability.effectIndex = effectIndex
end

function OnEirin04SpellThink(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.ability.target
	local VecCaster = caster:GetOrigin()
		if target:GetHealth() == 0 and target:IsRealHero() then
			target:RemoveModifierByName("modifier_ability_thdots_eirin04_effect")
			
			local effectIndex = ParticleManager:CreateParticle(
				"particles/units/heroes/hero_omniknight/omniknight_purification.vpcf", 
				PATTACH_CUSTOMORIGIN, 
				target)
			ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin())
			ParticleManager:SetParticleControl(effectIndex, 1, target:GetOrigin()/5)
			ParticleManager:SetParticleControl(effectIndex, 2, target:GetOrigin())
			ParticleManager:DestroyParticleSystem(effectIndex,false)
			ParticleManager:DestroyParticleSystem(keys.ability.effectIndex,true)
			if target:GetClassname()=="npc_dota_hero_chaos_knight" then
				target:SetRespawnPosition(VecCaster)
				target:RespawnUnit()
			end
			target:SetHealth(target:GetMaxHealth())
		end	
end

function OnEirinExEffect(keys)
	local caster = keys.caster
	caster.target = keys.target
	caster.effectIndex = ParticleManager:CreateParticle(
			"particles/items_fx/healing_flask.vpcf", 
			PATTACH_CUSTOMORIGIN, 
			keys.target)
	ParticleManager:SetParticleControlEnt(caster.effectIndex , 0, keys.target, 5, "follow_origin", Vector(0,0,0), true)
	ParticleManager:SetParticleControl(caster.effectIndex, 1, keys.target:GetOrigin())
	ParticleManager:DestroyParticleSystemTime(caster.effectIndex,keys.Duration)
end

function OnEirinExTakeDamage(keys)
	local caster=keys.caster
	if keys.attacker:IsHero() then
		caster.target:RemoveModifierByName("modifier_ability_thdots_eirinex_health_regen")
		ParticleManager:DestroyParticle(caster.effectIndex, true)
	end
end