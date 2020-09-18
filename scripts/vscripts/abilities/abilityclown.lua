
function OnClown01SpellStart(keys)
	
	local Ability=keys.ability
	local Caster=keys.caster
	local speed = keys.speed
	if FindTelentValue(Caster,"special_bonus_unique_doom_3") == 1 then
		speed = speed + 900
	end

	local TargetPoint=keys.target_points[1]
	local VecStart=Caster:GetOrigin()
	local Direction=(TargetPoint-VecStart):Normalized()
	local TickInterval=keys.tick_interval
	local MovePerTick = speed * TickInterval
	local tick=0
	local tick_max=GetDistanceBetweenTwoVec2D(Caster:GetOrigin(),TargetPoint)/MovePerTick
	local AttractionSpeed = keys.AttractionSpeed
	if Caster:HasModifier("modifier_item_wanbaochui") then
		AttractionSpeed = keys.AttractionSpeed*3
	end
	local pointRad = GetRadBetweenTwoVec2D(Caster:GetOrigin(),TargetPoint)
	local forwardVec = Vector( math.cos(pointRad) * speed , math.sin(pointRad) * speed , 0 )

	local projectileTable = {
		Ability				= keys.ability,
		EffectName			= "particles/heroes/clown/clown01.vpcf",
		vSpawnOrigin		= Caster:GetOrigin() + Vector(0,0,128),
		fDistance			= GetDistanceBetweenTwoVec2D(Caster:GetOrigin(),TargetPoint),
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
		AddFOWViewer( Caster:GetTeam(), TargetPoint, keys.radius, keys.Duration, false)
		ProjectileManager:DestroyLinearProjectile(projectileID)
		local effectIndex = ParticleManager:CreateParticle("particles/heroes/clown/clown01end.vpcf", PATTACH_CUSTOMORIGIN, nil)
		local VecPos = Vector(TargetPoint.x,TargetPoint.y,TargetPoint.z+256)
		ParticleManager:SetParticleControl(effectIndex, 0, VecPos)
		local light_effectIndex = ParticleManager:CreateParticle("particles/heroes/clown/clown01_ground_light.vpcf", PATTACH_CUSTOMORIGIN, nil)
		local VecPos = Vector(TargetPoint.x,TargetPoint.y,TargetPoint.z+20)
		ParticleManager:SetParticleControl(light_effectIndex, 0, VecPos)
		
		local time = 0
		local radius=keys.radius
		if Caster:HasModifier("modifier_item_wanbaochui") then
			radius=keys.radius+120
		end
		GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("OnClown01Effect"), 
			function ()
				if GameRules:IsGamePaused() then return 0.03 end
				if time < keys.Duration then
					local enemies = FindUnitsInRadius(
						Caster:GetTeamNumber(),
						TargetPoint,
						nil,
						radius,
						Ability:GetAbilityTargetTeam(),
						Ability:GetAbilityTargetType(),
						Ability:GetAbilityTargetFlags(),
						FIND_CLOSEST,
						false)
					for _,v in pairs(enemies) do							
						local Dis = GetDistanceBetweenTwoVec2D(v:GetOrigin(),TargetPoint)	
						if not v:HasModifier("modifier_thdots_clown01")	then
							Ability:ApplyDataDrivenModifier(Caster, v, "modifier_thdots_clown01", {duration = keys.Duration+0.2})							
						end						
						if v:HasModifier("modifier_thdots_clown01") and v:HasModifier("modifier_thdots_clown01_lock")==false then
							OnClown01SpellMove(v, TargetPoint, AttractionSpeed)
						end
					end
				else
					ParticleManager:DestroyParticleSystem(effectIndex,true)	
					ParticleManager:DestroyParticleSystem(light_effectIndex,true)	
					return nil
				end
				time = time + 0.03
				return 0.03
			end,
		0)		
		
			
	end
	Caster:SetContextThink(
		"clown01_main_loop",
		function () 
			if GameRules:IsGamePaused() then return 0.03 end
			if Ability:IsNull() then 
				OnThinkEnd()
				
				return nil
			end
			tick=tick+1
			if tick >= tick_max then 
				OnThinkEnd()
				
				return nil 
			end
			return TickInterval
		end,0)
	
end

function OnClown01SpellMove(target, targetpoint, AttractionSpeed)
	local Vec=target:GetOrigin()
	Vec = Vector(Vec.x,Vec.y,0)
	targetpoint = Vector(targetpoint.x,targetpoint.y,0)
	local Direction=(targetpoint-Vec):Normalized()
	target:SetForwardVector(Direction)
	FindClearSpaceForUnit(target, Vec + Direction*AttractionSpeed, true)
end

