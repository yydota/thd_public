function OnMomiji01Spawn(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	if caster.ability_momiji01_Spawn_unit == nil then
		caster.ability_momiji01_Spawn_unit = {}
	end

	count = 2 + FindTelentValue(caster,"special_bonus_unique_bounty_hunter")
	if caster:HasModifier("modifier_item_wanbaochui") then
		count = count + 1
	end

	for i=1,count do
		local unit = CreateUnitByName(
			"ability_momiji_Spawn_unit"
			,caster:GetOrigin() + ( caster:GetForwardVector() + Vector(math.cos((i-1.5)*math.pi/3),math.sin((i-1.5)*math.pi/3),0) ) * 100
			,false
			,caster
			,caster
			,caster:GetTeam()
		)

		if unit == nil then return end

		unit:CreatureLevelUp(keys.ability:GetLevel())
		unit:SetControllableByPlayer(caster:GetPlayerOwnerID(), true) 
		if caster:HasModifier("modifier_item_wanbaochui") then
			keys.ability:ApplyDataDrivenModifier( caster, unit, "modifier_momiji_01_wanbaochui_buff", {} )
		end
		SetTargetToTraversable(unit)
		
		if FindTelentValue(caster,"special_bonus_unique_lycan_1") == 1 then 			
			
			unit:AddAbility("ability_system_criticalstrike_2")
			local ability = unit:FindAbilityByName("ability_system_criticalstrike_2")
			ability:SetLevel(1)			
		
			if not caster:HasAbility("ability_system_criticalstrike_2") then
				caster:RemoveAbility("ability_system_criticalstrike")
				caster:RemoveModifierByName("modifier_system_attack")
				caster:AddAbility("ability_system_criticalstrike_2")
				local ability = caster:FindAbilityByName("ability_system_criticalstrike_2")
				ability:SetLevel(1)
			end
		else
			unit:AddAbility("ability_system_criticalstrike")
			local ability = unit:FindAbilityByName("ability_system_criticalstrike")
			ability:SetLevel(1)
		end

		if FindTelentValue(caster,"special_bonus_unique_bounty_hunter_2") == 1 then 
			unit:AddAbility("ability_thdots_momiji_unit")
			unit:SetBaseMaxHealth(1800)
			ability = unit:FindAbilityByName("ability_thdots_momiji_unit")		
			ability:SetLevel(1)
		end

		if keys.ability:GetLevel() >=3 then
			unit:AddAbility("lycan_summon_wolves_invisibility")
			ability = unit:FindAbilityByName("lycan_summon_wolves_invisibility")
			ability:SetLevel(1)
		end

		local oldSwpanUnit = caster.ability_momiji01_Spawn_unit[i]
		if oldSwpanUnit ~=nil and oldSwpanUnit:IsNull() == false then 
			oldSwpanUnit:ForceKill(false)
		end
		caster.ability_momiji01_Spawn_unit[i] = unit

		unit:SetContextThink(
		"ability_momiji01_Spawn_unit_regen", 
			function ()
				if GameRules:IsGamePaused() then return 0.03 end
				if GetDistanceBetweenTwoVec2D(caster:GetOrigin(),unit:GetOrigin()) <= keys.AuraDistance then
					unit:Heal(keys.RegenAmount/5, caster)
					local abilityMomiji04Caster = caster:FindAbilityByName("ability_thdots_momiji04")
					if abilityMomiji04Caster ~= nil then
						local abilityMomiji04 = unit:FindAbilityByName("ability_thdots_momiji04")
						if abilityMomiji04==nil then
							unit:AddAbility("ability_thdots_momiji04")
							abilityMomiji04 = unit:FindAbilityByName("ability_thdots_momiji04")
							abilityMomiji04:SetLevel(abilityMomiji04Caster:GetLevel())
						elseif abilityMomiji04:GetLevel() ~= abilityMomiji04Caster:GetLevel() then
							abilityMomiji04:SetLevel(abilityMomiji04Caster:GetLevel())
						end
					end
				else
					local abilityMomiji04 = unit:FindAbilityByName("ability_thdots_momiji04")
					if abilityMomiji04 ~= nil then
						unit:RemoveAbility("ability_thdots_momiji04")
						unit:RemoveModifierByName("passive_momiji04_bonus")
					end
				end
				return 0.2
			end, 
		0.2)
	end
end

function OnMomiji02Start(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local Duration = keys.Duration
	AddFOWViewer( caster:GetTeam(), keys.target_points[1], keys.Radius, Duration, false)
	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_bounty_hunter_3"))
	
	local effectIndex = ParticleManager:CreateParticle("particles/econ/courier/courier_trail_05/courier_trail_05.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, keys.target_points[1])

	ParticleManager:DestroyParticleSystemTime(effectIndex,Duration)

	local unit = CreateUnitByName(
		"npc_vision_momiji_dummy_unit"
		,caster:GetOrigin()
		,false
		,caster
		,caster
		,caster:GetTeam()
	)

	unit:SetOrigin(keys.target_points[1])

	local abilityGEM = unit:FindAbilityByName("ability_thdots_momiji02_unit")
	if abilityGEM ~= nil then
		abilityGEM:SetLevel(keys.ability:GetLevel())
		unit:CastAbilityImmediately(abilityGEM, 0)
	end

	local ability_dummy_unit = unit:FindAbilityByName("ability_dummy_unit")
	ability_dummy_unit:SetLevel(1)

	unit:SetContextThink("ability_momiji_02_vision", 
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			unit:RemoveSelf()
		end, 
	Duration)

	--[[Timer.Loop 'ability_momiji02_vision' (1.0, 150,
			function (i)
				local targets = FindUnitsInRadius(
					   caster:GetTeam(),		--caster team
					   keys.target_points[1],		--find position
					   nil,							--find entity
					   keys.Radius,		--find radius
					   DOTA_UNIT_TARGET_TEAM_ENEMY,
					   keys.ability:GetAbilityTargetType(),
					   0, FIND_CLOSEST,
					   false
				    )
				for k,v in pairs(targets) do
					keys.ability:ApplyDataDrivenModifier( caster, v, "modifier_momiji02_antiinvisible", {Duration=1.0} )
				end
			end
	)]]--
end

function OnMomiji03Start(keys)
	if is_spell_blocked(keys.target) then return end
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	UtilStun:UnitStunTarget( caster,target,keys.Duration)
	
	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_storm_bolt_projectile_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin())
	ParticleManager:SetParticleControl(effectIndex, 1, target:GetOrigin())
	ParticleManager:SetParticleControl(effectIndex, 3, target:GetOrigin())

	local DamageTable = {
			victim = target, 
			attacker = caster, 
			ability = keys.ability,
			damage = keys.ability:GetAbilityDamage(), 
			damage_type = keys.ability:GetAbilityDamageType(), 
			damage_flags = keys.ability:GetAbilityTargetFlags()
	}
	 UnitDamageTarget(DamageTable)
end