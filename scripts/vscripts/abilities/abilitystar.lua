function OnStar05SpellStart(keys)
	local caster = keys.caster
	local ability = keys.ability

	local spell_duration = FindValueTHD("duration",ability)
	caster:EmitSound("Hero_Mirana.Starstorm.Cast")
	
	caster:StartGesture(ACT_DOTA_CHANNEL_ABILITY_5)
	
	ability:ApplyDataDrivenModifier(caster,caster,"modifier_thdotsr_star05_think_interval",{duration = spell_duration})

	ability:ApplyDataDrivenModifier(caster,caster,"modifier_thdotsr_star05_think_interval_effect",{duration = spell_duration})end

function OnStar05EffectEnd(keys)

	local caster = keys.caster
	local ability = keys.ability
	
	for _,v in pairs(STAR_UNITS) do
	--	table.remove(STAR_UNITS, v)	
		ParticleManager:DestroyParticleSystem(v.spelleffect,false)
		v:RemoveSelf()
	
	end
	STAR_UNITS = {}
	
	caster:RemoveGesture(ACT_DOTA_CHANNEL_ABILITY_5)
end

function OnStar05SpellEnd(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	if caster:HasModifier("modifier_thdotsr_star05_think_interval") then
		caster:RemoveModifierByName("modifier_thdotsr_star05_think_interval")
		caster:RemoveModifierByName("modifier_thdotsr_star05_think_interval_effect")	
	end
end

function OnStar05SpellThink(keys)

	local caster = keys.caster
	local ability = keys.ability
	
	local intervals = FindValueTHD("intervals",ability)
	local search_radius = FindValueTHD("effect_radius",ability)
	local target_type = DOTA_UNIT_TARGET_CREEP

	if FindTelentValue(caster,"special_bonus_unique_star_4") ~= 0 then
		target_type = DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO
	end
	
	local targets = FindUnitsInRadius(
				   caster:GetTeam(),						--caster team
				   caster:GetAbsOrigin(),							--find position
				   nil,										--find entity
				   search_radius,						--find radius
				   DOTA_UNIT_TARGET_TEAM_ENEMY,
				   target_type,
				   0, --flag
				   FIND_ANY_ORDER,
				   false
			    )
				
	local base_damage = FindValueTHD("base_damage",ability)

	local int_scale = FindValueTHD("int_scale",ability)
	
	local spell_duration = FindValueTHD("duration",ability)
	
	local deal_damage = ((base_damage + caster:GetIntellect()*int_scale)*intervals)/spell_duration
				

	
	for _,v in pairs(targets) do
		if FindTelentValue(caster,"special_bonus_unique_star_4") ~= 0 then
			local heroes = FindUnitsInRadius(caster:GetTeam(),caster:GetOrigin(), nil, search_radius, DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO, 0, 0, false)
			if #heroes > 0 then
				v = heroes[1]
			end
		end
		v:EmitSound("Hero_Mirana.Starstorm.Impact.Layer")
		local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_mirana/mirana_starfall_attack.vpcf", PATTACH_ABSORIGIN_FOLLOW, v)
		ParticleManager:SetParticleControl(effectIndex, 0, v:GetAbsOrigin())
		v:SetContextThink("Star05_Think",
			function()
				if GameRules:IsGamePaused() then return 0.03 end
				if v~= nil and v:IsNull() ~= true then
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
			end,
			0.03)
		break					
	end	
	
	local heal = FindValueTHD("heal",ability)
	local duration = FindValueTHD("duration",ability)
	
	local heal_int_Scale = FindValueTHD("heal_int_Scale",ability)
	
	
	local healing = (heal + caster:GetIntellect()*heal_int_Scale) * intervals / duration
	
	caster:Heal(healing,caster)
	SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,caster,healing,nil)	
end


function OnStar05SpellThinkEffect(keys)

	local caster = keys.caster
	local ability = keys.ability
	local vecCaster = caster:GetOrigin()
	local max_spirit = 8
	
	
