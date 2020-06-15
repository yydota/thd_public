
ability_thdots_medicine00 = class({})
modifier_ability_thdots_medicine00_debuff = class({})
modifier_ability_thdots_medicine00_talent = class({})
LinkLuaModifier("modifier_ability_thdots_medicine00_debuff", "scripts/vscripts/abilities/abilitymedicine.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_thdots_medicine00_talent", "scripts/vscripts/abilities/abilitymedicine.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_ability_thdots_medicine00_talent:RemoveOnDeath() return false end
function modifier_ability_thdots_medicine00_talent:IsHidden()  return true end 

function ability_thdots_medicine00:GetBehavior()
	if self:GetCaster():HasModifier("modifier_ability_thdots_medicine00_talent") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_AUTOCAST + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	else
		return self.BaseClass.GetBehavior(self)
	end
end
function ability_thdots_medicine00:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local ability = self
	local castrange = 700
	caster:EmitSound("Hero_Viper.poisonAttack.Cast")
	if caster:HasModifier("modifier_special_bonus_cast_range") then
		castrange = castrange + 150
	end
	local flag = caster:FindAbilityByName("special_bonus_unique_meepo_3"):GetLevel()
	if flag ~= 0 and caster:HasModifier("modifier_ability_thdots_medicine00_talent") == false then 
		local modifier = caster:AddNewModifier(caster, ability, "modifier_ability_thdots_medicine00_talent",{})
	end
	THDReduceCooldown(ability,FindTelentValue(caster,"special_bonus_unique_meepo_4"))
	if FindTelentValue(caster,"special_bonus_unique_meepo_3") ~= 0 then
		local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil,castrange, ability:GetAbilityTargetTeam(),ability:GetAbilityTargetType(),0,0,false)
		-- print(#targets)
		for _,v in pairs(targets) do
			info = {
				EffectName = "particles/units/heroes/hero_viper/viper_poison_attack.vpcf",
				Ability = ability,
				iMoveSpeed = 1200,
				Source = caster,
				Target = v,
				bProvidesVision	= true,
				iVisionRadius = 300,
				bReplaceExisting 	= false,
				flExpireTime 		= GameRules:GetGameTime() + 10,
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
			}
			ProjectileManager:CreateTrackingProjectile(info)
		end
	else
		-- if target:TriggerSpellAbsorb(ability) then return end
		info = {
					EffectName = "particles/units/heroes/hero_viper/viper_poison_attack.vpcf",
					Ability = ability,
					iMoveSpeed = 1200,
					Source = caster,
					Target = target,
					bProvidesVision	= true,
					iVisionRadius = 300,
					bReplaceExisting 	= false,
					flExpireTime 		= GameRules:GetGameTime() + 10,
					iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
				}
		ProjectileManager:CreateTrackingProjectile(info)
	end
end

function ability_thdots_medicine00:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()
	if hTarget ~= nil and hTarget:IsAlive() then
		local medicine00_modifier = hTarget:AddNewModifier(caster, self, "modifier_ability_thdots_medicine00_debuff",{duration = self:GetSpecialValueFor("duration")})
	end
	caster:EmitSound("Hero_Viper.PoisonAttack.Target")
end

function modifier_ability_thdots_medicine00_debuff:IsDebuff() return true end
function modifier_ability_thdots_medicine00_debuff:IsPurgable()
	if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
		return false
	else
		return true
	end
end

function modifier_ability_thdots_medicine00_debuff:GetEffectName()
	return "particles/units/heroes/hero_viper/viper_poison_debuff.vpcf"
end

function modifier_ability_thdots_medicine00_debuff:OnCreated()
	self.ability = self:GetAbility()
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self:SetStackCount(1)
	self:StartIntervalThink(0.5)
end

function modifier_ability_thdots_medicine00_debuff:OnRefresh()
	if not IsServer() then return end
	self:IncrementStackCount()
end

function modifier_ability_thdots_medicine00_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_DECREPIFY_UNIQUE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_ability_thdots_medicine00_debuff:GetModifierMagicalResistanceDecrepifyUnique()
	return self.ability:GetSpecialValueFor("decrease_mgical_resistance") * self:GetStackCount()
end

function modifier_ability_thdots_medicine00_debuff:GetModifierPhysicalArmorBonus()
	return self.ability:GetSpecialValueFor("decrease_armor") * self:GetStackCount()
end

function modifier_ability_thdots_medicine00_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.ability:GetSpecialValueFor("base_slow_movement") + self.ability:GetSpecialValueFor("slow_movement") * (self:GetStackCount() - 1 )
end

function modifier_ability_thdots_medicine00_debuff:OnIntervalThink()
	if not IsServer() then return end
	local damage = self.ability:GetSpecialValueFor("damage") / 2
	local damageTable = {
		attacker = self.caster,
		ability = self.ability,
		victim = self.parent,
		damage = damage,
		damage_type = self.ability:GetAbilityDamageType(),
		damage_flags = 0
	}
	ApplyDamage(damageTable)
end

function OnMedicine01Spellbegining(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local castrange = keys.AbilityCastRange
	if caster:HasModifier("modifier_special_bonus_cast_range") then
		castrange = castrange + 150
	end
	print(castrange)
	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_meepo_4"))
	if FindTelentValue(caster,"special_bonus_unique_meepo_3") ~= 0 then
		local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil,castrange, ability:GetAbilityTargetTeam(),ability:GetAbilityTargetType(),0,0,false)
		for _,v in pairs(targets) do
			if v ~= target then 
			info = {
				EffectName = "particles/units/heroes/hero_viper/viper_poison_attack.vpcf",
				Ability = keys.ability,
				iMoveSpeed = 1200,
				Source = caster,
				Target = v,
				bProvidesVision	= true,
				iVisionRadius = 300,
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
			}
			ProjectileManager:CreateTrackingProjectile(info)
		 	end
		end
	end
end


function OnMedicine01SpellStart(keys)
	local caster = keys.caster
	local target = keys.target
	local stackcount = 1	
	local deal_duration = keys.Duration
	if caster:HasModifier("modifier_item_wanbaochui") then
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_medicine01_debuff_wanbaochui", {duration = deal_duration})
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_medicine01_move_debuff_wanbaochui", {duration = deal_duration})
		stackcount = target:GetModifierStackCount("modifier_medicine01_debuff_wanbaochui", caster)
		stackcount = stackcount + 1 
		target:SetModifierStackCount("modifier_medicine01_debuff_wanbaochui", keys.ability, stackcount)
	else
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_medicine01_debuff", {duration = deal_duration})
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_medicine01_move_debuff", {duration = deal_duration})
		stackcount = target:GetModifierStackCount("modifier_medicine01_debuff", caster)
		stackcount = stackcount + 1 
		target:SetModifierStackCount("modifier_medicine01_debuff", keys.ability, stackcount)
	end
end

function OnMedicine01SpellThink(keys)
	local caster = keys.caster
	local target = keys.target
	local deal_damage = keys.Damage/2
	local damage_table = {
			ability = keys.ability,
			victim = target,
			attacker = caster,
			damage = deal_damage,
			damage_type = keys.ability:GetAbilityDamageType(),
	    	damage_flags = 0
	}
	UnitDamageTarget(damage_table)
	if caster:HasModifier("modifier_item_wanbaochui") then
		local RandomNumber = RandomInt(1,100)
		if RandomNumber<9 then
			local targets = FindUnitsInRadius(
			   		caster:GetTeam(),		--caster team
					target:GetOrigin(),		--find position
			   		nil,					--find entity
			   		400,		--find radius
			   		DOTA_UNIT_TARGET_TEAM_ENEMY,
			   		keys.ability:GetAbilityTargetType(),
			   		0, 
			   		FIND_CLOSEST,
			   		false
				)
			for _,v in pairs(targets) do
				if v~=target then
					local stackcount = 0
					local deal_duration = keys.Duration
					if caster:HasModifier("modifier_item_wanbaochui") then
						keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_medicine01_debuff_wanbaochui", {duration = deal_duration})
						keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_medicine01_move_debuff_wanbaochui", {duration = deal_duration})
						stackcount = v:GetModifierStackCount("modifier_medicine01_debuff_wanbaochui", caster)
						stackcount = stackcount + 1 + FindTelentValue(caster,"special_bonus_unique_meepo_3")
						target:SetModifierStackCount("modifier_medicine01_debuff_wanbaochui", keys.ability, stackcount)
					else
						keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_medicine01_debuff", {duration = deal_duration})
						keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_medicine01_move_debuff", {duration = deal_duration})
						stackcount = v:GetModifierStackCount("modifier_medicine01_debuff", caster)
						stackcount = stackcount + 1 + FindTelentValue(caster,"special_bonus_unique_meepo_3")
						target:SetModifierStackCount("modifier_medicine01_debuff", keys.ability, stackcount)
					end
				end
			end
		end
	end							

end

function OnMedicine02SpellStart(keys)
	local caster = keys.caster
	local effectIndex = ParticleManager:CreateParticle("particles/heroes/medicine/medicine02.vpcf", PATTACH_CUSTOMORIGIN, nil)
	local Damage = keys.Damage+FindTelentValue(caster,"special_bonus_unique_viper_3")
		ParticleManager:SetParticleControl(effectIndex, 0, keys.target_points[1])
		local unit = CreateUnitByName(
			"npc_dota_unit_medicine02"
			,keys.target_points[1]
			,false
			,caster
			,caster
			,caster:GetTeam()
		)
	local time =0
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("OnMedicine02Think"), 
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			if time<keys.Duration then
				time=time+0.5
				local targets = FindUnitsInRadius(
			   		caster:GetTeam(),		--caster team
			  		keys.target_points[1],		--find position
			   		nil,					--find entity
			   		keys.Radius,		--find radius
			   		DOTA_UNIT_TARGET_TEAM_ENEMY,
			   		keys.ability:GetAbilityTargetType(),
			   		0, 
			   		FIND_CLOSEST,
			   		false
		    	)

				for _,v in pairs(targets) do
					local damage_table = {
							ability = keys.ability,
						    victim = v,
						    attacker = caster,
						    damage = Damage/2,
						    damage_type = keys.ability:GetAbilityDamageType(), 
				    	    damage_flags = 0
					}					
					UnitDamageTarget(damage_table)					
				end
				if FindTelentValue(caster,"special_bonus_unique_viper_1") ~= 0 then
					targets = FindUnitsInRadius(
				   		caster:GetTeam(),		--caster team
				  		keys.target_points[1],		--find position
				   		nil,					--find entity
				   		keys.Radius,		--find radius
				   		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
				   		DOTA_UNIT_TARGET_HERO,
				   		0, 
				   		FIND_CLOSEST,
				   		false
			    	)
			    	for _,v in pairs(targets) do
						if v == caster then
							v:Heal(Damage/2, caster)
						end
					end
				end
			else
				if unit ~=nil and unit:IsNull() == false then 
					unit:ForceKill(false)
				end
				return nil
			end
			return 0.5
		end,
	0)
