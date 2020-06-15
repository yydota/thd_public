function OnKomachi01Upgrade(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local modifier = caster:FindModifierByName("modifier_thdots_komachi_blink")
	if modifier~=nil then
		modifier:IncrementStackCount()
	end
end

function Komachi01_Think(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local modifier = caster:FindModifierByName("modifier_thdots_komachi_blink")
	local exduration = 0
	local stackcount=keys.stackCount
	if caster:HasModifier("modifier_item_wanbaochui") then
		
		stackcount=keys.stackCount+3
	end
	if modifier:GetStackCount()<stackcount and caster:HasModifier("modifier_thdots_komachi_time_to_add_blink")==false then
		keys.ability:ApplyDataDrivenModifier(caster,caster,"modifier_thdots_komachi_time_to_add_blink",{duration = 10 - FindTelentValue(caster,"special_bonus_unique_elder_titan")})
	end
end

function OnKomachi01SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local modifier = caster:FindModifierByName("modifier_thdots_komachi_blink")
	if modifier~=nil then
		if modifier:GetStackCount()>0 then
			modifier:DecrementStackCount()
			FindClearSpaceForUnit(caster, caster:GetOrigin() + caster:GetForwardVector() * keys.distance, false)
			local ability = caster:FindAbilityByName("ability_thdots_komachi02")
			if ability~=nil then
				if ability:GetLevel() <= 0 then
					ability:SetLevel(1)
					keys.ability:ApplyDataDrivenModifier(caster,caster,"modifier_thdots_komachi_01_02",{})
					ability:SetLevel(0)
				else
					keys.ability:ApplyDataDrivenModifier(caster,caster,"modifier_thdots_komachi_01_02",{})
				end
			end
		end

		if modifier:GetStackCount()>0 then
			keys.ability:EndCooldown()
		else
			local modifierThink = caster:FindModifierByName("modifier_thdots_komachi_time_to_add_blink")
			if modifierThink~=nil then
				keys.ability:EndCooldown()
				keys.ability:StartCooldown(modifierThink:GetRemainingTime())
			end
		end
	end
end

function Komachi01_AddBlink(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local modifier = caster:FindModifierByName("modifier_thdots_komachi_blink")
	local stackcount=keys.stackCount
	if caster:HasModifier("modifier_item_wanbaochui") then
		stackcount=keys.stackCount+3
	end
	if modifier == nil then return end
	if modifier:GetStackCount() < stackcount then
		modifier:IncrementStackCount()
	end
end

function Komachi02_NormalAttackLanded(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	if caster:IsRealHero()==false then return end
	if target:IsBuilding() then return end
	local ability = caster:FindAbilityByName("ability_thdots_komachi02")
	if ability~=nil then
		Komachi03_FireEffect(caster,target)			
	end
end

function Komachi02_AttackLanded(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local targets = keys.target_entities
	if caster:IsRealHero()==false then return end
	local deal_damage
	local ability = caster:FindAbilityByName("ability_thdots_komachi02")
	if ability~=nil then
		local Damage = ability:GetAbilityDamage() + FindTelentValue(caster,"special_bonus_unique_elder_titan_2")
		for _,v in pairs(targets) do
			local distance = GetDistanceBetweenTwoVec2D(caster:GetOrigin(),v:GetOrigin())
			if distance < 200 then
				deal_damage = Damage*0.5
				Komachi03_FireEffect(caster,v)
			elseif distance >= 200 then
				deal_damage = Damage*1.0
				Komachi03_FireEffect(caster,v)
				Komachi03_FireEffect(caster,v)
			end

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
	end
end

function Komachi02_FireEffect(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local effectIndex = ParticleManager:CreateParticle("particles/heroes/komachi/ability_komachi_02.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex , 0, caster:GetOrigin())
	ParticleManager:SetParticleControl(effectIndex , 1, caster:GetOrigin())
	ParticleManager:SetParticleControlForward(effectIndex, 1, caster:GetForwardVector())
end

function Komachi03_FireEffect(caster,target)
	local ability = caster:FindAbilityByName("ability_thdots_komachi03")

	if ability~=nil then
		local modifier = target:FindModifierByName("modifier_thdots_komachi_03_soul")

		if caster.komachi03_effectIndex_table == nil then
			caster.komachi03_effectIndex_table = {}
		end

		local effectIndex = ParticleManager:CreateParticle("particles/heroes/komachi/ability_komachi_03.vpcf", PATTACH_CUSTOMORIGIN, target)
		ParticleManager:SetParticleControlEnt(effectIndex, 0, target, 5, "follow_origin", Vector(0,0,0), true)

		if modifier == nil then
			ability:ApplyDataDrivenModifier(caster,target,"modifier_thdots_komachi_03_soul",{})
			modifier = target:FindModifierByName("modifier_thdots_komachi_03_soul")
			modifier:IncrementStackCount()
		else
			if modifier:GetStackCount() < 12 then
				modifier:IncrementStackCount()
				modifier:SetDuration(12.0,true)
			end
		end

		if caster.komachi_03_targets == nil then
			caster.komachi_03_targets = {}
		end

		table.insert(caster.komachi_03_targets,target)
		table.insert(caster.komachi03_effectIndex_table,effectIndex)
	end
end

function OnKomachi03SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	if caster.komachi_03_targets ~= nil then
		for k,v in pairs(caster.komachi_03_targets) do
			if v:IsNull()==false and v ~= nil then
				local modifier = v:FindModifierByName("modifier_thdots_komachi_03_soul")
				if modifier~=nil then
					local deal_damage = (keys.soul_damage + v:GetMaxHealth()*(keys.soul_percent_damage+FindTelentValue(caster,"special_bonus_unique_elder_titan_3"))/100 ) * modifier:GetStackCount()
					local damage_table = {
							ability = keys.ability,
						    victim = v,
						    attacker = caster,
						    damage = deal_damage,
						    damage_type = keys.ability:GetAbilityDamageType(), 
				    	    damage_flags = keys.ability:GetAbilityTargetFlags()
					}
					UnitDamageTarget(damage_table)
					if caster.komachi03_effectIndex_table~=nil then
						--for num,effectIndex in pairs(caster.komachi03_effectIndex_table) do							
							OnKomachi03SpellEndEffect(v)
						--end
						v:RemoveModifierByName("modifier_thdots_komachi_03_soul")						
					end					
				end
			end
		end
		caster.komachi03_effectIndex_table = {}
	end
	caster.komachi_03_targets = {}
end

function OnKomachi03SpellEffectEnd(keys)
	local target = keys.target
	local caster = keys.caster
	for k,v in pairs(caster.komachi_03_targets) do
		if v == target then
			ParticleManager:DestroyParticleSystem(caster.komachi03_effectIndex_table[k],true)
		end
	end
end

function OnKomachi03SpellEndEffect(target)
	local effectIndex = ParticleManager:CreateParticle("particles/heroes/komachi/ability_komachi_03_explosion_2.vpcf", PATTACH_CUSTOMORIGIN, nil)
	local vec = target:GetOrigin()+RandomVector(100)+Vector(0,0,128)
	ParticleManager:SetParticleControl(effectIndex , 0, vec)
	--ParticleManager:SetParticleControl(effectIndex , 1, vec)
	--ParticleManager:SetParticleControl(effectIndex , 3, vec)
	--ParticleManager:SetParticleControl(effectIndex , 5, vec)
end

function OnKomachi04SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	if is_spell_blocked(keys.target) then return end
	local target = keys.target
	local time = 0
	keys.ability:ApplyDataDrivenModifier(caster,target,"modifier_thdots_komachi_04_debuff",{})
	local effectIndex = ParticleManager:CreateParticle("particles/heroes/komachi/ability_komachi_04_circle.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControlEnt(effectIndex, 0, target, 5, "follow_origin", Vector(0,0,0), true)

	target:SetContextThink(DoUniqueString("OnKomachi04SpellStart"), 
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			if target:GetHealth() < ( target:GetMaxHealth() * (keys.KillHp + FindTelentValue(caster,"special_bonus_unique_elder_titan_4")) * 0.01 ) and target:IsAlive() and caster:IsAlive() then 
				OnKomachi04KillTarget(keys)
				ParticleManager:DestroyParticleSystem(effectIndex,true)
				return nil
			elseif time > keys.duration then
				ParticleManager:DestroyParticleSystem(effectIndex,true)
				return nil
			elseif not target:HasModifier("modifier_thdots_komachi_04_debuff") then
				ParticleManager:DestroyParticleSystem(effectIndex,true)
				return nil
			end
			time = time + 0.03
			return 0.03
		end,
	0.03)
end

function OnKomachi04KillTarget(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local target = keys.target

	keys.ability:ApplyDataDrivenModifier(caster,caster,"modifier_thdots_komachi_04",{})
	keys.ability:ApplyDataDrivenModifier(caster,target,"modifier_thdots_komachi_04",{})
	caster:AddNoDraw()

	local rad = GetRadBetweenTwoVec2D(caster:GetOrigin(),target:GetOrigin())
	local tarForward = Vector(math.cos(rad),math.sin(rad),0)

	target:SetForwardVector(tarForward)
	PlayerResource:SetCameraTarget(caster:GetPlayerOwnerID(), caster)

	local effectIndex_start = ParticleManager:CreateParticle("particles/heroes/komachi/ability_komachi_04_start.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(effectIndex_start, 0, vecCaster)
	ParticleManager:SetParticleControlForward(effectIndex_start, 0, tarForward)

	caster:SetContextThink(DoUniqueString("OnKomachi04SpellStart"), 
		function ()
			if GameRules:IsGamePaused() then return 0.03 end

			local effectIndex = ParticleManager:CreateParticle("particles/heroes/komachi/ability_komachi_04_blink.vpcf", PATTACH_CUSTOMORIGIN, target)
			ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin()-tarForward*250)
			ParticleManager:SetParticleControlForward(effectIndex, 0, tarForward)

			caster:SetOrigin(target:GetOrigin()-tarForward*150)
			caster:SetForwardVector(tarForward)
			caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)
			caster:RemoveNoDraw()
			
			return nil
		end,
	2.0)

	caster:SetContextThink(DoUniqueString("OnKomachi04SpellStart_stage_2"), 
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			if(caster~=nil)then
				target:Kill(keys.ability, caster)
			else
				target:Kill(keys.ability, nil)
			end
			caster:RemoveModifierByName("modifier_thdots_komachi_04")
			target:RemoveModifierByName("modifier_thdots_komachi_04")

			local effectIndex_end = ParticleManager:CreateParticle("particles/heroes/komachi/ability_komachi_04_scythe.vpcf", PATTACH_CUSTOMORIGIN, target)
			ParticleManager:SetParticleControl(effectIndex_end, 0, target:GetOrigin())
			ParticleManager:SetParticleControl(effectIndex_end, 1, target:GetOrigin())
			
			PlayerResource:SetCameraTarget(caster:GetPlayerOwnerID(), nil)
			return nil
		end,
	4.0)
end