--	caster.currentspinangle = caster.currentspinangle + 0.03
	caster.currentspinangle = caster.currentspinangle + 0.06
	-- print(caster:GetForwardVector())
	local spiritnumber = 0
	for _,v in pairs(STAR_UNITS) do
		spiritnumber = spiritnumber+1
		local forwardVector = caster:GetForwardVector()
		local rollRad = (spiritnumber + caster.currentspinangle)*math.pi*2/max_spirit
		local forwardCos = forwardVector.x
		local forwardSin = forwardVector.y
		local summon_range = 600
		local summonVector =  Vector(math.cos(rollRad)*forwardCos - math.sin(rollRad)*forwardSin,
								 forwardSin*math.cos(rollRad) + forwardCos*math.sin(rollRad),
								 0) * summon_range + vecCaster
		v:SetAbsOrigin(summonVector)
		
	--	ParticleManager:SetParticleControl(v.spelleffect, 0, Vector(v:GetAbsOrigin().x,v:GetAbsOrigin().y,v:GetAbsOrigin().z+300))
		
	--	ParticleManager:SetParticleControl(v.spelleffect, 0, v:GetAttachmentOrigin(v:ScriptLookupAttachment("attach_hitloc")))
		local vecpos = GetGroundPosition(v:GetAbsOrigin(),nil)
		ParticleManager:SetParticleControl(v.spelleffect, 0, Vector(vecpos.x,vecpos.y,vecpos.z+300))
		
	--	ParticleManager:SetParticleControl(v.spelleffect2, 0, GetGroundPosition(v:GetAbsOrigin(),nil))
	end

end

function OnStar05EffectCreated(keys)

	local caster = keys.caster
	local ability = keys.ability
	
	local particle_effect = "particles/units/heroes/hero_wisp/wisp_guardian.vpcf"
	
	local casterOrigin	= caster:GetAbsOrigin()
	
	local max_spirit = 8
	
	local vecCaster = caster:GetOrigin()
	
	caster.currentspinangle = 0
	
	STAR_UNITS = {}
	
	for i=1,max_spirit do
		local forwardVector = caster:GetForwardVector()
		local rollRad = i*math.pi*2/max_spirit
		local forwardCos = forwardVector.x
		local forwardSin = forwardVector.y
		local summon_range = 600
		local summonVector =  Vector(math.cos(rollRad)*forwardCos - math.sin(rollRad)*forwardSin,
								 forwardSin*math.cos(rollRad) + forwardCos*math.sin(rollRad),
								 0) * summon_range + vecCaster
		local newSpirit = CreateUnitByName( "npc_dummy_unit", summonVector, false, caster, caster, caster:GetTeam() )
		local effectIndex = ParticleManager:CreateParticle(particle_effect, PATTACH_CUSTOMORIGIN, newSpirit)
		ParticleManager:SetParticleControl(effectIndex, 0, newSpirit:GetAbsOrigin())
		newSpirit.spelleffect = effectIndex

		newSpirit:SetContextThink("dummy_kill",
			function ()
				if GameRules:IsGamePaused() then return 0.03 end
				if newSpirit ~= nil then
					newSpirit:ForceKill(true)
				end
			end, 
			FindValueTHD("duration",ability))
		
	--	local effectIndex2 = ParticleManager:CreateParticle(particle_effect, PATTACH_CUSTOMORIGIN, newSpirit)
	--	ParticleManager:SetParticleControl(effectIndex2, 0, newSpirit:GetAbsOrigin())
	--	newSpirit.spelleffect2 = effectIndex2
		
		newSpirit.StarOwner = caster
		
		table.insert(STAR_UNITS, newSpirit)
		
	--	newSpirit
	--	ParticleManager:SetParticleControl(effectIndex, 0, caster:GetOrigin())
	--	ParticleManager:SetParticleControl(effectIndex, 1, caster:GetOrigin())
	
	--	caster.abilitystar05spirit(i) = newSpirit
	
	end

end

ability_thdotsr_star01 = {}

function ability_thdotsr_star01:GetAOERadius()
	if self:GetCaster():HasModifier("modifier_ability_thdots_star_talent_2") then
		return 300
	else
		return 150
	end
end

