--[[function OnPatchouliSelect(keys)
	local caster=keys.caster
	local time = 0
	caster:SetContextThink(DoUniqueString("OnPatchouliSelect"), 
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			if time < 180 then 
				time = time + 0.2
			else				
				return nil
			end	
			if caster:HasModifier("modifier_thdots_patchouli_select") then 
				if caster:HasModifier("modifier_thdots_patchouli_fire")==true then
					caster:SwapAbilities("invoker_empty1", "ability_thdots_patchouli_fire", true, false)
					caster:RemoveAbility("ability_thdots_patchouli_fire")
					caster:RemoveModifierByName("modifier_thdots_patchouli_fire")					
					local ability = caster:FindAbilityByName("ability_thdots_patchouli_water")
					ability:SetLevel(0)
					ability = caster:FindAbilityByName("ability_thdots_patchouli_wood")
					ability:SetLevel(0)
					ability = caster:FindAbilityByName("ability_thdots_patchouli_metal")
					ability:SetLevel(0)
					ability = caster:FindAbilityByName("ability_thdots_patchouli_earth")
					ability:SetLevel(0)
					caster:RemoveModifierByName("modifier_thdots_patchouli_select")
					ability = caster:AddAbility("ability_thdots_patchouli_earth_earth")
					ability:SetLevel(1)
					ability:SetHidden(true)
					return nil
				elseif caster:HasModifier("modifier_thdots_patchouli_water")==true then
					caster:SwapAbilities("invoker_empty1", "ability_thdots_patchouli_water", true, false)
					caster:RemoveAbility("ability_thdots_patchouli_water")
					caster:RemoveModifierByName("modifier_thdots_patchouli_water")			
					ability = caster:FindAbilityByName("ability_thdots_patchouli_fire")
					ability:SetLevel(0)
					ability = caster:FindAbilityByName("ability_thdots_patchouli_wood")
					ability:SetLevel(0)
					ability = caster:FindAbilityByName("ability_thdots_patchouli_metal")
					ability:SetLevel(0)
					ability = caster:FindAbilityByName("ability_thdots_patchouli_earth")
					ability:SetLevel(0)
					caster:RemoveModifierByName("modifier_thdots_patchouli_select")
					ability = caster:AddAbility("ability_thdots_patchouli_earth_earth")
					ability:SetLevel(1)
					ability:SetHidden(true)
					return nil
				elseif caster:HasModifier("modifier_thdots_patchouli_wood")==true then
					caster:SwapAbilities("invoker_empty1", "ability_thdots_patchouli_wood", true, false)
					caster:RemoveAbility("ability_thdots_patchouli_wood")
					caster:RemoveModifierByName("modifier_thdots_patchouli_wood")
					ability = caster:FindAbilityByName("ability_thdots_patchouli_fire")
					ability:SetLevel(0)
					ability = caster:FindAbilityByName("ability_thdots_patchouli_water")
					ability:SetLevel(0)
					ability = caster:FindAbilityByName("ability_thdots_patchouli_metal")
					ability:SetLevel(0)
					ability = caster:FindAbilityByName("ability_thdots_patchouli_earth")
					ability:SetLevel(0)
					caster:RemoveModifierByName("modifier_thdots_patchouli_select")	
					ability = caster:AddAbility("ability_thdots_patchouli_earth_earth")
					ability:SetLevel(1)
					ability:SetHidden(true)	
					return nil	
				elseif caster:HasModifier("modifier_thdots_patchouli_metal")==true then
					caster:SwapAbilities("invoker_empty1", "ability_thdots_patchouli_metal", true, false)
					caster:RemoveAbility("ability_thdots_patchouli_metal")
					caster:RemoveModifierByName("modifier_thdots_patchouli_metal")
					ability = caster:FindAbilityByName("ability_thdots_patchouli_fire")
					ability:SetLevel(0)
					ability = caster:FindAbilityByName("ability_thdots_patchouli_wood")
					ability:SetLevel(0)
					ability = caster:FindAbilityByName("ability_thdots_patchouli_water")
					ability:SetLevel(0)
					ability = caster:FindAbilityByName("ability_thdots_patchouli_earth")
					ability:SetLevel(0)
					caster:RemoveModifierByName("modifier_thdots_patchouli_select")
					ability = caster:AddAbility("ability_thdots_patchouli_earth_earth")
					ability:SetLevel(1)
					ability:SetHidden(true)
					return nil
				elseif caster:HasModifier("modifier_thdots_patchouli_earth")==true then
					caster:SwapAbilities("invoker_empty1", "ability_thdots_patchouli_earth", true, false)
					caster:RemoveAbility("ability_thdots_patchouli_earth")
					caster:RemoveModifierByName("modifier_thdots_patchouli_earth")
					ability = caster:FindAbilityByName("ability_thdots_patchouli_fire")
					ability:SetLevel(0)
					ability = caster:FindAbilityByName("ability_thdots_patchouli_wood")
					ability:SetLevel(0)
					ability = caster:FindAbilityByName("ability_thdots_patchouli_metal")
					ability:SetLevel(0)
					ability = caster:FindAbilityByName("ability_thdots_patchouli_water")
					ability:SetLevel(0)
					caster:RemoveModifierByName("modifier_thdots_patchouli_select")
					return nil
				end
				
			end
			return 0.2
		end,
	0)
end
--]]

function OnPatchouliAddFire(keys)
	local caster=keys.caster
	if caster.ElementsNum==nil then caster.ElementsNum=1 end
	if caster.ElementsName==nil then caster.ElementsName={} end

	if caster.ElementsNum==1 and caster.ElementsName[1]~=nil then
		caster:RemoveModifierByName(caster.ElementsName[1])	
	elseif caster.ElementsNum==2 and caster.ElementsName[2]~=nil then		
		caster:RemoveModifierByName(caster.ElementsName[2])	
	elseif caster.ElementsNum==3 then		
		caster.ElementsNum=1
		caster:RemoveModifierByName(caster.ElementsName[1])	
	end
	caster.ElementsName[caster.ElementsNum]="modifier_thdots_patchouli_fire"
	caster.ElementsNum=caster.ElementsNum+1
end

function OnPatchouliAddWater(keys)
	local caster=keys.caster
	if caster.ElementsNum==nil then caster.ElementsNum=1 end
	if caster.ElementsName==nil then caster.ElementsName={} end
	if caster.ElementsNum==1 and caster.ElementsName[1]~=nil then
		caster:RemoveModifierByName(caster.ElementsName[1])	
	elseif caster.ElementsNum==2 and caster.ElementsName[2]~=nil then		
		caster:RemoveModifierByName(caster.ElementsName[2])	
	elseif caster.ElementsNum==3 then		
		caster.ElementsNum=1
		caster:RemoveModifierByName(caster.ElementsName[1])	
	end
	caster.ElementsName[caster.ElementsNum]="modifier_thdots_patchouli_water"
	caster.ElementsNum=caster.ElementsNum+1
end

function OnPatchouliAddWood(keys)
	local caster=keys.caster
	if caster.ElementsNum==nil then caster.ElementsNum=1 end
	if caster.ElementsName==nil then caster.ElementsName={} end
	if caster.ElementsNum==1 and caster.ElementsName[1]~=nil then
		caster:RemoveModifierByName(caster.ElementsName[1])	
	elseif caster.ElementsNum==2 and caster.ElementsName[2]~=nil then		
		caster:RemoveModifierByName(caster.ElementsName[2])	
	elseif caster.ElementsNum==3 then		
		caster.ElementsNum=1
		caster:RemoveModifierByName(caster.ElementsName[1])	
	end
	caster.ElementsName[caster.ElementsNum]="modifier_thdots_patchouli_wood"
	caster.ElementsNum=caster.ElementsNum+1
end

