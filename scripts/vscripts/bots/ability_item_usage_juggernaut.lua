
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

	ability01 = npcBot:GetAbilityByName( "ability_thdots_youmu01" );
	ability03 = npcBot:GetAbilityByName( "ability_thdots_youmu03" );
	ability04 = npcBot:GetAbilityByName( "ability_thdots_youmu04" );
	abilityEx = npcBot:GetAbilityByName( "ability_thdots_youmuEx" );

	-- Consider using each ability
	cast01Desire, cast01Location = ConsiderAbilityYoumu01();
	cast03Desire = ConsiderAbilityYoumu03();
	cast04Desire, cast04Target = ConsiderAbilityYoumu04();
	castexDesire = ConsiderAbilityYoumuEx()

	if ( castexDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityEx );
		return;
	end

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
		npcBot:Action_UseAbilityOnEntity( ability04 , cast04Target);
		return;
	end

end

----------------------------------------------------------------------------------------------------

function CanCastYoumu01OnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end

function CanCastYoumu03OnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end

function CanCastYoumu04OnTarget( npcTarget )
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
		if ( npcBot:GetTarget() == npcEnemy and CanCastYoumu04OnTarget( npcEnemy )  ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
		
		if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
		then
			if ( CanCastYoumu04OnTarget( npcEnemy ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
		
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
	
end

----------------------------------------------------------------------------------------------------

function ConsiderAbilityYoumuEx()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not ability01:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end;

	-- consider attack range
	local nCastRange = 220;

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange , true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:GetAttackTarget() == npcBot ) 
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
		
	end

	return BOT_ACTION_DESIRE_NONE;
end

----------------------------------------------------------------------------------------------------

function ConsiderAbilityYoumu01()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not ability01:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end;

	-- Get some of its values
	local nRadius = ability01:GetSpecialValueInt( "radius" );
	local nCastRange = ability01:GetCastRange();
	local nDamage = ability01:GetAbilityDamage();

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	if ( npcBot:GetActiveMode() == BOT_MODE_ATTACK and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange , true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:GetTarget() == npcEnemy and CanCastYoumu01OnTarget( npcEnemy )  ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
			end
			
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
			if ( CanCastYoumu01OnTarget( npcTarget ) )
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation();
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil;
end

----------------------------------------------------------------------------------------------------

function ConsiderAbilityYoumu03()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not ability03:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end;
	

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_ATTACK ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 300, true, BOT_MODE_NONE );
		if ( #tableNearbyEnemyHeroes > 0 ) then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

----------------------------------------------------------------------------------------------------

function ConsiderAbilityYoumu04()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not ability04:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE,nil;
	end;

	local nCastRange = ability04:GetCastRange();
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:GetTarget() == npcEnemy and CanCastYoumu04OnTarget( npcEnemy )  ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
				
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				if ( CanCastYoumu04OnTarget( npcEnemy ) ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
				end
			end
		end
	end
	
	-- Get some of its values
	local nCastRange = ability04:GetCastRange();

	if ( npcBot:GetActiveMode() == BOT_MODE_ATTACK ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange , true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:GetTarget() == npcEnemy and npcEnemy:GetArmor() < 5.0 and CanCastYoumu04OnTarget( npcEnemy ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE,npcEnemy;
			end
		end
	end

	-- extremely want attack -> direct util
	if ( npcBot:GetActiveMode() == BOT_MODE_ATTACK and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange , true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:GetTarget() == npcEnemy and CanCastYoumu04OnTarget( npcEnemy ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE,npcEnemy;
			end
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
			if ( CanCastYoumu04OnTarget( npcTarget ) )
			then
				return BOT_ACTION_DESIRE_HIGH,npcTarget;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil;

end

