if AbilityMokou == nil then
	AbilityMokou = class({})
end

function OnMokouKill(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local ability1 = caster:FindAbilityByName("ability_thdots_mokou01")
	local ability2 = caster:FindAbilityByName("ability_thdots_mokouEx")
	
	if caster:HasModifier("modifier_item_wanbaochui") and keys.unit:IsHero()==true and keys.unit:IsIllusion()==false then
		ability1:EndCooldown()
		ability2:EndCooldown()
	end
end


function OnMokou01SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)

	local targetPoint = keys.target_points[1]
	local Mokou01rad = GetRadBetweenTwoVec2D(caster:GetOrigin(),targetPoint)
	local Mokou01Distance = GetDistanceBetweenTwoVec2D(caster:GetOrigin(),targetPoint)
	keys.ability.ability_Mokou01_Rad = Mokou01rad
	keys.ability.ability_Mokou01_Distance = Mokou01Distance
end

function OnMokou01SpellMove(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()


	local targets = keys.target_entities
	local MokouExDamage = 1
	if caster:HasModifier("modifier_thdots_Mokou_ex") == true then
		MokouExDamage = 2
	end
	local damageenemy=(keys.ability:GetAbilityDamage()+FindTelentValue(caster,"special_bonus_unique_chaos_knight_3")) / MokouExDamage
	local damageself=(keys.ability:GetAbilityDamage()+FindTelentValue(caster,"special_bonus_unique_chaos_knight_3")) * MokouExDamage


	
	if(keys.ability.ability_Mokou01_Distance<30)then
		
		for _,v in pairs(targets) do

			local damage_table = {
				ability = keys.ability,
				victim = v,
				attacker = caster,
				damage = damageenemy,
				damage_type = keys.ability:GetAbilityDamageType(), 
				damage_flags = keys.ability:GetAbilityTargetFlags()
			}
			UnitDamageTarget(damage_table)
		end
		local damage_table = {
			ability = keys.ability,
			victim = caster,
			attacker = caster,
			damage = damageself,
			damage_type = keys.ability:GetAbilityDamageType(), 
			damage_flags = keys.ability:GetAbilityTargetFlags()
		}
		UnitDamageTarget(damage_table)
		caster:RemoveModifierByName("modifier_thdots_Mokou_ex")
		local effectIndex = ParticleManager:CreateParticle("particles/heroes/mouko/ability_mokou_01_boom.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(effectIndex, 0, caster:GetOrigin())
		ParticleManager:SetParticleControl(effectIndex, 1, caster:GetOrigin())
		ParticleManager:SetParticleControl(effectIndex, 3, caster:GetOrigin())
		ParticleManager:DestroyParticleSystem(effectIndex,false)
		
		SetTargetToTraversable(caster)
		vecCaster = caster:GetOrigin()

		caster:RemoveModifierByName("modifier_thdots_Mokou01_think_interval")
		keys.ability.ability_Mokou01_Distance = 120
		caster:EmitSound("Voice_Thdots_Mokou.AbilityMokou01") 
	else
		local distance = keys.ability.ability_Mokou01_Distance
		distance = distance - keys.MoveSpeed/50
		keys.ability.ability_Mokou01_Distance = distance
	end
	local Mokou01rad = keys.ability.ability_Mokou01_Rad
	local vec = Vector(vecCaster.x+math.cos(Mokou01rad)*keys.MoveSpeed/50,vecCaster.y+math.sin(Mokou01rad)*keys.MoveSpeed/50,GetGroundPosition(vecCaster, nil).z)
	caster:SetOrigin(vec)	
end


function OnMokou02SpellStartUnit(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target

	if(target.ability_Mokou02_speed_increase==nil)then
		target.ability_Mokou02_speed_increase = 0
	end
	local increaseSpeedCount = target.ability_Mokou02_speed_increase
	increaseSpeedCount = increaseSpeedCount + keys.IncreaseSpeed
	if(increaseSpeedCount>keys.IncreaseMaxSpeed)then
		target:RemoveModifierByName("modifier_mokou02_speed_up")
	else
		target.ability_Mokou02_speed_increase = increaseSpeedCount
		target:SetThink(
			function()
				target:RemoveModifierByName("modifier_flandre02_slow")
				local decreaseSpeedNow = target.ability_Mokou02_speed_increase - keys.IncreaseSpeed
				target.ability_Mokou02_speed_increase = decreaseSpeedNow	
			end, 
			DoUniqueString("ability_flandre02_speed_increase_duration"), 
			keys.Duration
		)	
	end
end

function OnMokou02DamageStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targets = keys.target_entities

	if(caster.ability_Mokou02_damage_bouns==nil)then
		caster.ability_Mokou02_damage_bouns = 0
	end

	local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/mouko/ability_mokou_02_boom.vpcf", PATTACH_CUSTOMORIGIN, caster)
	if(targets[1]~=nil)then
		ParticleManager:SetParticleControl(effectIndex, 0, targets[1]:GetOrigin())
		ParticleManager:SetParticleControl(effectIndex, 1, Vector(300,0,0))
		ParticleManager:DestroyParticleSystem(effectIndex,false)
	end

	for _,v in pairs(targets) do
		local dealdamage = keys.BounsDamage + caster.ability_Mokou02_damage_bouns 
		local damage_table = {
				ability = keys.ability,
			    victim = v,
			    attacker = caster,
			    damage = dealdamage,
			    damage_type = keys.ability:GetAbilityDamageType(),
	    	    damage_flags = 0
		}
		UnitDamageTarget(damage_table)
	end
end

function OnMokou04SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local dealdamage = caster:GetHealth() * keys.CostHp
	local damage_table = {
				ability = keys.ability,
			    victim = caster,
			    attacker = caster,
			    damage = dealdamage,
			    damage_type = keys.ability:GetAbilityDamageType(),
	    	    damage_flags = 0
	}
	if FindTelentValue(caster,"special_bonus_unique_chaos_knight") == 0 then
		UnitDamageTarget(damage_table)
	end

	--[[local unit = CreateUnitByName(
		"npc_dota2x_unit_mokou_04"
		,caster:GetOrigin() - caster:GetForwardVector() * 15 + Vector(0,0,170)
		,false
		,caster
		,caster
		,caster:GetTeam()
	)
	unit:SetForwardVector(caster:GetForwardVector())]]

	caster.ability_Mokou02_damage_bouns = keys.BounsDamage
	Timer.Wait 'ability_Mokou02_damage_bouns_timer' (20,
		function()
			caster.ability_Mokou02_damage_bouns = 0
		end
	)

	local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/mouko/ability_mokou_04_wing.vpcf", PATTACH_CUSTOMORIGIN, caster) 
	ParticleManager:SetParticleControlEnt(effectIndex , 0, caster, 5, "follow_origin", Vector(0,0,0), true)

	Timer.Wait 'ability_mokou_04_wing_destory' (20,
			function()
				ParticleManager:DestroyParticle(effectIndex,true)
			end
		)


	--[[Timer.Loop 'ability_Mokou04_wing_timer' (0.1, 200,
		function(i)
			unit:SetOrigin(caster:GetOrigin() - caster:GetForwardVector() * 15 + Vector(0,0,170))
			unit:SetForwardVector(caster:GetForwardVector())
			if(caster:IsAlive()==false)then
				unit:RemoveSelf()
				return nil
			end
		end
	)
	unit:SetContextThink('ability_Mokou04_wing_unit_timer',
		function()
			unit:RemoveSelf()
			return nil
		end, 
	20.5)]]
end

function OnMokouExSpellStart(keys)
	local caster = keys.caster
	local ability = nil
	ability = caster:FindAbilityByName("ability_thdots_mokou01")
	if ability~=nil then
		ability:EndCooldown()
	end
end