MARGATROID_ABILITYEX_DOLL_UNITNAME="ability_margatroidex_doll"
MARGATROID_ABILITYEX_NAME="ability_thdots_MargatroidEx"
MARGATROID_ABILITYEX_MODIFIER_TIME_TO_ADD_DOLL_NAME="modifier_thdots_margatroidex_time_to_add_doll"
MARGATROID_ABILITYEX_MODIFIER_DOLL_NAME="modifier_thdots_margatroidex_doll"
MARGATROID_ABILITYEX_MODIFIER_DOLL_LOST_NAME="modifier_thdots_margatroidex_doll_lost"
MARGATROID_ABILITYEX_MODIFIER_DOLL_RECOVERING_NAME="modifier_thdots_margatroidex_doll_recovering"
MARGATROID_ABILITYEX_MODIFIER_DOLL_COUNT_NAME="modifier_thdots_margatroidex_doll_count"
MARGATROID_ABILITYEX_MODIFIER_DOLL_TOTAL_COUNT_NAME="modifier_thdots_margatroidex_doll_total_count"
MARGATROID_ABILITYEX_MODIFIER_RESET_DOLL_NAME="modifier_thdots_margatroidex_reset_doll"
MARGATROID_ABILITY03_DOLL_UNITNAME="ability_margatroid03_doll"
MARGATROID_ABILITY03_MODIFIER_DOLL_NAME="modifier_thdots_margatroid03_doll"
MARGATROID_ABILITY04_MODIFIER_DOLL_EXPLOSION_NAME="modifier_thdots_margatroid04_doll_explosion"

g_PlayersTotalDollNum=g_PlayersTotalDollNum or {}

function Margatroid_CreateLine(caster,doll)
	local effectIndex = ParticleManager:CreateParticle("particles/heroes/alice/ability_alice_line.vpcf", PATTACH_CUSTOMORIGIN, doll)
	ParticleManager:SetParticleControlEnt(effectIndex , 0, caster, 5, "attach_line", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effectIndex , 1, doll, 5, "attach_hitloc", Vector(0,0,0), true)
	caster.isCreatedLine = true
end

function MargatroidEx_ModifyDollCount(caster,count)
	if caster.dollcount ~= nil then
		caster.dollcount = count + caster.dollcount
	else
		caster.dollcount = 1
	end
end

function MargatroidEx_ModifyDollReset(Caster)
	local playerid=Caster:GetEntityIndex()
	Caster:SetContextThink("MargatroidEx_ModifyDollReset", 
		function ()
			if Caster.dollcount == 0 then
				g_PlayersTotalDollNum[playerid]=math.max(0,(Caster:GetLevel()-1)/2+3)
				local AbilityEx=Caster:FindAbilityByName("ability_thdots_MargatroidEx")
				AbilityEx:ApplyDataDrivenModifier(Caster,Caster,"modifier_thdots_margatroidex_doll_count",{})
				Caster:SetModifierStackCount("modifier_thdots_margatroidex_doll_count",AbilityEx,math.floor((Caster:GetLevel()-1)/2+3))
			end
			return 0.03
		end, 
	0.03)
end

function MargatroidEx_ModifyDollActionTranslate(Caster)
	local AbilityEx=Caster:FindAbilityByName(MARGATROID_ABILITYEX_NAME)
	Caster:SetContextThink("MargatroidEx_ModifyDollActionTranslate", 
		function ()
			if Caster.dollcount~= nil and Caster.isCreatedLine ~= nil then
				if Caster.dollcount > 0 and Caster.isCreatedLine == true then
					AbilityEx:ApplyDataDrivenModifier(Caster,Caster,"modifier_thdots_margatridex_line_action",{})
				else
					Caster.isCreatedLine = false
					Caster:RemoveModifierByName("modifier_thdots_margatridex_line_action")
				end
			end
			return 0.03
		end, 
	0.03)
end

function Margatroid_GetTotalDollNum(hCaster)
	local playerid=hCaster:GetEntityIndex()
	return g_PlayersTotalDollNum[playerid] or 0
end
function Margatroid_ModifyTotalDollNum(hCaster,iModifyAmount)
	local playerid=hCaster:GetEntityIndex()
	local num=g_PlayersTotalDollNum[playerid] or 0
	g_PlayersTotalDollNum[playerid]=math.max(0,num + iModifyAmount)
	--[[if hCaster.isRespawned then
		g_PlayersTotalDollNum[playerid]=math.floor((hCaster:GetLevel()-1)/2+3)
		local AbilityEx=hCaster:FindAbilityByName("ability_thdots_MargatroidEx")
		AbilityEx:ApplyDataDrivenModifier(hCaster,hCaster,"modifier_thdots_margatroidex_doll_count",{})
		hCaster:SetModifierStackCount("modifier_thdots_margatroidex_doll_count",AbilityEx,math.floor((hCaster:GetLevel()-1)/2+3))
		hCaster.isRespawned = false
	else
		g_PlayersTotalDollNum[playerid]=math.max(0,num + iModifyAmount)
	end]]--
	print("TotalDollNum:"..tostring(g_PlayersTotalDollNum[playerid]))
end
function Margatroid_GetUsableDollNum(hCaster)
	return hCaster:GetModifierStackCount(MARGATROID_ABILITYEX_MODIFIER_DOLL_COUNT_NAME,hCaster)
