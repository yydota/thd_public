--------------------------------------------------------
--产灵「最初的金字塔」
--------------------------------------------------------
ability_thdots_keineEx = {}

function ability_thdots_keineEx:GetIntrinsicModifierName()
	return "modifier_ability_thdots_keineEx_passive"
end

modifier_ability_thdots_keineEx_passive = {}
LinkLuaModifier("modifier_ability_thdots_keineEx_passive","scripts/vscripts/abilities/abilitykeine.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_keineEx_passive:IsHidden() 		return false end
function modifier_ability_thdots_keineEx_passive:IsPurgable()		return false end
function modifier_ability_thdots_keineEx_passive:RemoveOnDeath() 	return false end
function modifier_ability_thdots_keineEx_passive:IsDebuff()		return false end

function modifier_ability_thdots_keineEx_passive:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("wanbaochui_range") end -- global
function modifier_ability_thdots_keineEx_passive:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_ability_thdots_keineEx_passive:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_ability_thdots_keineEx_passive:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
-- function modifier_ability_thdots_keineEx_passive:IsAuraActiveOnDeath()	return true	end  --是否死亡触发
function modifier_ability_thdots_keineEx_passive:GetModifierAura() return "modifier_ability_thdots_keineEx_passive_aura" end
function modifier_ability_thdots_keineEx_passive:IsAura() return self:GetCaster():HasModifier("modifier_item_wanbaochui") end
function modifier_ability_thdots_keineEx_passive:GetAuraEntityReject(target) return target == self:GetCaster() end

function modifier_ability_thdots_keineEx_passive:DeclareFunctions()
	return
	{
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_RESPAWNTIME,
		MODIFIER_PROPERTY_RESPAWNTIME_PERCENTAGE
	}
end

function modifier_ability_thdots_keineEx_passive:GetModifierConstantRespawnTime()
	--正数增加，负数减少
	if not self:GetParent():HasModifier("modifier_ability_thdots_keineEx_talent3") then
		return self:GetAbility():GetSpecialValueFor("keine_time")
	else
		return 0
	end
end

function modifier_ability_thdots_keineEx_passive:GetModifierPercentageRespawnTime()
	--百分比复活时间， 正数减少，负数增加。0.5表示减少50%复活时间
	if self:GetParent():HasModifier("modifier_ability_thdots_keineEx_talent3") then
		return self:GetAbility():GetSpecialValueFor("percent_time") / 100
	else
		return 0
	end
end

function modifier_ability_thdots_keineEx_passive:OnDeath(keys)
	if not IsServer() then return end
	if keys.unit == self:GetParent() then
		print("siwang")
		keys.unit:SetContextThink("HasAegis",
			function()
				if keys.unit:GetTimeUntilRespawn() > 5 then
					print(keys.unit:GetTimeUntilRespawn())
				end
			end
		,FrameTime())
	end
end

function modifier_ability_thdots_keineEx_passive:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end

function modifier_ability_thdots_keineEx_passive:OnIntervalThink()
	if not IsServer() then return end
	--天赋监听
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_keine_3") ~= 0 and not self:GetCaster():HasModifier("modifier_ability_thdots_keineEx_talent3") then
		self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_keineEx_talent3",{})
	end
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_keine_2") ~= 0 and not self:GetCaster():HasModifier("modifier_ability_thdots_keineEx_talent2") then
		self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_keineEx_talent2",{})
	end
end

modifier_ability_thdots_keineEx_talent2 = {}  --天赋监听
LinkLuaModifier("modifier_ability_thdots_keineEx_talent2","scripts/vscripts/abilities/abilitykeine.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_keineEx_talent2:IsHidden() 		return true end
function modifier_ability_thdots_keineEx_talent2:IsPurgable()		return false end
function modifier_ability_thdots_keineEx_talent2:RemoveOnDeath() 	return false end
function modifier_ability_thdots_keineEx_talent2:IsDebuff()		return false end

modifier_ability_thdots_keineEx_talent3 = {}  --天赋监听
LinkLuaModifier("modifier_ability_thdots_keineEx_talent3","scripts/vscripts/abilities/abilitykeine.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_keineEx_talent3:IsHidden() 		return true end
function modifier_ability_thdots_keineEx_talent3:IsPurgable()		return false end
function modifier_ability_thdots_keineEx_talent3:RemoveOnDeath() 	return false end
function modifier_ability_thdots_keineEx_talent3:IsDebuff()		return false end

--万宝槌光环
modifier_ability_thdots_keineEx_passive_aura = {}
LinkLuaModifier("modifier_ability_thdots_keineEx_passive_aura","scripts/vscripts/abilities/abilitykeine.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_ability_thdots_keineEx_passive_aura:IsPurgable()		return false end
function modifier_ability_thdots_keineEx_passive_aura:RemoveOnDeath() 	return false end
function modifier_ability_thdots_keineEx_passive_aura:IsDebuff()		return false end

function modifier_ability_thdots_keineEx_passive_aura:DeclareFunctions()
	return
	{
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_RESPAWNTIME,
		MODIFIER_PROPERTY_RESPAWNTIME_PERCENTAGE
	}
end

function modifier_ability_thdots_keineEx_passive_aura:GetModifierConstantRespawnTime()
	--正数增加，负数减少
	if not self:GetCaster():HasModifier("modifier_ability_thdots_keineEx_talent3") then
		return self:GetAbility():GetSpecialValueFor("keine_time")
	else
		return 0
	end
end

function modifier_ability_thdots_keineEx_passive_aura:GetModifierPercentageRespawnTime()
	--百分比复活时间， 正数减少，负数增加。0.5表示减少50%复活时间
	if self:GetCaster():HasModifier("modifier_ability_thdots_keineEx_talent3") then
		return self:GetAbility():GetSpecialValueFor("percent_time") / 100
	else
		return 0
	end
end

--------------------------------------------------------
--产灵「初始的历史鸿流」
--------------------------------------------------------

ability_thdots_keine01 = {}

function ability_thdots_keine01:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("cast_range")
end

function ability_thdots_keine01:OnSpellStart()
	if not IsServer() then return end
	local caster 				= self:GetCaster()
	local target 				= self:GetCursorTarget()
	local duration  			= self:GetSpecialValueFor("duration")
	if is_spell_blocked(target,caster) then return end
	
	if target:IsHero() or target:GetUnitName() == "ability_minamitsu_04_ship" then --若是英雄则记录生命值 --以及村纱水蜜的船
		if caster:HasModifier("modifier_ability_thdots_keine04") then --狂月状态
			target:AddNewModifier(caster, self, "modifier_ability_thdots_keine01_sawa",{duration = duration})
		else --慧音状态
			target:AddNewModifier(caster, self, "modifier_ability_thdots_keine01",{duration = duration})
		end
	else--杀死普通单位
		target:AddNewModifier(caster, self, "modifier_ability_thdots_keine01_kill",{duration = duration})
	end

	--
	self:GetCaster():EmitSound("Hero_Oracle.FalsePromise.Cast")
	target:EmitSound("Hero_Oracle.FalsePromise.Target")
	--particle
	self.particle_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_false_promise_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(self.particle_cast, 2, self:GetCaster():GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(self.particle_cast)
	
	self.particle_target = ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_false_promise_cast_enemy.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:ReleaseParticleIndex(self.particle_target)
end

modifier_ability_thdots_keine01 = {}
LinkLuaModifier("modifier_ability_thdots_keine01","scripts/vscripts/abilities/abilitykeine.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_keine01:IsHidden() 		return false end
function modifier_ability_thdots_keine01:IsPurgable()		return true end
function modifier_ability_thdots_keine01:RemoveOnDeath() 	return true end

function modifier_ability_thdots_keine01:IsDebuff()
	if self:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber() then
		return false
	else
		return true
	end
end

modifier_ability_thdots_keine01_sawa = {}
LinkLuaModifier("modifier_ability_thdots_keine01_sawa","scripts/vscripts/abilities/abilitykeine.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_keine01_sawa:IsHidden() 		return false end
function modifier_ability_thdots_keine01_sawa:IsPurgable()		return true end
function modifier_ability_thdots_keine01_sawa:RemoveOnDeath() 	return true end

function modifier_ability_thdots_keine01_sawa:IsDebuff()
	if self:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber() then
		return false
	else
		return true
	end
end

function modifier_ability_thdots_keine01:GetEffectName()
	return "particles/units/heroes/hero_oracle/oracle_false_promise.vpcf"
end

function modifier_ability_thdots_keine01:OnCreated()
	if not IsServer() then return end
	self.unit = self:GetParent()
	self.health = self.unit:GetHealthPercent()
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_MAGICAL_BLOCK, self:GetParent(), self.health, nil)
end

function modifier_ability_thdots_keine01:OnDestroy()
	if not IsServer() then return end
	if self:GetParent():IsAlive() then
		print("do it ")
		print(self:GetRemainingTime())
		if self:GetRemainingTime() < 0 then --被驱散就不生效
			if self:GetParent():GetHealthPercent() <= self.health then --特效
				self.end_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_false_promise_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
				ParticleManager:ReleaseParticleIndex(self.end_particle)
				self:GetParent():EmitSound("Hero_Oracle.FalsePromise.Healed")
			else
				self.end_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_false_promise_dmg.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
				ParticleManager:ReleaseParticleIndex(self.end_particle)
				self:GetParent():EmitSound("Hero_Oracle.FalsePromise.Damaged")
			end
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_MAGICAL_BLOCK, self:GetParent(), self.health, nil)

			if self.health <= 0 then
				self.unit:SetHealth(1)
			else
				self.unit:SetHealth(self.unit:GetMaxHealth() * self.health / 100)
			end
		end
	end
end
----------------------------------

function modifier_ability_thdots_keine01_sawa:GetEffectName()
	return "particles/units/heroes/hero_oracle/oracle_false_promise.vpcf"
end

function modifier_ability_thdots_keine01_sawa:OnCreated()
	if not IsServer() then return end
	self.unit = self:GetParent()
	self.health = self.unit:GetHealthPercent()
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_MAGICAL_BLOCK, self:GetParent(), self.health, nil)
end

function modifier_ability_thdots_keine01_sawa:OnDestroy()
	if not IsServer() then return end
	if self:GetParent():IsAlive() then
		local total_health = self:GetParent():GetHealthPercent()
		if self:GetRemainingTime() < 0 then --被驱散就不生效
			if total_health >= self.health then --特效
				self.end_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_false_promise_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
				ParticleManager:ReleaseParticleIndex(self.end_particle)
				self:GetParent():EmitSound("Hero_Oracle.FalsePromise.Healed")
			else
				self.end_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_false_promise_dmg.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
				ParticleManager:ReleaseParticleIndex(self.end_particle)
				self:GetParent():EmitSound("Hero_Oracle.FalsePromise.Damaged")
			end
			local change_health = ( total_health - self.health ) * self:GetAbility():GetSpecialValueFor("extra")/100
			change_health = ( total_health + change_health ) / 100
			print(change_health)
			if change_health > 0 then
				self.unit:SetHealth(self.unit:GetMaxHealth() * change_health)
			else
				self.unit:Kill(self:GetAbility(),self:GetCaster())
			end
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_MAGICAL_BLOCK, self:GetParent(), change_health, nil)
		end
	end
end


modifier_ability_thdots_keine01_kill = {}
LinkLuaModifier("modifier_ability_thdots_keine01_kill","scripts/vscripts/abilities/abilitykeine.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_keine01_kill:IsHidden() 		return false end
function modifier_ability_thdots_keine01_kill:IsPurgable()		return true end
function modifier_ability_thdots_keine01_kill:RemoveOnDeath() 	return true end
function modifier_ability_thdots_keine01_kill:IsDebuff()		return true end

function modifier_ability_thdots_keine01_kill:GetEffectName()
	return "particles/econ/items/oracle/oracle_ti10_immortal/oracle_ti10_immortal_purifyingflames.vpcf"
end
function modifier_ability_thdots_keine01_kill:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end

function modifier_ability_thdots_keine01_kill:OnIntervalThink()
	if not IsServer() then return end
	local damage = self:GetParent():GetMaxHealth() * 0.02
	if self:GetParent():GetName() == "npc_dota_roshan" then
		damage = damage * 0.2
	end
	local damage_tabel = {
				victim 			= self:GetParent(),
				damage 			= damage,
				damage_type		= self:GetAbility():GetAbilityDamageType(),
				damage_flags 	= self:GetAbility():GetAbilityTargetFlags(),
				attacker 		= self:GetCaster(),
				ability 		= self:GetAbility()
			}
	UnitDamageTarget(damage_tabel)
end

--------------------------------------------------------
--野符「武烈的危机残虐」
--------------------------------------------------------

ability_thdots_keine02 = {}

function ability_thdots_keine02:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("cast_range")
end

function ability_thdots_keine02:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if is_spell_blocked(target,caster) then return end
	local percent_health = self:GetSpecialValueFor("percent_health")
	local invincible_duration = self:GetSpecialValueFor("invincible_duration")
	local debuff_duration = self:GetSpecialValueFor("debuff_duration")
	local health = caster:GetHealth() * percent_health / 100 --扣除当前生命值的百分比
	caster:SetHealth(caster:GetHealth() - health)
	if caster:GetTeamNumber() ~= target:GetTeamNumber() and FindTelentValue(caster,"special_bonus_unique_keine_4") ~= 0 then --扣除目标当前生命值的百分比
		local target_health = target:GetHealth() * percent_health / 100
		target:SetHealth(target:GetHealth() - target_health)
	end

	caster:AddNewModifier(caster, self, "modifier_ability_thdots_keine02_invincible",{duration = invincible_duration})
	if target:GetTeamNumber() == caster:GetTeamNumber() then
		target:AddNewModifier(caster, self, "modifier_ability_thdots_keine02_invincible",{duration = invincible_duration})
	else
		target:AddNewModifier(caster, self, "modifier_ability_thdots_keine02_debuff",{duration = debuff_duration})
	end
	--sound
	caster:EmitSound("Hero_Oracle.FatesEdict.Cast")
	target:EmitSound("Hero_Oracle.FatesEdict")
	--particle
	self.hit_particle		= "particles/units/heroes/hero_oracle/oracle_purifyingflames_hit.vpcf"

	local keine2_caster = ParticleManager:CreateParticle(self.hit_particle, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(keine2_caster, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(keine2_caster)
	local purifying_cast_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_purifyingflames_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(purifying_cast_particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(purifying_cast_particle)

	if caster ~= target then
		local keine2_target = ParticleManager:CreateParticle(self.hit_particle, PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(keine2_target, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(keine2_target)
	end
	
end

modifier_ability_thdots_keine02_invincible = {}
LinkLuaModifier("modifier_ability_thdots_keine02_invincible","scripts/vscripts/abilities/abilitykeine.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_keine02_invincible:IsHidden() 		return false end
function modifier_ability_thdots_keine02_invincible:IsPurgable()		return false end
function modifier_ability_thdots_keine02_invincible:RemoveOnDeath() 	return true end
function modifier_ability_thdots_keine02_invincible:IsDebuff()		return false end

modifier_ability_thdots_keine02_debuff = {}
LinkLuaModifier("modifier_ability_thdots_keine02_debuff","scripts/vscripts/abilities/abilitykeine.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_keine02_debuff:IsHidden() 		return false end
function modifier_ability_thdots_keine02_debuff:IsPurgable()		return true end
function modifier_ability_thdots_keine02_debuff:RemoveOnDeath() 	return true end
function modifier_ability_thdots_keine02_debuff:IsDebuff()		return true end

function modifier_ability_thdots_keine02_invincible:GetEffectName() --无敌
	return "particles/thd2/items/item_tsundere.vpcf"
end

function modifier_ability_thdots_keine02_invincible:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
end

function modifier_ability_thdots_keine02_invincible:GetModifierIncomingDamage_Percentage()
	return -999
end

function modifier_ability_thdots_keine02_invincible:CheckState()
	return {
		-- [MODIFIER_STATE_INVULNERABLE] = true,
		-- [MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_STUNNED] = false,
	}
end

function modifier_ability_thdots_keine02_debuff:GetEffectName() --沉默缴械
	return "particles/units/heroes/hero_oracle/oracle_fatesedict.vpcf"
end

function modifier_ability_thdots_keine02_debuff:CheckState()
	return {
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_DISARMED] = true,
	}
end

--------------------------------------------------------
--产灵「最初的金字塔」
--------------------------------------------------------
ability_thdots_keine03 = {}

function ability_thdots_keine03:GetIntrinsicModifierName()
	return "modifier_ability_thdots_keine03_passive"
end

modifier_ability_thdots_keine03_passive = {}
LinkLuaModifier("modifier_ability_thdots_keine03_passive","scripts/vscripts/abilities/abilitykeine.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_keine03_passive:IsHidden() 		return false end
function modifier_ability_thdots_keine03_passive:IsPurgable()		return false end
function modifier_ability_thdots_keine03_passive:RemoveOnDeath() 	return false end
function modifier_ability_thdots_keine03_passive:IsDebuff()		return false end

function modifier_ability_thdots_keine03_passive:OnCreated()
	if not IsServer() then return end
end

function modifier_ability_thdots_keine03_passive:DeclareFunctions()
	return
	{
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_ability_thdots_keine03_passive:OnAttackStart(keys)
	if not IsServer() then return end
	if keys.attacker == self:GetParent() then
		self.change = self:GetAbility():GetSpecialValueFor("change") + FindTelentValue(self:GetParent(),"special_bonus_unique_keine_1")
		print(self.change)
		if RollPercentage(self.change) and not keys.attacker:HasModifier("modifier_ability_thdots_keine03_disable") then
			self.success = false
			local speed = 170
			self.success = true
			self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_3,self:GetParent():GetDisplayAttackSpeed()/speed)
		end
	end
end

function modifier_ability_thdots_keine03_passive:OnAttackLanded(keys)
	if not IsServer() then return end
	local caster = self:GetParent()
	local target = keys.target
	if not (keys.attacker == self:GetParent()) then return end
	if target:IsBuilding() or target:IsOther() or keys.target:GetTeamNumber() == keys.attacker:GetTeamNumber() then
		return end
	if self.success and not caster:HasModifier("modifier_ability_thdots_keine03_disable") then
		self.success = false
		self.damage = self:GetAbility():GetSpecialValueFor("damage")
		self.attack_bonus = self:GetAbility():GetSpecialValueFor("attack_bonus")
		self.pass_stun = self:GetAbility():GetSpecialValueFor("pass_stun")
		print(self.pass_stun)
		-- caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_3)
		
		target:EmitSound("Hero_FacelessVoid.TimeLockImpact")
		UtilStun:UnitStunTarget(caster,target,self.pass_stun)
		local damage = self.damage
		damage = damage + caster:GetAverageTrueAttackDamage(caster) * self.attack_bonus
		local damage_tabel = {
					victim 			= target,
					damage 			= damage,
					damage_type		= self:GetAbility():GetAbilityDamageType(),
					damage_flags 	= self:GetAbility():GetAbilityTargetFlags(),
					attacker 		= caster,
					ability 		= self:GetAbility()
				}
		UnitDamageTarget(damage_tabel)
	end
end

function ability_thdots_keine03:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("cast_range")
end

function ability_thdots_keine03:GetCastPoint()
	if not self:GetCaster():HasModifier("modifier_ability_thdots_keine04") then
		return self.BaseClass.GetCastPoint(self)
	else
		return 0
	end
end

function ability_thdots_keine03:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if is_spell_blocked(target,caster) then return end
	local damage = self:GetSpecialValueFor("damage")
	local attack_bonus = self:GetSpecialValueFor("attack_bonus")
	local act_stun = self:GetSpecialValueFor("act_stun")
	local disable_time = self:GetSpecialValueFor("disable_time")
	local start_point = caster:GetOrigin()
	local forward = (target:GetOrigin() - caster:GetOrigin()):Normalized()
	local point = target:GetOrigin() - forward * 100
	FindClearSpaceForUnit(caster, point, true)

	caster:AddNewModifier(caster, self, "modifier_ability_thdots_keine03_disable",{duration = disable_time})

	--特效音效
	if caster:HasModifier("modifier_ability_thdots_keine04") then
		caster:EmitSound("Hero_FacelessVoid.TimeWalk.Aeons")
	else
		caster:EmitSound("Hero_FacelessVoid.TimeWalk")
	end
	target:EmitSound("Hero_FacelessVoid.TimeLockImpact")
	local distance = ( target:GetOrigin() - caster:GetOrigin() ):Length2D()
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_time_walk_preimage.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, start_point)
	ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin() + forward * distance)
	ParticleManager:SetParticleControlEnt(particle, 2, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetForwardVector(), true)
	ParticleManager:ReleaseParticleIndex(particle)

	local aoe_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_time_walk_slow.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(aoe_pfx, 1, Vector(300,300,300))
	ParticleManager:ReleaseParticleIndex(aoe_pfx)

	UtilStun:UnitStunTarget(caster,target,act_stun)
	damage = damage + caster:GetAverageTrueAttackDamage(caster) * attack_bonus
	local damage_tabel = {
				victim 			= target,
				damage 			= damage,
				damage_type		= self:GetAbilityDamageType(),
				damage_flags 	= self:GetAbilityTargetFlags(),
				attacker 		= caster,
				ability 		= self
			}
	UnitDamageTarget(damage_tabel)

	target:SetContextThink("keine03_kill",
			function ()
				if not target:IsAlive() then
					self:EndCooldown()
					if FindTelentValue(caster,"special_bonus_unique_keine_1") ~= 0 then
						-- caster:SetMana(caster:GetMana() + self:GetManaCost(self:GetLevel() - 1)) --感觉这个返回魔法值的天赋没啥用
					end
				end
			end,
		FrameTime())
end

modifier_ability_thdots_keine03_disable = {}
LinkLuaModifier("modifier_ability_thdots_keine03_disable","scripts/vscripts/abilities/abilitykeine.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_keine03_disable:IsHidden() 		return false end
function modifier_ability_thdots_keine03_disable:IsPurgable()		return false end
function modifier_ability_thdots_keine03_disable:RemoveOnDeath() 	return false end
function modifier_ability_thdots_keine03_disable:IsDebuff()		return false end

--------------------------------------------------------
--满月「未来的创造狂月」
--------------------------------------------------------

ability_thdots_keine04 = {}

function ability_thdots_keine04:OnSpellStart()
	if not IsServer() then return end
	local caster 				= self:GetCaster()
	local duration  			= self:GetSpecialValueFor("duration")
	caster:AddNewModifier(caster, self, "modifier_ability_thdots_keine04", {duration = duration})

	for i=0,15 do 
		if caster:GetAbilityByIndex(i) ~= nil then
			if caster:GetAbilityByIndex(i) ~= self then
				caster:GetAbilityByIndex(i):EndCooldown()
			end
		end
	end
	caster:EmitSound("Voice_Thdots_Keine.AbilityKeine04")
	--particle
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lycan/lycan_shapeshift_cast.vpcf",PATTACH_ROOTBONE_FOLLOW,caster)
	ParticleManager:ReleaseParticleIndex(particle)
end


modifier_ability_thdots_keine04 = {}
LinkLuaModifier("modifier_ability_thdots_keine04","scripts/vscripts/abilities/abilitykeine.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_keine04:IsHidden() 		return false end
function modifier_ability_thdots_keine04:IsPurgable()		return false end
function modifier_ability_thdots_keine04:RemoveOnDeath() 	return true end
function modifier_ability_thdots_keine04:IsDebuff()		return false end

function modifier_ability_thdots_keine04:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
	}
end

function modifier_ability_thdots_keine04:GetModifierBonusStats_Strength()
	if self:GetParent():HasModifier("modifier_ability_thdots_keineEx_talent2") then
		return self:GetAbility():GetSpecialValueFor("str_bonus") * 2
	else
		return self:GetAbility():GetSpecialValueFor("str_bonus")
	end
end

function modifier_ability_thdots_keine04:GetModifierMoveSpeedBonus_Constant()
	if self:GetParent():HasModifier("modifier_ability_thdots_keineEx_talent2") then
		return self:GetAbility():GetSpecialValueFor("movement") * 2
	else
		return self:GetAbility():GetSpecialValueFor("movement")
	end
end

function modifier_ability_thdots_keine04:OnCreated()
	if not IsServer() then return end
	local caster = self:GetParent()
	caster:SetPrimaryAttribute(0)

	if caster:GetName() == "npc_dota_hero_void_spirit" then
		caster:SetModel("models/thd_hero/keine/keine2/keine2.vmdl")
		caster:SetOriginalModel("models/thd_hero/keine/keine2/keine2.vmdl")
	end
end

	function modifier_ability_thdots_keine04:OnDestroy()
	if not IsServer() then return end
	local caster = self:GetParent()
	if caster:GetName() == "npc_dota_hero_void_spirit" then
		caster:SetModel("models/thd_hero/keine/keine.vmdl")
		caster:SetOriginalModel("models/thd_hero/keine/keine.vmdl")
	end
	self:GetParent():SetPrimaryAttribute(2)
end
