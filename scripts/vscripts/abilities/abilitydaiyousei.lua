--------------------------------------------------------
--「妖精的节奏」
--------------------------------------------------------
ability_thdots_daiyouseiEx = {}

function ability_thdots_daiyouseiEx:GetIntrinsicModifierName()
	return "modifier_ability_thdots_daiyouseiEx_passive"
end

modifier_ability_thdots_daiyouseiEx_passive = {}
LinkLuaModifier("modifier_ability_thdots_daiyouseiEx_passive","scripts/vscripts/abilities/abilitydaiyousei.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_daiyouseiEx_passive:IsHidden() 		return false end
function modifier_ability_thdots_daiyouseiEx_passive:IsPurgable()		return false end
function modifier_ability_thdots_daiyouseiEx_passive:RemoveOnDeath() 	return false end
function modifier_ability_thdots_daiyouseiEx_passive:IsDebuff()		return false end

function modifier_ability_thdots_daiyouseiEx_passive:DeclareFunctions()
	return
	{
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_BONUS_DAY_VISION,
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
	}
end
function modifier_ability_thdots_daiyouseiEx_passive:GetBonusDayVision()
	if self:GetParent():HasModifier("modifier_ability_thdots_daiyouseiEx_talent4") then
		return self:GetAbility():GetSpecialValueFor("vision_bonus")
	else
		return 0
	end
end
function modifier_ability_thdots_daiyouseiEx_passive:GetBonusNightVision()
	if self:GetParent():HasModifier("modifier_ability_thdots_daiyouseiEx_talent4") then
		return self:GetAbility():GetSpecialValueFor("vision_bonus")
	else
		return 0
	end
end
function modifier_ability_thdots_daiyouseiEx_passive:OnAbilityFullyCast(keys)
	if not IsServer() then return end
	if keys.unit:GetTeam() == self:GetParent():GetTeam() and keys.unit:IsRealHero() then
		self:SetStackCount(1)
	end
end

function modifier_ability_thdots_daiyouseiEx_passive:OnAttackLanded(keys)
	if not IsServer() then return end
	if keys.attacker == self:GetParent() and self:GetStackCount() == 1 then
		print("attack")
		self:SetStackCount(0)
		local damage = keys.attacker:GetAverageTrueAttackDamage(keys.attacker) - keys.target:GetAverageTrueAttackDamage(keys.target)
		local damage_tabel = {
					victim 			= keys.target,
					-- Damage starts ramping from when cast time starts, so just gonna simiulate the effects by adding the cast point
					damage 			= damage,
					damage_type		= self:GetAbility():GetAbilityDamageType(),
					damage_flags 	= self:GetAbility():GetAbilityTargetFlags(),
					attacker 		= keys.attacker,
					ability 		= self:GetAbility()
				}
		if damage > 0 then --攻击力小于则不造成伤害
			UnitDamageTarget(damage_tabel)
		end
	end
end

function modifier_ability_thdots_daiyouseiEx_passive:OnCreated()
	if not IsServer() then return end
	self.time = 0.1
	self:StartIntervalThink(self.time)
end
function modifier_ability_thdots_daiyouseiEx_passive:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetParent()
	local radius = self:GetAbility():GetSpecialValueFor("radius")
	local view = caster:GetCurrentVisionRange()
	local trees = GridNav:GetAllTreesAroundPoint(caster:GetOrigin(), view, false)
	for _,tree in pairs(trees) do
		AddFOWViewer(caster:GetTeamNumber(), tree:GetOrigin(), radius,self.time + FrameTime(), false)
	end
	--天赋监听
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_daiyousei_3") ~= 0 and not self:GetCaster():HasModifier("modifier_ability_thdots_daiyouseiEx_talent3") then
		self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_daiyouseiEx_talent3",{})
	end
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_daiyousei_4") ~= 0 and not self:GetCaster():HasModifier("modifier_ability_thdots_daiyouseiEx_talent4") then
		self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_daiyouseiEx_talent4",{})
	end
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_daiyousei_5") ~= 0 and not self:GetCaster():HasModifier("modifier_ability_thdots_daiyouseiEx_talent5") then
		self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_daiyouseiEx_talent5",{})
	end
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_daiyousei_6") ~= 0 and not self:GetCaster():HasModifier("modifier_ability_thdots_daiyouseiEx_talent6") then
		self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_daiyouseiEx_talent6",{})
	end
end

modifier_ability_thdots_daiyouseiEx_attack = {}
LinkLuaModifier("modifier_ability_thdots_daiyouseiEx_attack","scripts/vscripts/abilities/abilitydaiyousei.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_daiyouseiEx_attack:IsHidden() 		return false end
function modifier_ability_thdots_daiyouseiEx_attack:IsPurgable()		return false end
function modifier_ability_thdots_daiyouseiEx_attack:RemoveOnDeath() 	return true end
function modifier_ability_thdots_daiyouseiEx_attack:IsDebuff()		return false end

function modifier_ability_thdots_daiyouseiEx_attack:OnCreated()
	if not IsServer() then return end
	self.caster 						= self:GetParent()
	self.attackspeed_bonus 				= self:GetAbility():GetSpecialValueFor("attackspeed_bonus")
end

modifier_ability_thdots_daiyouseiEx_talent3 = modifier_ability_thdots_daiyouseiEx_talent3 or {}  --天赋监听
LinkLuaModifier("modifier_ability_thdots_daiyouseiEx_talent3","scripts/vscripts/abilities/abilitydaiyousei.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_daiyouseiEx_talent3:IsHidden() 		return true end
function modifier_ability_thdots_daiyouseiEx_talent3:IsPurgable()		return false end
function modifier_ability_thdots_daiyouseiEx_talent3:RemoveOnDeath() 	return false end
function modifier_ability_thdots_daiyouseiEx_talent3:IsDebuff()		return false end

modifier_ability_thdots_daiyouseiEx_talent4 = modifier_ability_thdots_daiyouseiEx_talent4 or {}  --天赋监听
LinkLuaModifier("modifier_ability_thdots_daiyouseiEx_talent4","scripts/vscripts/abilities/abilitydaiyousei.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_daiyouseiEx_talent4:IsHidden() 		return true end
function modifier_ability_thdots_daiyouseiEx_talent4:IsPurgable()		return false end
function modifier_ability_thdots_daiyouseiEx_talent4:RemoveOnDeath() 	return false end
function modifier_ability_thdots_daiyouseiEx_talent4:IsDebuff()		return false end

modifier_ability_thdots_daiyouseiEx_talent5 = modifier_ability_thdots_daiyouseiEx_talent5 or {}  --天赋监听
LinkLuaModifier("modifier_ability_thdots_daiyouseiEx_talent5","scripts/vscripts/abilities/abilitydaiyousei.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_daiyouseiEx_talent5:IsHidden() 		return true end
function modifier_ability_thdots_daiyouseiEx_talent5:IsPurgable()		return false end
function modifier_ability_thdots_daiyouseiEx_talent5:RemoveOnDeath() 	return false end
function modifier_ability_thdots_daiyouseiEx_talent5:IsDebuff()		return false end

modifier_ability_thdots_daiyouseiEx_talent6 = modifier_ability_thdots_daiyouseiEx_talent6 or {}  --天赋监听
LinkLuaModifier("modifier_ability_thdots_daiyouseiEx_talent6","scripts/vscripts/abilities/abilitydaiyousei.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_daiyouseiEx_talent6:IsHidden() 		return true end
function modifier_ability_thdots_daiyouseiEx_talent6:IsPurgable()		return false end
function modifier_ability_thdots_daiyouseiEx_talent6:RemoveOnDeath() 	return false end
function modifier_ability_thdots_daiyouseiEx_talent6:IsDebuff()		return false end

--------------------------------------------------------
--「妖精之力」
--------------------------------------------------------

ability_thdots_daiyousei01 = {}

function ability_thdots_daiyousei01:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("cast_range")
end

function ability_thdots_daiyousei01:CastFilterResultTarget(target)
	if target == self:GetCaster() then
		return UF_FAIL_CUSTOM
	end
end

function ability_thdots_daiyousei01:OnSpellStart()
	if not IsServer() then return end
	local caster 				= self:GetCaster()
	local target 				= self:GetCursorTarget()
	local heal  				= self:GetSpecialValueFor("heal")
	if target:GetName() ~= "" and is_spell_blocked(target,caster) then return end
	--特效音效
	local blink_start_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_phantom_strike_start.vpcf", PATTACH_ABSORIGIN,caster)
	ParticleManager:ReleaseParticleIndex(blink_start_pfx)
	StartSoundEventFromPosition("Hero_PhantomAssassin.Strike.Start", caster:GetOrigin())
	FindClearSpaceForUnit(caster,target:GetAbsOrigin(),true)
	caster:EmitSound("Hero_PhantomAssassin.Strike.End")
	caster:Heal(heal,caster)
	SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,caster,heal,nil)

	if caster:GetTeam() == target:GetTeam() and target:IsRealHero() then
		target:Heal(heal,caster)
		SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,target,heal,nil)
		THDReduceCooldown(self,-self:GetCooldown(self:GetLevel() - 1) * 0.5)
	end

	--暴击参数
	local item = nil
	self.crit_mult = 100
	local item_anchor_crit_chance = 0
	local item_anchor_crit_mult = 100
	local item_sampan_crit_chance = 0
	local item_sampan_crit_mult = 100
	for i=0,5 do 
		item = caster:GetItemInSlot(i)
		if item ~= nil and item:GetName() == "item_anchor" then
			item_anchor_crit_chance = item:GetSpecialValueFor("crit_chance_const")
			item_anchor_crit_mult = item:GetSpecialValueFor("crit_mult")
			if caster:GetModifierStackCount("modifier_item_anchor_crit_chance_icon", caster) ~= 0 then
				item_anchor_crit_chance = caster:GetModifierStackCount("modifier_item_anchor_crit_chance_icon", caster)
			end
		end
	end
	for i=0,5 do 
		item = caster:GetItemInSlot(i)
		if item ~= nil and item:GetName() == "item_sampan" then
			item_sampan_crit_chance = item:GetSpecialValueFor("crit_chance")
			item_sampan_crit_mult = item:GetSpecialValueFor("crit_mult")
			break
		end
	end
	if RollPercentage(item_sampan_crit_chance) then
		self.crit_mult = item_sampan_crit_mult
	elseif RollPercentage(item_anchor_crit_chance) then
		self.crit_mult = item_anchor_crit_mult
	end

	if caster:GetTeam() ~= target:GetTeam() then
		--假攻击，附带法球
		caster:PerformAttack(target, true, true, true, true, true, true, false)
	
		-- 修改为一次普攻,附带暴击
		local damage = caster:GetAverageTrueAttackDamage(caster)
		local damage_tabel = {
					victim 			= target,
					damage 			= damage,
					damage_type		= DAMAGE_TYPE_PHYSICAL,
					damage_flags 	= self:GetAbilityTargetFlags(),
					attacker 		= caster,
					ability 		= self
				}
		if self.crit_mult ~= 100 then
			damage = damage * self.crit_mult / 100
			SendOverheadEventMessage(nil,OVERHEAD_ALERT_CRITICAL,target,damage,nil)
		end
		print(self.crit_mult)
		UnitDamageTarget(damage_tabel)
	end
end

--------------------------------------------------------
--「妖精之力」
--------------------------------------------------------

ability_thdots_daiyousei02 = {}

function ability_thdots_daiyousei02:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("radius")
end

function ability_thdots_daiyousei02:OnSpellStart()
	if not IsServer() then return end
	local caster 				= self:GetCaster()
	local radius  				= self:GetSpecialValueFor("radius")

	if caster:GetName() == "npc_dota_hero_nyx_assassin" then
		caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2,6)
		caster:SetContextThink("dayousei01", function()
			caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_2)
		end,0.41)
	end
	caster:EmitSound("Hero_NagaSiren.Ensnare.Cast")
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(),nil,radius,self:GetAbilityTargetTeam(),
		self:GetAbilityTargetType(),0,0,false)
	DeleteDummy(targets)
	for _,v in pairs(targets) do
		local info = {
			Source = self:GetCaster(),
			Target = v,
			Ability = self,
			bDodgeable = true,
			-- EffectName = "particles/items5_fx/clumsy_net_proj.vpcf",
			-- EffectName = "particles/units/heroes/hero_troll_warlord/troll_warlord_bersekers_net_projectile.vpcf",
			EffectName = "particles/units/heroes/hero_siren/siren_net_projectile.vpcf",
			iMoveSpeed = 1200--self:GetSpecialValueFor("projectile_speed"),
		}
		ProjectileManager:CreateTrackingProjectile(info)
	end
end

function ability_thdots_daiyousei02:OnProjectileHit(hTarget, vLocation)
	if not hTarget then return end
	local caster = self:GetCaster()
	local damage  				= self:GetSpecialValueFor("damage") + FindTelentValue(caster,"special_bonus_unique_daiyousei_2")
	local attack_bonus  		= self:GetSpecialValueFor("attack_bonus")
	local duration  			= self:GetSpecialValueFor("duration")
	local ability = self
	local modifier_spawn = "modifier_ability_thdots_daiyousei02_rooted"
	damage = damage + caster:GetAverageTrueAttackDamage(caster) * attack_bonus
	print("02damage is",damage)

	hTarget:AddNewModifier(caster, self, modifier_spawn, {duration = duration})
	local damage_tabel = {
				victim 			= hTarget,
				damage 			= damage,
				damage_type		= self:GetAbilityDamageType(),
				damage_flags 	= self:GetAbilityTargetFlags(),
				attacker 		= caster,
				ability 		= self
			}
	UnitDamageTarget(damage_tabel)
	hTarget:EmitSound("Hero_NagaSiren.Ensnare.Target")
end

modifier_ability_thdots_daiyousei02_rooted = {}
LinkLuaModifier("modifier_ability_thdots_daiyousei02_rooted","scripts/vscripts/abilities/abilitydaiyousei.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_ability_thdots_daiyousei02_rooted:IsHidden() 		return false end
function modifier_ability_thdots_daiyousei02_rooted:IsPurgable()		return true end
function modifier_ability_thdots_daiyousei02_rooted:RemoveOnDeath() 	return true end
function modifier_ability_thdots_daiyousei02_rooted:IsDebuff()		return true end

function modifier_ability_thdots_daiyousei02_rooted:GetEffectName()
	return "particles/units/heroes/hero_siren/siren_net.vpcf"
end
function modifier_ability_thdots_daiyousei02_rooted:CheckState() --缠绕
	return {
		[MODIFIER_STATE_ROOTED] = true,
	}
end

--------------------------------------------------------
--「妖精守护」
--------------------------------------------------------
ability_thdots_daiyousei03 = {}

function ability_thdots_daiyousei03:GetCooldown(level)
	if self:GetCaster():HasModifier("modifier_ability_thdots_daiyouseiEx_talent6") then
		return self.BaseClass.GetCooldown(self, level) - 7
	else
		return self.BaseClass.GetCooldown(self, level)
	end
end

function ability_thdots_daiyousei03:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasModifier("modifier_ability_thdots_daiyouseiEx_talent3") then
		return 0
	else
		return self:GetSpecialValueFor("cast_range")
	end
end

function ability_thdots_daiyousei03:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local duration = self:GetSpecialValueFor("duration")
	--特效音效
	caster:EmitSound("Item.LotusOrb.Activate")
	target:EmitSound("Item.LotusOrb.Target")
	target:AddNewModifier(caster, self, "modifier_ability_thdots_daiyousei03", {duration = duration})
	if FindTelentValue(caster,"special_bonus_unique_daiyousei_1") ~= 0 then
		target:Purge(false,true,false,true,false)
	end
end

modifier_ability_thdots_daiyousei03 = {}
LinkLuaModifier("modifier_ability_thdots_daiyousei03","scripts/vscripts/abilities/abilitydaiyousei.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_ability_thdots_daiyousei03:GetEffectName()
	return "particles/items3_fx/lotus_orb_shield.vpcf"
end

function modifier_ability_thdots_daiyousei03:GetEffectAttachType()
	return PATTACH_CUSTOMORIGIN_FOLLOW
end

function modifier_ability_thdots_daiyousei03:IsHidden() 		return false end
function modifier_ability_thdots_daiyousei03:IsPurgable()		return true end
function modifier_ability_thdots_daiyousei03:RemoveOnDeath() 	return true end
function modifier_ability_thdots_daiyousei03:IsDebuff()		return false end

function modifier_ability_thdots_daiyousei03:DeclareFunctions()	
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
end

function modifier_ability_thdots_daiyousei03:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("armor_bonus")
end

function modifier_ability_thdots_daiyousei03:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("damage_bonus")
end

--------------------------------------------------------
--「高级妖精」
--------------------------------------------------------
ability_thdots_daiyousei04 = {}

function ability_thdots_daiyousei04:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("radius")
end

function ability_thdots_daiyousei04:GetCooldown(level)
	if self:GetCaster():HasModifier("modifier_ability_thdots_daiyouseiEx_talent5") then
		return self.BaseClass.GetCooldown(self, level) - 50
	else
		return self.BaseClass.GetCooldown(self, level)
	end
end

function ability_thdots_daiyousei04:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local radius = self:GetSpecialValueFor("radius")
	local duration = self:GetSpecialValueFor("duration")


	if caster:GetName() == "npc_dota_hero_nyx_assassin" then
		caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2,6)
		caster:SetContextThink("dayousei04", function()
			caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_2)
		end,0.41)
	end
	-- caster:EmitSound("Hero_PhantomAssassin.Blur")
	caster:EmitSound("Hero_Slark.ShadowDance")
	caster:EmitSound("Hero_Puck.Attack")
	caster:AddNewModifier(caster, self, "modifier_ability_thdots_daiyousei04_invis", {duration = duration})
	caster:AddNewModifier(caster, self, "modifier_invisible", {duration = duration})
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(),nil,radius,self:GetAbilityTargetTeam(),
		self:GetAbilityTargetType(),0,0,false)
	DeleteDummy(targets)
	for _,v in pairs(targets) do
		local info = {
			Source = self:GetCaster(),
			Target = v,
			Ability = self,
			bDodgeable = true,
			EffectName = "particles/units/heroes/hero_puck/puck_base_attack.vpcf",
			-- EffectName = "particles/units/heroes/hero_troll_warlord/troll_warlord_bersekers_net_projectile.vpcf",
			-- EffectName = "particles/units/heroes/hero_siren/siren_net_projectile.vpcf",
			iMoveSpeed = 1200--self:GetSpecialValueFor("projectile_speed"),
		}
		ProjectileManager:CreateTrackingProjectile(info)
	end


	--暴击参数
	local item = nil
	self.crit_mult = 100
	local item_anchor_crit_chance = 0
	local item_anchor_crit_mult = 100
	local item_sampan_crit_chance = 0
	local item_sampan_crit_mult = 100
	for i=0,5 do 
		item = caster:GetItemInSlot(i)
		if item ~= nil and item:GetName() == "item_anchor" then
			item_anchor_crit_chance = item:GetSpecialValueFor("crit_chance_const")
			item_anchor_crit_mult = item:GetSpecialValueFor("crit_mult")
			if caster:GetModifierStackCount("modifier_item_anchor_crit_chance_icon", caster) ~= 0 then
				item_anchor_crit_chance = caster:GetModifierStackCount("modifier_item_anchor_crit_chance_icon", caster)
			end
		end
	end
	for i=0,5 do 
		item = caster:GetItemInSlot(i)
		if item ~= nil and item:GetName() == "item_sampan" then
			item_sampan_crit_chance = item:GetSpecialValueFor("crit_chance")
			item_sampan_crit_mult = item:GetSpecialValueFor("crit_mult")
			break
		end
	end
	if RollPercentage(item_sampan_crit_chance) then
		self.crit_mult = item_sampan_crit_mult
	elseif RollPercentage(item_anchor_crit_chance) then
		self.crit_mult = item_anchor_crit_mult
	end
