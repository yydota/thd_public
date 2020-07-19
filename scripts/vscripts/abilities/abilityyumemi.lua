function OnYumemiExSpellThink(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local cross = Entities:FindAllByModel("models/thd2/yumemi/yumemi_q_mmd.vmdl")
	caster:SetModifierStackCount("passive_yumemiEx_bonus_attack", keys.ability, #cross+1)
end

-- function OnYumemiExSpellOnDamage(keys)
-- 	local caster = EntIndexToHScript(keys.caster_entindex)
-- 	local cross = Entities:FindAllByModel("models/thd2/yumemi/yumemi_q_mmd.vmdl")
-- 	local telentblock = 0 + FindTelentValue(caster,"special_bonus_unique_tinker_2")

-- 	for k,v in pairs(cross) do
-- 		if v~=nil or v:IsNull()==false then 
-- 			local owner = v:GetOwner()
-- 			local casterOwner = caster:GetOwner()
-- 			if owner ~= nil and casterOwner~= nil and owner == casterOwner then
-- 				if keys.DamageTaken > telentblock then
-- 					if v.ability_yumemi_01_spell_dealdamage > 0 then
-- 						v.ability_yumemi_01_spell_dealdamage = v.ability_yumemi_01_spell_dealdamage - keys.DamageTaken
-- 						caster:SetHealth(caster:GetHealth() + keys.DamageTaken)
-- 						return
-- 					else
-- 						v:RemoveSelf()
						
-- 					end				
-- 				end	
-- 			end
-- 		end
-- 	end
-- end

function YumemiCreateCross(caster,vector)
	local count = 1 + FindTelentValue(caster,"special_bonus_unique_tinker")
	for i=1,count do
		local cross = CreateUnitByName(
				"npc_ability_yumemi_01_cross"
				,vector
				,false
				,caster
				,caster
				,caster:GetTeam()
		)
		local ability_dummy_unit = cross:FindAbilityByName("ability_dummy_unit")
		ability_dummy_unit:SetLevel(1)
		
		cross:SetForwardVector(caster:GetForwardVector())
		cross:SetContextThink(DoUniqueString("ability_yumemi_01_spell_cross"), 
			function()
				if GameRules:IsGamePaused() then return 0.03 end
				cross:ForceKill(true)
				return
			end, 
		12.0)
		local owner = caster:GetOwner()
		if owner~= nil then 
			cross:SetOwner(owner) 
		end
		cross.ability_yumemi_01_spell_dealdamage = 1
	end
end

function OnYumemi01SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local targetPoint = keys.target_points[1]
	
	local rad = GetRadBetweenTwoVec2D(caster:GetOrigin(),targetPoint) 
	local forwardVector = caster:GetOrigin() + Vector(math.cos(rad)*keys.FixedDistance,math.sin(rad)*keys.FixedDistance,0) 

	if caster.ability_yumemi_01_spell_dealdamage ~= 0 then
		caster.ability_yumemi_01_spell_dealdamage = 0
	end

	caster:SetContextThink(DoUniqueString("ability_yumemi_01_spell_start"), 
		function()
			if GameRules:IsGamePaused() then return 0.03 end
			YumemiCreateCross(caster,forwardVector)
			return nil
		end, 
	1.0)
end

function OnYumemi01SpellHit(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local dealdamage = keys.ability:GetAbilityDamage() + caster:GetIntellect() * keys.damage_int_mult

	local damage_table = {
				ability = keys.ability,
			    victim = keys.target,
			    attacker = caster,
			    damage = dealdamage,
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = keys.ability:GetAbilityTargetFlags()
	}
	UnitDamageTarget(damage_table)
end


function OnYumemi02SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local targetPoint = keys.target_points[1]
	local Yumemi02rad = GetRadBetweenTwoVec2D(caster:GetOrigin(),targetPoint)
	local Yumemi02dis = GetDistanceBetweenTwoVec2D(caster:GetOrigin(),targetPoint)
	keys.ability:SetContextNum("ability_Yumemi02_Rad",Yumemi02rad,0)
	keys.ability:SetContextNum("ability_Yumemi02_Dis",Yumemi02dis,0)
	--caster:SetModel("models/thd2/yumemi/yumemi_idousen.vmdl")
	local Caster = keys.caster
	local CasterName = Caster:GetClassname()
	if CasterName ~= "npc_dota_hero_tinker" then
		caster:SetOriginalModel("models/satori/satori.vmdl")
	else
		caster:SetOriginalModel("models/thd2/yumemi/yumemi_idousen.vmdl")
	end
end

function OnYumemi02SpellMove(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()

	local Yumemi02rad = keys.ability:GetContext("ability_Yumemi02_Rad")
	local vec = Vector(vecCaster.x+math.cos(Yumemi02rad)*keys.MoveSpeed/50,vecCaster.y+math.sin(Yumemi02rad)*keys.MoveSpeed/50,GetGroundPosition(caster:GetOrigin(), caster).z+100)
	caster:SetOrigin(vec)
	
	local Yumemi02dis = keys.ability:GetContext("ability_Yumemi02_Dis")
	local manacostpercent=keys.ManaCostPercent

	if(Yumemi02dis<0 or caster:GetMana()<=0)then
		SetTargetToTraversable(caster)
		keys.ability:SetContextNum("ability_Yumemi02_Dis",0,0)
		caster:RemoveModifierByName("modifier_thdots_yumemi02_think_interval")
		caster:SetOrigin(Vector(vec.x,vec.y,GetGroundPosition(caster:GetOrigin(), caster).z))
		local Caster = keys.caster
		local CasterName = Caster:GetClassname()
		if CasterName ~= "npc_dota_hero_tinker" then
			--caster:SetModel("models/satori/satori.vmdl")
			caster:SetOriginalModel("models/satori/satori.vmdl")
		else
			--caster:SetModel("models/thd2/yumemi/yumemi_mmd.vmdl")
			caster:SetOriginalModel("models/thd2/yumemi/yumemi_mmd.vmdl")
		end		
		local effectIndex = ParticleManager:CreateParticle("particles/econ/items/storm_spirit/storm_spirit_orchid_hat/stormspirit_orchid_ball_end.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(effectIndex, 0, caster:GetOrigin())
		ParticleManager:SetParticleControl(effectIndex, 1, caster:GetOrigin())
	else
	    Yumemi02dis = Yumemi02dis - keys.MoveSpeed/50
	    keys.ability:SetContextNum("ability_Yumemi02_Dis",Yumemi02dis,0)
	    caster:SetMana(caster:GetMana()-caster:GetMaxMana()*manacostpercent/5000-keys.ManaCost)
	end
end

function OnYumemi03SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	if caster:HasModifier("modifier_item_wanbaochui") then
		local MaxTargets=8
		local Targets=FindUnitsInRadius(caster:GetTeamNumber(),
										caster:GetAbsOrigin(),
										nil,
										700,
										DOTA_UNIT_TARGET_TEAM_ENEMY,
										DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
										DOTA_UNIT_TARGET_FLAG_NONE,
										FIND_ANY_ORDER,--[[FIND_CLOSEST,]]
										false)
		for _,unit in pairs(Targets) do
			if MaxTargets>0 then
				if unit and unit:IsAlive() and unit~=Target and caster:CanEntityBeSeenByMyTeam(unit) then
					caster:PerformAttack(unit,
						true,
						true,
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
	local vecCaster = caster:GetOrigin()
	local effectIndex = ParticleManager:CreateParticle("particles/heroes/yumemi/ability_yumemi_03_unit.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, caster:GetOrigin())
	ParticleManager:SetParticleControl(effectIndex, 1, caster:GetOrigin())

	caster:SetContextThink(DoUniqueString("ability_yumemi_03_spell_start"), 
		function()
			if GameRules:IsGamePaused() then return 0.03 end
			local targets = FindUnitsInRadius(
				   caster:GetTeam(),		
				   vecCaster,		
				   nil,					
				   keys.Radius,		
				   DOTA_UNIT_TARGET_TEAM_ENEMY,
				   keys.ability:GetAbilityTargetType(),
				   0, FIND_CLOSEST,
				   false
			)

			for _,v in pairs(targets) do
			local deal_damage = keys.ability:GetAbilityDamage()
			local damage_table = {
					ability = keys.ability,
					victim = v,
					attacker = caster,
					damage = deal_damage,
					damage_type = keys.ability:GetAbilityDamageType(), 
				    damage_flags = keys.ability:GetAbilityTargetFlags()
				}
				UnitDamageTarget(damage_table) 
				keys.ability:ApplyDataDrivenModifier( caster, v, "modifier_yumemi_03_slow", {} )
			end
			caster:EmitSound("Hero_StormSpirit.StaticRemnantExplode")
			YumemiCreateCross(caster,vecCaster)
			return nil
		end, 
	1.0)
end

function OnYumemi04PhaseStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)
	caster:EmitSound("Hero_Enigma.BlackHole.Cast.Chasm")
end

function OnYumemi04Destroy(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targets = FindUnitsInRadius(
				   caster:GetTeam(),		
				   vecCaster,		
				   nil,					
				   keys.Radius + FindTelentValue(caster,"special_bonus_unique_tinker_3"),		
				   DOTA_UNIT_TARGET_TEAM_ENEMY,
				   keys.ability:GetAbilityTargetType(),
				   0, FIND_CLOSEST,
				   false
			)
	for _,v in pairs(targets) do
		local deal_damage = keys.ability:GetAbilityDamage()
		local damage_table = {
			ability = keys.ability,
			victim = v,
			attacker = caster,
			damage = deal_damage,
			damage_type = keys.ability:GetAbilityDamageType(), 
			damage_flags = keys.ability:GetAbilityTargetFlags()
		}
		UnitDamageTarget(damage_table) 
		UtilStun:UnitStunTarget(caster,v,keys.StunDuration)
	end
	caster:EmitSound("Hero_Phoenix.SuperNova.Explode") 
end



function OnYumemiExSpellOnDamage(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local cross = Entities:FindAllByModel("models/thd2/yumemi/yumemi_q_mmd.vmdl")
	local telentblock = 0 + FindTelentValue(caster,"special_bonus_unique_tinker_2")

	for k,v in pairs(cross) do
		if v~=nil or v:IsNull()==false then 
			local owner = v:GetOwner()
			local casterOwner = caster:GetOwner()
			if owner ~= nil and casterOwner~= nil and owner == casterOwner then
				if keys.DamageTaken > telentblock then
					if not caster:HasModifier("modifier_ability_thdots_yumemiEx_cross") then
						caster:SetHealth(caster:GetHealth() + keys.DamageTaken)
						caster:AddNewModifier(caster, keys.ability, "modifier_ability_thdots_yumemiEx_cross", {duration = 0.05})
						v:RemoveSelf()
					else
						return
					end			
				end
			end
		end
	end
end

modifier_ability_thdots_yumemiEx_cross = {}
LinkLuaModifier("modifier_ability_thdots_yumemiEx_cross","scripts/vscripts/abilities/abilityyumemi.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_yumemiEx_cross:IsHidden() 		return false end
function modifier_ability_thdots_yumemiEx_cross:IsPurgable()		return false end
function modifier_ability_thdots_yumemiEx_cross:RemoveOnDeath() 	return false end
function modifier_ability_thdots_yumemiEx_cross:IsDebuff()		return false end

function modifier_ability_thdots_yumemiEx_cross:OnCreated()
	if not IsServer() then return end
	self.particle = "particles/units/heroes/hero_templar_assassin/templar_assassin_refraction.vpcf"
	self.duration = 0.3
	local caster 				= self:GetCaster()
	self.refraction_particle = ParticleManager:CreateParticle(self.particle, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(self.refraction_particle, 1, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:DestroyParticleSystemTime(self.refraction_particle, self.duration)
end

function modifier_ability_thdots_yumemiEx_cross:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK
	}
end


function modifier_ability_thdots_yumemiEx_cross:GetModifierTotal_ConstantBlock(kv)
	if not IsServer() then return end
	return kv.damage
end