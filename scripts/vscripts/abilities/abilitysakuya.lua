if AbilitySakuya == nil then
	AbilitySakuya = class({})
end

function OnSakuyaExSpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_templar_assassin"))
	if(caster.ability_sakuya_01_stun == FALSE or caster.ability_sakuya_01_stun == nil)then
		caster.ability_sakuya_01_stun = TRUE
		local effectIndex = ParticleManager:CreateParticle(
			"particles/heroes/sakuya/ability_sakuya_ex.vpcf", 
			PATTACH_CUSTOMORIGIN, 
			caster)
		caster.ability_sakuya_ex_index = effectIndex
		ParticleManager:SetParticleControlEnt(effectIndex , 0, caster, 5, "attach_attack1", Vector(0,0,0), true)
	else
		return
	end
end

function OnSakuya01SpellReset(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	if(caster.sakuya04_cooldown_reset==TRUE)then
		keys.ability:EndCooldown()
		local usedCount = caster.sakuya04_ability_01_used_count + 1
		caster:SetMana(caster:GetMana() - usedCount * 0.25 * keys.ability:GetManaCost(keys.ability:GetLevel()))
		caster.sakuya04_ability_01_used_count = usedCount
	end
end

function OnSakuya01SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	local intBouns = (caster:GetIntellect()	- (caster:GetIntellect()%6)) / 6 * keys.IntMulti + 1
	local agiBouns = (caster:GetAgility() - (caster:GetAgility()%6)) / 6 * keys.AgiMulti
	local bounsDamage = 0
	
	if(caster.ability_sakuya_01_stun==TRUE)then
		UnitPauseTargetSakuya( caster,target,keys.StunDuration,keys.ability )
		local effectIndex = ParticleManager:CreateParticle(
			"particles/heroes/sakuya/ability_sakuya_ex_stun.vpcf", 
			PATTACH_CUSTOMORIGIN, 
			caster)
		ParticleManager:SetParticleControlEnt(effectIndex , 0, target, 5, "follow_origin", Vector(0,0,0), true)
		ParticleManager:DestroyParticleSystem(effectIndex,false)
		bounsDamage = keys.DamageBouns
	end


	if(caster.ability_sakuya_ex_index ~= -1 and caster.ability_sakuya_ex_index ~= nil)then
		ParticleManager:DestroyParticleSystem(caster.ability_sakuya_ex_index,true)
		caster.ability_sakuya_ex_index = -1
	end
	
	local dealdamage = (agiBouns + keys.Damage + bounsDamage) * intBouns
	local damage_table = {
			    victim = target,
			    attacker = caster,
			    damage = dealdamage,
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0,
	    	    ability = keys.ability
	}
	UnitDamageTarget(damage_table)

	Timer.Wait 'ability_sakuya_01_stun_timer' (0.5,
		function()
			caster.ability_sakuya_01_stun = FALSE
		end
	)	
end

function OnSakuya02SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local targetPoint = keys.target_points[1]
	keys.ability.ability_sakuya02_point_x = targetPoint.x
	keys.ability.ability_sakuya02_point_y =targetPoint.y
	keys.ability.ability_sakuya02_point_z =targetPoint.z
end

function OnSakuya02SpellDamage(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targetPoint = Vector(keys.ability.ability_sakuya02_point_x,keys.ability.ability_sakuya02_point_y,keys.ability.ability_sakuya02_point_z)
	local targets = keys.target_entities

	local pointRad = GetRadBetweenTwoVec2D(vecCaster,targetPoint)
	local pointRad1 = pointRad + math.pi * (keys.DamageRad/180)
	local pointRad2 = pointRad - math.pi * (keys.DamageRad/180)

	local forwardVec = Vector( math.cos(pointRad) * 2000 , math.sin(pointRad) * 2000 , 0 )

	local knifeTable = {
		Ability				= keys.ability,
		EffectName			= "particles/thd2/heroes/sakuya/ability_sakuya_01.vpcf",
		vSpawnOrigin		= vecCaster + Vector(0,0,128),
		fDistance			= keys.DamageRadius,
		fStartRadius		= 120,
		fEndRadius			= 120,
		Source				= caster,
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
		iVisionTeamNumber	= caster:GetTeamNumber(),
		iSourceAttachment 	= PATTACH_CUSTOMORIGIN
	} 

	ProjectileManager:CreateLinearProjectile(knifeTable)

	for i=1,keys.ability:GetLevel() do
		local iVec = Vector( math.cos(pointRad + math.pi/18*(i+0.5)) * 2000 , math.sin(pointRad + math.pi/18*(i+0.5)) * 2000 , 0 )
		knifeTable.vVelocity = iVec
		ProjectileManager:CreateLinearProjectile(knifeTable)
		iVec = Vector( math.cos(pointRad - math.pi/18*(i+0.5)) * 2000 , math.sin(pointRad - math.pi/18*(i+0.5)) * 2000 , 0 )
		knifeTable.vVelocity = iVec
		ProjectileManager:CreateLinearProjectile(knifeTable)
	end

	for _,v in pairs(targets) do
		local vVec = v:GetOrigin()
		local vecRad = GetRadBetweenTwoVec2D(targetPoint,vecCaster)
		if IsPointInCircularSector(vVec.x,vVec.y,math.cos(vecRad),math.sin(vecRad),keys.DamageRadius,math.pi * (keys.DamageRad/180),vecCaster.x,vecCaster.y) then
			local intBouns = (caster:GetIntellect()	- (caster:GetIntellect()%6)) / 6 * keys.IntMulti + 1
			local agiBouns = (caster:GetAgility() - (caster:GetAgility()%6)) / 6 * keys.AgiMulti
			print("----------------------")
			print(intBouns)
			print(agiBouns)
			local dealdamage = (agiBouns + keys.Damage) * intBouns
			local damage_table = {
				victim = v,
				attacker = caster,
				damage = dealdamage,
				damage_type = keys.ability:GetAbilityDamageType(), 
				damage_flags = 0,
				ability = keys.ability
			}
			UnitDamageTarget(damage_table)
		end
	end
	if(caster.sakuya04_cooldown_reset==TRUE)then
		keys.ability:EndCooldown()
		local usedCount = caster.sakuya04_ability_02_used_count + 1
		caster:SetMana(caster:GetMana() - usedCount * 0.25 * keys.ability:GetManaCost(keys.ability:GetLevel()))
		caster.sakuya04_ability_02_used_count = usedCount
	end
end


function OnSakuya03SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_templar_assassin_2"))
	local targetPoint = keys.target_points[1]
	caster.ability_sakuya03_point_x = targetPoint.x
	caster.ability_sakuya03_point_y = targetPoint.y
	caster.ability_sakuya03_point_z = targetPoint.z
end

function OnSakuya03SpellDamage(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targetPoint = Vector(caster.ability_sakuya03_point_x,caster.ability_sakuya03_point_y,caster.ability_sakuya03_point_z)
	local targets = keys.target_entities

	local pointRad = GetRadBetweenTwoVec2D(vecCaster,targetPoint)

	local forwardVec = Vector( math.cos(pointRad) * 1000 , math.sin(pointRad) * 1000 , 0 )
	local knifeTable = {
	    Ability        	 	=   keys.ability,
		EffectName			=	"particles/thd2/heroes/sakuya/ability_sakuya_01.vpcf",
		vSpawnOrigin		=	vecCaster + Vector(0,0,64),
		fDistance			=	keys.DamageRadius/2,
		fStartRadius		=	120,
		fEndRadius			=	120,
		Source         	 	=   caster,
		bHasFrontalCone		=	false,
		bRepalceExisting 	=  false,
		iUnitTargetTeams		=	"DOTA_UNIT_TARGET_TEAM_ENEMY",
		iUnitTargetTypes		=	"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_CREEP",
		iUnitTargetFlags		=	"DOTA_UNIT_TARGET_FLAG_NONE",
		fExpireTime     =   GameRules:GetGameTime() + 10.0,
		bDeleteOnHit    =   false,
		vVelocity       =   forwardVec,
		bProvidesVision	=	true,
		iVisionRadius	=	400,
		iVisionTeamNumber = caster:GetTeamNumber()
	}

	for i=0,5 do
		local iVec = Vector( math.cos(pointRad + math.pi/6*i) * 1000 , math.sin(pointRad + math.pi/6*i) * 1000 , 0 )
		knifeTable.vVelocity = iVec
		ProjectileManager:CreateLinearProjectile(knifeTable)
		iVec = Vector( math.cos(pointRad - math.pi/6*i) * 1000 , math.sin(pointRad - math.pi/6*i) * 1000 , 0 )
		knifeTable.vVelocity = iVec
		ProjectileManager:CreateLinearProjectile(knifeTable)
	end

	local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/sakuya/ability_sakuya_03.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, caster:GetOrigin())
	ParticleManager:SetParticleControl(effectIndex, 1, caster:GetOrigin())
	ParticleManager:DestroyParticleSystem(effectIndex,false)

	if(GetDistanceBetweenTwoVec2D(vecCaster,targetPoint)<=keys.MaxRange)then
		FindClearSpaceForUnit(caster,targetPoint,true)
	else
		local blinkVector = Vector(math.cos(pointRad)*keys.MaxRange,math.sin(pointRad)*keys.MaxRange,0) + vecCaster
		FindClearSpaceForUnit(caster,blinkVector,true)
	end
	
	SetTargetToTraversable(caster)

	for _,v in pairs(targets) do
		local damage_table = {
			victim = v,
			attacker = caster,
			damage = keys.Damage,
			damage_type = keys.ability:GetAbilityDamageType(), 
			damage_flags = 0,
			ability = keys.ability
		}
		UnitDamageTarget(damage_table)
	end
	if(caster.sakuya04_cooldown_reset==TRUE)then
		keys.ability:EndCooldown()
		local usedCount = caster.sakuya04_ability_03_used_count + 1
		caster:SetMana(caster:GetMana() - usedCount * 0.25 * keys.ability:GetManaCost(keys.ability:GetLevel()))
		caster.sakuya04_ability_03_used_count = usedCount
	end
end

function OnSakuya04SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	if caster:HasModifier("modifier_item_wanbaochui") then 
		caster:EmitSound("Voice_Thdots_Sakuya.AbilitySakuya04_WanBaoChui")
	else
		caster:EmitSound("Voice_Thdots_Sakuya.AbilitySakuya04")
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
	local nEffectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/sakuya/ability_sakuya_04.vpcf",PATTACH_CUSTOMORIGIN,unit)
	local vecCorlor = Vector(255,0,0)
	ParticleManager:SetParticleControl( nEffectIndex, 0, caster:GetOrigin())
	if caster:HasModifier("modifier_item_wanbaochui") then 
		keys.ability:ApplyDataDrivenModifier(caster, unit, "modifier_the_world", {duration = 2})
	end


		
	caster.sakuya04_Effect_Unit = unit:GetEntityIndex()
	caster.sakuya04_ability_01_used_count = 0
	caster.sakuya04_ability_02_used_count = 0
	caster.sakuya04_ability_03_used_count = 0

	local ability = caster:FindAbilityByName("ability_thdots_sakuya01") 
	if(ability~=nil)then
		ability:EndCooldown()
	end
	ability = caster:FindAbilityByName("ability_thdots_sakuya02") 
	if(ability~=nil)then
		ability:EndCooldown()
	end
	ability = caster:FindAbilityByName("ability_thdots_sakuya03") 
	if(ability~=nil)then
		ability:EndCooldown()
	end
	ability = caster:FindAbilityByName("ability_thdots_satori01") 
	if(ability~=nil)then
		ability:EndCooldown()
	end
	ability = caster:FindAbilityByName("ability_thdots_satori02") 
	if(ability~=nil)then
		ability:EndCooldown()
	end
	ability = caster:FindAbilityByName("ability_thdots_satori03") 
	if(ability~=nil)then
		ability:EndCooldown()
	end
	ability = caster:FindAbilityByName("ability_thdots_satori04") 
	if(ability~=nil)then
		ability:EndCooldown()
	end

	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString('ability_sakuya04_remove'),
    	function ()
    		if GameRules:IsGamePaused() then return 0.03 end
		    if (unit~=nil) then
		        unit:RemoveSelf()
		        caster.sakuya04_cooldown_reset = FALSE
		    	return nil
			end
	    end,keys.Ability_Duration+0.1
	)
end

function OnSakuya04SpellThink(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local effectUnitIndex = caster.sakuya04_Effect_Unit
	local effectUnit = EntIndexToHScript(effectUnitIndex)
	local vecEffectUnit = effectUnit:GetOrigin()
	local radius=0
	if caster:HasModifier("modifier_item_wanbaochui") then 
		radius=99999
	else
		radius=keys.Radius
    end
	if(GetDistanceBetweenTwoVec2D(vecCaster,vecEffectUnit) <= radius)then
		caster.sakuya04_cooldown_reset = TRUE
	else
		caster.sakuya04_cooldown_reset = FALSE
	end
end