end
function Margatroid_ModifyUsableDollNum(hCaster,iModifyAmount)
	local AbilityEx=hCaster:FindAbilityByName(MARGATROID_ABILITYEX_NAME)
	if AbilityEx then
		if iModifyAmount>0 then
			local stack_count=hCaster:GetModifierStackCount(MARGATROID_ABILITYEX_MODIFIER_DOLL_COUNT_NAME,hCaster)+iModifyAmount
			if not hCaster:HasModifier(MARGATROID_ABILITYEX_MODIFIER_DOLL_COUNT_NAME) then
				AbilityEx:ApplyDataDrivenModifier(hCaster,hCaster,MARGATROID_ABILITYEX_MODIFIER_DOLL_COUNT_NAME,{})
			end
			hCaster:SetModifierStackCount(MARGATROID_ABILITYEX_MODIFIER_DOLL_COUNT_NAME,AbilityEx,stack_count)
		else
			local stack_count=hCaster:GetModifierStackCount(MARGATROID_ABILITYEX_MODIFIER_DOLL_COUNT_NAME,hCaster)+iModifyAmount
			if stack_count>0 then
				hCaster:SetModifierStackCount(MARGATROID_ABILITYEX_MODIFIER_DOLL_COUNT_NAME,AbilityEx,stack_count)
			else
				hCaster:RemoveModifierByNameAndCaster(MARGATROID_ABILITYEX_MODIFIER_DOLL_COUNT_NAME,hCaster)
			end
		end
	end
end
function Margatroid_IncUsableDollNum(hCaster)
	local AbilityEx=hCaster:FindAbilityByName(MARGATROID_ABILITYEX_NAME)
	if AbilityEx then
		if hCaster:HasModifier(MARGATROID_ABILITYEX_MODIFIER_DOLL_COUNT_NAME) then
			local stack_count=hCaster:GetModifierStackCount(MARGATROID_ABILITYEX_MODIFIER_DOLL_COUNT_NAME,hCaster)+1
			hCaster:SetModifierStackCount(MARGATROID_ABILITYEX_MODIFIER_DOLL_COUNT_NAME,AbilityEx,stack_count)
		else
			AbilityEx:ApplyDataDrivenModifier(hCaster,hCaster,MARGATROID_ABILITYEX_MODIFIER_DOLL_COUNT_NAME,{})
			hCaster:SetModifierStackCount(MARGATROID_ABILITYEX_MODIFIER_DOLL_COUNT_NAME,AbilityEx,1)
		end
	end
end
function Margatroid_DecUsableDollNum(hCaster)
	local AbilityEx=hCaster:FindAbilityByName(MARGATROID_ABILITYEX_NAME)
	if AbilityEx and hCaster:HasModifier(MARGATROID_ABILITYEX_MODIFIER_DOLL_COUNT_NAME) then
		local stack_count=hCaster:GetModifierStackCount(MARGATROID_ABILITYEX_MODIFIER_DOLL_COUNT_NAME,hCaster)-1
		if stack_count>0 then
			hCaster:SetModifierStackCount(MARGATROID_ABILITYEX_MODIFIER_DOLL_COUNT_NAME,AbilityEx,stack_count)
		else
			hCaster:RemoveModifierByNameAndCaster(MARGATROID_ABILITYEX_MODIFIER_DOLL_COUNT_NAME,hCaster)
		end
	end
end

function Margatroid_CreateDoll(hCaster, vecPos, vecForward,dollname)
	local AbilityEx=hCaster:FindAbilityByName(MARGATROID_ABILITYEX_NAME)

	if AbilityEx then
		local doll=CreateUnitByName(
				MARGATROID_ABILITYEX_DOLL_UNITNAME,
				vecPos,
				false,
				hCaster,
				hCaster,
				hCaster:GetTeam())
		if dollname == "FALANXI" then
			doll:SetModel("models/alice/penglai.vmdl")
			doll:SetOriginalModel("models/alice/penglai.vmdl")
		end
		doll:StartGesture(ACT_DOTA_CAST_ABILITY_1)
		Margatroid_CreateLine(hCaster,doll)
		MargatroidEx_ModifyDollCount(hCaster,1)

		if vecForward then
			local angles = VectorToAngles(vecForward)
			doll:SetAngles(angles.x,angles.y,angles.z)
		end
		AbilityEx:ApplyDataDrivenModifier(hCaster,doll,MARGATROID_ABILITYEX_MODIFIER_DOLL_NAME,{})

		local lvl_to_upgrade=AbilityEx:GetSpecialValueFor("lvl_to_upgrade")
		if lvl_to_upgrade and lvl_to_upgrade>0 then
			local upgrade_num=math.floor((hCaster:GetLevel()-1)/AbilityEx:GetSpecialValueFor("lvl_to_upgrade"))
			local doll_hp=AbilityEx:GetSpecialValueFor("doll_base_hp")+upgrade_num*AbilityEx:GetSpecialValueFor("upgrade_doll_hp")
			doll:SetMaxHealth(doll_hp)
			doll:SetBaseMaxHealth(doll_hp)
			doll:SetHealth(doll:GetMaxHealth())
		end
		return doll
	end
end

function Margatroid_FindDolls(hCaster, fRadius)
	local units=FindUnitsInRadius(
		hCaster:GetTeamNumber(),
		hCaster:GetOrigin(),
		nil,
		fRadius,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_NOT_DOMINATED,
		FIND_ANY_ORDER,
		false)
	local dolls={}
	for _,v in pairs(units) do
		if v:HasModifier(MARGATROID_ABILITYEX_MODIFIER_DOLL_NAME) and not v:HasModifier(MARGATROID_ABILITYEX_MODIFIER_DOLL_RECOVERING_NAME) then
			table.insert(dolls,v)
		end
	end
	return dolls
end

