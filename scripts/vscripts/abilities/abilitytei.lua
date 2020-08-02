abilitytei = class({})

function Tei01OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local duration = FindValueTHD("duration",ability)
	local odds = FindValueTHD("odds",ability)
	local heal = FindValueTHD("regen",ability)
	local effectIndex
	print(caster.debuff_count)
	if caster:HasModifier("modifier_ability_thdots_tei04") then
		odds = 100
	end
	if caster:GetModifierStackCount("modifier_ability_thdots_tei01_count", caster) >= FindValueTHD("count",ability) then
		odds = 100
	end
	if caster:HasModifier("modifier_item_wanbaochui") and caster:GetHealth() <= caster:GetMaxHealth()*0.3 then --万宝槌效果
		local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 450,
				DOTA_UNIT_TARGET_TEAM_ENEMY,ability:GetAbilityTargetType(),0,0,false)
		heal = heal * 3
		for _,v in pairs(targets) do
			local damage_table = {
				ability = ability,
				victim = v,
				attacker = caster,
				damage = heal,
				damage_type = keys.ability:GetAbilityDamageType()
				}
			UnitDamageTarget(damage_table)
		end
		if RollPercentage(50) then
			heal = caster:GetHealth() - 1
		end
		effectIndex = ParticleManager:CreateParticle("particles/heroes/tei/boom_wanbaochui.vpcf", PATTACH_POINT, caster)
		local damage_table = {
			ability = ability,
			victim = caster,
			attacker = caster,
			damage = heal,
			damage_type = keys.ability:GetAbilityDamageType()
			}
		UnitDamageTarget(damage_table)
		ParticleManager:DestroyParticleSystemTime(effectIndex,duration/2)
		caster:EmitSound("Hero_Techies.Suicide")
		return
	end
	if RandomInt(0,100) <= odds then
		local random = RandomInt(1,4)
		caster:SetModifierStackCount("modifier_ability_thdots_tei01_count", caster, 0)
		if random == 1 then
			if caster:HasModifier("modifier_item_wanbaochui") then
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_ability_thdots_tei01_movebonus_wanbaochui",{Duration = duration})
			else
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_ability_thdots_tei01_movebonus",{Duration = duration})
			end
		elseif random == 2 then
			if caster:HasModifier("modifier_item_wanbaochui") then
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_ability_thdots_tei01_attackbonus_wanbaochui",{Duration = duration})
			else
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_ability_thdots_tei01_attackbonus",{Duration = duration})
			end
		elseif random == 3 then
			if caster:HasModifier("modifier_item_wanbaochui") then
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_ability_thdots_tei01_damagebonus_wanbaochui",{Duration = duration})
			else
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_ability_thdots_tei01_damagebonus",{Duration = duration})
			end
		elseif random == 4 then
			if caster:HasModifier("modifier_item_wanbaochui") then
				heal = FindValueTHD("regen_wanbaochui",ability)
			end
			caster:Heal(heal, caster)
			SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,caster,heal,nil)
			caster:EmitSound("Rune.Regen")
			return
		end
		caster:EmitSound("DOTA_Item.PhaseBoots.Activate")
		effectIndex = ParticleManager:CreateParticle("particles/heroes/tei/tei01buff.vpcf", PATTACH_POINT, caster)
		ParticleManager:DestroyParticleSystemTime(effectIndex,duration)
	else
		local random = RandomInt(1,4)
		caster:FindModifierByName("modifier_ability_thdots_tei01_count"):IncrementStackCount()
		if random == 1 then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_ability_thdots_tei01_movereduce",{Duration = duration/2})
		elseif random == 2 then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_ability_thdots_tei01_attackreduce",{Duration = duration/2})
		elseif random == 3 then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_ability_thdots_tei01_damagereduce",{Duration = duration/2})
		elseif random == 4 then
			local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, FindValueTHD("radius",ability),
				DOTA_UNIT_TARGET_TEAM_ENEMY,ability:GetAbilityTargetType(),0,0,false)
			for _,v in pairs(targets) do
				local damage_table = {
					ability = ability,
					victim = v,
					attacker = caster,
					damage = heal,
					damage_type = keys.ability:GetAbilityDamageType()
					}
				UnitDamageTarget(damage_table)
			end
			local damage_table = {
				ability = ability,
				victim = caster,
				attacker = caster,
				damage = heal,
				damage_type = keys.ability:GetAbilityDamageType()
				}
			UnitDamageTarget(damage_table)
			effectIndex = ParticleManager:CreateParticle("particles/heroes/tei/boom.vpcf", PATTACH_POINT, caster)
			ParticleManager:DestroyParticleSystemTime(effectIndex,duration/2)
			caster:EmitSound("Hero_Techies.Suicide")
			return
		end
		caster:EmitSound("DOTA_Item.Nullifier.Slow")
		effectIndex = ParticleManager:CreateParticle("particles/heroes/tei/tei01debuff.vpcf", PATTACH_POINT, caster)
		ParticleManager:DestroyParticleSystemTime(effectIndex,duration/2)
	end
