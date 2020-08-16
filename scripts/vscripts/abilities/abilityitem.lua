
---------------------------------------------------------------------------------------
--[[
DEBUG FUNCTIONS
]]

--ITEM_DEBUG=true


function ItemAbility_wanbaochui02_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local caster = keys.caster
	local target = keys.target
	local TargetName = target:GetClassname()
	if target ~= caster and target:IsRealHero() == false then 
		print("No")
		return 
	else
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_wanbaochui", {})
		if (ItemAbility:IsItem()) then
			caster:RemoveItem(ItemAbility)
		end	
		if TargetName == "npc_dota_hero_chaos_knight" then
			return
		end
		if TargetName == "npc_dota_hero_clinkz" then
			return
		end
		keys.caster:AddNewModifier(keys.caster, nil, "modifier_item_ultimate_scepter", {duration = -1})
	end	
end


-- dota2 default support for aghanim scepter.
--[[ ============================================================================================================
	Author: Rook
	Date: January 26, 2015
	Called when Aghanim's Scepter is sold or dropped.  Removes the stock Aghanim's Scepter modifier if no other 
	Aghanim's Scepters exist in the player's inventory.
================================================================================================================= ]]

function modifier_item_ultimate_scepter_datadriven_on_created(keys)
	if not keys.caster:HasModifier("modifier_item_ultimate_scepter") then
		local target = keys.caster
	    local TargetName = target:GetClassname()
	    if TargetName == "npc_dota_hero_chaos_knight" then
			return
		end
		if TargetName == "npc_dota_hero_clinkz" then
			return
		end
		keys.caster:AddNewModifier(keys.caster, nil, "modifier_item_ultimate_scepter", {duration = -1})
	end
end

function modifier_item_ultimate_scepter_datadriven_on_destroy(keys)
	local num_scepters_in_inventory = 0


	for i=0, 5, 1 do  --Search for Aghanim's Scepters in the player's inventory.
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item ~= nil then
			local item_name = current_item:GetName()
			
			if item_name == "item_wanbaochui" then
				num_scepters_in_inventory = num_scepters_in_inventory + 1
			end
		end
	end

	if keys.caster:HasModifier("modifier_item_wanbaochui") then
		--has wanbaochui buff.
		return
	end

	--Remove the stock Aghanim's Scepter modifier if the player no longer has a scepter in their inventory.
	if num_scepters_in_inventory == 0 and keys.caster:HasModifier("modifier_item_ultimate_scepter") then
		keys.caster:RemoveModifierByName("modifier_item_ultimate_scepter")
	end
end

function ItemAbility_UFO_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local caster = keys.caster
	local target = keys.target
	if target ~= caster and target:IsRealHero() == false then 
		print("No")
		return 
	else
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_UFO_attack_speed_bonus", {})
		if (ItemAbility:IsItem()) then
			caster:RemoveItem(ItemAbility)
		end	
	end	
end

function ItemAbility_feixiangjian_OnAttack(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	if (Caster:IsRealHero() and Target:IsBuilding()==false) then
		local damage_to_deal =keys.PureDamage
		if Target:GetUnitName()=="npc_dota_roshan" then damage_to_deal=damage_to_deal*0.45 end
		local damage_table = {
			ability = ItemAbility,
			victim = Target,
			attacker = Caster,
			damage = damage_to_deal,
			damage_type = DAMAGE_TYPE_PURE,
			damage_flags = 1
		}
		UnitDamageTarget(damage_table)
		
		--SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_SPELL_DAMAGE,Target,damage_to_deal,nil)
		--PrintTable(damage_table)
		--DebugPrint("ItemAbility_Camera_OnAttack| Damage:"..damage_to_deal)
	end
end

function ItemAbility_specialcourier_OnSpellStart(keys)
	local Caster = keys.caster
	local unit = CreateUnitByName(
			"npc_dota_courier"
			,Caster:GetOrigin() + ( Caster:GetForwardVector() * 100 )
			,false
			,Caster
			,Caster
			,Caster:GetTeam()
		)
	unit:SetControllableByPlayer(Caster:GetPlayerOwnerID(), false)
	unit:SetOriginalModel("models/items/courier/chocobo/chocobo_flying.vmdl")	
	

	--local ability = unit:FindAbilityByName("courier_burst")
	--ability:SetLevel(1)

	local ability = unit:AddAbility("ability_system_fly")
	ability:SetLevel(1)

	--ability = unit:FindAbilityByName("courier_morph")
	--ability:SetLevel(1)
	--unit:CastAbilityNoTarget(ability,0)
	ItemAbility_SpendItem(keys)
end

function ItemAbility_xuenvdeweijin_Physical_Block(keys)
	local Caster = keys.caster
	local AttackCapability=Caster:GetAttackCapability()
	local IsMelee=false
	local damageblock=0
	if AttackCapability==DOTA_UNIT_CAP_MELEE_ATTACK then 
		IsMelee=true
	else 
		IsMelee=false
	end
	if  IsMelee==true then
		damageblock = keys.DamageBlock
	else
		damageblock = keys.DamageBlock-10
	end
	local DamageBlock = min(damageblock,keys.DamageTaken)
	--print("block")
	--DebugPrint("ItemAbility_xuenvdeweijin_Physical Block: "..DamageBlock)
	if (Caster:GetHealth() + DamageBlock <= keys.DamageTaken) then return end
	Caster:SetHealth(Caster:GetHealth()+DamageBlock)
	SendOverheadEventMessage(nil,OVERHEAD_ALERT_BLOCK,Caster,DamageBlock,nil)
end

