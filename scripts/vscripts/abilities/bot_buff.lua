
function Ability_Bot_Buff_OnInterval(keys)
	local now_time = GameRules:GetDOTATime(false, false)
	if (now_time < 1.0) then return end
	local Caster = keys.caster
	local CasterPlayerID = Caster:GetPlayerOwnerID()
	local add_gold = keys.GiveGoldAmount
	local add_exp = keys.GiveExpAmount * 2.0
	if now_time >= 300.0 and now_time < 600.0 then
		add_gold = add_gold * 1.5
		add_exp = add_exp * 1.75
	elseif now_time >= 600.0 and now_time < 900.0 then
		add_gold = add_gold * 2.0
		add_exp = add_exp * 2.25
	elseif now_time >= 900.0 and now_time < 1200.0 then
		add_gold = add_gold * 2.25
		add_exp = add_exp * 2.5
	elseif now_time >= 1200.0 then
		add_gold = add_gold * 2.5
		add_exp = add_exp * 2.5
	end
	if now_time <= 600.0 then
		local hcnt = FindUnitsInRadius(
			Caster:GetTeam(),		
			Caster:GetOrigin(),		
			nil,					
			1200,		
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,
			DOTA_UNIT_TARGET_HERO,
			0, FIND_CLOSEST,
			false
		)
		add_exp = add_exp / math.max(#hcnt,1.0)
	else
		local mm=1.0
		if now_time>=1200.0 then
			mm=2.0
		end
		Caster:SetBaseStrength(Caster:GetBaseStrength() + keys.IncreaseAllstat * mm)
		Caster:SetBaseAgility(Caster:GetBaseAgility() + keys.IncreaseAllstat * mm)
		Caster:SetBaseIntellect(Caster:GetBaseIntellect() + keys.IncreaseAllstat * mm)
	end
	--DebugPrint("now:"..PlayerResource:GetUnreliableGold(CasterPlayerID).."+"..keys.GiveGoldAmount)
	PlayerResource:SetGold(CasterPlayerID,PlayerResource:GetUnreliableGold(CasterPlayerID) + add_gold,false)
	Caster:AddExperience(add_exp,DOTA_ModifyXP_CreepKill,false,false)
	--SendOverheadEventMessage(Caster:GetOwner(),OVERHEAD_ALERT_GOLD,Caster,keys.GiveGoldAmount,nil)
end

function DeathBuff(keys)
	local now_time = GameRules:GetDOTATime(false, false)
	if (now_time < 600.0) then return end --do not bonus on death before 10min
	local bn=keys.BonusOnDeath
	local Caster = keys.caster
	local CasterPlayerID = Caster:GetPlayerOwnerID()
	if (now_time < 1200.0) then 
		PlayerResource:SetGold(CasterPlayerID,PlayerResource:GetUnreliableGold(CasterPlayerID) + bn,false)
		print('buff_x')
	else
		local mm=0.01
		if now_time>=1800.0 then
			mm=0.02
		end
		Caster:SetBaseStrength(Caster:GetBaseStrength() + bn * mm)
		Caster:SetBaseAgility(Caster:GetBaseAgility() + bn * mm)
		Caster:SetBaseIntellect(Caster:GetBaseIntellect() + bn * mm)
		print('buff_y')
	end
	
end

function Ability_Bot_SelfStun(keys)
	if RandomFloat(0.0,1.0) > keys.SelfStunChance then return end
	UtilStun:UnitStunTarget(keys.caster,keys.caster,keys.SelfStunDuration * RandomFloat(0.1,1.0) )
end
