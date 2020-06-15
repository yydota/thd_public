
local function IsItemAvailable(item_name)
    local npcBot = GetBot()
    for i = 0, 5 do
        local item = npcBot:GetItemInSlot(i)
        if (item ~= nil) then
            if (item:GetName() == item_name) then
				return item
            end
        end
    end
    return
end

----------------------------------------------------------------------------------------------------

cast01Desire = 0;
cast02Desire = 0;
cast03Desire = 0;
cast04Desire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();

	-- Check if we're already using an ability
	if ( npcBot:IsSilenced() or npcBot:IsUsingAbility() ) then return end;

	ability01 = npcBot:GetAbilityByName( "ability_thdots_wriggle01" );
	ability02 = npcBot:GetAbilityByName( "death_prophet_exorcism" );
	--ability03 = npcBot:GetAbilityByName( "ability_thdots_wriggle03" );
	--ability04 = npcBot:GetAbilityByName( "ability_thdots_wriggle04" );
	item_yukkuri = IsItemAvailable( "item_yukkuri_stick" )
	
	-- Consider using each ability
	cast01Desire = ConsiderAbilityWriggle01();
	cast02Desire = ConsiderAbilityWriggle02();
	
	if ( item_yukkuri~=nil and item_yukkuri:IsFullyCastable() )
	then 
		--print("item_yukkuri exist")
		castItemYukkuriDesire, castItemYukkuriTarget = ConsiderItemYukkuri()
		if ( castItemYukkuriDesire > 0 ) 
		then
			--print("item_yukkuri luanch")
			npcBot:Action_UseAbilityOnEntity( item_yukkuri, castItemYukkuriTarget );
			return;
		end
	end
	
	if ( cast01Desire > 0 ) 
	then
		npcBot:Action_UseAbility( ability01 );
		return;
	end

	if ( cast02Desire > 0 ) 
	then
		npcBot:Action_UseAbility( ability02 );
		return;
	end

end

----------------------------------------------------------------------------------------------------
function CanCastWriggle01OnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
----------------------------------------------------------------------------------------------------
function ConsiderItemYukkuri()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not item_stun:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, nil;
	end;

	-- Get some of its values
	local nCastRange = item_stun:GetCastRange();
	--print(nCastRange)
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange , true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcBot:GetTarget() == npcEnemy and CanCastWriggle01OnTarget( npcEnemy )  ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
		
		if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
		then
			if ( CanCastWriggle01OnTarget( npcEnemy ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
		
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
	
end

function ConsiderAbilityWriggle01()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not ability01:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end;
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000 , true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy ~= nil ) 
		then
			return BOT_ACTION_DESIRE_NONE;
		end
		
	end
	
	return BOT_ACTION_DESIRE_HIGH;
	
end

----------------------------------------------------------------------------------------------------

function ConsiderAbilityWriggle02()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not ability02:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end;
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 400 , true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy ~= nil ) 
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
		
	end
	
	return BOT_ACTION_DESIRE_NONE;
	
end
