if AbilityReisen == nil then
	AbilityReisen = class({})
end

function OnReisenExSpellStart(caster,target)
	for i=1,1 do
		local rad = RandomFloat(-math.pi,math.pi)
		local dis = RandomFloat(400,700)
		local unit = CreateUnitByName(
			"npc_thdots_unit_reisenEx_unit"
			,target:GetOrigin() + Vector(dis*math.cos(rad),dis*math.sin(rad),0)
			,false
			,caster
			,caster
			,caster:GetTeam()
		)
		--unit:MoveToTargetToAttack(target)
		
		unit:SetContextThink("ability_reisen_ex_spell_think_attack", 
			function ()
				if GameRules:IsGamePaused() then return 0.03 end
				if(target==nil)then
					return nil
				end
				local newOrder = {
			 		UnitIndex = unit:entindex(),
			 		OrderType =  DOTA_UNIT_ORDER_ATTACK_TARGET,
			 		TargetIndex = target:entindex(), --Optional.  Only used when targeting units
			 		AbilityIndex = 0, --Optional.  Only used when casting abilities
			 		Position = nil, --Optional.  Only used when targeting the ground
			 		Queue = 0 --Optional.  Used for queueing up abilities
			 	}
				ExecuteOrderFromTable(newOrder)
				return nil
			end, 
		0.1)
		unit:SetContextThink("ability_reisen_ex_spell_think", 
			function ()
				if GameRules:IsGamePaused() then return 0.03 end
				unit:ForceKill(true)
			end, 
		2.3)
	end
	local dummy = CreateUnitByName("npc_dummy_unit", 
	    	    target:GetAbsOrigin(), 
				false, 
				caster, 
				caster, 
				caster:GetTeamNumber()
	)
	dummy:SetContextThink("ability_reisen_ex_dummy_think", 
			function ()
				if GameRules:IsGamePaused() then return 0.03 end
				dummy:RemoveSelf()
			end, 
	2.3)
end

function OnReisen01SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local targetPoint = keys.target_points[1]
	local Reisen01rad = GetRadBetweenTwoVec2D(caster:GetOrigin(),targetPoint)
	keys.ability:SetContextNum("ability_Reisen01_Rad",Reisen01rad,0)
end

