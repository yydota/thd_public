--keys.caster --施法者
--keys.target_entities -- 目标表
--keys.ability --技能

function OnRumia01SpellEffectStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	if FindTelentValue(caster,"special_bonus_unique_lifestealer_3")==1 then
		caster:Purge(false,true,false,true,false)
	end
	local unit = CreateUnitByName(
		"npc_dummy_unit"
		,caster:GetOrigin()
		,false
		,caster
		,caster
		,caster:GetTeam()
	)
	local ability_dummy_unit = unit:FindAbilityByName("ability_dummy_unit")
	ability_dummy_unit:SetLevel(1)
	
	local nEffectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/rumia/ability_rumia01_effect.vpcf",PATTACH_CUSTOMORIGIN,unit)
	ParticleManager:SetParticleControl( nEffectIndex, 0, caster:GetOrigin())
	ParticleManager:SetParticleControl( nEffectIndex, 1, caster:GetOrigin())
	keys.ability:SetContextNum("ability_rumia01_effect",nEffectIndex,0)
	caster.ability_rumia_01_unit = unit
	unit:SetContextThink("ability_rumia01_effect_timer", 
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			unit:RemoveSelf()
			return nil
		end, 
		keys.Duration+0.1)
end

function OnRumia01SpellEffectThink(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local nEffectIndex = keys.ability:GetContext("ability_rumia01_effect")
	ParticleManager:SetParticleControl( nEffectIndex, 0, caster:GetOrigin())
	ParticleManager:SetParticleControl( nEffectIndex, 1, caster:GetOrigin())
	if caster.ability_rumia_01_unit~=nil and caster.ability_rumia_01_unit:IsNull() == false then
		caster.ability_rumia_01_unit:SetOrigin(caster:GetOrigin())
	end
end

function OnRumia02BloodDamage( keys )
	if keys.target ~= nil then
		local caster = EntIndexToHScript(keys.caster_entindex)
		local target = keys.target
		--[[local al = keys.ability:GetLevel() - 1
		damage = keys.ability:GetLevelSpecialValueFor("damage", al)]]--
	    local DamageTable = {
	    						ability = keys.ability,
							    victim = target, 
							    attacker = caster, 
							    damage = keys.dv,
							    damage_type = keys.ability:GetAbilityDamageType(),
							    damage_flags = 0
							}
	    UnitDamageTarget(DamageTable)
	  end
end

function OnRumia02Blood(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	if keys.target ~= nil then
		if not target:IsAncient() then
			Timer.Loop 'Rumia_Blood' (keys.ti,keys.dc,
								    function(i)

							            local DamageTable = {
							            						ability = keys.ability,
											                    victim = target, 
											                    attacker = caster, 
											                    damage = keys.dv, 
											                    damage_type = keys.ability:GetAbilityDamageType(),
											                    damage_flags = 0
															}
					    				UnitDamageTarget(DamageTable)
					                    if i == keys.dc then
					                    	--以下的语句为继续执行
					                    	--return true
										end
					                    --伤害次数
										--[[local count = v:GetContext("Reimu04_Effect_Damage_Count")
										count = count - 1
										--每次减一
										if (count<=0) then
											v:SetContextNum("Reimu04_Effect_Damage_Count" , 0, 0)
											return nil
											--小于0清0滚粗返空解除
										else
										    if(v~=nil)then
												v:SetContextNum("Reimu04_Effect_Damage_Count" , count, 0)
											end
											--大于0继续
										end]]--
								    end
							        )
		end
	end
end
function OnRumia04Start(keys)

	if keys.target ~= nil then
		if is_spell_blocked(keys.target) then return end
		local caster = EntIndexToHScript(keys.caster_entindex)
		if RollPercentage(50) then
			caster:EmitSound("Voice_Thdots_Rumia.AbilityRumia04")
		end
		THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_lifestealer_2"))
		local target = keys.target

		if(caster:GetContext("Rumia04_Strength_Up")==nil)then
				caster:SetContextNum("Rumia04_Strength_Up",0,0)
		end
		local Rumia_Strength_Up = caster:GetContext("Rumia04_Strength_Up")
		local DamageTable= {
								ability = keys.ability,
								victim = target,
								attacker = caster,
								damage = keys.ability:GetAbilityDamage(),
								damage_type = DAMAGE_TYPE_PURE,
							}
		if target:IsHero() ==false and (target:GetClassname()~="npc_dota_roshan") then
			DamageTable.damage = 99999
		end


	    if (caster:GetTeam() ~= target:GetTeam())then
	    	if target:GetHealth() <= DamageTable.damage  then
	    		local strength = 0
	    		if target:IsHero() then
	    			if not target:IsIllusion()	then
	    				Rumia_Strength_Up = Rumia_Strength_Up + 5 + 5*FindTelentValue(caster,"special_bonus_unique_lifestealer") 
	    				strength = 5 + 5*FindTelentValue(caster,"special_bonus_unique_lifestealer") 
	    			end
	    		else
	    			Rumia_Strength_Up = Rumia_Strength_Up + 1 + 1*FindTelentValue(caster,"special_bonus_unique_lifestealer") 
	    			strength = 1 + 1*FindTelentValue(caster,"special_bonus_unique_lifestealer") 
	    		end
				caster:SetHealth(caster:GetHealth() + target:GetHealth()*keys.StealHealth)
	    		caster:SetContextNum("Rumia04_Strength_Up",Rumia_Strength_Up,0)
	    		caster:SetBaseStrength(caster:GetBaseStrength() + strength)
	    	else
	    		caster:SetHealth(caster:GetHealth() + keys.ability:GetAbilityDamage()*keys.StealHealth)
	    	end
	    	UnitDamageTarget(DamageTable)
	    end
	end
end
function OnRumiaDead(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	if caster ~= nil then
		local Rumia_Strength_Up = caster:GetContext("Rumia04_Strength_Up")
		if ( Rumia_Strength_Up <= 0 or Rumia_Strength_Up == nil ) then return end	
		local strengthDown = Rumia_Strength_Up*keys.LostStrength
		Rumia_Strength_Up = Rumia_Strength_Up - strengthDown
		caster:SetContextNum("Rumia04_Strength_Up",Rumia_Strength_Up,0)
		caster:SetBaseStrength(caster:GetBaseStrength() - strengthDown)
	end
end


function OnRumia03Think(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local ability = keys.ability

	if caster:IsAlive() then
		if caster:HasModifier("modifier_rumia_03_day") == false and caster:HasModifier("modifier_rumia_03_night") == false then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_rumia_03_day", {})
		end

		if GameRules:IsDaytime() then
			if caster:HasModifier("modifier_rumia_03_day") == false and caster:HasModifier("modifier_rumia_03_night") == true then
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_rumia_03_day", {})
				caster:RemoveModifierByName("modifier_rumia_03_night")
			end
		else
			if caster:HasModifier("modifier_rumia_03_day") == true and caster:HasModifier("modifier_rumia_03_night") == false then
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_rumia_03_night", {})
				caster:RemoveModifierByName("modifier_rumia_03_day")
			end
		end
	end
end

function Rumiawanbaochui(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if (caster:IsRealHero() and caster:HasModifier("modifier_item_wanbaochui") and target:IsBuilding()==false) then
		local Rumia_Strength_Up = caster:GetContext("Rumia04_Strength_Up")
		local DamageTable= {
								ability = keys.ability,
								victim = target,
								attacker = caster,
								damage = keys.ability:GetAbilityDamage()/2,
								damage_type = DAMAGE_TYPE_PURE,
							}
		if target:IsHero() ==false and (target:GetClassname()~="npc_dota_roshan") then
			DamageTable.damage = 99999
		end
		if (caster:GetTeam() ~= target:GetTeam())then
	    	if target:GetHealth() <= DamageTable.damage  then
				caster:SetHealth(caster:GetHealth() + target:GetHealth()*keys.StealHealth)
	    	else
	    		caster:SetHealth(caster:GetHealth() + DamageTable.damage*keys.StealHealth)
	    	end
			UnitDamageTarget(DamageTable)
			local vec = keys.target:GetOrigin()
			local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControl(effectIndex, 0, vec)
			ParticleManager:SetParticleControl(effectIndex, 1, vec)
			ParticleManager:SetParticleControl(effectIndex, 2, vec)
			ParticleManager:SetParticleControl(effectIndex, 3, vec)
			ParticleManager:SetParticleControl(effectIndex, 4, vec)
			ParticleManager:SetParticleControl(effectIndex, 8, vec)
		end
	end
end
















--[[	
		if(target:IsHero()==false and target:GetUnitName()~="npc_dota_roshan") then
			target:Kill(keys.ability,caster)
			target:EmitSound("Ability.SandKing_CausticFinale")
			local vec = keys.target:GetOrigin()
			local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControl(effectIndex, 0, vec)
			ParticleManager:SetParticleControl(effectIndex, 1, vec)
			ParticleManager:SetParticleControl(effectIndex, 2, vec)
			ParticleManager:SetParticleControl(effectIndex, 3, vec)
			ParticleManager:SetParticleControl(effectIndex, 4, vec)
			ParticleManager:SetParticleControl(effectIndex, 8, vec)
		else
			local RandomNumber = RandomInt(1,100)
			if RandomNumber<18 then
				target:Kill(keys.ability,caster)
				target:EmitSound("Ability.SandKing_CausticFinale")
				local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_fallback_mid.vpcf", PATTACH_CUSTOMORIGIN, caster)
				ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin())
				ParticleManager:DestroyParticleSystem(effectIndex,false)
			end
		end
	end
end
]]	--
	