





function MirrorImage( event )
	local caster = event.caster
	local player = caster:GetPlayerID()
	local ability = event.ability
	local unit_name = caster:GetUnitName()
	local images_count = ability:GetLevelSpecialValueFor( "images_count", ability:GetLevel() - 1 )
	local duration = ability:GetLevelSpecialValueFor( "illusion_duration", ability:GetLevel() - 1 )
	local outgoingDamage = ability:GetLevelSpecialValueFor( "illusion_outgoing_damage", ability:GetLevel() - 1 )
	local incomingDamage = ability:GetLevelSpecialValueFor( "illusion_incoming_damage", ability:GetLevel() - 1 )
	local casterOrigin = caster:GetAbsOrigin()
	local casterAngles = caster:GetAngles()

	-- Stop any actions of the caster otherwise its obvious which unit is real
	caster:Stop()

	-- Initialize the illusion table to keep track of the units created by the spell
	if not caster.mirror_image_illusions then
		caster.mirror_image_illusions = {}
	end

	-- Kill the old images
	for k,v in pairs(caster.mirror_image_illusions) do
		if v and IsValidEntity(v) then 
			v:ForceKill(false)
	print("args")
		end
	end

	-- Start a clean illusion table
	caster.mirror_image_illusions = {}

	-- Setup a table of potential spawn positions
	local vRandomSpawnPos = {
		Vector( 72, 0, 0 ),		-- North
		Vector( 0, 72, 0 ),		-- East
		Vector( -72, 0, 0 ),	-- South
		Vector( 0, -72, 0 ),	-- West
	}

	for i=#vRandomSpawnPos, 2, -1 do	-- Simply shuffle them
		local j = RandomInt( 1, i )
		vRandomSpawnPos[i], vRandomSpawnPos[j] = vRandomSpawnPos[j], vRandomSpawnPos[i]
	end

	-- Insert the center position and make sure that at least one of the units will be spawned on there.
	table.insert( vRandomSpawnPos, RandomInt( 1, images_count+1 ), Vector( 0, 0, 0 ) )

	-- At first, move the main hero to one of the random spawn positions.
	FindClearSpaceForUnit( caster, casterOrigin + table.remove( vRandomSpawnPos, 1 ), true )

	-- Spawn illusions
	for i=1, images_count do

		local origin = casterOrigin + table.remove( vRandomSpawnPos, 1 )

		-- handle_UnitOwner needs to be nil, else it will crash the game.
		local illusion = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())
		illusion:SetPlayerID(caster:GetPlayerID())
		illusion:SetControllableByPlayer(player, true)

		illusion:SetAngles( casterAngles.x, casterAngles.y, casterAngles.z )
		
		-- Level Up the unit to the casters level
		local casterLevel = caster:GetLevel()
		for i=1,casterLevel-1 do
			illusion:HeroLevelUp(false)
		end

		-- Set the skill points to 0 and learn the skills of the caster
		illusion:SetAbilityPoints(0)
		for abilitySlot=0,15 do
			local ability = caster:GetAbilityByIndex(abilitySlot)
			if ability ~= nil then 
				local abilityLevel = ability:GetLevel()
				local abilityName = ability:GetAbilityName()
				local illusionAbility = illusion:FindAbilityByName(abilityName)
				illusionAbility:SetLevel(abilityLevel)
			end
		end

		-- Recreate the items of the caster
		for itemSlot=0,5 do
			local item = caster:GetItemInSlot(itemSlot)
			if item ~= nil then
				local itemName = item:GetName()
				local newItem = CreateItem(itemName, illusion, illusion)
				illusion:AddItem(newItem)
			end
		end

		-- Set the unit as an illusion
		-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
		illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
		
		-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
		illusion:MakeIllusion()
		-- Set the illusion hp to be the same as the caster
		illusion:SetHealth(caster:GetHealth())

		-- Add the illusion created to a table within the caster handle, to remove the illusions on the next cast if necessary
		table.insert(caster.mirror_image_illusions, illusion)

	end
end






