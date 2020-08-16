--------------------------------------------------------
--厄运「逆运绕」
--------------------------------------------------------
ability_thdots_hinaEx = {}

function ability_thdots_hinaEx:GetIntrinsicModifierName()
	return "modifier_ability_thdots_hinaEx_passive"
end

modifier_ability_thdots_hinaEx_passive = {}
LinkLuaModifier("modifier_ability_thdots_hinaEx_passive","scripts/vscripts/abilities/abilityhina.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_hinaEx_passive:IsHidden() 		return false end
function modifier_ability_thdots_hinaEx_passive:IsPurgable()		return false end
function modifier_ability_thdots_hinaEx_passive:RemoveOnDeath() 	return false end
function modifier_ability_thdots_hinaEx_passive:IsDebuff()		return false end

function modifier_ability_thdots_hinaEx_passive:OnCreated()
	if not IsServer() then return end
	self.caster = self:GetParent()
	self.refresh_time = self:GetAbility():GetSpecialValueFor("refresh_time")		--护盾刷新时间
	self.interval_time = self.refresh_time
	self.caster:AddNewModifier(self.caster, self:GetAbility(),"modifier_ability_thdots_hinaEx_shield",{})
	self:StartIntervalThink(0.1)
end

function modifier_ability_thdots_hinaEx_passive:OnIntervalThink()
	if not IsServer() then return end
	self.interval_time = self.interval_time - 0.1
	local MaxHealth_percent = self:GetAbility():GetSpecialValueFor("health_percent") + FindTelentValue(self.caster,"special_bonus_unique_hina_5")
	if self.interval_time <= 0 then
		if not self.caster:HasModifier("modifier_ability_thdots_hinaEx_shield") then
			self.caster:EmitSound("Hero_Wisp.Tether.Stop")
			self.caster:AddNewModifier(self.caster, self:GetAbility(),"modifier_ability_thdots_hinaEx_shield",{})
		else
			local modifier = self.caster:FindModifierByName("modifier_ability_thdots_hinaEx_shield")
			if modifier.shield_remaining ~= MaxHealth_percent * self.caster:GetMaxHealth() / 100 and self.caster:IsAlive() then
				self.caster:EmitSound("Hero_Wisp.Tether.Stop")
				self.caster:AddNewModifier(self.caster, self:GetAbility(),"modifier_ability_thdots_hinaEx_shield",{})
			end
		end
		self.interval_time = self.refresh_time
	end
	--天赋监听
	if FindTelentValue(self.caster,"special_bonus_unique_hina_4") ~= 0 and not self.caster:HasModifier("modifier_ability_thdots_hinaEx_talent4") then
		self.caster:AddNewModifier(self.caster,self:GetAbility(),"modifier_ability_thdots_hinaEx_talent4",{})
	end
	if FindTelentValue(self.caster,"special_bonus_unique_hina_6") ~= 0 and not self.caster:HasModifier("modifier_ability_thdots_hinaEx_talent6") then
		self.caster:AddNewModifier(self.caster,self:GetAbility(),"modifier_ability_thdots_hinaEx_talent6",{})
	end
end

function modifier_ability_thdots_hinaEx_passive:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
end

function modifier_ability_thdots_hinaEx_passive:OnTakeDamage(keys)
	if not IsServer() then return end
	if keys.unit == self:GetParent() then
		-- self.interval_time = self.refresh_time
	end
end

modifier_ability_thdots_hinaEx_shield = {}
LinkLuaModifier("modifier_ability_thdots_hinaEx_shield","scripts/vscripts/abilities/abilityhina.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_hinaEx_shield:IsHidden() 		return true end
function modifier_ability_thdots_hinaEx_shield:IsPurgable()		return false end
function modifier_ability_thdots_hinaEx_shield:RemoveOnDeath() 	return false end
function modifier_ability_thdots_hinaEx_shield:IsDebuff()		return false end

function modifier_ability_thdots_hinaEx_shield:OnCreated()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetParent()
	local shield_size = target:GetModelRadius() * 0.7
	local MaxHealth_percent = self:GetAbility():GetSpecialValueFor("health_percent") + FindTelentValue(caster,"special_bonus_unique_hina_5")
	self.shield_remaining = MaxHealth_percent * self:GetCaster():GetMaxHealth() / 100

	self.particle = ParticleManager:CreateParticle("particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_alliance.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	local common_vector = Vector(shield_size,0,shield_size)
	ParticleManager:SetParticleControl(self.particle, 1, common_vector)
	ParticleManager:SetParticleControl(self.particle, 2, common_vector)
	ParticleManager:SetParticleControl(self.particle, 4, common_vector)
	ParticleManager:SetParticleControl(self.particle, 5, Vector(shield_size,0,0))
	ParticleManager:SetParticleControlEnt(self.particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
end

function modifier_ability_thdots_hinaEx_shield:OnRefresh()
	if not IsServer() then return end
	local MaxHealth_percent = self:GetAbility():GetSpecialValueFor("health_percent") + FindTelentValue(self:GetParent(),"special_bonus_unique_hina_5")
	self.shield_remaining = MaxHealth_percent * self:GetCaster():GetMaxHealth() / 100
end

function modifier_ability_thdots_hinaEx_shield:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK
	}
end

function modifier_ability_thdots_hinaEx_shield:GetModifierTotal_ConstantBlock(kv)
	if not IsServer() then return end
	local target 				= self:GetParent()
	local caster 				= self:GetCaster()
	local target_vector			= target:GetAbsOrigin()
	local original_shield_amount	= self.shield_remaining
	self.shield_remaining = self.shield_remaining - kv.damage
	if kv.damage < original_shield_amount then
		--Emit damage blocking effect
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, kv.target, kv.damage, nil)
		return kv.damage
			--Else, reduce what you can and blow up the shield
	else
		--Emit damage block effect
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, kv.target, original_shield_amount, nil)
		ParticleManager:DestroyParticleSystem(self.particle, true)
		caster:EmitSound("Hero_Abaddon.AphoticShield.Destroy")
		local particle = ParticleManager:CreateParticle("particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_alliance_explosion.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(particle, 0, target_vector)
		ParticleManager:ReleaseParticleIndex(particle)
		self:Destroy()
		return original_shield_amount
	end
end

modifier_ability_thdots_hinaEx_talent4 = modifier_ability_thdots_hinaEx_talent4 or {}  --天赋监听
LinkLuaModifier("modifier_ability_thdots_hinaEx_talent4","scripts/vscripts/abilities/abilityhina.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_hinaEx_talent4:IsHidden() 		return true end
function modifier_ability_thdots_hinaEx_talent4:IsPurgable()		return false end
function modifier_ability_thdots_hinaEx_talent4:RemoveOnDeath() 	return false end
function modifier_ability_thdots_hinaEx_talent4:IsDebuff()		return false end

modifier_ability_thdots_hinaEx_talent6 = modifier_ability_thdots_hinaEx_talent6 or {}  --天赋监听
LinkLuaModifier("modifier_ability_thdots_hinaEx_talent6","scripts/vscripts/abilities/abilityhina.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_hinaEx_talent6:IsHidden() 		return true end
function modifier_ability_thdots_hinaEx_talent6:IsPurgable()		return false end
function modifier_ability_thdots_hinaEx_talent6:RemoveOnDeath() 	return false end
function modifier_ability_thdots_hinaEx_talent6:IsDebuff()		return false end

function modifier_ability_thdots_hinaEx_talent6:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_BONUS,
	}
end

function modifier_ability_thdots_hinaEx_talent6:GetModifierHealthBonus()
	return 1000
end

--------------------------------------------------------
--创符「流刑人形」
--------------------------------------------------------
ability_thdots_hina01 = {}

function ability_thdots_hina01:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
		return "custom/ability_thdots_hina01_wanbaochui"
	else
		return "custom/ability_thdots_hina01"
	end
end

function ability_thdots_hina01:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local duration = self:GetSpecialValueFor("duration")
	local MaxHealth = self:GetSpecialValueFor("health") + FindTelentValue(caster,"special_bonus_unique_hina_1")
	local doll_vec = target:GetAbsOrigin() + RandomVector(300)
	local shield_size = target:GetModelRadius() * 0.7
	local wanbaochui_radius = self:GetSpecialValueFor("wanbaochui_radius")
	local wanbaochui_damage = caster:GetMaxHealth() * self:GetSpecialValueFor("wanbaochui_damage") / 100
	self.table = {}
	if caster:HasModifier("modifier_item_wanbaochui") and caster == target then
		local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),nil,wanbaochui_radius,
			DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0,0, false)
		for _,v in pairs(targets) do
			if v:IsRealHero() and v ~= caster then
				local damage_tabel = {
					victim 			= caster,
					-- Damage starts ramping from when cast time starts, so just gonna simiulate the effects by adding the cast point
					damage 			= wanbaochui_damage,
					damage_type		= DAMAGE_TYPE_PURE,
					damage_flags 	= 0,
					attacker 		= caster,
					ability 		= self
				}
				UnitDamageTarget(damage_tabel)
				hina01_CreateDoll(caster,v,self)
			end
		end
		hina01_CreateDoll(caster,target,self)
	else
		hina01_CreateDoll(caster,target,self)
	end
	-- target:AddNewModifier(caster, self, "modifier_ability_thdots_hina01_shield", {duration = duration})
	-- self.target = target
	-- self.Doll = CreateUnitByName("npc_ability_hina01_doll", 
	-- 		doll_vec,
	-- 		false,
	-- 		caster,
	-- 		caster,
	-- 		caster:GetTeam()
	-- 	)
	-- FindClearSpaceForUnit(self.Doll,self.Doll:GetOrigin(),true)
	-- caster:EmitSound("Hero_Abaddon.AphoticShield.Cast")
	-- self.Doll:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
	-- self.Doll:SetBaseMaxHealth(MaxHealth)
	-- if FindTelentValue(caster,"special_bonus_unique_hina_3") ~= 0 then
	-- 	self.Doll:SetPhysicalArmorBaseValue(20)
	-- 	self.Doll:SetBaseMagicalResistanceValue(70)
	-- end
	-- self.Doll:AddNewModifier(caster, self, "modifier_ability_thdots_hina01_doll", {duration = duration})
	-- self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_aphotic_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	-- local common_vector = Vector(shield_size,0,shield_size)
	-- ParticleManager:SetParticleControl(self.particle, 1, common_vector)
	-- ParticleManager:SetParticleControl(self.particle, 2, common_vector)
	-- ParticleManager:SetParticleControl(self.particle, 4, common_vector)
	-- ParticleManager:SetParticleControl(self.particle, 5, Vector(shield_size,0,0))
	-- ParticleManager:SetParticleControlEnt(self.particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	-- ParticleManager:DestroyParticleSystemTime(self.particle, duration)
	for item_slot = 0, 5 do
		local individual_item = caster:GetItemInSlot(item_slot)
		if individual_item ~= nil then
			print(individual_item:GetName())
		end
	end
end

function hina01_CreateDoll(caster , target , self)
	local caster = caster
	local target = target
	local duration = self:GetSpecialValueFor("duration")
	local MaxHealth = self:GetSpecialValueFor("health") + FindTelentValue(caster,"special_bonus_unique_hina_1")
	local doll_vec = target:GetAbsOrigin() + RandomVector(300)
	local shield_size = target:GetModelRadius() * 0.7
	target:AddNewModifier(caster, self, "modifier_ability_thdots_hina01_shield", {duration = duration})
	self.target = target
	local Doll = CreateUnitByName("npc_ability_hina01_doll", 
			doll_vec,
			false,
			caster,
			caster,
			caster:GetTeam()
		)
	FindClearSpaceForUnit(Doll,Doll:GetOrigin(),true)
	caster:EmitSound("Hero_Abaddon.AphoticShield.Cast")
	Doll:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
	Doll:SetBaseMaxHealth(MaxHealth)
	if FindTelentValue(caster,"special_bonus_unique_hina_3") ~= 0 then
		Doll:SetPhysicalArmorBaseValue(20)
		Doll:SetBaseMagicalResistanceValue(50)
	end
	Doll:AddNewModifier(caster, self, "modifier_ability_thdots_hina01_doll", {duration = duration})
	self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_aphotic_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	local common_vector = Vector(shield_size,0,shield_size)
	ParticleManager:SetParticleControl(self.particle, 1, common_vector)
	ParticleManager:SetParticleControl(self.particle, 2, common_vector)
	ParticleManager:SetParticleControl(self.particle, 4, common_vector)
	ParticleManager:SetParticleControl(self.particle, 5, Vector(shield_size,0,0))
	ParticleManager:SetParticleControlEnt(self.particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:DestroyParticleSystemTime(self.particle, duration)
	local target_and_doll = {target,Doll}
	table.insert(self.table,target_and_doll)
end

modifier_ability_thdots_hina01_shield = {}
LinkLuaModifier("modifier_ability_thdots_hina01_shield","scripts/vscripts/abilities/abilityhina.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_hina01_shield:IsHidden() 		return false end
function modifier_ability_thdots_hina01_shield:IsPurgable()		return false end
function modifier_ability_thdots_hina01_shield:RemoveOnDeath() 	return false end
function modifier_ability_thdots_hina01_shield:IsDebuff()		return false end

function modifier_ability_thdots_hina01_shield:OnCreated()
	if not IsServer() then return end
	self.particle_hit = "particles/units/heroes/hero_warlock/warlock_fatal_bonds_hit.vpcf"
end

function modifier_ability_thdots_hina01_shield:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
	}
end

function modifier_ability_thdots_hina01_shield:GetModifierTotal_ConstantBlock(kv)
	if not IsServer() then return end
	local target 				= self:GetParent()
	local caster 				= self:GetCaster()
	local ability 				= self:GetAbility()
	local target_vector			= target:GetAbsOrigin()
	local doll
	for i=1,#ability.table do
		if ability.table[i][1] == target then
			doll = ability.table[i][2]
		end
	end
	if doll == nil then
		return
	end
	local original_shield_amount	= doll:GetHealth()
	-- local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/merlin/merlin04_thin.vpcf", PATTACH_CUSTOMORIGIN, nil)
	-- ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin()+Vector(0, 0, 100))
	-- ParticleManager:SetParticleControl(effectIndex, 1, doll:GetOrigin()+Vector(0, 0, 100))

	if target:HasModifier("modifier_ability_thdots_hinaEx_shield") then --如果有天生护盾则优先消耗天生护盾
		return
	end
	local particle_hit_fx = ParticleManager:CreateParticle(self.particle_hit, PATTACH_CUSTOMORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(particle_hit_fx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle_hit_fx, 1, doll, PATTACH_POINT_FOLLOW, "attach_hitloc", doll:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(particle_hit_fx)

	local damage_tabel = {
				victim 			= doll,
				-- Damage starts ramping from when cast time starts, so just gonna simiulate the effects by adding the cast point
				damage 			= kv.damage,
				damage_type		= kv.damage_type,
				damage_flags 	= kv.damage_flags,
				attacker 		= kv.attacker,
				ability 		= ability
			}
	UnitDamageTarget(damage_tabel)
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, doll, kv.damage, nil)

	if not doll:IsAlive() then
		caster:EmitSound("Hero_Abaddon.AphoticShield.Destroy")
		ParticleManager:DestroyParticleSystem(ability.particle, true)
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_aphotic_shield_explosion.vpcf", PATTACH_ABSORIGIN, target)
		ParticleManager:SetParticleControl(particle, 0, target_vector)
		ParticleManager:ReleaseParticleIndex(particle)
		self:Destroy()
		return original_shield_amount
	else
		return kv.damage
	end
end

modifier_ability_thdots_hina01_doll = {}
LinkLuaModifier("modifier_ability_thdots_hina01_doll","scripts/vscripts/abilities/abilityhina.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_hina01_doll:IsHidden() 		return false end
function modifier_ability_thdots_hina01_doll:IsPurgable()		return false end
function modifier_ability_thdots_hina01_doll:RemoveOnDeath() 	return false end
function modifier_ability_thdots_hina01_doll:IsDebuff()		return false end

function modifier_ability_thdots_hina01_doll:OnDestroy()
	if not IsServer() then return end
	-- ParticleManager:DestroyParticleSystem(ability.particle, true)
	self:GetParent():RemoveSelf()
end

--------------------------------------------------------
--创符「痛苦流路」
--------------------------------------------------------
ability_thdots_hina02 = class({})		--复制IMBA的致命链接

function ability_thdots_hina02:OnSpellStart()
	-- Ability properties
	local caster = self:GetCaster()
	local ability = self
	local target = self:GetCursorTarget()
	local sound_cast = "Hero_Warlock.FatalBonds"
	local particle_base = "particles/units/heroes/hero_warlock/warlock_fatal_bonds_base.vpcf"
	local particle_hit = "particles/units/heroes/hero_warlock/warlock_fatal_bonds_hit.vpcf"
	local modifier_bonds = "modifier_ability_thdots_hina02_bonds"

	-- Ability specials
	local max_targets = ability:GetSpecialValueFor("max_targets") + FindTelentValue(caster,"special_bonus_unique_hina_2")
	local duration = ability:GetSpecialValueFor("duration")
	local link_search_radius = ability:GetSpecialValueFor("link_search_radius")

	-- Play cast sound
	EmitSoundOn(sound_cast, caster)
	
	-- Initialize variables
	local targets_linked = 0
	local linked_units = {}
	local bond_table = {}

	local modifier_table = {}

	-- If target has Linken's Sphere off cooldown, do nothing
	if target:GetTeam() ~= caster:GetTeam() then
		if target:TriggerSpellAbsorb(ability) then
			return nil
		end
	end

	local bond_target = target

	for link = 1, max_targets do
		-- Find enemies and apply it on them as well, up to the maximum
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
			bond_target:GetAbsOrigin(),
			nil,
			link_search_radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NO_INVIS,
			FIND_CLOSEST,
			false)
			
		for _,enemy in pairs(enemies) do
			if not linked_units[enemy:GetEntityIndex()] then
				local bond_modifier = enemy:AddNewModifier(caster, ability, modifier_bonds, {duration = duration * (1 - enemy:GetStatusResistance())})
				table.insert(modifier_table, bond_modifier)
				
				table.insert(bond_table, enemy)
				linked_units[enemy:GetEntityIndex()] = true

				-- If it was the main target, link from Warlock to it - otherwise, link from the target to them
				if enemy == target then
					local particle_hit_fx = ParticleManager:CreateParticle(particle_hit, PATTACH_CUSTOMORIGIN_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(particle_hit_fx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(particle_hit_fx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
					ParticleManager:ReleaseParticleIndex(particle_hit_fx)

				else
					local particle_hit_fx = ParticleManager:CreateParticle(particle_hit, PATTACH_CUSTOMORIGIN_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(particle_hit_fx, 0, bond_target, PATTACH_POINT_FOLLOW, "attach_hitloc", bond_target:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(particle_hit_fx, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
					ParticleManager:ReleaseParticleIndex(particle_hit_fx)
				end
				
				bond_target	= enemy
				
				break
			end
		end
		
		-- Break out of outer loop early if last loop iteration didn't successfully apply another modifier
		if link > #modifier_table then
			break
		end
	end

	-- Put the bond table on all enemies' debuff modifiers
	for _, modifiers in pairs(modifier_table) do
		modifiers.bond_table = bond_table
	end
end

modifier_ability_thdots_hina02_bonds = class({})
LinkLuaModifier("modifier_ability_thdots_hina02_bonds", "scripts/vscripts/abilities/abilityhina.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_ability_thdots_hina02_bonds:IsHidden() return false end
function modifier_ability_thdots_hina02_bonds:IsPurgable() return true end
function modifier_ability_thdots_hina02_bonds:IsDebuff() return true end
function modifier_ability_thdots_hina02_bonds:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_ability_thdots_hina02_bonds:GetEffectName() return "particles/units/heroes/hero_warlock/warlock_fatal_bonds_icon.vpcf" end
function modifier_ability_thdots_hina02_bonds:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_ability_thdots_hina02_bonds:ShouldUseOverheadOffset() return true end

function modifier_ability_thdots_hina02_bonds:OnCreated()
	-- Ability properties
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.parent = self:GetParent()
	self.sound_damage = "Hero_Warlock.FatalBondsDamage"
	self.particle_icon = "particles/units/heroes/hero_warlock/warlock_fatal_bonds_icon.vpcf"
	self.particle_hit = "particles/units/heroes/hero_warlock/warlock_fatal_bonds_hit.vpcf"
	self.modifier_bonds = "modifier_ability_thdots_hina02_bonds"
	self.ability_hina02 = "ability_thdots_hina02"

	-- Ability specials
	self.link_damage_share_pct = self.ability:GetSpecialValueFor("link_damage_share_pct")
	self.golem_link_radius = self.ability:GetSpecialValueFor("golem_link_radius")
	self.golem_link_damage_pct = self.ability:GetSpecialValueFor("golem_link_damage_pct")

	-- #3 Talent: Fatal Bonds damage share increase
	self.link_damage_share_pct = self.link_damage_share_pct

	-- #7 Talent: Golems share damage they take to Fatal Bonded units, no range limit
	self.golem_link_radius = self.golem_link_radius

	if IsServer() then
		-- Find the caster's Shadow Word ability, if feasible
		if self.caster:HasAbility(self.ability_hina02) then
			self.ability_hina02_handler = self.caster:FindAbilityByName(self.ability_hina02)
		end
	end
end

function modifier_ability_thdots_hina02_bonds:OnDestroy()
	if not IsServer() or self:GetParent():IsAlive() then return end
	
	-- Check every unit that was linked by this modifier
	for _, enemy in pairs(self.bond_table) do
		if enemy ~= self:GetParent() then
		
			-- Find all link modifiers that that unit has
			local bond_modifiers = enemy:FindAllModifiersByName("modifier_ability_thdots_hina02_bonds")

			-- For each link modifier, check its own bond table
			for _, modifier in pairs(bond_modifiers) do

				-- Do it in descending order so there aren't weird indexing issues when removing entries
				for num = #(modifier.bond_table), 1, -1 do
					
					-- If the parent is found in that table, remove it so they don't keep taking damage after respawning
					if (modifier.bond_table)[num] == self:GetParent() then
						table.remove(modifier.bond_table, num)
						break
					end
				end
			end
		end
	end
end

function modifier_ability_thdots_hina02_bonds:DeclareFunctions()
	local decFuncs = {MODIFIER_EVENT_ON_TAKEDAMAGE}

	return decFuncs
end

function modifier_ability_thdots_hina02_bonds:OnTakeDamage(keys)
	if IsServer() and bit.band( keys.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION ) ~= DOTA_DAMAGE_FLAG_REFLECTION then
		local unit = keys.unit
		local original_damage = keys.original_damage
		local damage_type = keys.damage_type
		local inflictor = keys.inflictor

		-- Only apply if the unit taking damage is the parent
		if unit == self:GetParent() and self.bond_table then
			for _, bonded_enemy in pairs(self.bond_table) do
				if not bonded_enemy:IsNull() and bonded_enemy ~= self:GetParent() then
					local damageTable = {
						victim			= bonded_enemy,
						damage			= keys.original_damage * self.link_damage_share_pct * 0.01,
						damage_type		= keys.damage_type,
						attacker		= self:GetCaster(),
						ability			= self.ability,
						damage_flags	= DOTA_DAMAGE_FLAG_REFLECTION
					}

					ApplyDamage(damageTable)
				
					-- Add particle hit effect
					local particle_hit_fx = ParticleManager:CreateParticle(self.particle_hit, PATTACH_CUSTOMORIGIN_FOLLOW, self.parent)
					ParticleManager:SetParticleControlEnt(particle_hit_fx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(particle_hit_fx, 1, bonded_enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", bonded_enemy:GetAbsOrigin(), true)
					ParticleManager:ReleaseParticleIndex(particle_hit_fx)
				end
			end
		-- Instead, if it was an friendly Chaotic Golem that took damage, check if the debuffed unit is in its range
		elseif keys.attacker == self:GetParent() and string.find(keys.unit:GetUnitName(), "warlock_golem") and keys.unit:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
			-- Check distance, if it's in range, damage the parent
			if (keys.unit:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D() <= self.golem_link_radius then
				-- Apply damage
				local damageTable = 
				{
					victim			= self:GetParent(),
					damage			= keys.original_damage * self.golem_link_damage_pct * 0.01,
					damage_type		= keys.damage_type,
					attacker		= self:GetCaster(),
					ability			= self.ability,
					damage_flags	= DOTA_DAMAGE_FLAG_REFLECTION
				}

				ApplyDamage(damageTable)
				
				-- Add particle hit effect
				local particle_hit_fx = ParticleManager:CreateParticle(self.particle_hit, PATTACH_CUSTOMORIGIN_FOLLOW, self.parent)
				ParticleManager:SetParticleControlEnt(particle_hit_fx, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(particle_hit_fx, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(particle_hit_fx)
				
				-- If Shadow Word is not defined on the caster, do nothing
				if not self.ability_hina02_handler then
					return nil
				end
			end
		end
	end
end
--------------------------------------------------------
--疵符「破裂的护符」
--------------------------------------------------------
ability_thdots_hina03 = {}

function ability_thdots_hina03:GetAOERadius()
	if self:GetCaster():HasModifier("modifier_ability_thdots_hinaEx_talent4") then
		return self:GetSpecialValueFor("radius") + 120
	else
		return self:GetSpecialValueFor("radius")
	end
end

function ability_thdots_hina03:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local vPosition = self:GetCursorPosition()
	local ability = self
	local damage = self:GetSpecialValueFor("damage")
	local radius = self:GetSpecialValueFor("radius") + FindTelentValue(caster,"special_bonus_unique_hina_4")
	local duration = self:GetSpecialValueFor("duration")
	local targets = FindUnitsInRadius(caster:GetTeam(), vPosition, nil, radius,
		ability:GetAbilityTargetTeam(),ability:GetAbilityTargetType(),0,0,false)
	local aoe_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_maledict_aoe.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl( aoe_pfx, 0, vPosition )
	ParticleManager:SetParticleControl( aoe_pfx, 1, Vector(radius, radius, radius) )
	ParticleManager:ReleaseParticleIndex(aoe_pfx)
	for _,v in pairs(targets) do
		v:AddNewModifier(caster,ability, "modifier_ability_thdots_hina03",{duration = duration})
		local damageTable = 
				{
					victim			= v,
					damage			= damage,
					damage_type		= ability:GetAbilityDamageType(),
					attacker		= caster,
					ability			= self.ability,
					damage_flags	= self:GetAbilityTargetFlags()
				}
		ApplyDamage(damageTable)
	end
	if #targets > 0 then
		EmitSoundOn("Hero_WitchDoctor.Maledict_Cast", self:GetCaster())
	else
		EmitSoundOn("Hero_WitchDoctor.Maledict_CastFail", self:GetCaster())
	end
end

modifier_ability_thdots_hina03 = {}
LinkLuaModifier("modifier_ability_thdots_hina03","scripts/vscripts/abilities/abilityhina.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_hina03:IsHidden() 		return false end
function modifier_ability_thdots_hina03:IsPurgable()		return true end
function modifier_ability_thdots_hina03:RemoveOnDeath() 	return true end
function modifier_ability_thdots_hina03:IsDebuff()		return true end

function modifier_ability_thdots_hina03:GetStatusEffectName()
	return "particles/status_fx/status_effect_maledict.vpcf"
end

function modifier_ability_thdots_hina03:StatusEffectPriority()
	return 5
end

function modifier_ability_thdots_hina03:OnCreated()
	if not IsServer() then return end
	local hAbility 	 = self:GetAbility()
	local hParent	 = self:GetParent()
	self.burstParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_maledict.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(self.burstParticle, 0, hParent, PATTACH_POINT_FOLLOW, "attach_hitloc", hParent:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(self.burstParticle, 1, Vector(hAbility:GetSpecialValueFor("duration"), 0, 0))
	ParticleManager:SetParticleControl(self.burstParticle, 2, Vector(128, 1, 1))
	ParticleManager:DestroyParticleSystemTime(self.burstParticle,hAbility:GetSpecialValueFor("duration")+1)
end

function modifier_ability_thdots_hina03:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }
end

function modifier_ability_thdots_hina03:GetModifierIncomingDamage_Percentage()
	return self:GetAbility():GetSpecialValueFor("extra_damage")
end
--------------------------------------------------------
--厄符「噩运储存」
--------------------------------------------------------

ability_thdots_hina04 = {}

function ability_thdots_hina04:OnSpellStart()
	self.absorb_damage 	= 0
	if not IsServer() then return end
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	caster:AddNewModifier(caster, self, "modifier_ability_thdots_hina04", {duration = duration})
end


modifier_ability_thdots_hina04 = {}
LinkLuaModifier("modifier_ability_thdots_hina04","scripts/vscripts/abilities/abilityhina.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_hina04:IsHidden() 		return false end
function modifier_ability_thdots_hina04:IsPurgable()		return false end
function modifier_ability_thdots_hina04:RemoveOnDeath() 	return true end
function modifier_ability_thdots_hina04:IsDebuff()		return false end

modifier_ability_thdots_hina04_damage = {}
LinkLuaModifier("modifier_ability_thdots_hina04_damage","scripts/vscripts/abilities/abilityhina.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_hina04_damage:IsHidden() 		return true end
function modifier_ability_thdots_hina04_damage:IsPurgable()		return false end
function modifier_ability_thdots_hina04_damage:RemoveOnDeath() 	return false end
function modifier_ability_thdots_hina04_damage:IsDebuff()		return false end


function modifier_ability_thdots_hina04:OnCreated()
	self.caster 				= self:GetParent()
	self.ability 				= self:GetAbility()
	self.stun_time				= self:GetAbility():GetSpecialValueFor("stun_time")
	self.gravitation			= self:GetAbility():GetSpecialValueFor("gravitation")
	self.damage_absorb			= self:GetAbility():GetSpecialValueFor("damage_absorb")
	self.end_stun_time			= self:GetAbility():GetSpecialValueFor("end_stun_time")
	self.radius					= self:GetAbility():GetSpecialValueFor("radius")
	if not IsServer() then return end
	EmitSoundOn("Hero_Wisp.Spirits.Loop", self.caster )
	EmitSoundOn("Hero_Wisp.Relocate.Arc", self.caster )
	EmitSoundOn("Hero_Wisp.ReturnCounter", self.caster )
	self:StartIntervalThink(0.03)
	self.caster:StartGestureWithPlaybackRate(ACT_DOTA_IDLE,10)
	local pfx_name = "particles/heroes/hina/hina04.vpcf"
	self.particle = ParticleManager:CreateParticle(pfx_name, PATTACH_ABSORIGIN_FOLLOW, self.caster)
	ParticleManager:SetParticleControl(self.particle, 0, Vector(self:GetParent():GetAbsOrigin().x,self:GetParent():GetAbsOrigin().y,self:GetParent():GetAbsOrigin().z+64))
	ParticleManager:SetParticleControl(self.particle, 10, Vector(self.radius, self.pull_radius, 0))
end

function modifier_ability_thdots_hina04:OnIntervalThink()
	if not IsServer() then return end
	local caster = self.caster
	local enemies = FindUnitsInRadius(self.caster:GetTeam(),self.caster:GetAbsOrigin(),nil,
	 			self.radius,self.ability:GetAbilityTargetTeam(),self.ability:GetAbilityTargetType(),0,0,false)
	-- local speed =  self.gravitation / distance * 2 + self:GetAbility().absorb_damage / 50 --伤害越高，离中心越近，引力越强
	local speed = self.gravitation / 30 + self:GetAbility().absorb_damage / 150
	-- print(speed)
	for _,v in pairs (enemies) do
		local vec = v:GetAbsOrigin()
		local distance = ( caster:GetAbsOrigin() - vec):Length2D()
		local direct = ( caster:GetAbsOrigin() - vec):Normalized() * speed
		FindClearSpaceForUnit(v,v:GetAbsOrigin() + direct, true)
	end
	ParticleManager:SetParticleControl(self.particle, 0, Vector(self:GetParent():GetAbsOrigin().x,self:GetParent():GetAbsOrigin().y,self:GetParent():GetAbsOrigin().z+64))
	ParticleManager:SetParticleControl(self.particle, 10, Vector(self.radius, self.pull_radius, 0))
end

-- function modifier_ability_thdots_hina04:CheckState() --大招无碰撞
-- 	-- return {[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
-- 	return {
-- 		[MODIFIER_STATE_NO_UNIT_COLLISION] 		= true
-- 	}
-- end

function modifier_ability_thdots_hina04:DeclareFunctions()
	return {
		-- MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
		-- MODIFIER_EVENT_ON_DEATH,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
end

-- function modifier_ability_thdots_hina04:OnDeath(keys)
-- 	if not IsServer() then return end
-- 	if keys.unit == self:GetParent() then
-- 		local caster = self.GetParent()
-- 		ParticleManager:DestroyParticle(self.particle, false)
-- 		ParticleManager:ReleaseParticleIndex(self.particle)
-- 		self.dummy = CreateUnitByName("npc_dummy_unit", 
-- 	    	                        caster:GetOrigin(), 
-- 									false, 
-- 								    caster, 
-- 									caster, 
-- 									caster:GetTeamNumber()
-- 									)
-- 		self.caster:RemoveModifierByName("modifier_ability_thdots_hina04")
-- 	end
-- end

function modifier_ability_thdots_hina04:OnDestroy()
	if not IsServer() then return end
	local caster = self.caster
	print(self:GetAbility().absorb_damage)
	ParticleManager:DestroyParticle(self.particle, false)
	ParticleManager:ReleaseParticleIndex(self.particle)
	caster:RemoveGesture(ACT_DOTA_IDLE)
	local end_stun_time = self:GetAbility():GetSpecialValueFor("end_stun_time")
	caster:StopSound("Hero_Wisp.Spirits.Loop")
	caster:StopSound("Hero_Wisp.ReturnCounter")
	caster:EmitSound("Hero_Nevermore.RequiemOfSouls")
	UtilStun:UnitStunTarget(caster,caster,end_stun_time)
	
	local line_position = self.caster:GetAbsOrigin() + self.caster:GetForwardVector() * 1000
	local line_count = 6
	line_count = line_count + math.floor( self:GetAbility().absorb_damage/100 )
	if line_count > 18 then 
		line_count = 18
	end
	local qangle_rotation_rate = 360 / line_count
	local particle_caster_souls = "particles/units/heroes/hero_nevermore/nevermore_requiemofsouls_a.vpcf"
	local particle_caster_ground = "particles/units/heroes/hero_nevermore/nevermore_requiemofsouls.vpcf"
	local particle_caster_souls_fx = ParticleManager:CreateParticle(particle_caster_souls, PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle_caster_souls_fx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_caster_souls_fx, 1, Vector(lines, 0, 0))
	ParticleManager:SetParticleControl(particle_caster_souls_fx, 2, caster:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle_caster_souls_fx)

	local particle_caster_ground_fx = ParticleManager:CreateParticle(particle_caster_ground, PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle_caster_ground_fx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_caster_ground_fx, 1, Vector(lines, 0, 0))
	ParticleManager:ReleaseParticleIndex(particle_caster_ground_fx)
	self.dummy = CreateUnitByName("npc_dummy_unit", 
	    	                        caster:GetOrigin(), 
									false, 
								    caster, 
									caster, 
									caster:GetTeamNumber()
									)
	caster:SetContextThink("dummy_kill",
		function ()
			for i = 1, line_count do
				local qangle = QAngle(0, qangle_rotation_rate, 0)
				line_position = RotatePosition(self.caster:GetAbsOrigin(), qangle, line_position)

				-- Create every other line
				-- if self.caster:IsAlive() then
				-- 	CreateRequiemSoulLine(self.caster, self.ability, line_position, false)
				-- else
				-- 	self.dummy = CreateUnitByName("npc_dummy_unit", 
			 --    	                        caster:GetOrigin(), 
				-- 							false, 
				-- 						    caster, 
				-- 							caster, 
				-- 							caster:GetTeamNumber()
				-- 							)
				-- end
				CreateRequiemSoulLine(self.dummy, self.ability, line_position, false)
			caster:SetContextThink("dummy_kill",
				function ()
					print("doit")
					if self.dummy ~= nil then
						self.dummy:ForceKill(true)
					end
				end,
			1)
			end
		end,
	0.03)
end

function modifier_ability_thdots_hina04:OnTakeDamage(keys)
	if not IsServer() then return end
	local caster = self:GetParent()
	local unit = keys.unit
	local distance = (unit:GetOrigin() - caster:GetOrigin()):Length2D()
	if distance <= self.radius then
		local absorb = ( keys.damage * self.damage_absorb / 100)
		if unit:GetHealth() >= keys.damage then
			-- print("-------------")
			unit:SetHealth(unit:GetHealth() - keys.damage + absorb)
		end
		self:GetAbility().absorb_damage = self:GetAbility().absorb_damage + absorb
		-- print(self:GetAbility().absorb_damage)
	end
end

-- function modifier_ability_thdots_hina04:GetModifierTotal_ConstantBlock(kv)
-- 	if not IsServer() then return end
-- 	local absorb = ( kv.damage * self.damage_absorb / 100)
-- 	-- print_r(kv)
-- 	self:GetAbility().absorb_damage = self:GetAbility().absorb_damage + absorb
-- 	return absorb
-- end

function ability_thdots_hina04:OnProjectileHit_ExtraData(target, location, extra_data)
	-- If there was no target, do nothing
	if not target then
		return nil
	end
	local caster = self:GetCaster()
	local ability = self
	local stun_time = self:GetSpecialValueFor("stun_time")
	target:AddNewModifier(caster, ability, "modifier_ability_thdots_hina04_damage",{duration = stun_time})
	target:EmitSound("Hero_Nevermore.RequiemOfSouls.Damage")
end

function modifier_ability_thdots_hina04_damage:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true,
	}
end

function modifier_ability_thdots_hina04_damage:OnCreated()
	if not IsServer() then return end
	local ability = self:GetAbility()
	local caster = ability:GetCaster()
	local target = self:GetParent()
	local damage = ability.absorb_damage + ability:GetSpecialValueFor("min_damage")
	-- print("damage is :",damage)
	local damageTable = {victim = target,
						damage = damage,
						damage_type = ability:GetAbilityDamageType(),
						attacker = caster,
						ability = ability
						}
	local damage_dealt = ApplyDamage(damageTable)
end
function CreateRequiemSoulLine(caster, ability, line_end_position, death_cast) --IMBA影魔大招特效
	-- Ability properties
	local particle_lines = "particles/units/heroes/hero_nevermore/nevermore_requiemofsouls_line.vpcf"
	-- Ability specials
	local travel_distance = ability:GetSpecialValueFor("travel_distance")
	local lines_starting_width = ability:GetSpecialValueFor("lines_starting_width")
	local lines_end_width = ability:GetSpecialValueFor("lines_end_width")
	local travel_distance = ability:GetSpecialValueFor("travel_distance")
	local lines_travel_speed = ability:GetSpecialValueFor("lines_travel_speed")

	-- Calculate the time that it would take to reach the maximum distance
	local max_distance_time = travel_distance / lines_travel_speed

	-- Calculate velocity
	local velocity = (line_end_position - caster:GetAbsOrigin()):Normalized() * lines_travel_speed
	print(velocity)
	-- Launch the line
	projectile_info = {Ability = ability,
					   EffectName = particle_lines,
					   vSpawnOrigin = caster:GetAbsOrigin(),
					   fDistance = travel_distance,
					   fStartRadius = lines_starting_width,
					   fEndRadius = lines_end_width,
					   Source = caster,
					   bHasFrontalCone = false,
					   bReplaceExisting = false,
					   iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
					   iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
					   iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
					   bDeleteOnHit = false,
					   vVelocity = velocity,
					   bProvidesVision = false,
					   ExtraData = {scepter_line = false}
					   }

	-- Create the projectile
	ProjectileManager:CreateLinearProjectile(projectile_info)

	-- Create the particle
	local particle_lines_fx = ParticleManager:CreateParticle(particle_lines, PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle_lines_fx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_lines_fx, 1, velocity)
	ParticleManager:SetParticleControl(particle_lines_fx, 2, Vector(0, max_distance_time, 0))
	ParticleManager:ReleaseParticleIndex(particle_lines_fx)
end