function OnPatchouliAddMetal(keys)
	local caster=keys.caster
	if caster.ElementsNum==nil then caster.ElementsNum=1 end
	if caster.ElementsName==nil then caster.ElementsName={} end
	if caster.ElementsNum==1 and caster.ElementsName[1]~=nil then
		caster:RemoveModifierByName(caster.ElementsName[1])	
	elseif caster.ElementsNum==2 and caster.ElementsName[2]~=nil then		
		caster:RemoveModifierByName(caster.ElementsName[2])	
	elseif caster.ElementsNum==3 then		
		caster.ElementsNum=1
		caster:RemoveModifierByName(caster.ElementsName[1])	
	end
	caster.ElementsName[caster.ElementsNum]="modifier_thdots_patchouli_metal"
	caster.ElementsNum=caster.ElementsNum+1
end

function OnPatchouliAddEarth(keys)
	local caster=keys.caster
	if caster.ElementsNum==nil then caster.ElementsNum=1 end
	if caster.ElementsName==nil then caster.ElementsName={} end
	if caster.ElementsNum==1 and caster.ElementsName[1]~=nil then
		caster:RemoveModifierByName(caster.ElementsName[1])	
	elseif caster.ElementsNum==2 and caster.ElementsName[2]~=nil then		
		caster:RemoveModifierByName(caster.ElementsName[2])	
	elseif caster.ElementsNum==3 then		
		caster.ElementsNum=1
		caster:RemoveModifierByName(caster.ElementsName[1])	
	end
	caster.ElementsName[caster.ElementsNum]="modifier_thdots_patchouli_earth"
	caster.ElementsNum=caster.ElementsNum+1
end

function OnPatchouliInvoke(keys)
	local caster=keys.caster
	--[[local manaCost = keys.ManaCost*0.01*caster:GetMana()		--消耗当前法力值*蓝耗系数
		if FindTelentValue(caster,"special_bonus_unique_invoker_5") ~= 1 then
			caster:SetMana(caster:GetMana()-manaCost)
		end]]
	if caster.SwapAbilityName == nil then caster.SwapAbilityName= "ability_thdots_patchouli_xianzhezhishi" end
	if caster:HasModifier("modifier_thdots_patchouli_fire") and caster:HasModifier("modifier_thdots_patchouli_water") then 
		caster.NewAbilityName="ability_thdots_patchouli_fire_water"
	elseif caster:HasModifier("modifier_thdots_patchouli_fire") and caster:HasModifier("modifier_thdots_patchouli_wood") then 
		caster.NewAbilityName="ability_thdots_patchouli_fire_wood"	
	elseif caster:HasModifier("modifier_thdots_patchouli_fire") and caster:HasModifier("modifier_thdots_patchouli_metal") then 
		caster.NewAbilityName="ability_thdots_patchouli_fire_metal"
	elseif caster:HasModifier("modifier_thdots_patchouli_fire") and caster:HasModifier("modifier_thdots_patchouli_earth") then 
		caster.NewAbilityName="ability_thdots_patchouli_fire_earth"
	elseif caster:HasModifier("modifier_thdots_patchouli_water") and caster:HasModifier("modifier_thdots_patchouli_wood") then 
		caster.NewAbilityName="ability_thdots_patchouli_water_wood"
	elseif caster:HasModifier("modifier_thdots_patchouli_water") and caster:HasModifier("modifier_thdots_patchouli_metal") then 
		caster.NewAbilityName="ability_thdots_patchouli_water_metal"
	elseif caster:HasModifier("modifier_thdots_patchouli_water") and caster:HasModifier("modifier_thdots_patchouli_earth") then 
		caster.NewAbilityName="ability_thdots_patchouli_water_earth"
	elseif caster:HasModifier("modifier_thdots_patchouli_wood") and caster:HasModifier("modifier_thdots_patchouli_metal") then 
		caster.NewAbilityName="ability_thdots_patchouli_wood_metal"
	elseif caster:HasModifier("modifier_thdots_patchouli_wood") and caster:HasModifier("modifier_thdots_patchouli_earth") then 
		caster.NewAbilityName="ability_thdots_patchouli_wood_earth"
	elseif caster:HasModifier("modifier_thdots_patchouli_metal") and caster:HasModifier("modifier_thdots_patchouli_earth") then 
		caster.NewAbilityName="ability_thdots_patchouli_metal_earth"
	else
		if caster:HasModifier("modifier_thdots_patchouli_fire") then 
			caster.NewAbilityName="ability_thdots_patchouli_fire_fire"
		elseif caster:HasModifier("modifier_thdots_patchouli_water") then 
			caster.NewAbilityName="ability_thdots_patchouli_water_water"
		elseif caster:HasModifier("modifier_thdots_patchouli_wood") then 
			caster.NewAbilityName="ability_thdots_patchouli_wood_wood"
		elseif caster:HasModifier("modifier_thdots_patchouli_metal") then 
			caster.NewAbilityName="ability_thdots_patchouli_metal_metal"
		elseif caster:HasModifier("modifier_thdots_patchouli_earth") then 
			caster.NewAbilityName="ability_thdots_patchouli_earth_earth"
		end
	end
	if caster.SwapAbilityName~=caster.NewAbilityName then 
		caster:SwapAbilities(caster.NewAbilityName, caster.SwapAbilityName, true, false)
		caster.SwapAbilityName = caster.NewAbilityName
	end
end

function OnPatchouliFireWater(keys)
	if is_spell_blocked(keys.target) then return end
	local caster=keys.caster
	local target=keys.target	
	local targetPoint
	local firelevel
	local waterlevel
	local CasterName = caster:GetClassname()
	if CasterName ~= "npc_dota_hero_invoker" then
		if caster:GetLevel()>=13 then 
			firelevel =7
			waterlevel =7
		else
			firelevel =math.floor((caster:GetLevel()+1)/2)
			waterlevel =math.floor((caster:GetLevel()+1)/2)
		end
	else
		local abilityfire=caster:FindAbilityByName("ability_thdots_patchouli_fire")
		local abilitywater=caster:FindAbilityByName("ability_thdots_patchouli_water")
		firelevel=abilityfire:GetLevel()
		waterlevel=abilitywater:GetLevel()
	end
	local deal_duration= keys.Duration + waterlevel*keys.WaterMultiple
	--print("duration", deal_duration)
	local deal_damage=keys.Damage + firelevel*keys.FireMultiple
	--print("deal_damage", deal_damage)

	local time = 0
	target:SetContextThink(DoUniqueString("OnPatchouliFireWaterThink"), 
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			if time < deal_duration then 
				time = time + 0.5

			else
				return nil
			end
			targetPoint = target:GetOrigin()
			local targets = FindUnitsInRadius(
			   		caster:GetTeam(),		--caster team
			  		targetPoint,		--find position
			   		nil,					--find entity
			   		keys.Radius,		--find radius
			   		DOTA_UNIT_TARGET_TEAM_ENEMY,
			   		keys.ability:GetAbilityTargetType(),
			   		0, 
			   		FIND_CLOSEST,
			   		false
		    	)

			for _,v in pairs(targets) do
				local damage_table = {
						ability = keys.ability,
					    victim = v,
					    attacker = caster,
					    damage = deal_damage/2,
					    damage_type = keys.ability:GetAbilityDamageType(), 
			    	    damage_flags = 0
				}
				UnitDamageTarget(damage_table)
				keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_thdots_patchouli_fire_water", {duration=0.5})
			end
			return 0.5
		end,
	0.5)
	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_thdots_patchouli_fire_water", {duration=deal_duration})
end

