if AbilityAya == nil then
	AbilityAya = class({})
end

function OnAya01SpellStart(keys)
	AbilityAya:OnAya01Start(keys)	
end

function OnAya01SpellMove(keys)
	AbilityAya:OnAya01Move(keys)
end

function OnAya02SpellStart(keys)
	if is_spell_blocked(keys.target) then return end
	keys.ability:ApplyDataDrivenModifier(keys.caster,keys.target,keys.EffectName,{})
	if FindTelentValue(keys.caster,"special_bonus_unique_aya_1") ~= 0 then
		keys.ability:ApplyDataDrivenModifier(keys.caster,keys.target,"modifier_thdots_aya02_buff_talent",{})
	else
		keys.ability:ApplyDataDrivenModifier(keys.caster,keys.target,keys.BuffName,{})
	end
end

function OnAya02Attack(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	if(keys.attacker~=caster)then
		return
	end
	local target = keys.target
	local damage = keys.BounsDamage * (1 + FindTelentValue(keys.caster,"special_bonus_unique_aya_1"))
	print(damage)
	local damage_table = {
				ability = keys.ability,
			    victim = target,
			    attacker = caster,
			    damage = damage,
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
	}
	UnitDamageTarget(damage_table)
end

function OnAya03SpellStart(keys)
	AbilityAya:OnAya03Start(keys)
end

function OnAya04SpellOrderMoved(keys)
	AbilityAya:OnAya04OrderMoved(keys)
end

function OnAya04SpellOrderAttack(keys)
	AbilityAya:OnAya04OrderAttack(keys)
end

function OnAya04SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_slark"))
	local ability = caster:FindAbilityByName("ability_thdots_aya01") 
			ability:EndCooldown()
	--还原
	UnitNoPathingfix(caster,caster,keys.ability:GetSpecialValueFor("ability_duration"))

	--caster.aya04count = keys.Count
	--print("caster.aya04count",caster.aya04count)
end

function OnAya04SpellRefresh(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	--判断
	--if caster.aya04count <= 0 then return end
	local ability = caster:FindAbilityByName("ability_thdots_aya01") 
		--if(ability~=nil)then
			ability:EndCooldown()
		--end
end


function AbilityAya:OnAya01Start(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_slark_3"))
	--计数
	--if caster:HasModifier("modifier_thdots_aya04_blink") then		
		--caster.aya04count = caster.aya04count - 1	
		--print("caster.aya04count",caster.aya04count)
	--end
	if caster:HasModifier("modifier_item_wanbaochui") and caster:HasModifier("modifier_thdots_aya04_blink") then
		caster:SetMana(caster:GetMana()*0.94)
	end	
	local targetPoint = keys.target_points[1]
	local Aya01rad = GetRadBetweenTwoVec2D(caster:GetOrigin(),targetPoint)
	local Aya01dis = GetDistanceBetweenTwoVec2D(caster:GetOrigin(),targetPoint)
	if(Aya01dis>keys.FixDis)then
		Aya01dis = keys.FixDis
	end
	keys.ability:SetContextNum("ability_Aya01_Rad",Aya01rad,0)
	keys.ability:SetContextNum("ability_Aya01_Dis",Aya01dis,0)
end

function AbilityAya:OnAya01Move(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targets = keys.target_entities
	if caster:HasModifier("modifier_item_wanbaochui") and caster:HasModifier("modifier_thdots_aya04_blink") then
		local ability = caster:FindAbilityByName("ability_thdots_aya01")
		ability:EndCooldown()
		
	end
	
	for _,v in pairs(targets) do
		if(v:GetContext("ability_Aya01_damage")==nil)then
			v:SetContextNum("ability_Aya01_damage",TRUE,0)
		end
		if(v:GetContext("ability_Aya01_damage")==TRUE)then
			local damage_table = {
				ability = keys.ability,
			    victim = v,
			    attacker = caster,
			    damage = keys.ability:GetAbilityDamage()+FindTelentValue(caster,"special_bonus_unique_slark_4"),
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
		    }
			UnitDamageTarget(damage_table)
			if caster:HasModifier("modifier_item_wanbaochui") then 
				keys.ability:ApplyDataDrivenModifier( caster, v, "modifier_aya01_slow", {Duration=3} )
			end
		   
			v:SetContextNum("ability_Aya01_damage",FALSE,0)

			if v:IsHero() and caster:HasModifier("modifier_thdots_aya04_blink") and caster:GetClassname()=="npc_dota_hero_slark" then
				local ability = caster:FindAbilityByName("ability_thdots_aya01")
				ability:EndCooldown()
			end

			Timer.Wait 'ability_Aya01_damage_timer' (0.4,
			function()
				v:SetContextNum("ability_Aya01_damage",TRUE,0)
			end
	    	)
		end
	end
	local flyspeed=keys.MoveSpeed
	if caster:HasModifier("modifier_item_wanbaochui") then
		flyspeed=keys.MoveSpeed*2
	end

	local Aya01rad = keys.ability:GetContext("ability_Aya01_Rad")
	local vec = Vector(vecCaster.x+math.cos(Aya01rad)*flyspeed/50,vecCaster.y+math.sin(Aya01rad)*flyspeed/50,vecCaster.z)
	caster:SetOrigin(vec)
	
	local aya01dis = keys.ability:GetContext("ability_Aya01_Dis")
	if(aya01dis<0)then
		SetTargetToTraversable(caster)
		keys.ability:SetContextNum("ability_Aya01_Dis",0,0)
		caster:RemoveModifierByName("modifier_thdots_aya01_think_interval")
	else
	    aya01dis = aya01dis -flyspeed/50
	    keys.ability:SetContextNum("ability_Aya01_Dis",aya01dis,0)
	end
end

function AbilityAya:OnAya03Start(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targets = keys.target_entities
	local Attacker = keys.attacker
	for _,v in pairs(targets) do
		local deal_damage = keys.AbilityMulti * caster:GetPrimaryStatValue() + FindValueTHD("base_damage",keys.ability)

		if Attacker:IsRealHero() then
			deal_damage = deal_damage
		else deal_damage = deal_damage* 0.35
		end
		
		local damage_table = {
				ability = keys.ability,
			    victim = v,
			    attacker = caster,
			    damage = deal_damage,
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
		}
		UnitDamageTarget(damage_table)
	end
	local effectIndex = ParticleManager:CreateParticle(
	"particles/econ/items/windrunner/windrunner_cape_cascade/windrunner_windrun_cascade.vpcf", 
	PATTACH_CUSTOMORIGIN, 
	caster)
	ParticleManager:SetParticleControl(effectIndex, 0, caster:GetOrigin() + caster:GetForwardVector()*100)
	ParticleManager:SetParticleControl(effectIndex, 1, caster:GetOrigin() + caster:GetForwardVector()*100)
	ParticleManager:SetParticleControl(effectIndex, 3, caster:GetOrigin() + caster:GetForwardVector()*100)
	ParticleManager:DestroyParticleSystemTime(effectIndex,2)
end

function AbilityAya:OnAya04OrderMoved(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	if caster:IsStunned() == false and caster:HasModifier("modifier_item_yukkuri_stick_debuff") == false then
		if(keys.ability:GetContext("ability_Aya04_blink_lock")==FALSE)then
			return
		end

		keys.ability:ApplyDataDrivenModifier( caster, caster, "modifier_thdots_aya04_animation", {Duration=0.3} )
		

		local vecMove = caster:GetOrigin() + keys.BlinkRange * caster:GetForwardVector()
		caster:SetOrigin(vecMove)

		local effectIndex = ParticleManager:CreateParticle(
			"particles/heroes/aya/ability_aya_04.vpcf", 
			PATTACH_CUSTOMORIGIN, 
			caster)
		ParticleManager:SetParticleControl(effectIndex, 0, vecMove)
		ParticleManager:SetParticleControl(effectIndex, 3, vecMove)
		ParticleManager:DestroyParticleSystem(effectIndex,false)
		
		
			

		if(keys.ability:GetContext("ability_Aya04_blink_lock")==TRUE or keys.ability:GetContext("ability_Aya04_blink_lock")==nil)then
			keys.ability:SetContextNum("ability_Aya04_blink_lock",FALSE,0)
			Timer.Wait 'ability_Aya04_blink_lock' (0.1,
				function()
					keys.ability:SetContextNum("ability_Aya04_blink_lock",TRUE,0)
					
				end
		    	)
		end
	end
end

function AbilityAya:OnAya04OrderAttack(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	if caster:IsStunned() == false and caster:HasModifier("modifier_item_yukkuri_stick_debuff") == false then
		if(keys.ability:GetContext("ability_Aya04_blink_lock")==FALSE)then
			return
		end
		local vectarget = keys.target:GetOrigin()
		caster:SetOrigin(vectarget)

		local effectIndex = ParticleManager:CreateParticle(
			"particles/heroes/aya/ability_aya_04.vpcf", 
			PATTACH_CUSTOMORIGIN, 
			caster)
		ParticleManager:SetParticleControl(effectIndex, 0, vectarget)
		ParticleManager:SetParticleControl(effectIndex, 3, vectarget)
		ParticleManager:DestroyParticleSystem(effectIndex,false)

		if(keys.ability:GetContext("ability_Aya04_blink_lock")==TRUE or keys.ability:GetContext("ability_Aya04_blink_lock")==nil)then
			keys.ability:SetContextNum("ability_Aya04_blink_lock",FALSE,0)
			Timer.Wait 'ability_Aya04_blink_lock' (0.1,
				function()
					keys.ability:SetContextNum("ability_Aya04_blink_lock",TRUE,0)
				end
		    	)
		end
	end
end

function OnAya04upgrade(keys)
	local caster = keys.caster
	if caster:GetClassname() == "npc_dota_hero_slark" then
		caster:SetOriginalModel("models/new_touhou_model/aya/aya_with_wing.vmdl")
	end
end