end

function Tei01Onkill( keys )
	local caster = keys.caster
	local casterPlayerID = caster:GetPlayerOwnerID()
	local GoldBountyAmount= FindValueTHD("gold_bonus",keys.ability)
	caster.ItemAbility_DonationGem_TriggerTime=GameRules:GetGameTime()	--加钱
	PlayerResource:SetGold(casterPlayerID,PlayerResource:GetUnreliableGold(casterPlayerID) + GoldBountyAmount,false)
	SendOverheadEventMessage(caster:GetOwner(),OVERHEAD_ALERT_GOLD,caster,GoldBountyAmount,nil)
end

function Tei01OnUpgrade(keys)
	local caster = keys.caster
	if caster:FindAbilityByName("ability_thdots_teiex") ~= nil then
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_ability_thdots_tei01_ex", {})
	end
end

function Tei02OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local duration = FindValueTHD("duration",keys.ability)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_ability_thdots_tei02_back", {Duration = 0.2})
	ability.forced_direction = caster:GetForwardVector()*Vector(-1,-1,0)
	ability.forced_distance = FindValueTHD("distance",ability)
	ability.forced_speed = 120	-- * 1/30 gives a duration of ~0.4 second push time (which is what the gamepedia-site says it should be)
	ability.forced_traveled = 0
	if caster:HasModifier("modifier_item_wanbaochui") then
		ability.forced_distance = ability.forced_distance * 2
		ability.forced_speed = ability.forced_speed * 2
	end
	-- local illusion = create_illusion(keys,caster:GetOrigin(),400,0.1,duration)
	-- if (illusion ~= nil) then
		
	-- 	illusion:SetHealth(illusion:GetMaxHealth()*caster:GetHealthPercent()*0.01)
	-- 	illusion:SetMana(illusion:GetMaxMana()*caster:GetManaPercent()*0.01)
	-- 	illusion:SetModel("models/tei_pistol/tei2_pistol.vmdl")
	-- 	illusion:SetModelScale(caster:GetModelScale())
	-- end
	local illusion_create = CreateIllusions(caster,caster,{
		outgoing_damage 			= -70,
		incoming_damage				= 400,
		bounty_base					= keys.ability:GetLevel() * 2,
		bounty_growth				= nil,
		outgoing_damage_structure	= nil,
		outgoing_damage_roshan		= nil,
--			duration					= self:GetSpecialValueFor("illusion_duration")
		duration					= duration -- IMBAfication: Everlasting Reflection
	},1,caster:GetHullRadius(),true,true)
	local illusion = illusion_create[1]
	if illusion ~= nil then
		local casterAngles = caster:GetAnglesAsVector()
		illusion:SetAngles(casterAngles.x,casterAngles.y,casterAngles.z)
		keys.ability:ApplyDataDrivenModifier(caster, illusion, "modifier_ability_thdots_tei02_illusion", {Duration = duration})
		illusion:SetModel("models/tei_pistol/tei2_pistol.vmdl")
		illusion:SetModelScale(caster:GetModelScale())
	end
end