function item_xuenvdeweijin_on_spell_start(keys)
	local shivas_guard_particle = ParticleManager:CreateParticle("particles/items2_fx/shivas_guard_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)
	ParticleManager:SetParticleControl(shivas_guard_particle, 1, Vector(keys.BlastFinalRadius, keys.BlastFinalRadius / keys.BlastSpeedPerSecond, keys.BlastSpeedPerSecond))
	
	keys.caster:EmitSound("DOTA_Item.ShivasGuard.Activate")
	keys.caster.xuenvdeweijin_blast_radius=0.0
	keys.caster:SetThink(function ()
		if (keys.caster.xuenvdeweijin_blast_radius>=keys.BlastFinalRadius) then 
			return nil 
		end
		keys.ability:CreateVisibilityNode(keys.caster:GetAbsOrigin(), keys.BlastVisionRadius, keys.BlastVisionDuration)
		keys.caster.xuenvdeweijin_blast_radius = keys.caster.xuenvdeweijin_blast_radius + (keys.BlastSpeedPerSecond *0.03)
		local nearby_enemy_units = FindUnitsInRadius(keys.caster:GetTeam(), keys.caster:GetAbsOrigin(), nil, keys.caster.xuenvdeweijin_blast_radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

			for i, individual_unit in ipairs(nearby_enemy_units) do
				if not individual_unit:HasModifier("modifier_item_xuenvdeweijin_blast_debuff") then
					local damage_table = {
						ability = keys.ability,
						victim = individual_unit,
						attacker = keys.caster,
						damage = keys.BlastDamage,
						damage_type = DAMAGE_TYPE_MAGICAL,
						damage_flags = 0
					}
					UnitDamageTarget(damage_table)					
					
					--This impact particle effect should radiate away from the caster of Shiva's Guard.
					local shivas_guard_impact_particle = ParticleManager:CreateParticle("particles/items2_fx/shivas_guard_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, individual_unit)
					local target_point = individual_unit:GetAbsOrigin()
					local caster_point = individual_unit:GetAbsOrigin()
					ParticleManager:SetParticleControl(shivas_guard_impact_particle, 1, target_point + (target_point - caster_point) * 30)
					
					keys.ability:ApplyDataDrivenModifier(keys.caster, individual_unit, "modifier_item_xuenvdeweijin_blast_debuff", nil)
				end
			end
		return 0.03
	end)

	--[[Timers:CreateTimer({
				endTime = .03, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
				callback = function()
					keys.ability:CreateVisibilityNode(keys.caster:GetAbsOrigin(), keys.BlastVisionRadius, keys.BlastVisionDuration)  --Shiva's Guard's active provides 800 flying vision around the caster, which persists for 2 seconds.
				
					keys.caster.xuenvdeweijin_blast_radius = keys.caster.xuenvdeweijin_blast_radius + (keys.BlastSpeedPerSecond * .03)
					local nearby_enemy_units = FindUnitsInRadius(keys.caster:GetTeam(), keys.caster:GetAbsOrigin(), nil, keys.caster.xuenvdeweijin_blast_radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
					DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		
					for i, individual_unit in ipairs(nearby_enemy_units) do
						if not individual_unit:HasModifier("modifier_item_xuenvdeweijin_blast_debuff") then
							ApplyDamage({victim = individual_unit, attacker = keys.caster, damage = keys.BlastDamage, damage_type = DAMAGE_TYPE_MAGICAL,})
							
							--This impact particle effect should radiate away from the caster of Shiva's Guard.
							local shivas_guard_impact_particle = ParticleManager:CreateParticle("particles/items2_fx/shivas_guard_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, individual_unit)
							local target_point = individual_unit:GetAbsOrigin()
							local caster_point = individual_unit:GetAbsOrigin()
							ParticleManager:SetParticleControl(shivas_guard_impact_particle, 1, target_point + (target_point - caster_point) * 30)
							
							keys.ability:ApplyDataDrivenModifier(keys.caster, individual_unit, "modifier_item_xuenvdeweijin_blast_debuff", nil)
						end
					end
					
					if keys.caster.xuenvdeweijin_blast_radius < keys.BlastFinalRadius then  --If the blast should still be expanding.
						return .03
					else  --The blast has reached or exceeded its intended final radius.
						keys.caster.xuenvdeweijin_blast_radius = 0
						return nil
					end
				end
			})]]
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 15, 2015
	Called when the debuff aura modifier is created and regularly while it is on an enemy unit.  Since the debuff aura
	modifier should only be visible if the enemy team has vision over its emitter, check to see if this is the case and
	add or remove a visible aura accordingly.
================================================================================================================= ]]


--[[ ============================================================================================================
	Author: Rook
	Date: February 15, 2015
	Called when the debuff aura modifier is removed.  Removes the associated visible modifier, if applicable.
================================================================================================================= ]]


function ForceStaff (keys)

	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1	

	ability.forced_direction = target:GetForwardVector()
	ability.forced_distance = ability:GetLevelSpecialValueFor("push_length", ability_level)
	ability.forced_speed = ability:GetLevelSpecialValueFor("push_speed", ability_level) * 1/30	-- * 1/30 gives a duration of ~0.4 second push time (which is what the gamepedia-site says it should be)
	ability.forced_traveled = 0

end

function ForceHorizontal( keys )

	local target = keys.target
	local ability = keys.ability

	if ability.forced_traveled < ability.forced_distance then
		target:SetAbsOrigin(target:GetAbsOrigin() + ability.forced_direction * ability.forced_speed)
		ability.forced_traveled = ability.forced_traveled + (ability.forced_direction * ability.forced_speed):Length2D()
	else
		target:InterruptMotionControllers(true)
	end

end


function modifier_item_heavens_halberd_datadriven_on_attack_landed_random_on_success(keys)
	if keys.target.GetInvulnCount == nil then  --If the target is not a structure.
		keys.target:EmitSound("DOTA_Item.Maim")
		keys.ability:ApplyDataDrivenModifier(keys.attacker, keys.target, "modifier_item_heavens_halberd_datadriven_lesser_maim", nil)
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 4, 2015
	Called when Heaven's Halberd is cast on an enemy unit.  Applies a disarm with a duration dependant on whether the
	target is melee or ranged.
	Additional parameters: keys.DisarmDurationRanged and keys.DisarmDurationMelee
================================================================================================================= ]]
function item_heavens_halberd_datadriven_on_spell_start(keys)
	if is_spell_blocked(keys.target) then return end
	keys.caster:EmitSound("DOTA_Item.HeavensHalberd.Activate")
	
	if keys.target:IsRangedAttacker() then
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_heavens_halberd_datadriven_disarm", {duration = keys.DisarmDurationRanged})
	else  --The target is melee.
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_heavens_halberd_datadriven_disarm", {duration = keys.DisarmDurationMelee})
	end
end

function ItemAbility_tuzhushen_OnSpellStart(keys)
	local caster = keys.caster
	local target = keys.target
	target:Purge(false,true,false,true,false)
end

function GetCurrentCoolDown(ability, Caster)
	local cd_len = ability:GetCooldown(ability:GetLevel())
	if Caster:HasModifier("modifier_cooldown_reduction_80") then
		cd_len = cd_len * 0.2;
	elseif Caster:HasModifier("modifier_item_nuclear_stick_cooldown_reduction") then
		cd_len = cd_len * 0.75;
	end
	return cd_len
end

function PrintTargetInfo(target)
	print("Target Name:"..target:GetName())
	print("Target ModelName: "..target:GetModelName())
	
	print("Target Has Abilities("..tostring(target:GetAbilityCount())..")")
	for i=0,target:GetAbilityCount()-1 do
		local indent="\t"
		local Ability=target:GetAbilityByIndex(i)
		if Ability then
			print(indent.."Target's Ability index:"..tostring(i).." name:"..Ability:GetName())
			indent=indent.."\t"
			print(indent.."GetLevel:"..tostring(Ability:GetLevel()))
		end
	end
	
	print("Target Has Modifiers("..tostring(target:GetModifierCount()).."):")
	for i=0,target:GetModifierCount()-1 do
		local indent="\t"
		local ModifierName=target:GetModifierNameByIndex(i)
		print(indent.."Target's Modifier index:"..tostring(i).." name:"..ModifierName)
		local ModifierClass=target:FindModifierByName(ModifierName)
		if ModifierClass then
			indent=indent.."\t"
			local Ability=ModifierClass:GetAbility()
			if Ability then
				print(indent.."GetAbility:"..tostring(Ability))
				print(indent.."GetAbility Name:"..Ability:GetAbilityName())
			end
			print(indent.."CDOTA_Modifier_Lua:GetAttributes:"..tostring(CDOTA_Modifier_Lua.GetAttributes(ModifierClass)))
			print(indent.."GetStackCount:"..tostring(ModifierClass:GetStackCount()))
			print(indent.."GetDuration:"..tostring(ModifierClass:GetDuration()))
			print(indent.."GetRemainingTime:"..tostring(ModifierClass:GetRemainingTime()))
			print(indent.."GetClass:"..ModifierClass:GetClass())
			print(indent.."GetCaster Name"..ModifierClass:GetCaster():GetName())
			print(indent.."GetParent Name"..ModifierClass:GetParent():GetName())
		end
	end
end

function ItemAbility_Debug_GetGold(keys)
	DebugPrint("ItemAbility_GetGold"..keys.bonus_gold)
	local Caster = keys.caster
	local CasterPlayerID = Caster:GetPlayerID()
	PlayerResource:SetGold(CasterPlayerID,PlayerResource:GetUnreliableGold(CasterPlayerID) + keys.bonus_gold,false)
end
function ItemAbility_Debug_PrintHealth(keys)
	if (keys.caster) then
		DebugPrint(keys.debug_string.."caster health is "..keys.caster:GetHealth())
	end
	if (keys.target) then
		DebugPrint(keys.debug_string.."target health is "..keys.target:GetHealth())
	end
end

function DebugPrint(msg)
	if ITEM_DEBUG==true then print(msg) end
end

function DebugFunction(func,...)
	if ITEM_DEBUG then func(...) end
end
---------------------------------------------------------------------------------------
-- UTIL Functions

function clamp (Num, Min, Max)
	if (Num>Max) then return Max
	elseif (Num<Min) then return Min
	else return Num
	end
end

function round (num)
	return math.floor(num + 0.5)
end
 
function distance(a, b)
    local xx = (a.x-b.x)
    local yy = (a.y-b.y)
    return math.sqrt(xx*xx + yy*yy)
end

function GetAngleBetweenTwoVec(a,b)
	local y = b.y - a.y
	local x = b.x - a.x
	return math.atan2(y,x)
end

function ItemAbility_SpendItem(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	
	if (ItemAbility:IsItem()) then
		local Charge = ItemAbility:GetCurrentCharges()
		if (Charge>1) then
			ItemAbility:SetCurrentCharges(Charge-1)
		else
			Caster:RemoveItem(ItemAbility)
		end
	end
end

function PrintTable(t, indent, done)
	--DebugPrint ( string.format ('PrintTable type %s', type(keys)) )
    if type(t) ~= "table" then return end

    done = done or {}
    done[t] = true
    indent = indent or 0

    local l = {}
    for k, v in pairs(t) do
        table.insert(l, k)
    end

    table.sort(l)
    for k, v in ipairs(l) do
        -- Ignore FDesc
        if v ~= 'FDesc' then
            local value = t[v]

            if type(value) == "table" and not done[value] then
                done [value] = true
                DebugPrint(string.rep ("\t", indent)..tostring(v)..":")
                PrintTable (value, indent + 2, done)
            elseif type(value) == "userdata" and not done[value] then
                done [value] = true
                DebugPrint(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
                PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
            else
                if t.FDesc and t.FDesc[v] then
                    DebugPrint(string.rep ("\t", indent)..tostring(t.FDesc[v]))
                else
                    DebugPrint(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
                end
            end
        end
    end
end

function PrintKeys(keys)
	PrintTable(keys)
end

function UnitStunTarget(caster,target,stuntime)
    UtilStun:UnitStunTarget(caster,target,stuntime)
end

-- extra keys params:
-- string ModifierName
-- int Blockable
-- int ApplyToTower
function ItemAbility_ModifierTarget(keys)
	local ItemAbility = keys.ability
	local Caster = keys.Caster or keys.caster
	local Target = keys.Target or keys.target
	if Caster and Target and Caster:GetTeam()~=Target:GetTeam() then
		if keys.Blockable==1 and is_spell_blocked_by_hakurei_amulet(Target) then
			return
		elseif (not keys.ApplyToTower or keys.ApplyToTower==0) and Target:IsBuilding() then
			return
		end
	end
	ItemAbility:ApplyDataDrivenModifier(Caster,Target,keys.ModifierName,{})
end

function Item_frozen_frog_Ability_ModifierTarget(keys)
	local ItemAbility = keys.ability
	local Caster = keys.Caster or keys.caster
	local Target = keys.Target or keys.target
	if Caster and Target and Caster:GetTeam()~=Target:GetTeam() then
		if keys.Blockable==1 and is_spell_blocked_by_hakurei_amulet(Target) then
			return
		elseif (not keys.ApplyToTower or keys.ApplyToTower==0) and Target:IsBuilding() then
			return
		end
	end
	ItemAbility:ApplyDataDrivenModifier(Caster,Target,keys.ModifierName,{})
	Target:AddNewModifier(Caster, ItemAbility, "modifier_item_frozen_frog_cold_debuff_reduce_regen", {duration = ItemAbility:GetSpecialValueFor("cold_duration")})
end

modifier_item_frozen_frog_cold_debuff_reduce_regen = {}
LinkLuaModifier("modifier_item_frozen_frog_cold_debuff_reduce_regen","scripts/vscripts/abilities/abilityItem.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_item_frozen_frog_cold_debuff_reduce_regen:IsHidden() 		return true end
function modifier_item_frozen_frog_cold_debuff_reduce_regen:IsPurgable()		return true end
function modifier_item_frozen_frog_cold_debuff_reduce_regen:RemoveOnDeath() 	return true end
function modifier_item_frozen_frog_cold_debuff_reduce_regen:IsDebuff()		return true end

function modifier_item_frozen_frog_cold_debuff_reduce_regen:DeclareFunctions()	
	return {
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_TOOLTIP
	}
end

function modifier_item_frozen_frog_cold_debuff_reduce_regen:GetModifierHealAmplify_PercentageTarget()
	return -40
end

function modifier_item_frozen_frog_cold_debuff_reduce_regen:GetModifierHPRegenAmplify_Percentage()
	return -40
end

function modifier_item_frozen_frog_cold_debuff_reduce_regen:OnTooltip()
	return -40
end

function Item_tentacle_Ability_ModifierTarget(keys)
	local ItemAbility = keys.ability
	local Caster = keys.Caster or keys.caster
	local Target = keys.Target or keys.target
	-- if Caster and Target and Caster:GetTeam()~=Target:GetTeam() then
	-- 	if keys.Blockable==1 and is_spell_blocked_by_hakurei_amulet(Target) then
	-- 		return
	-- 	elseif (not keys.ApplyToTower or keys.ApplyToTower==0) and Target:IsBuilding() then
	-- 		return
	-- 	end
	-- end
	Caster:EmitSound("DOTA_Item.RodOfAtos.Cast")
	local projectile =
				{
					Target 				= Target,
					Source 				= Caster,
					Ability 			= ItemAbility,
					EffectName 			= "particles/items2_fx/rod_of_atos_attack.vpcf",
					iMoveSpeed			= 1200,
					vSourceLoc 			= Caster:GetAbsOrigin(),
					bDrawsOnMinimap 	= false,
					bDodgeable 			= true,
					bIsAttack 			= false,
					bVisibleToEnemies 	= true,
					bReplaceExisting 	= false,
					flExpireTime 		= GameRules:GetGameTime() + 20,
					bProvidesVision 	= false,
				}
				
	ProjectileManager:CreateTrackingProjectile(projectile)

	-- ItemAbility:ApplyDataDrivenModifier(Caster,Target,keys.ModifierName,{})
end

function ItemAbility_tentacle_OnProjectileHitUnit(keys)
	-- print_r(three_dimension_projectile)
	local caster = keys.Caster or keys.caster
	local target = keys.Target or keys.target
	if is_spell_blocked(target,caster) then return end
	if target and not target:IsMagicImmune() then
		target:EmitSound("DOTA_Item.RodOfAtos.Target")
		keys.ability:ApplyDataDrivenModifier(caster,target,keys.ModifierName,{})
		-- if target:GetTeam() ~= caster:GetTeam() then
		-- end
	end
end

-- extra keys params:
-- string ModifierName
-- int ModifierCount
-- table ApplyModifierParams
function ItemAbility_SetModifierStackCount(keys)
	local ItemAbility = keys.ability
	local Caster = keys.Caster or keys.caster
	local Target = keys.Target or keys.target
	
	if (keys.ModifierCount>0) then
		if (Target:HasModifier(keys.ModifierName)==false) then
			local Params = {}
			if (keys.ApplyModifierParams) then
				Params=keys.ApplyModifierParams
			end
			ItemAbility:ApplyDataDrivenModifier(Caster,Target,keys.ModifierName,Params)
		end
		Target:SetModifierStackCount(keys.ModifierName,ItemAbility,keys.ModifierCount)
	elseif(Target:HasModifier(keys.ModifierName)) then
		Target:RemoveModifierByName(keys.ModifierName)
	end
end

-- extra keys params:
-- int CountChange
-- string ModifierName
-- int ModifierCount
-- table ApplyModifierParams
function ItemAbility_ModifyModifierStackCount(keys)
	local ItemAbility = keys.ability
	local Caster = keys.Caster or keys.caster
	local Target = keys.Target or keys.target
	local ModifierStackCount = 0
	if (Target:HasModifier(keys.ModifierName)) then
		ModifierStackCount=Target:GetModifierStackCount(keys.ModifierName,Caster)
	end
	keys.ModifierCount=ModifierStackCount+keys.CountChange
	ItemAbility_SetModifierStackCount(keys)
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
---------------------------------------------------------------------------------------
function ItemAbility_CardGoodMan_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	ItemAbility_ModifierTarget({
		ability=keys.ability,
		Caster=Caster,
		Target=Target,
		ModifierName=keys.DebuffName,
		Blockable=0
	})
	ItemAbility_SpendItem(keys)
end
function ItemAbility_CardBadMan_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	ItemAbility:ApplyDataDrivenModifier(Caster,Caster,keys.BuffName,{})
	ItemAbility_SpendItem(keys)
end
function ItemAbility_CardWorseMan_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	local AbsorbMana = min(Target:GetMana(),keys.AbsorbManaAmount)
	
--	if not is_spell_blocked_by_hakurei_amulet(Target) then
		Target:ReduceMana(AbsorbMana)
		Caster:GiveMana(AbsorbMana)
		SendOverheadEventMessage(nil,OVERHEAD_ALERT_MANA_LOSS,Target,AbsorbMana,nil)
		
		UnitDamageTarget({
				ability = ItemAbility,
				victim = Target,
				attacker = Caster,
				damage = keys.AbsorbDamage,
				damage_type = DAMAGE_TYPE_PURE,
				Blockable=0
			})
		SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_SPELL_DAMAGE,Target,keys.AbsorbDamage,nil)
--	end
	ItemAbility_SpendItem(keys)
end
function ItemAbility_CardLoveMan_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	Target:Heal(keys.HealAmount,Caster)
	SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,Target,keys.HealAmount,nil)
	ItemAbility_SpendItem(keys)
end
function ItemAbility_MrYang_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target

	-- Target:SetMana(Target:GetMana() + ItemAbility:GetSpecialValueFor("decline_mana")) --修改为削660蓝，而不是蓝上限

	Caster:EmitSound("DOTA_Item.DiffusalBlade.Activate")
	Target:EmitSound("DOTA_Item.DiffusalBlade.Activate")
	if is_spell_blocked_by_hakurei_amulet(Target) then
		return
	end
	Target:Purge(true,false,false,false,false)
	if Target:HasModifier("modifier_item_ghost_spoon") then
		Target:RemoveModifierByName("modifier_item_ghost_spoon")
	end
	if Target:HasModifier("modifier_item_three_dimension_debuff") then 
		Target:RemoveModifierByName("modifier_item_three_dimension_debuff")
	end
	
	ItemAbility:ApplyDataDrivenModifier(Caster,Target,keys.DeclineIntDebuffName,{})
	
	for i=0.0,keys.SlowdownDuration,keys.SlowdownInterval do
		ItemAbility:ApplyDataDrivenModifier(Caster,Target,keys.SlowdownDebuffName,{duration=i})
	end
		ItemAbility:ApplyDataDrivenModifier(Caster,Caster,"modifier_item_mr_yang_attack_not_miss",{})

end

function ItemAbility_MrYang_OnAttackStart( keys )
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	if Target:HasModifier("modifier_item_mr_yang_decline_intellect") then
		ItemAbility:ApplyDataDrivenModifier(Caster,Caster,"modifier_item_mr_yang_attack_not_miss_when",{duration = 0.5})
	end
end

function ItemAbility_MrYang_OnIntervalThink(keys )
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	Target:Purge(true,false,false,false,false)
	if Target:HasModifier("modifier_item_ghost_spoon") then
		Target:RemoveModifierByName("modifier_item_ghost_spoon")
	end
	if Target:HasModifier("modifier_item_three_dimension_debuff") then 
		Target:RemoveModifierByName("modifier_item_three_dimension_debuff")
	end
end

function ItemAbility_SmashStick_OnAttack(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	if (Caster:IsRealHero() and Target:IsBuilding()==false) then
		if Caster:GetAttackCapability()==DOTA_UNIT_CAP_RANGED_ATTACK then
			DebugPrint("ItemAbility_SmashStick_OnAttack| Ranged Stun: "..keys.StunDurationRanged.." sec")
			UnitStunTarget(Caster,Target,keys.StunDurationRanged)
		elseif Caster:GetAttackCapability()==DOTA_UNIT_CAP_MELEE_ATTACK then
			DebugPrint("ItemAbility_SmashStick_OnAttack| Melee Stun: "..keys.StunDurationMelee.." sec")
			UnitStunTarget(Caster,Target,keys.StunDurationMelee)
		end
	end
end

function ItemAbility_GhostBallon_OnAttacked(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Attacker = keys.attacker	
	if (Attacker:IsBuilding()==false) then
		ItemAbility:ApplyDataDrivenModifier(Caster,Attacker,keys.ModifierName,{})
	end
end

function ItemAbility_WindGun_OnAttack(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	local damage_to_deal = keys.PhysicalDamage
	if (Caster:IsRealHero() and Target:IsRealHero()==false and Target:IsBuilding()==false) then
		local damage_table = {
			ability = ItemAbility,
			victim = Target,
			attacker = Caster,
			damage = damage_to_deal,
			damage_type = DAMAGE_TYPE_PHYSICAL,
			damage_flags = 1
		}
		UnitDamageTarget(damage_table)
		local effectIndex = ParticleManager:CreateParticle("particles/econ/items/sniper/sniper_charlie/sniper_base_attack_explosion_charlie.vpcf", PATTACH_ABSORIGIN_FOLLOW, Target)
		ParticleManager:SetParticleControl(effectIndex, 3, Caster:GetAbsOrigin())
		ParticleManager:DestroyParticleSystem(effectIndex,false)
	end
end

function ItemAbility_Camera_OnAttack(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	if (Caster:IsRealHero() and Target:IsBuilding()==false) then
		local damage_to_deal =Target:GetMaxHealth()*keys.DamageHealthPercent*0.01
		if Target:GetUnitName()=="npc_dota_roshan" then damage_to_deal=damage_to_deal*0.45 end
		local damage_table = {
			ability = ItemAbility,
			victim = Target,
			attacker = Caster,
			damage = damage_to_deal,
			damage_type = DAMAGE_TYPE_MAGICAL,
			damage_flags = 1
		}
		UnitDamageTarget(damage_table)
		
		--SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_SPELL_DAMAGE,Target,damage_to_deal,nil)
		--PrintTable(damage_table)
		--DebugPrint("ItemAbility_Camera_OnAttack| Damage:"..damage_to_deal)
	end
end

function ItemAbility_Verity_OnAttack(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	if (Target:IsBuilding()==false and Caster:IsIllusion()==false) then
		
		if ItemAbility:IsCooldownReady() then
			local damage_table = {
				ability = ItemAbility,
				victim = Target,
				attacker = Caster,
				damage = 200,
				damage_type = DAMAGE_TYPE_PHYSICAL,
				damage_flags = 1
			}
			UnitDamageTarget(damage_table)
			Target:ReduceMana(100)
			--ItemAbility:StartCooldown(ItemAbility:GetCooldown(1))
			ItemAbility:StartCooldown(GetCurrentCoolDown(ItemAbility,Caster))
		end

		local RemoveMana = Target:GetMaxMana()*keys.PenetrateRemoveManaPercent*0.01+keys.Basicremovemana
		RemoveMana=min(RemoveMana,Target:GetMana())
		Target:ReduceMana(RemoveMana)
		local damage_to_deal = RemoveMana*keys.PenetrateDamageFactor
		if (damage_to_deal>0) then
			local damage_table = {
				ability = ItemAbility,
				victim = Target,
				attacker = Caster,
				damage = damage_to_deal,
				damage_type = DAMAGE_TYPE_PHYSICAL,
				damage_flags = 1
			}
			UnitDamageTarget(damage_table)
			
			--PrintTable(damage_table)
			DebugPrint("ItemAbility_Verity_OnAttack| Damage:"..damage_to_deal)
		end
	end
end

function Kafziel_OnSpellStart( keys )
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	Caster:EmitSound("DOTA_Item.SpiritVessel.Cast")
	Target:EmitSound("DOTA_Item.SpiritVessel.Target.Enemy")
	local particle = ParticleManager:CreateParticle("particles/items4_fx/spirit_vessel_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, Caster)
	ParticleManager:SetParticleControl(particle, 1, Target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle)
end

function ItemAbility_Kafziel_OnAttack(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	if (Caster:IsRealHero() and Target:IsBuilding()==false) then
		local damage_to_deal = (Caster:GetHealth()-Target:GetHealth())*keys.HarvestDamageFactor
		if (damage_to_deal>0) then
			local damage_table = {
				ability = ItemAbility,
				victim = Target,
				attacker = Caster,
				damage = damage_to_deal,
				damage_type = DAMAGE_TYPE_MAGICAL,
				damage_flags = 1
			}
			UnitDamageTarget(damage_table)
			SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_SPELL_DAMAGE,Target,damage_to_deal,nil)
			
			--PrintTable(damage_table)
			DebugPrint("ItemAbility_Kafziel_OnAttack| Damage:"..damage_to_deal)
		end
	end
end

function ItemAbility_Frock_Poison(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Attacker = keys.attacker
	if ItemAbility:IsCooldownReady() == false then return end
	if (Attacker:IsBuilding()==false) then
		local damage_to_deal = 0
		if (Attacker:IsHero()) then
			local MaxAttribute = max(max(Attacker:GetStrength(),Attacker:GetAgility()),Attacker:GetIntellect())
			damage_to_deal = keys.PoisonDamageBase + MaxAttribute*keys.PoisonDamageFactor
		end
		damage_to_deal = max(damage_to_deal,keys.PoisonMinDamage)
		if (damage_to_deal>0) then
			local damage_table = {
				ability = ItemAbility,
				victim = Attacker,
				attacker = Caster,
				damage = damage_to_deal,
				damage_type = DAMAGE_TYPE_MAGICAL,
				damage_flags = 0
			}
			UnitDamageTarget(damage_table)
			SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_POISON_DAMAGE,Attacker,damage_to_deal,nil)
			
			--PrintTable(damage_table)
			DebugPrint("ItemAbility_Frock_Poison| Damage:"..damage_to_deal)
		end
	end
end

function ItemAbility_Frock_Poison_TakeDamage(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Attacker = keys.attacker
	local damage_to_deal = keys.TakenDamage * keys.BackFactor
	if Caster:GetContext("ability_yuyuko_Ex_deadflag")~=nil and keys.TakenDamage == Caster:GetMaxHealth() then
		damage_to_deal = 0
	end
	if (Attacker:IsBuilding()==false) and Attacker ~= Caster and Attacker:HasModifier("modifier_item_frock_OnTakeDamage") == false then
		if (damage_to_deal>0 and damage_to_deal<=Caster:GetMaxHealth()) then
			local damage_table = {
				ability = ItemAbility,
				victim = Attacker,
				attacker = Caster,
				damage = damage_to_deal,
				damage_type = DAMAGE_TYPE_MAGICAL,
				damage_flags = 0
			}
			UnitDamageTarget(damage_table)
			SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_POISON_DAMAGE,Attacker,damage_to_deal,nil)
		end
	end
end

function ItemAbility_LoneLiness_RegenHealth(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Health = Caster:GetHealth()
	local MaxHealth = Caster:GetMaxHealth()
	local HealthRegen = Caster:GetHealthRegen()
	local HealAmount = ((MaxHealth-Health)/2)*keys.PercentHealthRegenBonus*0.01 + HealthRegen*keys.HealthRegenMultiplier*0.01
	Caster:Heal(HealAmount,Caster)
end

function ItemAbility_Bagua_RegenMana(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Mana =  Caster:GetMana()
	local MaxMana = Caster:GetMaxMana()
	local ManaRegenAmount = MaxMana*keys.PercentManaRegenBonus*0.01
	Caster:SetMana(Mana + ManaRegenAmount)
end

function ItemAbility_HakureiTicket_FeastHeal(keys)
	local Caster = keys.caster
	local HealAmount = keys.HealAmount
	local Targets = keys.target_entities
	Caster:EmitSound("DOTA_Item.Mekansm.Activate")
	for i,v in pairs(Targets) do
		if not v:HasModifier("modifier_item_hakurei_ticket_feast_buff") then
			v:Heal(HealAmount + v:GetMaxHealth()*0.1,Caster)
			SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,v,HealAmount + v:GetMaxHealth()*0.1,nil)
		end
		v:EmitSound("DOTA_Item.Mekansm.Target")
		local effectIndex = ParticleManager:CreateParticle("particles/items2_fx/mekanism.vpcf", PATTACH_CUSTOMORIGIN, v)
		ParticleManager:SetParticleControlEnt(effectIndex , 0, v, 5, "follow_origin", Vector(0,0,0), true)
	end
end

function ItemAbility_DoctorDoll_DeclineHealth(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Health = Caster:GetHealth()
	
	local damage_to_deal = min(keys.DeclineHealthPerSec,Health-1)
	if (damage_to_deal>0) then
		Caster:SetHealth(Health - damage_to_deal)
		SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_POISON_DAMAGE,Caster,damage_to_deal,nil)
		
		--PrintTable(damage_table)
	end
end

function ItemAbility_DummyDoll_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	
	ProjectileManager:ProjectileDodge(Caster)
	--create_illusion(keys, illusion_origin, illusion_incoming_damage, illusion_outgoing_damage, illusion_duration)	
	illusion=create_illusion(keys,Caster:GetAbsOrigin(),keys.illusion_damage_percent_incoming_melee,-65,keys.illusions_duration)
	if (illusion ~= nil) then
		local CasterAngles = Caster:GetAnglesAsVector()
		illusion:SetAngles(CasterAngles.x,CasterAngles.y,CasterAngles.z)
		
		illusion:SetHealth(illusion:GetMaxHealth()*Caster:GetHealthPercent()*0.01)
		illusion:SetMana(illusion:GetMaxMana()*Caster:GetManaPercent()*0.01)
		--ItemAbility:ApplyDataDrivenModifier(illusion,illusion,keys.illusion_modifier,{})
	end
end

function ItemAbility_Good_Lunchbox_Charge(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.unit
	if Caster:HasModifier("modifier_item_better_lunchbox") or Caster:HasModifier("modifier_item_best_lunchbox") or Caster:HasModifier("modifier_item_god_lunchbox") then return end
	if Caster:GetTeam()~=Target:GetTeam() and Caster:CanEntityBeSeenByMyTeam(Target) then
		local CurrentActiveAbility=keys.event_ability
		if IsNotLunchbox_ability(CurrentActiveAbility) then return end
		if (ItemAbility:IsItem() and CurrentActiveAbility and not CurrentActiveAbility:IsItem()) then
			local Charge = ItemAbility:GetCurrentCharges()
			if (Charge<keys.MaxCharges) then
				ItemAbility:SetCurrentCharges(Charge+1)
			end
		end
	end
end

function ItemAbility_Better_Lunchbox_Charge(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.unit
	--print("debug_better_Caster is :" .. Caster:GetUnitName() .. "and Target is" .. Target:GetUnitName())
	if Caster:HasModifier("modifier_item_best_lunchbox") or Caster:HasModifier("modifier_item_god_lunchbox") then return end
	local Casters=FindUnitsInRadius(Target:GetTeamNumber(),
									Target:GetAbsOrigin(),
									nil,
									1400,
									DOTA_UNIT_TARGET_TEAM_ENEMY,
									DOTA_UNIT_TARGET_HERO,
									DOTA_UNIT_TARGET_FLAG_NONE,
									FIND_ANY_ORDER,
									false)	
	for i,v in pairs(Casters) do
	--print("Casters is :" .. v:GetName())	
		if v:GetTeam()~=Target:GetTeam() and v:CanEntityBeSeenByMyTeam(Target) and v:HasItemInInventory("item_better_lunchbox") then
			local CurrentActiveAbility=keys.event_ability
			if IsNotLunchbox_ability(CurrentActiveAbility) then return end
			if (ItemAbility:IsItem() and CurrentActiveAbility and not CurrentActiveAbility:IsItem()) then
				for k = 0,5,1 do
					if v:GetItemInSlot(k) ~= nil and v:GetItemInSlot(k):GetAbilityName() == "item_better_lunchbox" then
						local Charge = v:GetItemInSlot(k):GetCurrentCharges()
						if (Charge<keys.MaxCharges) then
							v:GetItemInSlot(k):SetCurrentCharges(Charge+1)
							break
						end
					end
				end
			end
		end	
	end
end

function ItemAbility_Best_Lunchbox_Charge(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.unit
	--print("debug_best_Caster is :" .. Caster:GetUnitName() .. "and Target is" .. Target:GetUnitName())
	if Caster:HasModifier("modifier_item_god_lunchbox") then return end
	local Casters=FindUnitsInRadius(Target:GetTeamNumber(),
									Target:GetAbsOrigin(),
									nil,
									1400,
									DOTA_UNIT_TARGET_TEAM_ENEMY,
									DOTA_UNIT_TARGET_HERO,
									DOTA_UNIT_TARGET_FLAG_NONE,
									FIND_ANY_ORDER,
									false)	
	for i,v in pairs(Casters) do	
		if v:GetTeam()~=Target:GetTeam() and v:CanEntityBeSeenByMyTeam(Target) and v:HasItemInInventory("item_best_lunchbox") then
			local CurrentActiveAbility=keys.event_ability
			if IsNotLunchbox_ability(CurrentActiveAbility) then return end
			if (ItemAbility:IsItem() and CurrentActiveAbility and not CurrentActiveAbility:IsItem()) then
				for k = 0,5,1 do
					if v:GetItemInSlot(k) ~= nil and v:GetItemInSlot(k):GetAbilityName() == "item_best_lunchbox" then
						local Charge = v:GetItemInSlot(k):GetCurrentCharges()
						if (Charge<keys.MaxCharges) then
							v:GetItemInSlot(k):SetCurrentCharges(Charge+1)
							break
						end
					end
				end
			end
		end	
	end
end

function ItemAbility_God_Lunchbox_Charge(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.unit --Target是施法的人 . Caster是接受能量点的人
--print("Target is :" .. Target:GetName())
--print("Caster is :" .. Caster:GetName())
--CanEntityBeSeenByMyTeam 视野方法
--DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE 视野方法
--GetAbilityName() 获取道具名
-- print("TargetName is:" .. tostring(Target:GetName()))
-- print(keys.event_ability:GetName())
-- print_r(keys)
	local Casters=FindUnitsInRadius(Target:GetTeamNumber(),
									Target:GetAbsOrigin(),
									nil,
									1400,
									DOTA_UNIT_TARGET_TEAM_ENEMY,
									DOTA_UNIT_TARGET_HERO,
									DOTA_UNIT_TARGET_FLAG_NONE,
									FIND_ANY_ORDER,
									false)		
	for i,v in pairs(Casters) do
	--print("Casters is kejian:" .. v:GetUnitName())
		if v:GetTeam()~=Target:GetTeam() and v:CanEntityBeSeenByMyTeam(Target) and v:HasItemInInventory("item_god_lunchbox") then
			local CurrentActiveAbility=keys.event_ability
			if IsNotLunchbox_ability(CurrentActiveAbility) then return end
			if (ItemAbility:IsItem() and CurrentActiveAbility and not CurrentActiveAbility:IsItem()) then
				--local Charge = ItemAbility:GetCurrentCharges()
				for k = 0,5,1 do
					--print(v:GetItemInSlot(k))
					--print(k)
					if v:GetItemInSlot(k) ~= nil and v:GetItemInSlot(k):GetAbilityName() == "item_god_lunchbox" then
						--print(tostring(v:GetItemInSlot(k)) .. "is god_lunchbox")
						local Charge = v:GetItemInSlot(k):GetCurrentCharges()
							if (Charge<keys.MaxCharges) then
							v:GetItemInSlot(k):SetCurrentCharges(Charge+1)
							-- print("debug_god_v is :" .. v:GetUnitName() .. "and Target is" .. Target:GetUnitName())
								break
							end
					end
				end
			end
		end
	end
end

function ItemAbility_Lunchbox_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	if (ItemAbility:IsItem()) then
		local Charge = ItemAbility:GetCurrentCharges()
		local HealAmount = Charge*keys.RestorePerCharge
		if (Charge>0) then
			Caster:Heal(HealAmount,Caster)
			SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,Caster,HealAmount,nil)
			Caster:GiveMana(HealAmount)
			SendOverheadEventMessage(nil,OVERHEAD_ALERT_MANA_ADD,Caster,HealAmount,nil)
			
			ItemAbility:SetCurrentCharges(0)
		end
	end
end

function ItemAbility_God_Lunchbox_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	if (ItemAbility:GetCurrentCharges()>=7) then
		--Purge(bool RemovePositiveBuffs, bool RemoveDebuffs, bool BuffsCreatedThisFrameOnly, bool RemoveStuns, bool RemoveExceptions) 
		Caster:Purge(false,true,false,true,false)
	end
	ItemAbility_Lunchbox_OnSpellStart(keys) --Spend Charges
end

function ItemAbility_DragonStar_Purge(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	DebugPrint("ItemAbility_Dragon_Star_Purge")
	--Purge(bool RemovePositiveBuffs, bool RemoveDebuffs, bool BuffsCreatedThisFrameOnly, bool RemoveStuns, bool RemoveExceptions) 
	Caster:Purge(false,true,false,true,false)
	
end

function ItemAbility_mushroom_kebab_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	Caster:SetBaseStrength(Caster:GetBaseStrength() + keys.IncreaseStrength)
	if (ItemAbility:IsItem()) then
		Caster:RemoveItem(ItemAbility)
		--ItemAbility:Kill()
	end
end

function ItemAbility_mushroom_pie_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	Caster:SetBaseAgility(Caster:GetBaseAgility() + keys.IncreaseAgility)
	if (ItemAbility:IsItem()) then
		Caster:RemoveItem(ItemAbility)
		--ItemAbility:Kill()
	end
end

function ItemAbility_mushroom_soup_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	Caster:SetBaseIntellect(Caster:GetBaseIntellect() + keys.IncreaseIntellect)
	if (ItemAbility:IsItem()) then
		Caster:RemoveItem(ItemAbility)
		--ItemAbility:Kill()
	end
end

function ItemAbility_HorseKing_OnOpen_SpendMana(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	--if (Caster:GetMaxMana()>keys.NeedSpendMana) then
	do
		if (Caster:GetManaPercent()<keys.SpendManaPercent and ItemAbility:GetToggleState()) then
			ItemAbility:ToggleAbility()
		else
			local SpendMana = Caster:GetMaxMana()*keys.SpendManaPercent*0.01
			Caster:SpendMana(SpendMana,ItemAbility)
			--Caster:ReduceMana(SpendMana)
		end
	end
end

function ItemAbility_HorseKing_ToggleOff(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	if (ItemAbility:GetToggleState()) then
		ItemAbility:ToggleAbility()
	end
end

function ItemAbility_DonationBox_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	local GoldBounty = Target:GetGoldBounty()
	if Target:GetUnitName() == "ability_minamitsu_04_ship" or Target:GetUnitName() == "ability_margatroid03_doll" then
		return
	end
	if Target:HasModifier("modifier_ability_thdots_super_siege") then --40分钟超级兵
		return
	end
	Target:SetMaximumGoldBounty(GoldBounty+keys.BonusGold)
	Target:SetMinimumGoldBounty(GoldBounty+keys.BonusGold)
	Target:Kill(ItemAbility,Caster)
	SendOverheadEventMessage(nil,OVERHEAD_ALERT_GOLD,Caster,keys.BonusGold,nil)
	Caster:AddExperience(180,DOTA_ModifyXP_CreepKill,false,false)
	
	local effectIndex = ParticleManager:CreateParticle("particles/thd2/items/item_donation_box.vpcf", PATTACH_CUSTOMORIGIN, Caster)
	ParticleManager:SetParticleControl(effectIndex, 0, Caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(effectIndex, 1, Target:GetAbsOrigin())
	
	local Duration=0.0
	Caster:SetThink(function ()
		if (Duration>1.0) then 
			ParticleManager:DestroyParticleSystem(effectIndex,false)
			return nil 
		end
		
		Duration = Duration+0.02
		ParticleManager:SetParticleControl(effectIndex, 0, Caster:GetAbsOrigin())
		return 0.02
	end)
end

function ItemAbility_DonationGem_BounsGold(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.unit
	local CasterPlayerID = Caster:GetPlayerOwnerID()
	local GoldBountyAmount=keys.GoldBountyAmount
	
	if Target:GetTeam()~=Caster:GetTeam() then
		if (ItemAbility and ItemAbility:IsCooldownReady()) then
			--ItemAbility:StartCooldown(ItemAbility:GetCooldown(ItemAbility:GetLevel()))
			ItemAbility:StartCooldown(GetCurrentCoolDown(ItemAbility,Caster))
			Caster.ItemAbility_DonationGem_TriggerTime=GameRules:GetGameTime()
			PlayerResource:SetGold(CasterPlayerID,PlayerResource:GetUnreliableGold(CasterPlayerID) + GoldBountyAmount,false)
			
			local effectIndex = ParticleManager:CreateParticle("particles/econ/items/alchemist/alchemist_midas_knuckles/alch_knuckles_lasthit_coins.vpcf", PATTACH_ABSORIGIN_FOLLOW, Caster)
			ParticleManager:DestroyParticleSystem(effectIndex,false)
			
			SendOverheadEventMessage(Caster:GetOwner(),OVERHEAD_ALERT_GOLD,Caster,GoldBountyAmount,nil)
			DebugPrint("ItemAbility_DonationGem_BounsGold| Bounty Gold: "..tostring(GoldBountyAmount))
		end
	end
end

function ItemAbility_Rocket_OnHit(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	if is_spell_blocked_by_hakurei_amulet(Target) then
		return
	end
	Caster:EmitSound("THD_ITEM.Rocket_Hit")
	UnitDamageTarget({
		ability = ItemAbility,
		victim = Target,
		attacker = Caster,
		damage = keys.RocketDamage,
		damage_type = DAMAGE_TYPE_MAGICAL
	})
	UnitStunTarget(Caster,Target,keys.StunDuration)
end

function ItemAbility_9ball_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local vecCaster = Caster:GetOrigin()
	local radian = RandomFloat(0,6.28)
	local range = RandomFloat(keys.BlinkRangeMin,keys.BlinkRangeMax)
	vecCaster.x = vecCaster.x+math.cos(radian)*range
	vecCaster.y = vecCaster.y+math.sin(radian)*range
	local effectIndex = ParticleManager:CreateParticle("particles/econ/events/ti7/blink_dagger_end_ti7.vpcf", PATTACH_POINT, Caster)
	ParticleManager:SetParticleControl(effectIndex, 0, Caster:GetAbsOrigin())
	ParticleManager:DestroyParticleSystem(effectIndex, false)
	Caster:EmitSound("DOTA_Item.BlinkDagger.Activate")
	FindClearSpaceForUnit(Caster, vecCaster, true)
	ProjectileManager:ProjectileDodge(Caster)
	--SetTargetToTraversable(Caster)
end

function ItemAbility_PresentBox_RestoreGold(keys)
	local ItemAbility = keys.ability
	if (ItemAbility:IsItem())then
		local Caster = keys.caster
		local CasterPlayerID = Caster:GetPlayerOwnerID()
		local RestoreGold = ItemAbility:GetCost()*keys.RestoreGoldPercent*0.01
		PlayerResource:SetGold(CasterPlayerID,PlayerResource:GetUnreliableGold(CasterPlayerID) + RestoreGold,false)
		Caster:RemoveItem(ItemAbility)
		SendOverheadEventMessage(Caster:GetOwner(),OVERHEAD_ALERT_GOLD,Caster,RestoreGold,nil)
	end
end

function ItemAbility_PresentBox_OnInterval(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local CasterPlayerID = Caster:GetPlayerOwnerID()
	--DebugPrint("now:"..PlayerResource:GetUnreliableGold(CasterPlayerID).."+"..keys.GiveGoldAmount)
	PlayerResource:SetGold(CasterPlayerID,PlayerResource:GetUnreliableGold(CasterPlayerID) + keys.GiveGoldAmount,false)
	--SendOverheadEventMessage(Caster:GetOwner(),OVERHEAD_ALERT_GOLD,Caster,keys.GiveGoldAmount,nil)
end

function ItemAbility_Lifu_RestoreGold(keys)
	local ItemAbility = keys.ability
	if (ItemAbility:IsItem())then
		local Caster = keys.caster
		local CasterPlayerID = Caster:GetPlayerOwnerID()
		local RestoreGold = ItemAbility:GetCost()*keys.RestoreGoldPercent*0.01
		PlayerResource:SetGold(CasterPlayerID,PlayerResource:GetUnreliableGold(CasterPlayerID) + RestoreGold,false)
		Caster:RemoveItem(ItemAbility)
		SendOverheadEventMessage(Caster:GetOwner(),OVERHEAD_ALERT_GOLD,Caster,RestoreGold,nil)
	end
end

function ItemAbility_Lifu_OnInterval(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local CasterPlayerID = Caster:GetPlayerOwnerID()
	--DebugPrint("now:"..PlayerResource:GetUnreliableGold(CasterPlayerID).."+"..keys.GiveGoldAmount)
	PlayerResource:SetGold(CasterPlayerID,PlayerResource:GetUnreliableGold(CasterPlayerID) + keys.GiveGoldAmount,false)
	--SendOverheadEventMessage(Caster:GetOwner(),OVERHEAD_ALERT_GOLD,Caster,keys.GiveGoldAmount,nil)
end

function ItemAbility_PresentBox_OnInterval(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local CasterPlayerID = Caster:GetPlayerOwnerID()
	--DebugPrint("now:"..PlayerResource:GetUnreliableGold(CasterPlayerID).."+"..keys.GiveGoldAmount)
	PlayerResource:SetGold(CasterPlayerID,PlayerResource:GetUnreliableGold(CasterPlayerID) + keys.GiveGoldAmount,false)
	--SendOverheadEventMessage(Caster:GetOwner(),OVERHEAD_ALERT_GOLD,Caster,keys.GiveGoldAmount,nil)
end

function ItemAbility_Peach_OnTakeDamage(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local DamageTaken = keys.DamageTaken
	local TakeDamageCount = Caster.ItemAbility_Peach_TakeDamageCount
	local SpeedupDuration = keys.SpeedupDuration
	local SpeedupModifierName = keys.SpeedupModifierName
	local SpeedupMaxModifierStack = keys.SpeedupMaxModifierStack
	local TimeNow = GameRules:GetGameTime()
	if (TakeDamageCount==nil) then
		TakeDamageCount=0
	end
	
	if (Caster.ItemAbility_Peach_LastTriggerTime==nil or TimeNow-Caster.ItemAbility_Peach_LastTriggerTime>=SpeedupDuration) then
		TakeDamageCount=0
		Caster.ItemAbility_Peach_LastTriggerTime = GameRules:GetGameTime()
	end
	
	TakeDamageCount = TakeDamageCount + DamageTaken
	Caster.ItemAbility_Peach_TakeDamageCount=TakeDamageCount
	DebugPrint("Item_Peach TakenDamageCount.."..TakeDamageCount)
	
	if (TakeDamageCount>keys.TakeDamageTrigger) then
		local ModifierCount = round(TakeDamageCount/keys.TakeDamageTrigger)+1
		local TriggerBuff = nil
		ModifierCount = min(ModifierCount,SpeedupMaxModifierStack)
		
		if (Caster:HasModifier(SpeedupModifierName)) then
			if (Caster:GetModifierStackCount(SpeedupModifierName,Caster)~=ModifierCount or (ModifierCount==SpeedupMaxModifierStack and TimeNow>Caster.ItemAbility_Peach_LastTriggerTime)) then
				Caster:RemoveModifierByName(SpeedupModifierName)
				ItemAbility:ApplyDataDrivenModifier(Caster,Caster,SpeedupModifierName,{duration = SpeedupDuration})
				Caster:SetModifierStackCount(SpeedupModifierName,ItemAbility,ModifierCount)
				TriggerBuff = true
			end
		else
			ItemAbility:ApplyDataDrivenModifier(Caster,Caster,SpeedupModifierName,{duration = SpeedupDuration})
			Caster:SetModifierStackCount(SpeedupModifierName,ItemAbility,ModifierCount)
			TriggerBuff = true
		end
		
		if (TriggerBuff) then
			Caster.ItemAbility_Peach_LastTriggerTime = TimeNow
		end
	end
end

function ItemAbility_Anchor_OnTakeDamage(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local DamageTaken = keys.DamageTaken
	local TakeDamageCount = Caster.ItemAbility_Anchor_TakeDamageCount
	local BuffDuration = keys.BuffDuration
	local IconModifierName = keys.IconModifierName
	local BuffMaxStack = keys.BuffMaxStack
	local TimeNow = GameRules:GetGameTime()
	if (TakeDamageCount==nil) then
		TakeDamageCount=0
	end
	
	if (Caster.ItemAbility_Anchor_LastTriggerTime==nil or TimeNow-Caster.ItemAbility_Anchor_LastTriggerTime>=BuffDuration) then
		TakeDamageCount=0
		Caster.ItemAbility_Anchor_LastTriggerTime = TimeNow
	end
	
	TakeDamageCount = TakeDamageCount + DamageTaken
	Caster.ItemAbility_Anchor_TakeDamageCount=TakeDamageCount
	DebugPrint("Item_Anchor TakenDamageCount.."..TakeDamageCount)
	
	if (TakeDamageCount>keys.TakeDamageTrigger) then
		local ModifierCount = round(TakeDamageCount/keys.TakeDamageTrigger)+1
		local TriggerBuff = nil
		ModifierCount = keys.CritChanceConst+min(ModifierCount,BuffMaxStack)*keys.BuffCritChance
		
		if (Caster:HasModifier(IconModifierName)) then
			if (Caster:GetModifierStackCount(IconModifierName,Caster)~=ModifierCount or (ModifierCount==keys.CritChanceConst+BuffMaxStack*keys.BuffCritChance and TimeNow>Caster.ItemAbility_Anchor_LastTriggerTime)) then
				Caster:RemoveModifierByName(IconModifierName)
				ItemAbility:ApplyDataDrivenModifier(Caster,Caster,IconModifierName,{duration = BuffDuration})
				Caster:SetModifierStackCount(IconModifierName,ItemAbility,ModifierCount)
				TriggerBuff = true
			end
		else
			ItemAbility:ApplyDataDrivenModifier(Caster,Caster,IconModifierName,{duration = BuffDuration})
			Caster:SetModifierStackCount(keys.IconModifierName,ItemAbility,ModifierCount)
			TriggerBuff = true
		end
		
		if (TriggerBuff) then
			Caster.ItemAbility_Anchor_LastTriggerTime = TimeNow
		end
	end
end

function ItemAbility_Anchor_OnAttackStart(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local CritChance = keys.CritChanceConst
	
	if (Caster:HasModifier(keys.IconModifierName)) then
		CritChance = Caster:GetModifierStackCount(keys.IconModifierName,Caster)
	end
	
	if (CritChance>=RandomInt(1,100)) then
		ItemAbility:ApplyDataDrivenModifier(Caster,Caster,keys.CritModifierName,{})
	end
end

function ItemAbility_NuclearStick_OnAbility(keys)
	local Caster=keys.caster
	local Ability=Caster:GetCurrentActiveAbility()
	local ReductionCooldown=keys.ReductionCooldown
	local AbilityCooldown=Ability:GetCooldown(Ability:GetLevel())*(100-ReductionCooldown)*0.01
	if not Ability or Ability:IsItem() then return end
	Caster:SetThink(function()
		DebugPrint("StartCooldown: "..tostring(AbilityCooldown).." sec")
		Ability:EndCooldown()
		Ability:StartCooldown(AbilityCooldown)
		return nil
	end)
end

function ItemAbility_Yuri_OnSpell(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	local ContractOverRange = keys.ContractOverRange
	local MaxRange = ContractOverRange*3
	local MaxSpeed=keys.MaxSpeed
	local BuffModifierName = keys.BuffModifierName
	local ModifierName = keys.ModifierName
	local FirstDistance = 400
	DebugFunction(PrintTargetInfo,Target)
	
	if Caster:GetTeam()~=Target:GetTeam() and is_spell_blocked_by_hakurei_amulet(Target) then
		return
	end
	--敌对
	if Caster:GetTeam()~=Target:GetTeam() then 
		ItemAbility:ApplyDataDrivenModifier(Caster,Caster,keys.BuffModifierName,{})
		ItemAbility:ApplyDataDrivenModifier(Caster,Target,keys.ModifierName,{duration=7})
		ItemAbility:ApplyDataDrivenModifier(Caster,Target,keys.ModifierName,{duration=4})
		ItemAbility:ApplyDataDrivenModifier(Caster,Target,keys.ModifierName,{duration=2})
	--友方
	else 
		ItemAbility:ApplyDataDrivenModifier(Caster,Caster,keys.BuffModifierName,{})
		ItemAbility:ApplyDataDrivenModifier(Caster,Target,keys.FriendlyModifierName,{})
	end
	
	local effectIndex = ItemAbility_Yuri_create_line(Caster,Target)

	Caster:SetThink(function ()
		local CasterPos = Caster:GetAbsOrigin()
		local TargetPos = Target:GetAbsOrigin()
		local Distance = distance(CasterPos,TargetPos)
		if (Caster:HasModifier(BuffModifierName)==false or Target:IsAlive()==false or Distance>MaxRange) then
			Caster:RemoveModifierByNameAndCaster(BuffModifierName,Caster)
			ParticleManager:DestroyParticleSystem(effectIndex,true)
			return nil
		end
		
		if (Distance>FirstDistance) then
			local vec = TargetPos - CasterPos
			local MoveDistance = (Distance-FirstDistance)
			MoveDistance=(MoveDistance*MoveDistance)/(200*200)*MaxSpeed*0.02
			if MoveDistance>1.0 then
				Caster:SetAbsOrigin(CasterPos + vec:Normalized()*MoveDistance)
			end
		end
		return 0.02
	end)
end

function ItemAbility_Yuri_create_line(caster,target)
	local effectIndex = ParticleManager:CreateParticle("particles/thd2/items/item_lily.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(effectIndex , 0, caster, 5, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effectIndex , 1, target, 5, "attach_hitloc", Vector(0,0,0), true)
	return effectIndex
end

function ItemAbility_Pad_Physical_Block(keys)
	local Caster = keys.caster
	local AttackCapability=Caster:GetAttackCapability()
	local IsMelee=false
	local damageblock=0
	if AttackCapability==DOTA_UNIT_CAP_MELEE_ATTACK then 
		IsMelee=true
	else 
		IsMelee=false
	end
	if  IsMelee==true then
		damageblock = keys.DamageBlock
	else
		damageblock = keys.DamageBlock-10
	end
	local DamageBlock = min(damageblock,keys.DamageTaken)
	
	DebugPrint("ItemAbility_Pad Physical Block: "..DamageBlock)
	if (Caster:GetHealth() + DamageBlock <= keys.DamageTaken) then return end
	Caster:SetHealth(Caster:GetHealth()+DamageBlock)
	
	
	SendOverheadEventMessage(nil,OVERHEAD_ALERT_BLOCK,Caster,DamageBlock,nil)
end

function ItemAbility_Bra_Physical_Block(keys)
	local Caster = keys.caster
	local AttackCapability=Caster:GetAttackCapability()
	local IsMelee=false
	local damageblock=0
	if AttackCapability==DOTA_UNIT_CAP_MELEE_ATTACK then 
		IsMelee=true
	else 
		IsMelee=false
	end
	if  IsMelee==true then
		damageblock = keys.DamageBlock
	else
		damageblock = keys.DamageBlock
	end
	local DamageBlock = min(damageblock,keys.DamageTaken)
	local bExistPad=false
	for i=0,5 do
		local item=Caster:GetItemInSlot(i)
		if item and item:GetName()=="item_pad" then
			bExistPad=true
			break
		end
	end
	if bExistPad then return end
	
	DebugPrint("ItemAbility_Bra Physical Block: "..DamageBlock)
	if (Caster:GetHealth() + DamageBlock <= keys.DamageTaken) then return end
	Caster:SetHealth(Caster:GetHealth()+DamageBlock)
	
	SendOverheadEventMessage(nil,OVERHEAD_ALERT_BLOCK,Caster,DamageBlock,nil)
end

function ItemAbility_MoonBow_OnHit(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	local damage_to_deal = keys.arrow_damage_const + Caster:GetIntellect()*keys.arrow_damage_int_mult
	--if (Target:IsHero()) then
		if (damage_to_deal>0) then
			local damage_table = {
				ability = ItemAbility,
				victim = Target,
				attacker = Caster,
				damage = damage_to_deal,
				damage_type = DAMAGE_TYPE_PHYSICAL,
				damage_flags = 1
			}
			--PrintTable(damage_table)
			DebugPrint("ItemAbility_Moon_Bow_OnHit| Damage:"..damage_to_deal)
			UnitDamageTarget(damage_table)
			
			
			SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_SPELL_DAMAGE,Target,damage_to_deal,nil)
		end
	--end
end

function ItemAbility_InabaIllusionWeapon_OnEquip(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local AttackCapability=Caster:GetAttackCapability()
	local IsMelee=false
	local IsRanged=false
	local IsCannon=false
	if AttackCapability==DOTA_UNIT_CAP_MELEE_ATTACK then IsMelee=true
	elseif AttackCapability==DOTA_UNIT_CAP_RANGED_ATTACK then IsRanged=true
	else IsCannon=true end 
	
	if IsMelee then
		if not Caster:HasModifier(keys.ModifierBuffMelee) then
			ItemAbility:ApplyDataDrivenModifier(Caster,Caster,keys.ModifierBuffMelee,{})
		end
	elseif IsRanged then
		if not Caster:HasModifier(keys.ModifierBuffRanged) then
			ItemAbility:ApplyDataDrivenModifier(Caster,Caster,keys.ModifierBuffRanged,{})
		end
	elseif IsCannon then
		if not Caster:HasModifier(keys.ModifierBuffCannon) then
			ItemAbility:ApplyDataDrivenModifier(Caster,Caster,keys.ModifierBuffCannon,{})
		end
	end
end

function ItemAbility_InabaIllusionWeapon_OnUnequip(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local ItemCount = 0
	for i=0,5 do
		local curr_item=Caster:GetItemInSlot(i)
		if curr_item and curr_item:GetName()==ItemAbility:GetName() then
			ItemCount=ItemCount+1
		end
	end
	if ItemCount<=0 then
		if Caster:HasModifier(keys.ModifierBuffMelee) then
			Caster:RemoveModifierByName(keys.ModifierBuffMelee)
		end
		if Caster:HasModifier(keys.ModifierBuffRanged) then
			Caster:RemoveModifierByName(keys.ModifierBuffRanged)
		end
		if Caster:HasModifier(keys.ModifierBuffCannon) then
			Caster:RemoveModifierByName(keys.ModifierBuffCannon)
		end
	end
end

function ItemAbility_InabaIllusionWeapon_Melee_OnAttackLanded(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	local CleavePercent=keys.CleavePercent
	local CleaveRadius=keys.CleaveRadius
	local ItemCount=0
	if Caster:IsRealHero() and Caster:GetTeam()~=Target:GetTeam() then
		for i=0,5 do
			local curr_item=Caster:GetItemInSlot(i)
			if curr_item and curr_item:GetName()==ItemAbility:GetName() then
				ItemCount=ItemCount+1
			end
		end
		
		if (ItemCount>0) then
			local Damage=keys.AttackDamage*ItemCount*CleavePercent*0.01
			DoCleaveAttack(Caster,Target,ItemAbility,Damage,CleaveRadius,CleaveRadius,CleaveRadius,"particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf")
		end
	end
end

function ItemAbility_InabaIllusionWeapon_Ranged_OnAttack(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	if Caster:HasModifier("modifier_ability_thdots_tei03") then return end --黑兔子开启枪斗术禁用兔炮效果
	local RangedSplitNum=keys.RangedSplitNum
	local RangedSplitRadius=keys.RangedSplitRadius
	local ItemCount=0
	if Caster:GetTeam()~=Target:GetTeam() then
		for i=0,5 do
			local curr_item=Caster:GetItemInSlot(i)
			if curr_item and curr_item:GetName()==ItemAbility:GetName() then
				ItemCount=ItemCount+1
			end
		end
		local MaxTargets=ItemCount*RangedSplitNum
		local Targets=FindUnitsInRadius(Caster:GetTeamNumber(),
										Caster:GetAbsOrigin(),
										nil,
										RangedSplitRadius,
										DOTA_UNIT_TARGET_TEAM_ENEMY,
										DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
										DOTA_UNIT_TARGET_FLAG_NONE,
										FIND_ANY_ORDER,--[[FIND_CLOSEST,]]
										false)
		for _,unit in pairs(Targets) do
			if MaxTargets>0 then
				if unit and unit:IsAlive() and unit~=Target and Caster:CanEntityBeSeenByMyTeam(unit) then
					Caster:PerformAttack(unit,
						true,
						false,
						true,
						false,
						true,
						false,
						true
						)
					MaxTargets=MaxTargets-1
				end
			else break end
		end
	end
end

function ItemAbility_InabaIllusionWeapon_Cannon_OnAttackLanded(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Target = keys.target
	local CannonDamageMin=keys.CannonDamageMin
	local CannonDamageMax=keys.CannonDamageMax
	local CannonDamageRadius=keys.CannonDamageRadius
	local ItemCount=0
	if Caster:IsRealHero() and Caster:GetTeam()~=Target:GetTeam() then
		for i=0,5 do
			local curr_item=Caster:GetItemInSlot(i)
			if curr_item and curr_item:GetName()==ItemAbility:GetName() then
				ItemCount=ItemCount+1
			end
		end
		
		if (ItemCount>0) then
			local Damage=RandomFloat(CannonDamageMin,CannonDamageMax)*ItemCount
			local Targets=FindUnitsInRadius(Caster:GetTeamNumber(),
											Target:GetAbsOrigin(),
											nil,
											CannonDamageRadius,
											DOTA_UNIT_TARGET_TEAM_ENEMY,
											DOTA_UNIT_TARGET_ALL,
											DOTA_UNIT_TARGET_FLAG_NONE,
											FIND_ANY_ORDER,
											false)
			for _,unit in pairs(Targets) do
				if unit and unit:IsAlive() then
					UnitDamageTarget{
						ability = ItemAbility,
						victim = unit,
						attacker = Caster,
						damage = Damage,
						damage_type = DAMAGE_TYPE_PURE
					}
				end
			end	
			DebugPrint("ItemAbility_InabaIllusionWeapon_Cannon_OnAttackLanded| Damage:"..Damage)
		end
	end
end
--------------------------------------------------------------------------------------------------------
--[[
	item_hakurei_amulet
]]
function is_spell_blocked_by_hakurei_amulet(target)
	if target:HasModifier("modifier_item_sphere_target") then
		target:RemoveModifierByName("modifier_item_sphere_target")  --The particle effect is played automatically when this modifier is removed (but the sound isn't).
		target:EmitSound("DOTA_Item.LinkensSphere.Activate")
		return true
	end
	return false
end

function ItemAbility_HakureiAmulet_OnCreated(keys)
	if keys.ability ~= nil and keys.ability:IsCooldownReady() then
		if keys.caster:HasModifier("modifier_item_sphere_target") then  --Remove any potentially temporary version of the modifier and replace it with an indefinite one.
			keys.caster:RemoveModifierByName("modifier_item_sphere_target")
		end
		keys.caster:AddNewModifier(keys.caster, keys.ability, "modifier_item_sphere_target", {duration = -1})
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_hakurei_amulet_icon", {duration = -1})
	end
end

function ItemAbility_HakureiAmulet_OnDestroy(keys)
	local num_off_cooldown_linkens_spheres_in_inventory = 0
	for i=0, 5, 1 do --Search for off-cooldown Linken's Spheres in the player's inventory.
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item ~= nil then
			if current_item:GetName() == "item_hakurei_amulet" and current_item:IsCooldownReady() then
				num_off_cooldown_linkens_spheres_in_inventory = num_off_cooldown_linkens_spheres_in_inventory + 1
			end
		end
	end
	
	--If the player just got rid of their last Linken's Sphere, which was providing the passive spellblock.
	if num_off_cooldown_linkens_spheres_in_inventory == 0 then
		keys.caster:RemoveModifierByName("modifier_item_sphere_target")
		keys.caster:RemoveModifierByName("modifier_item_hakurei_amulet_icon")
	end
end
function ItemAbility_HakureiAmulet_OnIntervalThink(keys)
	if not keys.caster:HasModifier("modifier_item_sphere_target") then
		if keys.caster:HasModifier("modifier_item_hakurei_amulet_icon") then -- blocked spell
			for i=0, 5, 1 do
				local current_item = keys.caster:GetItemInSlot(i)
				if current_item ~= nil and current_item:GetName()=="item_hakurei_amulet" then
					--current_item:StartCooldown(current_item:GetCooldown(current_item:GetLevel()))
					current_item:StartCooldown(GetCurrentCoolDown(current_item,keys.caster))
				end
			end
			keys.caster:RemoveModifierByName("modifier_item_hakurei_amulet_icon")
		else -- reset modifier
			local num_off_cooldown_linkens_spheres_in_inventory = 0
			for i=0, 5, 1 do
				local current_item = keys.caster:GetItemInSlot(i)
				if current_item ~= nil then
					if current_item:GetName() == "item_hakurei_amulet" and current_item:IsCooldownReady() then
						num_off_cooldown_linkens_spheres_in_inventory = num_off_cooldown_linkens_spheres_in_inventory + 1
					end
				end
			end
			if num_off_cooldown_linkens_spheres_in_inventory>0 then
				keys.caster:AddNewModifier(keys.caster, keys.ability, "modifier_item_sphere_target", {duration = -1})
				keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_hakurei_amulet_icon", {duration = -1})
			end
		end
	end
end

function ItemAbility_Qijizhixing_OnSpellStart(keys)
	local caster = keys.caster
	local target = keys.target

	target:Heal(keys.HealAmount + caster:GetMaxMana() * 0.25,caster)
	SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,target,keys.HealAmount + caster:GetMaxMana() * 0.25,nil)
	target:Purge(false,true,false,true,false)
end

function ItemAbility_tsundere_OnSpellStart(keys)
	local caster = keys.caster
	caster:Purge(false,true,false,true,false)
end



function ItemAbility_Ganggenier_OnDealDamage(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	if(caster.ganggenierlock == nil)then
		caster.ganggenierlock = false
	end

	if(caster.ganggenierlock == true)then
		return
	end

	caster.ganggenierlock = true
	
	local damage_table = {
		ability = keys.ability,
		victim = keys.unit,
		attacker = caster,
		damage = keys.DamageDeal * keys.IncreaseDamage/100,
		damage_type = DAMAGE_TYPE_PURE, 
		damage_flags = DOTA_DAMAGE_FLAG_NONE
	}
	UnitDamageTarget(damage_table)
	caster.ganggenierlock = false
end

function ItemAbility_Morenjingjuan_Antiblink_OnSpellStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local vecTarget = target:GetOrigin()
	local attackspeed = keys.AttackSpeedIncrese * (caster:GetMaxMana() - target:GetMaxMana())

	target.isAntiBlink = true

	attackspeedint =  math.floor(attackspeed/100)

	ability:ApplyDataDrivenModifier(caster,caster,"modifier_item_morenjingjuan_buff",{duration = keys.Duration})
	caster:SetModifierStackCount("modifier_item_morenjingjuan_buff",ability,attackspeedint)

	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_enigma/enigma_ambient_body.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(effectIndex, 0, vecTarget)

	local effectIndex2 = ParticleManager:CreateParticle("particles/thd2/items/item_morenjingjuan.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(effectIndex2 , 0, caster, 5, "follow_origin", Vector(0,0,0), true)
	ParticleManager:SetParticleControl(effectIndex2, 1, Vector(0,0,0))
	ParticleManager:SetParticleControl(effectIndex2, 6, Vector(1,1,1))
	ParticleManager:DestroyParticleSystemTime(effectIndex2,keys.Duration)

	local count = 0

	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString('item_ability_morenjingjuan'),
    	function ()
    		if GameRules:IsGamePaused() then return 0.03 end
    		count = count + 0.03

    		if target:HasModifier("modifier_item_morenjingjuan_antiblink") == false then
				ParticleManager:DestroyParticleSystem(effectIndex,true)
    			return nil
    		end

    		if target.is_Iku_02_knock == true then
    			return 0.03
    		end

		    target:SetOrigin(vecTarget)

		    if count > keys.Duration then
		    	ParticleManager:DestroyParticleSystem(effectIndex,true)
		    	return nil
		    else
		    	return 0.03
		    end
	    end,
	    0.03
	)

end

function ItemAbility_yuemianzhinu_range(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:GetAttackCapability() == DOTA_UNIT_CAP_RANGED_ATTACK then
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_item_yuemianzhinu_range",{})
	end
end

function ItemAbility_phoenix_wing_burn(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local dealdamage = keys.damage + caster:GetMaxHealth() * keys.damage_percent/100
	--local distance = GetDistanceBetweenTwoVec2D(caster:GetOrigin(),target:GetOrigin())
	--[[if distance>=0 and distance<200 then
		dealdamage = dealdamage
	elseif distance>=200 and distance<400 then
		dealdamage = dealdamage*0.6
	elseif distance>=400 then
		dealdamage = dealdamage*0.3
	end]]
	UnitDamageTarget({
		ability = ability,
		victim = target,
		attacker = caster,
		damage = dealdamage,
		damage_type = DAMAGE_TYPE_MAGICAL
	})
end

function OnZunGlasses_Take_Damage(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local VecCaster = caster:GetOrigin()

	if keys.ability:IsCooldownReady() and caster:IsRealHero() then 
		if caster:GetHealth() == 0 and caster:GetClassname()~="npc_dota_hero_necrolyte" and caster:HasModifier("modifier_thdots_komachi_04")==false then 
			if caster:GetClassname()=="npc_dota_hero_chaos_knight" then
				caster:SetRespawnPosition(VecCaster)
				caster:RespawnUnit()
			end
			caster:SetHealth(caster:GetMaxHealth()*0.15)
			--keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel()))
			keys.ability:StartCooldown(GetCurrentCoolDown(keys.ability,keys.caster))
		end
	end
		--原代码
	--if(caster:GetHealth()<=keys.DamageTaken and caster:GetClassname()~="npc_dota_hero_necrolyte")then
	--	local randomInt = RandomInt(0,100)
	--	if randomInt <= 50 and keys.ability:IsCooldownReady() then
	--		caster:SetHealth(caster:GetHealth()+keys.DamageTaken)
	--		keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel()))
	--	end
	--end
end

--[[function OnFly_BirdKillSpawn(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local caster = keys.caster
	if caster.ability_fly_bird~=nil and caster.ability_fly_bird:IsNull() == false then
		caster.ability_fly_bird:ForceKill(true)
	end
end]]

function OnTentacle_Effect(keys)
	local ItemAbility = keys.ability
	local Caster = keys.Caster or keys.caster
	local Target = keys.Target or keys.target
	if ( Caster:IsRealHero() == false ) then return end
	if Caster and Target and Caster:GetTeam()~=Target:GetTeam() then
		if (not keys.ApplyToTower or keys.ApplyToTower==0) and Target:IsBuilding() then
			return
		end	
		local randomInt = RandomInt(0,100)
		if randomInt <= 16  then
			ItemAbility:ApplyDataDrivenModifier(Caster,Target,keys.ModifierName,{})
		end	
	end
end
-------------------------------------------------------------------------------------------------------------------
--[[Author: Pizzalol
	Date: 18.01.2015.
	Checks if the target is an illusion, if true then it kills it
	otherwise the target model gets swapped into a frog]]
function voodoo_start( keys )
	local target = keys.target
	local model = keys.model

	if target:IsIllusion() then
		target:ForceKill(true)
	else
		if target.target_model == nil then
			target.target_model = target:GetModelName()
		end

		target:SetOriginalModel(model)
	end
end

--[[Author: Pizzalol
	Date: 18.01.2015.
	Reverts the target model back to what it was]]
function voodoo_end( keys )
	local target = keys.target

	-- Checking for errors
	if target.target_model ~= nil then
		target:SetModel(target.target_model)
		target:SetOriginalModel(target.target_model)
	end
end

--[[Author: Noya
	Date: 10.01.2015.
	Hides all dem hats
]]
function HideWearables( event )
	--[[
	local hero = event.target
	local ability = event.ability
	local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )
	print("Hiding Wearables")
	--hero:AddNoDraw() -- Doesn't work on classname dota_item_wearable

	hero.wearableNames = {} -- In here we'll store the wearable names to revert the change
	hero.hiddenWearables = {} -- Keep every wearable handle in a table, as its way better to iterate than in the MovePeer system
    local model = hero:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() ~= "" and model:GetClassname() == "dota_item_wearable" then
            local modelName = model:GetModelName()
            if string.find(modelName, "invisiblebox") == nil then
            	-- Add the original model name to revert later
            	table.insert(hero.wearableNames,modelName)
            	print("Hidden "..modelName.."")

            	-- Set model invisible
            	model:SetModel("models/development/invisiblebox.vmdl")
            	table.insert(hero.hiddenWearables,model)
            end
        end
        model = model:NextMovePeer()
        if model ~= nil then
        	print("Next Peer:" .. model:GetModelName())
        end
    end]]
end

--[[Author: Noya
	Date: 10.01.2015.
	Shows the hidden hero wearables
]]
function ShowWearables( event )
	--[[
	local hero = event.target
	print("Showing Wearables on ".. hero:GetModelName())

	-- Iterate on both tables to set each item back to their original modelName
	for i,v in ipairs(hero.hiddenWearables) do
		for index,modelName in ipairs(hero.wearableNames) do
			if i==index then
				print("Changed "..v:GetModelName().. " back to "..modelName)
				v:SetModel(modelName)
			end
		end
	end]]
end

three_dimension_projectile = nil

function ItemAbility_three_dimension_OnSpellStart(keys)
	local ItemAbility = keys.ability
	local caster = keys.Caster or keys.caster
	local target = keys.Target or keys.target
	
	-- Play the cast sound
	caster:EmitSound("DOTA_Item.EtherealBlade.Activate")

	-- Fire the projectile
	local projectile =
			{
				Target 				= target,
				Source 				= caster,
				Ability 			= ItemAbility,
				EffectName 			= "particles/items_fx/ethereal_blade.vpcf",
				iMoveSpeed			= 1275,
				vSourceLoc 			= caster:GetOrigin(),
				bDrawsOnMinimap 	= false,
				bDodgeable 			= true,
				bIsAttack 			= false,
				bVisibleToEnemies 	= true,
				bReplaceExisting 	= false,
				flExpireTime 		= GameRules:GetGameTime() + 20,
				bProvidesVision 	= false,
			}
	three_dimension_projectile = projectile
		ProjectileManager:CreateTrackingProjectile(projectile)
end

function ItemAbility_three_dimension_OnProjectileHitUnit(keys)
	-- print_r(three_dimension_projectile)
	local caster = keys.Caster or keys.caster
	local target = keys.Target or keys.target
	if is_spell_blocked(target,caster) then return end
	if target and not target:IsMagicImmune() then
		target:EmitSound("DOTA_Item.EtherealBlade.Target")
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_item_three_dimension_debuff", {})
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_item_three_dimension_debuff_movement_slow", {})
		-- if target:GetTeam() ~= caster:GetTeam() then
		-- end
	end
end

function ItemAbility_jiao_shou(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target_point = keys.target_points[1]
	local cast_range = keys.AbilityCastRange
	local radius = keys.radius
	local effectradius = radius + 125
	caster:EmitSound("DOTA_Item.VeilofDiscord.Activate")
	local effectIndex = ParticleManager:CreateParticle("particles/items2_fx/veil_of_discord.vpcf",PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, target_point)
	ParticleManager:SetParticleControl(effectIndex, 1, Vector(effectradius, 1, 1))
	ParticleManager:ReleaseParticleIndex(effectIndex)
	local targets = FindUnitsInRadius(caster:GetTeam(),target_point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,0,0,false)
	for _,v in pairs(targets) do
		ability:ApplyDataDrivenModifier(caster, v, "modifier_item_jiao_shou_play_debuff", {})
	end
end

function ItemAbility_zaiezhizhurenxing(keys)
	local caster = keys.caster
	local ability = keys.ability
	local radius = keys.effect_radius
	local effect_radius = radius + 250
	local target_point = keys.target_points[1]
	caster:EmitSound("DOTA_Item.VeilofDiscord.Activate")
	local effectIndex = ParticleManager:CreateParticle("particles/items2_fx/veil_of_discord.vpcf",PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, target_point)
	ParticleManager:SetParticleControl(effectIndex, 1, Vector(effect_radius, 1, 1))
	ParticleManager:ReleaseParticleIndex(effectIndex)
	local targets = FindUnitsInRadius(caster:GetTeam(),target_point, nil,radius, DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,0,0,false)
	for _,v in pairs(targets) do
		ability:ApplyDataDrivenModifier(caster, v, "modifier_item_zaiezhizhurenxing_play_debuff", {})
	end
end
------------------------------------------------------------------------------------------------