end

function OnMedicine03Attacked(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Attacker = keys.attacker
	if (Attacker:IsBuilding()==false) then
		local damage_to_deal = 0
		if (Attacker:IsHero()) then
			local MaxAttribute = max(max(Attacker:GetStrength(),Attacker:GetAgility()),Attacker:GetIntellect())
			damage_to_deal = keys.PoisonDamageBase + MaxAttribute * keys.PoisonDamageFactor
		end
		damage_to_deal = max(damage_to_deal,keys.PoisonMinDamage)
		if (damage_to_deal>0) then
			local damage_table = {
				ability = keys.ability,
				victim = Attacker,
				attacker = Caster,
				damage = damage_to_deal,
				damage_type = DAMAGE_TYPE_MAGICAL,
				damage_flags = 1
			}
			UnitDamageTarget(damage_table)
			SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_POISON_DAMAGE,Attacker,damage_to_deal,nil)
		end
	end
end

function OnMedicine03TakeDamage(keys)
	local Caster = keys.caster
	local unit = keys.unit
	local Attacker = keys.attacker
	local damage_to_deal = keys.TakenDamage * (keys.BackDamage + FindTelentValue(Caster,"special_bonus_unique_viper_2"))*0.01
	if (Attacker:IsBuilding()==false) and Attacker ~= unit and Attacker:HasModifier("modifier_item_frock_OnTakeDamage") == false then
		if (damage_to_deal>0 and damage_to_deal<=unit:GetMaxHealth()) then
			local damage_table = {
				ability = keys.ability,
				victim = Attacker,
				attacker = Caster,
				damage = damage_to_deal,
				damage_type = DAMAGE_TYPE_MAGICAL,
				damage_flags = 1
			}
			UnitDamageTarget(damage_table)
			SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_POISON_DAMAGE,Attacker,damage_to_deal,nil)
		end
	end