function OnClown02SpellStart(keys)
	local caster=keys.caster
	local target = keys.target
	local Ability=keys.ability
	if is_spell_blocked(target,caster) then return end
	keys.ability:ApplyDataDrivenModifier(caster, target,"modifier_thdots_clown02_target", {Duration = keys.duration})
	local TargetPoint=keys.target:GetOrigin()
	StartSoundEventFromPosition("Hero_Jakiro.LiquidFire", target:GetOrigin())
	caster.target = target
	caster.unit = CreateUnitByName(
		"npc_clown02_dummy_unit"
		,TargetPoint
		,false
		,caster
		,caster
		,caster:GetTeam()
	)
	Ability:ApplyDataDrivenModifier(caster, caster.unit, "modifier_thdots_clown02", {})	
	Ability:ApplyDataDrivenModifier(caster, caster.unit, "modifier_thdots_clown02_move", {})
	caster.effectIndex = ParticleManager:CreateParticle("particles/heroes/clown/clown02.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.unit)
	local time = 0
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("OnClown02End"), 
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			if time >= keys.Duration or target:HasModifier("modifier_thdots_clown02_target")==false then
				OnClown02UnitRemove(caster, caster.effectIndex)
				return nil
			end
			time=time+0.03
			return 0.03
		end,
	0)
end

function OnClown02UnitRemove(caster, effectIndex)
	if caster.unit then 		
		ParticleManager:DestroyParticleSystem(effectIndex,true)			
		caster.unit:RemoveSelf()	
		caster.unit = false	
	end
end

function OnClown02SpellThink(keys)
	local caster=keys.caster
	local Ability=keys.ability
	local target = keys.target
	local TargetPoint=keys.target:GetOrigin()
	local FinalTarget={}
	local AllTarget = FindUnitsInRadius(
						caster:GetTeam(),
						TargetPoint,
						nil,
						keys.OutRadius,
						DOTA_UNIT_TARGET_TEAM_ENEMY,
						Ability:GetAbilityTargetType(),
						Ability:GetAbilityTargetFlags(),
						FIND_CLOSEST,
						false)
	--print("AllTarget",unpack(AllTarget))
	local RemoveTarget = FindUnitsInRadius(
						caster:GetTeam(),
						TargetPoint,
						nil,
						keys.InRadius,
						DOTA_UNIT_TARGET_TEAM_ENEMY,
						Ability:GetAbilityTargetType(),
						Ability:GetAbilityTargetFlags(),
						FIND_CLOSEST,
						false)
	--print("RemoveTarget",unpack(RemoveTarget))
	for i = 1, #AllTarget do
		if AllTarget[i] ~= RemoveTarget[i] then
			for j = i, #AllTarget do
				table.insert(FinalTarget,AllTarget[j])
			end
			for _,v in pairs(FinalTarget) do				
				local damage_table = {
					ability = Ability,
					victim = v,
					attacker = caster,
					damage = keys.Damage/5,
					damage_type = Ability:GetAbilityDamageType(), 
					damage_flags = 0
				}
				UnitDamageTarget(damage_table)
			end
			break	
		end
	end
	--print("FinalTarget",unpack(FinalTarget))
end

function OnClown02SpellUnitMove(keys)
	local caster=keys.caster
	if caster.unit == false then return end
	local TargetPos = caster.target:GetAbsOrigin()
	local Pos =  caster.unit:GetAbsOrigin()
	local Direction = (Pos - TargetPos):Normalized()
	local Distance = GetDistanceBetweenTwoVec2D(TargetPos,Pos)
	local MoveRate = Distance/300
	if MoveRate > 1 then 
		MoveRate = 1
	end
	local Speed = 320*0.03
	local Time = keys.StunDuration
	if FindTelentValue(caster,"special_bonus_unique_doom_1") == 1 then
		Time = Time + 2
	end	
	caster.unit:SetAbsOrigin(Pos - Direction*Speed*MoveRate)
	if Distance>=400 and Distance <= 1800 then
		if caster.target:GetTeam() ~= caster:GetTeam() then
			local damage_table = {
					ability = keys.ability,
					victim = caster.target,
					attacker = caster,
					damage = keys.Damage,
					damage_type = keys.ability:GetAbilityDamageType(), 
					damage_flags = 0
				}
			UnitDamageTarget(damage_table)
			UtilStun:UnitStunTarget(caster, caster.target, Time)
			StartSoundEventFromPosition("Hero_StormSpirit.StaticRemnantExplode", TargetPos)			
		end
		OnClown02UnitRemove(caster, caster.effectIndex)
	elseif Distance > 1800 then
		OnClown02UnitRemove(caster, caster.effectIndex)
	end
end

function OnClown03Damage(keys)
	local caster=keys.caster
	local target=keys.target
	if is_spell_blocked(target) then return end
	if target:IsBuilding() then return end
	local deal_damage = target:GetMaxHealth()*keys.Damage*0.01 + keys.BaseDamage
	if FindTelentValue(caster,"special_bonus_unique_doom_4") == 1 then
		deal_damage = deal_damage * 1.5
	end
	if caster:GetUnitName() == "npc_dota_hero_doom_bringer" then
		local clown03_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_infernal_blade.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(clown03_effect, 0, target:GetAbsOrigin() )
		ParticleManager:ReleaseParticleIndex(clown03_effect)
	end
	local targets = FindUnitsInRadius(
						caster:GetTeam(),
						target:GetOrigin(),
						nil,
						keys.Radius,
						DOTA_UNIT_TARGET_TEAM_ENEMY,
						keys.ability:GetAbilityTargetType(),
						keys.ability:GetAbilityTargetFlags(),
						FIND_CLOSEST,
						false)
	for _,v in pairs(targets) do
		local damage_table = {
			ability = keys.ability,
			victim = v,
			attacker = caster,
			damage = deal_damage,
			damage_type = keys.ability:GetAbilityDamageType(), 
			damage_flags = keys.ability:GetAbilityTargetFlags()
		}
		UnitDamageTarget(damage_table)
		UtilStun:UnitStunTarget(caster, v, keys.StunDuration)
	end
