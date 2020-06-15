
----------------------------------------------------------------------------------------------------

cast01Desire = 0;
cast02Desire = 0;
cast03Desire = 0;
cast04Desire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();

	-- Check if we're already using an ability
	if ( npcBot:IsSilenced() or npcBot:IsUsingAbility() ) then return end;

	ability04 = npcBot:GetAbilityByName( "ability_thdots_koishi04" );
	abilityEx = npcBot:GetAbilityByName( "ability_thdots_koishiex" );
	

	-- Consider using each ability
	cast04Desire = ConsiderAbilityKoishi04();
	castExDesire = ConsiderAbilityKoishiEx();

	if ( castExDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityEx );
		return;
	end
	
	if ( cast04Desire > 0 ) 
	then
		if ( abilityEx:IsFullyCastable() ) 
		then 
			npcBot:Action_UseAbility( abilityEx );
		end
		
		npcBot:Action_UseAbility( ability04 );
		return;
	end

end

----------------------------------------------------------------------------------------------------

function ConsiderAbilityKoishiEx()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityEx:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end;
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

function ConsiderAbilityKoishi04()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not ability04:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end;

	tableNearbyEnemyHeroes1300 = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
	tableNearbyEnemyHeroes800 = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
	
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOTTOM  ) 
	then
		local tableNearbyEnemyBarracks = GetNearbyBarracks( 800, true );
		if #tableNearbyEnemyBarracks > 0 then
			if #tableNearbyEnemyHeroes1300 > 1 then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end

	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT ) 
	then
		if npcBot:GetHealth() > npcBot:GetMaxHealth() * 0.3 then
			if #tableNearbyEnemyHeroes800 >= 3 then
				return BOT_ACTION_DESIRE_MODERATE;
			end
			for _,npcEnemy in pairs( tableNearbyEnemyHeroes800 )
			do
				if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
				then
					return BOT_ACTION_DESIRE_MODERATE;
				end
			end
		end
	end

	if #tableNearbyEnemyHeroes1300 > 4 then
		return BOT_ACTION_DESIRE_MODERATE;
	end
	if #tableNearbyEnemyHeroes800 > 3 then
		return BOT_ACTION_DESIRE_MODERATE;
	end
	return BOT_ACTION_DESIRE_NONE;

end