end

function OnMedicine04SpellStart(keys)
	local target = keys.target
	local caster = keys.caster
	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_viper_4"))
	if is_spell_blocked(target) then return end
	if target:HasModifier("modifier_item_dragon_star_buff") then return end
	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_thdots_medicine04_debuff", {})
	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_thdots_medicine04_damage", {})
end

function OnMedicine04Start(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	local ability = keys.ability
	caster.medicine04caster = caster
	caster.medicine04target = target
	target.Team = target:GetTeam()
	target:SetTeam(caster:GetTeam())
	target:MoveToPosition(target:GetOrigin())
end

function OnMedicine04Think(keys)
	local target = keys.target
	AddFOWViewer( target.Team, target:GetOrigin(), 700, 0.1, false)
	local targets = FindUnitsInRadius(
				target.Team,	
				target:GetOrigin(),	
				nil,
				1000,
				DOTA_UNIT_TARGET_TEAM_FRIENDLY,
				DOTA_UNIT_TARGET_HERO,
				0, 
				FIND_CLOSEST,
				false
			)
	if targets[1] == nil then
		targets = FindUnitsInRadius(
				target.Team,	
				target:GetOrigin(),	
				nil,
				1000,
				DOTA_UNIT_TARGET_TEAM_FRIENDLY,
				DOTA_UNIT_TARGET_BASIC,
				0, 
				FIND_CLOSEST,
				false
			)
	end
	for i=1,#targets do 
		if targets[i]~=nil and targets[i]:IsInvisible()==false and targets[i]:GetUnitName()~="npc_reimu_04_dummy_unit" and targets[i]:GetUnitName()~="ability_yuuka_flower" and targets[i]:GetUnitName()~="npc_dota_watch_tower" then
			target:MoveToTargetToAttack(targets[i])
			break
		end
	end
end

function OnMedicine04End(keys)
	local target = keys.target
	local caster = keys.caster
	target:SetTeam(target.Team)
	target:MoveToPosition(target:GetOrigin())
end

function OnTargetDealDamage(keys)
	local caster = keys.caster
	if keys.unit:GetHealth()==0 then
		keys.unit:SetHealth(1)
		keys.unit:Kill( keys.ability, caster.medicine04caster)
	end	
end

function OnTargetTakeDamage(keys)
	local caster = keys.caster
	local target = caster.medicine04target
	if (target.medicine04lock == nil) then
		target.medicine04lock = false
	end

	if (target.medicine04lock == true) then
		return
	end

	target.medicine04lock = true
	if target:GetHealth()==0 then
		target:SetHealth(1)
		target:RemoveModifierByName("modifier_thdots_medicine04_debuff")
		target:Kill(keys.ability, caster.medicine04caster)
	end	
	target.medicine04lock = false
end

