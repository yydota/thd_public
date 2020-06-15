ABILITY_CIRNO_ICEBOUND_UNIT_NAME="npc_thdots_unit_cirno_icebound"
ABILITY_CIRNO_ICEBOUND_LIFETIME=11
ABILITY_CIRNO_ICEBOUND_HITBOX=250
ABILITY_CIRNO_ICEBOUND_DAMAGE_RANGE=250
ABILITY_CIRNO_ICEBOUND_BREAK_DELAY=0.2
ABILITY_CIRNO_ICEBOUND_GC_INTERVAL=0.03

g_cirno_icebound_set={}
function CirnoAbilityGC()
	local time_now=GameRules:GetGameTime()
	for _,ib in pairs(g_cirno_icebound_set) do
		if not ib.time_to_remove or time_now>=ib.time_to_remove then
			CirnoRemoveIcebound(ib)
		end
	end
end

function CirnoRemoveIcebound(icebound)
	if icebound then
		if icebound.effect_index then
			ParticleManager:DestroyParticle(icebound.effect_index,true)
		end
		g_cirno_icebound_set[icebound]=nil
	end
end

function CirnoFindIceboundsInRadius(pos,radius)
	local icebounds={}
	for _,ib in pairs(g_cirno_icebound_set) do
		if (ib.pos-pos):Length2D()<=radius and not ib.ready_to_break then
			table.insert(icebounds,ib)
		end
	end
	table.sort(icebounds,
		function (a,b)
			return (a.pos-pos):Length2D()<(b.pos-pos):Length2D()
		end)
	return icebounds
end

function CirnoCreateIcebound(caster,pos,lifetime)
	if not caster then return nil end
	pos = pos or caster:GetOrigin()
	lifetime = lifetime or ABILITY_CIRNO_ICEBOUND_LIFETIME
	local icebound={}
	icebound.pos=pos
	icebound.time_to_remove=GameRules:GetGameTime()+lifetime
	icebound.ready_to_break=false
	local effect_index=ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_ice_wall_snow_ground.vpcf", PATTACH_CUSTOMORIGIN, unit)
	ParticleManager:SetParticleControl(effect_index, 0, pos)
	icebound.effect_index=effect_index

	g_cirno_icebound_set[icebound]=icebound

	local game_ent = GameRules:GetGameModeEntity()
	if not game_ent.started_cirno_gc then
		game_ent.started_cirno_gc=true
		game_ent:SetContextThink(
			"cirno_ability_gc",
			function ()
				if GameRules:IsGamePaused() then return 0.03 end
				CirnoAbilityGC()
				return ABILITY_CIRNO_ICEBOUND_GC_INTERVAL
			end,0)
	end
	return icebound
end

--[[
icebound	-- table icebound
OnBreak		-- function OnBreak(caster,icebound,count,nearby_icebound)
count		-- tracert count  (do not input)
]]
function CirnoBreakIcebound(icebound,OnBreak,count)
	--print("CirnoBreakIcebound count="..tostring(count))
	if not icebound then return end
	count = count or 0

	icebound.ready_to_break=true
	local icebounds=CirnoFindIceboundsInRadius(icebound.pos,ABILITY_CIRNO_ICEBOUND_HITBOX)

	if OnBreak then
		--OnBreak(icebound,count,nearby_icebounds)
		OnBreak(icebound,count,icebounds)
	end

	local time_now=GameRules:GetGameTime()
	for _,ib in pairs(icebounds) do
		ib.ready_to_break=true
		Timer.Loop (tostring(ib).."ready_to_break") (
			ABILITY_CIRNO_ICEBOUND_BREAK_DELAY,1,
			function ()
				CirnoBreakIcebound(ib,OnBreak,count+1)
			end
			)
	end
	CirnoRemoveIcebound(icebound)
end