function ability_thdotsr_star01:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local ability = self
	local point = self:GetCursorPosition()

	local effectIndex = ParticleManager:CreateParticle("particles/econ/items/mirana/mirana_starstorm_bow/mirana_starstorm_starfall_attack.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, point)

	
	
	local search_radius = FindValueTHD("aoe",ability) + FindTelentValue(caster,"special_bonus_unique_star_2")
	
	local base_damage = FindValueTHD("base_damage",ability)

	local int_scale = FindValueTHD("int_scale",ability)
	
	local deal_damage = (base_damage + caster:GetIntellect()*int_scale)

	local stun_duration = FindValueTHD("stun_duration",ability) + FindTelentValue(caster,"special_bonus_unique_star_1")

	if FindTelentValue(caster,"special_bonus_unique_star_2") ~= 0 and not caster:HasModifier("modifier_ability_thdots_star_talent_2") then
		caster:AddNewModifier(caster, ability, "modifier_ability_thdots_star_talent_2",{})
	end

	EmitSoundOn("Ability.Starfall", caster)
	
	-- ability:ApplyDataDrivenModifier(caster,caster,"modifier_star01_back_swing",{})
	caster:SetContextThink("OnStar01SpellStart",
		function()
			if GameRules:IsGamePaused() then return 0.03 end
			StartSoundEventFromPosition("Ability.StarfallImpact", point)
			local targets = FindUnitsInRadius(
				   caster:GetTeam(),						--caster team
				   point,							--find position
				   nil,										--find entity
				   search_radius,						--find radius
				   DOTA_UNIT_TARGET_TEAM_ENEMY,
				   DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO,
				   0, --flag
				   FIND_ANY_ORDER,
				   false
			    )
			for _,v in pairs(targets) do
				local damage_table = {
					ability = ability,
				    victim = v,
				    attacker = caster,
				    damage = deal_damage,
				    damage_type = ability:GetAbilityDamageType(), 
					damage_flags = 0
				}
				UtilStun:UnitStunTarget(caster,v, stun_duration)
				v:EmitSound("Star01SpellHit")
				UnitDamageTarget(damage_table)
			end
			local dummy = CreateUnitByName("npc_dummy_unit", point, false, caster, caster, caster:GetTeam() )

			-- local particle = ParticleManager:CreateParticle("particles/econ/events/darkmoon_2017/darkmoon_generic_aoe.vpcf", PATTACH_POINT, caster)
  	-- 		ParticleManager:SetParticleControl(particle, 0, point)
  	-- 		ParticleManager:SetParticleControl(particle, 1, Vector(search_radius, 1, 1))
  	-- 		ParticleManager:ReleaseParticleIndex(particle)
			local strike_particle = "particles/units/heroes/hero_disruptor/disruptor_thunder_strike_bolt.vpcf"
			self.strike_particle_fx = ParticleManager:CreateParticle(strike_particle, PATTACH_ABSORIGIN, caster)
			ParticleManager:SetParticleControl(self.strike_particle_fx, 0, dummy:GetAbsOrigin())
			ParticleManager:SetParticleControl(self.strike_particle_fx, 1, dummy:GetAbsOrigin())
			ParticleManager:SetParticleControl(self.strike_particle_fx, 2, dummy:GetAbsOrigin())
			ParticleManager:SetParticleControl(self.strike_particle_fx, 7, Vector(search_radius,0,0))


			dummy:RemoveSelf()
		end,
		0.57)
end

function OnStar01SpellStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	local effectIndex = ParticleManager:CreateParticle("particles/econ/items/mirana/mirana_starstorm_bow/mirana_starstorm_starfall_attack.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, point)
	
	local search_radius = FindValueTHD("aoe",ability) + FindTelentValue(caster,"special_bonus_unique_star_2")
	
	local base_damage = FindValueTHD("base_damage",ability)

	local int_scale = FindValueTHD("int_scale",ability)
	
	local deal_damage = (base_damage + caster:GetIntellect()*int_scale)

	local stun_duration = FindValueTHD("stun_duration",ability) + FindTelentValue(caster,"special_bonus_unique_star_1")

	EmitSoundOn("Ability.Starfall", caster)
	
	-- ability:ApplyDataDrivenModifier(caster,caster,"modifier_star01_back_swing",{})
	caster:SetContextThink("OnStar01SpellStart",
		function()
			if GameRules:IsGamePaused() then return 0.03 end
			StartSoundEventFromPosition("Ability.StarfallImpact", point)
			local targets = FindUnitsInRadius(
				   caster:GetTeam(),						--caster team
				   point,							--find position
				   nil,										--find entity
				   search_radius,						--find radius
				   DOTA_UNIT_TARGET_TEAM_ENEMY,
				   DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO,
				   0, --flag
				   FIND_ANY_ORDER,
				   false
			    )
			for _,v in pairs(targets) do
				local damage_table = {
					ability = keys.ability,
				    victim = v,
				    attacker = caster,
				    damage = deal_damage,
				    damage_type = keys.ability:GetAbilityDamageType(), 
					damage_flags = 0
				}
				UtilStun:UnitStunTarget(caster,v, stun_duration)
				v:EmitSound("Star01SpellHit")
				UnitDamageTarget(damage_table)
			end
		end,
		0.57)
end

function OnStar03SpellStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = caster:GetOrigin()
	local attack_count = ability:GetSpecialValueFor("attack_count")
	local true_sight_range = ability:GetSpecialValueFor("true_sight_range")
	
	local starWard = CreateUnitByName( "ability_star03_ward", point, false, caster, caster, caster:GetTeam() )
	starWard:SetBaseMaxHealth(attack_count)
	local spell_duration = FindValueTHD("duration",ability)
	ability:ApplyDataDrivenModifier(caster,starWard,"modifier_thdotsr_star03_ward",{duration = spell_duration})
	starWard:SetModifierStackCount("modifier_thdotsr_star03_ward", caster, attack_count)
	starWard:AddNewModifier(caster, ability, "modifier_item_ward_true_sight", {duration = spell_duration,true_sight_range = true_sight_range})
	starWard:AddNewModifier(caster, ability, "modifier_kill", {duration = spell_duration})

	-- ParticleManager:SetParticleControl(effectIndex, 61, Vector(1000,1000,1000))
	starWard:SetContextThink("Star03_flash", function ()
		-- body
			if GameRules:IsGamePaused() then return 0.03 end
			if starWard:IsAlive() then
				local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_spirit_form_cast.vpcf",PATTACH_CUSTOMORIGIN_FOLLOW, starWard)
				ParticleManager:SetParticleControlEnt(effectIndex , 0, starWard, 0, "attach_hitloc", Vector(0,0,0), true)
				ParticleManager:ReleaseParticleIndex(effectIndex)
				return 10
			else
				return 0
			end
		end, 
	0.03)
--	starWard:AddNewModifier(caster, ability, "modifier_item_buff_ward", {duration = spell_duration,vision_range = 1000})
	
end

function OnStar03WardTakeDamage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ward = keys.unit
	local count = 0
	print(ward:GetUnitName())
	if ward:HasModifier("modifier_thdotsr_star03_ward") then
		count = ward:GetModifierStackCount("modifier_thdotsr_star03_ward",caster) - 1
		ward:SetModifierStackCount("modifier_thdotsr_star03_ward",caster,count)
		if not ward:HasModifier("modifier_kill") then
			ward:RemoveSelf()
			return
		end
		if count > 0 then
			ward:SetHealth(count)
		else
			ward:ForceKill(true)
		end
	end
end

ability_thdotsr_star02 = class({})

function ability_thdotsr_star02:GetAOERadius()
	if self:GetCaster():HasModifier("modifier_ability_thdots_star_talent_3") then
		return 400
	else
		return 0
	end
end

function ability_thdotsr_star02:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if is_spell_blocked(target) then
		return
	end
	if FindTelentValue(caster,"special_bonus_unique_star_3") ~= 0 and not caster:HasModifier("modifier_ability_thdots_star_talent_3") then
		caster:AddNewModifier(caster, self, "modifier_ability_thdots_star_talent_3",{})
	end
	self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_ability_thdotsr_star02_curse", {duration=self:GetSpecialValueFor("snare_duration")})
	target:EmitSound("DOTA_Item.RodOfAtos.Target")
	if FindTelentValue(caster,"special_bonus_unique_star_3") ~= 0 then
		local targets = FindUnitsInRadius(caster:GetTeam(), target:GetOrigin(), nil, FindTelentValue(caster,"special_bonus_unique_star_3"), 
											self:GetAbilityTargetTeam(),self:GetAbilityTargetType(),0,0,false)
		for _,v in pairs(targets) do 
			if v ~= target then
				v:AddNewModifier(self:GetCaster(), self, "modifier_ability_thdotsr_star02_curse", {duration=self:GetSpecialValueFor("snare_duration")})
				v:EmitSound("DOTA_Item.RodOfAtos.Target")
			end
		end
	end
end

LinkLuaModifier("modifier_ability_thdotsr_star02_curse", "scripts/vscripts/abilities/abilitystar.lua", LUA_MODIFIER_MOTION_NONE)

modifier_ability_thdotsr_star02_curse = modifier_ability_thdotsr_star02_curse or class({})

function modifier_ability_thdotsr_star02_curse:GetEffectName()
	return "particles/items2_fx/rod_of_atos.vpcf"
end

function modifier_ability_thdotsr_star02_curse:DeclareFunctions()
	local decFuncs = {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	}

	return decFuncs
end


function modifier_ability_thdotsr_star02_curse:CheckState()
	local state = {
		[MODIFIER_STATE_ROOTED] = true
	}

	return state
end


function modifier_ability_thdotsr_star02_curse:OnAbilityExecuted(keys)
	if not IsServer() then return end
	local target = self:GetParent()
	
	if keys.unit ~= target then
		return
	
	end
	
	--	for k,v in pairs(keys) do
	--		print(k,v)
	--	end	
	--	if target:GetCurrentActiveAbility():IsItem() then
		
	--		return
		
	--	end
	print(keys.ability:GetName())
	if keys.ability:IsItem() then
		return
	end
	if target:HasModifier("modifier_ability_thdotsr_star02_curse") then
	
		local ability = self:GetAbility()

		target:RemoveModifierByName("modifier_ability_thdotsr_star02_curse")
		
		local mana_burn = ability:GetSpecialValueFor("mana_burn")
		if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
			mana_burn = ability:GetSpecialValueFor("mana_burn_wanbaochui")
		end
	--	target:ReduceMana(target:GetMaxMana()*mana_burn*0.01)
		local manatoburn = math.min(target:GetMaxMana()*mana_burn*0.01,target:GetMana())
		
		target:ReduceMana(manatoburn)
		print("manaburn=="..manatoburn)


		target:EmitSound("Hero_Antimage.ManaBreak")
		local manaburn_pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControl(manaburn_pfx, 0, target:GetAbsOrigin() )
		ParticleManager:ReleaseParticleIndex(manaburn_pfx)

		local caster = self:GetCaster()
		
		if caster:HasModifier("modifier_item_wanbaochui") then
			local damage = (target:GetMaxMana() - target:GetMana() ) * ability:GetSpecialValueFor("wanbaochui_bonus")
			local radius = ability:GetSpecialValueFor("wanbaochui_radius")
			local targets = FindUnitsInRadius(caster:GetTeam(), target:GetOrigin(), nil,500,ability:GetAbilityTargetTeam(),
								DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,0,0,false)

			local void_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_manavoid.vpcf", PATTACH_POINT_FOLLOW, target)
			ParticleManager:SetParticleControlEnt(void_pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true)
			ParticleManager:SetParticleControl(void_pfx, 1, Vector(radius,0,0))
			ParticleManager:ReleaseParticleIndex(void_pfx)
			target:EmitSound("Hero_Antimage.ManaVoid")

			for _,v in pairs(targets) do
				local wanbaochui_damage_table = {
					ability = ability,
		    		victim = v,
		    		attacker = caster,
		    		damage = damage,
		    		damage_type = ability:GetAbilityDamageType(), 
					damage_flags = 0
					}
				UnitDamageTarget(wanbaochui_damage_table)
			end
		else
			local damage_table = {
			ability = ability,
		    victim = target,
		    attacker = caster,
		    damage = manatoburn,
		    damage_type = ability:GetAbilityDamageType(), 
			damage_flags = 0
			}
			UnitDamageTarget(damage_table)
		end
	end
end

function modifier_ability_thdotsr_star02_curse:IsDebuff()
	return true
end

function modifier_ability_thdotsr_star02_curse:IsPurgable()
	return true
end

function modifier_ability_thdotsr_star02_curse:RemoveOnDeath()
	return true
end

modifier_ability_thdots_star_talent_3 = {}
LinkLuaModifier("modifier_ability_thdots_star_talent_3","scripts/vscripts/abilities/abilitystar.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_star_talent_3:IsHidden() 		return true end
function modifier_ability_thdots_star_talent_3:IsPurgable()		return false end
function modifier_ability_thdots_star_talent_3:RemoveOnDeath() 	return false end
function modifier_ability_thdots_star_talent_3:IsDebuff()		return false end

modifier_ability_thdots_star_talent_2 = {}
LinkLuaModifier("modifier_ability_thdots_star_talent_2","scripts/vscripts/abilities/abilitystar.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_star_talent_2:IsHidden() 		return true end
function modifier_ability_thdots_star_talent_2:IsPurgable()		return false end
function modifier_ability_thdots_star_talent_2:RemoveOnDeath() 	return false end
function modifier_ability_thdots_star_talent_2:IsDebuff()		return false end