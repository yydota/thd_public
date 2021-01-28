if AbilityMarisa == nil then
	AbilityMarisa = class({})
end

function OnMarisa01SpellStart(keys)
	AbilityMarisa:OnMarisa01Start(keys)
end

function OnMarisa01SpellMove(keys)
	AbilityMarisa:OnMarisa01Move(keys)
end

function OnMarisa02SpellStart(keys)
	AbilityMarisa:OnMarisa02Start(keys)
end
function OnMarisa02SpellDamage(keys)
	AbilityMarisa:OnMarisa02Damage(keys)
end
function OnMarisa02SpellRemove(keys)
	--[[local caster = EntIndexToHScript(keys.caster_entindex)
	local unitIndex = keys.ability:GetContext("ability_marisa02_effectUnit")
	local unit = EntIndexToHScript(unitIndex)
	if(unit~=nil)then
		Timer.Wait 'ability_marisa02_effectUnit_release' (0.5,
			function()
				if(unit~=nil)then
					unit:RemoveSelf()
				end
			end
	    )
	end]]--
end

function OnMarisa03SpellStart(keys)
	AbilityMarisa:OnMarisa03Start(keys)
end

function OnMarisa03SpellThink(keys)
	AbilityMarisa:OnMarisa03Think(keys)
end