function OnPatchouliFireWood(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local firelevel
	local woodlevel
	
	local CasterName = caster:GetClassname()
	if CasterName ~= "npc_dota_hero_invoker" then
		if caster:GetLevel()>=13 then 
			firelevel =7
			woodlevel =7
		else
			firelevel =math.floor((caster:GetLevel()+1)/2)
			woodlevel =math.floor((caster:GetLevel()+1)/2)
		end
	else
		local abilityfire=caster:FindAbilityByName("ability_thdots_patchouli_fire")
		local abilitywood=caster:FindAbilityByName("ability_thdots_patchouli_wood")
		firelevel=abilityfire:GetLevel()
		woodlevel=abilitywood:GetLevel()
	end
	local deal_damage=keys.Damage + firelevel*keys.FireMultiple
	local delaytime=keys.DelayTime - keys.WoodMultiple*woodlevel
	local tree

	local effectIndex = ParticleManager:CreateParticle("particles/battlepass/healing_campfire_flame.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(effectIndex, 0, keys.target_points[1])
	ParticleManager:SetParticleControl(effectIndex, 1, keys.target_points[1])
	ParticleManager:SetParticleControl(effectIndex, 2, keys.target_points[1])
	ParticleManager:DestroyParticleSystem(effectIndex,false)


	if GridNav:IsNearbyTree(keys.target_points[1], keys.Radius+FindTelentValue(caster,"special_bonus_unique_invoker_10"), false) then
		tree = 1
	end

	local time = 0
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("OnPatchouliFireWood"), 
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			if time < delaytime+keys.Duration then 
				time = time + keys.WoodMultiple
				--print("time",time)
			else
				return nil
			end		
			if time==delaytime+keys.WoodMultiple then 
				StartSoundEventFromPosition("Hero_Jakiro.LiquidFire", keys.target_points[1])
				local effectIndex = ParticleManager:CreateParticle("particles/heroes/patchouli/fire_wood_char.vpcf", PATTACH_CUSTOMORIGIN, nil)
				ParticleManager:SetParticleControl(effectIndex, 0, keys.target_points[1])
				--ParticleManager:SetParticleControl(effectIndex, 1, Vector(2,1,1))
				--ParticleManager:DestroyParticleSystemTime(effectIndex,5)
			end	
			if time>delaytime then 
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
					local damage_table = {
							ability = keys.ability,
						    victim = v,
						    attacker = caster,
						    damage = deal_damage/4,
						    damage_type = keys.ability:GetAbilityDamageType(), 
				    	    damage_flags = 0
					}

					if tree ==1 then
						damage_table.damage=damage_table.damage*1.5
					elseif v:HasModifier("modifier_patchouli_wood_earth_root") then 
						damage_table.damage=damage_table.damage*1.5
					end
					UnitDamageTarget(damage_table)
				end
			end
			return 0.25
		end,
	0)	
end

function OnPatchouliFireMetal(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
		
	local target = keys.target
	local firelevel			
	local metallevel
	
	local CasterName = caster:GetClassname()
	if CasterName ~= "npc_dota_hero_invoker" then
		if caster:GetLevel()>=13 then 
			firelevel =7			
			metallevel =7			
		else
			firelevel =math.floor((caster:GetLevel()+1)/2)			
			metallevel =math.floor((caster:GetLevel()+1)/2)			
		end
	else
		local abilityfire=caster:FindAbilityByName("ability_thdots_patchouli_fire")
		local abilitymetal=caster:FindAbilityByName("ability_thdots_patchouli_metal")
		firelevel=abilityfire:GetLevel()
		metallevel=abilitymetal:GetLevel()
	end
	
	if target:GetTeam()==caster:GetTeam() then
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_patchouli_fire_metal_bonus_damage", {})
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_patchouli_fire_metal_bonus_attack_speed", {})
		target:SetModifierStackCount("modifier_patchouli_fire_metal_bonus_damage", keys.ability, firelevel*15+FindTelentValue(caster,"special_bonus_unique_invoker_1"))
		target:SetModifierStackCount("modifier_patchouli_fire_metal_bonus_attack_speed", keys.ability, metallevel*15+FindTelentValue(caster,"special_bonus_unique_invoker_1"))
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_patchouli_fire_metal_effect", {})
	else	
		if is_spell_blocked(keys.target) then return end
		local deal_mana_damage = keys.BaseManaDamage + target:GetMana()*(keys.ManaDamage+metallevel*keys.MetalMultiple)
		local deal_health_damage = deal_mana_damage*(keys.HealthDamage+firelevel*keys.FireMultiple)

		local damage_target = {
			victim = keys.target,
			attacker = caster,
			damage = deal_health_damage,
			damage_type = keys.ability:GetAbilityDamageType(), 
		    damage_flags = 0
		}
		UnitDamageTarget(damage_target)
		target:ReduceMana(deal_mana_damage)
		local digits = string.len( math.floor( deal_mana_damage ) ) + 1
		local numberIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn_msg.vpcf", PATTACH_OVERHEAD_FOLLOW, target )
		ParticleManager:SetParticleControl( numberIndex, 1, Vector( 1, deal_mana_damage, 0 ) )
	    ParticleManager:SetParticleControl( numberIndex, 2, Vector( 2.0, digits, 0 ) )
	    Timer.Wait 'patchouli_fire_metal' (2.0,
			function()				
				ParticleManager:DestroyParticleSystem( numberIndex, false )
			end
		)  
	end 
end

function OnPatchouliFireEarth(keys)
	local caster = keys.caster
	local radius = keys.Radius
	local duration = keys.Duration
	local target = keys.target
	local ability = keys.ability
	ability.center = keys.target_points[1]
	local firelevel		
	local earthlevel
	local CasterName = caster:GetClassname()
	if CasterName ~= "npc_dota_hero_invoker" then
		if caster:GetLevel()>=13 then 
			firelevel =7			
			earthlevel =7
		else
			firelevel =math.floor((caster:GetLevel()+1)/2)			
			earthlevel =math.floor((caster:GetLevel()+1)/2)
		end
	else
		local abilityfire=caster:FindAbilityByName("ability_thdots_patchouli_fire")
		local abilityearth=caster:FindAbilityByName("ability_thdots_patchouli_earth")
		firelevel=abilityfire:GetLevel()
		earthlevel=abilityearth:GetLevel()
	end
	
	local deal_damage=keys.Damage + firelevel*keys.FireMultiple
	--local deal_stun_duration = keys.StunDuration + earthlevel*keys.EarthMultiple
	local deal_duration = keys.Duration + earthlevel*keys.EarthMultiple

	keys.ability:ApplyDataDrivenThinker(caster, keys.target_points[1], "modifier_kinetic_field_datadriven", {duration=deal_duration})
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
				--[[for _,v in pairs(targets) do
					UtilStun:UnitStunTarget(caster,v,deal_stun_duration)
				end]]
				for _,v in pairs(targets) do
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


	if caster.VolcanoEffect == nil then
		caster.VolcanoEffect = {}
	end

	local angle = math.pi/8
	for i=1,16 do
		local position = Vector(keys.target_points[1].x+radius*math.sin(angle), keys.target_points[1].y+radius*math.cos(angle), keys.target_points[1].z)
		angle = angle + math.pi/8
		local effectIndex = ParticleManager:CreateParticle("particles/heroes/patchouli/patchouli_volcano.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(effectIndex, 0, position)
		ParticleManager:SetParticleControl(effectIndex, 1, position)
		ParticleManager:SetParticleControl(effectIndex, 2,  Vector(deal_duration,0,2))
		caster.VolcanoEffect[i]=effectIndex		
	end
	local time = 0
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("OnPatchouliFireEarthEffect"), 
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			if time < deal_duration+1 then 
				--print("time",time)
				time = time + 0.5
			else
				return nil
			end			
			if time > deal_duration then 
				for i=1,16 do
					ParticleManager:DestroyParticleSystem(caster.VolcanoEffect[i],false)
				end
			end
			return 0.5
		end,
	0)
end

function CheckPosition(keys)
	local caster = keys.caster
	local target = keys.unit
	local ability = keys.ability
	local radius = keys.Radius
	local duration = keys.Duration
	local earthlevel	
	local CasterName = caster:GetClassname()
	if CasterName ~= "npc_dota_hero_invoker" then
		if caster:GetLevel()>=13 then 
			earthlevel =7			
		else
			earthlevel =math.floor((caster:GetLevel()+1)/2)			
		end
	else
		local abilityearth=caster:FindAbilityByName("ability_thdots_patchouli_earth")
		earthlevel=abilityearth:GetLevel()
	end
	local deal_duration = keys.Duration + earthlevel*keys.EarthMultiple

	-- Solves for the target's distance from the border of the field (negative is inside, positive is outside)
	local distance = (target:GetAbsOrigin() - ability.center):Length2D()
	local distance_from_border = distance - radius
	-- The target's angle in the world
	local target_angle = target:GetAnglesAsVector().y
	
	-- Solves for the target's angle in relation to the center of the circle in radians
	local origin_difference =  ability.center - target:GetAbsOrigin()
	local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)
	
	-- Converts the radians to degrees.
	origin_difference_radian = origin_difference_radian * 180
	local angle_from_center = origin_difference_radian / math.pi
	-- Makes angle "0 to 360 degrees" as opposed to "-180 to 180 degrees" aka standard dota angles.
	angle_from_center = angle_from_center + 180.0
	
	-- Checks if the target is inside the field, less than 20 units from the border, and facing it (within 90 degrees)
	if distance_from_border < 0 and math.abs(distance_from_border) <= 20 and (math.abs(target_angle - angle_from_center)<90 or math.abs(target_angle - angle_from_center)>270) then
		-- Removes the movespeed minimum
		if target:HasModifier("modifier_movespeed_cap_low") == false then
			target:AddNewModifier(caster, nil, "modifier_movespeed_cap_low", {duration = deal_duration})
		end
		-- Slows the target to 0.1 movespeed (equivalent to an invisible wall)
		ability:ApplyDataDrivenModifier(caster, target, "modifier_kinetic_field_debuff",{})
	-- Checks if the target is outside the field, less than 30 units from the border, and facing it (within 90 degrees)
	elseif distance_from_border > 0 and math.abs(distance_from_border) <= 30 and (math.abs(target_angle - angle_from_center)>90) then
		-- Removes the movespeed minimum
		if target:HasModifier("modifier_movespeed_cap_low") == false then
			target:AddNewModifier(caster, nil, "modifier_movespeed_cap_low", {duration = deal_duration})
		end
		-- Slows the target to 0.1 movespeed (equivalent to an invisible wall)
		ability:ApplyDataDrivenModifier(caster, target, "modifier_kinetic_field_debuff",{})
	else
		-- Removes the slowing debuffs, so the unit can move freely
		if target:HasModifier("modifier_kinetic_field_debuff") then
			target:RemoveModifierByName("modifier_kinetic_field_debuff")
			target:RemoveModifierByName("modifier_movespeed_cap_low")
		end
	end

end

--[[Author: YOLOSPAGHETTI
	Date: March 30, 2016
	Ensures no units still have the slow modifiers after the field is gone]]
function RemoveModifiers(keys)
	local target = keys.target
	target:RemoveModifierByName("modifier_kinetic_field_debuff")
	target:RemoveModifierByName("modifier_movespeed_cap_low")
end

function OnPatchouliFireFire(keys)
	local caster=keys.caster
	local firelevel
	local CasterName = caster:GetClassname()
	if CasterName ~= "npc_dota_hero_invoker" then
		if caster:GetLevel()>=13 then 
			firelevel =7
		else
			firelevel =math.floor((caster:GetLevel()+1)/2)
		end
	else
		local abilityfire=caster:FindAbilityByName("ability_thdots_patchouli_fire")
		firelevel=abilityfire:GetLevel()
	end
	local count =1
	if caster.ability_patchouli_fire_unit == nil then
		caster.ability_patchouli_fire_unit = {}
	end
	if firelevel >4 then 
		count = 2
	end
	for i=1,count do
		local unit = CreateUnitByName(
			"npc_thdots_unit_patchouli_fire_fire"
			,caster:GetOrigin() + ( caster:GetForwardVector() + Vector(math.cos((i-1.5)*math.pi/3),math.sin((i-1.5)*math.pi/3),0) ) * 100
			,false
			,caster
			,caster
			,caster:GetTeam()
		)

		if unit == nil then return end
		keys.ability:ApplyDataDrivenModifier(caster, unit, "modifier_thdots_patchouli_fire_fire",{duration=keys.Duration})
		unit:CreatureLevelUp(1)
		unit:SetControllableByPlayer(caster:GetPlayerOwnerID(), true) 
		SetTargetToTraversable(unit)
		unit:SetBaseDamageMin(30+keys.BonusDamage*firelevel) 
		unit:SetBaseDamageMax(30+keys.BonusDamage*firelevel)
		unit:SetBaseMaxHealth(400+keys.BonusHealth*firelevel)
		local UnitAbility = unit:FindAbilityByName("ability_thdots_patchouli_fire_fire_unit")
		UnitAbility:SetLevel(1)
		local oldSwpanUnit = caster.ability_patchouli_fire_unit[i]
		if oldSwpanUnit ~=nil and oldSwpanUnit:IsNull() == false then 
			oldSwpanUnit:ForceKill(false)
		end
		caster.ability_patchouli_fire_unit[i] = unit
	end
end

function OnDestroyPatchouliFireFire(keys)
	local caster=keys.caster
	local target=keys.target
	if target ~=nil and target:IsNull() == false then
		target:ForceKill(false)
	end
end

function OnPatchouliFireFireUnit(keys)
	if keys.unit:IsBuilding()==false then return end
	local caster = EntIndexToHScript(keys.caster_entindex)	
	if(caster.firelock == nil)then
		caster.firelock = false
	end

	if(caster.firelock == true)then
		return
	end
	caster.firelock = true
	local damage_table = {
		ability = keys.ability,
		victim = keys.unit,
		attacker = caster,
		damage = keys.DealDamage * keys.ExDamage * 0.01,
		damage_type = keys.ability:GetAbilityDamageType(), 
		damage_flags = keys.ability:GetAbilityTargetFlags()
	}
	UnitDamageTarget(damage_table)
	caster.firelock = false
end



function OnPatchouliWaterMetal(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local waterlevel
	local metallevel
	local CasterName = caster:GetClassname()
	if CasterName ~= "npc_dota_hero_invoker" then
		if caster:GetLevel()>=13 then 
			waterlevel =7
			metallevel =7
		else
			waterlevel =math.floor((caster:GetLevel()+1)/2)
			metallevel =math.floor((caster:GetLevel()+1)/2)
		end
	else
		local abilitywater=caster:FindAbilityByName("ability_thdots_patchouli_water")
		local abilitymetal=caster:FindAbilityByName("ability_thdots_patchouli_metal")
		waterlevel=abilitywater:GetLevel()
		metallevel=abilitymetal:GetLevel()
	end

	local deal_damage=keys.Damage + metallevel*keys.MetalMultiple

	deal_resistance=keys.ReduceResistance + keys.WaterMultiple*waterlevel
	local effectIndex = ParticleManager:CreateParticle("particles/heroes/patchouli/patchouli_water_metal.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(effectIndex, 0, keys.target_points[1])
	ParticleManager:SetParticleControl(effectIndex, 2,  Vector(keys.Duration-1,0,1))

	local time = 0
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("OnPatchouliWaterMetal"), 
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			if time < keys.Duration then 
				time = time + 0.5
			else				
				return nil
			end		
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
				local damage_table = {
					ability = keys.ability,
					victim = v,
					attacker = caster,
					damage = deal_damage/2,
					damage_type = keys.ability:GetAbilityDamageType(), 
					damage_flags = 0
				}
				
				if v:HasModifier("modifier_patchouli_water_metal_debuff")==false then
					v:SetBaseMagicalResistanceValue(v:GetBaseMagicalResistanceValue()-deal_resistance)
					keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_patchouli_water_metal_debuff",{duration=1.0})
				elseif v:HasModifier("modifier_patchouli_water_metal_debuff") then
					keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_patchouli_water_metal_debuff",{duration=1.0})
				end
				UnitDamageTarget(damage_table)				
			end
			return 0.5
		end,
	0)	
end

function OnPatchouliWaterMetalEnd(keys)
	local target=keys.target
	target:SetBaseMagicalResistanceValue(target:GetBaseMagicalResistanceValue()+deal_resistance)
end

function OnPatchouliWaterWood(keys)
	local caster = keys.caster
	local target = keys.target
	local waterlevel
	local woodlevel
	local CasterName = caster:GetClassname()
	if CasterName ~= "npc_dota_hero_invoker" then
		if caster:GetLevel()>=13 then 
			waterlevel =7
			woodlevel =7
		else
			waterlevel =math.floor((caster:GetLevel()+1)/2)
			woodlevel =math.floor((caster:GetLevel()+1)/2)
		end
	else
		local abilitywater=caster:FindAbilityByName("ability_thdots_patchouli_water")
		waterlevel=abilitywater:GetLevel()
		local abilitywood=caster:FindAbilityByName("ability_thdots_patchouli_wood")
		woodlevel=abilitywood:GetLevel()
	end
	local deal_hp=keys.BaseHealth + woodlevel*keys.ExHealth
	local deal_mana=keys.BaseMana + waterlevel*keys.ExMana
	target:Heal(deal_hp,caster)
	target:GiveMana(deal_mana)
end

function OnPatchouliWaterEarthKnockback(keys, target, vecDirection)
	local Ability=keys.ability
	local Caster=keys.caster
	local earthlevel
	local CasterName = Caster:GetClassname()
	if CasterName ~= "npc_dota_hero_invoker" then
		if Caster:GetLevel()>=13 then 
			earthlevel =7
		else
			earthlevel =math.floor((Caster:GetLevel()+1)/2)
		end
	else
		local abilityearth=Caster:FindAbilityByName("ability_thdots_patchouli_earth")
		earthlevel=abilityearth:GetLevel()
	end
	local tick_interval=keys.tick_interval
	local duration=(keys.knockback_distance+keys.ExDistance*earthlevel)/keys.knockback_speed
	local move_per_tick=keys.knockback_speed*tick_interval
	local max_tick=(keys.knockback_distance+keys.ExDistance*earthlevel)/move_per_tick
	local tick=0
	local new_pos=target:GetOrigin()

	local OnThinkEnd=function ()
		FindClearSpaceForUnit(target, new_pos, false)
	end

	Ability:ApplyDataDrivenModifier(Caster, target, keys.knockback_debuff_name, {duration=duration})
	target:SetContextThink(
		"knockback",
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			if Ability:IsNull() then 
				OnThinkEnd()
				return nil
			end
			new_pos=target:GetOrigin()+move_per_tick*vecDirection
			GridNav:DestroyTreesAroundPoint(new_pos, 25, true)
			tick=tick+1
			if tick>=max_tick or not target:HasModifier(keys.knockback_debuff_name) then 
				OnThinkEnd()
				return nil 
			end
			target:SetOrigin(new_pos)
			return tick_interval
		end,0)
end

function OnPatchouliWaterEarth(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	local waterlevel
	local CasterName = Caster:GetClassname()
	if CasterName ~= "npc_dota_hero_invoker" then
		if Caster:GetLevel()>=13 then 
			waterlevel =7
		else
			waterlevel =math.floor((Caster:GetLevel()+1)/2)
		end
	else
		local abilitywater=Caster:FindAbilityByName("ability_thdots_patchouli_water")
		waterlevel=abilitywater:GetLevel()
	end
	local damage=keys.BasicDamage+waterlevel*keys.ExDamage
	local VecStart=Caster:GetOrigin()
	local Target=keys.target_points[1]
	if Caster:HasModifier("modifier_item_wanbaochui")==false then

		local TargetPoint=keys.target_points[1]
		local Direction=(TargetPoint-VecStart):Normalized()
		local TickInterval=keys.tick_interval
		local MovePerTick=keys.speed*TickInterval
		local tick=0
		local tick_max=(keys.range+keys.ExRange*waterlevel)/MovePerTick
		local pointRad = GetRadBetweenTwoVec2D(Caster:GetOrigin(),TargetPoint)
		local forwardVec = Vector( math.cos(pointRad) * keys.speed , math.sin(pointRad) * keys.speed , 0 )

		local projectileTable = {
			Ability				= keys.ability,
			EffectName			= "particles/units/heroes/hero_invoker/invoker_deafening_blast.vpcf",
			vSpawnOrigin		= Caster:GetOrigin() + Vector(0,0,128),
			fDistance			= keys.range+keys.ExRange*waterlevel,
			fStartRadius		= 120,
			fEndRadius			= 120,
			Source				= Caster,
			bHasFrontalCone		= false,
			bReplaceExisting	= false,
			iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
			iUnitTargetType		= DOTA_UNIT_TARGET_FLAG_NONE,
			fExpireTime			= GameRules:GetGameTime() + 10.0,
			bDeleteOnHit		= false,
			vVelocity			= forwardVec,
			bProvidesVision		= true,
			iVisionRadius		= 400,
			iVisionTeamNumber	= Caster:GetTeamNumber(),
			iSourceAttachment 	= PATTACH_CUSTOMORIGIN
		} 

		local projectileID = ProjectileManager:CreateLinearProjectile(projectileTable)

		local OnThinkEnd=function ()	
			ProjectileManager:DestroyLinearProjectile(projectileID)
		end

		Caster:SetContextThink(
			"water_earth_main_loop",
			function () 
				if GameRules:IsGamePaused() then return 0.03 end
				if Ability:IsNull() then 
					OnThinkEnd()
					return nil
				end

				local moved_distance=tick*MovePerTick
				local VecPos=VecStart+Direction*MovePerTick*tick
				local enemies = FindUnitsInRadius(
							Caster:GetTeamNumber(),
							VecPos,
							nil,
							keys.hitbox_radius,
							Ability:GetAbilityTargetTeam(),
							Ability:GetAbilityTargetType(),
							Ability:GetAbilityTargetFlags(),
							FIND_CLOSEST,
							false)

				for _,v in pairs(enemies) do
					if v:HasModifier("modifier_thdots_patchouli_water_earth_lock")==false then 
						local damage_table = {
							ability = keys.ability,
							victim = v,
							attacker = Caster,
							damage =  damage,
							damage_type = keys.ability:GetAbilityDamageType(), 
							damage_flags = 0
						}								
						UnitDamageTarget(damage_table)
						OnPatchouliWaterEarthKnockback(keys,v,Direction)
						Ability:ApplyDataDrivenModifier(Caster, v, "modifier_thdots_patchouli_water_earth_lock", {duration=(keys.range+keys.ExRange*waterlevel)/keys.speed})
					end
				end

				tick=tick+1
				if tick>=tick_max then 
					OnThinkEnd()
					return nil 
				end
				return TickInterval
			end,0)
	else

		local newdamage=damage*1.5
		local i=0
		while (i<13) do

			local angel=math.pi*i/6
			
			local TargetPoint=Vector(VecStart.x+400*math.sin(angel),VecStart.y+400*math.cos(angel),VecStart.z)
			local Direction=(TargetPoint-VecStart):Normalized()
			local TickInterval=keys.tick_interval
			local MovePerTick=keys.speed*TickInterval
			local tick=0
			local tick_max=(keys.range+keys.ExRange*waterlevel)/MovePerTick

			local pointRad = GetRadBetweenTwoVec2D(Caster:GetOrigin(),TargetPoint)
			local forwardVec = Vector( math.cos(pointRad) * keys.speed , math.sin(pointRad) * keys.speed , 0 )

			local projectileTable = {
				Ability				= keys.ability,
				EffectName			= "particles/units/heroes/hero_invoker/invoker_deafening_blast.vpcf",
				vSpawnOrigin		= Caster:GetOrigin() + Vector(0,0,128),
				fDistance			= keys.range+keys.ExRange*waterlevel,
				fStartRadius		= 120,
				fEndRadius			= 120,
				Source				= Caster,
				bHasFrontalCone		= false,
				bReplaceExisting	= false,
				iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
				iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
				iUnitTargetType		= DOTA_UNIT_TARGET_FLAG_NONE,
				fExpireTime			= GameRules:GetGameTime() + 10.0,
				bDeleteOnHit		= false,
				vVelocity			= forwardVec,
				bProvidesVision		= true,
				iVisionRadius		= 400,
				iVisionTeamNumber	= Caster:GetTeamNumber(),
				iSourceAttachment 	= PATTACH_CUSTOMORIGIN
			} 

			local projectileID = ProjectileManager:CreateLinearProjectile(projectileTable)

			local OnThinkEnd=function ()	
				ProjectileManager:DestroyLinearProjectile(projectileID)
			end

			Caster:SetContextThink(DoUniqueString("water_earth_main_loop"),
				function () 
					if GameRules:IsGamePaused() then return 0.03 end
					if Ability:IsNull() then 
						OnThinkEnd()
						return nil
					end

					local moved_distance=tick*MovePerTick
					local VecPos=VecStart+Direction*MovePerTick*tick
					local enemies = FindUnitsInRadius(
								Caster:GetTeamNumber(),
								VecPos,
								nil,
								keys.hitbox_radius,
								Ability:GetAbilityTargetTeam(),
								Ability:GetAbilityTargetType(),
								Ability:GetAbilityTargetFlags(),
								FIND_CLOSEST,
								false)

					for _,v in pairs(enemies) do
						if v:HasModifier("modifier_thdots_patchouli_water_earth_lock")==false then 
							local damage_table = {
								ability = keys.ability,
								victim = v,
								attacker = Caster,
								damage =  newdamage,
								damage_type = keys.ability:GetAbilityDamageType(), 
								damage_flags = 0
							}								
							UnitDamageTarget(damage_table)
							local UniqueDirection = (v:GetOrigin()-Caster:GetOrigin()):Normalized()
							OnPatchouliWaterEarthKnockback(keys,v,UniqueDirection)
							Ability:ApplyDataDrivenModifier(Caster, v, "modifier_thdots_patchouli_water_earth_lock", {duration=(keys.range+keys.ExRange*waterlevel)/keys.speed})
						end
					end

					tick=tick+1
					if tick>=tick_max then 
						OnThinkEnd()
						return nil 
					end
					return TickInterval
				end,0)
			i=i+1
			
		end
		
	end
end

function OnPatchouliWaterWater(keys)
	local caster = keys.caster
	local duration = keys.Duration
	local waterlevel
	local CasterName = caster:GetClassname()
	if CasterName ~= "npc_dota_hero_invoker" then
		if caster:GetLevel()>=13 then 
			waterlevel =7
		else
			waterlevel =math.floor((caster:GetLevel()+1)/2)
		end
	else
		local abilitywater=caster:FindAbilityByName("ability_thdots_patchouli_water")
		waterlevel=abilitywater:GetLevel()
	end
	local deal_duration = keys.Duration + waterlevel*keys.ExDuration
	local water_water_effectIndex = ParticleManager:CreateParticle("particles/heroes/patchouli/patchouli_water_water.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(water_water_effectIndex, 0, keys.target_points[1])

	local time = 0
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("OnPatchouliWaterWater"), 
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			if time < deal_duration then 
				time = time + 0.1
			else
				ParticleManager:DestroyParticleSystem(water_water_effectIndex,true)			
				return nil
			end		
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
				keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_patchouli_water_water_debuff",{duration=0.1})
				keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_patchouli_water_water_debuff_01",{duration=0.1})
				keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_patchouli_water_water_debuff_02",{duration=0.1})	
				v:SetModifierStackCount("modifier_patchouli_water_water_debuff_02", keys.ability, waterlevel)
			end
			return 0.1
		end,
	0)
end

function OnPatchouliWoodMetal(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	local woodlevel
	local metallevel
	local CasterName = Caster:GetClassname()
	if CasterName ~= "npc_dota_hero_invoker" then
		if Caster:GetLevel()>=13 then 
			woodlevel =7
			metallevel =7
		else
			woodlevel =math.floor((Caster:GetLevel()+1)/2)
			metallevel =math.floor((Caster:GetLevel()+1)/2)
		end
	else
		local abilitywood=Caster:FindAbilityByName("ability_thdots_patchouli_wood")
		woodlevel=abilitywood:GetLevel()
		local abilitymetal=Caster:FindAbilityByName("ability_thdots_patchouli_metal")
		metallevel=abilitymetal:GetLevel()
	end
	local TargetPoint=keys.target_points[1]
	local VecStart=Caster:GetOrigin()
	local Direction=(TargetPoint-VecStart):Normalized()
	local TickInterval=keys.tick_interval
	local MovePerTick=keys.speed*TickInterval
	local tick=0
	local tick_max=keys.range/MovePerTick
	local tree=0
	local pointRad = GetRadBetweenTwoVec2D(Caster:GetOrigin(),TargetPoint)
	local forwardVec = Vector( math.cos(pointRad) * keys.speed , math.sin(pointRad) * keys.speed , 0 )
	local deal_damage = keys.Damage+keys.ExDamage*metallevel
	local deal_heal = deal_damage*keys.HealRate*woodlevel*0.01
	Caster:EmitSound("Hero_Shredder.Chakram.Target")
	local projectileTable = {
		Ability				= keys.ability,
		EffectName			= "particles/units/heroes/hero_shredder/shredder_chakram.vpcf",
		vSpawnOrigin		= Caster:GetOrigin() + Vector(0,0,128),
		fDistance			= keys.range,
		fStartRadius		= 80,
		fEndRadius			= 80,
		Source				= Caster,
		bHasFrontalCone		= false,
		bReplaceExisting	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType		= DOTA_UNIT_TARGET_FLAG_NONE,
		fExpireTime			= GameRules:GetGameTime() + 10.0,
		bDeleteOnHit		= false,
		vVelocity			= forwardVec,
		bProvidesVision		= true,
		iVisionRadius		= 400,
		iVisionTeamNumber	= Caster:GetTeamNumber(),
		iSourceAttachment 	= PATTACH_CUSTOMORIGIN
	} 

	local projectileID = ProjectileManager:CreateLinearProjectile(projectileTable)

	local OnThinkEnd=function ()	
		ProjectileManager:DestroyLinearProjectile(projectileID)
		Caster:EmitSound("Hero_Shredder.TimberChain.Retract")
	end

	Caster:SetContextThink(
		"wood_metal_main_loop",
		function () 
			if GameRules:IsGamePaused() then return 0.03 end
			if Ability:IsNull() then 
				OnThinkEnd()
				return nil
			end

			local moved_distance=tick*MovePerTick
			local VecPos=VecStart+Direction*MovePerTick*tick

			local enemies = FindUnitsInRadius(
						Caster:GetTeamNumber(),
						VecPos,
						nil,
						keys.hitbox_radius,
						Ability:GetAbilityTargetTeam(),
						Ability:GetAbilityTargetType(),
						Ability:GetAbilityTargetFlags(),
						FIND_CLOSEST,
						false)
			if GridNav:IsNearbyTree(VecPos,80, false) then
				GridNav:DestroyTreesAroundPoint(VecPos, 80, true)
				tree = 1
			end
			if #enemies>0 then
				local Target=enemies[1]
				UnitDamageTarget{
					victim=Target, 
					attacker=Caster, 
					ability=Ability, 
					damage=deal_damage,
					damage_type=Ability:GetAbilityDamageType(),
				}
				
				Caster:Heal( deal_heal, Caster) 
				SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,Caster, deal_heal,nil)

				OnThinkEnd()
				return nil
			end
			if tree ==1 then
				Caster:Heal( deal_heal, Caster) 
				SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,Caster, deal_heal,nil)
				OnThinkEnd()
				return nil
			end


			tick=tick+1
			if tick>=tick_max then 
				OnThinkEnd()
				return nil 
			end
			return TickInterval
		end,0)
end

function OnPatchouliWoodEarth(keys)
	if is_spell_blocked(keys.target) then return end
	local caster=keys.caster
	local target=keys.target
	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_invoker_3"))
	local Vec = target:GetOrigin()
	
	local woodlevel
	local earthlevel
	local CasterName = caster:GetClassname()
	if CasterName ~= "npc_dota_hero_invoker" then
		if caster:GetLevel()>=13 then 
			woodlevel =7
			earthlevel =7
		else
			woodlevel =math.floor((caster:GetLevel()+1)/2)
			earthlevel =math.floor((caster:GetLevel()+1)/2)
		end
	else
		local abilitywood=caster:FindAbilityByName("ability_thdots_patchouli_wood")
		woodlevel=abilitywood:GetLevel()
		local abilityearth=caster:FindAbilityByName("ability_thdots_patchouli_earth")
		earthlevel=abilityearth:GetLevel()
	end
	local Duration = keys.Duration+earthlevel*keys.ExDuration
	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_patchouli_wood_earth_root",{duration=Duration})
	wood_earth_effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_treant/treant_overgrowth_vines.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(wood_earth_effectIndex, 0, Vec)
	local time = 0
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("OnPatchouliWoodEarth"), 
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			if time < Duration then 
				time = time + 0.5
			else
				ParticleManager:DestroyParticleSystem(wood_earth_effectIndex,false)		
				return nil
			end
			return 0.5
		end,
	0)
end

function OnPatchouliWoodEarthThink(keys)	
	local caster = keys.caster
	local target = keys.target
	local woodlevel
	local CasterName = caster:GetClassname()
	if CasterName ~= "npc_dota_hero_invoker" then
		if caster:GetLevel()>=13 then 
			woodlevel =7			
		else
			woodlevel =math.floor((caster:GetLevel()+1)/2)			
		end
	else
		local abilitywood=caster:FindAbilityByName("ability_thdots_patchouli_wood")
		woodlevel=abilitywood:GetLevel()		
	end
	local deal_damage = woodlevel*keys.ExDamage+keys.Damage
	local damage_table = {
						ability = keys.ability,
						victim = target,
						attacker = caster,
						damage = deal_damage/2,
						damage_type = keys.ability:GetAbilityDamageType(), 
						damage_flags = 0
					}								
	UnitDamageTarget(damage_table)
end

function OnPatchouliMetalEarth(keys)
	print("earth")
	local Ability=keys.ability
	local Caster=keys.caster
	local metallevel
	local earthlevel
	local CasterName = Caster:GetClassname()
	if CasterName ~= "npc_dota_hero_invoker" then
		if Caster:GetLevel()>=13 then 
			metallevel =7
			earthlevel =7
		else
			metallevel =math.floor((Caster:GetLevel()+1)/2)
			earthlevel =math.floor((Caster:GetLevel()+1)/2)
		end
	else
		local abilitymetal=Caster:FindAbilityByName("ability_thdots_patchouli_metal")
		metallevel=abilitymetal:GetLevel()
		local abilityearth=Caster:FindAbilityByName("ability_thdots_patchouli_earth")
		earthlevel=abilityearth:GetLevel()
	end
	local TargetPoint=keys.target_points[1]
	local VecStart=Caster:GetOrigin()
	local Direction=(TargetPoint-VecStart):Normalized()
	local TickInterval=keys.tick_interval
	local MovePerTick=keys.speed*TickInterval
	local tick=0
	local tick_max=(keys.range+keys.ExRange*earthlevel)/MovePerTick
	local deal_damage=keys.Damage+metallevel*keys.ExDamage+FindTelentValue(Caster,"special_bonus_unique_invoker_9")

	local pointRad = GetRadBetweenTwoVec2D(Caster:GetOrigin(),TargetPoint)
	local forwardVec = Vector( math.cos(pointRad) * keys.speed , math.sin(pointRad) * keys.speed , 0 )
	
	local projectileTable = {
		Ability				= keys.ability,
		EffectName			= "particles/heroes/patchouli/metal_earth.vpcf",
		-- EffectName			= "particles/units/heroes/hero_invoker/invoker_chaos_meteor.vpcf",
		vSpawnOrigin		= TargetPoint,
		fDistance			= keys.range+keys.ExRange*earthlevel,
		fStartRadius		= 120,
		fEndRadius			= 120,
		Source				= Caster,
		bHasFrontalCone		= false,
		bReplaceExisting	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType		= DOTA_UNIT_TARGET_FLAG_NONE,
		fExpireTime			= GameRules:GetGameTime() + 10.0,
		bDeleteOnHit		= false,
		vVelocity			= forwardVec,
		bProvidesVision		= true,
		iVisionRadius		= 400,
		iVisionTeamNumber	= Caster:GetTeamNumber(),
		iSourceAttachment 	= PATTACH_CUSTOMORIGIN
	} 

	local projectileID = ProjectileManager:CreateLinearProjectile(projectileTable)

	local OnThinkEnd=function ()	
		ProjectileManager:DestroyLinearProjectile(projectileID)
		StartSoundEventFromPosition("Hero_Invoker.ChaosMeteor.Destroy", TargetPoint)
	end
	StartSoundEventFromPosition("Hero_Invoker.ChaosMeteor.Impact", TargetPoint)
	Caster:SetContextThink(
		"metal_earth_main_loop",
		function () 
			if GameRules:IsGamePaused() then return 0.03 end
			if Ability:IsNull() then 
				OnThinkEnd()
				return nil
			end

			local moved_distance=tick*MovePerTick
			local VecPos=TargetPoint+Direction*MovePerTick*tick
			local enemies = FindUnitsInRadius(
						Caster:GetTeamNumber(),
						VecPos,
						nil,
						keys.hitbox_radius,
						Ability:GetAbilityTargetTeam(),
						Ability:GetAbilityTargetType(),
						Ability:GetAbilityTargetFlags(),
						FIND_CLOSEST,
						false)

			for _,v in pairs(enemies) do
				if v:HasModifier("modifier_thdots_patchouli_metal_earth_lock")==false then 
					local damage_table = {
						ability = keys.ability,
						victim = v,
						attacker = Caster,
						damage = deal_damage/2,
						damage_type = keys.ability:GetAbilityDamageType(), 
						damage_flags = 0
					}								
					UnitDamageTarget(damage_table)

					
					Ability:ApplyDataDrivenModifier(Caster, v, "modifier_thdots_patchouli_metal_earth_lock", {duration=0.5})
				end

				local unit_location = v:GetAbsOrigin()
				
				local vector_distance = VecPos - unit_location

				local direction = (vector_distance):Normalized()
				FindClearSpaceForUnit(v, unit_location + direction*5, true)
						
			end

			tick=tick+1
			if tick>=tick_max then 
				OnThinkEnd()
				return nil 
			end
			return TickInterval
		end,0)
end

function OnPatchouliWoodWood(keys)
	local caster = keys.caster
	local target = keys.target
	local woodlevel
	local CasterName = caster:GetClassname()
	if CasterName ~= "npc_dota_hero_invoker" then
		if caster:GetLevel()>=13 then 
			woodlevel =7
		else
			woodlevel =math.floor((caster:GetLevel()+1)/2)
		end
	else
		local abilitywood=caster:FindAbilityByName("ability_thdots_patchouli_wood")
		woodlevel=abilitywood:GetLevel()
	end
	local deal_duration = keys.Duration+woodlevel*keys.ExDuration
	--print("deal_duration",deal_duration)

	
	local time = 0
	target:SetContextThink(
		"wood_wood_main_loop",
		function () 
			if GameRules:IsGamePaused() then return 0.03 end
			if time < deal_duration then				
				keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_thdots_patchouli_wood_wood_effect", {duration=deal_duration})
			else				
				return nil
			end
			time = time + deal_duration
			--print("time",time)
			return deal_duration
		end,0)
end

function OnPatchouliEarthEarth(keys)
	local caster = keys.caster
	local earthlevel
	local CasterName = caster:GetClassname()
	if CasterName ~= "npc_dota_hero_invoker" then
		if caster:GetLevel()>=13 then 
			earthlevel =7
		else
			earthlevel =math.floor((caster:GetLevel()+1)/2)
		end
	else
		local abilityearth=caster:FindAbilityByName("ability_thdots_patchouli_earth")
		earthlevel=abilityearth:GetLevel()
	end

	local deal_damage=keys.Damage + earthlevel*keys.ExDamage
	local deal_duration=keys.Duration + keys.ExDuration*earthlevel

	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("OnPatchouliEarthEarth"), 
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			
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
				local damage_table = {
						ability = keys.ability,
					    victim = v,
					    attacker = caster,
					    damage = deal_damage,
					    damage_type = keys.ability:GetAbilityDamageType(), 
			    	    damage_flags = 0
				}
				
				UnitDamageTarget(damage_table)
				UtilStun:UnitStunTarget(caster,v,deal_duration)
			end
			
			return nil
		end,
	keys.DelayTime)	
