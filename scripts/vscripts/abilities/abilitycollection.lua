function OnCollectionPower(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	caster:SetContextNum("ability_collection_power_speed",2,0)
	local vecCaster = caster:GetOrigin()
	local targets = keys.target_entities
	for _,v in pairs(targets) do
		if((v:GetUnitName()=="npc_coin_up_unit") or (v:GetUnitName()== "npc_power_up_unit"))then
			if(v:GetContext("ability_collection_power")==nil)then
				v:SetThink(
				function()
					OnCollectionPowerMove(v,caster)
					return 0.02
				end, 
				"ability_collection_power",
				0.02)
			end
		end
	end
end

function OnGetCollection(Collection,Hero)
	local vecHero = Hero:GetOrigin()
	if((Collection:GetUnitName()=="npc_coin_up_unit"))then
		local effectIndex = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(effectIndex, 0, vecHero)
		ParticleManager:SetParticleControl(effectIndex, 1, vecHero)
		ParticleManager:DestroyParticleSystem(effectIndex,false)
		local ply = Hero:GetOwner()
		local playerId = ply:GetPlayerID()
		local modifyGold = PlayerResource:GetReliableGold(playerId) + 35
		PlayerResource:SetGold(playerId, modifyGold, true)
		SendOverheadEventMessage(Hero:GetOwner(),OVERHEAD_ALERT_GOLD,Hero,35,nil)
	elseif(Collection:GetUnitName()=="npc_power_up_unit")then
		local powerCount = Hero:GetContext("hero_bouns_stat_power_count")
		if(powerCount==nil)then
			Hero:SetContextNum("hero_bouns_stat_power_count",0,0)
			powerCount = 0
		end
		if(powerCount<30)then
			local effectIndex = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn_spotlight.vpcf", PATTACH_CUSTOMORIGIN, Hero)
			ParticleManager:SetParticleControl(effectIndex, 0, vecHero)
			ParticleManager:ReleaseParticleIndex(effectIndex)
			powerCount = powerCount + 1
			Hero:SetContextNum("hero_bouns_stat_power_count",powerCount,0)
			local ability = Hero:FindAbilityByName("ability_common_power_buff")
			if ability then
				if(Hero:GetPrimaryAttribute()==0)then
					Hero:SetModifierStackCount("common_thdots_power_str_buff",ability,powerCount)
				elseif(Hero:GetPrimaryAttribute()==1)then
					Hero:SetModifierStackCount("common_thdots_power_agi_buff",ability,powerCount)
				elseif(Hero:GetPrimaryAttribute()==2)then
					Hero:SetModifierStackCount("common_thdots_power_int_buff",ability,powerCount)
				end
			end
		end
	end
	Collection:RemoveSelf()
end

function OnCollectionPowerMove(target,caster)
	local vecTarget = target:GetOrigin()
	local vecCaster = caster:GetOrigin()
	local speed = caster:GetContext("ability_collection_power_speed") + 1
	local radForward = GetRadBetweenTwoVec2D(vecTarget,vecCaster)
	local vecForward = Vector(math.cos(radForward) * speed,math.sin(radForward) * speed,1)
	vecTarget = vecTarget + vecForward
	
	target:SetOrigin(vecTarget)
	caster:SetContextNum("ability_collection_power_speed",speed,0)
	if(GetDistanceBetweenTwoVec2D(vecTarget,vecCaster)<50)then
		OnGetCollection(target,caster)
	end
end

function OnCollectionMoveToMaster(keys)
	local Collection = keys.caster
	local Hero = keys.target
	if (Collection~=nil and Hero:IsRealHero()) then
		local vecCollection = Collection:GetAbsOrigin()
		local vecHero = Hero:GetAbsOrigin()
		local Vec = vecHero - vecCollection
		local Distance = GetDistanceBetweenTwoVec2D(vecHero,vecCollection)
		if (Distance<keys.FindRadius) then
			local MoveDistance = (keys.FindRadius-Distance)/keys.FindRadius*keys.MaxMovespeed
			local ts=keys.FindRadius/GetDistanceBetweenTwoVec2D(vecHero,vecCollection)
			Collection:SetAbsOrigin(vecCollection + Vec:Normalized()*MoveDistance)
			if(GetDistanceBetweenTwoVec2D(vecCollection,vecHero)<25)then
				OnGetCollection(Collection,Hero)
			end
		end
	end
end
