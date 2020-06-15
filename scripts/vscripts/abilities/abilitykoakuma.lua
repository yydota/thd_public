function OnKoakuma01SpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if is_spell_blocked(keys.target) then return end
	local ability_level = ability:GetLevel() - 1
	local koakuma03
	local koakuma03_level
	local koakuma04
	local koakuma04_level
	-- Create the dummy unit which keeps track of bounces
	local dummy = CreateUnitByName( "npc_dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber() )
	dummy:AddAbility("ability_thdots_koakuma01_dummy")
	local dummy_ability =  dummy:FindAbilityByName("ability_thdots_koakuma01_dummy")
	dummy_ability:ApplyDataDrivenModifier( caster, dummy, "modifier_koakuma01_dummy_unit", {} )
	local Int = caster:GetIntellect()
	if caster:GetClassname()=="npc_dota_hero_lich" then		
		koakuma03 = caster:FindAbilityByName("ability_thdots_koakuma03")
		koakuma03_level = koakuma03:GetLevel() - 1
		koakuma04 = caster:FindAbilityByName("ability_thdots_koakuma04")
		koakuma04_level = koakuma04:GetLevel() - 1
	end
	local bonus_projectile_speed = 0
	if caster:HasModifier("modifier_thdots_koakuma03") then
		bonus_projectile_speed = koakuma03:GetLevelSpecialValueFor("bonus_projectile_speed", koakuma03_level)
		local reduction_cooldown = (-1) * koakuma03:GetLevelSpecialValueFor("reduction_cooldown", koakuma03_level)
		THDReduceCooldown(ability, reduction_cooldown)
		local cd_len = koakuma03:GetCooldown(koakuma03_level)		
		if caster:HasModifier("modifier_item_nuclear_stick_cooldown_reduction") then
			cd_len = cd_len * 0.75;
		end
		koakuma03:StartCooldown(cd_len)
		caster:RemoveModifierByName("modifier_thdots_koakuma03")
	end	

	local koakuma04_bonus_damage = 0
	if caster:HasModifier("modifier_koakuma04") then 
		koakuma04_bonus_damage = koakuma04:GetLevelSpecialValueFor("bonus_damage", koakuma04_level)/100	
	end
	-- Ability variables

	dummy_ability.bounceTable = {}
	dummy_ability.bounceCount = 0
	dummy_ability.damage = (1 + koakuma04_bonus_damage) * (ability:GetLevelSpecialValueFor("damage", ability_level) + Int * ability:GetLevelSpecialValueFor("damage_bonus_percent", ability_level)) + FindTelentValue(caster,"special_bonus_unique_lich_4")
	dummy_ability.bounceRange = ability:GetLevelSpecialValueFor("range", ability_level) 	
	dummy_ability.original_ability = ability
	dummy_ability.particle_name = "particles/heroes/koakuma/koakuma01.vpcf"
	dummy_ability.projectile_speed = ability:GetLevelSpecialValueFor("projectile_speed", ability_level) + bonus_projectile_speed + FindTelentValue(caster,"special_bonus_unique_lich_1")
	print("projectile_speed"..dummy_ability.projectile_speed)
	dummy_ability.projectileFrom = caster
	dummy_ability.projectileTo = nil
	if caster:GetClassname()=="npc_dota_hero_lich" then	
		dummy_ability.maxBounces = koakuma03:GetLevelSpecialValueFor("bounces", koakuma03_level)  + FindTelentValue(caster,"special_bonus_unique_lich_3")
		dummy_ability.damage_reduction_percent = (koakuma03:GetLevelSpecialValueFor("damage_reduction_percent", koakuma03_level) + FindTelentValue(caster,"special_bonus_unique_lich_2"))/100	
		dummy_ability.koakuma04_damage_percentage = koakuma04:GetLevelSpecialValueFor("damage_percentage", koakuma04_level)
		dummy_ability.koakuma04_radius = koakuma04:GetLevelSpecialValueFor("radius", koakuma04_level)
	else
		dummy_ability.maxBounces = 0
		dummy_ability.damage_reduction_percent = 0
		dummy_ability.koakuma04_damage_percentage = 0
		dummy_ability.koakuma04_radius = 0
	end

	-- Find the closest target that fits the search criteria
	local iTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
	local iType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local iFlag = DOTA_UNIT_TARGET_FLAG_NONE	
	-- It has to be a target different from the current one	
	dummy_ability.projectileTo = target
			

	-- If we didnt find a new target then kill the dummy and end the function
	local info = {
    Target = dummy_ability.projectileTo,
    Source = dummy_ability.projectileFrom,
    EffectName = dummy_ability.particle_name,
    Ability = dummy_ability,
    bDodgeable = false,
    bProvidesVision = false,
    iMoveSpeed = dummy_ability.projectile_speed,
    iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
	}
	ProjectileManager:CreateTrackingProjectile( info )   
end

--[[Author: Pizzalol
	Date: 29.09.2015.
	Creates bounce projectiles to the nearest target if there is any]]
function OnKoakuma01SpellJump( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local iTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
	local iType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local iFlag = DOTA_UNIT_TARGET_FLAG_NONE

	-- Initialize the damage table
	local damage_table = {}
	damage_table.attacker = caster:GetOwner()
	damage_table.victim = target
	damage_table.ability = ability.original_ability
	damage_table.damage_type = DAMAGE_TYPE_MAGICAL
	if ability.bounceCount ~= 0 then
		damage_table.damage = ability.damage * (1-ability.damage_reduction_percent)
	else
		damage_table.damage = ability.damage
	end
	if target:GetTeam() ~= caster:GetTeam() then
		UnitDamageTarget(damage_table)
	end
	--ApplyDamage(damage_table)
	-- Save the new damage for future bounces
	ability.damage = damage_table.damage
	if caster:GetOwner():HasModifier("modifier_koakuma04") then
		local targets = FindUnitsInRadius(
			caster:GetTeamNumber(), 
			target:GetAbsOrigin(), 
			nil, 
			ability.koakuma04_radius, 
			iTeam, 
			iType, 
			iFlag, 
			FIND_CLOSEST, 
			false)

		for _,v in pairs(targets) do
			if v ~= target then				
				local deal_damage = ability.damage * ability.koakuma04_damage_percentage / 100
				local damage_table = {
						ability = ability.original_ability,
					    victim = v,
					    attacker = caster:GetOwner(),
					    damage = deal_damage,
					    damage_type = DAMAGE_TYPE_MAGICAL, 
			    	    damage_flags = 0
				}
				UnitDamageTarget(damage_table)
			end
		end
	end

	-- If we exceeded the bounce limit then remove the dummy and stop the function
	if ability.bounceCount >= ability.maxBounces then
		killDummy(caster,caster)
		return
	end

	-- Reset target data and find new targets
	ability.projectileFrom = ability.projectileTo
	ability.projectileTo = nil

	
	local bounce_targets = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, ability.bounceRange, iTeam, iType, iFlag, 0, false)

	
	-- Find a new target that is not the current one
	for _,v in pairs(bounce_targets) do
		if v ~= target then
			ability.projectileTo = v
			break
		end
	end
	
	if ability.projectileTo == nil then
		--find self
		bounce_targets = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, ability.bounceRange, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, iFlag, FIND_CLOSEST, false)
		for _,v in pairs(bounce_targets) do
			if v == caster:GetOwner() and v ~= target then
				ability.projectileTo = v
				break
			end
		end
	end

	-- If we didnt find a new target then kill the dummy
	if ability.projectileTo == nil then
		killDummy(caster, caster)
	else
	-- Otherwise increase the bounce count and create a new bounce projectile
		ability.bounceCount = ability.bounceCount + 1
		local info = {
        Target = ability.projectileTo,
        Source = ability.projectileFrom,
        EffectName = ability.particle_name,
        Ability = ability,
        bDodgeable = false,
        bProvidesVision = false,
        iMoveSpeed = ability.projectile_speed,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
    	}
    	ProjectileManager:CreateTrackingProjectile( info )
    end
