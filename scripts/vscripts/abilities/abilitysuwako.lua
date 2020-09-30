


function OnsuwakoexSpellStart(keys)

local caster = keys.caster
local target = keys.target
local ability = keys.ability
local suwakointscale = keys.intscale
local dealdamagesuwako = ((caster:GetIntellect()*suwakointscale) +  ability:GetAbilityDamage())
	--caster:EmitSound("suwako_innate_"..math.random(1,3))	 
	 
	 --ApplyDamage({victim = target, attacker = caster, damage = dealdamagesuwako, damage_type = keys.ability:GetAbilityDamageType()})
	 
	 
	 		local damage_table = {
				ability = keys.ability,
			    victim = target,
			    attacker = caster,
			    damage = dealdamagesuwako,
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
	    	}	
	
	 local effectIndex = ParticleManager:CreateParticle( "particles/econ/items/storm_spirit/strom_spirit_ti8/gold_storm_sprit_ti8_overload_discharge.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin())
		ParticleManager:SetParticleControl(effectIndex, 1, target:GetOrigin())
		ParticleManager:SetParticleControl(effectIndex, 2, target:GetOrigin())
		ParticleManager:SetParticleControl(effectIndex, 5, target:GetOrigin())
		caster:EmitSound("Hero_VengefulSpirit.MagicMissileImpact")
		
		
		local suwakoexdamage = UnitDamageTarget(damage_table)	
		 
	
end

function OnsuwakoexSpellStart2(keys)
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability
	local damageradius = ability:GetLevelSpecialValueFor("suwakoex_radius", ability:GetLevel() - 1 )
	
	local suwakointscale = ability:GetLevelSpecialValueFor("int_multi", ability:GetLevel() - 1 )
	local dealdamagesuwako = ((caster:GetIntellect()*suwakointscale) +  ability:GetAbilityDamage())
	
	local suwakomaxtarget = FindValueTHD("max_target",ability)
	
	--ability:EndCooldown()
	--ability:StartCooldown(2.2)
	
	local suwakotarget = 0
	local targets = FindUnitsInRadius(
				   caster:GetTeam(),						--caster team
				   target,							--find position
				   nil,										--find entity
				   damageradius,						--find radius
				   DOTA_UNIT_TARGET_TEAM_ENEMY,
				   DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
				   0, FIND_CLOSEST,
				   false
			    )
	caster.suwakoexeffect = 0
				
	for _,v in pairs(targets) do
	 		suwakotarget = suwakotarget + 1
			if suwakotarget > suwakomaxtarget then
				dealdamagesuwako = 0
			end
	 		local damage_table = {
				ability = keys.ability,
			    victim = v,
			    attacker = caster,
			    damage = dealdamagesuwako,
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
	    	}
			

			
	    if caster.suwakoexeffect == 0 then 
			local effectIndex = ParticleManager:CreateParticle( "particles/econ/items/storm_spirit/strom_spirit_ti8/gold_storm_sprit_ti8_overload_discharge.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControl(effectIndex, 0, target)
			ParticleManager:SetParticleControl(effectIndex, 1, target)
			ParticleManager:SetParticleControl(effectIndex, 2, target)
			ParticleManager:SetParticleControl(effectIndex, 5, target)
			v:EmitSound("Hero_VengefulSpirit.MagicMissileImpact")			
			caster.suwakoexeffect = 1
	
	    end			
			
			
	    			
	    UnitDamageTarget(damage_table)
	
	end
	
	caster.suwakoexeffect = 0

end



function suwako01soundeffect(keys)
local caster = keys.caster


	 

	caster:EmitSound("suwako01effectvoice_"..math.random(1,3))	 
	
end


function suwakoexvoice(keys)
local caster = keys.caster


	caster:EmitSound("suwako_innate_"..math.random(1,3))	 
	
end


function OnSuwako01SpellStart(keys)
	local caster = keys.caster
	
	local target = keys.target
	local ability = keys.ability
	 --ApplyDamage({victim = target, attacker = caster, damage = (caster:GetIntellect()*1.4) +  ability:GetAbilityDamage(), damage_type = keys.ability:GetAbilityDamageType()})
	local intscale = keys.intscale 
	 local suwako01dealdamage = (caster:GetIntellect()*intscale) + ability:GetAbilityDamage() +FindTelentValue(caster,"special_bonus_unique_suwako_1")
	 
	
		--UnitDamageTarget(damage_table)	 
	 
	 	local damage_table = {
				ability = keys.ability,
			    victim = target,
			    attacker = caster,
			    damage = suwako01dealdamage,
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
		}
	UnitDamageTarget(damage_table) 
	caster:EmitSound("suwako01effect")			 
end



function OnSuwako01SpellEnd(keys)
	local caster = keys.caster
	
	local target = keys.target
	local ability = keys.ability

	 
		
	 
end

function Suwako02cooldown(keys)
	local caster = keys.caster
	THDReduceCooldown(keys.ability,-FindTelentValue(caster,"special_bonus_unique_suwako_2"))	

end


function OnSuwako02SpellStart(keys)
	local caster = keys.caster
	
	--local target = keys.target
	local ability = keys.ability
	local model = keys.model


	if caster.caster_model == nil then 
		caster.caster_model = caster:GetModelName()
	end	
	
	caster:SetOriginalModel(model)
	caster:SetModelScale(4)
	--caster:SetModel(model)	
	caster:EmitSound("suwako02_1")	
end


function suwako02modelcheck(keys)
	local caster = keys.caster
	
	--local target = keys.target
	local ability = keys.ability
	local model = keys.model
	caster:SetModel(model)	
	--caster:EmitSound("suwako02_1")	

end

function suwako02effectcheck(keys)
	local caster = keys.caster
	local radius = keys.radius
		local effectIndex4 = ParticleManager:CreateParticle( "particles/econ/events/ti7/shivas_guard_active_ti7.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	
		ParticleManager:SetParticleControl(effectIndex4, 0, caster:GetOrigin())
		ParticleManager:SetParticleControl(effectIndex4, 1, Vector(radius-300, 0, radius-300))
		--ParticleManager:ReleaseParticleIndex(effectIndex4)		
	caster:EmitSound("suwako_02") 		
end		

function OnSuwako02SpellEnd(keys)
	local caster = keys.caster
	
	--local target = keys.target
	local ability = keys.ability
	local model2 = keys.model2
	
	caster:SetOriginalModel(caster.caster_model)
	caster:SetModelScale(1)
	--caster:SetModel(model2)	
end

function suwako02damage(keys)
	local caster = keys.caster
	
	local target = keys.target
	local ability = keys.ability
	local intervals = FindValueTHD("intervals",ability)
	local intscale = FindValueTHD("int_scale",ability)
	local suwako02dealdamage = ((caster:GetIntellect()*intscale) + ability:GetAbilityDamage())*intervals
	 --ApplyDamage({victim = target, attacker = caster, damage = ((caster:GetIntellect()*0.5) +  ability:GetAbilityDamage())*0.5, damage_type = keys.ability:GetAbilityDamageType()})
	
	 
	 
	 
	caster:EmitSound("suwako_02") 
	
		 local effectIndex = ParticleManager:CreateParticle( "particles/econ/events/ti7/shivas_guard_impact_ti7.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin())
		ParticleManager:SetParticleControl(effectIndex, 1, target:GetOrigin())
		
	local suwakoslowduration = 0	
	if caster:HasModifier("modifier_suwako02_change") then	
		
		local suwako2duration = caster:FindModifierByName("modifier_suwako02_change"):GetRemainingTime()
		
		suwakoslowduration = keys.SlowDuration + suwako2duration
		
		else
		suwakoslowduration = keys.SlowDuration
	end	
		
	
	
			

 	keys.ability:ApplyDataDrivenModifier(caster,target,"modifier_suwako02_slow",{duration = suwakoslowduration})
		local damage_table = {
				ability = keys.ability,
			    victim = target,
			    attacker = caster,
			    damage = suwako02dealdamage,
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
		}	
		UnitDamageTarget(damage_table)	
 	--keys.ability:ApplyDataDrivenModifier(caster,target,"modifier_suwako02_ministun",{})
end

function suwako03manacost (keys)
	local caster = keys.caster
	local manacost = keys.manacost
	local manatospend = ((caster:GetMaxMana()*manacost)/100)
	local ability = keys.ability
--	caster:SpendMana(manatospend,ability)
print("args")
	caster:ReduceMana(manatospend)




end

function suwako03check(keys)


	local caster = keys.caster
	local manacost = keys.manacost
	
	local ability = keys.ability
	
	if caster:GetMana() < ((caster:GetMaxMana()*manacost)/100) then
	
		ability:SetActivated(false)
	else
		ability:SetActivated(true)	
	
	
	end
	






end





function OnSuwako04SpellStartNew(keys)

	local caster = keys.caster
	local ability = keys.ability
	

	THDReduceCooldown(ability,-FindTelentValue(caster,"special_bonus_unique_suwako_3"))	

	--caster:EmitSound("suwako_04_"..math.random(1,3))	
	EmitGlobalSound("suwako_04_"..math.random(1,3))	
	--caster:GiveMana(((caster:GetIntellect()*0.6)+120)*0.12)	
	
	local targets = FindUnitsInRadius(
				   caster:GetTeam(),						--caster team
				   caster:GetAbsOrigin(),							--find position
				   nil,										--find entity
				   99999,						--find radius
				   DOTA_UNIT_TARGET_TEAM_ENEMY,
				   DOTA_UNIT_TARGET_HERO,
				   DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST,
				   false
			    )
	
	for _,v in pairs(targets) do
	
		ability:ApplyDataDrivenModifier( caster, v, "modifier_suwako04", {} )
			
	
	
	end

end

function OnSuwako04ModifierCheckDestroyedNew(keys)
	local caster = keys.caster
	
	local target = keys.target
	local ability = keys.ability
	 --ApplyDamage({victim = target, attacker = caster, damage = (caster:GetIntellect()*0.6) +  ability:GetAbilityDamage(), damage_type = keys.ability:GetAbilityDamageType()})
	ability:ApplyDataDrivenModifier( caster, target, "modifier_suwako04_stun", {} )	
	local suwako04dealdamage = (caster:GetIntellect()*0.6) +  ability:GetAbilityDamage() +FindTelentValue(caster,"special_bonus_unique_suwako_4")

	
		local damage_table = {
				ability = keys.ability,
			    victim = target,
			    attacker = caster,
			    damage = suwako04dealdamage,
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
		}	
		UnitDamageTarget(damage_table)	
		
	
	caster:EmitSound("suwako_04") 
	 
	 		 local effectIndex = ParticleManager:CreateParticle( "particles/econ/items/kunkka/kunkka_weapon_whaleblade_retro/kunkka_spell_torrent_retro_whaleblade_b.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin())
		ParticleManager:SetParticleControl(effectIndex, 1, target:GetOrigin())
		ParticleManager:SetParticleControl(effectIndex, 2, target:GetOrigin())
		ParticleManager:SetParticleControl(effectIndex, 5, target:GetOrigin())
		
	-- 		 local effectIndex2 = ParticleManager:CreateParticle( "particles/decompiled_particles/econ/items/kunkka/kunkka_weapon_whaleblade/kunkka_spell_torrent_splash_whaleblade.vpcf", PATTACH_CUSTOMORIGIN, caster)
	--	ParticleManager:SetParticleControl(effectIndex2, 0, target:GetOrigin())
	--	ParticleManager:SetParticleControl(effectIndex2, 1, target:GetOrigin())
	--	ParticleManager:SetParticleControl(effectIndex2, 2, target:GetOrigin())
	--	ParticleManager:SetParticleControl(effectIndex2, 5, target:GetOrigin())		 	

	 		 local effectIndex4 = ParticleManager:CreateParticle( "particles/units/heroes/hero_earthshaker/earthshaker_fissure.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(effectIndex4, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(effectIndex4, 1, caster:GetAbsOrigin())		
		ParticleManager:DestroyParticleSystem(effectIndex4,false)		
		
		local effectIndex = ParticleManager:CreateParticle( "particles/econ/events/ti7/shivas_guard_impact_ti7.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin())
		ParticleManager:SetParticleControl(effectIndex, 1, target:GetOrigin())
		

end





function Onsuwako04check(event)


	local caster = event.caster
	
	local target = event.target
	local ability = event.ability
	
	ability:ApplyDataDrivenModifier( caster, target, "modifier_suwako04", {} )
	ability:ApplyDataDrivenModifier( caster, target, "modifier_suwako04_stun", {} )		
	
end



function Onsuwako04start(keys)
	local caster = keys.caster
	
	local target = keys.target
	local ability = keys.ability
	 --ApplyDamage({victim = target, attacker = caster, damage = (caster:GetIntellect()*0.6) +  ability:GetAbilityDamage(), damage_type = keys.ability:GetAbilityDamageType()})
	
	local suwako04dealdamage = (caster:GetIntellect()*0.6) +  ability:GetAbilityDamage() +FindTelentValue(caster,"special_bonus_unique_suwako_4")

	
		local damage_table = {
				ability = keys.ability,
			    victim = target,
			    attacker = caster,
			    damage = suwako04dealdamage,
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
		}	
		UnitDamageTarget(damage_table)	
		
	
	caster:EmitSound("suwako_04") 
	 
	 		 local effectIndex = ParticleManager:CreateParticle( "particles/econ/items/kunkka/kunkka_weapon_whaleblade_retro/kunkka_spell_torrent_retro_whaleblade_b.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin())
		ParticleManager:SetParticleControl(effectIndex, 1, target:GetOrigin())
		ParticleManager:SetParticleControl(effectIndex, 2, target:GetOrigin())
		ParticleManager:SetParticleControl(effectIndex, 5, target:GetOrigin())
		
	-- 		 local effectIndex2 = ParticleManager:CreateParticle( "particles/decompiled_particles/econ/items/kunkka/kunkka_weapon_whaleblade/kunkka_spell_torrent_splash_whaleblade.vpcf", PATTACH_CUSTOMORIGIN, caster)
	--	ParticleManager:SetParticleControl(effectIndex2, 0, target:GetOrigin())
	--	ParticleManager:SetParticleControl(effectIndex2, 1, target:GetOrigin())
	--	ParticleManager:SetParticleControl(effectIndex2, 2, target:GetOrigin())
	--	ParticleManager:SetParticleControl(effectIndex2, 5, target:GetOrigin())		 	

	 		 local effectIndex4 = ParticleManager:CreateParticle( "particles/units/heroes/hero_earthshaker/earthshaker_fissure.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(effectIndex4, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(effectIndex4, 1, caster:GetAbsOrigin())		
		ParticleManager:DestroyParticleSystem(effectIndex4,false)		
		
		local effectIndex = ParticleManager:CreateParticle( "particles/econ/events/ti7/shivas_guard_impact_ti7.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin())
		ParticleManager:SetParticleControl(effectIndex, 1, target:GetOrigin())
		

end


function Suwako04voice(event)
	local caster = event.caster
	--local ability = event.ability	
	THDReduceCooldown(event.ability,-FindTelentValue(caster,"special_bonus_unique_suwako_3"))	

	--caster:EmitSound("suwako_04_"..math.random(1,3))	
	EmitGlobalSound("suwako_04_"..math.random(1,3))	
--caster:GiveMana(((caster:GetIntellect()*0.6)+120)*0.12)	

end


--LinkLuaModifier("modifier_suwako_mana", "scripts/vscripts/modifiers/modifier_suwako_mana.lua", LUA_MODIFIER_MOTION_NONE)




function HideWearables( event )
	local hero = event.caster
	local ability = event.ability

	hero.hiddenWearables = {} -- Keep every wearable handle in a table to show them later
    local model = hero:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() == "dota_item_wearable" then
            model:AddEffects(EF_NODRAW) -- Set model hidden
            table.insert(hero.hiddenWearables, model)
        end
        model = model:NextMovePeer()
    end
end


function ShowWearables( event )
	local hero = event.caster

	for i,v in pairs(hero.hiddenWearables) do
		v:RemoveEffects(EF_NODRAW)
	end
end


function OnSuwako03DealDamage(keys)

	local caster = keys.caster
	local dmg = keys.DealDamage
	local returnmana = keys.Manareturn
	print(dmg)
	local getmana = dmg*returnmana*0.01
	
	caster:GiveMana(getmana)	


end

function OnSuwako03TakeDamage(keys)

	local caster = keys.caster
	local ability = keys.ability	
	local attacker = keys.attacker
	
	--print(attacker:GetName())
	
	
	local damagetaken = keys.DamageTaken
	print(damagetaken)
	--print(damagetaken)
	local reduction  = ability:GetLevelSpecialValueFor("damage_reduction", ability:GetLevel() - 1 )
	local positivereduction = reduction*(-1)
	local rawdamage = (damagetaken*100)/positivereduction
	
	local reducedamage = rawdamage*positivereduction*0.01
	local manaabsorb = keys.Manaabsorb
	local manatospend = reducedamage/manaabsorb
	
	
--	local manatospend = reducedamage*manaabsorb	
--	print(manatospend)
	
--	caster:SpendMana(manatospend ,ability)
	
	--caster:GiveMana(getmana)	
	--if caster:GetMana() == 0 then
	--	caster:RemoveModifierByName("modifier_suwako03shield")	
	
	--end
	if caster:GetHealth() == 0 then
		return	
	end
	
	if manatospend > caster:GetMana() then
		local mananeeded = manatospend-caster:GetMana()
		local hpneeded = mananeeded*manaabsorb
	--	print(caster:GetHealth())
	--	caster:ModifyHealth(-hpneed,ability,false,nil)
		if hpneeded > caster:GetHealth() then
		
		--	caster:SetHealth(1)
			if attacker== nil then
				caster:SetHealth(1)
			else	
				caster:Kill(ability,attacker)
			end				
		else
			caster:SetHealth(caster:GetHealth()-hpneeded)
		end		
			
		caster:SetMana(0)
	--	print(caster:GetHealth())
		ability:ToggleAbility()
	else
		--caster:ReduceMana(manatospend)
		caster:SetMana(caster:GetMana()-manatospend)


	end
	
	if caster:GetMana() == 0 then
		ability:ToggleAbility()
	end	



end

function suwako03toggleoff(keys)

	local caster = keys.caster
	local ability = keys.ability	
	ability:StartCooldown(5)



end