function CirnoBreakIceboundsInRadius(caster,pos,radius)
	local icebound_cnt=0

	local AbilityCirno02=caster:FindAbilityByName("ability_thdots_cirno02")
	local cirno02_StunEnemyDuration=0
	local cirno02_damage_table
	if AbilityCirno02 then 
		cirno02_StunEnemyDuration=AbilityCirno02:GetLevelSpecialValueFor("stun_enemy_duration",AbilityCirno02:GetLevel())
		cirno02_damage_table={
			victim=nil, 
			attacker=caster, 
			damage=AbilityCirno02:GetAbilityDamage(),
			damage_type=AbilityCirno02:GetAbilityDamageType(),
		}
	end

	local AbilityCirno04=caster:FindAbilityByName("ability_thdots_cirno04")
	local cirno04_freeze_damage_table
	if AbilityCirno04 then
		cirno04_freeze_damage_table={
			victim=nil, 
			attacker=caster, 
			damage=AbilityCirno04:GetLevelSpecialValueFor("freeze_damage",AbilityCirno04:GetLevel()),
			damage_type=AbilityCirno04:GetAbilityDamageType(),
		}
	end

	local icebounds=CirnoFindIceboundsInRadius(caster:GetAbsOrigin(),ABILITY_CIRNO_ICEBOUND_HITBOX)
	--print("#icebounds="..tostring(#icebounds))

	local LstDmgCnt={}
	for _,ib in pairs(icebounds) do
		if not ib.ready_to_break then
			icebound_cnt=icebound_cnt+1
			CirnoBreakIcebound(
				ib,
				function (icebound,count,nearby_icebounds) 
					--print(tostring(#nearby_icebounds))
					local is_stun_unit=(#nearby_icebounds==0)
					local enemies = FindUnitsInRadius(
						caster:GetTeamNumber(),
						icebound.pos,
						nil,
						ABILITY_CIRNO_ICEBOUND_DAMAGE_RANGE,
						DOTA_UNIT_TARGET_TEAM_ENEMY,
						DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
						DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
						FIND_ANY_ORDER,--[[FIND_CLOSEST,]]
						false)
					for _,v in pairs(enemies) do
						if not v:IsMagicImmune() or v:HasModifier("modifier_thdots_crino04_freeze") then
							if AbilityCirno04 and v:HasModifier("modifier_thdots_crino04_freeze") then
								v:RemoveModifierByName("modifier_thdots_crino04_freeze")
								v:RemoveModifierByName("modifier_thdots_crino04_slowdown")
								cirno04_freeze_damage_table.victim=v
								ParticleManager:DestroyParticleSystem(v.ability_cirno_04_effect_index,true)
								UnitDamageTarget(cirno04_freeze_damage_table)
							end

							if AbilityCirno02 then
								if not LstDmgCnt[v] or LstDmgCnt[v]<count then
									LstDmgCnt[v]=count
									cirno02_damage_table.victim=v
									UnitDamageTarget(cirno02_damage_table)
								end
								if is_stun_unit then
									UtilStun:UnitStunTarget(caster,v,cirno02_StunEnemyDuration)
								end
							end
						end
					end
					if caster.ability_cirno_04_effect_index_table~=nil then
						for k,v in pairs(caster.ability_cirno_04_effect_index_table) do
							ParticleManager:DestroyParticleSystem(v,true)	
						end
					end
					local effectOrigin = icebound.pos
					local effectIndex = ParticleManager:CreateParticle("particles/heroes/cirno/ability_cirno_02.vpcf", PATTACH_CUSTOMORIGIN, nil)
					ParticleManager:SetParticleControl(effectIndex, 0, effectOrigin)
					ParticleManager:SetParticleControl(effectIndex, 2, effectOrigin)
					caster:EmitSound("Hero_Crystal.CrystalNova.Yulsaria")
				end
			)
		end
	end
	print("(icebound_cnt))"..tostring(icebound_cnt))
	return icebound_cnt
end

function OnCirno01SpellStart(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	local Targets=FindUnitsInRadius(
		Caster:GetTeamNumber(),
		Caster:GetAbsOrigin(),
		nil,
		keys.radius,
		Ability:GetAbilityTargetTeam(),
		Ability:GetAbilityTargetType(),
		Ability:GetAbilityTargetFlags(),
		FIND_ANY_ORDER,--[[FIND_CLOSEST,]]
		false)
	local damage_table={
		victim=nil, 
		attacker=Caster, 
		damage=Ability:GetAbilityDamage(),
		damage_type=Ability:GetAbilityDamageType(),
	}
	for _,v in pairs(Targets) do
		damage_table.victim=v
		UnitDamageTarget(damage_table)

		Ability:ApplyDataDrivenModifier(Caster, v, keys.debuff_name, {})
	end
	CirnoCreateIcebound(Caster)
	local effectOrigin = Caster:GetOrigin()
	local effectIndex = ParticleManager:CreateParticle("particles/heroes/cirno/ability_cirno_02.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(effectIndex, 0, effectOrigin)
	ParticleManager:SetParticleControl(effectIndex, 2, effectOrigin)
end

function OnCirno02SpellStart(keys)
	if (CirnoBreakIceboundsInRadius(keys.caster, keys.caster:GetOrigin(), keys.radius)==0) then
		UtilStun:UnitStunTarget(keys.caster,keys.caster,keys.stun_self_duration)
	end
end

function OnCirno03SpellStart(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	local TargetPoint=keys.target_points[1]
	local VecStart=Caster:GetOrigin()
	local Direction=(TargetPoint-VecStart):Normalized()
	local TickInterval=keys.tick_interval
	local MovePerTick=keys.speed*TickInterval
	local tick=0
	local tick_max=keys.length/MovePerTick

	local damage_table={
		victim=nil, 
		attacker=Caster, 
		damage=Ability:GetAbilityDamage(),
		damage_type=Ability:GetAbilityDamageType(),
	}

	local HasDamaged={}
	Caster:SetContextThink(
		"cirno03_in_spelling",
		function () 
			if GameRules:IsGamePaused() then return 0.03 end
			local VecPos=VecStart+Direction*MovePerTick*tick
			local enemies = FindUnitsInRadius(
						Caster:GetTeamNumber(),
						VecPos,
						nil,
						keys.width,
						Ability:GetAbilityTargetTeam(),
						Ability:GetAbilityTargetType(),
						Ability:GetAbilityTargetFlags(),
						FIND_ANY_ORDER,--[[FIND_CLOSEST,]]
						false)
			for _,v in pairs(enemies) do
				if not HasDamaged[v] then
					HasDamaged[v]=true
					damage_table.victim=v
					UnitDamageTarget(damage_table)

					Ability:ApplyDataDrivenModifier(Caster, v, keys.debuff_name, {})
				end
			end

			CirnoCreateIcebound(Caster,VecPos)

			local effectOrigin = VecPos
			local effectIndex = ParticleManager:CreateParticle("particles/heroes/cirno/ability_cirno_02.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(effectIndex, 0, effectOrigin)
			ParticleManager:SetParticleControl(effectIndex, 2, effectOrigin)
			Caster:EmitSound("Hero_Crystal.CrystalNova")

			tick=tick+1
			if tick>=tick_max then return nil end
			return TickInterval
		end,0)
end

function OnCirno04SpellStart(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	local TickInterval=keys.tick_interval
	local tick=0
	local tick_max=keys.duration/TickInterval
	local tick_persec=math.floor(1/TickInterval)
	if tick_persec==0 then tick_persec=1 end

	local AOE_damage_table={
		victim=nil, 
		attacker=Caster, 
		damage=Ability:GetAbilityDamage()*TickInterval,
		damage_type=Ability:GetAbilityDamageType(),
	}

	local effectIndex = ParticleManager:CreateParticle("particles/heroes/cirno/ability_cirno_04.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControlEnt(effectIndex , 0, Caster, 5, "follow_origin", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effectIndex , 3, Caster, 5, "follow_origin", Vector(0,0,0), true)
	Caster.ability_cirno_04_caster_effect_index = effectIndex

	Caster:SetContextThink(
		"cirno04_in_spelling",
		function () 
			if GameRules:IsGamePaused() then return 0.03 end
			local bApplyModifier=(tick>0 and tick%tick_persec==0)
			local left_time=(tick_max-tick)*TickInterval
			local enemies = FindUnitsInRadius(
						Caster:GetTeamNumber(),
						Caster:GetOrigin(),
						nil,
						keys.radius,
						Ability:GetAbilityTargetTeam(),
						Ability:GetAbilityTargetType(),
						Ability:GetAbilityTargetFlags(),
						FIND_ANY_ORDER,--[[FIND_CLOSEST,]]
						false)
			for _,v in pairs(enemies) do
				AOE_damage_table.victim=v
				UnitDamageTarget(AOE_damage_table)

				if bApplyModifier then
					if not v:HasModifier(keys.debuff_freeze_name) then
						local new_stack=v:GetModifierStackCount(keys.debuff_slowdown_name,Caster)+1
						if v:HasModifier(keys.debuff_slowdown_name) then
							Caster:RemoveModifierByName(keys.debuff_slowdown_name)
						end
						Ability:ApplyDataDrivenModifier(Caster, v, keys.debuff_slowdown_name, {})
						v:SetModifierStackCount(keys.debuff_slowdown_name, Caster, new_stack)

						if new_stack>=keys.stack_slow_max then
							Ability:ApplyDataDrivenModifier(Caster, v, keys.debuff_freeze_name, {duration=left_time})
							Caster:EmitSound("Ability.PowershotPull.Stinger")
							local effectOrigin = v:GetOrigin()
							local effectIndex = ParticleManager:CreateParticle("particles/heroes/cirno/ability_cirno_04_buff.vpcf", PATTACH_CUSTOMORIGIN, v)
							ParticleManager:SetParticleControl(effectIndex, 0, effectOrigin + Vector(0,0,175))		
							ParticleManager:SetParticleControl(effectIndex, 3, effectOrigin + Vector(0,0,175))
							v.ability_cirno_04_effect_index = effectIndex
							Caster.ability_cirno_04_effect_index_table = {}
							table.insert(Caster.ability_cirno_04_effect_index_table,effectIndex)
						end
					end
				end
			end

			CirnoCreateIcebound(Caster,Caster:GetOrigin())

			tick=tick+1
			if tick>=tick_max or not Caster:IsAlive() then 
				CirnoBreakIceboundsInRadius(Caster,Caster:GetOrigin(),keys.radius)
				UtilStun:UnitStunTarget(Caster,Caster,keys.stun_self_duration)
				ParticleManager:DestroyParticleSystem(Caster.ability_cirno_04_caster_effect_index,true)
				return nil 
			end
			return TickInterval
		end,0)
end

function OnCrino02ActionDestroy(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_5)
end

function OnCrino04IconDestroy(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_cirno04_bonus_action", nil)
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_2)
end

function OnCrino04ActionDestroy(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	caster:Stop()
end

function Cirnowanbaochui(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local casterName = caster:GetClassname()
	if (caster:IsRealHero() and target:IsHero()==true and caster:HasModifier("modifier_item_wanbaochui") and casterName == "npc_dota_hero_axe") then
		local modifier = target:FindModifierByName("Cirno_wanbaochui_debuff")
		if modifier == nil then
			ability:ApplyDataDrivenModifier(caster,target,"Cirno_wanbaochui_debuff",{duration=59})
			modifier = target:FindModifierByName("Cirno_wanbaochui_debuff")
			modifier:IncrementStackCount()
			
		else
				modifier:IncrementStackCount()
				modifier:SetDuration(59,true)	
				ability:ApplyDataDrivenModifier(caster,target,"Cirno_wanbaochui_debuff_ex",{duration=0.03})	
		end

		if caster:GetIntellect()<target:GetIntellect() then
			local dealdamage=target:GetIntellect()-caster:GetIntellect()		
			local damage_table = {
					ability = keys.ability,
					victim = target,
					attacker = caster,
					damage = dealdamage,
					damage_type = keys.ability:GetAbilityDamageType(), 
					damage_flags = 1
			}
			UnitDamageTarget(damage_table)	
			SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_SPELL_DAMAGE,target,dealdamage,nil)
		else
			UtilStun:UnitStunTarget(caster,target,1.9)
			target:RemoveModifierByName("Cirno_wanbaochui_debuff")
		end
	end
end
    
			