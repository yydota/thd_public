function OnNueExSpellStart(keys)
	if is_spell_blocked(keys.target) then return end
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target

	if target:IsIllusion()==false then
		local DamageTable = {
				victim = target, 
				attacker = caster, 
				ability = keys.ability,
				damage = GetNueExtraDamage(caster) * keys.damage_percent + 45, 
				damage_type = keys.ability:GetAbilityDamageType(), 
				damage_flags = keys.ability:GetAbilityTargetFlags()
		}
		UnitDamageTarget(DamageTable)
	else
		if(caster~=nil)then
			target:Kill(keys.ability, caster)
		else
			target:Kill(keys.ability, nil)
		end
		ability = caster:FindAbilityByName("ability_thdots_nueEx")
		if ability~=nil then
			ability:EndCooldown()
		end
	end
	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_trap_explode.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl( effectIndex , 0, target:GetOrigin())
end

function GetNueExtraDamage(caster)
	local ability = caster:FindAbilityByName("ability_thdots_nue01")
	if ability == nil then
		return 0
	end
	local basedamage = ability:GetSpecialValueFor("damage") + FindTelentValue(caster,"special_bonus_unique_phantom_assassin")

	local extradamage = caster:GetModifierStackCount("modifier_nue_01_extradamage", caster) or 0

	return extradamage*basedamage + basedamage
end