function Margatroid_MoveDoll(hDoll, vecTarget, fMoveSpeed, fnOnMoving, fnOnFinshMove,isfly)
	local tick_interval=0.03

	local distance=(hDoll:GetOrigin()-vecTarget):Length()
	local vecMove=(hDoll:GetOrigin()-vecTarget):Normalized()*fMoveSpeed*tick_interval
	local tick=math.floor(distance/(fMoveSpeed*tick_interval))
	local finish_move=false
	hDoll:SetContextThink(
		"margatroid_move_doll_"..tostring(vecTarget),
		function ()
			hDoll:SetOrigin(GetGroundPosition(hDoll:GetOrigin()+vecMove,hDoll))

			tick=tick-1
			if tick<=0 then finish_move=true end
			if fnOnMoving and fnOnMoving(hDoll) then finish_move=true end
			if finish_move then
				if fnOnFinshMove then
					fnOnFinshMove(hDoll)
				end
				return nil 
			end
			return tick_interval
		end,0)
end

function MargatroidEx_OnRespawn(keys)
	-- local Caster=keys.caster
	-- local playerid=Caster:GetEntityIndex()
	-- print("do it")
	-- g_PlayersTotalDollNum[playerid] = keys.DollBaseNum+math.floor((Caster:GetLevel()-1)/keys.LvlToUpgrade) + FindTelentValue(Caster,"special_bonus_unique_margatroid_2")
end

function MargatroidEx_IntervalAddDoll(keys)
	local AbilityEx=keys.ability
	local Caster=keys.caster
	local MaxStoreNum=keys.DollBaseNum+math.floor((Caster:GetLevel()-1)/keys.LvlToUpgrade) + FindTelentValue(Caster,"special_bonus_unique_margatroid_2")
	local Modifier = MARGATROID_ABILITYEX_MODIFIER_TIME_TO_ADD_DOLL_NAME
	if FindTelentValue(Caster,"special_bonus_unique_margatroid_1") ~= 0 then
		Modifier = "modifier_thdots_margatroidex_time_to_add_doll_talent"
	end
	-- print(Margatroid_GetTotalDollNum(Caster))
	-- print(MaxStoreNum)
	if Margatroid_GetTotalDollNum(Caster)<MaxStoreNum and not Caster:HasModifier(Modifier) then
	-- if Margatroid_GetUsableDollNum(Caster)<MaxStoreNum and not Caster:HasModifier(Modifier) then
		-- AbilityEx:ApplyDataDrivenModifier(Caster,Caster,MARGATROID_ABILITYEX_MODIFIER_TIME_TO_ADD_DOLL_NAME,{})
		AbilityEx:ApplyDataDrivenModifier(Caster,Caster,Modifier,{})
	end
	Caster.margatroid_last_level=Caster.margatroid_last_level or Caster:GetLevel()
	if Caster:GetLevel()-Caster.margatroid_last_level>=keys.LvlToUpgrade then
		local upgrade_num=math.floor((Caster:GetLevel()-Caster.margatroid_last_level)/keys.LvlToUpgrade)
		Margatroid_ModifyUsableDollNum(Caster,upgrade_num) 
		Margatroid_ModifyTotalDollNum(Caster,upgrade_num) 
		Caster.margatroid_last_level=Caster:GetLevel()+upgrade_num*keys.LvlToUpgrade
	end
end

function MargatroidEx_OnDollIntervalThink(keys)
	local AbilityEx=keys.ability
	local Caster=keys.caster
	local doll=keys.target	
	if not Caster:IsAlive() or CalcDistanceBetweenEntityOBB(Caster,doll)>keys.DollMaxDistance then
		doll:RemoveModifierByNameAndCaster(MARGATROID_ABILITYEX_MODIFIER_DOLL_NAME,Caster)
		AbilityEx:ApplyDataDrivenModifier(Caster,doll,MARGATROID_ABILITYEX_MODIFIER_DOLL_LOST_NAME,{})
	end
	
end

function MargatroidEx_AddDoll(keys)
	local AbilityEx=keys.ability
	local Caster=keys.caster

	Caster:SetContextThink(DoUniqueString("margatroid_ex_doll_recovering_reset"), 
		function()
			if Caster:IsAlive() then
				print("MargatroidEx_AddDoll")
				if keys.UsableDollAmount then 
					Margatroid_ModifyUsableDollNum(Caster,keys.UsableDollAmount) 
				end

				if keys.TotalDollAmount then 
					Margatroid_ModifyTotalDollNum(Caster,keys.TotalDollAmount) 
				end
				return nil
			else
				return 0.03
			end
		end, 
	0.03)
end


function MargatroidEx_OnDollDestroy(keys)
	local AbilityEx=keys.ability
	local Caster=keys.caster
	local doll=keys.target

	local effectIndex = ParticleManager:CreateParticle("particles/econ/items/clockwerk/clockwerk_paraflare/clockwerk_para_rocket_flare_explosion.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(effectIndex, 0, doll:GetOrigin())
	ParticleManager:SetParticleControl(effectIndex, 3, doll:GetOrigin())
	Caster:EmitSound("Hero_Techies.LandMine.Detonate")

	Margatroid_ModifyTotalDollNum(Caster,-1)
	if doll:IsAlive() then
		ExecuteOrderFromTable{
			UnitIndex = doll:entindex(),
			OrderType = DOTA_UNIT_ORDER_STOP}
		doll:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)
		doll:SetControllableByPlayer(-1,true)
	end

	MargatroidEx_ModifyDollCount(Caster,-1)
	doll:Destroy()
end

