--------------------------------------------------------
--舌切雀「对谦虚之富者的仇恨」
--------------------------------------------------------
ability_thdots_parseeEx = {}

function ability_thdots_parseeEx:GetBehavior()
	if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	else
		return self.BaseClass.GetBehavior(self)
	end
end

function ability_thdots_parseeEx:GetCooldown(level)
	if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
		return self:GetSpecialValueFor("wanbaochui_cooldown")
	else
		return self:GetSpecialValueFor("cooldown")
	end
end

function ability_thdots_parseeEx:GetCastRange()
	if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
		return self:GetSpecialValueFor("wanbaochui_cast_range")
	else
		return 0
	end
end

function ability_thdots_parseeEx:GetIntrinsicModifierName()
	return "modifier_ability_thdots_parseeEx_passive"
end

function ability_thdots_parseeEx:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if not target:IsRealHero() then self:EndCooldown() return end
	local passive_modifier = caster:FindModifierByName("modifier_ability_thdots_parseeEx_passive")
	passive_modifier:SetStackCount(1)
	if caster.parseeEx_wanbaochui_target ~= nil then
		caster.parseeEx_wanbaochui_target:RemoveModifierByName("modifier_ability_thdots_parseeEx_wanbaochui_target")
	end
	caster.parseeEx_wanbaochui_target = target
	target.parseeEx_wanbaochui_caster = caster
	caster:AddNewModifier(caster, self, "modifier_ability_thdots_parseeEx_wanbaochui_caster", {})
	target:AddNewModifier(caster, self, "modifier_ability_thdots_parseeEx_wanbaochui_target", {})
	if caster == target then
		caster:RemoveModifierByName("modifier_ability_thdots_parseeEx_wanbaochui_caster")
		caster:RemoveModifierByName("modifier_ability_thdots_parseeEx_wanbaochui_target")
		caster:FindModifierByName("modifier_ability_thdots_parseeEx_passive"):SetStackCount(0)
		return
	end
	--特效
	local particle_name = "particles/units/heroes/hero_necrolyte/necrolyte_pulse_friend.vpcf"
	local parseeEx_particle = ParticleManager:CreateParticle(particle_name, PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(parseeEx_particle , 0, caster, 5, "attach_attack1", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(parseeEx_particle , 1, target, 5, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControl(parseeEx_particle, 2, Vector(4000,0,0))
	ParticleManager:DestroyParticleSystemTime(parseeEx_particle,1)
	target:EmitSound("Voice_Thdots_Parsee.AbilityParseeEx_Wanbaochui")
end

modifier_ability_thdots_parseeEx_wanbaochui_caster = {}
LinkLuaModifier("modifier_ability_thdots_parseeEx_wanbaochui_caster","scripts/vscripts/abilities/abilityparsee.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_parseeEx_wanbaochui_caster:IsHidden() 		return false end
function modifier_ability_thdots_parseeEx_wanbaochui_caster:IsPurgable()		return false end
function modifier_ability_thdots_parseeEx_wanbaochui_caster:RemoveOnDeath() 	return false end
function modifier_ability_thdots_parseeEx_wanbaochui_caster:IsDebuff()		return false end

modifier_ability_thdots_parseeEx_wanbaochui_target = {}
LinkLuaModifier("modifier_ability_thdots_parseeEx_wanbaochui_target","scripts/vscripts/abilities/abilityparsee.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_parseeEx_wanbaochui_target:IsHidden() 		return false end
function modifier_ability_thdots_parseeEx_wanbaochui_target:IsPurgable()		return false end
function modifier_ability_thdots_parseeEx_wanbaochui_target:RemoveOnDeath() 	return false end
function modifier_ability_thdots_parseeEx_wanbaochui_target:IsDebuff()		return false end

--万宝槌击杀记录金钱，击杀后返回一半给parsee,并且自己加4
function modifier_ability_thdots_parseeEx_wanbaochui_target:OnCreated()
	if not IsServer() then return end
	self.gold = 0
	self:StartIntervalThink(FrameTime())
end

function modifier_ability_thdots_parseeEx_wanbaochui_target:OnIntervalThink()
	if not IsServer() then return end
	self.gold = self:GetParent():GetGold()
	local caster = self:GetCaster()
	local target = self:GetParent()
	local ability = self:GetAbility()
	if target:GetHealthPercent() <= 20 and target:IsAlive() and target:IsRealHero() and self:GetStackCount() ~= 1 then
		target:AddNewModifier(caster, self:GetAbility(), "modifier_ability_thdots_parseeEx_invin", {duration = self:GetAbility():GetSpecialValueFor("invin_time")})
		caster:RemoveModifierByName("modifier_ability_thdots_parseeEx_wanbaochui_caster")
		self:Destroy()
	end
end
function modifier_ability_thdots_parseeEx_wanbaochui_target:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
end

function modifier_ability_thdots_parseeEx_wanbaochui_target:GetModifierIncomingDamage_Percentage()
	return self:GetAbility():GetSpecialValueFor("wanbaochui_income_damage")
end

function modifier_ability_thdots_parseeEx_wanbaochui_target:OnDeath(keys)
	if not IsServer() then return end
	local caster = self:GetCaster()
	if keys.attacker == self:GetParent() then
		-- print(self:GetParent():GetGold())
		-- print(self.gold)
		--水桥增加一半
		local totalgoldget = ( self:GetParent():GetGold() - self.gold ) / 2
		local PlayerID = caster:GetPlayerOwnerID()
        PlayerResource:SetGold(PlayerID,PlayerResource:GetUnreliableGold(PlayerID) + totalgoldget,false)
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD,caster, totalgoldget, nil)

        --自己击杀增加
		local target = self:GetParent()
        local wanbaochui_gold = self:GetAbility():GetSpecialValueFor("wanbaochui_gold")
		local Target_PlayerID = target:GetPlayerOwnerID()
        PlayerResource:SetGold(Target_PlayerID,PlayerResource:GetUnreliableGold(Target_PlayerID) + wanbaochui_gold,false)
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD,target, wanbaochui_gold, nil)
	end
end

function modifier_ability_thdots_parseeEx_wanbaochui_target:OnDestroy()
	if not IsServer() then return end
	self:GetParent().parseeEx_wanbaochui_caster = nil
end



------------------------------------天生BUFF
modifier_ability_thdots_parseeEx_passive = {}
LinkLuaModifier("modifier_ability_thdots_parseeEx_passive","scripts/vscripts/abilities/abilityparsee.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_parseeEx_passive:IsHidden()
	if self:GetStackCount() == 1 then
 		return true
	else
 		return false
 	end
 end
function modifier_ability_thdots_parseeEx_passive:IsPurgable()		return false end
function modifier_ability_thdots_parseeEx_passive:RemoveOnDeath() 	return false end
function modifier_ability_thdots_parseeEx_passive:IsDebuff()		return false end

-- function modifier_ability_thdots_parseeEx_passive:DeclareFunctions()
-- 	return {
-- 		MODIFIER_EVENT_ON_DEATH,
-- 	}
-- end
-- function modifier_ability_thdots_parseeEx_passive:OnDeath(keys)
-- 	if not IsServer() then return end
-- 	if keys.attacker == self:GetParent() then
-- 		print("gold is ----------------")
-- 		print(self:GetParent():GetGold())
-- 		print(self.gold)
-- 	end
-- end

function modifier_ability_thdots_parseeEx_passive:OnCreated()
	if not IsServer() then return end
	self:GetCaster().parseeEx_wanbaochui_target = nil
	self.gold = 0
	self:StartIntervalThink(FrameTime())
end

function modifier_ability_thdots_parseeEx_passive:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetParent()
	local ability = self:GetAbility()
	self.gold = caster:GetGold()
	if caster:GetHealthPercent() <= 20 and self:GetAbility():IsCooldownReady() and caster:IsAlive() and caster:IsRealHero() and self:GetStackCount() ~= 1 then
		caster:AddNewModifier(caster, self:GetAbility(), "modifier_ability_thdots_parseeEx_invin", {duration = self:GetAbility():GetSpecialValueFor("invin_time")})
		ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))
	end
	--天赋监听
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_parsee_4") ~= 0 and not self:GetCaster():HasModifier("modifier_ability_thdots_parseeEx_talent1") then
		self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_parseeEx_talent1",{})
	end
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_parsee_5") ~= 0 and not self:GetCaster():HasModifier("modifier_ability_thdots_parseeEx_talent2") then
		self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_parseeEx_talent2",{})
	end
	--万宝槌监听
	if not self:GetCaster():HasModifier("modifier_item_wanbaochui") then
		self:SetStackCount(0)
		if caster:FindModifierByName("modifier_ability_thdots_parseeEx_wanbaochui_caster") then
			caster:RemoveModifierByName("modifier_ability_thdots_parseeEx_wanbaochui_caster")
			if caster.parseeEx_wanbaochui_target ~= nil then
				caster.parseeEx_wanbaochui_target:RemoveModifierByName("modifier_ability_thdots_parseeEx_wanbaochui_target")
			end
		end
	end
end

modifier_ability_thdots_parseeEx_talent1 = {}  --天赋监听
LinkLuaModifier("modifier_ability_thdots_parseeEx_talent1","scripts/vscripts/abilities/abilityparsee.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_parseeEx_talent1:IsHidden() 		return true end
function modifier_ability_thdots_parseeEx_talent1:IsPurgable()		return false end
function modifier_ability_thdots_parseeEx_talent1:RemoveOnDeath() 	return false end
function modifier_ability_thdots_parseeEx_talent1:IsDebuff()		return false end

modifier_ability_thdots_parseeEx_talent2 = {}  --天赋监听
LinkLuaModifier("modifier_ability_thdots_parseeEx_talent2","scripts/vscripts/abilities/abilityparsee.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_parseeEx_talent2:IsHidden() 		return true end
function modifier_ability_thdots_parseeEx_talent2:IsPurgable()		return false end
function modifier_ability_thdots_parseeEx_talent2:RemoveOnDeath() 	return false end
function modifier_ability_thdots_parseeEx_talent2:IsDebuff()		return false end


modifier_ability_thdots_parseeEx_invin = {}
LinkLuaModifier("modifier_ability_thdots_parseeEx_invin","scripts/vscripts/abilities/abilityparsee.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_parseeEx_invin:IsHidden() 		return false end
function modifier_ability_thdots_parseeEx_invin:IsPurgable()		return false end
function modifier_ability_thdots_parseeEx_invin:RemoveOnDeath() 	return false end
function modifier_ability_thdots_parseeEx_invin:IsDebuff()		return false end

modifier_ability_thdots_parseeEx_illusion = {}
LinkLuaModifier("modifier_ability_thdots_parseeEx_illusion","scripts/vscripts/abilities/abilityparsee.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_parseeEx_illusion:IsHidden() 		return false end
function modifier_ability_thdots_parseeEx_illusion:IsPurgable()		return false end
function modifier_ability_thdots_parseeEx_illusion:RemoveOnDeath() 	return true end
function modifier_ability_thdots_parseeEx_illusion:IsDebuff()		return false end

--无敌buff
function modifier_ability_thdots_parseeEx_invin:CheckState()
	local state =
	{
		[MODIFIER_STATE_INVULNERABLE] 	= true,
		[MODIFIER_STATE_OUT_OF_GAME]	= true,
		[MODIFIER_STATE_UNSELECTABLE]	= true,
		[MODIFIER_STATE_DISARMED]		= true,
		[MODIFIER_STATE_STUNNED]		= true,
	}
	return state
end

function modifier_ability_thdots_parseeEx_invin:OnCreated()
	if not IsServer() then return end
	local caster = self:GetParent()
	ProjectileManager:ProjectileDodge(self:GetParent())
	local randomPoint = caster:GetOrigin()
	local max_distance = 500
	self.Illusion_point = Vector(0,0,0)
	self.caster_point = Vector(0,0,0)

	self.Illusion_point.x 	= randomPoint.x + RandomFloat(-max_distance,max_distance)
	self.Illusion_point.y 	= randomPoint.y + RandomFloat(-max_distance,max_distance)
	self.Illusion_point.z 	= randomPoint.z

	self.caster_point.x 	= randomPoint.x + RandomFloat(-max_distance,max_distance)
	self.caster_point.y 	= randomPoint.y + RandomFloat(-max_distance,max_distance)
	self.caster_point.z 	= randomPoint.z

	--特效音效
	local illusion_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_lancer/phantom_lancer_doppleganger_illlmove.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(illusion_particle, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(illusion_particle, 1, self.Illusion_point)

	local caster_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_lancer/phantom_lancer_doppleganger_illlmove.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(caster_particle, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(caster_particle, 1, self.caster_point)

	local particle = "particles/units/heroes/hero_phantom_lancer/phantom_lancer_doppleganger_aoe.vpcf"
	local doppleganger_particle = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(doppleganger_particle, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(doppleganger_particle, 2, Vector(325, 325, 325))
	ParticleManager:SetParticleControl(doppleganger_particle, 3, Vector(1, 0, 0))
	ParticleManager:ReleaseParticleIndex(doppleganger_particle)
	
	caster:EmitSound("Voice_Thdots_Parsee.AbilityParseeEx_Passive_Cast")
	self:GetParent():AddNoDraw()
end

function modifier_ability_thdots_parseeEx_invin:OnDestroy()
	if not IsServer() then return end
	local caster = self:GetParent()
	self:GetParent():EmitSound("Hero_PhantomLancer.Doppelganger.Appear")
	self:GetParent():RemoveNoDraw()

	caster:Purge(false,true,false,true,false)
	FindClearSpaceForUnit(caster, self.caster_point, true)
	--制造幻象
	local illusion = create_illusion(caster,self:GetAbility(),self.Illusion_point,0,0,self:GetAbility():GetSpecialValueFor("duration"))
	illusion:SetHealth(caster:GetHealthPercent()/100 * illusion:GetBaseMaxHealth())
	illusion:AddNewModifier(caster, self:GetAbility(), "modifier_ability_thdots_parseeEx_illusion", {})
end

--幻象爆炸buff
function modifier_ability_thdots_parseeEx_illusion:OnDestroy()
	if not IsServer() then return end
	local caster 	= self:GetCaster()
	local ability 	= self:GetAbility()
	local radius 	= ability:GetSpecialValueFor("radius")
	local lv_damage = ability:GetSpecialValueFor("lv_damage")
	local damage 	= ability:GetSpecialValueFor("damage") + caster:GetLevel() * lv_damage
	local targets = FindUnitsInRadius(caster:GetTeam(), self:GetParent():GetAbsOrigin(), nil, radius,
					DOTA_UNIT_TARGET_TEAM_ENEMY,ability:GetAbilityTargetType(),0,0,false)
	--爆炸特效音效
	local parseeEx_explosion_particle = ParticleManager:CreateParticle("particles/econ/items/pugna/pugna_ti9_immortal/pugna_ti9_immortal_netherblast.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(parseeEx_explosion_particle, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(parseeEx_explosion_particle, 1, Vector(radius,0,0))
	ParticleManager:ReleaseParticleIndex(parseeEx_explosion_particle)

	StartSoundEventFromPosition("Voice_Thdots_Parsee.AbilityParseeEx_Explosion", self:GetParent():GetAbsOrigin())

	for _,v in pairs(targets) do
		local damage_tabel = {
				victim 			= v,
				damage 			= damage,
				damage_type		= ability:GetAbilityDamageType(),
				attacker 		= caster,
				ability 		= ability
			}
		UnitDamageTarget(damage_tabel)
	end
end

function create_illusion(caster,self, illusion_origin, illusion_incoming_damage, illusion_outgoing_damage, illusion_duration)
	local player_id = caster:GetPlayerID()
	local caster_team = caster:GetTeam()
	local tmp = caster
	if GetMapName() == "dota" then
		tmp = nil
	end
	
	local illusion = CreateUnitByName(caster:GetUnitName(), illusion_origin, true, caster, tmp, caster_team)  --handle_UnitOwner needs to be nil, or else it will crash the game.
	illusion:SetPlayerID(player_id)
	illusion:SetControllableByPlayer(player_id, true)

	--Level up the illusion to the caster's level.
	local caster_level = caster:GetLevel()
	for i = 1, caster_level - 1 do
		illusion:HeroLevelUp(false)
	end

	--Set the illusion's available skill points to 0 and teach it the abilities the caster has.
	illusion:SetAbilityPoints(0)
	for ability_slot = 0, 15 do
		local individual_ability = caster:GetAbilityByIndex(ability_slot)
		if individual_ability ~= nil then 
			local illusion_ability = illusion:FindAbilityByName(individual_ability:GetAbilityName())
			if illusion_ability ~= nil then
				illusion_ability:SetLevel(individual_ability:GetLevel())
			end
		end
	end

	--Recreate the caster's items for the illusion.
	for item_slot = 0, 5 do
		local individual_item = caster:GetItemInSlot(item_slot)
		if individual_item ~= nil then
			local illusion_duplicate_item = CreateItem(individual_item:GetName(), illusion, illusion)
			illusion:AddItem(illusion_duplicate_item)
			illusion_duplicate_item:SetPurchaser(nil)
		end
	end
	
	-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle 
	illusion:AddNewModifier(caster, self, "modifier_illusion", {duration = illusion_duration, outgoing_damage = illusion_outgoing_damage, incoming_damage = illusion_incoming_damage})
	
	illusion:MakeIllusion()  --Without MakeIllusion(), the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.  Without it, IsIllusion() returns false and IsRealHero() returns true.

	return illusion
end


--------------------------------------------------------
--咒怨念法「积怨返」
--------------------------------------------------------

ability_thdots_parsee01 = {}

function ability_thdots_parsee01:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasModifier("modifier_ability_thdots_parseeEx_talent1") then
		return self:GetSpecialValueFor("cast_range") + 200
	else
		return self:GetSpecialValueFor("cast_range")
	end
end

function ability_thdots_parsee01:GetIntrinsicModifierName()
	return "modifier_ability_thdots_parsee01_passive"
end

modifier_ability_thdots_parsee01_passive = {}
LinkLuaModifier("modifier_ability_thdots_parsee01_passive","scripts/vscripts/abilities/abilityparsee.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_parsee01_passive:IsHidden() 		return false end
function modifier_ability_thdots_parsee01_passive:IsPurgable()		return false end
function modifier_ability_thdots_parsee01_passive:RemoveOnDeath() 	return false end
function modifier_ability_thdots_parsee01_passive:IsDebuff()		return false end

function modifier_ability_thdots_parsee01_passive:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end

function modifier_ability_thdots_parsee01_passive:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	self.radius = ability:GetSpecialValueFor("cast_range")
	local passive_percent = ability:GetSpecialValueFor("passive_percent")
	if FindTelentValue(caster,"special_bonus_unique_parsee_4") ~= 0 then
		self.radius = self.radius + FindTelentValue(caster,"special_bonus_unique_parsee_4")
		passive_percent = passive_percent * 2
	end
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, self.radius,
					ability:GetAbilityTargetTeam(),ability:GetAbilityTargetType(),0,0,false)
	local count = 0
	for _,v in pairs(targets) do
		if v:IsHero() then
			count = count + 1
		end
	end
	self:SetStackCount(count)
	--设置附近单位的debuff时间延长
	for _,v in pairs(targets) do
	    for i=0,30 do
	         if v:GetModifierNameByIndex(i) ~= "" then
	         	local modifier = v:FindModifierByName(v:GetModifierNameByIndex(i))
	         	if modifier ~= nil then
		            if modifier:IsDebuff() and modifier.parsee01 ~= false then
		            	modifier.parsee01 = false --只生效一次
		            	local modifier_time = modifier:GetRemainingTime()
		            	print(modifier:GetRemainingTime())
		            	local extra_time = 1 + (self:GetStackCount() *  passive_percent)/100 --debuff延长时间百分比
		            	if IsNoBugModifier(modifier) then
	            			modifier:SetDuration(modifier_time * extra_time, true)
		            	end
		            	print(extra_time)
		            	print(modifier:GetRemainingTime())
		            	print("--------------------")
		            end
		        end
	         end
	    end
	end
end

function ability_thdots_parsee01:OnSpellStart()
	if not IsServer() then return end
	local caster 				= self:GetCaster()
	local target 				= self:GetCursorTarget()
	if is_spell_blocked(target,caster) then return end

	local number 				= self:GetSpecialValueFor("number")
	local number 				= self:GetSpecialValueFor("number")
	self.start_point = self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("attach_attack1"))

	caster:EmitSound("Voice_Thdots_Parsee.AbilityParsee01_Caster")

	-- local particle = "particles/units/heroes/hero_phantom_lancer/phantom_lancer_death.vpcf"
	-- self.fxIndex = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN, caster)
	-- ParticleManager:SetParticleControlEnt(self.fxIndex , 0, caster, 5, "attach_hitloc", Vector(0,0,0), true)

	-- local doppleganger_particle = ParticleManager:CreateParticle("particles/econ/items/pugna/pugna_ti9_immortal/pugna_ti9_immortal_netherblast.vpcf", PATTACH_WORLDORIGIN, nil)
	-- ParticleManager:SetParticleControl(doppleganger_particle, 0, caster:GetAbsOrigin())
	-- ParticleManager:SetParticleControl(doppleganger_particle, 1, Vector(500,0,0))
	-- ParticleManager:ReleaseParticleIndex(doppleganger_particle)

	-- local particle = "particles/units/heroes/hero_phantom_lancer/phantom_lancer_doppleganger_aoe.vpcf"
	-- local doppleganger_particle = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, self:GetCaster())
	-- ParticleManager:SetParticleControl(doppleganger_particle, 0, self:GetCaster():GetAbsOrigin())
	-- ParticleManager:SetParticleControl(doppleganger_particle, 2, Vector(325, 325, 325))
	-- ParticleManager:SetParticleControl(doppleganger_particle, 3, Vector(1, 0, 0))
	-- ParticleManager:ReleaseParticleIndex(doppleganger_particle)

	--创建投射物
	local width = 50
	local length = 1500
	local travel_speed = 1500
	-- local particle_projectile = "particles/units/heroes/hero_sniper/sniper_assassinate.vpcf"
	-- local assassinate_projectile = {Target = target,
	-- 			Source = caster,
	-- 			Ability = self,
	-- 			EffectName = particle_projectile,
	-- 			iMoveSpeed = travel_speed,
	-- 			bDodgeable = true,
	-- 			bVisibleToEnemies = true,
	-- 			bReplaceExisting = false,
	-- 			bProvidesVision = false,
	-- 			ExtraData = {
	-- 				target_entindex		= target:entindex(),
	-- 				projectile_num		= projectile_num,
	-- 				total_projectiles	= total_projectiles,
	-- 				bAutoCast			= bAutoCast
	-- 			}
	-- 		}
	-- ProjectileManager:CreateTrackingProjectile(assassinate_projectile)
	local point = caster:GetOrigin()
	local back_point = point + caster:GetForwardVector()* - 250
	local vec = math.acos(caster:GetForwardVector().x)
	for i=1,number do
		local even = IsEven(i)
		local even_num = 1
		if even then
			even_num = 1
		else
			even_num = -1
		end
		local caster_forward = caster:GetForwardVector()
		-- local dummy = CreateUnitByName("npc_dota_hero_pugna", 
		local dummy = CreateUnitByName("npc_dummy_unit", 
	    	                        self.start_point, 
									false, 
								    caster, 
									caster, 
									caster:GetTeamNumber()
									)
		-- dummy:SetPlayerID(caster:GetPlayerID())
		-- dummy:SetControllableByPlayer(player, true)
		-- dummy:SetOrigin(back_point + Vector(math.cos(vec+math.pi/1*i) * 250,math.sin(vec+math.pi/1*i) * 250,0))
		dummy:SetOrigin(RotatePosition(caster:GetAbsOrigin(),QAngle(0,45*even_num, 0), back_point))
		RotatePosition(caster:GetAbsOrigin(),QAngle(0, -45*i, 0), back_point)
		dummy:AddNewModifier(caster, self, "modifier_ability_thdots_parsee01_dummy",{duration = 5})
		dummy.parsee01_target = target
		dummy.even = even
		dummy.t = 0
		-- point = RotatePosition(caster:GetAbsOrigin(), qangle, point)
		-- qangle = QAngle(0, angle, 0)
	end
end

--判断奇偶数
function IsEven(num)
	local v = num%2
	if v==0 then
		return true
	else
		return false
	end
end

-- function ability_thdots_parsee01:OnProjectileHit(target, location)
-- 	if not IsServer() then return end
-- 	if target == nil then return end
-- 	local caster = self:GetCaster()
-- 	local ability = self
-- 	local targets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, self.radius,
-- 					ability:GetAbilityTargetTeam(),ability:GetAbilityTargetType(),0,0,false)
-- 	local count = 0
-- 	for _,v in pairs(targets) do
-- 		if v:IsRealHero() then
-- 			count = count + 1
-- 		end
-- 	end
-- 	local damage = self:GetSpecialValueFor("damage") * (1 + self:GetSpecialValueFor("passive_damage")/100 * count ) / 2
-- 	print(damage)
-- 	--特效音效
-- 	target:EmitSound("Hero_Sniper.Boom_Headshot")
-- 	local damageTable = {victim = target,
-- 						damage = damage,
-- 						damage_type = self:GetAbilityDamageType(),
-- 						attacker = caster,
-- 						ability = self
-- 						}
-- 	UnitDamageTarget(damageTable)
-- end

modifier_ability_thdots_parsee01_dummy = {}
LinkLuaModifier("modifier_ability_thdots_parsee01_dummy","scripts/vscripts/abilities/abilityparsee.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_parsee01_dummy:IsHidden() 		return false end
function modifier_ability_thdots_parsee01_dummy:IsPurgable()		return false end
function modifier_ability_thdots_parsee01_dummy:RemoveOnDeath() 	return true end
function modifier_ability_thdots_parsee01_dummy:IsDebuff()		return false end
function modifier_ability_thdots_parsee01_dummy:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_ability_thdots_parsee01_dummy:OnCreated()
	if not IsServer() then return end
	-- body
	self.caster 				= self:GetCaster()
	self.start_point 			= self:GetAbility().start_point
	self.target 				= self:GetParent().parsee01_target
	self.stun_duration 			= FindTelentValue(self:GetCaster(),"special_bonus_unique_letty_2")
	self.damage 				= self:GetAbility():GetSpecialValueFor("damage")
	self.passive_damage 		= self:GetAbility():GetSpecialValueFor("passive_damage") / 100
	self.cast_range 			= self:GetAbility():GetSpecialValueFor("cast_range")
	self.speed 					= 800 * FrameTime()
	-- self.angle = 0
	local dummy = self:GetParent()
	-- local particle = "particles/units/heroes/hero_pugna/pugna_base_attack.vpcf"
	local particle = "particles/econ/items/necrolyte/necrophos_sullen/necro_sullen_pulse_enemy.vpcf"
	self.fxIndex = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN, dummy)
	-- ParticleManager:SetParticleControl(self.fxIndex, 0, dummy:GetOrigin())
	ParticleManager:SetParticleControlEnt(self.fxIndex , 0, dummy, 5, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControl(self.fxIndex, 0, dummy:GetOrigin())
	ParticleManager:SetParticleControl(self.fxIndex, 1, dummy:GetOrigin())
	ParticleManager:SetParticleControl(self.fxIndex, 2, Vector(2000,0,0))
	self:StartIntervalThink(FrameTime())
end

function modifier_ability_thdots_parsee01_dummy:OnIntervalThink()
	if not IsServer() then return end
	local caster = self.caster
	local dummy = self:GetParent()
	local target = dummy.parsee01_target
	local ability = self:GetAbility()
	local damage = self.damage

	-- local qangle = QAngle(0, 30, 0)
	-- local add_increase		= 1	--递增角度
	-- local max_angel			= 10--最大发射角度
	-- if self.angle <= max_angel then
	-- 	self.angle = self.angle + add_increase
	-- else
	-- 	self.angle = -self.angle
	-- 	self.angle = self.angle - add_increase
	-- end
	-- qangle = QAngle(0, self.angle, 0)
	-- local direct = (target:GetOrigin() - dummy:GetOrigin()):Normalized()
	-- --移动
	-- local next_point = dummy:GetOrigin() + direct * self.speed
	-- -- local next_point = dummy:GetOrigin() + Vector(10,10,0) * self.speed
	-- next_point.z = self.start_point.z
	-- -- dummy:SetOrigin(next_point)


	if dummy:IsNull() then return end
	local vec = dummy:GetOrigin() 
	local rad = GetRadBetweenTwoVec2D(vec,target:GetOrigin())
	local high = target:GetOrigin().z
	dummy.t = dummy.t + 0.15
	local t = dummy.t
	local even = 1
	--相反角度
	if dummy.even then
		even = 1
	else
		even = -1
	end
	if t < math.pi then --固定转的弧度，pi为半圈
		vec = Vector(vec.x + even*math.cos(t)*20,vec.y + math.sin(t)*20,400)
		dummy:SetOrigin(vec)
	elseif t < math.pi*1.2 then --转完了冲目标而去
			vec = Vector(vec.x + (math.cos(rad) + math.cos(t)) *(20-math.pi*2+t),vec.y + (math.sin(rad) + math.sin(t)) *(20-math.pi*2+t),vec.z)
			dummy:SetOrigin(vec)
	elseif t > math.pi*1.2 then
		dummy.t = dummy.t + 0.5
		vec = Vector(vec.x + math.cos(rad)*(20+t*2),vec.y + math.sin(rad)*(20+t*2),vec.z)
		dummy:SetOrigin(vec)
		if not target:IsAlive() then
			dummy:RemoveSelf()
			self:Destroy()
			return
		elseif GetDistanceBetweenTwoVec2D(dummy:GetAbsOrigin(),target:GetAbsOrigin()) < 50 then --击中距离判定
			--特效音效
			local particle_name = "particles/econ/items/undying/undying_pale_augur/undying_pale_augur_decay_strength_xfer.vpcf"
			local particle = ParticleManager:CreateParticle(particle_name, PATTACH_WORLDORIGIN, nil)
			ParticleManager:SetParticleControl(particle, 0, dummy:GetOrigin())
			ParticleManager:SetParticleControl(particle, 1, dummy:GetOrigin())
			ParticleManager:SetParticleControl(particle, 2, dummy:GetOrigin())
			ParticleManager:ReleaseParticleIndex(particle)
			dummy:EmitSound("Hero_Lich.ChainFrostImpact.Creep")
			--击中，获取目标周围的少女数量，根据数量增加伤害
			local targets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, self.cast_range,
					ability:GetAbilityTargetTeam(),ability:GetAbilityTargetType(),0,0,false)
			local count = 0
			for _,v in pairs(targets) do
				if v:IsRealHero() then
					count = count + 1
				end
			end
			print(count)
			print(self.passive_damage)
			print(damage)
			damage = damage * (1 + count * self.passive_damage) / 2
			print(damage)
			local damage_tabel = {
				victim 			= target,
				damage 			= damage,
				damage_type		= ability:GetAbilityDamageType(),
				attacker 		= caster,
				ability 		= ability
			}
			UnitDamageTarget(damage_tabel)
			dummy:RemoveSelf()
			self:Destroy()
			return
		end
	end
	ParticleManager:SetParticleControl(self.fxIndex, 1, dummy:GetOrigin())

	-----------------
	-- dummy.parsee01_target:GetOrigin() = RotatePosition(self.start_point, qangle, dummy.parsee01_target:GetOrigin())
	-- ParticleManager:SetParticleControl(self.fxIndex, 0, dummy:GetOrigin())
	-- ParticleManager:SetParticleControl(self.fxIndex, 2, Vector(2000,0,0))


	--冰冻伤害
	local targets = FindUnitsInRadius(caster:GetTeam(), dummy:GetOrigin(),nil,128,ability:GetAbilityTargetTeam(),
			ability:GetAbilityTargetType(),0,0,false)
	DeleteDummy(targets)
end

function modifier_ability_thdots_parsee01_dummy:OnDestroy()
	if not IsServer() then return end
	local dummy = self:GetParent()
	
	dummy:RemoveSelf()
	-- ParticleManager:DestroyParticleSystem(self.fxIndex,true)
	ParticleManager:ReleaseParticleIndex(self.fxIndex)
end

--------------------------------------------------------
--嫉妒「嫉妒之炸药」
--------------------------------------------------------

ability_thdots_parsee02 = {}

function ability_thdots_parsee02:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("cast_range")
end

function ability_thdots_parsee02:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function ability_thdots_parsee02:OnSpellStart()
	if not IsServer() then return end
	local caster 				= self:GetCaster()
	local point 				= self:GetCursorPosition()
	local radius 				= self:GetSpecialValueFor("radius")
	local number 				= self:GetSpecialValueFor("number")
	local damage 				= self:GetSpecialValueFor("damage")
	local return_mana 			= self:GetSpecialValueFor("return_mana") / 100
	local slow_duration 		= self:GetSpecialValueFor("slow_duration")
	local intval 				= 0.7
	local point 				= self:GetCursorPosition()

	caster:SetContextThink("Parsee02",
		function()
			if GameRules:IsGamePaused() then return 0.03 end
			if number > 0 then
				local effectIndex = ParticleManager:CreateParticle("particles/econ/items/oracle/oracle_ti10_immortal/oracle_ti10_immortal_purifyingflames_hit.vpcf", PATTACH_WORLDORIGIN, caster)
				ParticleManager:SetParticleControl(effectIndex, 0, point)
				ParticleManager:SetParticleControl(effectIndex, 4, point)
				ParticleManager:ReleaseParticleIndex(effectIndex)
				caster:SetContextThink("Parsee02_delay",
					function()
						if GameRules:IsGamePaused() then return 0.03 end
						StartSoundEventFromPosition("Voice_Thdots_Parsee.AbilityParsee02", point)
						local targets = FindUnitsInRadius(caster:GetTeam(), point, nil, radius,
										self:GetAbilityTargetTeam(),self:GetAbilityTargetType(),0,0,false)
						DeleteDummy(targets)
						--返回蓝
						if #targets == 0 then
							local mana_regen = self:GetManaCost(self:GetLevel()-1) * return_mana
							caster:SetMana(caster:GetMana() + mana_regen)
							SendOverheadEventMessage(nil,OVERHEAD_ALERT_MANA_ADD,caster,mana_regen,nil)
						end
						for _,v in pairs(targets) do
							local damage_table = {
								ability = self,
							    victim = v,
							    attacker = caster,
							    damage = damage,
							    damage_type = self:GetAbilityDamageType(), 
								damage_flags = 0
							}
							--全中造成眩晕
							if v:HasModifier("modifier_ability_thdots_parsee02_debuff") then
								local parsee02_debuff = v:FindModifierByName("modifier_ability_thdots_parsee02_debuff")
								parsee02_debuff:IncrementStackCount()
								parsee02_debuff:SetDuration(slow_duration, true)
								if parsee02_debuff:GetStackCount() >= 3 and FindTelentValue(caster,"special_bonus_unique_parsee_1") ~= 0 then
									UtilStun:UnitStunTarget(caster,v,FindTelentValue(caster,"special_bonus_unique_parsee_1"))
								end
							else
								local parsee02_debuff = v:AddNewModifier(caster, self, "modifier_ability_thdots_parsee02_debuff",{duration = slow_duration})
								parsee02_debuff:SetStackCount(1)
							end
							UnitDamageTarget(damage_table)
						end
					end
				,0.15)

				number = number - 1
				return intval
			else
				return 0
			end
		end,
		0.1)

end

modifier_ability_thdots_parsee02_debuff = {}
LinkLuaModifier("modifier_ability_thdots_parsee02_debuff","scripts/vscripts/abilities/abilityparsee.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_parsee02_debuff:IsHidden() 		return false end
function modifier_ability_thdots_parsee02_debuff:IsPurgable()		return true end
function modifier_ability_thdots_parsee02_debuff:RemoveOnDeath() 	return true end
function modifier_ability_thdots_parsee02_debuff:IsDebuff()		return true end

function modifier_ability_thdots_parsee02_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end


function modifier_ability_thdots_parsee02_debuff:GetModifierMoveSpeedBonus_Percentage()
	return -self:GetAbility():GetSpecialValueFor("slow_percent")
end

function modifier_ability_thdots_parsee02_debuff:GetModifierAttackSpeedBonus_Constant()
	return -self:GetAbility():GetSpecialValueFor("slow_attack")
end

--------------------------------------------------------
--嫉妒「看不见的绿眼怪兽」
--------------------------------------------------------

ability_thdots_parsee03 = {}

function ability_thdots_parsee03:OnSpellStart()
	if not IsServer() then return end
	local caster 				= self:GetCaster()
	local duration 		= self:GetSpecialValueFor("duration")
	local dummy_health 		= self:GetSpecialValueFor("dummy_health")
	local point = caster:GetOrigin()
	local number = self:GetSpecialValueFor("num") + FindTelentValue(caster,"special_bonus_unique_parsee_3")
	local back_point = point + caster:GetForwardVector()*Vector(-1,-1,0)
	local vec = math.acos(caster:GetForwardVector().x)
	for i = 1,number do
		local parsee03_eyes = CreateUnitByName("npc_ability_parsee03_dummy", 
			caster:GetOrigin(),
			false,
			caster,
			caster,
			caster:GetTeam()
		)
		parsee03_eyes:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
		-- parsee03_eyes:AddNewModifier(caster, ability, "modifier_kill", {duration = duration})
		-- parsee03_eyes:AddNewModifier(caster, self, "modifier_ability_thdots_parsee03_dummy", {duration = duration})
		parsee03_eyes:AddNewModifier(caster, self, "modifier_ability_thdots_parsee03_dummy", {})
		parsee03_eyes:SetBaseMaxHealth(dummy_health)
		FindClearSpaceForUnit(parsee03_eyes, back_point + Vector(math.cos(vec+math.pi/3.5*i) * 150,math.sin(vec+math.pi/3.5*i) * 150,0), true)

		local particle = "particles/econ/items/viper/viper_ti7_immortal/viper_poison_attack_ti7_glow_soft.vpcf"
		local particle_2 = "particles/econ/items/viper/viper_ti7_immortal/viper_poison_attack_ti7_edge.vpcf"
		local particle_3 = "particles/econ/items/viper/viper_ti7_immortal/viper_poison_attack_ti7_model.vpcf"
		local parsee03_particle = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN, parsee03_eyes)
		local parsee03_particle_2 = ParticleManager:CreateParticle(particle_2, PATTACH_CUSTOMORIGIN, parsee03_eyes)
		local parsee03_particle_3 = ParticleManager:CreateParticle(particle_3, PATTACH_CUSTOMORIGIN, parsee03_eyes)
		ParticleManager:SetParticleControlEnt(parsee03_particle   , 3, parsee03_eyes, 5, "attach_hitloc", Vector(0,0,0), true)
		ParticleManager:SetParticleControlEnt(parsee03_particle_2 , 3, parsee03_eyes, 5, "attach_hitloc", Vector(0,0,0), true)
		ParticleManager:SetParticleControlEnt(parsee03_particle_3 , 3, parsee03_eyes, 5, "attach_hitloc", Vector(0,0,0), true)
		-- ParticleManager:SetParticleControl(self.fxIndex, 0, parsee03_eyes:GetOrigin())
		-- ParticleManager:DestroyParticleSystemTime(effectIndex,keys.Duration)
		-- ParticleManager:SetParticleControl(parsee03_particle, 0, parsee03_eyes:GetOrigin())
		-- ParticleManager:SetParticleControl(parsee03_particle, 1, parsee03_eyes:GetOrigin())
		-- ParticleManager:SetParticleControl(parsee03_particle, 2, Vector(2000,0,0))

		parsee03_eyes:SetContextThink("parsee03_move",function ()
			if self:GetCursorTarget() ~= nil then
				parsee03_eyes:MoveToTargetToAttack(self:GetCursorTarget())
			else
				parsee03_eyes:MoveToPositionAggressive(self:GetCursorPosition())
			end
		end,FrameTime())
	end

end

modifier_ability_thdots_parsee03_dummy = {}
LinkLuaModifier("modifier_ability_thdots_parsee03_dummy","scripts/vscripts/abilities/abilityparsee.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_parsee03_dummy:IsHidden() 			return true end
function modifier_ability_thdots_parsee03_dummy:IsPurgable()		return false end
function modifier_ability_thdots_parsee03_dummy:RemoveOnDeath() 	return false end
function modifier_ability_thdots_parsee03_dummy:IsDebuff()			return false end

function modifier_ability_thdots_parsee03_dummy:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
end

function modifier_ability_thdots_parsee03_dummy:GetModifierAttackSpeedBonus_Constant()
	if self:GetCaster():HasModifier("modifier_ability_thdots_parseeEx_talent2") then
		return 100
	else
		return 0
	end
end

function modifier_ability_thdots_parsee03_dummy:GetModifierMoveSpeedBonus_Constant()
	if self:GetCaster():HasModifier("modifier_ability_thdots_parseeEx_talent2") then
		return 200
	else
		return 0
	end
end
function modifier_ability_thdots_parsee03_dummy:GetModifierIncomingDamage_Percentage()
	return -999
end

function modifier_ability_thdots_parsee03_dummy:OnCreated()
	if not IsServer() then return end
	self.ability = self:GetAbility()
	self.phy_int = self.ability:GetSpecialValueFor("phy_int")
	self.mag_int = self.ability:GetSpecialValueFor("mag_int")
	self.change = self.ability:GetSpecialValueFor("change")
	self.magic_damage = self.ability:GetSpecialValueFor("magic_damage")
	self.phy_damage = self.ability:GetSpecialValueFor("phy_damage")
	self.stun_time = self.ability:GetSpecialValueFor("stun_time")
	self:StartIntervalThink(0.05)
end

function modifier_ability_thdots_parsee03_dummy:OnIntervalThink()
	if not IsServer() then return end
	local dummy = self:GetParent()
	local damage_perFrameTime = dummy:GetBaseMaxHealth() / self.ability:GetSpecialValueFor("duration") * 0.05
	if dummy:GetHealth() <= 1 then
		dummy:RemoveSelf()
	else
		dummy:SetHealth(dummy:GetHealth() - damage_perFrameTime)
	end
end

function modifier_ability_thdots_parsee03_dummy:OnAttackLanded(keys)
	if not IsServer() then return end
	local caster = self:GetCaster()
	local dummy = self:GetParent()
	local ability = self:GetAbility()
	local target = keys.target
	if keys.attacker == dummy and not target:IsBuilding() then
		local int = caster:GetIntellect()
		local damage_table = {
			ability = ability,
		    victim = target,
		    attacker = caster,
		    damage = damage,
		    damage_type = ability:GetAbilityDamageType(), 
		}
		if RollPercentage(self.change) then
			UtilStun:UnitStunTarget(caster,target,self.stun_time)
		end
		damage_table.damage = self.phy_damage + int*self.phy_int
		damage_table.damage_type = DAMAGE_TYPE_PHYSICAL
		UnitDamageTarget(damage_table)

		damage_table.damage = self.magic_damage + int*self.mag_int
		damage_table.damage_type = DAMAGE_TYPE_MAGICAL
		UnitDamageTarget(damage_table)
	end
end

function modifier_ability_thdots_parsee03_dummy:OnDestroy()
	if not IsServer() then return end
	local unit = self:GetParent()
	--死亡特效音效

	unit:RemoveSelf()
end
function modifier_ability_thdots_parsee03_dummy:CheckState()
	return {
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		-- [MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}
end

--------------------------------------------------------
--恨符「丑时参拜第七日」
--------------------------------------------------------

ability_thdots_parsee04 = {}

function ability_thdots_parsee04:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("cast_range")
end

function ability_thdots_parsee04:OnSpellStart()
	if not IsServer() then return end
	local caster 				= self:GetCaster()
	local target 				= self:GetCursorTarget()
	local point 				= self:GetCursorTarget():GetOrigin()
	local duration 				= self:GetSpecialValueFor("duration")
	local health 				= self:GetSpecialValueFor("health")
	local relive_range 			= self:GetSpecialValueFor("relive_range")
	if is_spell_blocked(target) then return end
	--创建诅咒人偶
	local dummy = CreateUnitByName("npc_ability_parsee04_dummy", 
	    	                        caster:GetOrigin(), 
									false, 
								    caster, 
									caster, 
									caster:GetTeamNumber()
									)
	FindClearSpaceForUnit(dummy, Vector(point.x,point.y,point.z),true)
	self.dummy = dummy
	self.point = point
	dummy:SetBaseMaxHealth(health)
	if FindTelentValue(caster,"special_bonus_unique_parsee_2") ~= 0 then
		dummy:SetBaseMaxHealth(health + FindTelentValue(caster,"special_bonus_unique_parsee_2"))
	end
	dummy:SetDayTimeVisionRange(relive_range)
	dummy:SetNightTimeVisionRange(relive_range)
	dummy:AddNewModifier(caster, self, "modifier_ability_thdots_parsee04_dummy", {duration = duration})
	dummy.targets_modifier = {}
	local target_number = 1
	if FindTelentValue(caster,"special_bonus_unique_parsee_6") ~= 0 then
		local targets = FindUnitsInRadius(caster:GetTeam(), dummy:GetAbsOrigin(), nil, relive_range,
					self:GetAbilityTargetTeam(),self:GetAbilityTargetType(),0,0,false)
		for _,victim in pairs (targets) do
			if victim:IsRealHero() and victim ~= target then
				local target_modifier = victim:AddNewModifier(caster, self, "modifier_ability_thdots_parsee04_target", {duration = duration})
				dummy.targets_modifier[target_number] = target_modifier
				target_number = target_number + 1
				victim:EmitSound("Voice_Thdots_Parsee.AbilityParsee04_Target")
			end
		end
	end
	--音效
	dummy:EmitSound("Voice_Thdots_Parsee.AbilityParsee04_Cast")
	caster:EmitSound("Voice_Thdots_Parsee.AbilityParsee04_Caster")
	target:EmitSound("Voice_Thdots_Parsee.AbilityParsee04_Target")
end

modifier_ability_thdots_parsee04_dummy = {}
LinkLuaModifier("modifier_ability_thdots_parsee04_dummy","scripts/vscripts/abilities/abilityparsee.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_parsee04_dummy:IsHidden() 		return false end
function modifier_ability_thdots_parsee04_dummy:IsPurgable()		return false end
function modifier_ability_thdots_parsee04_dummy:RemoveOnDeath() 	return true end
function modifier_ability_thdots_parsee04_dummy:IsDebuff()		return false end

function modifier_ability_thdots_parsee04_dummy:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_STUNNED] = true,
	}
end

function modifier_ability_thdots_parsee04_dummy:OnCreated()
	if not IsServer() then return end
	self.caster 		= self:GetCaster()
	self.target 		= self:GetAbility():GetCursorTarget()
	self.ability		= self:GetAbility()
	self.dummy 			= self.ability.dummy
	self.stun_time  	= self.ability:GetSpecialValueFor("stun_time")
	self.damage_bonus  	= self.ability:GetSpecialValueFor("damage_bonus")
	self.damage  		= self.ability:GetSpecialValueFor("damage")
	self.relive_range  	= self.ability:GetSpecialValueFor("relive_range")

	--特效音效
	local particle = "particles/units/heroes/hero_pugna/pugna_ward_ambient.vpcf"
	self.parsee04_particle = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN, self.dummy)
	-- ParticleManager:SetParticleControlEnt(self.parsee04_particle, 3, self.dummy, 0, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControl(self.parsee04_particle, 0, self.dummy:GetAbsOrigin())

	local particle_2 = "particles/units/heroes/hero_pugna/pugna_life_give.vpcf"
	local particle_3 = "particles/units/heroes/hero_pugna/pugna_life_give.vpcf"
	local particle_4 = "particles/econ/items/pugna/pugna_ti9_immortal/pugna_ti9_immortal_netherblast_pre_ring.vpcf"
	if self:GetStackCount() ~= 1 then
		self.parsee04_particle_2 = ParticleManager:CreateParticle(particle_2, PATTACH_CUSTOMORIGIN, self.dummy)
		ParticleManager:SetParticleControlEnt(self.parsee04_particle_2, 0, self.caster, 5, "attach_hitloc", Vector(0,0,0), true)
		ParticleManager:SetParticleControlEnt(self.parsee04_particle_2, 1, self.dummy, 5, "attach_hitloc", Vector(0,0,0), true)
		self:SetStackCount(1)
	end
	self.parsee04_particle_3 = ParticleManager:CreateParticle(particle_3, PATTACH_CUSTOMORIGIN, self.dummy)
	ParticleManager:SetParticleControlEnt(self.parsee04_particle_3, 0, self.dummy, 5, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(self.parsee04_particle_3, 1, self.target, 5, "attach_hitloc", Vector(0,0,0), true)
	-- ParticleManager:SetParticleControl(self.parsee04_particle_3, 0, self.dummy:GetAbsOrigin())
	-- ParticleManager:SetParticleControl(self.parsee04_particle_3, 1, self.target:GetAbsOrigin())
	self.parsee04_particle_4 = ParticleManager:CreateParticle(particle_4, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(self.parsee04_particle_4, 0, self.dummy:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.parsee04_particle_4, 1, Vector(self.relive_range,1,1))
	ParticleManager:ReleaseParticleIndex(self.parsee04_particle_4)
	-- ParticleManager:SetParticleControlEnt(self.parsee04_particle_3, 0, self.dummy, 5, "attach_hitloc", Vector(0,0,0), true)
	self.dummy:EmitSound("Voice_Thdots_Parsee.AbilityParsee04_Loop")

	self:StartIntervalThink(FrameTime())
end

function modifier_ability_thdots_parsee04_dummy:OnIntervalThink()
	if not IsServer() then return end
	--特效
	local particle_4 = "particles/econ/items/pugna/pugna_ti9_immortal/pugna_ti9_immortal_netherblast_pre_ring.vpcf"
	local parsee04_particle_4 = ParticleManager:CreateParticle(particle_4, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(parsee04_particle_4, 0, self.dummy:GetAbsOrigin())
	ParticleManager:SetParticleControl(parsee04_particle_4, 1, Vector(self.relive_range,self.relive_range,self.relive_range))
	ParticleManager:DestroyParticleSystemTime(parsee04_particle_4,0.3)

	--给予视野
	AddFOWViewer(self.caster:GetTeamNumber(), self.target:GetOrigin(),128,FrameTime(), false)
	AddFOWViewer(self.target:GetTeamNumber(), self.caster:GetOrigin(),128,FrameTime(), false)
	AddFOWViewer(self.target:GetTeamNumber(), self.dummy:GetOrigin(),128,FrameTime(), false)
	local vec = self.ability.point
	vec.z = 400
	self.dummy:SetOrigin(vec)
	local caster_distance = (self.caster:GetOrigin() - self.dummy:GetOrigin()):Length2D()
	local target_distance = (self.target:GetOrigin() - self.dummy:GetOrigin()):Length2D()
	if caster_distance > self.relive_range or target_distance > self.relive_range or not self.caster:IsAlive() then
		self:Destroy()
	end
end


function modifier_ability_thdots_parsee04_dummy:OnDestroy()
	if not IsServer() then return end
	local damage = self.damage
	if self:GetRemainingTime() >= 0 then --时间未结束
		local particle = "particles/econ/items/antimage/antimage_weapon_basher_ti5/antimage_manavoid_ti_5.vpcf"
		local parsee04_particle_noact = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN_FOLLOW, self.target)
		ParticleManager:SetParticleControl(parsee04_particle_noact, 0, self.target:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(parsee04_particle_noact)
		self.target:EmitSound("Voice_Thdots_Parsee.AbilityParsee04_Damage_1")
		local damage_table = {
					ability = self.ability,
				    victim = self.target,
				    attacker = self.caster,
				    damage = damage,
				    damage_type = self.ability:GetAbilityDamageType(), 
					damage_flags = 0
				}
		UnitDamageTarget(damage_table)
	else 								 --时间结束
		local particle = "particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/antimage_manavoid_ti_5_gold.vpcf"
		local parsee04_particle_noact = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN_FOLLOW, self.target)
		ParticleManager:SetParticleControl(parsee04_particle_noact, 0, self.target:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(parsee04_particle_noact)
		self.target:EmitSound("Voice_Thdots_Parsee.AbilityParsee04_Damage_2")
		local damage_table = {
					ability = self.ability,
				    victim = self.target,
				    attacker = self.caster,
				    damage = damage,
				    damage_type = self.ability:GetAbilityDamageType(), 
					damage_flags = 0
				}
		for i=1,#self.dummy.targets_modifier do
			if not self.dummy.targets_modifier[i]:IsNull() then
				self.dummy.targets_modifier[i]:SetStackCount(1)
			end
		end
		damage_table.damage = self.damage * self.damage_bonus
		UtilStun:UnitStunTarget(self.caster,self.target,self.stun_time)
		UnitDamageTarget(damage_table)
	end
	--特效音效结束
	ParticleManager:ReleaseParticleIndex(self.parsee04_particle)
	ParticleManager:ReleaseParticleIndex(self.parsee04_particle_2)
	ParticleManager:ReleaseParticleIndex(self.parsee04_particle_3)
	self.dummy:StopSound("Voice_Thdots_Parsee.AbilityParsee04_Loop")
	for i=1,#self.dummy.targets_modifier do
		if not self.dummy.targets_modifier[i]:IsNull() then
			self.dummy.targets_modifier[i]:Destroy()
		end
	end
	self:GetParent():RemoveSelf()
end

modifier_ability_thdots_parsee04_target = {}
LinkLuaModifier("modifier_ability_thdots_parsee04_target","scripts/vscripts/abilities/abilityparsee.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_parsee04_target:IsHidden() 		return false end
function modifier_ability_thdots_parsee04_target:IsPurgable()		return true end
function modifier_ability_thdots_parsee04_target:RemoveOnDeath() 	return true end
function modifier_ability_thdots_parsee04_target:IsDebuff()		return true end

function modifier_ability_thdots_parsee04_target:OnCreated()
	if not IsServer() then return end
	self.caster 		= self:GetCaster()
	self.target 		= self:GetParent()
	self.ability		= self:GetAbility()
	self.dummy 			= self.ability.dummy
	self.stun_time  	= self.ability:GetSpecialValueFor("stun_time")
	self.damage_bonus  	= self.ability:GetSpecialValueFor("damage_bonus")
	self.damage  		= self.ability:GetSpecialValueFor("damage")
	self.relive_range  	= self.ability:GetSpecialValueFor("relive_range")

	--特效音效
	local particle_target_1 = "particles/econ/items/pugna/pugna_ti10_immortal/pugna_ti10_immortal_life_drain_gold.vpcf"
	local particle_target_2 = "particles/econ/items/pugna/pugna_ti10_immortal/pugna_ti10_immortal_life_drain.vpcf"
	local particle_target_3 = "particles/econ/items/pugna/pugna_ti10_immortal/pugna_ti10_immortal_life_give.vpcf"
	local particle_3 = particle_target_1
	local random = RandomInt(1,3)
	if random == 1 then
		particle_3 = particle_target_1
	elseif random == 2 then
		particle_3 = particle_target_2
	else
		particle_3 = particle_target_3
	end
	self.parsee04_particle_target = ParticleManager:CreateParticle(particle_3, PATTACH_CUSTOMORIGIN, self.dummy)
	ParticleManager:SetParticleControlEnt(self.parsee04_particle_target, 0, self.dummy, 5, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(self.parsee04_particle_target, 1, self.target, 5, "attach_hitloc", Vector(0,0,0), true)

	self.target:EmitSound("Voice_Thdots_Parsee.AbilityParsee04_Loop")
	self:StartIntervalThink(FrameTime())
end

function modifier_ability_thdots_parsee04_target:OnIntervalThink()
	if not IsServer() then return end
	--给予视野
	if self.dummy:IsNull() then return end
	AddFOWViewer(self.caster:GetTeamNumber(), self.target:GetOrigin(),128,FrameTime(), false)
	AddFOWViewer(self.target:GetTeamNumber(), self.caster:GetOrigin(),128,FrameTime(), false)
	AddFOWViewer(self.target:GetTeamNumber(), self.dummy:GetOrigin(),128,FrameTime(), false)

	local caster_distance = (self.caster:GetOrigin() - self.dummy:GetOrigin()):Length2D()
	local target_distance = (self.target:GetOrigin() - self.dummy:GetOrigin()):Length2D()
	if caster_distance > self.relive_range or target_distance > self.relive_range or not self.caster:IsAlive() then
		self:Destroy()
	end
end


function modifier_ability_thdots_parsee04_target:OnDestroy()
	if not IsServer() then return end
	local damage = self.damage
	-- print("self:GetRemainingTime()")
	-- print(self:GetRemainingTime())
	-- print(self:GetStackCount())
	if self:GetRemainingTime() >= 0 and self:GetStackCount() ~= 1 then --时间未结束
		local particle = "particles/econ/items/antimage/antimage_weapon_basher_ti5/antimage_manavoid_ti_5.vpcf"
		local parsee04_particle_noact = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN_FOLLOW, self.target)
		ParticleManager:SetParticleControl(parsee04_particle_noact, 0, self.target:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(parsee04_particle_noact)
		self.target:EmitSound("Voice_Thdots_Parsee.AbilityParsee04_Damage_1")
		local damage_table = {
					ability = self.ability,
				    victim = self.target,
				    attacker = self.caster,
				    damage = damage,
				    damage_type = self.ability:GetAbilityDamageType(), 
					damage_flags = 0
				}
		UnitDamageTarget(damage_table)
	else  --时间结束
		local particle = "particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/antimage_manavoid_ti_5_gold.vpcf"
		local parsee04_particle_noact = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN_FOLLOW, self.target)
		ParticleManager:SetParticleControl(parsee04_particle_noact, 0, self.target:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(parsee04_particle_noact)
		self.target:EmitSound("Voice_Thdots_Parsee.AbilityParsee04_Damage_2")
		local damage_table = {
					ability = self.ability,
				    victim = self.target,
				    attacker = self.caster,
				    damage = damage,
				    damage_type = self.ability:GetAbilityDamageType(), 
					damage_flags = 0
				}
		damage_table.damage = self.damage * self.damage_bonus
		UtilStun:UnitStunTarget(self.caster,self.target,self.stun_time)
		UnitDamageTarget(damage_table)
	end
	--特效音效结束
	ParticleManager:DestroyParticleSystem(self.parsee04_particle_target,true)
	self.target:StopSound("Voice_Thdots_Parsee.AbilityParsee04_Loop")
end
