if AbilityKaguya == nil then
	AbilityKaguya = class({})
end

function OnKaguya01SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_furion"))
	--设置计数器，控制旋转角度
	keys.ability:SetContextNum("ability_kaguya01_spell_count", 0, 0)
end

function OnKaguya01SpellThink(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local forwardVector = caster:GetForwardVector()
	local count = keys.ability:GetContext("ability_kaguya01_spell_count")
	local rollRad = count*math.pi*2/7
	local forwardCos = forwardVector.x
	local forwardSin = forwardVector.y
	local damageVector =  Vector(math.cos(rollRad)*forwardCos - math.sin(rollRad)*forwardSin,
								 forwardSin*math.cos(rollRad) + forwardCos*math.sin(rollRad),
								 0) * 350 + vecCaster

	local effectIndex
	if(count%3==0)then
		effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/kaguya/ability_kaguya01_light.vpcf", PATTACH_CUSTOMORIGIN, nil)
	elseif(count%3==1)then
		effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/kaguya/ability_kaguya01_light_green.vpcf", PATTACH_CUSTOMORIGIN, nil)
	elseif(count%3==2)then
		effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/kaguya/ability_kaguya01_light_red.vpcf", PATTACH_CUSTOMORIGIN, nil)
	end		
	count = count + 1
	keys.ability:SetContextNum("ability_kaguya01_spell_count", count, 0)

	ParticleManager:SetParticleControl(effectIndex, 0, damageVector)
	ParticleManager:SetParticleControl(effectIndex, 1, damageVector)
	ParticleManager:DestroyParticleSystem(effectIndex,false)
	
	local targets = FindUnitsInRadius(
				   caster:GetTeam(),						--caster team
				   damageVector,							--find position
				   nil,										--find entity
				   keys.DamageRadius,						--find radius
				   DOTA_UNIT_TARGET_TEAM_ENEMY,
				   keys.ability:GetAbilityTargetType(),
				   0, FIND_CLOSEST,
				   false
			    )
	for _,v in pairs(targets) do
		if v:HasModifier("modifier_thdots_kaguya01_exdamage") ==false then
			if(v.kaguya01_exdamage_count==nil)then
				v.kaguya01_exdamage_count = 0
			else
				v.kaguya01_exdamage_count = 0
			end
		end
		keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_thdots_kaguya01_exdamage", {})
		local deal_damage = keys.ability:GetAbilityDamage() + FindTelentValue(caster,"special_bonus_unique_furion_2")+v.kaguya01_exdamage_count*keys.ExDamage
		local damage_table = {
				ability = keys.ability,
			    victim = v,
			    attacker = caster,
			    damage = deal_damage,
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
		}
		UnitDamageTarget(damage_table)
		v.kaguya01_exdamage_count=v.kaguya01_exdamage_count+1
		if caster:HasModifier("modifier_item_wanbaochui") then
			if v.kaguya01_exdamage_count==1 then
				keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_thdots_kaguya_wanbaochui_debuff_1", {duration=3})
			elseif v.kaguya01_exdamage_count==2 then
				keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_thdots_kaguya_wanbaochui_debuff_2", {duration=3})
			elseif v.kaguya01_exdamage_count==3 then
				keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_thdots_kaguya_wanbaochui_debuff_3", {duration=3})
			elseif v.kaguya01_exdamage_count==4 then
				keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_thdots_kaguya_wanbaochui_debuff_4", {duration=3})
			elseif v.kaguya01_exdamage_count==5 then
				keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_thdots_kaguya_wanbaochui_debuff_5", {duration=3})
			elseif v.kaguya01_exdamage_count==6 then
				keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_thdots_kaguya_wanbaochui_debuff_6", {duration=3})
				caster:GiveMana(caster:GetMaxMana()*0.3)
			elseif v.kaguya01_exdamage_count==7 then
				keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_thdots_kaguya_wanbaochui_debuff_7", {duration=3})
				local maxhpdamage=v:GetMaxHealth()*0.2
				local ex_damage_table = {
					ability = keys.ability,
					victim = v,
					attacker = caster,
					damage = maxhpdamage,
					damage_type = keys.ability:GetAbilityDamageType(), 
					damage_flags = 0
			}
			UnitDamageTarget(ex_damage_table)
			end
		end
			

		v:SetModifierStackCount("modifier_thdots_kaguya01_exdamage", keys.ability, v.kaguya01_exdamage_count)
	end
	local damage_table_caster = {
			ability = keys.ability,
			victim = caster,
			attacker = caster,
			damage = keys.HealthCost * caster:GetMaxHealth(),
			damage_type = keys.ability:GetAbilityDamageType(), 
			damage_flags = 0
	}
	UnitDamageTarget(damage_table_caster)
end

function OnKaguyaSwapAbility(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	if(keys.ability:GetContext("ability_kaguya02_swap_ability")==nil)then
		keys.ability:SetContextNum("ability_kaguya02_swap_ability",0,0)
	end
	local abilityNumber = keys.ability:GetContext("ability_kaguya02_swap_ability")
	if 	FindTelentValue(caster,"special_bonus_unique_furion_4")==1 then
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_kaguya02_Brilliant_Dragon_Bullet", nil)
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_kaguya02_Buddhist_Diamond", nil)
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_kaguya02_Salamander_Shield", nil)
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_kaguya02_Life_Spring_Infinity", nil)
		keys.ability:SetContextNum("ability_kaguya02_swap_ability",0,0)
	else	
		if(abilityNumber==0)then
			keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_kaguya02_Brilliant_Dragon_Bullet", nil)
			caster:RemoveModifierByName("modifier_thdots_kaguya02_Life_Spring_Infinity") 
			keys.ability:SetContextNum("ability_kaguya02_swap_ability",1,0)
		elseif(abilityNumber==1)then
			keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_kaguya02_Buddhist_Diamond", nil)
			caster:RemoveModifierByName("modifier_thdots_kaguya02_Brilliant_Dragon_Bullet") 
			keys.ability:SetContextNum("ability_kaguya02_swap_ability",2,0)
		elseif(abilityNumber==2)then
			keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_kaguya02_Salamander_Shield", nil)
			caster:RemoveModifierByName("modifier_thdots_kaguya02_Buddhist_Diamond") 
			keys.ability:SetContextNum("ability_kaguya02_swap_ability",3,0)
		elseif(abilityNumber==3)then
			keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_kaguya02_Life_Spring_Infinity", nil)
			caster:RemoveModifierByName("modifier_thdots_kaguya02_Salamander_Shield") 
			keys.ability:SetContextNum("ability_kaguya02_swap_ability",0,0)
		end
	end
end

function OnKaguya02SpellDamage(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local targets = keys.target_entities
	for _,v in pairs(targets) do
		local damage_table = {
				ability = keys.ability,
			    victim = v,
			    attacker = caster,
			    damage = (keys.AbilityDamage + FindTelentValue(caster,"special_bonus_unique_furion_3"))/5,
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
		}
		UnitDamageTarget(damage_table)
	end
end

function OnKaguya03SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local dummy = CreateUnitByName(
		"npc_dummy_unit"
		,caster:GetOrigin()
		,false
		,caster
		,caster
		,caster:GetTeam()
	)
	local ability_dummy_unit = dummy:FindAbilityByName("ability_dummy_unit")
	ability_dummy_unit:SetLevel(1)
	
	dummy:AddAbility("night_stalker_darkness") 
	local darkness = dummy:FindAbilityByName("night_stalker_darkness")
	darkness:SetLevel(3)
	dummy:CastAbilityImmediately(darkness, caster:GetPlayerOwnerID())
	dummy:RemoveSelf()
end

function OnKaguya03ManaRegen(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	if(GameRules:IsDaytime()==true)then
		if FindTelentValue(caster,"special_bonus_unique_meepo")==1 then		
			local bonusMana = 2*(keys.ManaRegen + keys.BonusRegen * GameRules:GetGameTime()/keys.increaseTime)/10
			caster:SetMana(caster:GetMana()+bonusMana)
		end
	else
		if FindTelentValue(caster,"special_bonus_unique_meepo")==1 then	
			local bonusMana = 1.5*(keys.ManaRegen + keys.BonusRegen * GameRules:GetGameTime()/keys.increaseTime)/10
			caster:SetMana(caster:GetMana()+bonusMana)
		else
			local bonusMana = (keys.ManaRegen + keys.BonusRegen * GameRules:GetGameTime()/keys.increaseTime)/10
			caster:SetMana(caster:GetMana()+bonusMana)
		end
	end
end

function OnKaguya04SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	caster.ability_kaguya_04_point = keys.target_points[1]
	caster.effectIndex = ParticleManager:CreateParticle("particles/heroes/kaguya/ability_kaguya04_effect.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(caster.effectIndex, 0, keys.target_points[1])
	ParticleManager:SetParticleControl(caster.effectIndex, 1, keys.target_points[1])
	ParticleManager:SetParticleControl(caster.effectIndex, 3, keys.target_points[1])
	ParticleManager:DestroyParticleSystem(caster.effectIndex,false)
	caster:EmitSound("Hero_Phoenix.SuperNova.Cast")

	local dummy = CreateUnitByName(
		"npc_dummy_unit"
		,caster.ability_kaguya_04_point
		,false
		,caster
		,caster
		,caster:GetTeam()
	)		
	
	caster.kaguya04dummy = dummy
	
	local effectIndex = ParticleManager:CreateParticle("particles/heroes/kaguya/kaguya04ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.kaguya04dummy)
	caster.kaguya04aimrange = effectIndex
	ParticleManager:SetParticleControl(caster.kaguya04aimrange, 0, Vector(100,0,0))
	ParticleManager:SetParticleControl(caster.kaguya04aimrange, 1, Vector(100,0,0))
	ParticleManager:DestroyParticleSystemTime(caster.kaguya04aimrange,5)

	local effectIndex2 = ParticleManager:CreateParticle("particles/heroes/kaguya/kaguya04ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.kaguya04dummy)
	caster.kaguya04aimrange2 = effectIndex2
	ParticleManager:SetParticleControl(caster.kaguya04aimrange2, 0, Vector(90,0,0))
	ParticleManager:SetParticleControl(caster.kaguya04aimrange2, 1, Vector(90,0,0))
	ParticleManager:DestroyParticleSystemTime(caster.kaguya04aimrange2,5)
	
	local effectIndex3 = ParticleManager:CreateParticle("particles/heroes/kaguya/kaguya04ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.kaguya04dummy)
	caster.kaguya04aimrange3 = effectIndex3
	ParticleManager:SetParticleControl(caster.kaguya04aimrange3, 0, Vector(80,0,0))
	ParticleManager:SetParticleControl(caster.kaguya04aimrange3, 1, Vector(80,0,0))
	ParticleManager:DestroyParticleSystemTime(caster.kaguya04aimrange3,5)	

	local effectIndex4 = ParticleManager:CreateParticle("particles/heroes/kaguya/kaguya04ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.kaguya04dummy)
	caster.kaguya04aimrange4 = effectIndex4
	ParticleManager:SetParticleControl(caster.kaguya04aimrange4, 0, Vector(70,0,0))
	ParticleManager:SetParticleControl(caster.kaguya04aimrange4, 1, Vector(70,0,0))
	ParticleManager:DestroyParticleSystemTime(caster.kaguya04aimrange4,5)

	local effectIndex5 = ParticleManager:CreateParticle("particles/heroes/kaguya/kaguya04ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.kaguya04dummy)
	caster.kaguya04aimrange5 = effectIndex5
	ParticleManager:SetParticleControl(caster.kaguya04aimrange5, 0, Vector(60,0,0))
	ParticleManager:SetParticleControl(caster.kaguya04aimrange5, 1, Vector(60,0,0))	
	ParticleManager:DestroyParticleSystemTime(caster.kaguya04aimrange5,5)
	

	local effectIndex6 = ParticleManager:CreateParticle("particles/heroes/kaguya/kaguya04ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.kaguya04dummy)
	caster.kaguya04aimrange6 = effectIndex6
	ParticleManager:SetParticleControl(caster.kaguya04aimrange6, 0, Vector(50,0,0))
	ParticleManager:SetParticleControl(caster.kaguya04aimrange6, 1, Vector(50,0,0))	
	ParticleManager:DestroyParticleSystemTime(caster.kaguya04aimrange6,5)
	-- keys.ability:SetActivated(false)

	caster.kaguya04dummy:SetContextThink("killself",
		function ()
			if caster.kaguya04dummy ~= nil then
				caster.kaguya04dummy:ForceKill(true)
			end
		end, 
	5)
end

function OnKaguya04Passive(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local lostHp = caster:GetMaxHealth() - caster:GetHealth()
	if(caster.ability_kaguya_04_mana_store==nil)then
		caster.ability_kaguya_04_mana_store = 0
	end
	if(lostHp>0)then
		if FindTelentValue(caster,"special_bonus_unique_meepo_2")==1 then
			if(caster:GetMana()>=lostHp*keys.CostMana)then
				caster:SetHealth(caster:GetHealth() + lostHp)
				caster:SetMana(caster:GetMana() - lostHp*keys.CostMana)
			else
				caster:SetHealth(caster:GetHealth() + caster:GetMana())
				caster:SetMana(0)
			end
			caster.ability_kaguya_04_mana_store = 700
		else
			if(lostHp <= keys.HpRegen)then
				if(caster:GetMana()>=lostHp*keys.CostMana)then
					caster:SetHealth(caster:GetHealth() + lostHp)
					caster:SetMana(caster:GetMana() - lostHp*keys.CostMana)
					caster.ability_kaguya_04_mana_store = caster.ability_kaguya_04_mana_store + lostHp*keys.CostMana
				end
			else
				if(caster:GetMana()>=keys.HpRegen*keys.CostMana)then
					caster:SetHealth(caster:GetHealth() + keys.HpRegen)
					caster:SetMana(caster:GetMana() - keys.HpRegen*keys.CostMana)
					caster.ability_kaguya_04_mana_store = caster.ability_kaguya_04_mana_store + keys.HpRegen*keys.CostMana
				end
			end
		end
	else
		if(caster.ability_kaguya_04_mana_store~=nil)then
			if(caster.ability_kaguya_04_mana_store>=0)then
				caster.ability_kaguya_04_mana_store = caster.ability_kaguya_04_mana_store - caster:GetMaxMana() * keys.Decrease_speed
				if(caster.ability_kaguya_04_mana_store<0)then
					caster.ability_kaguya_04_mana_store =0
				end
			end
		end
	end
end

function OnKaguya04Think(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	if(caster.ability_kaguya_04_mana_store == nil)then
		caster.ability_kaguya_04_mana_store = 0
	end
	if(caster.ability_kaguya_04_radius==nil)then
		caster.ability_kaguya_04_radius = 100
	end
	if(caster.ability_kaguya_04_mana_store>=700)then
		caster.ability_kaguya_04_mana_store = 700
	end
	if(caster.ability_kaguya_04_radius<=300+caster.ability_kaguya_04_mana_store)then
		caster.ability_kaguya_04_radius = caster.ability_kaguya_04_radius + keys.IncreaseRadius
	else
		caster.ability_kaguya_04_radius = 100
		caster.ability_kaguya_04_mana_store =0
		if(caster.effectIndex~=nil)then
			local effectIndex = ParticleManager:CreateParticle("particles/heroes/kaguya/ability_kaguya04_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControl(effectIndex, 0, caster.ability_kaguya_04_point)
			ParticleManager:SetParticleControl(effectIndex, 3, caster.ability_kaguya_04_point)
			ParticleManager:DestroyParticleSystemTime(effectIndex,1.0)
			ParticleManager:DestroyParticleSystemTime(caster.effectIndex,0)
		end
		caster:StopSound("Hero_Phoenix.SuperNova.Cast")
		caster:EmitSound("Hero_Abaddon.AphoticShield.Destroy")
		if caster.kaguya04dummy:IsNull() == false and caster.kaguya04dummy ~= nil then
			ParticleManager:DestroyParticleSystem(caster.kaguya04aimrange,true)	
			ParticleManager:DestroyParticleSystem(caster.kaguya04aimrange2,true)
			ParticleManager:DestroyParticleSystem(caster.kaguya04aimrange3,true)	
			ParticleManager:DestroyParticleSystem(caster.kaguya04aimrange4,true)
			ParticleManager:DestroyParticleSystem(caster.kaguya04aimrange5,true)	
			ParticleManager:DestroyParticleSystem(caster.kaguya04aimrange6,true)		
			caster.kaguya04dummy:RemoveSelf()	
			caster:RemoveModifierByName("modifier_thdots_kaguya04_think")
		end
	end
	local targets = FindUnitsInRadius(
				   caster:GetTeam(),						--caster team
				   caster.ability_kaguya_04_point,			--find position
				   nil,										--find entity
				   caster.ability_kaguya_04_radius,			--find radius
				   DOTA_UNIT_TARGET_TEAM_ENEMY,
				   keys.ability:GetAbilityTargetType(),
				   0, FIND_CLOSEST,
				   false
			    )
	for _,v in pairs(targets) do
		local damage_table = {
				ability = keys.ability,
			    victim = v,
			    attacker = caster,
			    damage = keys.ability:GetAbilityDamage(),
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = keys.ability:GetAbilityTargetFlags()
		}
		UnitDamageTarget(damage_table)
		UtilStun:UnitStunTarget( caster,v,keys.StunDuration)
	end
	if caster.kaguya04aimrange ~= nil then
		ParticleManager:SetParticleControl(caster.kaguya04aimrange, 0, Vector(caster.ability_kaguya_04_radius,0,0))
		ParticleManager:SetParticleControl(caster.kaguya04aimrange, 1, Vector(caster.ability_kaguya_04_radius,0,0))		
		ParticleManager:SetParticleControl(caster.kaguya04aimrange2, 0, Vector((caster.ability_kaguya_04_radius*0.9),0,0))
		ParticleManager:SetParticleControl(caster.kaguya04aimrange2, 1, Vector((caster.ability_kaguya_04_radius*0.9),0,0))		
		ParticleManager:SetParticleControl(caster.kaguya04aimrange3, 0, Vector((caster.ability_kaguya_04_radius*0.8),0,0))
		ParticleManager:SetParticleControl(caster.kaguya04aimrange3, 1, Vector((caster.ability_kaguya_04_radius*0.8),0,0))	
		ParticleManager:SetParticleControl(caster.kaguya04aimrange4, 0, Vector((caster.ability_kaguya_04_radius*0.7),0,0))
		ParticleManager:SetParticleControl(caster.kaguya04aimrange4, 1, Vector((caster.ability_kaguya_04_radius*0.7),0,0))
		ParticleManager:SetParticleControl(caster.kaguya04aimrange5, 0, Vector((caster.ability_kaguya_04_radius*0.6),0,0))
		ParticleManager:SetParticleControl(caster.kaguya04aimrange5, 1, Vector((caster.ability_kaguya_04_radius*0.6),0,0))		
		ParticleManager:SetParticleControl(caster.kaguya04aimrange6, 0, Vector((caster.ability_kaguya_04_radius*0.5),0,0))
		ParticleManager:SetParticleControl(caster.kaguya04aimrange6, 1, Vector((caster.ability_kaguya_04_radius*0.5),0,0))			
	end
	--caster:EmitSound("Hero_Phoenix.FireSpirits.Target")
	caster:EmitSound("Hero_Abaddon.DeathCoil.Target")
	
end



function KaguyaEx_OnIntervalThink(keys)
	local ability=keys.ability
	local caster=keys.caster
	local ability_lvl=math.floor(caster:GetLevel()/6) + 1
	if ability_lvl~=ability:GetLevel() then
		ability:SetLevel(ability_lvl)
	end
end