end

function killDummy(caster, target)
	if caster:GetUnitName() == "npc_dummy_unit" then
		caster:RemoveSelf()
	elseif target:GetUnitName() == "npc_dummy_unit" then
		target:RemoveSelf()
	end
end

function OnKoakuma02SpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if is_spell_blocked(keys.target) then return end
	local ability_level = ability:GetLevel() - 1
	local koakuma03
	local koakuma03_level
	local koakuma04
	local koakuma04_level
	-- Create the dummy unit which keeps track of bounces
	local dummy = CreateUnitByName( "npc_dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber() )
	dummy:AddAbility("ability_thdots_koakuma02_dummy")
	local dummy_ability =  dummy:FindAbilityByName("ability_thdots_koakuma02_dummy")
	dummy_ability:ApplyDataDrivenModifier( caster, dummy, "modifier_koakuma02_dummy_unit", {} )
	local Int = caster:GetIntellect()

	if caster:GetClassname()=="npc_dota_hero_lich" then	
		koakuma03 = caster:FindAbilityByName("ability_thdots_koakuma03")
		koakuma03_level = koakuma03:GetLevel() - 1
		koakuma04 = caster:FindAbilityByName("ability_thdots_koakuma04")
		koakuma04_level = koakuma04:GetLevel() - 1
	end
	local bonus_projectile_speed = 0
	if caster:HasModifier("modifier_thdots_koakuma03") then
		bonus_projectile_speed = koakuma03:GetLevelSpecialValueFor("bonus_projectile_speed", koakuma03_level)
		local reduction_cooldown = (-1) * koakuma03:GetLevelSpecialValueFor("reduction_cooldown", koakuma03_level)
		THDReduceCooldown(ability, reduction_cooldown)
		local cd_len = koakuma03:GetCooldown(koakuma03_level)		
		if caster:HasModifier("modifier_item_nuclear_stick_cooldown_reduction") then
			cd_len = cd_len * 0.75;
		end
		koakuma03:StartCooldown(cd_len)
		caster:RemoveModifierByName("modifier_thdots_koakuma03")
	end
	
	local koakuma04_bonus_damage = 0
	if caster:HasModifier("modifier_koakuma04") then 
		koakuma04_bonus_damage = koakuma04:GetLevelSpecialValueFor("bonus_damage", koakuma04_level)/100	
	end
	-- Ability variables
	
	dummy_ability.damage = (1 + koakuma04_bonus_damage) * (ability:GetLevelSpecialValueFor("damage", ability_level) + Int * (FindTelentValue(caster,"special_bonus_unique_lich_5") * 0.25 + ability:GetLevelSpecialValueFor("damage_bonus_percent", ability_level))) 

	dummy_ability.bounceTable = {}
	dummy_ability.bounceCount = 0
	dummy_ability.bounceRange = ability:GetLevelSpecialValueFor("range", ability_level) 	
	dummy_ability.original_ability = ability
	dummy_ability.particle_name = "particles/heroes/koakuma/koakuma02.vpcf"
	dummy_ability.projectile_speed = ability:GetLevelSpecialValueFor("projectile_speed", ability_level) + bonus_projectile_speed + FindTelentValue(caster,"special_bonus_unique_lich_1")
	dummy_ability.projectileFrom = caster
	dummy_ability.projectileTo = nil

	if caster:GetClassname()=="npc_dota_hero_lich" then	
		dummy_ability.maxBounces = koakuma03:GetLevelSpecialValueFor("bounces", koakuma03_level) + FindTelentValue(caster,"special_bonus_unique_lich_3")
		dummy_ability.damage_reduction_percent = (koakuma03:GetLevelSpecialValueFor("damage_reduction_percent", koakuma03_level) + FindTelentValue(caster,"special_bonus_unique_lich_2"))/100	
		dummy_ability.koakuma04_damage_percentage = koakuma04:GetLevelSpecialValueFor("damage_percentage", koakuma04_level)
		dummy_ability.koakuma04_radius = koakuma04:GetLevelSpecialValueFor("radius", koakuma04_level)
	else
		dummy_ability.maxBounces = 0
		dummy_ability.damage_reduction_percent = 0
		dummy_ability.koakuma04_damage_percentage = 0
		dummy_ability.koakuma04_radius = 0
	end

	-- Find the closest target that fits the search criteria
	local iTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
	local iType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local iFlag = DOTA_UNIT_TARGET_FLAG_NONE	
	-- It has to be a target different from the current one	
	dummy_ability.projectileTo = target
	
	-- If we didnt find a new target then kill the dummy and end the function
	local info = {
    Target = dummy_ability.projectileTo,
    Source = dummy_ability.projectileFrom,
    EffectName = dummy_ability.particle_name,
    Ability = dummy_ability,
    bDodgeable = false,
    bProvidesVision = false,
    iMoveSpeed = dummy_ability.projectile_speed,
    iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
	}
	ProjectileManager:CreateTrackingProjectile( info )   
end

--[[Author: Pizzalol
	Date: 29.09.2015.
	Creates bounce projectiles to the nearest target if there is any]]
function OnKoakuma02SpellJump( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local iTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
	local iType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local iFlag = DOTA_UNIT_TARGET_FLAG_NONE

	-- Initialize the damage table
	local damage_table = {}
	damage_table.attacker = caster:GetOwner()
	damage_table.victim = target
	damage_table.ability = ability.original_ability
	damage_table.damage_type = DAMAGE_TYPE_MAGICAL
	if ability.bounceCount ~= 0 then
		damage_table.damage = ability.damage * (1-ability.damage_reduction_percent)
	else
		damage_table.damage = ability.damage
	end
	if target:GetTeam() ~= caster:GetTeam() then
		UnitDamageTarget(damage_table)		
		if target:HasModifier("modifier_koakuma02_debuff") == false then			
			target.koakuma02count = 0			
		end
		ability.original_ability:ApplyDataDrivenModifier(caster:GetOwner(), target, "modifier_koakuma02_debuff", {})
		target.koakuma02count = target.koakuma02count + 1
		target:SetModifierStackCount("modifier_koakuma02_debuff", ability.original_ability, target.koakuma02count)
	end
	--ApplyDamage(damage_table)
	-- Save the new damage for future bounces
	ability.damage = damage_table.damage
	if caster:GetOwner():HasModifier("modifier_koakuma04") then
		local targets = FindUnitsInRadius(
			caster:GetTeamNumber(), 
			target:GetAbsOrigin(), 
			nil, 
			ability.koakuma04_radius, 
			iTeam, 
			iType, 
			iFlag, 
			FIND_CLOSEST, 
			false)

		for _,v in pairs(targets) do
			if v ~= target then				
				local deal_damage = ability.damage * ability.koakuma04_damage_percentage / 100
				local damage_table = {
						ability = ability.original_ability,
					    victim = v,
					    attacker = caster:GetOwner(),
					    damage = deal_damage,
					    damage_type = DAMAGE_TYPE_MAGICAL, 
			    	    damage_flags = 0
				}
				UnitDamageTarget(damage_table)
				if v:HasModifier("modifier_koakuma02_debuff") == false then			
					v.koakuma02count = 0			
				end
				ability.original_ability:ApplyDataDrivenModifier(caster:GetOwner(), v, "modifier_koakuma02_aoe_debuff", {})
				v.koakuma02count = v.koakuma02count + 1
				v:SetModifierStackCount("modifier_koakuma02_aoe_debuff", ability.original_ability, v.koakuma02count)				
			end
		end
	end

	-- If we exceeded the bounce limit then remove the dummy and stop the function
	if ability.bounceCount >= ability.maxBounces then
		killDummy(caster,caster)
		return
	end

	-- Reset target data and find new targets
	ability.projectileFrom = ability.projectileTo
	ability.projectileTo = nil

	-- find enemy hero
	local bounce_targets = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, ability.bounceRange, iTeam, iType, iFlag, 0, false)
	
	-- Find a new target that is not the current one
	for _,v in pairs(bounce_targets) do
		if v ~= target then
			ability.projectileTo = v
			break
		end
	end	

	if ability.projectileTo == nil then
		--find self
		bounce_targets = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, ability.bounceRange, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, iFlag, FIND_CLOSEST, false)
		for _,v in pairs(bounce_targets) do
			if v == caster:GetOwner() and v ~= target then
				ability.projectileTo = v
				break
			end
		end
	end

	-- If we didnt find a new target then kill the dummy
	if ability.projectileTo == nil then
		killDummy(caster, caster)
	else
	-- Otherwise increase the bounce count and create a new bounce projectile
		ability.bounceCount = ability.bounceCount + 1
		local info = {
        Target = ability.projectileTo,
        Source = ability.projectileFrom,
        EffectName = ability.particle_name,
        Ability = ability,
        bDodgeable = false,
        bProvidesVision = false,
        iMoveSpeed = ability.projectile_speed,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
    	}
    	ProjectileManager:CreateTrackingProjectile( info )
    end
