function OnMinamitsu01SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_kunkka_3"))
	local vecCaster = caster:GetOrigin()
	local targetPoint = keys.target_points[1]
	local rad = GetRadBetweenTwoVec2D(vecCaster,targetPoint)
	local vecHook = caster:GetOrigin() + Vector(0,0,88) + caster:GetForwardVector()*105
	local distance = 0
	local speed = keys.speed * 0.03
	local timeCount = 0
	local targettype = nil
	
	if caster:HasModifier("modifier_item_wanbaochui") then	
		targettype=DOTA_UNIT_TARGET_HERO
	else
		targettype=keys.ability:GetAbilityTargetType()
	end

	keys.ability:ApplyDataDrivenModifier( caster, caster, "modifier_minamitsu01_pause", {} )
	caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_1)
    caster:StartGesture(ACT_DOTA_CHANNEL_ABILITY_1)

	local effectIndex = ParticleManager:CreateParticle("particles/heroes/minamitsu/ability_minamitsu_01.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(effectIndex, 0, vecHook)
	ParticleManager:SetParticleControl(effectIndex, 1, vecHook)
	ParticleManager:SetParticleControl(effectIndex, 3, vecHook)
	ParticleManager:SetParticleControl(effectIndex, 4, Vector(2400,0,0))
	ParticleManager:SetParticleControl(effectIndex, 5, Vector(2400,0,0))
	ParticleManager:SetParticleControl(effectIndex, 6, vecHook)

	caster:EmitSound("Hero_Pudge.AttackHookExtend")

	caster:SetContextThink(
		"ability_thdots_minamitsu_01_stage_01",
			function ()
				if GameRules:IsGamePaused() then
					return 0.03
				end
				timeCount = timeCount + 0.03
				distance = distance + speed
				

				
				if distance < keys.range then
					vecHook = vecHook + Vector(math.cos(rad)*speed,math.sin(rad)*speed,0)
					ParticleManager:SetParticleControl(effectIndex, 3, vecHook)

					local targets = FindUnitsInRadius(
					   caster:GetTeam(),		
					   vecHook,	
					   nil,					
					   keys.hitbox_radius,		
					   keys.ability:GetAbilityTargetTeam(),
					   targettype,
					   0,
					   FIND_CLOSEST,
					   false
				    )
				    for k,v in pairs(targets) do
				    	if v == caster or v:GetClassname()=="npc_dota_roshan" or v:GetUnitName()=="ability_minamitsu_04_ship" 
				    		or v:HasModifier("dummy_unit") or v:HasModifier("modifier_item_dragon_star_buff") 
				    		or v:HasModifier("modifier_meirin02_buff") then
				    		table.remove(targets,k)
				    	end
				    end
				    if targets[1] ~= nil then
				    	OnMinamitsu01Back(vecHook,targets[1],rad,distance,effectIndex,keys)
				    	return nil
				    end
				    return 0.03
				else
					OnMinamitsu01Back(vecHook,nil,rad,distance,effectIndex,keys)
					return nil
				end
			end,
		0.03
	)
end

function OnMinamitsu01Back(vecHook,target,rad,distance,effectIndex,keys)
	local caster = keys.caster
	local speed = keys.speed * 0.03
	local finaldamage = 0
	caster:StopSound("Hero_Pudge.AttackHookExtend")
	caster:EmitSound("Hero_Pudge.AttackHookRetract")
	if caster:HasModifier("modifier_item_wanbaochui") then	
		targettype=DOTA_UNIT_TARGET_HERO
		finaldamage = keys.ability:GetAbilityDamage()+200
	else
		targettype=keys.ability:GetAbilityTargetType()
		finaldamage=keys.ability:GetAbilityDamage()
	end

	if target ~= nil then
		caster:EmitSound("Hero_Pudge.AttackHookImpact")
		if target:GetTeam() ~= caster:GetTeam() then
			local damage_table = {
				ability = keys.ability,
				victim = target,
				attacker = caster,
				damage = 	finaldamage,
				damage_type = keys.ability:GetAbilityDamageType(), 
			    damage_flags = keys.ability:GetAbilityTargetFlags()
			}
			UnitDamageTarget(damage_table) 
		end
	end
	caster:SetContextThink(
		"ability_thdots_minamitsu_01_stage_02",
			function ()
				if GameRules:IsGamePaused() then
					return 0.03
				end
				distance = distance - speed
				if distance > 0 then
					vecHook = vecHook - Vector(math.cos(rad)*speed,math.sin(rad)*speed,0)
					ParticleManager:SetParticleControl(effectIndex, 3, vecHook)

					if target == nil then
						local targets = FindUnitsInRadius(
						   caster:GetTeam(),		
						   vecHook,	
						   nil,					
						   keys.hitbox_radius,		
						   keys.ability:GetAbilityTargetTeam(),
						   targettype,
						   0,
						   FIND_CLOSEST,
						   false
					    )
					    for k,v in pairs(targets) do
					    	if v == caster or v:GetClassname()=="npc_dota_roshan" or v:GetUnitName()=="ability_minamitsu_04_ship"
					    	 or v:HasModifier("dummy_unit") or v:HasModifier("modifier_item_dragon_star_buff") 
					    	 or v:HasModifier("modifier_meirin02_buff") then
					    		table.remove(targets,k)
					    	end
					    end
					    if targets[1] ~= nil then
					    	OnMinamitsu01Back(vecHook,targets[1],rad,distance,effectIndex,keys)
					    end
					else
						if target:IsNull() == false then
							target:SetOrigin(vecHook - Vector(0,0,128))
							keys.ability:ApplyDataDrivenModifier( caster, target, "modifier_minamitsu01_pause", {} )
						end
					end
					return 0.03
				else
					if target ~= nil and target:IsNull() == false and target ~= caster then
						target:RemoveModifierByName("modifier_minamitsu01_pause")
						if target:GetTeam() ~= caster:GetTeam() then
							UtilStun:UnitStunTarget( caster, target , 1.2 )
						end
						FindClearSpaceForUnit(target, vecHook - Vector(0,0,128), false)
						if GridNav:CanFindPath(target:GetOrigin(),target:GetOrigin() + Vector(500,500,0)) == false then
							UnitNoPathingfix(caster,target,5.0)
						end
					end
					caster:EmitSound("Hero_Pudge.AttackHookRetract")
					caster:EmitSound("Hero_Pudge.AttackHookRetractStop")
					caster:RemoveModifierByName("modifier_minamitsu01_pause")
					ParticleManager:DestroyParticleSystem(effectIndex,true)
					caster:RemoveGesture(ACT_DOTA_CHANNEL_ABILITY_1)
					caster:StartGesture(ACT_DOTA_CAST_ABILITY_1_END)
					return nil
				end
			end,
		0.03
	)
end

function OnMinamitsu02SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targetPoint = keys.target_points[1]
	local distance = GetDistanceBetweenTwoVec2D(vecCaster,targetPoint)
	local speed = distance * 0.03
	local rad = GetRadBetweenTwoVec2D(vecCaster,targetPoint)
	local vecHook = caster:GetOrigin()
	local forwardVector = caster:GetForwardVector()
	local timeCount = 0

	local effectIndex = ParticleManager:CreateParticle("particles/heroes/minamitsu/ability_minamitsu_02_body.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 3, vecHook)
	ParticleManager:SetParticleControlForward(effectIndex, 3, forwardVector)

	caster:SetContextThink(
		DoUniqueString("ability_thdots_minamitsu_02_stage_01"),
			function ()
				if GameRules:IsGamePaused() then
					return 0.03
				end
				timeCount = timeCount + 0.03
				distance = distance - speed
				if distance >= 0 then
					vecHook =  vecHook + Vector(math.cos(rad)*speed,math.sin(rad)*speed,0)
					ParticleManager:SetParticleControl(effectIndex, 3, vecHook)
				else
					ParticleManager:DestroyParticleSystem(effectIndex,true)
					local effectIndex2 = ParticleManager:CreateParticle("particles/heroes/minamitsu/ability_minamitsu_02.vpcf", PATTACH_CUSTOMORIGIN, nil)
					ParticleManager:SetParticleControl(effectIndex2, 0, vecHook)
					ParticleManager:SetParticleControl(effectIndex2, 3, vecHook)
					Timer.Wait 'OnMinamitsu02Vortex' (0.5,
						function()
							caster:EmitSound("Voice_Thdots_Minamitsu.AbilityMinamitsu022")
							OnMinamitsu02Vortex(keys)
						end
					)
					return nil
				end
				return 0.03
			end,
		0.03
	)
end

function OnMinamitsu02Vortex(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targetPoint = keys.target_points[1]
	local distance = GetDistanceBetweenTwoVec2D(vecCaster,targetPoint)
	local rad = GetRadBetweenTwoVec2D(vecCaster,targetPoint)
	local timeCount = 0
	caster.ability_minamitsu_02_group = {}

	caster:SetContextThink(
		DoUniqueString("ability_thdots_minamitsu_02_stage_02"),
			function ()
				if GameRules:IsGamePaused() then
					return 0.03
				end
				timeCount = timeCount + 0.03
				local targets = FindUnitsInRadius(
				   caster:GetTeam(),		
				   targetPoint,	
				   nil,					
				   keys.Radius,		
				   keys.ability:GetAbilityTargetTeam(),
				   keys.ability:GetAbilityTargetType(),
				   0,
				   FIND_CLOSEST,
				   false
			    )
			    for k,v in pairs(targets) do
			    	if v:IsNull() == false and v~=nil then
						local damage_table = {
							ability = keys.ability,
							victim = v,
							attacker = caster,
							damage = keys.ability:GetAbilityDamage()/8,
							damage_type = keys.ability:GetAbilityDamageType(), 
						    damage_flags = keys.ability:GetAbilityTargetFlags()
						}
						UnitDamageTarget(damage_table)
						if not v:HasModifier("modifier_item_dragon_star_buff") and not v:HasModifier("modifier_meirin02_buff") then
			    			table.insert(caster.ability_minamitsu_02_group,v)
							if v:IsNull() ==false and v~=nil then
								if v:HasModifier("modifier_minamitsu02_pause") == false then
									keys.ability:ApplyDataDrivenModifier( caster, v, "modifier_minamitsu02_pause", {} )
								end
								if v:HasModifier("modifier_minamitsu02_vortex_target") == false then
									local vecTarget = v:GetOrigin()
									local distance = GetDistanceBetweenTwoVec2D(vecTarget,targetPoint)
									local targetRad = GetRadBetweenTwoVec2D(targetPoint,vecTarget)
									if distance>30 then
										v:SetOrigin(Vector(vecTarget.x - math.cos(targetRad - math.pi/3) * keys.VortexSpeed *1.5, vecTarget.y - math.sin(targetRad - math.pi/3) * keys.VortexSpeed *1.5, vecTarget.z))
									else
										v:AddNoDraw()
										keys.ability:ApplyDataDrivenModifier( caster, v, "modifier_minamitsu02_vortex_target", {} )
										keys.ability:ApplyDataDrivenModifier( caster, v, "modifier_minamitsu02_vortex_pause_target", {} )
										v:SetOrigin(v:GetOrigin()+RandomVector(100)+Vector(0,0,128))
									end
								end
							end
			    		end
				    end
			    end
			    if timeCount >= 1.5 then
			    	Timer.Wait 'OnMinamitsu02Vortex_starge_2' (1.0,
						function()
							caster:EmitSound("Ability.Torrent")
							OnMinamitsu02VortexEnd(keys)
						end
					)
					return nil
			    end
			    return 0.03
			end,
		0.03
	)
end

function OnMinamitsu02VortexEnd(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targetPoint = keys.target_points[1]
	local distance = GetDistanceBetweenTwoVec2D(vecCaster,targetPoint)
	local rad = GetRadBetweenTwoVec2D(vecCaster,targetPoint)
	local timeCount = 0
	local speed = 3
	local g = 0.18

	caster:SetContextThink(
		DoUniqueString("ability_thdots_minamitsu_02_stage_02"),
			function ()
				if GameRules:IsGamePaused() then return 0.03 end
				timeCount = timeCount + 0.03
				speed = speed - g 
				if caster.ability_minamitsu_02_group ~= nil then 
				    for k,v in pairs(caster.ability_minamitsu_02_group) do
				    	if v:IsNull() == false and v~=nil then
				    		if v:HasModifier("modifier_minamitsu02_pause") then
				    			v:RemoveModifierByName("modifier_minamitsu02_pause")
				    		end
				    		if v:HasModifier("modifier_minamitsu02_vortex_target") then
				    			v:RemoveNoDraw()
				    			v:RemoveModifierByName("modifier_minamitsu02_vortex_target")
				    		end
				    		if v:HasModifier("modifier_minamitsu02_vortex_pause_target") then
				    			if v:GetOrigin().z >= GetGroundHeight(v:GetOrigin(),nil) then
				    				v:SetOrigin(v:GetOrigin() + Vector(0,0,speed))
				    			end
				    		end
					    end
				    end
				    if timeCount >= 1.0 then
				    	for k2,v2 in pairs(caster.ability_minamitsu_02_group) do
							if v2:IsNull() == false and v2~=nil then
								if v2:HasModifier("modifier_minamitsu02_vortex_pause_target") then
									v2:RemoveModifierByName("modifier_minamitsu02_vortex_pause_target")
								end
							end
						end
						return nil
				    end
				end
				return 0.03
			end,
		0.03
	)
end

function OnMinamitsu03SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_kunkka_2"))

    local effectIndex = ParticleManager:CreateParticle("particles/heroes/minamitsu/ability_minamitsu_03.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(effectIndex , 0, caster, 5, "attach_minamitsu_attack", Vector(0,0,0), true)

	local effectIndex2 = ParticleManager:CreateParticle("particles/heroes/minamitsu/ability_minamitsu_03_body.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(effectIndex2 , 0, caster, 5, "follow_origin", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effectIndex2 , 1, caster, 5, "follow_origin", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effectIndex2 , 3, caster, 5, "follow_origin", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effectIndex2 , 4, caster, 5, "follow_origin", Vector(0,0,0), true)

	ParticleManager:DestroyParticleSystemTime(effectIndex,7.0)
	ParticleManager:DestroyParticleSystemTime(effectIndex2,7.0)
end

function OnMinamitsu03AttackLanded(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local deal_damage = keys.AttackBonus
	if FindTelentValue(caster,"special_bonus_unique_kunkka_4")==1 then
		deal_damage = deal_damage + 125
	end
	local targets = FindUnitsInRadius(
		    caster:GetTeam(),		
		    vecCaster,	
		    nil,					
		    keys.Radius,		
		    keys.ability:GetAbilityTargetTeam(),
		    keys.ability:GetAbilityTargetType(),
		    0,
		    FIND_CLOSEST,
		    false
    )
    for k,v in pairs(targets) do
    	local damage_table = {
    		ability = keys.ability,
			victim = v,
			attacker = caster,
			damage = deal_damage,
			damage_type = keys.ability:GetAbilityDamageType(), 
		    damage_flags = keys.ability:GetAbilityTargetFlags()
		}
		UnitDamageTarget(damage_table) 
    end
   	local effectIndex = ParticleManager:CreateParticle("particles/econ/items/kunkka/divine_anchor/hero_kunkka_dafx_weapon/kunkka_spell_tidebringer_fxset.vpcf", PATTACH_CUSTOMORIGIN, nil)
   	ParticleManager:SetParticleControl(effectIndex, 0, vecCaster)
	ParticleManager:SetParticleControl(effectIndex, 18, vecCaster)
end

function OnMinamitsu04Spawn(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local caster = keys.caster
	local target = keys.target
	local level = keys.ability:GetLevel()

	caster.ability_minamitsu_ship = target
	caster.ability_minamitsu_ship_index = target:GetEntityIndex()
	target.ability_minamitsu_hero = caster
	target.ability_minamitsu_hero_index = caster:GetEntityIndex()
	caster.ability_minamitsu_ship.driving = false
	target:CreatureLevelUp(keys.ability:GetLevel()-1)
	target:SetModelScale(1.6)

	keys.ability:ApplyDataDrivenModifier( target, target, "modifier_minamitsu04_death", {} )

	local ability = target:FindAbilityByName("ability_thdots_minamitsu04_unit_upload")
	ability:SetLevel(1)
	ability = target:FindAbilityByName("ability_thdots_minamitsu04_unit_download")
	ability:SetLevel(1)
	if level == 2 then
		ability = target:FindAbilityByName("ability_thdots_minamitsu04_unit_back")
		ability:SetLevel(1)
		ability = target:FindAbilityByName("ability_thdots_minamitsu04_unit_boom")
		ability:SetLevel(2)
	elseif level == 3 then
		ability = target:FindAbilityByName("ability_thdots_minamitsu04_unit_back")
		ability:SetLevel(1)
		ability = target:FindAbilityByName("ability_thdots_minamitsu04_unit_boom")
		ability:SetLevel(3)
	else
		ability = target:FindAbilityByName("ability_thdots_minamitsu04_unit_back")
		ability:SetLevel(1)
		ability = target:FindAbilityByName("ability_thdots_minamitsu04_unit_boom")
		ability:SetLevel(1)
	end
	
end

function OnMinamitsu04KillSpawn(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local caster = keys.caster
	if caster.ability_minamitsu_ship~=nil and caster.ability_minamitsu_ship:IsNull() == false then
		caster.ability_minamitsu_ship:ForceKill(true)
	end
end

function OnMinamitsu04ShipUnitUpload(keys)
	local hero = keys.caster.ability_minamitsu_hero
	local target = keys.target

	if target~=hero then
		return
	end

	if hero ~= nil and hero:IsNull() == false then
		local ability = hero:FindAbilityByName("ability_thdots_minamitsu04")
		if ability ~= nil then
			OnMinamitsu04ShipUpload(hero)
		end
	end
end

function OnMinamitsu04ShipUnitDownload(keys)
	local hero = keys.caster.ability_minamitsu_hero
	local targetPoint = keys.target_points[1]

	if hero ~= nil and hero:IsNull() == false then
		if hero.IsDriving then
			hero:SetOrigin(targetPoint)
			OnMinamitsu04ShipDownload(hero)
		end
	end
end

function OnMinamitsu04ShipDeath(keys)
	local hero = keys.unit.ability_minamitsu_hero
	
	if hero ~= nil and hero:IsNull() == false then
		local ability = hero:FindAbilityByName("ability_thdots_minamitsu04")
		if ability ~= nil then
			ability:EndCooldown()
			ability:StartCooldown(120.0 + FindTelentValue(hero,"special_bonus_unique_kunkka"))
		end
	end
end

function OnMinamitsu04ShipDestroy(keys)
	local hero = keys.unit.ability_minamitsu_hero
	local caster = keys.unit.ability_minamitsu_hero
	if hero ~= nil and hero:IsNull() == false then
		local ability = hero:FindAbilityByName("ability_thdots_minamitsu04")
		if ability ~= nil then
			if hero.IsDriving then
				OnMinamitsu04ShipDownload(hero)
				if FindTelentValue(caster,"special_bonus_unique_kunkka_5")==0 then
					ability:ApplyDataDrivenModifier( hero, hero, "modifier_minamitsu04_ship_destroy", {Duration = 10.0} )
				end
			end
		end
	end
end

function OnMinamitsu04ShipUpload(caster)
	local ship = caster.ability_minamitsu_ship
	local ability = caster:FindAbilityByName("ability_thdots_minamitsu04")

	caster.IsDriving = true
	caster:EmitSound("Voice_Thdots_Minamitsu.AbilityMinamitsu041")
	ability:ApplyDataDrivenModifier( caster, ship, "modifier_minamitsu04_speed", {} )
	caster:AddNoDraw()
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_minamitsu04_Invincible", {} )
	caster:SetContextThink(DoUniqueString("ability_thdots_minamitsu_04_move_to_ship"),
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			if ship ~= nil and ship:IsNull()==false and caster.IsDriving then
				caster:SetOrigin(ship:GetOrigin())
				return 0.03
			else
				return nil
			end
		end,
	0.03)
end

function OnMinamitsu04ShipDownload(caster)
	caster.IsDriving = false
	caster:EmitSound("Voice_Thdots_Minamitsu.AbilityMinamitsu042")
	FindClearSpaceForUnit(caster, caster:GetOrigin(), false)
	caster:MoveToPositionAggressive(caster:GetOrigin())
	caster:RemoveNoDraw()
	caster:RemoveModifierByName("modifier_minamitsu04_Invincible")

	Timer.Wait 'ability_minamitsu_04_remove_speed' (2,
		function()
			if caster.IsDriving == false then
				if caster.ability_minamitsu_ship ~= nil and caster.ability_minamitsu_ship:IsNull() == false then
					caster.ability_minamitsu_ship:RemoveModifierByName("modifier_minamitsu04_speed")
				end
			end
		end
	)
end

function OnMinamitsu04ShipBack(keys)
	local caster = keys.caster
	caster:SetOrigin(caster.ability_minamitsu_hero:GetOrigin())
	caster:EmitSound("Hero_Chen.TeleportOut")
	
	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_chen/chen_holy_persuasion_a.vpcf", PATTACH_CUSTOMORIGIN, nil)
   	ParticleManager:SetParticleControl(effectIndex, 0, caster:GetOrigin())
   	ParticleManager:SetParticleControl(effectIndex, 1, caster:GetOrigin())
   	ParticleManager:SetParticleControl(effectIndex, 2, caster:GetOrigin())
end

function OnMinamitsu04ShipUnitBoom(keys)
	local caster = keys.caster
	local hero = caster.ability_minamitsu_hero
	local vecCaster = caster:GetOrigin()
	local targetPoint = keys.target_points[1]
	local rad = GetRadBetweenTwoVec2D(vecCaster,targetPoint)
	local distance = GetDistanceBetweenTwoVec2D(vecCaster,targetPoint)
	local high = vecCaster.z + 100
	local fallspeed = high / (distance / 35)
	local distance_end = distance

	hero:EmitSound("Ability.Ghostship")

	caster:SetContextThink(DoUniqueString("ability_thdots_minamitsu_04_unit_ship_destroy"),
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			distance_end = distance_end - 35
			if distance_end >= 0 then
				caster:SetOrigin(caster:GetOrigin() + Vector(math.cos(rad)*35,math.sin(rad)*35,-fallspeed))
				return 0.04
			else
				local targets = FindUnitsInRadius(
					    hero:GetTeam(),		
					    targetPoint,	
					    nil,					
					    300,		
					    keys.ability:GetAbilityTargetTeam(),
					    keys.ability:GetAbilityTargetType(),
					    0,
					    FIND_CLOSEST,
					    false
			    )
			    for k,v in pairs(targets) do
			    	local damage_table = {
			    		ability = keys.ability,
						victim = v,
						attacker = hero,
						damage = keys.Damage,
						damage_type = keys.ability:GetAbilityDamageType(), 
					    damage_flags = keys.ability:GetAbilityTargetFlags()
					}
					UnitDamageTarget(damage_table) 
					UtilStun:UnitStunTarget( hero, v , 1.5 )
			    end

			    local effectIndex = ParticleManager:CreateParticle("particles/heroes/minamitsu/ability_minamitsu_04_boom.vpcf", PATTACH_CUSTOMORIGIN, nil)
   				ParticleManager:SetParticleControl(effectIndex, 0, targetPoint)
   				
   				hero:StopSound("Ability.Ghostship")
   				hero:EmitSound("Ability.Ghostship.crash")
			    caster:AddNoDraw()
				caster:ForceKill(true)
				return nil
			end
		end,
	0.04)
end

function OnMinamitsu04ShipUnitGetHealth(keys)
	local Caster = keys.caster
	NowHealth = Caster:GetHealth()
end

function OnMinamitsu04ShipUnitBlock(keys)--抵挡队友伤害
	local Caster = keys.caster
	local Attacker = keys.attacker
	local Health = NowHealth
	if (Attacker:GetTeam() ~= Caster:GetTeam()) then
		return
	elseif ( Attacker == Caster ) then
		return	
	else	
		if keys.DamageTaken >= Caster:GetHealth() then
			Caster:SetHealth(Health)
		else
			Caster:SetHealth(Caster:GetHealth()+keys.DamageTaken)
		end
	end
end