function OnReisen01SpellMove(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targets = keys.target_entities
	local Reisen01rad = keys.ability:GetContext("ability_Reisen01_Rad")

	local vec = Vector(vecCaster.x-math.cos(Reisen01rad)*keys.MoveSpeed/50,vecCaster.y-math.sin(Reisen01rad)*keys.MoveSpeed/50,vecCaster.z)
	caster:SetOrigin(vec)
end

function OnReisen01SpellHit(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local damage_table = {
				ability = keys.ability,
			    victim = keys.target,
			    attacker = caster,
			    damage = keys.ability:GetAbilityDamageType(),
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
	}
	UnitDamageTarget(damage_table)
	if(caster:GetContext("ability_reisen02_buff")==TRUE)then
		local targets = FindUnitsInRadius(
		   	caster:GetTeam(),		--caster team
		  	keys.target:GetOrigin(),		--find position
		   	nil,					--find entity
		    caster:GetContext("ability_reisen02_buff_radius"),		--find radius
		   	DOTA_UNIT_TARGET_TEAM_ENEMY,
		   	keys.ability:GetAbilityTargetType(),
		   	0, 
		   	FIND_CLOSEST,
		   	false
	    )
	    OnReisen02FireEffect(keys.target)
	    OnReisen02DealDamage(caster,targets)
	end

	OnReisenExSpellStart(caster,keys.target)

	SetTargetToTraversable(caster)
end

function OnReisen02SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	caster:SetContextNum("ability_reisen02_buff",TRUE,0)
	caster:SetContextNum("ability_reisen02_buff_damage",keys.BounsDamage,0)
	caster:SetContextNum("ability_reisen02_buff_stun_duration",keys.Duration,0)
	caster:SetContextNum("ability_reisen02_buff_radius",keys.Radius,0)
	caster:SetContextNum("ability_reisen02_buff_type",keys.ability:GetAbilityDamageType(),0)
	caster:SetContextNum("ability_reisen02_buff_flag",keys.ability:GetAbilityTargetFlags(),0)
	local effectIndex = ParticleManager:CreateParticle("particles/heroes/reisen/ability_reisen02_buff.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(effectIndex , 0, caster, 5, "attach_attack1", Vector(0,0,0), true)
	ParticleManager:DestroyParticleSystemTime(effectIndex,keys.AbilityDuration)

	caster:SetContextThink("ability_reisen02_buff_timer", 
		function()
			if GameRules:IsGamePaused() then return 0.03 end
			caster:SetContextNum("ability_reisen02_buff",FALSE,0)
			return nil
		end, 
	keys.AbilityDuration)
end

function OnReisen02DealDamage(caster,targets)
	for _,v in pairs(targets) do
		local damage_table = {
			ability = keys.ability,
			victim = v,
			attacker = caster,
			damage = caster:GetContext("ability_reisen02_buff_damage"),
			damage_type = caster:GetContext("ability_reisen02_buff_type"), 
			damage_flags = caster:GetContext("ability_reisen02_buff_flag")
		}

		--PrintTable(damage_table)
		--OnReisenExSpellStart(caster,v)
		UnitDamageTarget(damage_table)
		UtilStun:UnitStunTarget( caster,v,caster:GetContext("ability_reisen02_buff_stun_duration") )
	end	
end

function OnReisen02FireEffect(v)
	local effectIndex = ParticleManager:CreateParticle("particles/heroes/reisen/ability_reisen02.vpcf", PATTACH_CUSTOMORIGIN, v)
	ParticleManager:SetParticleControlEnt(effectIndex, 0, v, 0, follow_origin, v:GetOrigin(), false)
	ParticleManager:DestroyParticleSystem(effectIndex,false)
end

function OnReisen03SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local targetPoint = keys.target_points[1]
	local reisen03rad = GetRadBetweenTwoVec2D(caster:GetOrigin(),targetPoint) + math.pi/3
	local reisen03dis = GetDistanceBetweenTwoVec2D(caster:GetOrigin(),targetPoint)
	local effectIndex = ParticleManager:CreateParticle("particles/heroes/reisen/ability_reisen_01_e.vpcf", PATTACH_CUSTOMORIGIN, caster)
	local originVector = caster:GetOrigin() + Vector(math.cos(reisen03rad- math.pi/37.5)*reisen03dis,math.sin(reisen03rad- math.pi/37.5)*reisen03dis,0)

	ParticleManager:SetParticleControlEnt(effectIndex , 0, caster, 5, "attach_eye", Vector(0,0,0), true)
	ParticleManager:SetParticleControl(effectIndex, 1, originVector)
	ParticleManager:SetParticleControlEnt(effectIndex , 9, caster, 5, "attach_eye", Vector(0,0,0), true)
	
	
	keys.ability:SetContextNum("ability_reisen03_Rad",reisen03rad,0)
	keys.ability:SetContextNum("ability_reisen03_dis",reisen03dis,0)
	keys.ability:SetContextNum("ability_reisen03_effectIndex",effectIndex,0)

	UnitPauseTarget( caster,caster,0.5)
end


function OnReisen03SpellMove(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targets = keys.target_entities
	local originRad = keys.ability:GetContext("ability_reisen03_Rad")
	local originVector = Vector(math.cos(originRad),math.sin(originRad),0)
	local originDis = keys.ability:GetContext("ability_reisen03_dis")
	
	for _,v in pairs(targets) do
		local vecV = v:GetOrigin()
		if(IsRadInRect(vecV,vecCaster,100,originDis,originRad))then
			local damage_table = {
			    victim = v,
			    attacker = caster,
			   	damage = keys.ability:GetAbilityDamage(),
			    damage_type = keys.ability:GetAbilityDamageType(), 
			    ability_damage_target_type = keys.ability:GetAbilityTargetType(),
	    	   	damage_flags = 0
			}
			OnReisen03DamageTarget(damage_table)
		end
	end
	local effectIndex = keys.ability:GetContext("ability_reisen03_effectIndex")
	local originRad = originRad - math.pi/37.5
	caster:SetForwardVector(Vector(math.cos(originRad)*originDis,math.sin(originRad)*originDis,0))
	local forwardVec = caster:GetForwardVector()
	keys.ability:SetContextNum("ability_reisen03_Rad",originRad,0)

	ParticleManager:SetParticleControl(effectIndex, 1, caster:GetOrigin() + Vector(math.cos(originRad)*originDis,math.sin(originRad)*originDis,0))
	
	ParticleManager:DestroyParticleSystem(effectIndex,false)
end

function OnReisen03DamageTarget(damage_table)
	local caster = damage_table.attacker
	local target = damage_table.victim
	if(target:GetContext("ability_reisen03_damage_tag")==nil or target:GetContext("ability_reisen03_damage_tag")==FALSE)then
		target:SetContextNum("ability_reisen03_damage_tag",TRUE,0)
		Timer.Wait 'ability_reisen03_damage_tag' (1,
			function()
				OnReisenExSpellStart(caster,target)
				UnitDamageTarget(damage_table)
				
				if(caster:GetContext("ability_reisen02_buff")==TRUE)then
					local targets = FindUnitsInRadius(
					   	caster:GetTeam(),		--caster team
					  	target:GetOrigin(),		--find position
					   	nil,					--find entity
					   	caster:GetContext("ability_reisen02_buff_radius"),		--find radius
					   	DOTA_UNIT_TARGET_TEAM_ENEMY,
					   	damage_table.ability_damage_target_type,
					   	0, 
					   	FIND_CLOSEST,
					   	false
				    )
				    OnReisen02FireEffect(target)
				    OnReisen02DealDamage(caster,targets)
				end

				target:SetContextNum("ability_reisen03_damage_tag",FALSE,0)
			end
		)
	end
end

function OnReisen04SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local OnHitFuction = "OnReisen04ProjectileOnHit"
	local forwardVec = caster:GetForwardVector()
	local forwardCos = forwardVec.x
	local forwardSin = forwardVec.y

	for i=1,5 do
		local rollRad = math.pi/6 * i - math.pi/2
		local shotVector =  Vector(math.cos(rollRad)*forwardCos - math.sin(rollRad)*forwardSin,
								 forwardSin*math.cos(rollRad) + forwardCos*math.sin(rollRad),
								 0)
		local BulletTable = {
		    Ability        	 	=   keys.ability,
			EffectName			=	"particles/heroes/reisen/ability_reisen_04_bullet.vpcf",
			vSpawnOrigin		=	caster:GetOrigin() + Vector(0,0,64),
			vSpawnOriginNew		=	caster:GetOrigin() + Vector(0,0,64),
			fDistance			=	1500,
			fStartRadius		=	keys.DamageRadius,
			fEndRadius			=	keys.DamageRadius,
			Source         	 	=   caster,
			bHasFrontalCone		=	false,
			bRepalceExisting 	=  false,
			iUnitTargetTeams		=	"DOTA_UNIT_TARGET_TEAM_ENEMY",
			iUnitTargetTypes		=	"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_CREEP",
			iUnitTargetFlags		=	"DOTA_UNIT_TARGET_FLAG_NONE",
			fExpireTime     =   GameRules:GetGameTime() + 10.0,
			bDeleteOnHit    =   true,
			vVelocity       =   shotVector,
			bProvidesVision	=	true,
			iVisionRadius	=	400,
			iVisionTeamNumber = caster:GetTeamNumber()
		}
		DotsCreateProjectileMoveToTargetPoint(BulletTable,caster,keys.MoveSpeed,keys.Acceleration1,keys.Acceleration2,OnHitFuction)
	end
end

function OnReisen04ProjectileOnHit(caster,targets,ability)
    local damage_table = {
    	ability = keys.ability,
        victim = targets[1],
        attacker = caster,
        damage = ability:GetAbilityDamage(),
        damage_type = ability:GetAbilityDamageType(),
        damage_flags = ability:GetAbilityTargetFlags()
    }
    OnReisenExSpellStart(caster,targets[1])
    UnitDamageTarget(damage_table)
    if(caster:GetContext("ability_reisen02_buff")==TRUE and (GetDistanceBetweenTwoVec2D(caster:GetOrigin(),targets[1]:GetOrigin()) >= 200))then
		local targets02 = FindUnitsInRadius(
		   	caster:GetTeam(),		--caster team
		  	targets[1]:GetOrigin(),		--find position
		   	nil,					--find entity
		    caster:GetContext("ability_reisen02_buff_radius"),		--find radius
		   	DOTA_UNIT_TARGET_TEAM_ENEMY,
		   	ability:GetAbilityTargetType(),
		   	0, 
		   	FIND_CLOSEST,
		   	false
	    )
	    OnReisen02FireEffect(targets[1])
	    OnReisen02DealDamage(caster,targets02)
	end
end


function DotsCreateProjectileMoveToTargetPoint(projectileTable,caster,speed,acceleration1,acceleration2,OnHitFuction)
    local effectIndex = ParticleManager:CreateParticle(projectileTable.EffectName, PATTACH_CUSTOMORIGIN, caster)
    local acceleration = acceleration1
    local targets = {}
    caster:SetContextThink(DoUniqueString("ability_caster_projectile"), 
        function()
        	if GameRules:IsGamePaused() then return 0.03 end
            local vec = projectileTable.vSpawnOriginNew + projectileTable.vVelocity*speed/50
            local dis = GetDistanceBetweenTwoVec2D(projectileTable.vSpawnOrigin,vec)
            targets = FindUnitsInRadius(
                caster:GetTeam(),       --caster team
                vec,                    --find position
                nil,                    --find entity
                projectileTable.fStartRadius,       --find radius
                projectileTable.Ability:GetAbilityTargetTeam(),
                projectileTable.Ability:GetAbilityTargetType(),
                projectileTable.Ability:GetAbilityTargetFlags(), 
                FIND_CLOSEST,
                false
            )
            if(targets[1]~=nil)then
                if(projectileTable.bDeleteOnHit)then
                    if(OnHitFuction=="OnReisen04ProjectileOnHit")then
                        OnReisen04ProjectileOnHit(caster,targets,projectileTable.Ability)
                    end
                    ParticleManager:DestroyParticleSystem(effectIndex,true)
                    return nil
                else
                    if(OnHitFuction=="OnReisen04ProjectileOnHit")then
                        OnReisen04ProjectileOnHit(caster,targets,projectileTable.Ability)
                    end
                    targets = {}
                end
            end

            if(speed <= 0 and acceleration2 ~= 0)then
                acceleration = acceleration2
                speed = 0
                acceleration2 = 0
            end

            if(dis<projectileTable.fDistance)then
                    ParticleManager:SetParticleControl(effectIndex,3,vec)
                    projectileTable.vSpawnOriginNew = vec
                    speed = speed + acceleration
                    return 0.02
            else
                ParticleManager:DestroyParticleSystem(effectIndex,true)
                return nil
            end
        end, 
    0.02)
end

function OnReisenOldExSpellSuccess(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	local RandomNumber = RandomInt(1,100)
	local deal_damage = caster:GetPrimaryStatValue()*0.5
	if target:IsBuilding() then 
		deal_damage=deal_damage*0.3
	end
	local extrachance = caster:FindAbilityByName("ability_thdots_reisenOld04"):GetLevel()*8
	local deal_chance = extrachance + keys.Chance
	local damage_table = {
		ability = keys.ability,
        victim = keys.target,
        attacker = caster,
        damage = deal_damage,
        damage_type = keys.ability:GetAbilityDamageType(),
        damage_flags = keys.ability:GetAbilityTargetFlags()
		}
	if caster:HasModifier("ability_reisenold04_modifier") then 		
		UnitDamageTarget(damage_table)
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_reisenexold_slow", {})
		StartSoundEvent("Voice_Thdots_Reisen.AbilityReisen01", caster)
	elseif RandomNumber <= deal_chance then		
		UnitDamageTarget(damage_table)
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_reisenexold_slow", {})
		StartSoundEvent("Voice_Thdots_Reisen.AbilityReisen01", caster)
	elseif target:HasModifier("modifier_thdots_reisen03_full") then
		UnitDamageTarget(damage_table)
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_reisenexold_slow", {})
		StartSoundEvent("Voice_Thdots_Reisen.AbilityReisen01", caster)
	end	
end

function OnReisenOld02SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)

	local VecCaster = caster:GetOrigin()
	local radian = RandomFloat(0,6.28)
	VecCaster.x = VecCaster.x+math.cos(radian)*50
	VecCaster.y = VecCaster.y+math.sin(radian)*50
	FindClearSpaceForUnit(caster, VecCaster, true)

	if(caster.ability_reisen02_illusion_max == nil)then
		caster.ability_reisen02_illusion_max = 0
	end
	if(caster.ability_reisen02_illusion_max < keys.Max_illusions)then
		caster.ability_reisen02_illusion_max = caster.ability_reisen02_illusion_max + 2
		for i=1,2 do
			illusion=create_illusion_reisen(keys,caster:GetOrigin(),keys.Illusion_damage_in_pct,keys.Illusion_damage_out_pct,keys.Illusion_duration)
			if (illusion ~= nil) then
				local CasterAngles = caster:GetAnglesAsVector()
				illusion:SetAngles(CasterAngles.x,CasterAngles.y,CasterAngles.z)
				illusion:SetHealth(illusion:GetMaxHealth()*caster:GetHealthPercent()*0.01)
				illusion:SetMana(illusion:GetMaxMana()*caster:GetManaPercent()*0.01)
				local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_lancer/phantom_lancer_spawn_smoke.vpcf", PATTACH_CUSTOMORIGIN, caster)
				ParticleManager:SetParticleControl(effectIndex, 0, illusion:GetOrigin())
				ParticleManager:SetParticleControl(effectIndex, 1, illusion:GetOrigin())
				illusion.illusioncaster = caster
			end
		end
	end
end

function OnReisenOld02SpellSuccess(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local hero
	local chance = RandomFloat(0,100)

	if(caster:IsIllusion())then
		hero = caster.illusioncaster
		if(hero:FindModifierByName("ability_reisenold04_modifier") ~= nil)then
			chance = 0
		end
		if(chance>keys.illusionChance)then
			return
		end
	else
		hero = caster
		if(hero:FindModifierByName("ability_reisenold04_modifier") ~= nil)then
			chance = 0
		end
		if(chance>keys.Chance)then
			return
		end
	end
	if(hero.ability_reisen02_illusion_max == nil)then
		hero.ability_reisen02_illusion_max = 0
	end
	if(hero.ability_reisen02_illusion_max < keys.Max_illusions)then
		hero.ability_reisen02_illusion_max = hero.ability_reisen02_illusion_max + 1
		illusion=create_illusion_reisen(keys,caster:GetOrigin(),keys.Illusion_damage_in_pct,keys.Illusion_damage_out_pct,keys.Illusion_duration)
		if (illusion ~= nil) then
			local CasterAngles = hero:GetAnglesAsVector()
			illusion:SetAngles(CasterAngles.x,CasterAngles.y,CasterAngles.z)
			illusion:SetHealth(illusion:GetMaxHealth()*hero:GetHealthPercent()*0.01)
			illusion:SetMana(illusion:GetMaxMana()*hero:GetManaPercent()*0.01)
			local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_lancer/phantom_lancer_spawn_smoke.vpcf", PATTACH_CUSTOMORIGIN, hero)
			ParticleManager:SetParticleControl(effectIndex, 0, illusion:GetOrigin())
			ParticleManager:SetParticleControl(effectIndex, 1, illusion:GetOrigin())
			if(hero:IsIllusion())then
				illusion.illusioncaster = hero.illusioncaster
			else
				illusion.illusioncaster = hero
			end
		end
	end
end

function OnReisenOld02OnDeath(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)

	if(caster:IsIllusion())then
		local hero = caster.illusioncaster
		hero.ability_reisen02_illusion_max = hero.ability_reisen02_illusion_max - 1
	end
end

function create_illusion_reisen(keys, illusion_origin, illusion_incoming_damage, illusion_outgoing_damage, illusion_duration)	
	local player_id = keys.caster:GetPlayerID()
	local caster_team = keys.caster:GetTeam()
	local tmp = keys.caster
	if GetMapName() == "dota" then
		tmp = nil
	end
	local illusion = CreateUnitByName(keys.caster:GetUnitName(), illusion_origin, true, keys.caster, tmp, caster_team)
	illusion:SetPlayerID(player_id)
	illusion:SetControllableByPlayer(player_id, true)

	--Level up the illusion to the caster's level.
	local caster_level = keys.caster:GetLevel()
	for i = 1, caster_level - 1 do
		illusion:HeroLevelUp(false)
	end

	--Set the illusion's available skill points to 0 and teach it the abilities the caster has.
	illusion:SetAbilityPoints(0)
	for ability_slot = 0, 15 do
		local individual_ability = keys.caster:GetAbilityByIndex(ability_slot)
		if individual_ability ~= nil then 
			local illusion_ability = illusion:FindAbilityByName(individual_ability:GetAbilityName())
			if illusion_ability ~= nil then
				illusion_ability:SetLevel(individual_ability:GetLevel())
			end
		end
	end

	print("AddNewModifier")
	-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle 
	illusion:AddNewModifier(keys.caster, keys.ability, "modifier_illusion", {duration = illusion_duration, outgoing_damage = illusion_outgoing_damage, incoming_damage = illusion_incoming_damage})
	print("MakeIllusion")
	print(illusion_incoming_damage)
	illusion:MakeIllusion()  --Without MakeIllusion(), the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.  Without it, IsIllusion() returns false and IsRealHero() returns true.

	--Recreate the caster's items for the illusion.
	for item_slot = 0, 8 do
		local individual_item = keys.caster:GetItemInSlot(item_slot)
		if individual_item ~= nil then
			local illusion_duplicate_item = CreateItem(individual_item:GetName(), illusion, illusion)
			illusion:AddItem(illusion_duplicate_item)
			illusion_duplicate_item:SetPurchaser(nil)
		end
	end
	
	return illusion
end

function OnReisen03ChannellStart(keys)
	local caster = keys.caster
	caster.ability_reisen_03_time_count = 0.05
	caster.ability_reisen_03_damage_count = 0.05
	if caster:HasModifier("modifier_item_wanbaochui") then
		THDReduceCooldown(keys.ability,-9)
	end

end
function OnReisen03Channelling(keys)
	local caster = keys.caster	
	caster.ability_reisen_03_time_count = caster.ability_reisen_03_time_count + 0.05
end

function OnReisen03Shoot(keys)
	local caster = keys.caster
	caster.ability_reisen_03_damage_count = caster.ability_reisen_03_time_count
	print(caster.ability_reisen_03_damage_count)
end

function OnReisenOld03SpellHit(keys)
	local caster = keys.caster
	local damage_rate = math.floor(10*caster.ability_reisen_03_damage_count/1.0)/10	
	local damagetype = keys.ability:GetAbilityDamageType()
	--[[if caster:HasModifier("modifier_item_wanbaochui") then
		damage_rate=1
	end]]--
	local deal_damage=keys.ability:GetAbilityDamage()*damage_rate
	

	if FindTelentValue(caster,"special_bonus_unique_mirana_1") == 1 then
		deal_damage = deal_damage * 1.5
	end
	
	if damage_rate == 1 then
		if caster:HasModifier("modifier_item_wanbaochui") then
			deal_damage=deal_damage*1.8
		end
		print("damage_rate = "..damage_rate)
		keys.ability:ApplyDataDrivenModifier(caster, keys.target, "modifier_thdots_reisen03_full", {})
	end
	if caster:HasModifier("modifier_item_wanbaochui") then
		local damage_table = {
			ability = keys.ability,
			victim = keys.target,
			attacker = caster,
			damage = deal_damage,
			damage_type = DAMAGE_TYPE_MAGICAL, 
			damage_flags = keys.ability:GetAbilityTargetFlags()
		}
		UnitDamageTarget(damage_table)
		keys.ability:ApplyDataDrivenModifier(caster, keys.target, "modifier_reisen03_knockback", {})
	else
		local damage_table = {
			ability = keys.ability,
			victim = keys.target,
			attacker = caster,
			damage = deal_damage,
			damage_type =  keys.ability:GetAbilityDamageType(), 
			damage_flags = keys.ability:GetAbilityTargetFlags()
		}
		UnitDamageTarget(damage_table)
	end

	if caster:GetClassname()=="npc_dota_hero_mirana" then
		local ex_damage = caster:GetPrimaryStatValue()*0.5
		local damage_table_ex = {
			ability = keys.ability,
	        victim = keys.target,
	        attacker = caster,
	        damage = ex_damage,
	        damage_type = keys.ability:GetAbilityDamageType(),
	        damage_flags = keys.ability:GetAbilityTargetFlags()
			}		
		UnitDamageTarget(damage_table_ex)
		caster:FindAbilityByName("ability_thdots_reisenOldex"):ApplyDataDrivenModifier(caster, keys.target, "modifier_reisenexold_slow", {})
		StartSoundEvent("Voice_Thdots_Reisen.AbilityReisen01", caster)
	end	
end

function OnReisenOld04SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	caster:EmitSound("Voice_Thdots_Reisen.AbilityReisen04")
	keys.ability:ApplyDataDrivenModifier(caster, caster, "ability_reisenold04_modifier", {Duration = keys.duration + FindTelentValue(caster,"special_bonus_unique_mirana_2")})
	keys.ability:ApplyDataDrivenModifier(caster, caster, "ability_reisenold04_bouns_attack_speed", {Duration = keys.duration + FindTelentValue(caster,"special_bonus_unique_mirana_2")})
end