end

function OnKoakuma03Think(keys)
	local caster = keys.caster
	local ability = keys.ability
	if ability:IsCooldownReady() and caster:HasModifier("modifier_thdots_koakuma03") == false then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_koakuma03", {})
	end	
end

function OnKoakumaExThink(keys)
	local caster = keys.caster
	local ability = keys.ability	
	local mana = caster:GetMana()
	local max_mana = caster:GetMaxMana()
	local stack_count = math.floor( 100 - ( mana / max_mana ) * 100 )

	if caster:HasModifier("modifier_thdots_koakumaex") == false then			
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_koakumaex", {})	
	end
	caster:SetModifierStackCount("modifier_thdots_koakumaex", ability, stack_count)
	
end

function OnKoakuma04Think(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vec_caster = caster:GetOrigin()
		if caster:GetHealth() == 0 and caster:IsRealHero() and caster:HasModifier("modifier_item_wanbaochui") then
			local effectIndex1 = ParticleManager:CreateParticle("particles/econ/items/monkey_king/arcana/fire/mk_arcana_fire_spring_ring_radial.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControlEnt(effectIndex1 , 0, caster, 5, "attach_hitloc", Vector(0,0,0), true)
			local effectIndex2 = ParticleManager:CreateParticle("particles/heroes/yumemi/ability_yumemi_04_exolosion.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControlEnt(effectIndex2 , 0, caster, 5, "attach_hitloc", Vector(0,0,0), true)
			caster:EmitSound("Hero_Huskar.Inner_Fire.Cast")
				
			local targets = FindUnitsInRadius(
						caster:GetTeam(),		--caster team
						vec_caster,		--find position
						nil,					--find entity
						1000,		--find radius
						DOTA_UNIT_TARGET_TEAM_ENEMY,
						DOTA_UNIT_TARGET_HERO,
						0, 
						FIND_CLOSEST,
						false
					)
			for _,v in pairs(targets) do
				local deal_damage=v:GetMaxHealth()*0.3
				local damage_table = {
						ability = keys.ability,
						victim = v,
						attacker = caster,
						damage = deal_damage,
						damage_type = DAMAGE_TYPE_MAGICAL, 
						damage_flags = 0
				}
				UnitDamageTarget(damage_table)
				UtilStun:UnitStunTarget(caster,v, 1)

				local effectIndex = ParticleManager:CreateParticle("particles/econ/items/invoker/invoker_apex/invoker_sun_strike_beam_immortal1.vpcf", PATTACH_CUSTOMORIGIN, caster)
				ParticleManager:SetParticleControl(effectIndex, 0, v:GetOrigin())
				v:EmitSound("Hero_Huskar.Inner_Fire.Cast")
				
				ParticleManager:DestroyParticleSystem(effectIndex,false)

		
			end
			
		end	
end