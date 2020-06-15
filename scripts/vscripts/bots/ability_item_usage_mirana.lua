
----------------------------------------------------------------------------------------------------

cast01Desire = 0;
cast02Desire = 0;
cast03Desire = 0;
cast04Desire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();

	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() ) then return end;

	--ability01 = npcBot:GetAbilityByName( "ability_thdots_reisenOld01" );
	ability02 = npcBot:GetAbilityByName( "ability_thdots_reisenOld02" );
	--ability03 = npcBot:GetAbilityByName( "ability_thdots_reisenOld03" );
	ability04 = npcBot:GetAbilityByName( "ability_thdots_reisenOld04" );

	-- Consider using each ability
	cast02Desire = ConsiderAbilityReisen02();
	cast04Desire = ConsiderAbilityReisen04();

	if ( cast02Desire > 0 ) 
	then
		npcBot:Action_UseAbility( ability02 );
		return;
	end

	if ( cast04Desire > 0 ) 
	then
		npcBot:Action_UseAbility( ability04 );
		return;
	end

end

----------------------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------------------

function ConsiderAbilityReisen02()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not ability02:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end;
	-- as bot has mana buff and could multi controll perfectly
	-- bot should just use this as much as possible
	return BOT_ACTION_DESIRE_HIGH;
end

function ConsiderAbilityReisen04()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not ability04:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end;
	
	-- Fighting or Retreating with hero
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT or npcBot:GetActiveMode() == BOT_MODE_ATTACK ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE ); -- attack range is better, wait for api :p
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcEnemy ~= nil ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;

end