end

modifier_thdots_daiyousei04_thinker = class({})

function modifier_thdots_daiyousei04_thinker:OnCreated()
	if IsServer() then
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_thdots_daiyousei04_thinker:OnIntervalThink()
	if not IsServer() then return end
end



function ability_thdots_daiyousei04:OnProjectileHit(hTarget, vLocation)
	if not hTarget then return end
	local caster = self:GetCaster()
	local damage  				= self:GetSpecialValueFor("damage")
	local attack_bonus  		= self:GetSpecialValueFor("attack_bonus")
	local duration  			= self:GetSpecialValueFor("duration")
	local ability = self

	hTarget:EmitSound("Hero_Puck.ProjectileImpact")
	
	--假攻击，附带法球
	caster:PerformAttack(hTarget, true, true, true, true, true, true, false)

	-- 修改为一次普攻,附带暴击
	damage = damage + caster:GetAverageTrueAttackDamage(caster) * attack_bonus
	local damage_tabel = {
				victim 			= hTarget,
				damage 			= damage,
				damage_type		= self:GetAbilityDamageType(),
				damage_flags 	= self:GetAbilityTargetFlags(),
				attacker 		= caster,
				ability 		= self
			}
	if self.crit_mult ~= 100 then
		damage = damage * self.crit_mult / 100
		SendOverheadEventMessage(nil,OVERHEAD_ALERT_CRITICAL,hTarget,damage,nil)
	end
	print(self.crit_mult)
	UnitDamageTarget(damage_tabel)

	hTarget:EmitSound("Hero_NagaSiren.Ensnare.Target")
	if caster:HasModifier("modifier_ability_thdots_daiyouseiEx_passive") then
		caster:SetModifierStackCount("modifier_ability_thdots_daiyouseiEx_passive", caster, 1)
	end