end

function OnClown03Passive(keys)
	local target = keys.target
	local caster = keys.caster
	if target:IsBuilding() then return end	
	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_thdots_clown03_passive_debuff", {})	
end

function OnClown03SpellThink(keys)
	local caster = keys.caster
	local target = keys.target
	local damage_table = {
					ability = keys.ability,
					victim = target,
					attacker = caster,
					damage = keys.ExDamage * 0.5,
					damage_type = keys.ability:GetAbilityDamageType(), 
					damage_flags = 0
				}
	UnitDamageTarget(damage_table)	
end

function OnClown04SpellStart(keys)
	local caster = keys.caster
	local TargetPoint=keys.target_points[1]
	caster:EmitSound("Voice_Thdots_Clownpiece.AbilityClownpiece04")
	local effectIndex = ParticleManager:CreateParticle("particles/heroes/clown/clown04.vpcf", PATTACH_CUSTOMORIGIN, nil)
	--local VecPos = Vector(TargetPoint.x,TargetPoint.y,TargetPoint.z)
	ParticleManager:SetParticleControl(effectIndex, 0, TargetPoint)
	ParticleManager:SetParticleControl(effectIndex, 1, TargetPoint)	
	local effectIndex02 = ParticleManager:CreateParticle("particles/dark_smoke_test.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(effectIndex02, 0, TargetPoint)
	local time = 0
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("OnClown04SpellStart"), 
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			if time >= keys.Duration then
				ParticleManager:DestroyParticleSystem(effectIndex,true)	
				ParticleManager:DestroyParticleSystem(effectIndex02,true)	
				return nil
			end
			time=time+0.03
			return 0.03
		end,
	0)
end

function OnClown04SpellThink(keys)
	local caster = keys.caster
	local target = keys.target
	if target:IsBuilding() then return end
	if target:GetClassname()=="npc_dota_roshan" then return	end
	local damage_table = {
					ability = keys.ability,
					victim = target,
					attacker = caster,
					damage = keys.Damage/2,
					damage_type = keys.ability:GetAbilityDamageType(), 
					damage_flags = 1
				}
	UnitDamageTarget(damage_table)	
end

function OnClown04SpentMana( event )
	local caster = event.caster
	local target = event.unit -- The unit that spent mana
	local ability = event.ability
	local ward = ability.nether_ward -- Keep track of the ward to attach the particle
	local AbilityDamageType = ability:GetAbilityDamageType()

	local mana_spent
	if target.OldMana then
		mana_spent = target.OldMana - target:GetMana()
	end

	if mana_spent and mana_spent > 0 then
		local mana_multiplier = ability:GetLevelSpecialValueFor("mana_multiplier", ability:GetLevel() - 1 )
		if FindTelentValue(caster,"special_bonus_unique_doom_2") == 1 then
			mana_multiplier = mana_multiplier + 0.5
		end
		local zap_damage = mana_spent * mana_multiplier
		local damage_table = {
					ability = ability,
					victim = target,
					attacker = caster,
					damage = zap_damage,
					damage_type = ability:GetAbilityDamageType(), 
					damage_flags = 0
				}
		UnitDamageTarget(damage_table)
		print("Damage "..zap_damage.." = "..mana_spent.." * "..mana_multiplier)

		local attackName = "particles/units/heroes/hero_pugna/pugna_ward_attack.vpcf" -- There are some light/medium/heavy unused versions
		local attack = ParticleManager:CreateParticle(attackName, PATTACH_ABSORIGIN_FOLLOW, ward)
		ParticleManager:SetParticleControl(attack, 1, target:GetAbsOrigin())

		target:EmitSound("Hero_Pugna.NetherWard.Target")
		caster:EmitSound("Hero_Pugna.NetherWard.Attack")
	end
end

-- Store all the targets mana and initialize the attack counter of the ward
function OnClown04StartCheck( event )
	local target = event.target
	local ability = event.ability
	local attacks_to_destroy = ability:GetLevelSpecialValueFor("attacks_to_destroy", ability:GetLevel() - 1 )
	target.attack_counter = attacks_to_destroy

	-- This is needed to attach the particle attack. Should be a table if we were dealing with possible multiple wards
	ability.nether_ward = target

	--print(target:GetEntityIndex(),target.attack_counter)

	local targets = event.target_entities
	for _,hero in pairs(targets) do
		target.OldMana = target:GetMana()
	end
end

-- Continuously keeps track of all the targets mana
function OnClown04ThinkerCheck( event )
	local targets = event.target_entities
	for _,hero in pairs(targets) do
		hero.OldMana = hero:GetMana()
	end
end