end

function MetalMetalOnCreated( keys )
	local caster = keys.caster
	local target = keys.target
	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_willow/dark_willow_wisp_spell_fear_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:DestroyParticleSystemTime(effectIndex,FindValueTHD("duration",ability))
end

function OnPatchouliMetalMetal(keys)
	if is_spell_blocked(keys.target) then return end
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local metallevel
	local CasterName = caster:GetClassname()
	if CasterName ~= "npc_dota_hero_invoker" then
		if caster:GetLevel()>=13 then 
			metallevel =7
		else
			metallevel =math.floor((caster:GetLevel()+1)/2)
		end
	else
		local abilitymetal=caster:FindAbilityByName("ability_thdots_patchouli_metal")
		metallevel=abilitymetal:GetLevel()
	end
	local movement_damage_pct = keys.movement_damage_pct
	local damage_cap_amount = 1300
	local position = target:GetAbsOrigin()
	if target:HasModifier("modifier_patchouli_metal_metal_debuff")==false then 
		move_count=0 
		ability.origin = position
	end
	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_patchouli_metal_metal_debuff", {})
	if ability.origin ~= null then
		local distance = math.sqrt((ability.origin.x - position.x)^2 + (ability.origin.y - position.y)^2)
		if distance <= damage_cap_amount and distance > 0 then
			damage = distance * (movement_damage_pct+keys.ExDamage*metallevel)/100
			local damage_table = {
				ability = keys.ability,
				victim = target,
				attacker = caster,
				damage = damage,
				damage_type = keys.ability:GetAbilityDamageType(), 
				damage_flags = 0
			}				
			UnitDamageTarget(damage_table)
			target:EmitSound("Voice_Thdots_Patchouli.AbilityMetalMetal")
			move_count=move_count+metallevel
			
			target:SetModifierStackCount("modifier_patchouli_metal_metal_debuff", keys.ability, move_count)
		end
	end
	ability.origin = position
