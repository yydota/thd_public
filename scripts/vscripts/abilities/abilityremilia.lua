
function OnRemilia01SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_warlock_1"))
	local vecCaster = caster:GetOrigin()
	keys.ability.ability_remilia01_vecCaster = vecCaster
end

function OnRemilia01SpellHit(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	local vecTarget = target:GetOrigin() + Vector(0,0,64)
	local dealdamage = keys.ability:GetAbilityDamage()
	local damage_table = {
			ability = keys.ability,
			victim = target,
			attacker = caster,
			damage = dealdamage,
			damage_type = keys.ability:GetAbilityDamageType(), 
	    	amage_flags = 0
	}
	UnitDamageTarget(damage_table)	
	local spellPoint = keys.ability.ability_remilia01_vecCaster
	local dis = GetDistanceBetweenTwoVec2D(spellPoint,target:GetOrigin())

	UtilStun:UnitStunTarget(caster,target,keys.StunDuration)
	
	local effectIndex = ParticleManager:CreateParticle(
		"particles/heroes/remilia/ability_remilia_01_explosion.vpcf", 
		PATTACH_CUSTOMORIGIN, 
		target)
	ParticleManager:SetParticleControl(effectIndex, 0, vecTarget)
	ParticleManager:SetParticleControl(effectIndex, 3, vecTarget)
	ParticleManager:SetParticleControl(effectIndex, 5, vecTarget)
	ParticleManager:DestroyParticleSystem(effectIndex,false)
end

function OnRemilia02SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	caster.ability_remilia_02_time_count = 0
	caster.ability_remilia_02_jump_high = 0
	caster.ability_remilia_02_jump_distance = 0
	caster.ability_remilia_02_forward_vector = caster:GetForwardVector()
	local effectIndex = ParticleManager:CreateParticleForTeam(
		"particles/heroes/remilia/ability_remilia_02.vpcf", 
		PATTACH_CUSTOMORIGIN, 
		caster,
		caster:GetTeam())
	ParticleManager:SetParticleControl(effectIndex, 0, caster:GetOrigin())
	caster.ability_remilia_02_effectIndex = effectIndex
end

function OnRemilia02SpellThink(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	caster.ability_remilia_02_time_count = caster.ability_remilia_02_time_count + 0.01
	local moveDistance = 3000 * caster.ability_remilia_02_time_count
	local vecForward = caster.ability_remilia_02_forward_vector
	local effectOrigin = caster:GetOrigin() + Vector(vecForward.x*moveDistance,vecForward.y*moveDistance,0)
	ParticleManager:SetParticleControl(caster.ability_remilia_02_effectIndex, 0, effectOrigin)
end

function OnRemilia02SpellRemove(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local moveDistance = 3000 * caster.ability_remilia_02_time_count
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_Remilia02_action", nil)

	caster:SetContextThink("ability_remilia_02_jump_timer", 
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			if(caster.ability_remilia_02_jump_distance < moveDistance)then
				if(caster.ability_remilia_02_jump_distance <= moveDistance/2)then
					caster.ability_remilia_02_jump_high = 30
				else
					caster.ability_remilia_02_jump_high = -30
				end
				caster.ability_remilia_02_jump_distance = caster.ability_remilia_02_jump_distance + keys.MoveSpeed/20
				local vecCaster = caster:GetOrigin()
				local forwardVec = caster.ability_remilia_02_forward_vector
				local vec = vecCaster + forwardVec*keys.MoveSpeed/20 + Vector(0,0,caster.ability_remilia_02_jump_high)
				caster:SetOrigin(vec)
				return 0.05
			else
				caster:SetContextThink("ability_remilia_02_delay",
					function () 
						if GameRules:IsGamePaused() then return 0.03 end
						caster:RemoveModifierByName("modifier_thdots_Remilia02_action")
						ParticleManager:DestroyParticleSystem(caster.ability_remilia_02_effectIndex,true)
						caster.ability_remilia_02_jump_distance = 0
						caster.ability_remilia_02_jump_high = 0
						local vecCaster = caster:GetOrigin()
						caster:SetOrigin(Vector(vecCaster.x,vecCaster.y,GetGroundPosition(vecCaster,nil).z))
						OnRemilia02SpellRemoveStage2(keys,moveDistance)
						return nil
					end,
				0.1)
				return nil
			end 
		end, 
	0.05)
end

function OnRemilia02SpellRemoveStage2(keys,moveDistance)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local radius = 120
	if caster:HasModifier("modifier_item_wanbaochui") then
		radius = 240
	end


	local targets = FindUnitsInRadius(
		   caster:GetTeam(),		
		   caster:GetOrigin(),		
		   nil,					
		   radius,		
		   keys.ability:GetAbilityTargetTeam(),
		   keys.ability:GetAbilityTargetType(),
		   keys.ability:GetAbilityTargetFlags(), 
		   FIND_CLOSEST,
		   false
	)
	local target = nil

	for _,v in pairs(targets) do
		if(v~=nil) and v:HasModifier("modifier_thdots_yasaka04_buff")==false then
			target = v
		end
	end

	if(target ~= nil)then
		local stuntime = moveDistance/keys.MoveSpeed
		UtilStun:UnitStunTarget(caster,target,stuntime)
		if caster:HasModifier("modifier_item_wanbaochui") then
				local damage_table = {
					ability = keys.ability,
					victim = target,
					attacker = caster,
					damage = 400,
					damage_type = keys.ability:GetAbilityDamageType(), 
					damage_flags = keys.ability:GetAbilityTargetFlags()
			}
		    UnitDamageTarget(damage_table)
		end

	end

	if(moveDistance > 0)then
		caster:SetContextThink("ability_remilia_02_jump_timer_stage2_action", 
			function ()
				if GameRules:IsGamePaused() then return 0.03 end
				if(caster.ability_remilia_02_time_count ~= 0)then
					keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_Remilia02_action_stage2", nil)
				end
			end,
		0.2)
	end

	caster:SetContextThink("ability_remilia_02_jump_timer_stage2", 
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			if(caster.ability_remilia_02_jump_distance < moveDistance and (caster:HasModifier("modifier_thdots_Remilia03_think_interval")==false) )then
				if(caster.ability_remilia_02_jump_distance <= moveDistance/2)then
					caster.ability_remilia_02_jump_high = 30
				else
					caster.ability_remilia_02_jump_high = -30
				end
				caster.ability_remilia_02_jump_high = caster.ability_remilia_02_jump_high + 10
				caster.ability_remilia_02_jump_distance = caster.ability_remilia_02_jump_distance + keys.MoveSpeed/20
				local vecCaster = caster:GetOrigin()
				caster:SetForwardVector(caster.ability_remilia_02_forward_vector)
				local forwardVec = caster.ability_remilia_02_forward_vector
				local vec = vecCaster - forwardVec*keys.MoveSpeed/20 + Vector(0,0,caster.ability_remilia_02_jump_high)
				caster:SetOrigin(vec)
				if(target~=nil)then
					target:SetOrigin(vec)
				end
				return 0.05
			else
				SetTargetToTraversable(caster)
				if(target~=nil)then
					SetTargetToTraversable(target)
				end
				local vecCaster = caster:GetOrigin()
				caster:SetOrigin(Vector(vecCaster.x,vecCaster.y,GetGroundPosition(vecCaster,nil).z))
				caster.ability_remilia_02_time_count = 0
				caster:RemoveModifierByName("modifier_thdots_Remilia02_action_stage2")
				return nil
			end 
		end, 
	0.05)
end

function OnRemilia03Start(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	
	local effectIndex = ParticleManager:CreateParticle(
		"particles/econ/courier/courier_trail_04/courier_trail_04_bats.vpcf", 
		PATTACH_CUSTOMORIGIN, 
		nil)
	ParticleManager:SetParticleControl(effectIndex, 0, Caster:GetOrigin()+Vector(0,0,64))
	ParticleManager:SetParticleControl(effectIndex, 1, Caster:GetOrigin())
	ParticleManager:SetParticleControl(effectIndex, 3, Caster:GetOrigin()+Vector(0,0,64))
	ParticleManager:DestroyParticleSystemTime(effectIndex,1)
	Caster:SetContextThink("ability_remilia_03_start_action", 
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			Caster:AddNoDraw()
			return nil
		end,
	0.3)
end
function OnRemilia03End(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	Caster:RemoveNoDraw()
	local effectIndex = ParticleManager:CreateParticle(
		"particles/units/heroes/hero_batrider/batrider_firefly_startflash.vpcf", 
		PATTACH_CUSTOMORIGIN, 
		Caster)
	ParticleManager:SetParticleControl(effectIndex, 0, Caster:GetOrigin())
	ParticleManager:DestroyParticleSystemTime(effectIndex,1)
end

function OnRemilia03Think(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	local Targets=keys.target_entities
	local Damage=keys.DamagePerSec*0.2
	
	for _,unit in pairs(Targets) do
		if unit and unit:IsAlive() then
			UnitDamageTarget{
				ability = keys.ability,
				victim = unit,
				attacker = Caster,
				damage = Damage,
				damage_type = keys.ability:GetAbilityDamageType()
			}
		end
	end
end

function OnRemilia04Start(keys)
	local Caster=keys.caster
	local effectIndex = ParticleManager:CreateParticle(
		"particles/heroes/remilia/ability_remilia_04_laser.vpcf", 
		PATTACH_CUSTOMORIGIN, 
		Caster)
	ParticleManager:SetParticleControl(effectIndex, 0, Caster:GetOrigin()+Vector(0,0,32))
	ParticleManager:SetParticleControl(effectIndex, 1, Caster:GetOrigin()+Vector(0,-500,128))
	ParticleManager:SetParticleControl(effectIndex, 2, Caster:GetOrigin()+Vector(0,500,128))
	ParticleManager:SetParticleControl(effectIndex, 3, Caster:GetOrigin()+Vector(-500,0,128))
	ParticleManager:SetParticleControl(effectIndex, 4, Caster:GetOrigin()+Vector(500,0,128))
	Caster.ability_remilia_04_effectIndex = effectIndex
	local effectIndexSmoke = ParticleManager:CreateParticle(
		"particles/heroes/remilia/ability_remilia_04_laser_rocket.vpcf", 
		PATTACH_CUSTOMORIGIN, 
	Caster)
	ParticleManager:SetParticleControlEnt(effectIndexSmoke , 0, Caster, 5, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControl(effectIndexSmoke, 1, Vector(math.cos(math.pi/2),math.sin(math.pi/2),0))
	ParticleManager:SetParticleControl(effectIndexSmoke, 2, Vector(math.cos(math.pi),math.sin(math.pi),0))
	ParticleManager:SetParticleControl(effectIndexSmoke, 3, Vector(math.cos(math.pi*3/2),math.sin(math.pi*3/2),0))
	ParticleManager:SetParticleControl(effectIndexSmoke, 4, Vector(math.cos(math.pi*4/2),math.sin(math.pi*4/2),0))
	Caster.ability_remilia_04_effectIndexSmoke = effectIndexSmoke
	Caster:EmitSound("Hero_Phoenix.SunRay.Loop")
end

function OnRemilia04Remove(keys)
	local Caster=keys.caster
	ParticleManager:DestroyParticleSystem(Caster.ability_remilia_04_effectIndex,true)
	ParticleManager:DestroyParticleSystem(Caster.ability_remilia_04_effectIndexSmoke,true)
	Caster:StopSound("Hero_Phoenix.SunRay.Loop")
end

function OnRemilia04Think(keys)
	local Caster=keys.caster
	local Ability=keys.ability
	local CrossRadius=keys.CrossRadius
	local CrossWidth=keys.CrossWidth/2
	local Damage=keys.DamagePerSec*0.5/10
	local ManaCost=keys.ManaCostPerSec*0.5/10
	local LifestealPercent=keys.LifestealPercent*0.01
	
	if Caster:GetMana()<ManaCost then
		if Ability:GetToggleState() then
			Ability:ToggleAbility()
		end
		if Caster:HasModifier("modifier_thdots_Remilia04_think_interval") then
			Caster:RemoveModifierByName("modifier_thdots_Remilia04_think_interval")
			ParticleManager:DestroyParticleSystem(Caster.ability_remilia_04_effectIndex,true)
		end
		return
	end
	Caster:ReduceMana(ManaCost)

	ParticleManager:SetParticleControl(Caster.ability_remilia_04_effectIndex , 0, Caster:GetOrigin()+Vector(0,0,32))
	ParticleManager:SetParticleControl(Caster.ability_remilia_04_effectIndex, 1, Caster:GetOrigin()+Vector(0,-500,128))
	ParticleManager:SetParticleControl(Caster.ability_remilia_04_effectIndex, 2, Caster:GetOrigin()+Vector(0,500,128))
	ParticleManager:SetParticleControl(Caster.ability_remilia_04_effectIndex, 3, Caster:GetOrigin()+Vector(-500,0,128))
	ParticleManager:SetParticleControl(Caster.ability_remilia_04_effectIndex, 4, Caster:GetOrigin()+Vector(500,0,128))
	
	local CasterPos=Caster:GetAbsOrigin()
	local targets = FindUnitsInRadius(
		   Caster:GetTeam(),		
		   Caster:GetOrigin(),		
		   nil,					
		   CrossRadius,		
		   Ability:GetAbilityTargetTeam(),
		   Ability:GetAbilityTargetType(),
		   Ability:GetAbilityTargetFlags(), 
		   FIND_ANY_ORDER,
		   false
	)
	
	local DamageAmount=0
	for _,unit in pairs(targets) do
		if unit and unit:IsAlive() then
			if (math.abs(unit:GetAbsOrigin().x-CasterPos.x)<=CrossWidth) or (math.abs(unit:GetAbsOrigin().y-CasterPos.y)<=CrossWidth) then
				local DamageDone=UnitDamageTarget{
						ability = keys.ability,
						victim = unit,
						attacker = Caster,
						damage = Damage,
						damage_type = keys.ability:GetAbilityDamageType()
				}
				if DamageDone and DamageDone>0 then
					DamageAmount=DamageAmount+DamageDone
				end
			end
		end
	end
	
	Caster:Heal(DamageAmount*LifestealPercent,Caster)
end