function MargatroidEx_OnDollRecovering(keys)
	local AbilityEx=keys.ability
	local Caster=keys.caster
	local doll=keys.target

	if doll:HasModifier(MARGATROID_ABILITYEX_MODIFIER_DOLL_NAME) and doll:HasModifier(MARGATROID_ABILITYEX_MODIFIER_DOLL_RECOVERING_NAME) and not Caster:IsStunned() then
		local vecCasterPos=Caster:GetOrigin()
		local vecDollPos=doll:GetOrigin()

		local radForward = GetRadBetweenTwoVec2D(vecDollPos,vecCasterPos)
		local vecForward = Vector(math.cos(radForward),math.sin(radForward),doll:GetForwardVector().z)
		doll:SetForwardVector(vecForward)

		local vecMovePos=vecDollPos+(vecCasterPos-vecDollPos):Normalized()*keys.ThinkInterval*keys.RecoveringMoveSpeed
		if (vecCasterPos-vecMovePos):Length2D()<50 then
			
			AbilityEx:ApplyDataDrivenModifier(Caster,Caster,MARGATROID_ABILITYEX_MODIFIER_RESET_DOLL_NAME,{Duration=keys.ResetDollTime})
			
			local effectIndex = ParticleManager:CreateParticle("particles/heroes/alice/ability_alice_ex_release.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControlEnt(effectIndex , 0, Caster, 5, "attach_line", Vector(0,0,0), true)
			doll:EmitSound("Voice_Thdots_Alice.AbilityAliceEx")
			Caster:SetMana(Caster:GetMana()+20)
			
			doll:RemoveModifierByNameAndCaster(MARGATROID_ABILITYEX_MODIFIER_DOLL_RECOVERING_NAME,Caster)
			MargatroidEx_ModifyDollCount(Caster,-1)
			doll:Destroy()
			--doll:AddNoDraw()
			--doll:ForceKill(false)
			--Margatroid_ModifyTotalDollNum(Caster,1)
		else
			doll:SetOrigin(GetGroundPosition(vecMovePos,doll))
		end
	end
end

function MargatroidEx_OnSpellStart(keys)
	local AbilityEx=keys.ability
	local Caster=keys.caster
	local Radius=keys.Radius
	local dolls=Margatroid_FindDolls(Caster,Radius)
	for _,doll in pairs(dolls) do
		if doll:GetUnitName()==MARGATROID_ABILITYEX_DOLL_UNITNAME then
			doll:StartGesture(ACT_DOTA_RUN)
			AbilityEx:ApplyDataDrivenModifier(Caster,doll,MARGATROID_ABILITYEX_MODIFIER_DOLL_RECOVERING_NAME,{})
		end
	end
end

function MargatroidEx_OnUpgrade(keys)
	local AbilityEx=keys.ability
	local Caster=keys.caster

	if AbilityEx:GetLevel()==1 then
		Margatroid_ModifyUsableDollNum(Caster,3)
		Margatroid_ModifyTotalDollNum(Caster,3)
		Caster.isCreatedLine = false
		MargatroidEx_ModifyDollActionTranslate(Caster)
		--MargatroidEx_ModifyDollReset(Caster)
	end
end

function Margatroid01_OnSpellStart(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	if Caster:HasModifier("modifier_item_wanbaochui") then
		THDReduceCooldown(keys.ability,-3)
	end
	local Point=keys.target_points[1]
	local caster_pos=Caster:GetOrigin()
	local direction=(Point-Caster:GetOrigin()):Normalized()
	local mana_cost=Ability:GetManaCost(Ability:GetLevel())
	local usable_doll_num=math.min(Margatroid_GetUsableDollNum(Caster),3)
	usable_doll_num=math.min(usable_doll_num,math.floor(Caster:GetMana()/mana_cost)+1)

	local dolls_and_pos={} -- [doll,start_pos]

	if usable_doll_num==0 or not Point then
		Ability:EndCooldown()
		Ability:RefundManaCost()
		return
	elseif usable_doll_num==1 then
		local start_pos=caster_pos+direction*keys.Radius
		local doll=Margatroid_CreateDoll(Caster,caster_pos+(start_pos-caster_pos):Normalized()*20,direction,"SHANGHAI")
		dolls_and_pos[1]={doll=doll,start_pos=start_pos}
	elseif usable_doll_num==2 then
		Caster:SpendMana(mana_cost*(usable_doll_num-1),Ability)
		local base_pos=caster_pos+direction*keys.Radius

		local rotate_angle=QAngle(0,30,0)
		local start_pos=RotatePosition(base_pos,rotate_angle,caster_pos)
		local doll=Margatroid_CreateDoll(Caster,caster_pos+(start_pos-caster_pos):Normalized()*20,direction,"SHANGHAI")
		dolls_and_pos[1]={doll=doll,start_pos=start_pos}
		

		local rotate_angle=QAngle(0,-30,0)
		local start_pos=RotatePosition(base_pos,rotate_angle,caster_pos)
		local doll=Margatroid_CreateDoll(Caster,caster_pos+(start_pos-caster_pos):Normalized()*20,direction,"SHANGHAI")
		dolls_and_pos[2]={doll=doll,start_pos=start_pos}
	elseif usable_doll_num==3 then
		Caster:SpendMana(mana_cost*(usable_doll_num-1),Ability)
		local base_pos=caster_pos+direction*keys.Radius

		local start_pos=base_pos
		local doll=Margatroid_CreateDoll(Caster,caster_pos+(start_pos-caster_pos):Normalized()*20,direction,"SHANGHAI")
		dolls_and_pos[1]={doll=doll,start_pos=start_pos}

		local rotate_angle=QAngle(0,45,0)
		local start_pos=RotatePosition(caster_pos,rotate_angle,base_pos)
		local doll=Margatroid_CreateDoll(Caster,caster_pos+(start_pos-caster_pos):Normalized()*20,direction,"SHANGHAI")
		dolls_and_pos[2]={doll=doll,start_pos=start_pos}	

		local rotate_angle=QAngle(0,-45,0)
		local start_pos=RotatePosition(caster_pos,rotate_angle,base_pos)
		local doll=Margatroid_CreateDoll(Caster,caster_pos+(start_pos-caster_pos):Normalized()*20,direction,"SHANGHAI")
		dolls_and_pos[3]={doll=doll,start_pos=start_pos}
	end
	Margatroid_ModifyUsableDollNum(Caster,-usable_doll_num)

	local goforward_duration=(keys.MoveDistance+keys.Radius)/keys.MoveSpeed
	for _,tab in pairs(dolls_and_pos) do
		local OnDollFinshMove=
			function (hDoll)
				hDoll:StartGesture(ACT_DOTA_ATTACK)
				hDoll:SetForwardVector(direction)
				local effectIndex = ParticleManager:CreateParticle("particles/heroes/alice/ability_alice_dash_a1.vpcf", PATTACH_CUSTOMORIGIN, hDoll)
				ParticleManager:SetParticleControlEnt(effectIndex , 0, hDoll, 5, "attach_hitloc", Vector(0,0,0), true)
				hDoll:EmitSound("Voice_Thdots_Alice.AbilityAlice012")
				
				hDoll:SetContextThink(
					"margatroid01_action_delay",
					function ()
						Ability:ApplyDataDrivenModifier(Caster,hDoll,keys.ModifierGoForward,{Duration=goforward_duration})
					end,0.1)
			end
		if tab.doll then
			Margatroid_MoveDoll(
				tab.doll,
				tab.start_pos,
				keys.Radius*2,
				nil,
				OnDollFinshMove,true)
		end
	end
end

function Margatroid01_DollGoForwardThink(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	local Doll=keys.target

	local vec=Doll:GetForwardVector()*keys.MoveSpeed*keys.Interval
	Doll:SetOrigin(GetGroundPosition(Doll:GetOrigin()+vec,Doll))
end

function Margatroid01_IfKnockback(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	local Target=keys.target
	keys.KnockbackDuration=0.5
	keys.KnockbackDistance=150
	if not Target:HasModifier(keys.ModifierKnockbackName) then
		Ability:ApplyDataDrivenModifier(Caster,Target,keys.ModifierKnockbackName,{Duration=keys.KnockbackDuration})
		Margatroid01_KnockbackTarget(Caster,Target,Caster:GetForwardVector(),keys.KnockbackDistance,keys.KnockbackDuration,keys.ModifierKnockbackName)
		UnitDamageTarget{
			ability = Ability,
			victim = Target,
			attacker = Caster,
			damage = Ability:GetAbilityDamage(),
			damage_type = Ability:GetAbilityDamageType()
		}
	end
end

function Margatroid01_KnockbackTarget(hCaster,hTarget,vecDirection,fDistance,fDuration,strModifierKnockbackName)
	local tick_interval=0.03
	local tick_move=vecDirection*fDistance*tick_interval
	local max_tick=math.floor(fDuration/tick_interval)
	local tick=0
	local max_height=50
	local base_height=hTarget:GetOrigin().z
	local a=-max_height/(max_tick*0.5)^2
	hTarget:SetContextThink(
		"Margatroid01_Knockback",
		function ()
			tick=tick+1

			if hTarget:HasModifier(strModifierKnockbackName) then 
				local height=base_height+a*(tick-max_tick*0.5)^2+max_height
				local now_pos=hTarget:GetOrigin()+tick_move
				now_pos.z=height
				hTarget:SetOrigin(now_pos)
				--print("tick="..tostring(tick).." half_tick="..tostring(tick-max_tick/0.5).." height="..tostring(height))
			else
				local now_pos=hTarget:GetOrigin()
				now_pos.z=base_height
				hTarget:SetOrigin(now_pos)
				return nil 
			end
			if tick>max_tick then return nil end
			return tick_interval
		end,0)
end

function Margatroid02_OnSpellStart(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	if Caster:HasModifier("modifier_item_wanbaochui") then
		THDReduceCooldown(keys.ability,-2)
	end
	local Point=keys.target_points[1]
	local caster_pos=Caster:GetOrigin()
	local focus_target=((caster_pos-Point):Length2D()<=keys.FocusTargetInRadius)
	local offset_if_focus_target=300
	local direction=(Point-Caster:GetOrigin()):Normalized()
	local mana_cost=Ability:GetManaCost(Ability:GetLevel())
	local usable_doll_num=math.min(Margatroid_GetUsableDollNum(Caster),3)
	usable_doll_num=math.min(usable_doll_num,math.floor(Caster:GetMana()/mana_cost)+1)

	local dolls_and_pos={} -- [doll,start_pos]

	if usable_doll_num==0 or not Point then
		Ability:EndCooldown()
		Ability:RefundManaCost()
		return
	elseif usable_doll_num==1 then
		if focus_target then
			local start_pos=caster_pos+direction*offset_if_focus_target
			local target_pos=(caster_pos-direction*(caster_pos-Point):Length2D())
			local doll=Margatroid_CreateDoll(Caster,caster_pos+(start_pos-caster_pos):Normalized()*20,doll_dir,"FALANXI")
			dolls_and_pos[1]={doll=doll,start_pos=start_pos}
		else
			local start_pos=caster_pos-direction*keys.Radius
			local doll=Margatroid_CreateDoll(Caster,caster_pos+(start_pos-caster_pos):Normalized()*20,direction,"FALANXI")
			dolls_and_pos[1]={doll=doll,start_pos=start_pos}
		end
	elseif usable_doll_num==2 then
		Caster:SpendMana(mana_cost*(usable_doll_num-1),Ability)
		if focus_target then
			local base_pos=caster_pos+direction*offset_if_focus_target
			local target_pos=(caster_pos-direction*(caster_pos-Point):Length2D())

			local rotate_angle=QAngle(0,60,0)
			local start_pos=RotatePosition(caster_pos,rotate_angle,base_pos)
			local vec=(start_pos-caster_pos):Normalized()
			local doll_dir=(start_pos-target_pos):Normalized()
			local doll=Margatroid_CreateDoll(Caster,caster_pos+vec*20,doll_dir,"FALANXI")
			dolls_and_pos[1]={doll=doll,start_pos=start_pos}
			

			local rotate_angle=QAngle(0,-60,0)
			local start_pos=RotatePosition(caster_pos,rotate_angle,base_pos)
			local vec=(start_pos-caster_pos):Normalized()
			local doll_dir=(start_pos-target_pos):Normalized()
			local doll=Margatroid_CreateDoll(Caster,caster_pos+vec*20,doll_dir,"FALANXI")
			dolls_and_pos[2]={doll=doll,start_pos=start_pos}
		else
			local base_pos=caster_pos-direction*keys.Radius

			local rotate_angle=QAngle(0,30,0)
			local start_pos=RotatePosition(caster_pos,rotate_angle,base_pos)
			local doll=Margatroid_CreateDoll(Caster,caster_pos+(start_pos-caster_pos):Normalized()*20,direction,"FALANXI")
			dolls_and_pos[1]={doll=doll,start_pos=start_pos}
			

			local rotate_angle=QAngle(0,-30,0)
			local start_pos=RotatePosition(caster_pos,rotate_angle,base_pos)
			local doll=Margatroid_CreateDoll(Caster,caster_pos+(start_pos-caster_pos):Normalized()*20,direction,"FALANXI")
			dolls_and_pos[2]={doll=doll,start_pos=start_pos}
		end
	elseif usable_doll_num==3 then
		Caster:SpendMana(mana_cost*(usable_doll_num-1),Ability)
		if focus_target then
			local base_pos=caster_pos+direction*offset_if_focus_target
			local target_pos=(caster_pos-direction*(caster_pos-Point):Length2D())

			local start_pos=base_pos
			local vec=(start_pos-caster_pos):Normalized()
			local doll_dir=(start_pos-target_pos):Normalized()
			local doll=Margatroid_CreateDoll(Caster,caster_pos+vec*20,doll_dir,"FALANXI")
			dolls_and_pos[1]={doll=doll,start_pos=start_pos}

			local rotate_angle=QAngle(0,60,0)
			local start_pos=RotatePosition(caster_pos,rotate_angle,base_pos)
			local vec=(start_pos-caster_pos):Normalized()
			local doll_dir=(start_pos-target_pos):Normalized()
			local doll=Margatroid_CreateDoll(Caster,caster_pos+vec*20,doll_dir,"FALANXI")
			dolls_and_pos[2]={doll=doll,start_pos=start_pos}	

			local rotate_angle=QAngle(0,-60,0)
			local start_pos=RotatePosition(caster_pos,rotate_angle,base_pos)
			local vec=(start_pos-caster_pos):Normalized()
			local doll_dir=(start_pos-target_pos):Normalized()
			local doll=Margatroid_CreateDoll(Caster,caster_pos+vec*20,doll_dir,"FALANXI")
			dolls_and_pos[3]={doll=doll,start_pos=start_pos}
		else
			local base_pos=caster_pos-direction*keys.Radius

			local start_pos=base_pos
			local doll=Margatroid_CreateDoll(Caster,caster_pos+(start_pos-caster_pos):Normalized()*20,direction,"FALANXI")
			dolls_and_pos[1]={doll=doll,start_pos=start_pos}

			local rotate_angle=QAngle(0,35,0)
			local start_pos=RotatePosition(caster_pos,rotate_angle,base_pos)
			local doll=Margatroid_CreateDoll(Caster,caster_pos+(start_pos-caster_pos):Normalized()*20,direction,"FALANXI")
			dolls_and_pos[2]={doll=doll,start_pos=start_pos}	

			local rotate_angle=QAngle(0,-35,0)
			local start_pos=RotatePosition(caster_pos,rotate_angle,base_pos)
			local doll=Margatroid_CreateDoll(Caster,caster_pos+(start_pos-caster_pos):Normalized()*20,direction,"FALANXI")
			dolls_and_pos[3]={doll=doll,start_pos=start_pos}
		end
	end
	Margatroid_ModifyUsableDollNum(Caster,-usable_doll_num)

	for _,tab in pairs(dolls_and_pos) do
		local OnDollFinshMove=
			function (hDoll)
				local doll_pos=hDoll:GetOrigin()
				local target_dir=direction
				if focus_target then
					target_dir=(Point-doll_pos):Normalized()
				end
				hDoll:StartGesture(ACT_DOTA_ATTACK)
				hDoll:SetForwardVector(target_dir)

				hDoll:SetContextThink(
					"margatroid02_action_delay",
					function ()
						local effectIndex = ParticleManager:CreateParticle("particles/heroes/alice/ability_alice_02.vpcf", PATTACH_CUSTOMORIGIN, hDoll)

						ParticleManager:SetParticleControl(effectIndex, 0, hDoll:GetAttachmentOrigin(hDoll:ScriptLookupAttachment("attach_attack1"))+Vector(0,0,30))
						ParticleManager:SetParticleControl(effectIndex, 1, hDoll:GetOrigin()+hDoll:GetForwardVector()*600)
						ParticleManager:SetParticleControl(effectIndex, 9, hDoll:GetAttachmentOrigin(hDoll:ScriptLookupAttachment("attach_attack1"))+Vector(0,0,30))

						hDoll:EmitSound("Voice_Thdots_Alice.AbilityAlice022")

						local angles=VectorToAngles(target_dir)
						angles.y=-angles.y
						--print("x0="..tostring(target_dir.x).." y0="..tostring(target_dir.y).." z0="..tostring(target_dir.z))
						--print("x1="..tostring(angles.x).." y1="..tostring(angles.y).." z1="..tostring(angles.z))
						local rotate_angle=angles
						local enemies=FindUnitsInRadius(
							Caster:GetTeamNumber(),
							doll_pos+target_dir*keys.Distance*0.5,
							nil,
							keys.Distance,
							DOTA_UNIT_TARGET_TEAM_ENEMY,
							DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
							DOTA_UNIT_TARGET_FLAG_NONE,
							FIND_ANY_ORDER,
							false)
						for __,enemy in pairs(enemies) do
							local after_rotate_pos=RotatePosition(doll_pos,rotate_angle,enemy:GetOrigin())
							if math.abs(after_rotate_pos.y-doll_pos.y)<keys.LaserRadius then
								UnitDamageTarget{
									ability = Ability,
									victim = enemy,
									attacker = Caster,
									damage = Ability:GetAbilityDamage(),
									damage_type = Ability:GetAbilityDamageType()
								}
							end
						end
					end,0.1)
			end
		if tab.doll then
			Margatroid_MoveDoll(
				tab.doll,
				tab.start_pos,
				keys.Radius*2,
				nil,
				OnDollFinshMove,false)
		end
	end
end



function Margatroid03_OnSpellStart(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	local ability_lvl=Ability:GetLevel()
	local Point=keys.target_points[1]
	local vecForward = Caster:GetForwardVector()

	local doll=CreateUnitByName(
		MARGATROID_ABILITY03_DOLL_UNITNAME,
		Caster:GetOrigin()+Caster:GetForwardVector()*100,
		true,
		Caster,
		Caster,
		Caster:GetTeam())
	Margatroid_CreateLine(Caster,doll)
	doll.ability_alice_03_owner = Caster
	MargatroidEx_ModifyDollCount(Caster,1)

	Ability:ApplyDataDrivenModifier(Caster,doll,MARGATROID_ABILITY03_MODIFIER_DOLL_NAME,{})
	doll:SetForwardVector(Caster:GetForwardVector())
	print(keys.DollHP)
	doll:SetBaseMaxHealth(keys.DollHP*(1+FindTelentValue(Caster,"special_bonus_unique_visage_1")))
	-- doll:SetMaxHealth(keys.DollHP*(1+FindTelentValue(Caster,"special_bonus_unique_visage_1")))
	doll:CreatureLevelUp(0)
	doll:SetBaseDamageMax(keys.DollDamage*(1+FindTelentValue(Caster,"special_bonus_unique_visage_1")))
	doll:SetBaseDamageMin(keys.DollDamage*(1+FindTelentValue(Caster,"special_bonus_unique_visage_1")))
	doll:SetMana(400)
	doll:SetControllableByPlayer(Caster:GetPlayerID(),false)
	doll:SetBaseMoveSpeed(400)
	if FindTelentValue(Caster,"special_bonus_unique_visage_4")==1 then
		doll:SetPhysicalArmorBaseValue(30)
		doll:SetBaseMagicalResistanceValue(75)
	end
	-- doll:SetHealth(doll:GetMaxHealth())



	if ability_lvl<=1 and keys.Level1Ability then
		local ability=doll:AddAbility(keys.Level1Ability)
		ability:SetLevel(1)
	end
	if ability_lvl>=2 and keys.Level2Ability then
		local ability=doll:AddAbility(keys.Level2Ability)
		ability:SetLevel(1)
	end
	if ability_lvl>=3 and keys.Level3Ability then
		local ability=doll:AddAbility(keys.Level3Ability)
		ability:SetLevel(1)
	end
	if ability_lvl>=4 and keys.Level4Ability then
		local ability=doll:AddAbility(keys.Level4Ability)
		ability:SetLevel(1)
	end

	doll:StartGesture(ACT_DOTA_ATTACK)
	local effectIndex = ParticleManager:CreateParticle("particles/heroes/alice/ability_alice_dash_a1.vpcf", PATTACH_CUSTOMORIGIN, doll)
	ParticleManager:SetParticleControlEnt(effectIndex , 0, doll, 5, "attach_hitloc", Vector(0,0,0), true)
	doll:EmitSound("Voice_Thdots_Alice.AbilityAlice012")

	local distance = 0

	doll:SetContextThink(DoUniqueString("margatroid_03_dash"),
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			local speed=2800*0.03
			distance = speed + distance
			local enemies=FindUnitsInRadius(
				   Caster:GetTeam(),	
				   doll:GetOrigin(),		
				   nil,				
				   100,		
				   DOTA_UNIT_TARGET_TEAM_ENEMY,
				   DOTA_UNIT_TARGET_HERO,
				   0, FIND_CLOSEST,
				   false
			    )
			if distance >= 800 or enemies[1]~=nil then
				local abilityStun = doll:FindAbilityByName(keys.Level2Ability)
				if abilityStun~=nil then
					doll:CastAbilityOnTarget(enemies[1], abilityStun, 0 )
				end
				local abilityLaser = doll:FindAbilityByName(keys.Level3Ability)
				if abilityLaser~=nil then
					doll:CastAbilityOnTarget(enemies[1], abilityLaser, 0 )
				end
				return nil
			else
				doll:SetOrigin(GetGroundPosition(doll:GetOrigin()+vecForward*speed,doll))
				return 0.03
			end
	end,0.03)
end

function Margatroid03_DollOnIntervalThink(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	local Doll=keys.target

	local distance=CalcDistanceBetweenEntityOBB(Caster,Doll)
	if FindTelentValue(Caster,"special_bonus_unique_visage_3")==0 then
		if distance>keys.DollMaxDistance*2 then
			FindClearSpaceForUnit(Doll,Caster:GetOrigin(),true)
		elseif distance>keys.DollMaxDistance then
			local new_pos=Caster:GetOrigin()+(Doll:GetOrigin()-Caster:GetOrigin()):Normalized()*keys.DollMaxDistance
			FindClearSpaceForUnit(Doll,new_pos,true)
		end
		if Caster:IsAlive() == false then
			Doll:ForceKill(true)
		end
	end
end

function Margatroid03_OnDollDestroy(keys)
	local AbilityEx=keys.ability
	local Caster=keys.caster
	local doll=keys.target

	local effectIndex = ParticleManager:CreateParticle("particles/econ/items/clockwerk/clockwerk_paraflare/clockwerk_para_rocket_flare_explosion.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(effectIndex, 0, doll:GetOrigin())
	ParticleManager:SetParticleControl(effectIndex, 3, doll:GetOrigin())
	Caster:EmitSound("Hero_Techies.LandMine.Detonate")

	if doll:IsAlive() then
		ExecuteOrderFromTable{
			UnitIndex = doll:entindex(),
			OrderType = DOTA_UNIT_ORDER_STOP}
		doll:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)
		doll:SetControllableByPlayer(-1,true)
	end

	MargatroidEx_ModifyDollCount(Caster,-1)

	doll:Destroy()
end

function Margatroid32_OnSpellStart(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	local Target=keys.target
	if is_spell_blocked(Target) then return end
	Caster:StartGesture(ACT_DOTA_ATTACK)
    UtilStun:UnitStunTarget(Caster,Target,keys.StunDuration)
    local effectIndex = ParticleManager:CreateParticle("particles/heroes/alice/ability_alice_dash_a1.vpcf", PATTACH_CUSTOMORIGIN, Caster)
	ParticleManager:SetParticleControlEnt(effectIndex , 0, Caster, 5, "attach_attack1", Vector(0,0,0), true)

	UnitDamageTarget{
			ability = Ability,
			victim = Target,
			attacker = keys.caster.ability_alice_03_owner,
			damage = Ability:GetAbilityDamage(),
			damage_type = Ability:GetAbilityDamageType()
		}    
end

function Margatroid33_OnSpellStart(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	local Point=keys.target_points[1]

	local caster_pos=Caster:GetOrigin()
	local target_dir=(Point-caster_pos):Normalized()

	local effectIndex = ParticleManager:CreateParticle("particles/heroes/alice/ability_alice_02.vpcf", PATTACH_CUSTOMORIGIN, Caster)

	ParticleManager:SetParticleControl(effectIndex, 0, Caster:GetAttachmentOrigin(Caster:ScriptLookupAttachment("attach_cast"))+Vector(0,0,160))
	ParticleManager:SetParticleControl(effectIndex, 1, Caster:GetAttachmentOrigin(Caster:ScriptLookupAttachment("attach_cast"))+Caster:GetForwardVector()*600+Vector(0,0,160))
	ParticleManager:SetParticleControl(effectIndex, 9, Caster:GetAttachmentOrigin(Caster:ScriptLookupAttachment("attach_cast"))+Vector(0,0,160))

	Caster:EmitSound("Voice_Thdots_Alice.AbilityAlice022")

	local damage_table={
			ability = Ability,
			victim = nil,
			attacker = keys.caster.ability_alice_03_owner,
			damage = Ability:GetAbilityDamage(),
			damage_type = Ability:GetAbilityDamageType()
		}  

	local enemies=FindUnitsInRadius(
		Caster:GetTeamNumber(),
		caster_pos+target_dir*keys.Distance*0.5,
		nil,
		keys.Distance,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false)  

	local rotate_angle=VectorToAngles(target_dir)
	rotate_angle.y=-rotate_angle.y
	for _,enemy in pairs(enemies) do
		local after_rotate_pos=RotatePosition(caster_pos,rotate_angle,enemy:GetOrigin())
		if after_rotate_pos.y-caster_pos.y<keys.LaserRadius then
			damage_table.victim=enemy
			UnitDamageTarget(damage_table)
		end
	end
end

function Margatroid33_KillItself(keys)
	local effectIndex = ParticleManager:CreateParticle("particles/econ/items/clockwerk/clockwerk_paraflare/clockwerk_para_rocket_flare_explosion.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(effectIndex, 0, keys.caster:GetOrigin())
	ParticleManager:SetParticleControl(effectIndex, 3, keys.caster:GetOrigin())
	keys.caster:EmitSound("Hero_Techies.LandMine.Detonate")
	if keys.caster.ability_alice_03_owner ~= nil then
		MargatroidEx_ModifyDollCount(keys.caster.ability_alice_03_owner,-1)
	end
	keys.caster:Destroy()
end

function Margatroid04_OnSpellStart(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	local Point=keys.target_points[1]
	local dolls=Margatroid_FindDolls(Caster,keys.FindDollsRadius)
	Caster:EmitSound("Voice_Thdots_Alice.AbilityAlice04")
	for _,doll in pairs(dolls) do
		Ability:ApplyDataDrivenModifier(Caster,doll,MARGATROID_ABILITY04_MODIFIER_DOLL_EXPLOSION_NAME,{})
		--doll:RemoveModifierByNameAndCaster(MARGATROID_ABILITYEX_MODIFIER_DOLL_NAME,Caster)

		doll:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)

		doll:SetContextThink(
			"Margatroid04_action",
			function ()
				ExecuteOrderFromTable{
					UnitIndex = doll:entindex(),
					OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
					Position = Point }
			end,0)
	end
end

function Margatroid04_SetControllableForCaster(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	local Doll=keys.target
	Doll:SetControllableByPlayer(Caster:GetPlayerID(),true)
end
function Margatroid04_End(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	local Doll=keys.target

	ExecuteOrderFromTable{
		UnitIndex = Doll:entindex(),
		OrderType = DOTA_UNIT_ORDER_STOP}
	Doll:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)
	Doll:SetControllableByPlayer(-1,true)


end
function Margatroid04_DamageTargets(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	local targets = keys.target_entities

	for k,v in pairs(targets) do
		UnitDamageTarget{
			ability = Ability,
			victim = v,
			attacker = Caster,
			damage = keys.explosion_damage + FindTelentValue(Caster,"special_bonus_unique_visage_2"),
			damage_type = Ability:GetAbilityDamageType()
		}
	end
end