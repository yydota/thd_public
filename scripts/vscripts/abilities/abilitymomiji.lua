function OnMomiji01Spawn(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	if caster.ability_momiji01_Spawn_unit == nil then
		caster.ability_momiji01_Spawn_unit = {}
	end

	count = 2 + FindTelentValue(caster,"special_bonus_unique_bounty_hunter")
	-- if caster:HasModifier("modifier_item_wanbaochui") then
	-- 	count = count + 1
	-- end

	for i=1,count do
		local unit = CreateUnitByName(
			"ability_momiji_Spawn_unit"
			,caster:GetOrigin() + ( caster:GetForwardVector() + Vector(math.cos((i-1.5)*math.pi/3),math.sin((i-1.5)*math.pi/3),0) ) * 100
			,false
			,caster
			,caster
			,caster:GetTeam()
		)

		if unit == nil then return end

		unit:CreatureLevelUp(keys.ability:GetLevel())
		unit:SetControllableByPlayer(caster:GetPlayerOwnerID(), true) 
		-- if caster:HasModifier("modifier_item_wanbaochui") then
		-- 	keys.ability:ApplyDataDrivenModifier( caster, unit, "modifier_momiji_01_wanbaochui_buff", {} )
		-- end
		SetTargetToTraversable(unit)
		
		if FindTelentValue(caster,"special_bonus_unique_lycan_1") == 1 then 			
			
			unit:AddAbility("ability_system_criticalstrike_2")
			local ability = unit:FindAbilityByName("ability_system_criticalstrike_2")
			ability:SetLevel(1)			
		
			if not caster:HasAbility("ability_system_criticalstrike_2") then
				caster:RemoveAbility("ability_system_criticalstrike")
				caster:RemoveModifierByName("modifier_system_attack")
				caster:AddAbility("ability_system_criticalstrike_2")
				local ability = caster:FindAbilityByName("ability_system_criticalstrike_2")
				ability:SetLevel(1)
			end
		else
			unit:AddAbility("ability_system_criticalstrike")
			local ability = unit:FindAbilityByName("ability_system_criticalstrike")
			ability:SetLevel(1)
		end

		if FindTelentValue(caster,"special_bonus_unique_bounty_hunter_2") == 1 then 
			unit:AddAbility("ability_thdots_momiji_unit")
			unit:SetBaseMaxHealth(1800)
			ability = unit:FindAbilityByName("ability_thdots_momiji_unit")		
			ability:SetLevel(1)
		end

		if keys.ability:GetLevel() >=3 then
			unit:AddAbility("lycan_summon_wolves_invisibility")
			ability = unit:FindAbilityByName("lycan_summon_wolves_invisibility")
			ability:SetLevel(1)
		end

		local oldSwpanUnit = caster.ability_momiji01_Spawn_unit[i]
		if oldSwpanUnit ~=nil and oldSwpanUnit:IsNull() == false then 
			oldSwpanUnit:ForceKill(false)
		end
		caster.ability_momiji01_Spawn_unit[i] = unit

		unit:SetContextThink(
		"ability_momiji01_Spawn_unit_regen", 
			function ()
				if GameRules:IsGamePaused() then return 0.03 end
				if GetDistanceBetweenTwoVec2D(caster:GetOrigin(),unit:GetOrigin()) <= keys.AuraDistance then
					unit:Heal(keys.RegenAmount/5, caster)
					local abilityMomiji04Caster = caster:FindAbilityByName("ability_thdots_momiji04")
					if abilityMomiji04Caster ~= nil then
						local abilityMomiji04 = unit:FindAbilityByName("ability_thdots_momiji04")
						if abilityMomiji04==nil then
							unit:AddAbility("ability_thdots_momiji04")
							abilityMomiji04 = unit:FindAbilityByName("ability_thdots_momiji04")
							abilityMomiji04:SetLevel(abilityMomiji04Caster:GetLevel())
						elseif abilityMomiji04:GetLevel() ~= abilityMomiji04Caster:GetLevel() then
							abilityMomiji04:SetLevel(abilityMomiji04Caster:GetLevel())
						end
					end
				else
					local abilityMomiji04 = unit:FindAbilityByName("ability_thdots_momiji04")
					if abilityMomiji04 ~= nil then
						unit:RemoveAbility("ability_thdots_momiji04")
						unit:RemoveModifierByName("passive_momiji04_bonus")
					end
				end
				return 0.2
			end, 
		0.2)
	end
end

function OnMomiji02Start(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local Duration = keys.Duration
	AddFOWViewer( caster:GetTeam(), keys.target_points[1], keys.Radius, Duration, false)
	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_bounty_hunter_3"))
	
	local effectIndex = ParticleManager:CreateParticle("particles/econ/courier/courier_trail_05/courier_trail_05.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, keys.target_points[1])

	ParticleManager:DestroyParticleSystemTime(effectIndex,Duration)

	local unit = CreateUnitByName(
		"npc_vision_momiji_dummy_unit"
		,caster:GetOrigin()
		,false
		,caster
		,caster
		,caster:GetTeam()
	)

	unit:SetOrigin(keys.target_points[1])

	local abilityGEM = unit:FindAbilityByName("ability_thdots_momiji02_unit")
	if abilityGEM ~= nil then
		abilityGEM:SetLevel(keys.ability:GetLevel())
		unit:CastAbilityImmediately(abilityGEM, 0)
	end

	local ability_dummy_unit = unit:FindAbilityByName("ability_dummy_unit")
	ability_dummy_unit:SetLevel(1)

	unit:SetContextThink("ability_momiji_02_vision", 
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			unit:RemoveSelf()
		end, 
	Duration)

	--[[Timer.Loop 'ability_momiji02_vision' (1.0, 150,
			function (i)
				local targets = FindUnitsInRadius(
					   caster:GetTeam(),		--caster team
					   keys.target_points[1],		--find position
					   nil,							--find entity
					   keys.Radius,		--find radius
					   DOTA_UNIT_TARGET_TEAM_ENEMY,
					   keys.ability:GetAbilityTargetType(),
					   0, FIND_CLOSEST,
					   false
				    )
				for k,v in pairs(targets) do
					keys.ability:ApplyDataDrivenModifier( caster, v, "modifier_momiji02_antiinvisible", {Duration=1.0} )
				end
			end
	)]]--
end

function OnMomiji03Start(keys)
	if is_spell_blocked(keys.target) then return end
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	UtilStun:UnitStunTarget( caster,target,keys.Duration)
	
	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_storm_bolt_projectile_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin())
	ParticleManager:SetParticleControl(effectIndex, 1, target:GetOrigin())
	ParticleManager:SetParticleControl(effectIndex, 3, target:GetOrigin())

	local DamageTable = {
			victim = target, 
			attacker = caster, 
			ability = keys.ability,
			damage = keys.ability:GetAbilityDamage(), 
			damage_type = keys.ability:GetAbilityDamageType(), 
			damage_flags = keys.ability:GetAbilityTargetFlags()
	}
	 UnitDamageTarget(DamageTable)
end


ability_thdots_momiji03 = {}

function ability_thdots_momiji03:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local duration = self:GetSpecialValueFor("ability_duration")
	if is_spell_blocked(target) then return end
	caster:EmitSound("Hero_DragonKnight.DragonTail.Target")
	UtilStun:UnitStunTarget(caster,target,duration)
	
	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_storm_bolt_projectile_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin())
	ParticleManager:SetParticleControl(effectIndex, 1, target:GetOrigin())
	ParticleManager:SetParticleControl(effectIndex, 3, target:GetOrigin())

	local DamageTable = {
			victim = target, 
			attacker = caster, 
			ability = self,
			damage = self:GetAbilityDamage(), 
			damage_type = self:GetAbilityDamageType(), 
			damage_flags = self:GetAbilityTargetFlags()
	}
	 UnitDamageTarget(DamageTable)

	
end
function ability_thdots_momiji03:GetIntrinsicModifierName()
	return "modifier_ability_thdots_momiji03_passvie"
end

modifier_ability_thdots_momiji03_passvie = {}
LinkLuaModifier("modifier_ability_thdots_momiji03_passvie","scripts/vscripts/abilities/abilityMomiji.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_momiji03_passvie:IsHidden() 		return false end
function modifier_ability_thdots_momiji03_passvie:IsPurgable()		return false end
function modifier_ability_thdots_momiji03_passvie:RemoveOnDeath() 	return false end
function modifier_ability_thdots_momiji03_passvie:IsDebuff()		return false end

function modifier_ability_thdots_momiji03_passvie:DeclareFunctions()
	return
	{
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
	}
end

function modifier_ability_thdots_momiji03_passvie:GetModifierTotal_ConstantBlock(kv)
	if not IsServer() then return end
	if kv.attacker == nil then return end
	local caster = self:GetParent()
	local target = kv.attacker
	local defence = kv.damage * self:GetAbility():GetSpecialValueFor("physical_block") / 100

	local vecV = target:GetOrigin()
	local vecCaster = caster:GetOrigin()
	local targetPoint =  vecCaster + caster:GetForwardVector() --keys.target_points[1]
	local sparkRad = GetRadBetweenTwoVec2D(vecCaster,targetPoint)

	--正面减少物理伤害
	if IsRadInRect(vecV,vecCaster,400,99999,sparkRad) and kv.damage_type == 1 then
		local particle_name =  "particles/units/heroes/hero_mars/mars_shield_of_mars.vpcf"
		local fxIndex = ParticleManager:CreateParticle(particle_name, PATTACH_CUSTOMORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(fxIndex , 0, caster, 1, "attach_hitloc", Vector(0,0,0), true)

		caster:EmitSound("Voice_Thdots_Momiji.AbilityMomiji03")
		return defence
	else
		return 0
	end
end


--狗椛大招
ability_thdots_momiji04 = {}

function ability_thdots_momiji04:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("radius")
end

function ability_thdots_momiji04:GetCooldown(level)
	if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
		return self:GetSpecialValueFor("wanbaochui_cooldonw")
	else
		return 0
	end
end

function ability_thdots_momiji04:GetIntrinsicModifierName()
	return "passive_momiji04_bonus"
end

function ability_thdots_momiji04:GetBehavior()
	if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
		return DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_NO_TARGET
	else
		return self.BaseClass.GetBehavior(self)
	end
end

--被动光环主体
passive_momiji04_bonus = {}
LinkLuaModifier("passive_momiji04_bonus","scripts/vscripts/abilities/abilityMomiji.lua",LUA_MODIFIER_MOTION_NONE)
function passive_momiji04_bonus:IsHidden() 		return false end
function passive_momiji04_bonus:IsPurgable()		return false end
function passive_momiji04_bonus:RemoveOnDeath() 	return false end
function passive_momiji04_bonus:IsDebuff()		return false end

function passive_momiji04_bonus:IsAura()	return true end
function passive_momiji04_bonus:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end -- global
function passive_momiji04_bonus:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function passive_momiji04_bonus:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function passive_momiji04_bonus:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function passive_momiji04_bonus:GetAuraEntityReject(target) return target == self:GetCaster() end
function passive_momiji04_bonus:GetModifierAura() return "modifier_momiji04_bonus" end

function passive_momiji04_bonus:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end


function passive_momiji04_bonus:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("attack_speed")
end

function passive_momiji04_bonus:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("move_speed")
end

--被动光环
modifier_momiji04_bonus = {}
LinkLuaModifier("modifier_momiji04_bonus","scripts/vscripts/abilities/abilityMomiji.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_momiji04_bonus:IsHidden() 		return false end
function modifier_momiji04_bonus:IsPurgable()		return false end
function modifier_momiji04_bonus:RemoveOnDeath() 	return true end
function modifier_momiji04_bonus:IsDebuff()		return false end

function modifier_momiji04_bonus:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_momiji04_bonus:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("aura_move_speed")
end

function ability_thdots_momiji04:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local ability = self
	local duration = self:GetSpecialValueFor("wanbaochui_duration")
	local sound_cast = "Hero_Centaur.Stampede.Cast"
	print("do it")
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(),nil,99999,DOTA_UNIT_TARGET_TEAM_FRIENDLY,
			DOTA_UNIT_TARGET_HERO,0,0,false)
	for _,v in pairs(targets) do
		if v:IsRealHero() then
			print(v:GetName())
			v:AddNewModifier(caster, self, "modifier_momiji04_wanbaochui_bonus", {duration = duration})
		end
	end
	EmitSoundOn(sound_cast, caster)
end

--万宝槌移速
modifier_momiji04_wanbaochui_bonus = {}
LinkLuaModifier("modifier_momiji04_wanbaochui_bonus","scripts/vscripts/abilities/abilityMomiji.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_momiji04_wanbaochui_bonus:IsHidden() 		return false end
function modifier_momiji04_wanbaochui_bonus:IsPurgable()		return true end
function modifier_momiji04_wanbaochui_bonus:RemoveOnDeath() 	return true end
function modifier_momiji04_wanbaochui_bonus:IsDebuff()		return false end
function modifier_momiji04_wanbaochui_bonus:GetEffectName()
	return "particles/units/heroes/hero_centaur/centaur_stampede_overhead.vpcf"
end

function modifier_momiji04_wanbaochui_bonus:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_momiji04_wanbaochui_bonus:OnCreated()
	if not IsServer() then return end
	self.particle_stampede = "particles/units/heroes/hero_centaur/centaur_stampede.vpcf"
	self.particle_stampede_fx = ParticleManager:CreateParticle(self.particle_stampede, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(self.particle_stampede_fx, 0, self:GetParent():GetAbsOrigin())
end

function modifier_momiji04_wanbaochui_bonus:OnDestroy()
	if not IsServer() then return end
	-- ParticleManager:ReleaseParticleIndex(self.particle_stampede_fx)
	ParticleManager:DestroyParticleSystem(self.particle_stampede_fx,true)
end

function modifier_momiji04_wanbaochui_bonus:CheckState()
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
	}
end

function modifier_momiji04_wanbaochui_bonus:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_momiji04_wanbaochui_bonus:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("wanbaochui_movement")
end