end

function OnPatchouliXianzhezhishi(keys)
	local caster = keys.caster
	local CasterName = caster:GetClassname()
	if CasterName ~= "npc_dota_hero_invoker" then return end
	local ability_xianzhezhishi=caster:FindAbilityByName("ability_thdots_patchouli_xianzhezhishi")

	if caster:HasModifier("modifier_thdots_patchouli_xianzhezhishi_add")==false then stone_count = 0 end
	stone_count = stone_count + 1
	if FindTelentValue(caster,"special_bonus_unique_invoker_6") == 1 then
		ability_xianzhezhishi:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_patchouli_xianzhezhishi_add", {Duration = 4.5})
	else
		ability_xianzhezhishi:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_patchouli_xianzhezhishi_add", {Duration = 3.0})
	end
	caster:SetModifierStackCount("modifier_thdots_patchouli_xianzhezhishi_add", ability_xianzhezhishi, stone_count)
	if stone_count == 5 then
		stone_count = 0
		caster:RemoveModifierByName("modifier_thdots_patchouli_xianzhezhishi_royal_flame")
		caster:RemoveModifierByName("modifier_thdots_patchouli_xianzhezhishi_moon_divinity")
		if FindTelentValue(caster,"special_bonus_unique_invoker_8") == 1 then			
			ability_xianzhezhishi:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_patchouli_xianzhezhishi_royal_flame", {Duration = 2.0})
			ability_xianzhezhishi:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_patchouli_xianzhezhishi_moon_divinity", {Duration = 10.0})
			local time = 0
			GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("OnPatchouliExSunAndMoon"), 
			function ()
				if GameRules:IsGamePaused() then return 0.03 end
				if time == 0 then
					caster:EmitSound("Voice_Thdots_Patchouli.AbilityExSun")
				elseif time > 2.5 then
					caster:EmitSound("Voice_Thdots_Patchouli.AbilityExMoon")
					return nil
				end
				time = time + 0.03
				return 0.03
			end,0)
		else
			if GameRules:IsDaytime() then
				ability_xianzhezhishi:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_patchouli_xianzhezhishi_royal_flame", {Duration = 2.0})
				caster:EmitSound("Voice_Thdots_Patchouli.AbilityExSun")
			else
				ability_xianzhezhishi:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_patchouli_xianzhezhishi_moon_divinity", {Duration = 10.0})
				caster:EmitSound("Voice_Thdots_Patchouli.AbilityExMoon")
			end
		end
		caster:RemoveModifierByName("modifier_thdots_patchouli_xianzhezhishi_add")
	end