function Tei02Back( keys )
	local caster = keys.caster
	local ability = keys.ability
	if ability.forced_traveled < ability.forced_distance then
		print(ability.forced_traveled)
		print(ability.forced_distance)
		caster:SetAbsOrigin(caster:GetAbsOrigin() + ability.forced_direction * ability.forced_speed)
		ability.forced_traveled = ability.forced_traveled + (ability.forced_direction * ability.forced_speed):Length2D()
		GridNav:DestroyTreesAroundPoint(caster:GetAbsOrigin(), 80,false)
	else
		caster:InterruptMotionControllers(true)
	end
end

function Tei02Destroy( keys )
	local caster = keys.caster
	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
end

function Tei02OnDestroy( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local targets = FindUnitsInRadius(caster:GetTeam(),target:GetAbsOrigin(),nil,FindValueTHD("radius",ability),ability:GetAbilityTargetTeam(),
		ability:GetAbilityTargetType() ,0,0,false)
	for _,v in pairs(targets) do
		local damage_table = {
			ability = ability,
			victim = v,
			attacker = caster,
			damage = FindValueTHD("damage",ability) + FindTelentValue(caster,"special_bonus_unique_tei_1"),
			damage_type = keys.ability:GetAbilityDamageType()
			}
		UnitDamageTarget(damage_table)
		ability:ApplyDataDrivenModifier(caster, v, "modifier_ability_thdots_tei02_debuff", {Duration = FindValueTHD("debuff_duration",ability)})
	end
	target:EmitSound("Hero_Techies.LandMine.Detonate")
	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_blast_off.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControl(effectIndex , 0, target:GetOrigin())
	ParticleManager:DestroyParticleSystem(effectIndex,false)
end

function create_illusion(keys, illusion_origin, illusion_incoming_damage, illusion_outgoing_damage, illusion_duration)	
	local player_id = keys.caster:GetPlayerID()
	local caster_team = keys.caster:GetTeam()
	local tmp = keys.caster
	if GetMapName() == "dota" then
		tmp = nil
	end
	
	local illusion = CreateUnitByName(keys.caster:GetUnitName(), illusion_origin, true, keys.caster, tmp, caster_team)  --handle_UnitOwner needs to be nil, or else it will crash the game.
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

	--Recreate the caster's items for the illusion.
	for item_slot = 0, 5 do
		local individual_item = keys.caster:GetItemInSlot(item_slot)
		if individual_item ~= nil then
			local illusion_duplicate_item = CreateItem(individual_item:GetName(), illusion, illusion)
			illusion:AddItem(illusion_duplicate_item)
			illusion_duplicate_item:SetPurchaser(nil)
		end
	end
	
	-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle 
	illusion:AddNewModifier(keys.caster, keys.ability, "modifier_illusion", {duration = illusion_duration, outgoing_damage = illusion_outgoing_damage, incoming_damage = illusion_incoming_damage})
	illusion:MakeIllusion()  --Without MakeIllusion(), the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.  Without it, IsIllusion() returns false and IsRealHero() returns true.

	return illusion
end

function Tei03OnSpellStart(keys )
	local caster = keys.caster
	caster.attact = 1
	if caster:GetName() == "npc_dota_hero_gyrocopter" then
		caster:SetModel("models/tei_pistol/tei2_pistol.vmdl")
		caster:SetOriginalModel("models/tei_pistol/tei2_pistol.vmdl")
	end
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_ability_thdots_tei03", {Duration = FindValueTHD("duration",keys.ability)})
	--  for i=0,5 do --禁用月兔幻觉兵器
	-- 	local item = caster:GetItemInSlot(i)
	-- 	if item ~= nil and item:GetName() == "item_inaba_illusion_weapon" then
	-- 		print(item:GetName())
	-- 		item:SetContainedItem(item)
	-- 	end SetStickyItemDisabled(bDisabled)
	-- end
end

function Tei03OnDestroy( keys )
	local caster = keys.caster
	if caster:GetName() == "npc_dota_hero_gyrocopter" then
		caster:SetModel("models/tei/tei2.vmdl")
		caster:SetOriginalModel("models/tei/tei2.vmdl")
	end
	--激活月兔幻觉兵器
end

function Tei03OnAttack( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target_number = 0
	if caster.attact ~= 1 then return end
	caster.attact = 1
	caster:EmitSound("Hero_Sniper.MKG_attack")
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, FindValueTHD("radius",keys.ability) + FindTelentValue(caster,"special_bonus_unique_tei_5"),
	ability:GetAbilityTargetTeam(),ability:GetAbilityTargetType(),
	DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE,
	0,false)
	for _,v in pairs(targets) do
		caster.attact = 0
		if v ~= keys.target then
			caster:PerformAttack(v, false, true, true, true, true, false, false)
		end
		caster.attact = 1
	end
end


function Tei03OnUpgrade( keys )
	local caster = keys.caster
	if caster:FindAbilityByName("ability_thdots_teiex") ~= nil then
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_ability_thdots_tei03_ex", {})
	end
	
end


function Tei03ExOnAttacked( keys )--tei03被动：被攻击触发反击
	local caster = keys.caster
	local target = keys.attacker
	local odds = FindValueTHD("odds",keys.ability)
	if target:IsRangedAttacker() then
		odds = odds * 2
	end
	if target:IsIllusion() then
		odds = 50
	end
	if RandomInt(0, 100) <= odds then
		caster.attact = 0
		caster:PerformAttack(target, false, true, true, true, true, false, false)
		caster.attact = 1
		caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_3,(caster:GetDisplayAttackSpeed()-100)/100)
		caster:FaceTowards(target:GetAbsOrigin())
	end