if AbilityFlandre == nil then
	AbilityFlandre = class({})
end

function OnFlandreExDealDamage(keys)
	--PrintTable(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	if(caster.flandrelock == nil)then
		caster.flandrelock = false
	end

	if(caster.flandrelock == true)then
		return
	end

	caster.flandrelock = true
	local damage_table = {
		ability = keys.ability,
		victim = keys.unit,
		attacker = caster,
		damage = keys.DealDamage * keys.IncreaseDamage,
		damage_type = keys.ability:GetAbilityDamageType(), 
		damage_flags = keys.ability:GetAbilityTargetFlags()
	}
	--caster:RemoveModifierByName("passive_flandreEx_damaged")
	UnitDamageTarget(damage_table)
	caster.flandrelock = false
	--keys.ability:ApplyDataDrivenModifier(caster, caster, "passive_flandreEx_damaged", nil)
end

function OnFlandre02SpellStartUnit(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	if target:IsBuilding() then return end	
	local MaxDecreaseNum = keys.DecreaseMaxSpeed + FindTelentValue(caster, "special_bonus_unique_naga_siren_3")
	if caster:HasModifier("modifier_item_wanbaochui") then
		if(target:GetContext("ability_flandre02_Speed_Decrease")==nil)then
			target:SetContextNum("ability_flandre02_Speed_Decrease",0,0)
		end
		local decreaseSpeedCount = target:GetContext("ability_flandre02_Speed_Decrease")
		decreaseSpeedCount = decreaseSpeedCount + 1
		keys.ability:ApplyDataDrivenModifier(caster,target,"modifier_flandre02_slow_wanbaochui",{})
		if(decreaseSpeedCount>MaxDecreaseNum)then
			target:RemoveModifierByName("modifier_flandre02_slow_wanbaochui")
		else
			target:SetContextNum("ability_flandre02_Speed_Decrease",decreaseSpeedCount,0)
			target:SetThink(
				function()
					target:RemoveModifierByName("modifier_flandre02_slow_wanbaochui")
					local decreaseSpeedNow = target:GetContext("ability_flandre02_Speed_Decrease") - 1
					target:SetContextNum("ability_flandre02_Speed_Decrease",decreaseSpeedNow,0)	
				end, 
				DoUniqueString("ability_flandre02_Speed_Decrease_Duration"), 
				keys.Duration
			)	
		end
	
	else
		if(target:GetContext("ability_flandre02_Speed_Decrease")==nil)then
			target:SetContextNum("ability_flandre02_Speed_Decrease",0,0)
		end
		local decreaseSpeedCount = target:GetContext("ability_flandre02_Speed_Decrease")
		decreaseSpeedCount = decreaseSpeedCount + 1
		keys.ability:ApplyDataDrivenModifier(caster,target,"modifier_flandre02_slow",{})
		if(decreaseSpeedCount>MaxDecreaseNum)then
			target:RemoveModifierByName("modifier_flandre02_slow")
		else
			target:SetContextNum("ability_flandre02_Speed_Decrease",decreaseSpeedCount,0)
			target:SetThink(
				function()
					target:RemoveModifierByName("modifier_flandre02_slow")
					local decreaseSpeedNow = target:GetContext("ability_flandre02_Speed_Decrease") - 1
					target:SetContextNum("ability_flandre02_Speed_Decrease",decreaseSpeedNow,0)	
				end, 
				DoUniqueString("ability_flandre02_Speed_Decrease_Duration"), 
				keys.Duration
			)	
		end
	end
end

function OnFlandre02Passive(keys)
	local target = keys.target
	local caster = keys.caster
	if target:IsBuilding() then return end	
	if caster:HasModifier("modifier_item_wanbaochui") then
		keys.ability:ApplyDataDrivenModifier(caster,target,"modifier_flandre02_passive_debuff",{})
	end	
end


function  OnFlandre02SpellThink(keys)
	local caster = keys.caster
	local target = keys.target
	local damage_table = {
					ability = keys.ability,
					victim = target,
					attacker = caster,
					damage = keys.ExDamage,
					damage_type = DAMAGE_TYPE_PHYSICAL, 
					damage_flags = 0
				}
	UnitDamageTarget(damage_table)	
end


function OnFlandre04SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	keys.ability:SetContextNum("ability_flandre04_multi_count",0,0)
	local count = 1 + FindTelentValue(caster,"special_bonus_unique_naga_siren_2")
	local illusions = FindUnitsInRadius(
		   caster:GetTeam(),		
		   caster:GetOrigin(),		
		   nil,					
		   3000,		
		   DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		   DOTA_UNIT_TARGET_ALL,
		   DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED, 
		   FIND_CLOSEST,
		   false
	)

	for _,v in pairs(illusions) do
		if(v:IsIllusion() and v:GetModelName() == "models/thd2/flandre/flandre_mmd.vmdl")then
			count = count + 1
			v:MoveToPosition(caster:GetOrigin())
			v:SetThink(
				function()
					OnFlandre04illusionsRemove(v,caster)
					return 0.02
				end, 
				DoUniqueString("ability_collection_power"),
			0.02)
		end
	end

	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_bringer_ambient.vpcf", PATTACH_CUSTOMORIGIN, caster) 
	ParticleManager:SetParticleControlEnt(effectIndex , 0, caster, 5, "attach_attack1", Vector(0,0,0), true)
	ParticleManager:DestroyParticleSystemTime(effectIndex,keys.Duration)

	keys.ability:SetContextNum("ability_flandre04_multi_count",count,0)
	keys.ability:SetContextNum("ability_flandre04_effectIndex",effectIndex,0)
	
end



function OnFlandre04SpellRemove(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local count = keys.ability:GetContext("ability_flandre04_multi_count")
	count = count - 1
	keys.ability:SetContextNum("ability_flandre04_multi_count",count,0)
	if(count<=0)then
		caster:RemoveModifierByName("modifier_thdots_flandre_04_multi")
	end
end

function OnFlandre04EffectRemove(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local effectIndex = keys.ability:GetContext("ability_flandre04_effectIndex")
	ParticleManager:DestroyParticle(effectIndex,true)
end

function OnFlandre04illusionsRemove(target,caster,keys)
	local vecTarget = target:GetOrigin()
	local vecCaster = caster:GetOrigin()
	local speed = 30
	local radForward = GetRadBetweenTwoVec2D(vecTarget,vecCaster)
	local vecForward = Vector(math.cos(radForward) * speed,math.sin(radForward) * speed,1)
	vecTarget = vecTarget + vecForward
	
	target:SetForwardVector(vecForward)
	target:SetOrigin(vecTarget)
	if(GetDistanceBetweenTwoVec2D(vecTarget,vecCaster)<50)then
		local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/flandre/ability_flandre_04_effect.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(effectIndex, 0, vecCaster)
		ParticleManager:DestroyParticleSystem(effectIndex,false)
		
		target:RemoveSelf()
		
	end
end

function Onflandre04Success(keys)
	local Target = keys.target
	local caster = keys.caster
	local ability = nil
	ability = caster:FindAbilityByName("ability_thdots_flandre04")
	if Target:IsRealHero() == true then
		if ability~=nil then
			ability:EndCooldown()		

			local effectIndex = ParticleManager:CreateParticle(
					"particles/units/heroes/hero_bloodseeker/bloodseeker_bloodrage.vpcf", 
					PATTACH_CUSTOMORIGIN, 
					keys.caster)
			ParticleManager:SetParticleControlEnt(effectIndex , 0, keys.caster, 5, "follow_origin", Vector(0,0,0), true)
			ParticleManager:SetParticleControl(effectIndex, 1, keys.caster:GetOrigin())
			ParticleManager:DestroyParticleSystemTime(effectIndex,2)

			EmitSoundOn("Hero_Bane.BrainSap.Target",keys.caster)
		end
	end
end

function Onflandre04Kill(keys )
	local caster = keys.caster
	local target = keys.unit
	if target:IsRealHero() then
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_flandre_04_speed", {})
	end
end