function OnMarisa03DealDamage(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local dealdamage
	if keys.unit:IsBuilding() then
		dealdamage = keys.DealDamage * 0.8
	else
		dealdamage = keys.DealDamage
	end
	local damage_table = {
		ability = keys.ability,
		victim = keys.unit,
		attacker = caster.hero,
		damage = dealdamage * (1+FindTelentValue(caster.hero,"special_bonus_unique_crystal_maiden_1")),
		damage_type = keys.ability:GetAbilityDamageType(), 
	    damage_flags = keys.ability:GetAbilityTargetFlags()
	}
	UnitDamageTarget(damage_table) 
end

function OnMarisa04SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local targetPoint = keys.target_points[1]

print("do it")
	local particle_name = "particles/units/heroes/hero_windrunner/windrunner_windrun_beam.vpcf"
		-- local particle_name = "particles/econ/items/windrunner/windranger_arcana/windranger_arcana_debut_ambient_v2.vpcf"
	local marisaEx_particle = ParticleManager:CreateParticle(particle_name, PATTACH_OVERHEAD_FOLLOW, caster)
		-- marisaEx_particle = ParticleManager:CreateParticle(particle_name, PATTACH_CUSTOMORIGIN_FOLLOW, caster)
		-- marisaEx_particle = ParticleManager:CreateParticle(particle_name, PATTACH_POINT_FOLLOW, caster)
		-- ParticleManager:SetParticleControlEnt(marisaEx_particle , 0, caster, 5, "attach_hitloc", Vector(0,0,0), true)
		ParticleManager:ReleaseParticleIndex(marisaEx_particle)
	
	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_crystal_maiden_2"))

	local unit = CreateUnitByName(
		"npc_dota2x_unit_marisa04_spark"
		,caster:GetOrigin()
		,false
		,caster
		,caster
		,caster:GetTeam()
	)
	local ability_dummy_unit = unit:FindAbilityByName("ability_dummy_unit")
	ability_dummy_unit:SetLevel(1)
	
	caster.effectcircle = ParticleManager:CreateParticle("particles/heroes/marisa/marisa_04_spark_circle.vpcf", PATTACH_CUSTOMORIGIN, unit)
	ParticleManager:DestroyParticleSystem(caster.effectcircle,false)
	caster.effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/marisa/marisa_04_spark.vpcf", PATTACH_CUSTOMORIGIN, unit)
	ParticleManager:DestroyParticleSystem(caster.effectIndex,false)
	caster.effectIndex_b = ParticleManager:CreateParticle("particles/thd2/heroes/marisa/marisa_04_spark_wind_b.vpcf", PATTACH_CUSTOMORIGIN, unit)
	ParticleManager:DestroyParticleSystem(caster.effectIndex_b,false)
	keys.ability:SetContextNum("ability_marisa_04_spark_unit",unit:GetEntityIndex(),0)

	MarisaSparkParticleControl(caster,targetPoint,keys.ability)
	keys.ability:SetContextNum("ability_marisa_04_spark_lock",FALSE,0)
end

function MarisaSparkParticleControl(caster,targetPoint,ability)
	local unitIndex = ability:GetContext("ability_marisa_04_spark_unit")
	local unit = EntIndexToHScript(unitIndex)

	if(caster.targetPoint == targetPoint)then
		return
	else
		caster.targetPoint = targetPoint
	end

	if(caster.effectIndex_b ~= -1)then
		ParticleManager:DestroyParticleSystem(caster.effectIndex_b,true)
	end

	if(unit == nil or caster.effectIndex == -1 or caster.effectcircle == -1)then
		print(unit)
		print(caster.effectIndex)
		print(caster.effectcircle)
		return
	end

	caster.effectIndex_b = ParticleManager:CreateParticle("particles/thd2/heroes/marisa/marisa_04_spark_wind_b.vpcf", PATTACH_CUSTOMORIGIN, unit)

	forwardRad = GetRadBetweenTwoVec2D(targetPoint,caster:GetOrigin()) 
	vecForward = Vector(math.cos(math.pi/2 + forwardRad),math.sin(math.pi/2 + forwardRad),0)
	unit:SetForwardVector(vecForward)
	vecUnit = caster:GetOrigin() + Vector(caster:GetForwardVector().x * 100,caster:GetForwardVector().y * 100,160)
	vecColor = Vector(255,255,255)
	unit:SetOrigin(vecUnit)

	ParticleManager:SetParticleControl(caster.effectcircle, 0, caster:GetOrigin())
	
	local effect2ForwardRad = GetRadBetweenTwoVec2D(caster:GetOrigin(),targetPoint) 
	local effect2VecForward = Vector(math.cos(effect2ForwardRad)*850,math.sin(effect2ForwardRad)*850,0) + caster:GetOrigin() + Vector(caster:GetForwardVector().x * 100,caster:GetForwardVector().y * 100,108)
	
	ParticleManager:SetParticleControl(caster.effectIndex, 0, caster:GetOrigin() + Vector(caster:GetForwardVector().x * 92,caster:GetForwardVector().y * 92,150))
	ParticleManager:SetParticleControl(caster.effectIndex, 1, effect2VecForward)
	ParticleManager:SetParticleControl(caster.effectIndex, 2, vecColor)
	local forwardRadwind = forwardRad + math.pi
	ParticleManager:SetParticleControl(caster.effectIndex, 8, Vector(math.cos(forwardRadwind),math.sin(forwardRadwind),0))
	ParticleManager:SetParticleControl(caster.effectIndex, 9, caster:GetOrigin() + Vector(caster:GetForwardVector().x * 100,caster:GetForwardVector().y * 100,108))

	ParticleManager:SetParticleControl(caster.effectIndex_b, 0, caster:GetOrigin() + Vector(caster:GetForwardVector().x * 92,caster:GetForwardVector().y * 92,150))
	ParticleManager:SetParticleControl(caster.effectIndex_b, 8, Vector(math.cos(forwardRadwind),math.sin(forwardRadwind),0))
	ParticleManager:DestroyParticleSystem(caster.effectIndex_b,false)
end


function OnMarisa04SpellThink(keys)
	if(keys.ability:GetContext("ability_marisa_04_spark_lock")==FALSE)then
		AbilityMarisa:OnMarisa04Think(keys)
	end
end

function OnMarisa04SpellRemove(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local unitIndex = keys.ability:GetContext("ability_marisa_04_spark_unit")

	local unit = EntIndexToHScript(unitIndex)
	if(unit~=nil)then
		unit:RemoveSelf()
		caster.effectcircle = -1
		caster.effectIndex = -1
	end
	keys.ability:SetContextNum("ability_marisa_04_spark_lock",TRUE,0)
end

function AbilityMarisa:OnMarisa01Start(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_crystal_maiden_4"))
	-- local targetPoint  = CastRang_Calculate(caster,keys.target_points[1],keys.ability:GetSpecialValueFor("cast_range"))
	local targetPoint = keys.target_points[1]
	local range = keys.ability:GetSpecialValueFor("cast_range")
	local distance = ( targetPoint - caster:GetOrigin() ):Length2D()
	if distance >= range then
		targetPoint = caster:GetOrigin() + ( targetPoint - caster:GetOrigin() ):Normalized() * range 
	end
	local marisa01rad = GetRadBetweenTwoVec2D(caster:GetOrigin(),targetPoint)
	local marisa01dis = GetDistanceBetweenTwoVec2D(caster:GetOrigin(),targetPoint)
	keys.ability:SetContextNum("ability_marisa01_Rad",marisa01rad,0)
	keys.ability:SetContextNum("ability_marisa01_Dis",marisa01dis,0)
	--local marisa01time = marisa01dis/1250
	--UnitPauseTarget(caster,caster,marisa01time)
end

function AbilityMarisa:OnMarisa01Move(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targets = keys.target_entities
	for _,v in pairs(targets) do
		if(v:GetContext("ability_marisa01_damage")==nil)then
			v:SetContextNum("ability_marisa01_damage",TRUE,0)
		end
		if(v:GetContext("ability_marisa01_damage")==TRUE)then
			local damage_table = {
				ability = keys.ability,
			    victim = v,
			    attacker = caster,
			    damage = keys.ability:GetAbilityDamage(),
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
		    }
		    UnitDamageTarget(damage_table)
			v:SetContextNum("ability_marisa01_damage",FALSE,0)
			Timer.Wait 'ability_marisa01_damage_timer' (0.7,
			function()
				v:SetContextNum("ability_marisa01_damage",TRUE,0)
			end
	    	)
		end
	end
	local marisa01rad = keys.ability:GetContext("ability_marisa01_Rad")
	local vec = Vector(vecCaster.x+math.cos(marisa01rad)*keys.MoveSpeed/50,vecCaster.y+math.sin(marisa01rad)*keys.MoveSpeed/50,vecCaster.z)
	caster:SetOrigin(vec)
	local marisa01dis = keys.ability:GetContext("ability_marisa01_Dis")
	if(marisa01dis<0)then
		SetTargetToTraversable(caster)
		keys.ability:SetContextNum("ability_marisa01_Dis",0,0)
		caster:RemoveModifierByName("modifier_thdots_marisa01_think_interval")
	else
	    marisa01dis = marisa01dis - keys.MoveSpeed/50
	    keys.ability:SetContextNum("ability_marisa01_Dis",marisa01dis,0)
	end
end

function AbilityMarisa:OnMarisa02Start(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local targetPoint = keys.target_points[1]
	keys.ability:SetContextNum("ability_marisa02_point_x",targetPoint.x,0)
	keys.ability:SetContextNum("ability_marisa02_point_y",targetPoint.y,0)
	keys.ability:SetContextNum("ability_marisa02_point_z",targetPoint.z,0)
	local unit = CreateUnitByName(
		"npc_dummy_unit"
		,caster:GetOrigin()
		,false
		,caster
		,caster
		,caster:GetTeam()
	)
	keys.ability:SetContextNum("ability_marisa02_effectUnit",unit:GetEntityIndex(),0)

	unit:SetContextThink("ability_marisa02_effect_remove", 
		function()
			if GameRules:IsGamePaused() then return 0.03 end
			unit:RemoveSelf()
			return nil
		end, 
	1) 
end

function AbilityMarisa:OnMarisa02Damage(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targetPoint = Vector(keys.ability:GetContext("ability_marisa02_point_x"),keys.ability:GetContext("ability_marisa02_point_y"),keys.ability:GetContext("ability_marisa02_point_z"))
	local targets = keys.target_entities
	
	local unitIndex = keys.ability:GetContext("ability_marisa02_effectUnit")
	local unit = EntIndexToHScript(unitIndex)
	local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/marisa/marisa_02_stars.vpcf", PATTACH_CUSTOMORIGIN, unit)
	local vecForward = Vector(500 * caster:GetForwardVector().x,500 * caster:GetForwardVector().y,caster:GetForwardVector().z)
	ParticleManager:SetParticleControl(effectIndex, 0, caster:GetOrigin()+caster:GetForwardVector()*100)
	ParticleManager:SetParticleControl(effectIndex, 3, vecForward)
	ParticleManager:DestroyParticleSystem(effectIndex,false)
	
	-- Ñ­»µ¸÷¸öÄ¿±êµ¥Î»
	for _,v in pairs(targets) do
		local vVec = v:GetOrigin()
		local vecRad = GetRadBetweenTwoVec2D(targetPoint,vecCaster)
		local vDistance = GetDistanceBetweenTwoVec2D(vVec,vecCaster)

		if(IsPointInCircularSector(vVec.x,vVec.y,math.cos(vecRad),math.sin(vecRad),keys.DamageRadius,math.pi/3,vecCaster.x,vecCaster.y))then
			local deal_damage = (keys.ability:GetAbilityDamage()+FindTelentValue(caster,"special_bonus_unique_crystal_maiden_3"))/5
			if(vDistance<460)then
				deal_damage = deal_damage *2
			end
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
	end
end

function AbilityMarisa:OnMarisa03Start(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local duration = keys.AbilityDuration + FindTelentValue(caster,"special_bonus_unique_crystal_maiden_1")
	self.Marisa03Stars = {}
	for i = 0,3 do
		local vec = Vector(caster:GetOrigin().x + math.cos(i*math. pi/2) * 150,caster:GetOrigin().y + math.sin(i*math.pi/2) * 150,caster:GetOrigin().z + 300)
		local unit = CreateUnitByName(
		"npc_thdots_unit_marisa03_star"
		,vec
		,false
		,caster
		,caster
		,caster:GetTeam()
		)
		unit:SetContextNum("ability_marisa03_unit_rad",GetRadBetweenTwoVec2D(caster:GetOrigin(),vec),0)
		unit.hero = caster
		unitAbility = unit:FindAbilityByName("ability_thdots_marisa03_dealdamage")
		unitAbility:SetLevel(keys.ability:GetLevel())

		local ability_dummy_unit = unit:FindAbilityByName("ability_dummy_unit")
		ability_dummy_unit:SetLevel(1)
		--unit:SetBaseDamageMax(keys.ability:GetAbilityDamage())
		--unit:SetBaseDamageMin(keys.ability:GetAbilityDamage())
		local effectIndex
		if(i==0)then
			effectIndex = ParticleManager:CreateParticle("particles/heroes/marisa/marisa_03_stars.vpcf", PATTACH_CUSTOMORIGIN, unit)
		elseif(i==1)then
			effectIndex = ParticleManager:CreateParticle("particles/heroes/marisa/marisa_03_stars_b.vpcf", PATTACH_CUSTOMORIGIN, unit)
		elseif(i==2)then
			effectIndex = ParticleManager:CreateParticle("particles/heroes/marisa/marisa_03_stars_c.vpcf", PATTACH_CUSTOMORIGIN, unit)
		elseif(i==3)then
			effectIndex = ParticleManager:CreateParticle("particles/heroes/marisa/marisa_03_stars_d.vpcf", PATTACH_CUSTOMORIGIN, unit)
		end
		ParticleManager:SetParticleControlEnt(effectIndex , 0, unit, 5, "follow_origin", Vector(0,0,0), true)

		-- Timer.Wait 'ability_marisa03_star_release' (duration,
		-- 	function()
		-- 		unit:ForceKill(true)
		-- 		unit:AddNoDraw()
		-- 		caster:RemoveModifierByName("modifier_thdots_marisa03_think_interval")
		-- 	end
		--    )
		unit:AddNewModifier(caster,keys.ability,"modifier_thdots_marisa03_unit_death",{duration = duration})
		table.insert(self.Marisa03Stars,unit)
	end
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_marisa03_think_interval", {Duration = duration})
end

modifier_thdots_marisa03_unit_death = {}
LinkLuaModifier("modifier_thdots_marisa03_unit_death","scripts/vscripts/abilities/abilityMarisa.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_thdots_marisa03_unit_death:IsHidden() 		return false end
function modifier_thdots_marisa03_unit_death:IsPurgable()		return false end
function modifier_thdots_marisa03_unit_death:RemoveOnDeath() 	return true end
function modifier_thdots_marisa03_unit_death:IsDebuff()		return false end
function modifier_thdots_marisa03_unit_death:OnDestroy()
	if not IsServer() then return end
	self:GetParent():ForceKill(true)
	self:GetParent():AddNoDraw()
end



function AbilityMarisa:OnMarisa03Think(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vCaster = caster:GetOrigin()
	local stars = self.Marisa03Stars
	for _,v in pairs(stars) do
		local vVec = v:GetOrigin()
		local turnRad = v:GetContext("ability_marisa03_unit_rad") + math.pi/120
		v:SetContextNum("ability_marisa03_unit_rad",turnRad,0)
		local turnVec = Vector(vCaster.x + math.cos(turnRad) * 150,vCaster.y + math.sin(turnRad) * 150,vCaster.z + 300)
		v:SetOrigin(turnVec)
	end
end

function AbilityMarisa:OnMarisa04Think(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targetPoint =  vecCaster + caster:GetForwardVector() --keys.target_points[1]
	local sparkRad = GetRadBetweenTwoVec2D(vecCaster,targetPoint)
	local findVec = Vector(vecCaster.x + math.cos(sparkRad) * keys.DamageLenth/2,vecCaster.y + math.sin(sparkRad) * keys.DamageLenth/2,vecCaster.z)
	local findRadius = math.sqrt(((keys.DamageLenth/2)*(keys.DamageLenth/2) + (keys.DamageWidth/2)*(keys.DamageWidth/2)))
	local DamageTargets = FindUnitsInRadius(
		   caster:GetTeam(),		--caster team
		   findVec,		            --find position
		   nil,					    --find entity
		   findRadius,		        --find radius
		   DOTA_UNIT_TARGET_TEAM_ENEMY,
		   keys.ability:GetAbilityTargetType(),
		   0, FIND_CLOSEST,
		   false
	    )
	for _,v in pairs(DamageTargets) do
		local vecV = v:GetOrigin()
		if(IsRadInRect(vecV,vecCaster,keys.DamageWidth,keys.DamageLenth,sparkRad))then
			local deal_damage = keys.ability:GetAbilityDamage()/20
			if(IsRadInRect(vecV,vecCaster,200,keys.DamageLenth,sparkRad))then
				deal_damage = deal_damage * 2
			end
			local damage_table = {
				ability = keys.ability,
				victim = v,
				attacker = caster,
				damage = deal_damage,
				damage_type = keys.ability:GetAbilityDamageType(), 
				damage_flags = 0
			}
			UnitDamageTarget(damage_table)
			UtilStun:UnitStunTarget(caster,v,0.2)
		end
	end
	MarisaSparkParticleControl(caster,targetPoint,keys.ability)
end

function OnMarisawanbaocuiExThink(keys)
	local caster = keys.caster
	local ability = keys.ability	
	local mana = caster:GetMana()
	local max_mana = caster:GetMaxMana()
	local stack_count = math.floor(( mana / max_mana ) * 100 )

	if caster:HasModifier("modifier_item_wanbaochui") then			
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_marisa_wanbaochui_buff", {})
	else
		caster:RemoveModifierByName("modifier_marisa_wanbaochui_buff")	
	end
	caster:SetModifierStackCount("modifier_marisa_wanbaochui_buff", ability, stack_count)
	
end

ability_thdots_marisaEx = {}

function ability_thdots_marisaEx:GetIntrinsicModifierName()
    return "ability_thdots_marisaEx_passive"
end

ability_thdots_marisaEx_passive = {}
LinkLuaModifier("ability_thdots_marisaEx_passive","scripts/vscripts/abilities/abilityMarisa.lua",LUA_MODIFIER_MOTION_NONE)
function ability_thdots_marisaEx_passive:IsHidden()
	if self:GetStackCount() ~= 1 then
		return false 
	else
		return true
	end
end
function ability_thdots_marisaEx_passive:IsPurgable()      return false end
function ability_thdots_marisaEx_passive:RemoveOnDeath()   return false end
function ability_thdots_marisaEx_passive:IsDebuff()        return false end

function ability_thdots_marisaEx_passive:OnCreated()
    if not IsServer() then return end
    self.caster 				= self:GetCaster()
    self.ability 				= self:GetAbility()
    self.refresh_interval		= self.ability:GetSpecialValueFor("refresh_interval")
    self.refresh_time 			= self.ability:GetSpecialValueFor("refresh_time")
    self.refresh_time_ult 		= self.ability:GetSpecialValueFor("refresh_time_ult")
    self.react_time	= 0

    self:SetStackCount(1)
    self:StartIntervalThink(FrameTime())
end

function ability_thdots_marisaEx_passive:OnIntervalThink()
    if not IsServer() then return end
    if self.react_time <= self.refresh_interval and self:GetStackCount() ~= 0 then
    	self.react_time = self.react_time + FrameTime()
    elseif self.react_time > self.refresh_interval and self:GetStackCount() ~= 0 then
    	self.caster:EmitSound("Voice_Thdots_Marisa.AbilityMarisaEx")
    	local particle_name = "particles/units/heroes/hero_windrunner/windrunner_windrun_beam.vpcf"
		local marisaEx_particle = ParticleManager:CreateParticle(particle_name, PATTACH_OVERHEAD_FOLLOW, self.caster)
		ParticleManager:ReleaseParticleIndex(marisaEx_particle)
    	self:SetStackCount(0)
    end
end

function ability_thdots_marisaEx_passive:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	}
end

function ability_thdots_marisaEx_passive:OnAbilityExecuted(keys)
	if not IsServer() then return end
	local caster = self:GetParent()
	local ability = keys.ability
	if keys.unit ~= caster or ability:IsItem() then return end
	
	self.react_time = 0
	if self:GetStackCount() ~= 1 then
		print("do is")
		if ability:GetAbilityType() == 1 then
			caster:SetContextThink("marisaEx", function ()
				THDReduceCooldown(ability,-self.refresh_time_ult)
				print(ability:GetCooldownTimeRemaining())
			end, FrameTime())
		else
			caster:SetContextThink("marisaEx", function ()
				THDReduceCooldown(ability,-self.refresh_time)
				print(ability:GetCooldownTimeRemaining())
			end, FrameTime())
		end
		self:SetStackCount(1)
	end
end