end

function Tei04OnSpellStart( keys )
	local caster = keys.caster
	local duration = FindValueTHD("duration",keys.ability) 
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_ability_thdots_tei04", {Duration = duration})
	local effectIndex = ParticleManager:CreateParticle("particles/heroes/tei/tei04buff.vpcf",PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:DestroyParticleSystemTime(effectIndex,duration)
	if caster:GetName() == "npc_dota_hero_gyrocopter" then
		caster:EmitSound("Hero_Tei04")
	end
end

function Tei04OnAttackLanded( keys )
	local caster = keys.attacker
	local target = keys.target
	local max_count = FindValueTHD("max_count",keys.ability) - FindTelentValue(caster,"special_bonus_unique_tei_3")
	local ulti_gold_to_steal = FindValueTHD("gold_steal",keys.ability) * FindValueTHD("gold_rate",keys.ability)
	if target:IsHero() then
		local count
		if target:HasModifier("modifier_ability_thdots_tei04_debuff") == false then 
			keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_ability_thdots_tei04_debuff",{Duration = FindValueTHD("duration",keys.ability)})
			target:SetModifierStackCount("modifier_ability_thdots_tei04_debuff", keys.ability, 1)
		else
			count = target:GetModifierStackCount("modifier_ability_thdots_tei04_debuff",nil)
			target:SetModifierStackCount("modifier_ability_thdots_tei04_debuff", keys.ability, count + 1)
			target:FindModifierByName("modifier_ability_thdots_tei04_debuff"):SetDuration(FindValueTHD("duration",keys.ability),true)
		end
		if count == max_count then
			--兔子大招偷钱
			local target_money = target:GetGold()
			if target:IsHero() and not target:IsIllusion() and not target:HasModifier("modifier_thdots_yuyukoEx") then
				target:ModifyGold(-ulti_gold_to_steal, false, DOTA_ModifyGold_Unspecified)
				caster:ModifyGold(ulti_gold_to_steal, false, DOTA_ModifyGold_Unspecified)
				SendOverheadEventMessage(caster, OVERHEAD_ALERT_GOLD, caster, ulti_gold_to_steal, nil)
				if caster:HasModifier("modifier_ability_thdots_tei04_ex") then
					caster:FindModifierByName("modifier_ability_thdots_tei04_ex"):SetStackCount(caster:FindModifierByName("modifier_ability_thdots_tei04_ex"):GetStackCount() + ulti_gold_to_steal)
				end
				if ulti_gold_to_steal >= target_money then
					local damage = math.abs(ulti_gold_to_steal -target_money) * FindValueTHD("damage_rate",keys.ability)
					damage = 0
					local damage_table = {
					ability = keys.ability,
					victim = target,
					attacker = caster,
					damage = damage,
					damage_type = keys.ability:GetAbilityDamageType()
					}
					UnitDamageTarget(damage_table)
				end
				local money_particle = ParticleManager:CreateParticle("particles/econ/items/bounty_hunter/bounty_hunter_ti9_immortal/bh_ti9_immortal_jinada.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
				ParticleManager:SetParticleControlEnt(money_particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(money_particle)
				target:SetModifierStackCount("modifier_ability_thdots_tei04_debuff", caster, 0)
				target:RemoveModifierByName("modifier_ability_thdots_tei04_debuff")
			end
		end
	end
end

function Tei04ExOnAttackLanded( keys )
	local caster = keys.attacker
	if caster:IsIllusion() then return end
	local target = keys.target
	local ability = keys.ability
	local normal_count = FindValueTHD("normal_count",keys.ability) - 1
	local attact_gold_to_steal = FindValueTHD("gold_steal",keys.ability)
	if not target:IsBuilding() then
		local count
		if target:HasModifier("modifier_ability_thdots_tei04ex_debuff") == false then
			keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_ability_thdots_tei04ex_debuff",{Duration = FindValueTHD("duration",keys.ability)/2})
			target:SetModifierStackCount("modifier_ability_thdots_tei04ex_debuff", keys.ability, 1)
		else
			count = target:GetModifierStackCount("modifier_ability_thdots_tei04ex_debuff", nil)
			target:SetModifierStackCount("modifier_ability_thdots_tei04ex_debuff", keys.ability, count + 1)
			target:FindModifierByName("modifier_ability_thdots_tei04ex_debuff"):SetDuration(FindValueTHD("duration",keys.ability)/2,true)
		end
		if count == normal_count then
			--兔子天生偷钱
			if target:IsHero() and not target:IsIllusion() and not target:HasModifier("modifier_thdots_yuyukoEx") then
				target:ModifyGold(-300, false, DOTA_ModifyGold_Unspecified)
				caster:ModifyGold(attact_gold_to_steal, false, DOTA_ModifyGold_Unspecified)
				SendOverheadEventMessage(caster, OVERHEAD_ALERT_GOLD, caster, attact_gold_to_steal, nil)
				local money_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_jinada.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
				ParticleManager:SetParticleControlEnt(money_particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(money_particle)
				if caster:HasModifier("modifier_ability_thdots_tei04_ex") then
					caster:FindModifierByName("modifier_ability_thdots_tei04_ex"):SetStackCount(caster:FindModifierByName("modifier_ability_thdots_tei04_ex"):GetStackCount() + attact_gold_to_steal)
				end
			end
			local damage_table = {
			ability = keys.ability,
			victim = target,
			attacker = caster,
			damage = FindValueTHD("damage",ability),
			damage_type = keys.ability:GetAbilityDamageType()
			}
			UnitDamageTarget(damage_table)
			target:SetModifierStackCount("modifier_ability_thdots_tei04ex_debuff", caster, 0)
			target:RemoveModifierByName("modifier_ability_thdots_tei04ex_debuff")
		end
	end
end

function Tei04OnUpgrade( keys )
	local caster = keys.caster
	if caster:FindAbilityByName("ability_thdots_teiex") ~= nil then
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_ability_thdots_tei04_ex", {})
	end
end

function Tei04Debuff( keys )
	local caster = keys.caster
	local target = keys.target
	target.armor = target:GetPhysicalArmorBaseValue()
	local armor_reduce = FindValueTHD("armor_reduce",keys.ability)/100 + FindTelentValue(caster,"special_bonus_unique_tei_2")
	target:SetPhysicalArmorBaseValue(-target.armor*armor_reduce)
end
function Tei04DebuffDestroy( keys )
	local target = keys.target
	target:SetPhysicalArmorBaseValue(0)
end