end

function OnPatchouliSunMoon(keys)
	local ability = keys.ability
	local caster = keys.caster
	if FindTelentValue(caster,"special_bonus_unique_invoker_7") == 1 then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_patchouli_xianzhezhishi_sun", {duration = -1})
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_patchouli_xianzhezhishi_moon", {duration = -1})
	else
		if GameRules:IsDaytime() then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_patchouli_xianzhezhishi_sun", {duration = -1})
			if caster:HasModifier("modifier_thdots_patchouli_xianzhezhishi_moon") then 
				caster:RemoveModifierByName("modifier_thdots_patchouli_xianzhezhishi_moon")
			end
		else 
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_patchouli_xianzhezhishi_moon", {duration = -1})
			if caster:HasModifier("modifier_thdots_patchouli_xianzhezhishi_sun") then 
				caster:RemoveModifierByName("modifier_thdots_patchouli_xianzhezhishi_sun")
			end
		end
	end
end

function OnPatchouliRoyalFlame(keys)
	local caster=keys.caster
	local vec_caster=caster:GetOrigin()
	local effectIndex1 = ParticleManager:CreateParticle("particles/econ/items/monkey_king/arcana/fire/mk_arcana_fire_spring_ring_radial.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(effectIndex1 , 0, caster, 5, "attach_hitloc", Vector(0,0,0), true)
	local targets = FindUnitsInRadius(
		   		caster:GetTeam(),		--caster team
		  		vec_caster,		--find position
		   		nil,					--find entity
		   		800,		--find radius
		   		DOTA_UNIT_TARGET_TEAM_ENEMY,
		   		keys.ability:GetAbilityTargetType(),
		   		0, 
		   		FIND_CLOSEST,
		   		false
	    	)
	for _,v in pairs(targets) do
		local deal_damage=v:GetMaxHealth()*keys.Damage*0.01
		local damage_table = {
				ability = keys.ability,
			    victim = v,
			    attacker = caster,
			    damage = deal_damage,
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
		}
		UnitDamageTarget(damage_table)
		local effectIndex = ParticleManager:CreateParticle("particles/econ/items/invoker/invoker_apex/invoker_sun_strike_beam_immortal1.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(effectIndex, 0, v:GetOrigin())
		
		ParticleManager:DestroyParticleSystem(effectIndex,false)

		
	end
end

function OnPatchouliMoonDivinity(keys)
	local caster=keys.caster
	local vec_caster=caster:GetOrigin()
	local effectIndex1 = ParticleManager:CreateParticle("particles/units/heroes/hero_luna/luna_eclipse_cast_moonlight_glow03.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(effectIndex1 , 0, caster, 5, "attach_hitloc", Vector(0,0,0), true)
	
	local targets = FindUnitsInRadius(
		   		caster:GetTeam(),		--caster team
		  		vec_caster,		--find position
		   		nil,					--find entity
		   		1200,		--find radius
		   		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		   		keys.ability:GetAbilityTargetType(),
		   		0, 
		   		FIND_CLOSEST,
		   		false
	    	)
	for _,v in pairs(targets) do
		local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_mirana/mirana_moonlight_ray.vpcf", PATTACH_CUSTOMORIGIN, v)
		ParticleManager:SetParticleControl(effectIndex, 0, v:GetOrigin())
		local regen=caster:GetMaxMana()*0.1
		v:Heal(regen,caster)
		v:GiveMana(regen)
		
	end
	
end


function OnPatchouliMaxLevel(keys)
	local caster=keys.caster
	if caster.levelold==nil then caster.levelold=1 end
	if caster:GetAbilityPoints()~=0 then return end
	if caster:GetLevel()>=29 then
		caster:SetAbilityPoints(15)
	end
	if caster:GetLevel()%3==0 and caster:GetLevel()~=caster.levelold then
		caster:SetAbilityPoints(1)
		caster.levelold=caster:GetLevel()
	end	
end

