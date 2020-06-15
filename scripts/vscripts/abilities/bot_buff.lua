
function Ability_Bot_Buff_OnInterval(keys)
	local Caster = keys.caster
	local CasterPlayerID = Caster:GetPlayerOwnerID()
	--DebugPrint("now:"..PlayerResource:GetUnreliableGold(CasterPlayerID).."+"..keys.GiveGoldAmount)
	PlayerResource:SetGold(CasterPlayerID,PlayerResource:GetUnreliableGold(CasterPlayerID) + keys.GiveGoldAmount,false)
	Caster:AddExperience(keys.GiveExpAmount,DOTA_ModifyXP_CreepKill,false,false)
	--SendOverheadEventMessage(Caster:GetOwner(),OVERHEAD_ALERT_GOLD,Caster,keys.GiveGoldAmount,nil)
end