function OnNue01SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel()))

	keys.ability:ApplyDataDrivenModifier( caster, caster, "modifier_nue_01_extradamage", {} )
	caster:SetModifierStackCount("modifier_nue_01_extradamage", caster, caster:GetModifierStackCount("modifier_nue_01_extradamage", caster)+1)

	local effectIndex = ParticleManager:CreateParticle("particles/heroes/nue/ability_nue_01_ball.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(effectIndex , 0, caster, 5, "attach_ball", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effectIndex , 1, caster, 5, "attach_ball", Vector(0,0,0), true)
	ParticleManager:DestroyParticleSystemTime(effectIndex,keys.Duration)
end

function OnNue01AttackLanded(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target

	if(target:IsBuilding()==true)then
		return
	end

	local DamageTable = {
			victim = target, 
			attacker = caster, 
			ability = keys.ability,
			damage = GetNueExtraDamage(caster), 
			damage_type = keys.ability:GetAbilityDamageType(), 
			damage_flags = keys.ability:GetAbilityTargetFlags()
	}
	UnitDamageTarget(DamageTable)
	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_meld_hit.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(effectIndex , 0, target, 5, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effectIndex , 3, target, 5, "attach_hitloc", Vector(0,0,0), true)
end

function OnNue02SpellHit(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local ability = keys.ability
	local target = keys.target

	local damage_table = {
				ability = keys.ability,
			    victim = keys.target,
			    attacker = caster,
			    damage = keys.ability:GetAbilityDamage() + GetNueExtraDamage(caster) * keys.damage_percent,
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = keys.ability:GetAbilityTargetFlags()
	}


	if caster:HasModifier("modifier_item_wanbaochui") then
		local modifier = keys.target:FindModifierByName("modifier_nue_wanbaochui_debuff")

		if  target:IsAlive() and modifier == nil then
			ability:ApplyDataDrivenModifier(caster,target,"modifier_nue_wanbaochui_debuff",{})
			modifier = target:FindModifierByName("modifier_nue_wanbaochui_debuff")
			modifier:IncrementStackCount()
		else
			if  target:IsAlive() then
				modifier:IncrementStackCount()
				modifier:SetDuration(12.0,true)	
			end		
		end
		if target:IsRealHero() then
			THDReduceCooldown(keys.ability,-3)
		end
	end
	UnitDamageTarget(damage_table)


		
end

function OnNue03Kill(keys)
	local caster = keys.attacker
	local target = keys.unit
	local ability = nil
	local level = keys.ability:GetLevel()

	if target:IsHero() and target:IsIllusion() == false then
		if level >= 1 then
 			ability = caster:FindAbilityByName("ability_thdots_nue01")
 			if ability~=nil then
 				ability:EndCooldown()
 			end
 			ability = caster:FindAbilityByName("ability_thdots_nueEx")
 			if ability~=nil then
 				ability:EndCooldown()
 			end
 		end
 		if level >= 2 then
 			ability = caster:FindAbilityByName("ability_thdots_nue02")
 			if ability~=nil then
 				ability:EndCooldown()
 			end
 		end
		if level >= 3 then
			ability = caster:FindAbilityByName("ability_thdots_nue04")
			if ability~=nil then
 				ability:EndCooldown()
 			end
		end
		if level >= 4 then
			for i=0,15 do
			 	ability = caster:GetItemInSlot(i)

			 	if ability~=nil then
	 				ability:EndCooldown()
	 			end
			end 
 		end
	end
	caster:AddExperience(keys.exp_bonus,DOTA_ModifyXP_CreepKill,false,false)
end

function OnNue04PhaseStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local ufoIndex = ParticleManager:CreateParticle("particles/heroes/nue/ability_nue_04_light_ufo.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl( ufoIndex , 0, caster:GetOrigin())
	ParticleManager:DestroyParticleSystemTime(ufoIndex,2.0)
end

function OnNue04Start(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_phantom_assassin_3"))
	local targetPoint = keys.target_points[1]
	caster:EmitSound("Voice_Thdots_Nue.AbilityNue04_1")
	local ufoMoveIndex = ParticleManager:CreateParticle("particles/heroes/nue/ability_minoriko_04_ufo_move.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl( ufoMoveIndex , 0, targetPoint)
	AddFOWViewer( DOTA_TEAM_GOODGUYS, targetPoint, 700, 1.5, false)
	AddFOWViewer( DOTA_TEAM_BADGUYS, targetPoint, 700, 1.5, false)

	local time = 1.5
	caster:SetContextThink(DoUniqueString("OnNue04SpellThinkUfo"), 
		function()
			if GameRules:IsGamePaused() then return 0.03 end
			if time>0 then
				time = time - 0.05
			else
				ParticleManager:DestroyParticleSystem(ufoMoveIndex,true)
				return nil
			end
			ParticleManager:SetParticleControl( ufoMoveIndex , 0, targetPoint - Vector(550,0,0) + (caster:GetOrigin() - targetPoint):Normalized()*time*100 )
			return 0.05
		end,
	0.05)

	caster:AddNoDraw()
	caster:SetContextThink(DoUniqueString("OnNue04SpellThink"), 
		function()
			if GameRules:IsGamePaused() then return 0.03 end
			caster:RemoveNoDraw()
			local targets = FindUnitsInRadius(
			   caster:GetTeam(),		
			   targetPoint,	
			   nil,					
			   keys.Radius,		
			   DOTA_UNIT_TARGET_TEAM_ENEMY,
			   keys.ability:GetAbilityTargetType(),
			   0,
			   FIND_CLOSEST,
			   false
		    )
		    
			local effectIndex = ParticleManager:CreateParticle("particles/heroes/nue/ability_nue_04.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControl( effectIndex , 0, targetPoint)
			ParticleManager:SetParticleControl( effectIndex , 2, Vector(147,112,219))
			caster:EmitSound("Voice_Thdots_Nue.AbilityNue04_2")

		    for k,v in pairs(targets) do
		    	local damage_table = {
					ability = keys.ability,
				    victim = v,
				    attacker = caster,
				    damage = keys.ability:GetAbilityDamage() + GetNueExtraDamage(caster) * keys.damage_percent,
				    damage_type = keys.ability:GetAbilityDamageType(), 
		    	    damage_flags = keys.ability:GetAbilityTargetFlags()
				}
				UtilStun:UnitStunTarget(caster,v,keys.stun_duration+FindTelentValue(caster,"special_bonus_unique_phantom_assassin_2"))	
		    	UnitDamageTarget(damage_table)
			end
			FindClearSpaceForUnit(caster, targetPoint, true)
			caster:StartGesture(ACT_DOTA_CAST_ABILITY_4_END)
			local ufoIndex2 = ParticleManager:CreateParticle("particles/heroes/nue/ability_nue_04_light_ufo.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControl( ufoIndex2 , 0, caster:GetOrigin())
			ParticleManager:DestroyParticleSystemTime(ufoIndex2,1.0)

			caster:EmitSound("Nue.AbilityNue04_End")
			caster:EmitSound("Nue.AbilityNue04_End_stomp")

			return nil
		end,
	1.5)
end