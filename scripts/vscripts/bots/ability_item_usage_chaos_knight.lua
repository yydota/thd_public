
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
    return nil
end

----------------------------------------------------------------------------------------------------

cast01Desire = 0;
cast02Desire = 0;
cast03Desire = 0;
cast04Desire = 0;

is_safe = 0;

function MyItemUsageThink()
	
	local npcBot = GetBot();

	-- Check if we're already using an ability
	if ( npcBot:IsMuted() or npcBot:IsUsingAbility() ) then return end;

	item_stun = IsItemAvailable( "item_yuetufensuijvren" )
	if item_stun == nil then
		item_stun = IsItemAvailable( "item_pocket_watch" )
	end
	
	if ( item_stun~=nil and item_stun:IsFullyCastable() )
	then 
		--print("stun item exist")
		castItemStunDesire, castItemStunTarget = ConsiderItemStun()
		if ( castItemStunDesire > 0 ) 
		then
			--print("stun luanch")
			npcBot:Action_UseAbilityOnEntity( item_stun, castItemStunTarget );
			return;
		end
	end

end

function AbilityUsageThink()
	
	MyItemUsageThink();
	local npcBot = GetBot();

	-- Check if we're already using an ability
	if ( npcBot:IsSilenced() or npcBot:IsUsingAbility() ) then return end;

	ability01 = npcBot:GetAbilityByName( "ability_thdots_mokou01" );
	--ability03 = npcBot:GetAbilityByName( "ability_thdots_mokou03" );
	ability03 = npcBot:GetAbilityByName( "phoenix_supernova" );
	ability04 = npcBot:GetAbilityByName( "ability_thdots_mokou04" );
	
	-- Consider using each ability
	cast01Desire, cast01Location = ConsiderAbilityMokou01();
	cast03Desire = ConsiderAbilityMokou03();
	cast04Desire = ConsiderAbilityMokou04();
	
	if ( cast01Desire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( ability01, cast01Location );
		return;
	end

	if ( cast03Desire > 0 ) 
	then
		npcBot:Action_UseAbility( ability03 );
		return;
	end

	if ( cast04Desire > 0 ) 
	then
		npcBot:Action_UseAbility( ability04 );
		return;
	end

end

----------------------------------------------------------------------------------------------------
function CanCastMokou01OnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

----------------------------------------------------------------------------------------------------

function ConsiderItemStun()

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
		if ( npcBot:GetTarget() == npcEnemy and CanCastMokou01OnTarget( npcEnemy )  ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
		
		if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
		then
			if ( CanCastMokou01OnTarget( npcEnemy ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
		
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
	
end

----------------------------------------------------------------------------------------------------

function ConsiderAbilityMokou01()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not ability01:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end;

	-- Get some of its values
	local nRadius = ability01:GetSpecialValueInt( "radius" );
	local nCastRange = ability01:GetCastRange();
	local nDamage = ability01:GetLevel() * 70 + 70;

	--attack mode
	if ( npcBot:GetActiveMode() == BOT_MODE_ATTACK and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange , true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:GetTarget() == npcEnemy and CanCastMokou01OnTarget( npcEnemy ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end

	-- Can kill enemy hero
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange , true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( CanCastMokou01OnTarget( npcEnemy ) and nDamage > npcEnemy:GetHealth() ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
		end
	end
	
	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're farming and can kill 3+ creeps with LSA
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM ) then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, nDamage );

		if ( locationAoE.count >= 3 ) then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
		end
	end

	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOTTOM or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOTTOM ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );

		if ( locationAoE.count >= 4 ) 
		then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
		end
	end
	
	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		
		if ( npcTarget ~= nil ) 
		then
			if ( CanCastMokou01OnTarget( npcTarget ) )
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation();
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
	
end

----------------------------------------------------------------------------------------------------

function ConsiderAbilityMokou03()

	local npcBot = GetBot();
	
	-- not needed
	if npcBot:GetHealth() > npcBot:GetMaxHealth() * 0.3 then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	-- Make sure it's castable
	if ( not ability03:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end;
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT ) --Need ++
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1500, true, BOT_MODE_NONE );
		if #tableNearbyEnemyHeroes > 0 then --enemy hero near by
			is_safe = GameTime(); --reset delay
			return BOT_ACTION_DESIRE_NONE;
		end
		
		-- 10 seconds delay
		if GameTime() - is_safe > 10 then return BOT_ACTION_DESIRE_HIGH;  -- check is safe or not
		else return BOT_ACTION_DESIRE_NONE; end
	end
	
	return BOT_ACTION_DESIRE_NONE;
	
end

function ConsiderAbilityMokou04()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not ability04:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end;
	
	-- Fighting or Retreating with hero
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT or npcBot:GetActiveMode() == BOT_MODE_ATTACK ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1500, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcEnemy ~= nil ) 
			then
				--print('success')
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	--print('mokou failed')
	
	return BOT_ACTION_DESIRE_NONE;

end