end

modifier_ability_thdots_daiyousei04_invis = {}
LinkLuaModifier("modifier_ability_thdots_daiyousei04_invis","scripts/vscripts/abilities/abilitydaiyousei.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_ability_thdots_daiyousei04_invis:IsDebuff() return false end
function modifier_ability_thdots_daiyousei04_invis:IsHidden() return false end
function modifier_ability_thdots_daiyousei04_invis:IsPurgable() return true end
function modifier_ability_thdots_daiyousei04_invis:RemoveOnDeath() return true end

function modifier_ability_thdots_daiyousei04_invis:GetStatusEffectName()
	return "particles/status_fx/status_effect_slark_shadow_dance.vpcf"
end

function modifier_ability_thdots_daiyousei04_invis:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE]			= true,
		[MODIFIER_STATE_TRUESIGHT_IMMUNE]	= true
	}
end

function modifier_ability_thdots_daiyousei04_invis:OnCreated()
	if not IsServer() then return end
	self.react_time = 0.2
	local caster = self:GetCaster()
	self:StartIntervalThink(FrameTime())
	self.dummy = CreateUnitByName("npc_no_vision_dummy_unit", 
	    	                        caster:GetOrigin(), 
									false, 
								    caster, 
									caster, 
									caster:GetTeamNumber()
									)
	self.dummy:FindAbilityByName("ability_dummy_unit"):SetLevel(1)
	self.shadow_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_shadow_dance.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.dummy)
	ParticleManager:SetParticleControlEnt(self.shadow_particle, 1, self.dummy, PATTACH_POINT_FOLLOW, "attach_hitloc", self.dummy:GetAbsOrigin(), true)
end

function modifier_ability_thdots_daiyousei04_invis:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticleSystem(self.shadow_particle,true)
	self.dummy:RemoveSelf()
end

function modifier_ability_thdots_daiyousei04_invis:OnIntervalThink()
	if not IsServer() then return end
	self.dummy:SetOrigin(self:GetParent():GetOrigin())
	-- if not self:GetParent():HasModifier("modifier_invisible")then
	-- self:GetParent():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_invisible", {duration = self:GetRemainingTime()})
	-- end
end